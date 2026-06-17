import Config

IO.puts("Length of app password: #{String.length(System.get_env("APP_PASSWORD"))}")

config :personal,
  app_password: System.get_env("APP_PASSWORD")
