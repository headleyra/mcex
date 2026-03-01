defmodule Mcex.Modifier.InlineTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Inline

  setup do
    %{mappings: Mc.Mappings.s()}
  end

  describe "modify/3" do
    test "expands `buffer` as an 'inline string'", %{mappings: mappings} do
      assert Inline.modify("just normal stuff", "", mappings) == {:ok, "just normal stuff"}
      assert Inline.modify("will split into; lines", "", mappings) == {:ok, "will split into\nlines"}
      assert Inline.modify("won't split into;lines", "", mappings) == {:ok, "won't split into;lines"}
      assert Inline.modify("big; tune; ", "", mappings) == {:ok, "big\ntune\n"}
    end

    test "runs 'curly scripts' in place", %{mappings: mappings} do
      assert Inline.modify("zero {range 4} five", "", mappings) == {:ok, "zero 1\n2\n3\n4 five"}
      assert Inline.modify("do you {buffer foo}?", "", mappings) == {:ok, "do you foo?"}
      assert Inline.modify("yes {buffer WHEE; casel; replace whee we} can", "", mappings) == {:ok, "yes we can"}
      assert Inline.modify("; ;tumble; weed; ", "", mappings) == {:ok, "\n;tumble\nweed\n"}
    end

    test "expands multiple 'inline strings'", %{mappings: mappings} do
      buffer = "14da {buffer TREBLE; casel} 24da {buffer x; replace x bass}"
      assert Inline.modify(buffer, "", mappings) == {:ok, "14da treble 24da bass"}
    end

    test "returns errors", %{mappings: mappings} do
      assert Inline.modify("{error oops}", "", mappings) == {:error, "oops"}
    end

    test "returns the first error", %{mappings: mappings} do
      assert Inline.modify("{error first} {error second}", "", mappings) == {:error, "first"}
    end

    test "works with ok tuples" do
      assert Inline.modify({:ok, "lock; down"}, "", %{}) == {:ok, "lock\ndown"}
    end

    test "allows error tuples to pass through" do
      assert Inline.modify({:error, "reason"}, "", %{}) == {:error, "reason"}
    end
  end
end
