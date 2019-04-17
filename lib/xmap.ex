defmodule XMap do
  @moduledoc ~S'''
  XML to Map conversion.

  XMap transforms an XML string into a `Map` containing a collection of pairs
  where the key is the node name and the value is its content.

  ## Examples

  Here is an example:

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

  Keys can be converted to atoms with the `keys: :atoms` option. Unless you absolutely
  know what you're doing, do not use the `keys: :atoms` option. Atoms are not garbage-collected,
  see Erlang Efficiency Guide for more info:

  > Atoms are not garbage-collected. Once an atom is created, it will never
  > be removed. The emulator will terminate if the limit for the number of
  > atoms (1048576 by default) is reached.
  '''

  @doc ~S'''
  Returns a `Map` containing a collection of pairs where the key is the node name
  and the value is its content.

  ## Examples

  Here is an example:

      iex> xml = """
      ...> <?xml version="1.0" encoding="UTF-8"?>
      ...> <post id="1">
      ...>   <title>Hello world!</title>
      ...>   <stats>
      ...>     <visits type="integer">1000</visits>
      ...>     <likes type="integer">3</likes>
      ...>   </stats>
      ...> </post>
      ...> """
      iex> XMap.from_xml(xml)
      %{"post" => %{"stats" => %{"likes" => "3", "visits" => "1000"},
                    "title" => "Hello world!"}}
      iex> XMap.from_xml(xml, keys: :atoms)
      %{post: %{stats: %{likes: "3", visits: "1000"}, title: "Hello world!"}}

  Keys can be converted to atoms with the `keys: :atoms` option. Unless you absolutely
  know what you're doing, do not use the `keys: :atoms` option. Atoms are not garbage-collected,
  see Erlang Efficiency Guide for more info:

  > Atoms are not garbage-collected. Once an atom is created, it will never
  > be removed. The emulator will terminate if the limit for the number of
  > atoms (1048576 by default) is reached.

  ### XML attributes and comments

  Both XML attributes and comments are ignored:

      iex> xml = """
      ...> <?xml version="1.0" encoding="UTF-8"?>
      ...> <post id="1">
      ...>   <title>Hello world!</title>
      ...>   <stats>
      ...>     <visits type="integer">1000</visits>
      ...>     <likes type="integer">3</likes>
      ...>   </stats>
      ...> </post>
      ...> """
      iex> XMap.from_xml(xml, keys: :atoms)
      %{post: %{stats: %{likes: "3", visits: "1000"}, title: "Hello world!"}}

  ### Empty XML nodes

  Empty XML nodes are parsed as empty maps:

      iex> xml = """
      ...> <?xml version="1.0" encoding="UTF-8"?>
      ...> <post>
      ...>   <author/>
      ...>   <body>Hello world!</body>
      ...>   <footer></footer>
      ...> </post>
      ...> """
      iex> XMap.from_xml(xml, keys: :atoms)
      %{post: %{author: %{}, body: "Hello world!", footer: %{}}}

  ### Casting

  The type casting of the values is delegated to the developer.
  '''

  @options_defaults %{keys: :string, disable_attributes: true}

  @spec from_xml(String.t(), keyword) :: map
  def from_xml(xml, options \\ []) do
    %{keys: keys, disable_attributes: attributes_disabled?} =
      Enum.into(options, @options_defaults)

    xml
    |> :erlang.bitstring_to_list()
    |> :xmerl_scan.string(space: :normalize, comments: false)
    |> elem(0)
    |> parse_record(attributes_disabled?)
    |> maybe_atomize_keys(keys)
  end

  defp parse_record([], _), do: %{}
  defp parse_record([head], attributes_disabled?), do: parse_record(head, attributes_disabled?)

  defp parse_record([head | tail], attributes_disabled?),
    do:
      head
      |> parse_record(attributes_disabled?)
      |> merge_records(parse_record(tail, attributes_disabled?))

  defp parse_record({:xmlText, _, _, _, value, _}, attributes_disabled?),
    do: value |> to_string() |> String.trim()

  defp parse_record(
         {:xmlElement, name, _, _, _, _, _, attributes, value, _, _, _},
         attributes_disabled?
       ) do
    %{"#{name}" => parse_record(value, attributes_disabled?)}
    |> merge_records(parse_record(attributes, attributes_disabled?))
  end

  defp parse_record(
         {:xmlAttribute, name, _, _, _, [{parent_element, _pos} | _tail], _, _, value, _},
         false
       ) do
    %{
      "#{parent_element |> to_string() |> String.trim()}_#{name}" =>
        value |> to_string() |> String.trim()
    }
  end

  defp parse_record({:xmlAttribute, _, _, _, _, _, _, _, _, _}, true) do
    %{}
  end

  # Spaces between tags are normalized but parsed as
  defp merge_records(r, ""), do: r
  # empty xmlText elements.
  defp merge_records("", r), do: r
  defp merge_records(r1, r2) when is_binary(r1) and is_binary(r2), do: r1 <> r2
  defp merge_records(r1, r2), do: Map.merge(r1, r2, fn _, v1, v2 -> List.flatten([v1, v2]) end)

  defp maybe_atomize_keys(map, :atoms), do: map |> atomize_keys()
  defp maybe_atomize_keys(map, _), do: map

  defp atomize_keys([]), do: []
  defp atomize_keys([head | tail]), do: [atomize_keys(head)] ++ atomize_keys(tail)

  defp atomize_keys(map) when is_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), atomize_keys(value)}
  end

  defp atomize_keys(value), do: value
end
