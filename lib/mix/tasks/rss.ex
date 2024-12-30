defmodule Mix.Tasks.Rss do
  use Mix.Task
  alias Personal.Blog
  import Personal

  use Phoenix.Component
  import Phoenix.HTML

  @destination "output/feed.xml"

  @impl Mix.Task
  def run(_args) do
    items =
      Blog.all_posts()
      |> Enum.map(&link_xml/1)
      |> Enum.join()

    document = """
    <?xml version="1.0" encoding="UTF-8" ?>
    <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
      <channel>
        <title>andyleclair.dev</title>
        <description>Personal blog of Andy LeClair</description>
        <link>#{url()}</link>
        <atom:link href="#{url("rss.xml")}" rel="self" type="application/rss+xml" />
        #{items}
      </channel>
    </rss>
    """

    case File.write(@destination, document) do
      :ok ->
        Mix.shell().info([:green, "Generated file #{@destination}"])

      {:error, posix} ->
        Mix.shell().info([:red, "Failed to write to #{@destination}: #{inspect(posix)}"])
    end
  end

  defp link_xml(post) do
    """
    <item>
      <title>#{post.title}</title>
      <description>#{post.description}</description>
      <pubDate>#{rfc_822(post.date)}</pubDate>
      <link>#{url(post.path)}</link>
      <guid isPermaLink="true">#{url(post.path)}</guid>
    </item>
    """
  end
end
