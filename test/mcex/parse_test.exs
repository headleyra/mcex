defmodule Mcex.ParseTest do
  use ExUnit.Case, async: true
  alias Mcex.Parse

  describe "mapify/1" do
    test "parses its input and returns a map" do
      assert Parse.mapify("x:one") == %{x: "one"}
      assert Parse.mapify("b:bee hi:howdy") == %{b: "bee", hi: "howdy"}
      assert Parse.mapify("x::y") == %{x: ":y"}
    end

    test "allows empty keys" do
      assert Parse.mapify(":x") == %{"": "x"}
      assert Parse.mapify(":a b:2") == %{"": "a", b: "2"}
    end

    test "allows emtpy values" do
      assert Parse.mapify("a:") == %{a: ""}
      assert Parse.mapify("a: b:") == %{a: "", b: ""}
    end

    test "URI decodes values" do
      assert Parse.mapify("a:foo%20bar%20biz b:bish%09bosh") == %{a: "foo bar biz", b: "bish\tbosh"}
    end

    test "ignores leading/trailing whitespace" do
      assert Parse.mapify("   a:foo b:bar   ") == %{a: "foo", b: "bar"}
      assert Parse.mapify(" \t  from:start to:finish%20line  \t") == %{from: "start", to: "finish line"}
      assert Parse.mapify("   whitespace:%20%09    \t") == %{whitespace: " \t"}
    end

    test "ignores 'internal' whitespace" do
      assert Parse.mapify("a:one   b:two") == %{a: "one", b: "two"}
      assert Parse.mapify("a:one \t  b:two") == %{a: "one", b: "two"}
      assert Parse.mapify("a:one%09   b:two") == %{a: "one\t", b: "two"}
    end

    test "returns an empty map with whitespace input" do
      assert Parse.mapify("") == %{}
      assert Parse.mapify("  ") == %{}
      assert Parse.mapify("\t") == %{}
    end

    test "errors when input can't be parsed" do
      assert Parse.mapify("x") == :error
      assert Parse.mapify("x y") == :error
    end
  end
end
