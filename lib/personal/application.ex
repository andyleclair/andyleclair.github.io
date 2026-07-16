defmodule Personal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {Bandit, plug: Personal.DevServer},
        watcher()
      ]
      |> List.flatten()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Personal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def watcher do
    if Personal.env() == :dev do
      {Personal.Watcher, dirs: ["./assets/css", "./lib", "./posts"]}
    else
      []
    end
  end
end
