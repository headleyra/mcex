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
      "neo" => "#{ago(5)} #{ago(3)} #{ago(0)}",
      "ft1" => "#{ago(0)}",
      "ft2" => "#{ago(0)} #{ago(-1)}"
    }})

    mappings = %{
      get: Mc.Modifier.Get,
      set: Mc.Modifier.Set,
      buffer: Mc.Modifier.Buffer,
      trim: Mc.Modifier.Trim,
      trap: Mcex.Modifier.Trap,
      date: Mcex.Modifier.Date
    }

    %{mappings: mappings}
  end

  describe "modify/3" do
    test "shows stats for a key (up to, and including, yesterday)", %{mappings: mappings} do
      assert Have.modify("", "dan show", mappings) == {:ok, "one: #{ago(7)}\nhav: 2\ntot: 7\navg: 2.5\nint: 1, 4"}
      assert Have.modify("", "jed show", mappings) == {:ok, "one: #{ago(7)}\nhav: 3\ntot: 7\navg: 1.33\nint: 1, 1, 2"}
      assert Have.modify("", "neo show", mappings) == {:ok, "one: #{ago(5)}\nhav: 2\ntot: 5\navg: 1.5\nint: 1, 2"}
    end

    test "works with 'have' days that are in the future", %{mappings: mappings} do
      assert Have.modify("", "ft1 show", mappings) == {:ok, "one: n/a\nhav: 0\ntot: 0\navg: 0\nint:"}
      assert Have.modify("", "ft2 show", mappings) == {:ok, "one: n/a\nhav: 0\ntot: 0\navg: 0\nint:"}
    end

    test "adds today as a 'have' day", %{mappings: mappings} do
      today = "#{ago(0)}"
      assert Have.modify("", "sam", mappings) == {:ok, today}
      assert Mc.m("get sam", mappings) == {:ok, today}
    end

    test "errors when a key contains whitespace", %{mappings: mappings} do
      assert Have.modify("", "tim show", mappings) == {:error, "Mcex.Modifier.Have: whitespace dates"}
      assert Have.modify("", "jon show", mappings) == {:error, "Mcex.Modifier.Have: whitespace dates"}
    end

    test "errors when a key doesn't exist", %{mappings: mappings} do
      assert Have.modify("", "no.exist show", mappings) == {:error, "Mcex.Modifier.Have: dates key not found"}
    end

    test "errors with a key containing 'bad' dates", %{mappings: mappings} do
      assert Have.modify("", "bob show", mappings) == {:error, "Mcex.Modifier.Have: bad dates"}
    end
  end

  defp ago(days) do
    Date.utc_today()
    |> Date.add(-days)
  end
end
