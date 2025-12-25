defmodule Mcex.LineSpecTest do
  use ExUnit.Case, async: true
  alias Mcex.LineSpec

  describe "parse/1" do
    test "parses a 'line specification'" do
      assert LineSpec.parse("1") == [0]
      assert LineSpec.parse("2 5") == [1, 4]
      assert LineSpec.parse("2-4 8") == [[1, 2, 3], 7]
      assert LineSpec.parse("11 11-15 98") == [10, [10, 11, 12, 13, 14], 97]
      assert LineSpec.parse("1-3 8-5") == [[0, 1, 2], [7, 6, 5, 4]]
    end

    test "errors with a bad spec" do
      assert LineSpec.parse("0") == :error
      assert LineSpec.parse("0-3") == :error
      assert LineSpec.parse("1 two") == :error
      assert LineSpec.parse("foo bar") == :error
      assert LineSpec.parse("-3") == :error
      assert LineSpec.parse("-1-3") == :error
      assert LineSpec.parse("") == :error
      assert LineSpec.parse("\t") == :error
      assert LineSpec.parse(" \n") == :error
    end
  end
end
