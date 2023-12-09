defmodule Mcex.Modifier.SetmTest do
  use ExUnit.Case, async: false
  alias Mc.Adapter.KvMemory
  alias Mcex.Modifier.Getm
  alias Mcex.Modifier.Setm

  defmodule Mappings do
    defstruct [
      get: {Mc.Modifier.Get, :modify},
      set: {Mc.Modifier.Set, :modify}
    ]
  end

  setup do
    start_supervised({KvMemory, map: %{}})
    :ok
  end

  describe "modify/3" do
    test "parses the `buffer` as 'setm' format and sets keys/values as appropriate" do
      Setm.modify("key\nvalue", "", %Mappings{})
      assert Mc.Modifier.Get.modify("", "key", %Mappings{}) == {:ok, "value"}

      Setm.modify("a\napple\tcore\n---\nt\ntennis\nball", "", %Mappings{})
      assert Mc.Modifier.Get.modify("", "a", %Mappings{}) == {:ok, "apple\tcore"}
      assert Mc.Modifier.Get.modify("", "t", %Mappings{}) == {:ok, "tennis\nball"}
    end

    test "accepts a URI-encoded separator" do
      Setm.modify("five\ndata 5 -\t@ seven\nvalue 7", " -%09@ ", %Mappings{})
      assert Mc.Modifier.Get.modify("", "five", %Mappings{}) == {:ok, "data 5"}
      assert Mc.Modifier.Get.modify("", "seven", %Mappings{}) == {:ok, "value 7"}
    end

    test "complements the 'getm' modifier" do
      setm_string1 = "key1\ndata one\n---\nkey2\nvalue two"
      Setm.modify(setm_string1, "", %Mappings{})
      assert Getm.modify("key1 key2", "", %Mappings{}) == {:ok, setm_string1}

      setm_string2 = "key1\ndata one:::key2\nvalue two"
      Setm.modify(setm_string2, ":::", %Mappings{})
      assert Getm.modify("key1 key2", ":::", %Mappings{}) == {:ok, setm_string2}
    end

    test "works with ok tuples" do
      Setm.modify({:ok, "cash\ndosh"}, "", %Mappings{})
      assert Mc.Modifier.Get.modify("", "cash", %Mappings{}) == {:ok, "dosh"}
    end

    test "allows error tuples to pass through" do
      assert Setm.modify({:error, "reason"}, "", %Mappings{}) == {:error, "reason"}
    end
  end
end
