defmodule Mcex.Modifier.MinTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Min

  describe "m/3" do
    test "returns the minimum value in `buffer`" do
      assert Min.m("3 4 11", "", %{}) == {:ok, "3"}
      assert Min.m("c b aa", "n/a", %{}) == {:ok, "aa"}
      assert Min.m("1 -17 -7", "", %{}) == {:ok, "-17"}
      assert Min.m("-001 4 7", "", %{}) == {:ok, "-1"}
    end

    test "works with ok tuples" do
      assert Min.m({:ok, "some buffer text"}, "", %{}) == {:ok, "buffer"}
    end

    test "allows error tuples to pass-through" do
      assert Min.m({:error, "reason"}, "n/a", %{}) == {:error, "reason"}
    end
  end
end
