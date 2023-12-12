defmodule Mcex.Modifier.SelectTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Select

  describe "modify/3" do
    test "selects lines from `buffer` using a series of comma-seperated 'line specs'" do
      assert Select.modify("one\ntwo\nthree", "2", %{}) == {:ok, "two"}
      assert Select.modify("one\ntwo\nthree", "3", %{}) == {:ok, "three"}
      assert Select.modify("un\ndeux\ntrois\n\n", "2,4,5", %{}) == {:ok, "deux\n\n"}
      assert Select.modify("\n\none\ntwo\nthree\n\n", "5,3", %{}) == {:ok, "three\none"}
      assert Select.modify("one\ntwo\nthree\nfour", "2-4", %{}) == {:ok, "two\nthree\nfour"}
      assert Select.modify("one\ntwo\nthree\nfour\nfive", "1,3-5,1", %{}) == {:ok, "one\nthree\nfour\nfive\none"}
      assert Select.modify("one\ntwo\nthree\nfour\nfive", "3-1,5", %{}) == {:ok, "three\ntwo\none\nfive"}
    end

    @errmsg "Mcex.Modifier.Select: bad line spec(s)"

    test "errors given bad line specs" do
      assert Select.modify("one\ntwo", "oops", %{}) == {:error, @errmsg}
      assert Select.modify("one\ntwo", "5.1", %{}) == {:error, @errmsg}
    end

    test "errors when zero is mentioned" do
      assert Select.modify("one\ntwo", "0", %{}) == {:error, @errmsg}
      assert Select.modify("one\ntwo", "0-3", %{}) == {:error, @errmsg}
      assert Select.modify("one\ntwo", "1,0-5", %{}) == {:error, @errmsg}
    end

    test "works with ok tuples" do
      assert Select.modify({:ok, "one\nmore"}, "2", %{}) == {:ok, "more"}
    end

    test "allows error tuples to pass-through" do
      assert Select.modify({:error, "reason"}, "1", %{}) == {:error, "reason"}
    end
  end

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

  describe "int_from/1" do
    test "converts an integer string into a zero-based integer" do
      assert Select.int_from("1") == 0
      assert Select.int_from("8") == 7
    end

    test "errors when < 1" do
      assert Select.int_from("0") == :error
      assert Select.int_from("-1") == :error
    end
  end

  describe "int_from/2" do
    test "converts two integer strings into a zero-based integer list" do
      assert Select.int_from("1", "3") == [0, 1, 2]
      assert Select.int_from("8", "5") == [7, 6, 5, 4]
      assert Select.int_from("1", "1") == [0]
    end

    test "errors when any of its integers are < 1" do
      assert Select.int_from("0", "1") == :error
      assert Select.int_from("-1", "5") == :error
    end

    test "errors when any integers are bad" do
      assert Select.int_from("2", "-") == :error
      assert Select.int_from("foo", "5") == :error
      assert Select.int_from("foo", "bar") == :error
      assert Select.int_from("2", "3.142") == :error
    end
  end
end
