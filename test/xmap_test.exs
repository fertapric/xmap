defmodule XMapTest do
  use ExUnit.Case
  doctest XMap

  test "parses empty nodes as empty maps" do
    xml = """
      <comments>
        <comment>
          <author/>
          <body>Hello world!</body>
          <footer></footer>
        </comment>
        <comment></comment>
        <comment/>
      </comments>
    """

    map = XMap.from_xml(xml, keys: :atoms)

    assert map == %{
      comments: %{
        comment: [
          %{author: %{}, body: "Hello world!", footer: %{}},
          %{},
          %{}
        ]
      }
    }
  end

  test "parses HTML special entities as a single text entry" do
    xml = """
    <comment>
      <author>Fernando Tapia</author>
      <body>&quot;Hello world!&quot;</body>
    </comment>
    """

    map = XMap.from_xml(xml, keys: :atoms)

    assert map == %{
      comment: %{
        author: "Fernando Tapia",
        body: "\"Hello world!\""
      }
    }
  end
end
