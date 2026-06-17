defmodule Personal.Post do
  @fields [
    :id,
    :author,
    :title,
    :body,
    :description,
    :tags,
    :date,
    :path,
    :og_image_path,
    :related_listening
  ]
  @enforce_keys @fields
  defstruct @fields

  def build(filename, attrs, body) do
    path = Path.rootname(filename)
    [year, month_day_id] = path |> Path.split() |> Enum.take(-2)
    path = path <> ".html"
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    month = String.pad_leading(month, 2, "0")
    day = String.pad_leading(day, 2, "0")
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")
    og_path = Path.join([Personal.url(), "assets", "images", "og", Path.rootname(path)]) <> ".png"

    struct!(
      __MODULE__,
      [id: id, date: date, body: body, path: path, og_image_path: og_path] ++ Map.to_list(attrs)
    )
  end
end
