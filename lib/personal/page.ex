defmodule Personal.Page do
  @enforce_keys [
    :id,
    :author,
    :title,
    :description,
    :body,
    :path
  ]
  defstruct [:id, :author, :title, :body, :description, :path]

  def build(filename, attrs, body) do
    path = Path.rootname(filename)
    [id] = path |> Path.split() |> Enum.take(-1)
    path = path <> ".html"
    struct!(__MODULE__, [id: id, body: body, path: path] ++ Map.to_list(attrs))
  end
end
