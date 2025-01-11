defmodule Mix.Tasks.Auth.CreateAdmin do
  use Mix.Task

  @shortdoc "Creates an admin user"
  def run(_) do
    Mix.Task.run("app.start")
    
    IO.puts "Creating admin user..."
    
    {:ok, user} = Auth.Accounts.Manager.create_admin_user(%{
      email: "admin@example.com",
      password: "admin123",
      tenant_id: 1  # You might want to handle this differently
    })

    IO.puts "Admin user created successfully: #{user.email}"
  end
end
