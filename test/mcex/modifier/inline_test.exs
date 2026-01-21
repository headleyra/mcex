defmodule Mcex.Modifier.InlineTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Inline

  describe "modify/3" do
    test "expands `buffer` as an 'inline string'" do
      assert Inline.modify("just normal stuff", "", Mc.Mappings.s()) == {:ok, "just normal stuff"}
      assert Inline.modify("will split into; lines", "", Mc.Mappings.s()) == {:ok, "will split into\nlines"}
      assert Inline.modify("won't split into;lines", "", Mc.Mappings.s()) == {:ok, "won't split into;lines"}
      assert Inline.modify("big; tune; ", "", Mc.Mappings.s()) == {:ok, "big\ntune\n"}
    end

    test "runs back-ticked scripts in place" do
      assert Inline.modify("zero {range 4} five", "", Mc.Mappings.s()) == {:ok, "zero 1\n2\n3\n4 five"}
      assert Inline.modify("do you {buffer foo}?", "", Mc.Mappings.s()) == {:ok, "do you foo?"}
      assert Inline.modify("yes {buffer WHEE; casel; replace whee we} can", "", Mc.Mappings.s()) == {:ok, "yes we can"}
      assert Inline.modify("; ;tumble; weed; ", "", Mc.Mappings.s()) == {:ok, "\n;tumble\nweed\n"}
    end

    test "expands multiple 'inline strings'" do
      assert Inline.modify("14da {buffer TREBLE; casel} 24da {buffer x; replace x bass}", "", Mc.Mappings.s()) ==
        {:ok, "14da treble 24da bass"}
    end

    test "handles 'inline strings' that return errors" do
      assert Inline.modify("{error oops}", "", Mc.Mappings.s()) == {:error, "oops"}
      assert Inline.modify("{error first} `error second`", "", Mc.Mappings.s()) == {:error, "first"}
    end

    test "works with ok tuples" do
      assert Inline.modify({:ok, "lock; down"}, "", Mc.Mappings.s()) == {:ok, "lock\ndown"}
    end

    test "allows error tuples to pass through" do
      assert Inline.modify({:error, "reason"}, "", Mc.Mappings.s()) == {:error, "reason"}
    end
  end
end
