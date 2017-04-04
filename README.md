# XMap

XML to Map converter.

XMap transforms an XML string into a [`Map`](https://hexdocs.pm/elixir/Map.html) containing a collection of pairs where the key is the node name and the value is its content.

## Examples

Here is an example:

```elixir
iex> xml = """
...> <?xml version="1.0" encoding="UTF-8"?>
...> <blog>
...>   <post>
...>     <title>Hello Elixir!</title>
...>   </post>
...>   <post>
...>     <title>Hello World!</title>
...>   </post>
...> </blog>
...> """
iex> XMap.from_xml(xml)
%{"blog" => %{"post" => [%{"title" => "Hello Elixir!"},
                         %{"title" => "Hello World!"}]}}
iex> XMap.from_xml(xml, keys: :atoms)
%{blog: %{post: [%{title: "Hello Elixir!"}, %{title: "Hello World!"}]}}
```

Unless you absolutely know what you're doing, do not use the `keys: :atoms` option.
Atoms are not garbage-collected, see Erlang Efficiency Guide for more info:

> Atoms are not garbage-collected. Once an atom is created, it will never
> be removed. The emulator will terminate if the limit for the number of
> atoms (1048576 by default) is reached.

## Installation

Add XMap to your project's dependencies in `mix.exs`:

```elixir
def deps do
  [{:xmap, "~> 0.1.0"}]
end
```

And fetch your project's dependencies:

```shell
$ mix deps.get
```

## Documentation

Documentation is available at http://hexdocs.pm/xmap

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fertapric/xmap. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### Running tests

Clone the repo and fetch its dependencies:

```shell
$ git clone https://github.com/fertapric/xmap.git
$ cd xmap
$ mix deps.get
$ mix test
```

### Building docs

```shell
$ mix docs
```

## License

**XMap** is released under the [MIT License](http://www.opensource.org/licenses/MIT).

## Author

Fernando Tapia Rico, [@fertapric](https://twitter.com/fertapric)
