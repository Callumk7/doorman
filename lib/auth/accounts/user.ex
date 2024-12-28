defmodule Auth.Accounts.User do
  defstruct id: nil,
            tenant_id: nil,
            username: nil,
            email: nil,
            password_hash: nil,
            confirmed: false,
            locked: false,
            failed_attempts: 0,
            last_login: nil,
            magic_link_token: nil,
            magic_link_token_expires_at: nil,
            password_reset_token: nil,
            password_reset_token_expires_at: nil
end
