import Config

config :joken, default_signer: System.get_env("SERVER_SECRET")
