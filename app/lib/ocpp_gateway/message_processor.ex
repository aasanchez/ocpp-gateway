defmodule OcppGateway.MessageProcessor do
  alias OcppGateway.ChargePointRegistry

  def process_incoming(message, charge_point_id) do
    case message do
      %{"messageType" => 2, "action" => action} ->
        handle_call_action(action, message, charge_point_id)

      %{"messageType" => 3} ->
        handle_call_result(message, charge_point_id)

      %{"messageType" => 4} ->
        handle_call_error(message, charge_point_id)

      _ ->
        {:error, :invalid_message_type}
    end
  end

  defp handle_call_action("BootNotification", message, charge_point_id) do
    # Handle boot notification
    ChargePointRegistry.update_status(charge_point_id, :booted)
    forward_to_csms(charge_point_id, message)
  end

  defp handle_call_action("Heartbeat", message, charge_point_id) do
    # Update last heartbeat timestamp
    ChargePointRegistry.record_heartbeat(charge_point_id)
    forward_to_csms(charge_point_id, message)
  end

  defp handle_call_action(action, message, charge_point_id) do
    # Default handler for other actions
    forward_to_csms(charge_point_id, message)
  end

  defp handle_call_result(message, charge_point_id) do
    forward_to_csms(charge_point_id, message)
  end

  defp handle_call_error(message, charge_point_id) do
    forward_to_csms(charge_point_id, message)
  end

  defp forward_to_csms(charge_point_id, message) do
    case ChargePointRegistry.get_csms_connection(charge_point_id) do
      {:ok, csms_conn} -> GenServer.cast(csms_conn, {:send_to_csms, message})
      _ -> {:error, :no_csms_connection}
    end
  end
end
