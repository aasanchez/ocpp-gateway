defmodule OcppGateway.ChargePointRegistry do
  use GenServer

  # Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def register(charge_point_id, csms_conn) do
    GenServer.call(__MODULE__, {:register, charge_point_id, csms_conn})
  end

  def get_csms_connection(charge_point_id) do
    GenServer.call(__MODULE__, {:get_connection, charge_point_id})
  end

  def update_status(charge_point_id, status) do
    GenServer.cast(__MODULE__, {:update_status, charge_point_id, status})
  end

  def record_heartbeat(charge_point_id) do
    GenServer.cast(__MODULE__, {:record_heartbeat, charge_point_id})
  end

  # Server callbacks
  def init(state) do
    {:ok, state}
  end

  def handle_call({:register, charge_point_id, csms_conn}, _from, state) do
    {:reply, :ok, Map.put(state, charge_point_id, %{
      csms_conn: csms_conn,
      status: :connecting,
      last_heartbeat: nil
    })}
  end

  def handle_call({:get_connection, charge_point_id}, _from, state) do
    case Map.get(state, charge_point_id) do
      nil -> {:reply, {:error, :not_found}, state}
      data -> {:reply, {:ok, data.csms_conn}, state}
    end
  end

  def handle_cast({:update_status, charge_point_id, status}, state) do
    case Map.get(state, charge_point_id) do
      nil -> {:noreply, state}
      data ->
        updated = Map.put(data, :status, status)
        {:noreply, Map.put(state, charge_point_id, updated)}
    end
  end

  def handle_cast({:record_heartbeat, charge_point_id}, state) do
    case Map.get(state, charge_point_id) do
      nil -> {:noreply, state}
      data ->
        updated = Map.put(data, :last_heartbeat, DateTime.utc_now())
        {:noreply, Map.put(state, charge_point_id, updated)}
    end
  end
end
