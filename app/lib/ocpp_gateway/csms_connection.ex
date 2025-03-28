defmodule OcppGateway.CsmsConnection do
  use GenServer
  use WebSockex

  @csms_url "wss://your-csms-server.com/ocpp"

  def start_link(charge_point_id, charge_point_pid) do
    GenServer.start_link(__MODULE__, {charge_point_id, charge_point_pid})
  end

  def init({charge_point_id, charge_point_pid}) do
    state = %{
      charge_point_id: charge_point_id,
      charge_point_pid: charge_point_pid,
      conn: nil
    }

    {:ok, conn} = WebSockex.start_link(@csms_url, __MODULE__, state)
    {:ok, %{state | conn: conn}}
  end

  def handle_cast({:send_to_csms, message}, state) do
    WebSockex.send_frame(state.conn, {:text, Jason.encode!(message)})
    {:noreply, state}
  end

  def handle_frame({:text, message}, state) do
    case Jason.decode(message) do
      {:ok, ocpp_message} ->
        send(state.charge_point_pid, {:send_to_charge_point, ocpp_message})
        {:ok, state}

      {:error, _} ->
        {:error, :invalid_json, state}
    end
  end

  def terminate(_reason, state) do
    if state.conn, do: WebSockex.close(state.conn)
    :ok
  end
end
