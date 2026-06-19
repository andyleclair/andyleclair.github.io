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
        <meta property="og:title" content={@page.title} />
        <meta property="og:type" content="website" />
        <meta property="og:url" content={url(@page.path)} />
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
        <meta property="og:title" content={@post.title} />
        <meta property="og:type" content="website" />
        <meta property="og:url" content={url(@post.html_path)} />
        <meta property="og:image" content={url(@post.og_image_path)} />
        <link rel="site.standard.document" href={@post.standard_site_document} />
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
        <meta property="og:title" content="andy leclair dot dev" />
        <meta property="og:description" content="Personal website of Andy LeClair" />
        <meta property="og:type" content="website" />
        <meta property="og:url" content={url()} />
        <meta property="og:image" content={url("/assets/images/og/main_header.png")} />
      </:head>
      <ul>
        <li :for={post <- @posts}>
          {post.date} - <a href={post.html_path}>{post.title}</a>
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
        <meta property="og:title" content="andy leclair dot dev" />
        <meta
          property="og:description"
          content="welcome to the personal website of andy leclair, internet wizard"
        />
        <meta property="og:type" content="website" />
        <meta property="og:url" content={url()} />
        <meta property="og:image" content={url("/assets/images/og/main_header.png")} />
        <!-- PostHog analytics -->
        <script>
          !function(t,e){var o,n,p,r;e.__SV||(window.posthog && window.posthog.__loaded)||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split(".");2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement("script")).type="text/javascript",p.crossOrigin="anonymous",p.async=!0,p.src=s.api_host.replace(".i.posthog.com","-assets.i.posthog.com")+"/static/array.js",(r=t.getElementsByTagName("script")[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a="posthog",u.people=u.people||[],u.toString=function(t){var e="posthog";return"posthog"!==a&&(e+="."+a),t||(e+=" (stub)"),e},u.people.toString=function(){return u.toString(1)+".people (stub)"},o="Pn On init Wn Qn ki Gn Kn zn capture calculateEventProperties rs register register_once register_for_session unregister unregister_for_session os getFeatureFlag getFeatureFlagPayload getFeatureFlagResult isFeatureEnabled reloadFeatureFlags updateFlags updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures on onFeatureFlags onSurveysLoaded onSessionId getSurveys getActiveMatchingSurveys renderSurvey displaySurvey cancelPendingSurvey canRenderSurvey canRenderSurveyAsync ls identify setPersonProperties unsetPersonProperties group resetGroups setPersonPropertiesForFlags resetPersonPropertiesForFlags setGroupPropertiesForFlags resetGroupPropertiesForFlags reset setIdentity clearIdentity get_distinct_id getGroups get_session_id get_session_replay_url alias set_config startSessionRecording stopSessionRecording sessionRecordingStarted captureException addExceptionStep captureLog startExceptionAutocapture stopExceptionAutocapture loadToolbar get_property getSessionProperty ns es createPersonProfile setInternalOrTestUser ss Hn cs opt_in_capturing opt_out_capturing has_opted_in_capturing has_opted_out_capturing get_explicit_consent_status is_capturing clear_opt_in_out_capturing Yn debug Ci gr getPageViewId captureTraceFeedback captureTraceMetric qn".split(" "),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);
          posthog.init('phc_vhZWEzTVQHGiiGk9Gv3stmBmYwZeE3JnZziYuHvwPsUt', {
              api_host: 'https://us.i.posthog.com',
              defaults: '2026-05-30',
              person_profiles: 'always',
          })
        </script>
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
            {post.date} - <a href={post.html_path}>{post.title}</a>
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
        <link
          rel="site.standard.publication"
          href={Application.get_env(:personal, :well_known)}
        />
        <meta property="og:site_name" content="andy leclair dot dev" />
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
    File.mkdir_p!(@output_dir <> "/.well-known")

    posts = Personal.Blog.all_posts()
    pages = Personal.Pages.all_pages()

    render_file("index.html", index(%{posts: posts, pages: pages}))
    render_file("posts/index.html", blog(%{posts: posts, pages: pages}))
    render_text(".well-known/site.standard.publication", well_known())

    for page <- pages do
      dir = Path.dirname(page.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      render_file(page.path, page(%{page: page, pages: pages}))
    end

    for post <- posts do
      dir = Path.dirname(post.html_path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      Personal.Opengraph.generate_image(post)

      render_file(post.html_path, post(%{post: post, pages: pages}))
    end

    :ok
  end

  def well_known do
    Application.get_env(:personal, :well_known)
  end

  def render_file(path, rendered) do
    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    File.write!(output, safe)
  end

  def render_text(path, text) do
    output = Path.join([@output_dir, path])
    File.write!(output, text)
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

  def env do
    Application.get_env(:personal, :env)
  end
end
