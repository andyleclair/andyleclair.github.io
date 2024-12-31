defmodule Personal.Router do
  use Plug.Router
  plug :match
  plug :dispatch

  get "/drafts" do
    send_resp(conn, 200, "drafts")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end

defmodule Personal.DevServer do
  use Plug.Builder

  plug Plug.Static.IndexHtml, at: "/"

  plug Plug.Static,
    at: "/",
    from: "./output"

  plug Personal.Router
end
