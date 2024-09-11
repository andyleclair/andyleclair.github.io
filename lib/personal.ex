defmodule Personal do
  use Phoenix.Component
  import Phoenix.HTML

  def post(assigns) do
    ~H"""
    <.layout>
      <article class="prose lg:prose-xl prose-pre:bg-codebg">
        <h1><%= @post.title %></h1>
        <h3><%= @post.description %></h3>
        <h3><a href={@post.related_listening}>Related Listening</a></h3>
        <p class="text-smurf-blood">Posted on <%= @post.date %></p>
        <%= raw(@post.body) %>
      </article>
    </.layout>
    """
  end

  def index(assigns) do
    ~H"""
    <.layout>
      <h2 class="text-xl">Blog!</h2>
      <ul>
        <li :for={post <- @posts}>
          <%= post.date %> - <a href={post.path}><%= post.title %></a>
        </li>
      </ul>
    </.layout>
    """
  end

  def layout(assigns) do
    ~H"""
    <!doctype html>
    <html>
      <head>
        <meta charset="UTF-8" />
        <link rel="stylesheet" href="/assets/app.css" />
        <script type="text/javascript" src="/assets/app.js" />
      </head>

      <body class="bg-nor-easter text-smurf-blood">
        <div class="flex h-60 min-h-screen flex-col items-center">
          <header class="bg-bludacris p-10 my-4 lg:mt-10 lg:mb-14">
            <h1>andy@andyleclair.dev$><span class="blink">_</span></h1>
          </header>
          <main class="relative grow min-h-96 flex-1 p-4">
            <%= render_slot(@inner_block) %>
          </main>
          <footer class="bg-bludacris p-4 text-center">© Andy LeClair 2024</footer>
        </div>
      </body>
    </html>
    """
  end

  @output_dir "./output"
  File.mkdir_p!(@output_dir)

  def build() do
    posts = Personal.Blog.all_posts()

    render_file("index.html", index(%{posts: posts}))

    for post <- posts do
      dir = Path.dirname(post.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      render_file(post.path, post(%{post: post}))
    end

    copy_static()

    :ok
  end

  @font_dir "./assets/fonts"
  @image_dir "./assets/images"
  def copy_static() do
    File.cp_r!(@font_dir, Path.join([@output_dir, "assets", "fonts"]))
    File.cp_r!(@image_dir, Path.join([@output_dir, "assets", "images"]))
  end

  def render_file(path, rendered) do
    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    File.write!(output, safe)
  end
end
