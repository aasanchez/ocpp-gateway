defmodule OcppGateway.WSHandler do
  @behaviour WebSock

  def init(state) do
    {:ok, csms_conn, stream_ref} = connect_to_csms(nil)
    {:ok, %{csms_conn: csms_conn, stream_ref: stream_ref}}
  end

  defp connect_to_csms(_url) do
    {:ok, pid} = :gun.open('localhost', 9000)
    {:ok, _protocol} = :gun.await_up(pid)

    stream_ref = :gun.ws_upgrade(pid, "/")
    {:ok, pid, stream_ref}
  end

  def handle_in({:text, msg}, state) do
    :ok = :gun.ws_send(state.csms_conn, {:text, msg})
    {:ok, state}
  end

  def handle_info({:csms_message, msg}, state) do
    {:push, {:text, msg}, state}
  end

  def handle_cast(_msg, state), do: {:ok, state}
  def terminate(_reason, _state), do: :ok
end
