import Config

config :ocpp_gateway,
  port: 4000,
  csms_url: System.get_env("CSMS_URL") || "wss://your-csms-server.com/ocpp"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:charge_point_id]
