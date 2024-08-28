defmodule Mix.Tasks.Build do
  use Mix.Task
  @impl Mix.Task
  def run(_args) do
    {micro, :ok} =
      :timer.tc(fn ->
        Personal.build()
      end)

    ms = micro / 1000
    IO.puts("BUILT in #{ms}ms")
  end
end
