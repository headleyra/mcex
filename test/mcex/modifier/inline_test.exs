defmodule Mcex.Modifier.InlineTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Inline

  setup do
    %{mappings: Mc.Mappings.standard()}
  end

  describe "m/3" do
    test "expands `buffer` as an 'inline string'", %{mappings: mappings} do
      assert Inline.m("just normal stuff", "", mappings) == {:ok, "just normal stuff"}
      assert Inline.m("will split into; lines", "", mappings) == {:ok, "will split into\nlines"}
      assert Inline.m("won't split into;lines", "", mappings) == {:ok, "won't split into;lines"}
      assert Inline.m("big; tune; ", "", mappings) == {:ok, "big\ntune\n"}
    end

    test "runs 'curly scripts' in place", %{mappings: mappings} do
      assert Inline.m("zero {range 4} five", "", mappings) == {:ok, "zero 1\n2\n3\n4 five"}
      assert Inline.m("do you {buffer foo}?", "", mappings) == {:ok, "do you foo?"}
      assert Inline.m("yes {buffer WHEE; casel; replace whee we} can", "", mappings) == {:ok, "yes we can"}
      assert Inline.m("; ;tumble; weed; ", "", mappings) == {:ok, "\n;tumble\nweed\n"}
    end

    test "expands multiple 'inline strings'", %{mappings: mappings} do
      buffer = "14da {buffer TREBLE; casel} 24da {buffer x; replace x bass}"
      assert Inline.m(buffer, "", mappings) == {:ok, "14da treble 24da bass"}
    end

    test "returns errors", %{mappings: mappings} do
      assert Inline.m("{error oops}", "", mappings) == {:error, "oops"}
    end

    test "returns the first error", %{mappings: mappings} do
      assert Inline.m("{error first} {error second}", "", mappings) == {:error, "first"}
    end

    test "works with ok tuples" do
      assert Inline.m({:ok, "lock; down"}, "", %{}) == {:ok, "lock\ndown"}
    end

    test "allows error tuples to pass through" do
      assert Inline.m({:error, "reason"}, "", %{}) == {:error, "reason"}
    end
  end
end
