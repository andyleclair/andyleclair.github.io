%{
  title: "Things You Can Do With Ecto",
  description: "Neat tricks I've learned while working with Ecto",
  author: "Andy LeClair",
  tags: ["elixir", "ecto"],
  related_listening: "https://www.youtube.com/watch?v=SJnfdEX0QWk",
}
---

I've been hard at work at my day job porting our analytics stack from Snowflake to Clickhouse. We've needed to port over our two existing query builders (one in Javascript, one Elixir)
to one system. We're heavy users of Ecto, so naturally we would prefer to use the excellent [ecto_ch](https://github.com/plausible/ecto_ch) library to interact with Clickhouse. This mostly works, but we've run into a few
limitations that have required us to get creative. Here are a few things I've learned along the way. 

## Fragment

`fragment` is an elegant escape hatch when you need to do something specific to your database. Clickhouse has a _ton_ of specific functions, so we use `fragment` a lot.
We have a module that looks like this that we import, like `Ecto.Query`. For example, if you wanted to use Clickhouse's `argMax` aggregate to get the _latest_ value for a column, given some timestamp column (a common use-case), you could do this:

```elixir
defmodule Clickhouse.Helpers do
  import Ecto.Query

  defmacro arg_max(column, timestamp) do
    quote do
      fragment("argMax(?, ?)", unquote(column), unquote(timestamp))
    end
  end
end
```

And this works! Let's imagine you're storing user profiles. The profiles are essentially a map with the keys and values broken out into separate columns.

With a table schema like this:

```elixir
defmodule MyApp.UserProfile do
  use Ecto.Schema

  schema "user_profiles" do
    field :user_id, :string
    field :key, :string
    field :value, :string
    field :timestamp, Ch, type: "DateTime64(3)"
  end
end
```

We will not update values, instead we will just write in new values whenever some attribute changes. You can easily get the latest values for each user with a query like this:

```elixir
defmodule MyApp.Profiles do
  import Ecto.Query
  import Clickhouse.Helpers

  alias MyApp.UserProfile

  def latest_values do
    from p in UserProfile,
      select: %{
        user_id: p.user_id,
        key: p.key,
        value: arg_max(p.value, p.timestamp)
      },
      group_by: [p.user_id, p.key]
  end

end
```

The cool thing about `fragment` is that you can nest it! 

```elixir
defmacro map(key, value) do
  quote do
    fragment("map(?, ?)", unquote(key), unquote(value))
  end
end

defmacro max_map(col) do
  quote do
    fragment("maxMap(?)", unquote(col))
  end
end

def latest_profile do
  from q in subquery(
          from t in UserProfile,
            select: %{
              user_id: t.user_id,
              attrs: map(t.key, arg_max(t.value, t.timestamp))
            },
            group_by: [t.user_id]
        ),
        select: %{
          user_id: q.user_id, 
          profile: max_map(q.attrs)
        }
end
```

Now you've got Clickhouse rolling up the profiles and you'll get a map back. Neat! I am going to spend _zero_ time talking about why the function
in Clickhouse to merge nested maps is `maxMap` because _I do not know_. It simply is. But, you can see that composing these macros makes this super easy and the resulting Ecto query looks very close to what we'd get writing the query by hand. This is an especially useful property when you have a target query you're working toward and you want to work backward from that into Ecto.

That's all well and good, but let's say that you need to do some filtering. Let's say we want to find the users with a specific profile value for a given key. If you want to filter on the _latest_ values, you could do it with `having` (because `argMax` is an aggregate we need to use `having` not `where`):

```elixir
@spec matching_users(String.t(), String.t()) :: Ecto.Query.t()
def matching_users(key, value) do
  from p in UserProfile,
    select: %{
      user_id: p.user_id,
      key: p.key,
      value: arg_max(p.value, p.timestamp) |> selected_as(:value)
    },
    where: p.key == ^key,
    group_by: [p.user_id],
    having: selected_as(:value) == ^value
end
```

However, Clickhouse also provides aggregate combinators that you might want to use, such as `argMaxIfOrNull`. This combinator is like `argMax` but it has a third argument, a condition.

This leads to my next thing I learned about `fragment`: you can pass in an _expression_.

```elixir
defmacro arg_max_if_or_null(column, timestamp, condition) do
  quote do
    fragment("argMaxIfOrNull(?, ?, ?)", unquote(column), unquote(timestamp), unquote(condition))
  end
end

@spec users_with_latest_values([String.t()]) :: Ecto.Query.t()
def users_with_latest_values(attributes) do
  query =
    from p in UserProfile,
      select: %{user_id: p.user_id},
      group_by: [p.user_id]

  Enum.reduce(query, attributes, fn attr, query ->
    from q in query,
      select_merge: %{
        ^attr => arg_max_if_or_null(q.value, q.timestamp, q.key == ^attr)
      }
  end)
end
```

