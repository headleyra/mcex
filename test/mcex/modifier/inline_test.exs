defmodule Mcex.Modifier.InlineTest do
  use ExUnit.Case, async: false
  alias Mcex.Modifier.Inline

  setup do
    start_supervised({Mc, mappings: %Mc.Mappings{}})
    :ok
  end

  describe "Mcex.Modifier.Inline.modify/2" do
    test "expands `buffer` as an 'inline string'" do
      assert Inline.modify("just normal stuff", "") == {:ok, "just normal stuff"}
      assert Inline.modify("will split into; lines", "") == {:ok, "will split into\nlines"}
      assert Inline.modify("won't split into;lines", "") == {:ok, "won't split into;lines"}
      assert Inline.modify("big; tune; ", "") == {:ok, "big\ntune\n"}
      assert Inline.modify("foo %0a %09 bar", "") == {:ok, "foo \n \t bar"}
    end

    test "runs back-ticked scripts in place" do
      assert Inline.modify("zero `range 4` five", "") == {:ok, "zero 1\n2\n3\n4 five"}
      assert Inline.modify("do you `buffer foo`?", "") == {:ok, "do you foo?"}
      assert Inline.modify("yes `buffer WHEE; lcase; replace whee we` can", "") == {:ok, "yes we can"}
      assert Inline.modify("== `buffer FOO %0a lcase; replace foo bar` ==", "") == {:ok, "== bar  =="}
      assert Inline.modify("; ;tumble; weed; ", "") == {:ok, "\n;tumble\nweed\n"}
    end

    test "expands multiple 'inline strings'" do
      assert Inline.modify("14da `b TREBLE; lcase` 24da `b x; r x bass`", "") == {:ok, "14da treble 24da bass"}
    end

    test "handles 'inline strings' that return errors" do
      assert Inline.modify("`error oops`", "") == {:error, "oops"}
      assert Inline.modify("`error first` `error second`", "") == {:error, "first"}
    end

    test "works with ok tuples" do
      assert Inline.modify({:ok, "lock; down"}, "") == {:ok, "lock\ndown"}
    end

    test "allows error tuples to pass through" do
      assert Inline.modify({:error, "reason"}, "") == {:error, "reason"}
    end
  end
end
