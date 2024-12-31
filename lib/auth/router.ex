defmodule Auth.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)

  get "/" do
    send_resp(conn, 200, "SHE LIVES!!!")
  end

  post "/tenants" do
    send_resp(conn, 400, "I have not built this yet")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
