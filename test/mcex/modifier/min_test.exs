defmodule Mcex.Modifier.MinTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Min

  describe "modify/3" do
    test "returns the minimum value in `buffer`" do
      assert Min.modify("3 4 11", "", %{}) == {:ok, "3"}
      assert Min.modify("c b aa", "n/a", %{}) == {:ok, "aa"}
      assert Min.modify("1 -17 -7", "", %{}) == {:ok, "-17"}
      assert Min.modify("-001 4 7", "", %{}) == {:ok, "-1"}
    end

    test "works with ok tuples" do
      assert Min.modify({:ok, "some buffer text"}, "", %{}) == {:ok, "buffer"}
    end

    test "allows error tuples to pass-through" do
      assert Min.modify({:error, "reason"}, "n/a", %{}) == {:error, "reason"}
    end
  end
end
