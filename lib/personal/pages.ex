defmodule Personal.Pages do
  use NimblePublisher,
    build: Personal.Page,
    from: "./pages/*.md",
    as: :pages,
    highlighters: [:makeup_syntect, :makeup_elixir, :makeup_erlang]

  @pages Enum.sort_by(@pages, & &1.id, :desc)

  # And finally export them
  def all_pages, do: @pages
end
