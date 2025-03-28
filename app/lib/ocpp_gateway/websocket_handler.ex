defmodule OcppGateway.ChargePoint.WebSocketHandler do
  @behaviour :cowboy_websocket
  @ocpp_protocols ["ocpp1.6", "ocpp2.0.1"]

  def init(req, _opts) do
    charge_point_id = get_charge_point_id(req)
    protocols = :cowboy_req.parse_header("sec-websocket-protocol", req)

    case validate_protocols(protocols) do
      {:ok, protocol} ->
        req = :cowboy_req.set_resp_header("sec-websocket-protocol", protocol, req)
        {:cowboy_websocket, req, %{charge_point_id: charge_point_id, csms_connection: nil}}

      :error ->
        {:ok, :cowboy_req.reply(400, req), %{}}
    end
  end

  def websocket_init(state) do
    case OcppGateway.CsmsConnection.start_link(state.charge_point_id, self()) do
      {:ok, csms_connection} ->
        {:ok, %{state | csms_connection: csms_connection}}

      {:error, reason} ->
        {:reply, {:close, 1008, "Failed to connect to CSMS"}, state}
    end
  end

  def websocket_handle({:text, message}, state) do
    case Jason.decode(message) do
      {:ok, ocpp_message} ->
        OcppGateway.MessageProcessor.process_incoming(ocpp_message, state.charge_point_id)
        {:ok, state}

      {:error, _} ->
        {:reply, {:text, error_response("Invalid JSON")}, state}
    end
  end

  def websocket_info({:send_to_charge_point, message}, state) do
    {:reply, {:text, Jason.encode!(message)}, state}
  end

  def terminate(_reason, _req, state) do
    if state.csms_connection, do: GenServer.stop(state.csms_connection)
    :ok
  end

  defp get_charge_point_id(req) do
    :cowboy_req.binding(:charge_point_id, req) ||
      :cowboy_req.header("charge-point-id", req) ||
      raise "Charge Point ID missing"
  end

  defp validate_protocols(protocols) do
    Enum.find_value(@ocpp_protocols, fn protocol ->
      if protocol in protocols, do: {:ok, protocol}
    end) || :error
  end

  defp error_response(message) do
    Jason.encode!(%{
      "error" => message,
      "timestamp" => DateTime.utc_now() |> DateTime.to_iso8601()
    })
  end
end
