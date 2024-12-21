defmodule Mcex.Modifier.HaveTest do
  use ExUnit.Case, async: false
  alias Mcex.Modifier.Have

  setup do
    start_supervised({Mc.Adapter.KvMemory, map: %{
      "tim" => "  ",
      "jon" => "\n  \t"
    }})

    mappings = %Mc.Mappings{} |> Map.merge(%Mcex.Mappings{})
    %{mappings: mappings}
  end

  describe "modify/3" do
    test "expects `mappings` to contain key/value modifiers, 'get' and 'set'", do: true
    test "expects `mappings` to contain the 'trap' modifier (from `%Mcex.Mappings{}`)", do: true

    test "shows stats for a key that doesn't exist (or is empty)", %{mappings: mappings} do
      assert Have.modify("", "no.exist show", mappings) == {:ok, "one: n/a\nhav: 0\ntot: 0\navg: infinity"}
      assert Have.modify("", "jon show", mappings) == {:ok, "one: n/a\nhav: 0\ntot: 0\navg: infinity"}
      assert Have.modify("", "tim show", mappings) == {:ok, "one: n/a\nhav: 0\ntot: 0\navg: infinity"}
    end

    test "adds today as a 'have' day", %{mappings: mappings} do
      today = "#{Date.utc_today()}"
      assert Have.modify("", "sam", mappings) == {:ok, today}
      assert Mc.m("get sam", mappings) == {:ok, today}
    end

    test "shows stats for a non-empty key", %{mappings: mappings} do
      today = "#{Date.utc_today()}"
      Have.modify("", "dan", mappings)
      assert Have.modify("", "dan show", mappings) == {:ok, "one: #{today}\nhav: 1\ntot: 1\navg: n/a"}
    end
  end
end
