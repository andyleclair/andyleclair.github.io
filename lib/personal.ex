defmodule Personal do
  use Phoenix.Component
  import Phoenix.HTML

  @site_url Application.compile_env(:personal, :root_url)

  def page(assigns) do
    ~H"""
    <.layout pages={@pages}>
      <:head>
        <title>{@page.title}</title>
        <meta name="description" content={@page.description} />
      </:head>
      <article class="mx-auto prose sm:prose-sm md:prose-md lg:prose-xl prose-pre:bg-codebg">
        <h1>{@page.title}</h1>
        {raw(@page.body)}
      </article>
    </.layout>
    """
  end

  def post(assigns) do
    ~H"""
    <.layout pages={@pages}>
      <:head>
        <title>{@post.title}</title>
        <meta name="description" content={@post.description} />
      </:head>
      <article class="mx-auto prose sm:prose-sm md:prose-md lg:prose-xl prose-pre:bg-codebg">
        <h1>{@post.title}</h1>
        <h3>{@post.description}</h3>
        <h3><a href={@post.related_listening}>Related Listening</a></h3>
        <p class="text-smurf-blood">Posted on {@post.date}</p>
        {raw(@post.body)}
      </article>
    </.layout>
    """
  end

  def blog(assigns) do
    ~H"""
    <.layout pages={@pages}>
      <:head>
        <title>andyleclair.dev</title>
        <meta name="description" content="Personal website of Andy LeClair" />
      </:head>
      <ul>
        <li :for={post <- @posts}>
          {post.date} - <a href={post.path}>{post.title}</a>
        </li>
      </ul>
    </.layout>
    """
  end

  def index(assigns) do
    ~H"""
    <.layout pages={@pages}>
      <:head>
        <title>Andy LeClair</title>
        <meta
          name="description"
          content="welcome to the personal website of andy leclair, internet wizard"
        />
      </:head>
      <article class="mx-auto prose sm:prose-sm md:prose-md lg:prose-xl prose-pre:bg-codebg">
        <h2>Welcome!</h2>
        <h3>You've found my little slice of the dang ol internet</h3>
        <p></p>
      </article>
      <article class="mx-auto prose sm:prose-sm md:prose-md lg:prose-xl prose-pre:bg-codebg">
        <h3>While you're here, check out my blog</h3>
        <ul>
          <li :for={post <- @posts}>
            {post.date} - <a href={post.path}>{post.title}</a>
          </li>
        </ul>
      </article>
    </.layout>
    """
  end

  slot :head
  attr :pages, :any

  def layout(assigns) do
    ~H"""
    <!doctype html>
    <html>
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="stylesheet" href="/assets/app.css" />
        <script type="text/javascript" src="/assets/app.js" />
        {render_slot(@head)}
      </head>

      <body class="bg-nor-easter text-smurf-blood">
        <div class="flex h-60 min-h-screen flex-col items-center">
          <header class="my-10">
            <h1 class="bg-bludacris p-10 my-4 lg:mt-10 lg:mb-14">
              <a href={url()}>andy@andyleclair.dev</a>$><span class="blink">_</span>
            </h1>

            <div class="flex flex-row justify-between">
              <h2><a href="/">Home</a></h2>
              <h2><a href="/posts/">Blog</a></h2>
              <h2 :for={page <- @pages}>
                <a href={"/pages/#{page.id}.html"}>{page.title}</a>
              </h2>
            </div>
          </header>
          <main class="flex flex-col mx-auto relative grow min-h-96 flex-1 p-4 justify-items-center">
            {render_slot(@inner_block)}
          </main>
          <footer class="mt-24 bg-bludacris p-4 text-center">
            © Andy LeClair 2026 | <a href="/atom.xml">Atom</a>
            | <a href="/feed.xml">RSS</a>
            |
            <a href="https://github.com/andyleclair/andyleclair.github.io" target="_blank">
              Site Source
            </a>
          </footer>
        </div>
      </body>
    </html>
    """
  end

  @output_dir "./output"
  File.mkdir_p!(@output_dir)

  def build do
    File.mkdir_p!(@output_dir <> "/posts")

    posts = Personal.Blog.all_posts()
    pages = Personal.Pages.all_pages()

    render_file("index.html", index(%{posts: posts, pages: pages}))
    render_file("posts/index.html", blog(%{posts: posts, pages: pages}))

    for page <- pages do
      dir = Path.dirname(page.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      render_file(page.path, page(%{page: page, pages: pages}))
    end

    for post <- posts do
      dir = Path.dirname(post.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      render_file(post.path, post(%{post: post, pages: pages}))
    end

    :ok
  end

  def render_file(path, rendered) do
    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    File.write!(output, safe)
  end

  @doc """
    Helper to return an absolute URL for a given path
  """
  def url(path \\ "") do
    "#{@site_url}/#{path}"
  end

  def rfc_3339(date) do
    Calendar.strftime(date, "%Y-%m-%dT00:00:00-05:00")
  end

  def rfc_822(date) do
    Calendar.strftime(date, "%a, %d %b %Y 00:00:00 EST")
  end
end
