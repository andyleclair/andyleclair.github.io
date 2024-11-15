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
  |> Repo.one(query)
end

def preload(query), do: preload(query, true)
def preload(query, nil), do: query

def preload(query, true) do
  from q in query, preload: [
    :association,
    other_assoc: [:sub_assoc]
  ]
end

def preload(query, preloads) do
  from q in query, preload: ^preloads
end
```

If you need to get fancier with it, you can also use a `left_join` and get more specific with your preload conditions.
This will allow you to do things like adjust the query based on the associations, like if you'd need to sort based on
say, the index of the association.

```elixir
def preload(query, true) do
  from q in query, 
    left_join: t in assoc(q, :thing),
    left_join: s in assoc(t, :sub_thing),
    preload: [
      thing: {t, [sub_thing: s]}
    ],
    order_by: [asc: t.index]
]
end
```
That's the basic gist of it. I hope this helps someone out there!
