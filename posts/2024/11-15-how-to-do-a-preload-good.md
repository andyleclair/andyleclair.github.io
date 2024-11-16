%{
  title: "How To Do A Preload Good",
  description: "Avoiding N+1 queries with Ecto's preload",
  author: "Andy LeClair",
  tags: ["elixir", "ecto"],
  related_listening: "https://www.youtube.com/watch?v=nhWlJLP6QyM",
}
---

I recently had [this exchange](https://twitter.com/andyleclair/status/1857112936101134588) on Twitter about using Ecto's `Repo.preload` and I wanted to describe
the way that we handle this at Appcues. Obviously everyone has their opinions, but this has served us very well for years, and we've never posted anything about it!

Hopefully this can help somebody out there.

## The Problem

So, if you do something like `Repo.get(queryable) |> Repo.preload(:association)`, you're going to get a query for the original record, and then a query for each of the associated records. This is the classic N+1 query problem, and it's not good.

How do you solve it? More functions!

## The Solution
```elixir
def get_thing(id, opts \\ []) do
  from(t in Thing, where: t.id == ^id)
  |> preload(opts[:preload])
  |> Repo.one()
end

defp preload(query), do: preload(query, true)
defp preload(query, nil), do: query

defp preload(query, true) do
  from q in query, 
    left_join: t in assoc(q, :thing),
    left_join: s in assoc(t, :sub_thing),
    preload: [
      thing: {t, [sub_thing: s]}
    ],
    order_by: [asc: t.index]
]
end

defp preload(query, preloads) do
  from q in query, preload: ^preloads
end
```
Edit: I made a mistake here originally. Thanks to [@AtomKirk](https://twitter.com/atomkirk) for pointing it out!

What I had originally was:
```elixir
def preload(query, true) do
  from q in query, preload: [
    :association,
    other_assoc: [:sub_assoc]
  ]
end
```

However, this is incorrect. The correct way to do this is to use the `left_join` with `assoc` functions.

What I described originally was how [Ash](https://ash-hq.org/) does it. In Ash, you'd do something like:
```elixir
Ash.get!(Thing, id, load: [:association, other_assoc: [:sub_assoc]])
```

For a more explicit example, check out [this code here](https://github.com/andyleclair/garage/blob/main/lib/garage_web/live/builds_live/show.ex#L197)
