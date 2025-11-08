defmodule Mix.Tasks.PublishPost do
  use Mix.Task

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

    File.cp!("./drafts/#{draft}", "./posts/#{today.year}/#{month}-#{day}-#{draft}")
    File.rm!("./drafts/#{draft}")
  end

  def get_draft do
    IO.gets("Which draft post would you like to publish?: ")
    |> String.trim()
    |> String.to_integer()
  end
end
