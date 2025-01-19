defmodule Mcex.Modifier.HaveTest do
  use ExUnit.Case, async: false
  alias Mcex.Modifier.Have

  defp ago(days) do
    Date.utc_today()
    |> Date.add(-days)
  end

  defp day_1 do
    ago(7)
  end

  defp day_2 do
    ago(2)
  end

  setup do
    start_supervised({Mc.Adapter.KvMemory, map: %{
      "bob" => "2016-7-foo\n2017-01-02 2018-07-05",
      "tim" => "  ",
      "jon" => "\n  \t",
      "dan" => "#{day_1()}\n#{day_2()}"
    }})

    mappings = %Mc.Mappings{} |> Map.merge(%Mcex.Mappings{})
    %{mappings: mappings}
  end

  describe "modify/3" do
    test "expects `mappings` to contain key/value modifiers, 'get' and 'set'", do: true
    test "expects `mappings` to contain the 'trap' modifier (from `%Mcex.Mappings{}`)", do: true

    @error {:error, "Mcex.Modifier.Have: no dates"}

    test "errors with a key that doesn't exist (or is 'empty')", %{mappings: mappings} do
      assert Have.modify("", "no.exist show", mappings) == @error
      assert Have.modify("", "tim show", mappings) == @error
      assert Have.modify("", "jon show", mappings) == @error
    end

    test "errors with a key containing 'bad' dates", %{mappings: mappings} do
      assert Have.modify("", "bob show", mappings) == {:error, "Mcex.Modifier.Have: dates parse"}
    end

    test "adds today as a 'have' day", %{mappings: mappings} do
      today = "#{Date.utc_today()}"
      assert Have.modify("", "sam", mappings) == {:ok, today}
      assert Mc.m("get sam", mappings) == {:ok, today}
    end

    test "shows stats for a non-empty key", %{mappings: mappings} do
      assert Have.modify("", "dan show", mappings) == {:ok, "one: #{day_1()}\nhav: 2\ntot: 8\navg: 3.0\nint: 4, 2"}
    end
  end
end
