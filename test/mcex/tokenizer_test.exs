defmodule Mcex.TokenizerTest do
  use ExUnit.Case, async: true
  alias Mcex.Tokenizer

  describe "parse/1" do
    test "tokenizes characters in curly braces" do
      assert Tokenizer.parse("foo bar") == g("foo bar")
      assert Tokenizer.parse("drum \u00e1 bass") == g("drum \u00e1 bass")
      assert Tokenizer.parse("now: {time}") == g("now: ") ++ [{:token, ~w(t i m e)}]
      assert Tokenizer.parse("{a}") == [{:token, ["a"]}]
      assert Tokenizer.parse("{a}{b}") == [{:token, ["a"]}, {:token, ["b"]}]
      assert Tokenizer.parse("{ time\nis\tnow }") == [{:token, g(" time\nis\tnow ")}]
      
      assert Tokenizer.parse("date {date} time {time} ::") ==
        g("date ") ++ [{:token, g("date")}] ++ g(" time ") ++ [{:token, g("time")}] ++ g(" ::")
    end

    test "allows mismatched braces" do
      assert Tokenizer.parse("a}") == g("a}")
      assert Tokenizer.parse("a} foo bar") == g("a} foo bar")
      assert Tokenizer.parse("\t {123}\n :: }") == g("\t ") ++ [{:token, g("123")}] ++ g("\n :: }")
      assert Tokenizer.parse(" {abc") == g(" {abc")
      assert Tokenizer.parse("{abc} :: {") == [{:token, g("abc")}] ++ g(" :: {")
      assert Tokenizer.parse("foo} {bar") == g("foo} {bar")
    end

    test "allows double braces" do
      assert Tokenizer.parse("{{abc") == g("{{abc")
      assert Tokenizer.parse("foo}}") == g("foo}}")
    end

    test "allows nested braces" do
      assert Tokenizer.parse("{{hi}}") == g("{") ++ [{:token, g("hi")}] ++ g("}")
    end
  end

  defp g(string), do: String.graphemes(string)
end
