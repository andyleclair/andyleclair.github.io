%{
  title: "Dev Server",
  description: "Adding a development server",
  author: "Andy LeClair",
  tags: ["elixir", "meta"],
  related_listening: "https://www.youtube.com/watch?v=SJnfdEX0QWk",
}
---

A minor annoyance while developing this site is that I've not really had a good way to iterate on the markup of the pages, nor a good way to preview how a post will look before I publish it. Annoying! 

What I've been doing is just a string of `fish` commands to rebuild the whole site and then start a python server in the `/output` directory. Let's do better!

First, we'll pull in [Bandit](https://github.com/mtrudel/bandit) to serve the stuff, and then we'll pull in [FileSystem](https://github.com/falood/file_system) to watch for changes.

```elixir
{:bandit, "~> 1.0"},
{:plug_static_index_html, "~> 1.0"},
{:file_system, "~> 1.0", only: :dev}
```

I'm using `plug_static_index_html` but it hasn't been updated in years, and it's one file, I could just pull it in. It needs to be updated and emits a warning. Maybe the author will take a PR?

I've added this `Plug` which handles serving the static files and the `index.html` file. It would be nice if `Plug.Static` could do that automatically. There have been closed PRs that would do it, but apparently it's not wanted? Fair enough.

```elixir
defmodule Personal.Router do
  use Plug.Router
  plug :match
  plug :dispatch

  get "/drafts" do
    send_resp(conn, 200, "drafts")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end

defmodule Personal.DevServer do
  use Plug.Builder

  plug Plug.Static.IndexHtml, at: "/"

  plug Plug.Static,
    at: "/",
    from: "./output"

  plug Personal.Router
end

```

There's a stub for serving drafts from the `/drafts` folder, but I can live without it for now. Perfect is the enemy of good, after all.

Then we add the Filesystem watcher:

```elixir
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
    {:noreply, state}
  end

  def handle_info(
        {:file_event, watcher_pid, {_path, _events}},
        %{watcher_pid: watcher_pid} = state
      ) do
    {:noreply, state}
  end
end

```

I'm planning to get a bit fancier with this, currently I'm just rebuilding the whole site when any file changes. That's fine for now, but I'd like to get to a point where I could rebuild just one post at a time, for example.

Something else I ran into, you can't use `Mix.Task.run` in the watcher, because the posts are stored in a module attribute and I don't know how to force a recompile of the module. I think I could use `Code.compile_file` but that seems like a problem for another day.

Lastly, we need to start the watcher and the server:

```elixir
defmodule Personal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit, plug: Personal.DevServer},
      {Personal.Watcher, dirs: ["./lib", "./posts"]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Personal.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

That's it! Now I can run `iex -S mix` and have a dev server that watches the filesystem for changes.

Feel free to check out the PR [here]()
