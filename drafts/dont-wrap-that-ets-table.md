%{
  title: "Don't Wrap That ETS Table",
  description: "Don't make this common mistake",
  author: "Andy LeClair",
  tags: ["elixir"],
  related_listening: "https://www.youtube.com/watch?v=fXjTxC-HbKY",
}
---

I've seen this pattern enough that I wanted to make a post about it. Don't wrap that ETS table!

Consider the following Elixir code:

```elixir
def MyServer do
    use GenServer
    @table __MODULE__

    def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end

    def init(_) do
        _tid = :ets.new(@table, [:set, :protected, :named_table])
        {:ok, []}
    end

    def put_item(key, value) do
        GenServer.call(__MODULE__, {:put_item, key, value})
    end

    def get_item(key) do
        GenServer.call(__MODULE__, {:get_item, key})
    end

    def handle_call({:get_item, key}, _from, _state) do
        :ets.lookup(@table, key)
    end

    def handle_call({:put_item, key, value}, _from, _state) do
        :ets.insert(@table, key, value)
    end
end
```

