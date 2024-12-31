defmodule Personal.Watcher do
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  # These emit a LOT of events, [:modified] is fine
  def handle_info(
        {:file_event, watcher_pid, {path, [:modified]}},
        %{watcher_pid: watcher_pid} = state
      ) do
    Mix.shell().info(["File modified: #{path}"])
    Mix.shell().info(["Site Rebuilding"])
    # Currently, we're just recompiling the entire site
    # TODO: make this fancier based on the path
    System.cmd("mix", ["site.build"])
    Mix.shell().info([:green, "Site rebuilt"])
    {:noreply, state}
  end

  def handle_info(
        {:file_event, watcher_pid, {_path, _events}},
        %{watcher_pid: watcher_pid} = state
      ) do
    {:noreply, state}
  end
end
