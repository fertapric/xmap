defmodule XMapTest do
  use ExUnit.Case, async: true
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

  test "parses empty nodes as empty maps with attributes" do
    xml = """
    <comments>
      <comment empty=\"true\">
        <author/>
        <body>Hello world!</body>
        <footer></footer>
      </comment>
      <comment empty=\"false\"></comment>
      <comment/>
    </comments>
    """

    map = XMap.from_xml(xml, keys: :atoms, disable_attributes: false)

    assert map == %{
             comments: %{
               comment: [
                 %{author: %{}, body: "Hello world!", footer: %{}},
                 %{},
                 %{}
               ],
               comment_empty: ["true", "false"]
             }
           }
  end

  test "parses HTML special entities" do
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

  test "parses CDATA" do
    xml = """
    <?xml version="1.0" encoding="UTF-8" ?>
    <post>
      <title>Hello!</title>
      <body><![CDATA[Hello world!]]></body>
    </post>
    """

    map = XMap.from_xml(xml, keys: :atoms)

    assert map == %{
             post: %{
               title: "Hello!",
               body: "Hello world!"
             }
           }
  end

  test "parses xml into strings" do
    xml = """
      <post url=\"http://www.google.com\">
        <title>Google</title>
      </post>
    """

    map = XMap.from_xml(xml)

    assert map == %{
             "post" => %{
               "title" => "Google"
             }
           }
  end

  test "parses attributes" do
    xml = """
      <post url=\"http://www.google.com\">
        <title>Google</title>
      </post>
    """

    map = XMap.from_xml(xml, keys: :atoms, disable_attributes: false)

    assert map == %{
             post: %{
               title: "Google"
             },
             post_url: "http://www.google.com"
           }
  end

  test "parses multiple attributes" do
    xml = """
      <post url=\"http://www.google.com\">
        <title url=\"http://www.google.org\">Google</title>
      </post>
    """

    map = XMap.from_xml(xml, keys: :atoms, disable_attributes: false)

    assert map == %{
             post: %{
               title: "Google",
               title_url: "http://www.google.org"
             },
             post_url: "http://www.google.com"
           }
  end

  test "parses empty attribute tag" do
    xml = """
      <post url=\"http://www.google.com\">
        <title url=\"http://www.google.org\"/>
      </post>
    """

    map = XMap.from_xml(xml, keys: :atoms, disable_attributes: false)

    assert map == %{
             post: %{
               title: %{},
               title_url: "http://www.google.org"
             },
             post_url: "http://www.google.com"
           }
  end
end
