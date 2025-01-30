defmodule Mcex.Modifier.HaveTest do
  use ExUnit.Case, async: false
  alias Mcex.Modifier.Have

  setup do
    start_supervised({Mc.Adapter.KvMemory, map: %{
      "bob" => "2016-7-foo\n2017-01-02 2018-07-05",
      "tim" => "  ",
      "jon" => "\n  \t",
      "dan" => "#{ago(7)}\n#{ago(5)}",
      "jed" => "#{ago(7)} #{ago(5)} #{ago(3)}",
      "neo" => "#{ago(5)} #{ago(3)} #{ago(0)}"
    }})

    mappings = %Mc.Mappings{} |> Map.merge(%Mcex.Mappings{})
    %{mappings: mappings}
  end

  describe "modify/3" do
    test "expects `mappings` to contain key/value modifiers, 'get' and 'set'", do: true
    test "expects `mappings` to contain the 'trap' modifier (from `%Mcex.Mappings{}`)", do: true

    test "shows stats for a non-empty key (up to yesterday)", %{mappings: mappings} do
      assert Have.modify("", "dan show", mappings) == {:ok, "one: #{ago(7)}\nhav: 2\ntot: 7\navg: 2.5\nint: 1, 4"}
      assert Have.modify("", "jed show", mappings) == {:ok, "one: #{ago(7)}\nhav: 3\ntot: 7\navg: 1.33\nint: 1, 1, 2"}
      assert Have.modify("", "neo show", mappings) == {:ok, "one: #{ago(5)}\nhav: 2\ntot: 5\navg: 1.5\nint: 1, 2"}
    end

    test "adds today as a 'have' day", %{mappings: mappings} do
      today = "#{ago(0)}"
      assert Have.modify("", "sam", mappings) == {:ok, today}
      assert Mc.m("get sam", mappings) == {:ok, today}
    end

    @error {:error, "Mcex.Modifier.Have: no dates"}

    test "errors with a key that doesn't exist (or is 'empty')", %{mappings: mappings} do
      assert Have.modify("", "no.exist show", mappings) == @error
      assert Have.modify("", "tim show", mappings) == @error
      assert Have.modify("", "jon show", mappings) == @error
    end

    test "errors with a key containing 'bad' dates", %{mappings: mappings} do
      assert Have.modify("", "bob show", mappings) == {:error, "Mcex.Modifier.Have: dates parse"}
    end
  end

  defp ago(days) do
    Date.utc_today()
    |> Date.add(-days)
  end
end
