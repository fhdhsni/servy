defmodule ParserTest do
  use ExUnit.Case
  alias Servy.Parser
  doctest Servy.Parser

  test "parses a list of header fields into a map" do
    headers = ["foo:   bar", "baz: bax:jaz  "]

    assert Parser.parse_headers(headers) ==
             %{
               "foo" => "bar",
               "baz" => "bax:jaz"
             }
  end
end
