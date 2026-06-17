defmodule Personal.StandardSite do
  alias Personal.Post
  alias Site.Standard.Document
  alias Atex.XRPC.LoginClient

  def publish_document(%LoginClient{} = client, %Post{} = post) do
    if enabled?() do
      Atex.XRPC.post(client, %Com.Atproto.Repo.CreateRecord{
        input: %Com.Atproto.Repo.CreateRecord.Input{
          repo: did(),
          collection: "site.standard.document",
          rkey: Atex.TID.now() |> to_string(),
          record: document(post)
        }
      })
    end
  end

  def document(%Post{
        tags: tags,
        title: title,
        path: path,
        description: description,
        date: date
      }) do
    published_at = date |> DateTime.new!(~T[04:20:00]) |> DateTime.to_iso8601()

    %Document{
      site: well_known(),
      title: title,
      description: description,
      path: path,
      publishedAt: published_at,
      tags: tags
    }
  end

  def well_known do
    Application.get_env(:personal, :well_known)
  end

  def did do
    Application.get_env(:personal, :did)
  end

  def enabled? do
    Application.get_env(:personal, :env) == :prod
  end
end
