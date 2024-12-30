defmodule Mix.Tasks.Atom do
  use Mix.Task
  alias Personal.Blog
  import Personal

  @atom_feed_path "output/atom.xml"

  @impl Mix.Task
  def run(_args) do
    posts = Blog.all_posts()

    items =
      posts
      |> Enum.map(&entry/1)
      |> Enum.join()

    last_updated = List.first(posts).date |> rfc_3339()

    document = """
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>andyleclair.dev</title>
      <link href="#{url()}" />
      <link href="#{url("atom.xml")}" rel="self" />
      <updated>#{last_updated}</updated>
      <author>
        <name>Andy LeClair</name>
      </author>
      <id>#{url()}</id>

      #{items}
    </feed>
    """

    case File.write(@atom_feed_path, document) do
      :ok ->
        Mix.shell().info([:green, "Generated file #{@atom_feed_path}"])

      {:error, posix} ->
        Mix.shell().info([:red, "Failed to write to #{@atom_feed_path}: #{inspect(posix)}"])
    end
  end

  def entry(post) do
    """
    <entry>
      <title>#{post.title}</title>
      <link href="#{url(post.path)}" />
      <id>#{url(post.path)}</id>
      <updated>#{rfc_3339(post.date)}</updated>
      <summary>#{post.description}</summary>
    </entry>
    """
  end
end
