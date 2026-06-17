defmodule Mix.Tasks.Build do
  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:personal)
    Application.ensure_all_started(:req)

    {micro, :ok} =
      :timer.tc(fn ->
        Personal.build()
      end)

    ms = micro / 1000
    Mix.shell().info([:green, "Built site in #{ms}ms"])
  end
end
