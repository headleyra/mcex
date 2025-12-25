defmodule Mcex.Modifier.SelectTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Select

  describe "modify/3" do
    test "selects lines from `buffer` using a series of space-separated 'line specs'" do
      assert Select.modify("one\ntwo\nthree", "2", %{}) == {:ok, "two"}
      assert Select.modify("one\ntwo\nthree", "3", %{}) == {:ok, "three"}
      assert Select.modify("un\ndeux\ntrois\n\n", "2 4 5", %{}) == {:ok, "deux\n\n"}
      assert Select.modify("\n\none\ntwo\nthree\n\n", "5 3", %{}) == {:ok, "three\none"}
      assert Select.modify("one\ntwo\nthree\nfour", "2-4", %{}) == {:ok, "two\nthree\nfour"}
      assert Select.modify("one\ntwo\nthree\nfour\nfive", "1 3-5 1", %{}) == {:ok, "one\nthree\nfour\nfive\none"}
      assert Select.modify("one\ntwo\nthree\nfour\nfive", "3-1 5", %{}) == {:ok, "three\ntwo\none\nfive"}
    end

    @errmsg "Mcex.Modifier.Select: bad line spec"

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
end
