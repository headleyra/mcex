defmodule Mcex.ParseTest do
  use ExUnit.Case, async: true
  alias Mcex.Parse

  describe "split/1" do
    test "uses the 1st substring (of `string`), plus a space, to split the rest (of `string`)" do
      assert Parse.split(", one, two") == ["one", "two"]
      assert Parse.split(":: foo:: bar :biz:: niz") == ["foo", "bar :biz", "niz"]
      assert Parse.split("<sep> cash<sep> dosh") == ["cash", "dosh"]
      assert Parse.split("/ b {time; d \..*$}/ b {date}") == ["b {time; d \..*$}", "b {date}"]
      assert Parse.split("x  foox bar ") == [" foo", "bar "]
    end

    test "returns the 'rest of string' when the 'split string' is not found" do
      assert Parse.split(", no comma+SPACEs,in this") == ["no comma+SPACEs,in this"]
      assert Parse.split(";     ") == ["    "]
    end

    test "returns `string` in a list when it's 'unsplittable'" do
      assert Parse.split("abc") == ["abc"]
      assert Parse.split("") == [""]
      assert Parse.split(" ") == [" "]
      assert Parse.split("   ") == ["   "]
    end

    test "ignores leading white space" do
      assert Parse.split(" \t  <sep> cash<sep> dosh") == ["cash", "dosh"]
    end

    test "interprets separator as a URI encoded string" do
      assert Parse.split("%20: foo : bar") == ["foo", "bar"]
      assert Parse.split("%0a un\n deux") == ["un", "deux"]
    end
  end
end
