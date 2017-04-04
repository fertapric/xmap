defmodule XMapTest do
  use ExUnit.Case
  doctest XMap

  test "parses empty nodes as empty maps" do
    xml = """
      <comments>
        <comment>
          <body>Hello world!</body>
          <footer></footer>
          <author/>
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
end
