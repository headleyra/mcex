defmodule Mcex.SelectTest do
  use ExUnit.Case, async: true
  alias Mcex.Select

  describe "parse/1" do
    test "parses a line spec" do
      assert Select.parse("1") == 0
      assert Select.parse("5") == 4
      assert Select.parse("2-4") == [1, 2, 3]
      assert Select.parse("5-1") == [4, 3, 2, 1, 0]
    end

    test "errors on 'bad' line specs" do
      assert Select.parse("0") == :error
      assert Select.parse("0-2") == :error
      assert Select.parse("0--11") == :error
      assert Select.parse("^-11") == :error
      assert Select.parse("foobar") == :error
    end
  end

  describe "int/1" do
    test "converts an integer string into a zero-based integer" do
      assert Select.int("1") == 0
      assert Select.int("8") == 7
    end

    test "errors when < 1" do
      assert Select.int("0") == :error
      assert Select.int("-1") == :error
    end
  end

  describe "int/2" do
    test "converts two integer strings into a zero-based integer list" do
      assert Select.int("1", "3") == [0, 1, 2]
      assert Select.int("8", "5") == [7, 6, 5, 4]
      assert Select.int("1", "1") == [0]
    end

    test "errors when any of its integers are < 1" do
      assert Select.int("0", "1") == :error
      assert Select.int("-1", "5") == :error
    end

    test "errors when any integers are bad" do
      assert Select.int("2", "-") == :error
      assert Select.int("foo", "5") == :error
      assert Select.int("foo", "bar") == :error
      assert Select.int("2", "3.142") == :error
    end
  end
end
