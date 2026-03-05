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

  describe "m/3" do
    test "lists modifiers in the mappings", %{mappings: mappings} do
      assert Mods.m("", "", %{}) == {:ok, ""}
      assert Mods.m("", "", mappings) == {:ok, "foo: Bar\nbiz: Niz"}
    end
  end
end
