defmodule Mcex.Modifier.SetmTest do
  use ExUnit.Case, async: false
  alias Mc.Client.Kv.Memory
  alias Mc.Modifier.Get
  alias Mc.Modifier.Set
  alias Mcex.Modifier.Getm
  alias Mcex.Modifier.Setm

  setup do
    start_supervised({Memory, map: %{}, name: :mem})
    start_supervised({Get, kv_client: Memory, kv_pid: :mem})
    start_supervised({Set, kv_client: Memory, kv_pid: :mem})
    start_supervised({Mc, mappings: %Mc.Mappings{}})
    :ok
  end

  describe "Mc.Modifier.Setm.modify/2" do
    test "parses the `buffer` as 'setm' format and sets keys/values as appropriate" do
      Setm.modify("key\nvalue", "")
      assert Get.modify("", "key") == {:ok, "value"}

      Setm.modify("a\napple\tcore\n---\nt\ntennis\nball", "")
      assert Get.modify("", "a") == {:ok, "apple\tcore"}
      assert Get.modify("", "t") == {:ok, "tennis\nball"}
    end

    test "accepts a URI-encoded separator" do
      Setm.modify("five\ndata 5 -\t@ seven\nvalue 7", " -%09@ ")
      assert Get.modify("", "five") == {:ok, "data 5"}
      assert Get.modify("", "seven") == {:ok, "value 7"}
    end

    test "complements the 'getm' modifier" do
      setm_string1 = "key1\ndata one\n---\nkey2\nvalue two"
      Setm.modify(setm_string1, "")
      assert Getm.modify("key1 key2", "") == {:ok, setm_string1}

      setm_string2 = "key1\ndata one:::key2\nvalue two"
      Setm.modify(setm_string2, ":::")
      assert Getm.modify("key1 key2", ":::") == {:ok, setm_string2}
    end

    test "works with ok tuples" do
      Setm.modify({:ok, "cash\ndosh"}, "")
      assert Get.modify("", "cash") == {:ok, "dosh"}
    end

    test "allows error tuples to pass through" do
      assert Setm.modify({:error, "reason"}, "") == {:error, "reason"}
    end
  end
end
