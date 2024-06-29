defmodule Mcex.TokenizerTest do
  use ExUnit.Case, async: true
  alias Mcex.Tokenizer

  describe "parse/1" do
    test "tokenizes" do
      assert Tokenizer.parse("foo bar biz") == ~w(f o o) ++ [" "] ++ ~w(b a r)++ [" "] ++ ~w(b i z)
      assert Tokenizer.parse("drum:bass") == ~w(d r u m : b a s s)
      assert Tokenizer.parse("now: {time}") == ~w(n o w :) ++ [" "] ++ [{:ok, ~w(t i m e)}]
      assert Tokenizer.parse("{a}") == [{:ok, ["a"]}]
    end

    test "errors when token delimeters are mismatched" do
      assert Tokenizer.parse("a}") == {:error, :mismatch}
      assert Tokenizer.parse("a} foo bar") == {:error, :mismatch}
      assert Tokenizer.parse("24}") == {:error, :mismatch}
      assert Tokenizer.parse("{b") == {:error, :mismatch}
      assert Tokenizer.parse("{12") == {:error, :mismatch}
      assert Tokenizer.parse("}{") == {:error, :mismatch}
      assert Tokenizer.parse("foo} {bar") == {:error, :mismatch}
    end
  end
end
