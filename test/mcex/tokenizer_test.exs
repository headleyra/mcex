defmodule Mcex.TokenizerTest do
  use ExUnit.Case, async: true
  alias Mcex.Tokenizer

  describe "parse/1" do
    test "tokenizes" do
      assert Tokenizer.parse("foo bar") == g("foo bar")
      assert Tokenizer.parse("drum \u00e1 bass") == g("drum \u00e1 bass")
      assert Tokenizer.parse("now: {time}") == g("now: ") ++ [{:ok, ~w(t i m e)}]
      assert Tokenizer.parse("{a}") == [{:ok, ["a"]}]
      assert Tokenizer.parse("{a}{b}") == [{:ok, ["a"]}, {:ok, ["b"]}]
      
      assert Tokenizer.parse("date {date} time {time} ::") ==
        g("date ") ++ [{:ok, g("date")}] ++ g(" time ") ++ [{:ok, g("time")}] ++ g(" ::")
    end

    test "allows mismatched open/close characters`" do
      assert Tokenizer.parse("a}") == g("a}")
      assert Tokenizer.parse("a} foo bar") == g("a} foo bar")
      assert Tokenizer.parse("\t {123}\n :: }") == g("\t ") ++ [{:ok, g("123")}] ++ g("\n :: }")
      assert Tokenizer.parse(" {abc") == g(" {abc")
      assert Tokenizer.parse("{abc} :: {") == [{:ok, g("abc")}] ++ g(" :: {")
      assert Tokenizer.parse("foo} {bar") == g("foo} {bar")
    end

    test "allows double open/close characters" do
      assert Tokenizer.parse("{{abc") == g("{{abc")
      assert Tokenizer.parse("foo}}") == g("foo}}")
    end

    test "allows nested open/close characters" do
      assert Tokenizer.parse("{{hi}}") == g("{") ++ [{:ok, g("hi")}] ++ g("}")
    end
  end

  defp g(string) do
    String.graphemes(string)
  end
end
