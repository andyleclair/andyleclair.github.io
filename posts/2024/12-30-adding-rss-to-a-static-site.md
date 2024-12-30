%{
  title: "Adding RSS to a static site",
  description: "Adding RSS and Atom feeds to this site",
  author: "Andy LeClair",
  tags: ["elixir", "meta"],
  related_listening: "https://www.youtube.com/watch?v=rVpR_WTRhmc",
}
---

At the prompting of [this github issue](https://github.com/andyleclair/andyleclair.github.io/issues/1), I've added RSS and Atom feeds to this site.

Overall this was pretty easy to get something working! Since this site is just static files deployed to Github Pages, I just built some XML as strings in Elixir and wrote them to disk. EZPZ! However, this happens to be _my_ blog and if I'm gonna do anything, I'd rather do it the _fun_ way.

I'd like to see if I can get it to work using HEEX templates. Then, I think it should be reasonably easy to make a simple knock-off of `Phoenix.VerifiedRoutes` that just gets the "routes" from the list of `Posts`. Right now I've got a simple `url` helper that gives me a hard-coded absolute URL, but I think having `~p` would be slick.

I think it will also be the time I finally get around to having a real dev server that watches the filesystem for changes.

I'm going to push what I have so far and close the issue, but I'll be back with another post about getting fancy with the XML generation.

