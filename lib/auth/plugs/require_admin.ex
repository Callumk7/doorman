defmodule Auth.Plugs.RequireAdmin do
  import Plug.Conn

  def init(opts), do: opts

  def call(%{assigns: assigns} = conn, _opts) do
    case assigns do
      %{current_user_role: "admin"} ->
        conn

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{error: "Admin access is required"}))
        |> halt()
    end
  end
end
