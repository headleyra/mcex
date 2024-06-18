defmodule Mcex.Modifier.MaxTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Max

  describe "modify/3·" do
    test "returns the maximum value in `buffer`" do
      assert Max.modify("3 4 11", "n/a", %{}) == {:ok, "11"}
      assert Max.modify("c b aa", "", %{}) == {:ok, "c"}
      assert Max.modify("1 -17 -7", "", %{}) == {:ok, "1"}
      assert Max.modify("-001 4 7", "", %{}) == {:ok, "7"}
    end

    test "works with ok tuples" do
      assert Max.modify({:ok, "some buffer text"}, "", %{}) == {:ok, "text"}
    end

    test "allows error tuples to pass-through" do
      assert Max.modify({:error, "reason"}, "n/a", %{}) == {:error, "reason"}
    end
  end
end
