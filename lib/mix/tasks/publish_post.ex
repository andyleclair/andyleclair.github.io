defmodule Mix.Tasks.PublishPost do
  use Mix.Task
  alias Personal.Post
  alias Personal.StandardSite

  @impl Mix.Task
  def run(_args) do
    {:ok, drafts} = File.ls("./drafts")

    indexed_drafts = Enum.with_index(drafts, 1) |> Enum.map(fn {path, i} -> "#{i}. #{path}" end)

    IO.puts("""
    Listing Draft posts:
    #{Enum.join(indexed_drafts, "\n")}
    """)

    index = get_draft()
    draft = Enum.at(drafts, index - 1)

    IO.puts("Publishing #{draft}")

    today = Date.utc_today()

    month = today.month |> to_string() |> String.pad_leading(2, "0")
    day = today.day |> to_string() |> String.pad_leading(2, "0")

    dest_path = "./posts/#{today.year}/#{month}-#{day}-#{draft}"

    File.cp!("./drafts/#{draft}", dest_path)
    File.rm!("./drafts/#{draft}")

    # Update the frontmatter with the published_at time
    {:ok, attrs, body} = parse_contents(dest_path, File.read!(dest_path))

    Post.build(dest_path, attrs, body)
    |> publish_document()

    :ok
  end

  def publish_document(post) do
    {:ok, client} =
      Atex.XRPC.LoginClient.login(
        "https://bsky.social",
        Application.get_env(:personal, :at_handle),
        Application.get_env(:personal, :app_password)
      )

    post = put_in(post, [Access.key(:published_at)], DateTime.utc_now() |> DateTime.to_iso8601())

    {:ok, %Req.Response{status: 200, body: %Com.Atproto.Repo.CreateRecord.Output{uri: uri}},
     _client} = StandardSite.publish_document(client, post)

    post = put_in(post, [Access.key(:standard_site_document)], uri)

    Post.write(post)
  end

  def get_draft do
    IO.gets("Which draft post would you like to publish?: ")
    |> String.trim()
    |> String.to_integer()
  end

  defp parse_contents(path, contents) do
    case :binary.split(contents, ["\n---\n", "\r\n---\r\n"]) do
      [_] ->
        {:error, "could not find separator --- in #{inspect(path)}"}

      [code, body] ->
        case Code.eval_string(code, []) do
          {%{} = attrs, _} ->
            {:ok, attrs, body}

          {other, _} ->
            {:error,
             "expected attributes for #{inspect(path)} to return a map, got: #{inspect(other)}"}
        end
    end
  end
end
