defmodule Mcex.Modifier.TruncateTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Truncate

  describe "modify/3" do
    test "truncates `buffer` given a character count" do
      assert Truncate.modify("coffee is life", "10", %{}) == {:ok, "coffee is~"}
      assert Truncate.modify("tea is\npretty\ngood too", "17", %{}) == {:ok, "tea is\npretty\ngo~"}
      assert Truncate.modify("123", "2", %{}) == {:ok, "1~"}
      assert Truncate.modify("12", "1", %{}) == {:ok, "~"}
      assert Truncate.modify("\t\n\n", "2", %{}) == {:ok, "\t~"}
      assert Truncate.modify("   ", "2", %{}) == {:ok, " ~"}
      assert Truncate.modify("·^¬", "2", %{}) == {:ok, "·~"}
    end

    test "returns `buffer` (unchanged) when truncation isn't necessary" do
      assert Truncate.modify("tea", "7", %{}) == {:ok, "tea"}
      assert Truncate.modify("dosh\n", "5", %{}) == {:ok, "dosh\n"}
      assert Truncate.modify("", "100", %{}) == {:ok, ""}
    end

    @errmsg "Mcex.Modifier.Truncate: bad character count"

    test "errors when the character count isn't a positive integer" do
      assert Truncate.modify("tea", "0", %{}) == {:error, @errmsg}
      assert Truncate.modify("milk", "-1", %{}) == {:error, @errmsg}
      assert Truncate.modify("", "-71", %{}) == {:error, @errmsg}
      assert Truncate.modify("sugar", "foobar", %{}) == {:error, @errmsg}
      assert Truncate.modify("honey", "3.142", %{}) == {:error, @errmsg}
    end

    test "works with ok tuples" do
      assert Truncate.modify({:ok, "best\nof 3"}, "5", %{}) == {:ok, "best~"}
    end

    test "allows error tuples to pass through" do
      assert Truncate.modify({:error, "reason"}, "", %{}) == {:error, "reason"}
    end
  end
end
