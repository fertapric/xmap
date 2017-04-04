defmodule XMap do
  @moduledoc ~S'''
  XML to Map conversion.

  XMap transforms an XML string into a `Map` containing a collection of pairs
  where the key is the node name and the value is its content.

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

  Unless you absolutely know what you're doing, do not use the `keys: :atoms`
  option. Atoms are not garbage-collected, see Erlang Efficiency Guide for more info:

  > Atoms are not garbage-collected. Once an atom is created, it will never
  > be removed. The emulator will terminate if the limit for the number of
  > atoms (1048576 by default) is reached.
  '''

  @doc ~S'''
  Returns a `Map` containing a collection of pairs where the key is the node name
  and the value is its content.

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
      iex> XMap.from_xml(xml, keys: :atoms)
      %{post: %{stats: %{likes: "3", visits: "1000"}, title: "Hello world!"}}

  Both XML attributes and comments are ignored.

  The type casting of the values is delegated to the developer.
  '''
  @spec from_xml(String.t, keyword) :: map
  def from_xml(xml, options \\ [])
  def from_xml(xml, keys: :atoms), do: xml |> from_xml() |> atomize_keys()
  def from_xml(xml, []) do
    xml
    |> :erlang.bitstring_to_list()
    |> :xmerl_scan.string(space: :normalize, comments: false)
    |> elem(0)
    |> parse_record()
  end

  defp parse_record([]), do: %{}
  defp parse_record([head | tail]), do: parse_record(head) |> merge_records(parse_record(tail))
  defp parse_record({:xmlText, _, _, _, value, _}), do: String.strip(to_string(value))
  defp parse_record({:xmlElement, name, _, _, _, _, _, _, value, _, _, _}) do
    %{"#{name}" => parse_record(value)}
  end

  defp merge_records(record, ""), do: record
  defp merge_records("", record), do: record
  defp merge_records(record1, record2) do
    Map.merge(record1, record2, fn
      _, value1, value2 when is_list(value1) and is_list(value2) -> value1 ++ value2
      _, value1, value2 when is_list(value1) -> value1 ++ [value2]
      _, value1, value2 when is_list(value2) -> [value1] ++ value2
      _, value1, value2 -> [value1, value2]
    end)
  end

  defp atomize_keys([]), do: []
  defp atomize_keys([head | tail]), do: [atomize_keys(head)] ++ atomize_keys(tail)
  defp atomize_keys(map) when is_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), atomize_keys(value)}
  end
  defp atomize_keys(value), do: value
end
