import Config

if File.exists?("config/#{config_env()}.secret.exs") do
  import_config("#{config_env()}.secret.exs")
end
