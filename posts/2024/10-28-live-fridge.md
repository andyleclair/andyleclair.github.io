%{
  description: "My take on an internet fridge magnet poetry experience using Elixir, Ash, and LiveView.",
  author: "Andy LeClair",
  title: "Live Fridge",
  published_at: "2024-10-28T04:20:00Z",
  related_listening: "https://open.spotify.com/playlist/0hTDYi34toP4tTE8rCAkgY?si=671fa097213c4103",
  standard_site_document: "at://did:plc:elpdw5nwg3yzxouqzzjqjg43/site.standard.document/3moha2rft5tid",
  tags: ["elixir", "ash", "liveview"]
}
---
I’ve spent some time over the past few weeks putting this little project together. It’s a realtime multiplayer fridge magnet poetry experience built with LiveView, Ash and a little JS (just hooks!).

I’m working on putting together a video walkthrough of the design choices and how I go about building code like this, but it’s still WIP (never made a screencast before!). 
That said, I tried to structure the commits into atomic chunks, so if you checkout any commit, you should be able to see the state of the project at that point and how I evolved it over time.

There are some cool Elixir tricks in here (hashing terms to HSL color space! Atomic counters for online presence!) but I want to show off how easy it is to get super slick realtime multiplayer experiences going in Elixir 

The code is available here:

[Source](https://github.com/andyleclair/live_fridge)

The site is live here:

[livefridge](https://live-fridge.fly.dev)
