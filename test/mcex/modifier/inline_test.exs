defmodule Mcex.Modifier.InlineTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Inline

  describe "modify/3" do
    test "expands `buffer` as an 'inline string'" do
      assert Inline.modify("just normal stuff", "", %Mc.Mappings{}) == {:ok, "just normal stuff"}
      assert Inline.modify("will split into; lines", "", %Mc.Mappings{}) == {:ok, "will split into\nlines"}
      assert Inline.modify("won't split into;lines", "", %Mc.Mappings{}) == {:ok, "won't split into;lines"}
      assert Inline.modify("big; tune; ", "", %Mc.Mappings{}) == {:ok, "big\ntune\n"}
      assert Inline.modify("foo %0a %09 bar", "", %Mc.Mappings{}) == {:ok, "foo \n \t bar"}
    end

    test "runs back-ticked scripts in place" do
      assert Inline.modify("zero `range 4` five", "", %Mc.Mappings{}) == {:ok, "zero 1\n2\n3\n4 five"}
      assert Inline.modify("do you `buffer foo`?", "", %Mc.Mappings{}) == {:ok, "do you foo?"}
      assert Inline.modify("yes `buffer WHEE; casel; replace whee we` can", "", %Mc.Mappings{}) == {:ok, "yes we can"}
      assert Inline.modify("== `buffer FOO %0a casel; replace foo bar` ==", "", %Mc.Mappings{}) == {:ok, "== bar  =="}
      assert Inline.modify("; ;tumble; weed; ", "", %Mc.Mappings{}) == {:ok, "\n;tumble\nweed\n"}
    end

    test "expands multiple 'inline strings'" do
      assert Inline.modify("14da `buffer TREBLE; casel` 24da `buffer x; replace x bass`", "", %Mc.Mappings{}) ==
        {:ok, "14da treble 24da bass"}
    end

    test "handles 'inline strings' that return errors" do
      assert Inline.modify("`error oops`", "", %Mc.Mappings{}) == {:error, "oops"}
      assert Inline.modify("`error first` `error second`", "", %Mc.Mappings{}) == {:error, "first"}
    end

    test "works with ok tuples" do
      assert Inline.modify({:ok, "lock; down"}, "", %Mc.Mappings{}) == {:ok, "lock\ndown"}
    end

    test "allows error tuples to pass through" do
      assert Inline.modify({:error, "reason"}, "", %Mc.Mappings{}) == {:error, "reason"}
    end
  end
end
