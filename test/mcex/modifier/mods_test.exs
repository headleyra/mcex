defmodule Mcex.Modifier.ModsTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Mods

  setup do
    mappings =
      %{
        foo: Bar,
        biz: Niz
      }

    %{mappings: mappings}
  end

  describe "modify/3" do
    test "lists modifiers in the mappings", %{mappings: mappings} do
      assert Mods.modify("", "", %{}) == {:ok, ""}
      assert Mods.modify("", "", mappings) == {:ok, "foo: Bar\nbiz: Niz"}
    end
  end
end