As you can see, the third "argument" to `arg_max_if_or_null` is an expression, but it gets interpolated into `?` inside `fragment`. Incredible! This _just works!_ When I figured this out, it really blew my mind, and I don't think the docs mention it at all.

## CTEs

If you work with analytical queries at all, you will probably encounter a CTE. These are also known as `with` statements. I'm not going to give a full primer on CTEs, but they're a way to define a subquery that you can reference later in your query. Unfortunately for us, Clickhouse doesn't materialize CTE results, so if you refer to the binding multiple times, the query gets run multiple times. I hear they're working on it! That said, CTEs definitely still have a use and we use them. It was not immediately obvious to me from the docs how I could use a CTE, so here are some things I've learned.

### You can pass `with_cte` a string!

The docs for [with_cte](https://hexdocs.pm/ecto/Ecto.Query.html#with_cte) don't say you can do this, but you can just name your CTE parts directly, with a string. This is a version
of the query from above, but using a CTE. Let's make it a little more interesting of a query, and say we also need to go get the latest event for each of those users in order to sort the data and return the latest timestamp.

```elixir
defmodule NeatEcto.Schemas.Events do
  use Ecto.Schema

  schema "events" do
    field :user_id, :string
    field :event_type, :string
    field :timestamp, Ch, type: "DateTime64(3)"
  end
end


def latest_profile_cte_version do
  attrs_query =
    from t in UserProfile,
      select: %{
        user_id: t.user_id,
        attrs: map(t.key, arg_max(t.value, t.timestamp))
      },
      group_by: [t.user_id]

  latest_events_query =
    from e in Events,
      select: %{
        user_id: e.user_id,
        latest_timestamp: max(e.timestamp)
      },
      group_by: [e.user_id]

  "attr_pairs"
  |> with_cte("attr_pairs", as: ^attrs_query)
  |> with_cte("latest_events", as: ^latest_events_query)
  |> join(:inner, [a], e in "latest_events", on: a.user_id == e.user_id)
  |> select([a, e], %{
    user_id: a.user_id,
    latest_event: e.latest_timestamp,
    profile: max_map(a.attrs)
  })
  |> order_by([a, e], desc: e.timestamp)
  |> group_by([a, e], [a.user_id])
end
```

Of course, you could join on a subquery here, but I'm just trying to illustrate the specifics of using a CTE. It's totally possible to dynamically build CTEs and that can be a super useful tool in building complex queries.

## Cheating

Ok this last one is a little dirty. Maybe even _yucky_. Ecto expects that the developer is in charge of the naming of things and that those names are mostly available at compile time. There are few places where you can essentially allow for using
user input to name things (CTEs being one!), mostly you need to be using atoms, and every BEAM developer knows you shouldn't dynamically create atoms because they're never GC'd. That leads us to the following trick:

```elixir
# Everything in life needs a limit
@substitutions for i <- 0..100, into: %{}, do: {i, :"subs_#{i}"}
def substitutions, do: @substitutions

@spec latest_profiles([String.t()]) :: Ecto.Query.t()
def latest_profiles(keys) do
  substitutions = substitutions()
  base_query = from u in UserProfile, select: %{user_id: u.user_id}

  indexed_keys = Enum.with_index(keys)

  placeholders = for {name, i} <- indexed_keys, into: %{}, do: {name, substitutions[i]}

  query =
    Enum.reduce(indexed_keys, base_query, fn {prop, i}, query ->
      prop_placeholder = placeholders[i]

      select_merge(
        query,
        [p],
        %{
          ^prop_placeholder =>
            arg_max_if_or_null(p.attribute_value, p.timestamp, p.attribute_name == ^prop)
        }
      )
    end)

  {query, placeholders}
end
```

What you _can_ do is map your user provided list of strings to a list of atoms and then just hand back the mapping along with the query. Then, some enterprising developer could use the above `latest_profiles` query inside 
a subquery. This is really useful if you need to make sure that you're able to compare on the results of the subquery externally and to make sure that the subquery only gets executed once. This technique can also be useful
if you need to return data in a specific column aliasing and it would be better to make the database do some calculation. You can execute the query and then use the placeholders to map back to the original key.

It is an _extremely_ niche use-case I know, however, it's something I did run into in my day job. It's useful to know how flexible Ecto can be! I try to coach my engineers to use Ecto as much as we can. There are _very_
few places where Ecto outright doesn't work (perhaps fodder for another blog post) but you can get an absolutely insane amount of mileage out of it. It's the best query builder I've ever used! Ecto forever.

I hope this was useful to you. If you want to reach out, hit me up on Bluesky at [andyleclair.dev](https://bsky.app/profile/andyleclair.dev) 🦋 
