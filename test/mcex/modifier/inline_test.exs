defmodule Mcex.Modifier.InlineTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Inline

  defmodule Mappings do
    defstruct [
      buffer: Mc.Modifier.Buffer,
      error: Mc.Modifier.Error,
      lcase: Mc.Modifier.Lcase,
      range: Mc.Modifier.Range,
      replace: Mc.Modifier.Replace
    ]
  end

  describe "modify/3" do
    test "expands `buffer` as an 'inline string'" do
      assert Inline.modify("just normal stuff", "", %Mappings{}) == {:ok, "just normal stuff"}
      assert Inline.modify("will split into; lines", "", %Mappings{}) == {:ok, "will split into\nlines"}
      assert Inline.modify("won't split into;lines", "", %Mappings{}) == {:ok, "won't split into;lines"}
      assert Inline.modify("big; tune; ", "", %Mappings{}) == {:ok, "big\ntune\n"}
      assert Inline.modify("foo %0a %09 bar", "", %Mappings{}) == {:ok, "foo \n \t bar"}
    end

    test "runs back-ticked scripts in place" do
      assert Inline.modify("zero `range 4` five", "", %Mappings{}) == {:ok, "zero 1\n2\n3\n4 five"}
      assert Inline.modify("do you `buffer foo`?", "", %Mappings{}) == {:ok, "do you foo?"}
      assert Inline.modify("yes `buffer WHEE; lcase; replace whee we` can", "", %Mappings{}) == {:ok, "yes we can"}
      assert Inline.modify("== `buffer FOO %0a lcase; replace foo bar` ==", "", %Mappings{}) == {:ok, "== bar  =="}
      assert Inline.modify("; ;tumble; weed; ", "", %Mappings{}) == {:ok, "\n;tumble\nweed\n"}
    end

    test "expands multiple 'inline strings'" do
      assert Inline.modify("14da `buffer TREBLE; lcase` 24da `buffer x; replace x bass`", "", %Mappings{}) ==
        {:ok, "14da treble 24da bass"}
    end

    test "handles 'inline strings' that return errors" do
      assert Inline.modify("`error oops`", "", %Mappings{}) == {:error, "oops"}
      assert Inline.modify("`error first` `error second`", "", %Mappings{}) == {:error, "first"}
    end

    test "works with ok tuples" do
      assert Inline.modify({:ok, "lock; down"}, "", %Mappings{}) == {:ok, "lock\ndown"}
    end

    test "allows error tuples to pass through" do
      assert Inline.modify({:error, "reason"}, "", %Mappings{}) == {:error, "reason"}
    end
  end
end
