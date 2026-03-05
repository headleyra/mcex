defmodule Mcex.Modifier.TruncateTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Truncate

  describe "m/3" do
    test "truncates `buffer` given a character count" do
      assert Truncate.m("coffee is life", "10", %{}) == {:ok, "coffee is~"}
      assert Truncate.m("tea is\npretty\ngood too", "17", %{}) == {:ok, "tea is\npretty\ngo~"}
      assert Truncate.m("123", "2", %{}) == {:ok, "1~"}
      assert Truncate.m("12", "1", %{}) == {:ok, "~"}
      assert Truncate.m("\t\n\n", "2", %{}) == {:ok, "\t~"}
      assert Truncate.m("   ", "2", %{}) == {:ok, " ~"}
      assert Truncate.m("·^¬", "2", %{}) == {:ok, "·~"}
    end

    test "returns `buffer` (unchanged) when truncation isn't necessary" do
      assert Truncate.m("tea", "7", %{}) == {:ok, "tea"}
      assert Truncate.m("dosh\n", "5", %{}) == {:ok, "dosh\n"}
      assert Truncate.m("", "100", %{}) == {:ok, ""}
    end

    @err "Mcex.Modifier.Truncate: bad truncate count"

    test "errors when the character count isn't a positive integer" do
      assert Truncate.m("tea", "0", %{}) == {:error, @err}
      assert Truncate.m("milk", "-1", %{}) == {:error, @err}
      assert Truncate.m("", "-71", %{}) == {:error, @err}
      assert Truncate.m("sugar", "foobar", %{}) == {:error, @err}
      assert Truncate.m("honey", "3.142", %{}) == {:error, @err}
    end

    test "works with ok tuples" do
      assert Truncate.m({:ok, "best\nof 3"}, "5", %{}) == {:ok, "best~"}
    end

    test "allows error tuples to pass through" do
      assert Truncate.m({:error, "reason"}, "", %{}) == {:error, "reason"}
    end
  end
end
