defmodule Mix.Tasks.NewPost do
  use Mix.Task
  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:personal)

    title = get_title()
    url = title |> String.downcase() |> String.replace("'", "") |> String.replace(~r/\W+/, "-")
    tags = get_tags()
    related_listening = get_related_listening()
    description = "TODO"

    post_body = """
    %{
      title: "#{title}",
      description: #{description},
      author: "Andy LeClair",
      tags: #{inspect(tags)},
      related_listening: "#{related_listening}",
    }
    ---


    """

    path = "drafts/#{url}.md"

    File.write(path, post_body)

    IO.puts("Post created at #{path} --")
    IO.puts(post_body)
  end

  def get_title do
    IO.gets("Title: ") |> String.trim()
  end

  def get_tags do
    IO.gets("Tags: ") |> String.trim() |> String.split(",") |> Enum.map(&String.trim/1)
  end

  def get_related_listening do
    IO.gets("Related Listening: ") |> String.trim()
  end
end
