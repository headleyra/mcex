defmodule Mcex.ParseTest do
  use ExUnit.Case, async: true
  alias Mcex.Parse

  describe "mapify/1" do
    test "parses its input and returns a map" do
      assert Parse.mapify("x:one") == %{x: "one"}
      assert Parse.mapify("b:bee hi:howdy") == %{b: "bee", hi: "howdy"}
      assert Parse.mapify("30:percent off bogof:241") == %{"30": "percent off", bogof: "241"}
    end

    test "allows empty keys" do
      assert Parse.mapify(":x") == %{"": "x"}
      assert Parse.mapify(":a b:2") == %{"": "a", b: "2"}
    end

    test "URI decodes" do
      assert Parse.mapify("a:foo%20bar biz b:bish%09bosh") == %{a: "foo bar biz", b: "bish\tbosh"}
    end

    test "allows emtpy values" do
      assert Parse.mapify("a:") == %{a: ""}
      assert Parse.mapify("a: b:") == %{a: "", b: ""}
    end

    test "ignores leading/trailing whitespace" do
      assert Parse.mapify("   a:foo b:bar   ") == %{a: "foo", b: "bar"}
      assert Parse.mapify(" \t  from:start to:finish line  \t") == %{from: "start", to: "finish line"}
      assert Parse.mapify("   whitespace:%20 %09    \t") == %{whitespace: "  \t"}
    end

    test "ignores internal (non URI character) whitespace" do
      assert Parse.mapify("a:one    b:two") == %{a: "one", b: "two"}
      assert Parse.mapify("a:one \t    b:two") == %{a: "one", b: "two"}
      assert Parse.mapify("a:one %09    b:two") == %{a: "one \t", b: "two"}
    end

    test "return an empty map given whitespace" do
      assert Parse.mapify("") == %{}
      assert Parse.mapify("  ") == %{}
      assert Parse.mapify("\t") == %{}
    end

    test "errors with incomplete input" do
      assert Parse.mapify("x") == :error
      assert Parse.mapify("x y") == :error
    end
  end

  describe "split/1" do
    test "splits `string` on its first substring ('separator')" do
      assert Parse.split("- one-two") == ["one", "two"]
      assert Parse.split(": foo: bar :biz niz") == ["foo", " bar ", "biz niz"]
      assert Parse.split("<sep> cash<sep>dosh") == ["cash", "dosh"]
      assert Parse.split("/ b `time; d \..*$`/b `date`") == ["b `time; d \..*$`", "b `date`"]
      assert Parse.split("a  ") == [" "]
      assert Parse.split("b   foo") == ["  foo"]
      assert Parse.split("x   fooxbar") == ["  foo", "bar"]
    end

    test "ignores leading white space" do
      assert Parse.split(" \t  <sep> cash<sep>dosh") == ["cash", "dosh"]
    end

    test "returns empty string when there's nothing to do" do
      assert Parse.split("") == [""]
      assert Parse.split(" ") == [""]
      assert Parse.split("-") == [""]
      assert Parse.split("- ") == [""]
    end

    test "interprets separator as a URI encoded string" do
      assert Parse.split("%20 foo bar") == ["foo", "bar"]
      assert Parse.split("%0a un\ndeux") == ["un", "deux"]
    end
  end
end
