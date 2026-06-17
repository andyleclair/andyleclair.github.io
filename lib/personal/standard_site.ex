defmodule Personal.StandardSite do
  alias Personal.Post
  alias Site.Standard.Document
  alias Atex.XRPC.LoginClient

  @collection "site.standard.document"

  def publish_document(%LoginClient{} = client, %Post{} = post) do
    Atex.XRPC.post(client, %Com.Atproto.Repo.CreateRecord{
      input: %Com.Atproto.Repo.CreateRecord.Input{
        repo: did(),
        collection: @collection,
        rkey: Atex.TID.now() |> to_string(),
        record: document(post)
      }
    })
  end

  def list_documents(%LoginClient{} = client) do
    request = %Com.Atproto.Repo.ListRecords{
      params: %Com.Atproto.Repo.ListRecords.Params{
        collection: @collection,
        repo: did()
      }
    }

    client
    |> list_all_documents(request)
    |> Enum.map(fn doc ->
      # Making these all 1 map makes this easier to work with
      {values, rest} = Map.pop(doc, "value")
      Map.merge(rest, values)
    end)
  end

  def list_all_documents(client, request, client \\ nil)

  def list_all_documents(client, request, nil) do
    case Atex.XRPC.get(client, request) do
      {:ok,
       %Req.Response{
         status: 200,
         body: %Com.Atproto.Repo.ListRecords.Output{cursor: nil, records: records}
       }, _client} ->
        records

      {:ok,
       %Req.Response{
         status: 200,
         body: %Com.Atproto.Repo.ListRecords.Output{cursor: cursor, records: records}
       }, client} ->
        records ++ list_all_documents(client, request, cursor)
    end
  end

  def list_all_documents(client, request, cursor) do
    request = put_in(request, [Access.key(:params), Access.key(:cursor)], cursor)

    case Atex.XRPC.get(client, request) do
      {:ok,
       %Req.Response{
         status: 200,
         body: %Com.Atproto.Repo.ListRecords.Output{cursor: nil, records: records}
       }, _client} ->
        records

      {:ok,
       %Req.Response{
         status: 200,
         body: %Com.Atproto.Repo.ListRecords.Output{cursor: cursor, records: records}
       }, client} ->
        records ++ list_all_documents(client, request, cursor)
    end
  end

  def document(%Post{
        tags: tags,
        title: title,
        html_path: path,
        description: description,
        date: date
      }) do
    published_at = date |> DateTime.new!(~T[04:20:00]) |> DateTime.to_iso8601()

    %Document{
      site: well_known(),
      title: title,
      description: description,
      # per the spec this should start with a /
      path: "/" <> path,
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
end
