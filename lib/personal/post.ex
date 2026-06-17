defmodule Personal.Post do
  @required [
    :id,
    :author,
    :title,
    :body,
    :description,
    :tags,
    :date,
    :md_path,
    :html_path,
    :og_image_path,
    :related_listening
  ]
  @optional [
    :published_at,
    :standard_site_document
  ]

  @enforce_keys @required
  defstruct @required ++ @optional

  def build(filename, attrs, body) do
    path = Path.rootname(filename)
    [year, month_day_id] = path |> Path.split() |> Enum.take(-2)
    path = path <> ".html"
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    month = String.pad_leading(month, 2, "0")
    day = String.pad_leading(day, 2, "0")
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")
    og_path = Path.join(["assets", "images", "og", Path.rootname(path)]) <> ".png"

    struct!(
      __MODULE__,
      [id: id, date: date, body: body, html_path: path, og_image_path: og_path, md_path: filename] ++
        Map.to_list(attrs)
    )
  end

  @doc """
  Update the post file on disk
  """
  def write(%__MODULE__{md_path: path} = post) do
    frontmatter =
      post
      |> Map.from_struct()
      |> Map.take([
        :title,
        :author,
        :tags,
        :description,
        :related_listening,
        :standard_site_document,
        :published_at
      ])
      |> inspect(pretty: true)

    # Extract the markdown body
    [_, md] = File.read!(path) |> String.split("---")

    File.open!(path, [:write], fn file ->
      IO.binwrite(file, frontmatter)
      IO.binwrite(file, "\n---")
      IO.binwrite(file, md)
    end)
  end
end
