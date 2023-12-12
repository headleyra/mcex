defmodule Mcex.Modifier.GetmTest do
  use ExUnit.Case, async: false
  alias Mc.Adapter.KvMemory
  alias Mcex.Modifier.Getm

  defmodule Mappings do
    defstruct [
      get: Mc.Modifier.Get
    ]
  end

  setup do
    start_supervised({KvMemory, map: %{"key1" => "data one", "key2" => "value\ntwo\n"}})
    :ok
  end

  describe "modify/3" do
    test "parses the `buffer` as a set of whitespace-separated keys and expands them into 'setm' format" do
      assert Getm.modify("key1", "", %Mappings{}) == {:ok, "key1\ndata one"}
      assert Getm.modify("key1 key2", "", %Mappings{}) == {:ok, "key1\ndata one\n---\nkey2\nvalue\ntwo\n"}
      assert Getm.modify("key2 key1", "", %Mappings{}) == {:ok, "key2\nvalue\ntwo\n\n---\nkey1\ndata one"}
      assert Getm.modify(" key1\t\n", "", %Mappings{}) == {:ok, "key1\ndata one"}
      assert Getm.modify("no.exist", "", %Mappings{}) == {:ok, "no.exist\n"}
      assert Getm.modify("no.exist.1 no.exist.2", "", %Mappings{}) == {:ok, "no.exist.1\n\n---\nno.exist.2\n"}
    end

    test "accepts a URI-encoded separator" do
      assert Getm.modify("key1", "; ", %Mappings{}) == {:ok, "key1\ndata one"}
      assert Getm.modify("key1 key2", "; ", %Mappings{}) == {:ok, "key1\ndata one; key2\nvalue\ntwo\n"}
      assert Getm.modify("key1 key2", " -%09: ", %Mappings{}) == {:ok, "key1\ndata one -\t: key2\nvalue\ntwo\n"}
    end

    test "works with ok tuples" do
      assert Getm.modify({:ok, "key1"}, "", %Mappings{}) == {:ok, "key1\ndata one"}
    end

    test "allows error tuples to pass through" do
      assert Getm.modify({:error, "reason"}, "", %Mappings{}) == {:error, "reason"}
    end
  end
end
