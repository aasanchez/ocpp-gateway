defmodule OcppGateway.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/ocpp/:charge_point_id" do
    conn = fetch_query_params(conn)
    opts = %{}
    :cowboy_websocket.upgrade(conn, OcppGateway.ChargePoint.WebSocketHandler, opts)
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
