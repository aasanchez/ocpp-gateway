defmodule OcppGateway.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  match "/ws" do
    conn
    |> WebSockAdapter.upgrade(OcppGateway.WSHandler, %{csms_url: "ws://localhost:9000"}, [])
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
