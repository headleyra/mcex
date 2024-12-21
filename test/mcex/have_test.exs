defmodule Mcex.HaveTest do
  use ExUnit.Case, async: true
  alias Mcex.Have

  describe "stats/2" do
    test "calculates the average interval between 'have' days", do: true
    test "expects today's date as the 2nd argument", do: true

    test "works with an empty date string" do
      assert Have.stats("", d(5)) == %{one: "n/a", tot: 0, hav: 0, avg: "infinity"}
      assert Have.stats("\n \t ", d(8)) == %{one: "n/a", tot: 0, hav: 0, avg: "infinity"}
    end

    test "works with 1 date" do
      assert Have.stats(t(2), d(3)) == %{one: d(2), tot: 2, hav: 1, avg: 1}
      assert Have.stats(t(11), d(15)) == %{one: d(11), tot: 5, hav: 1, avg: 4}
    end

    test "works with 1 date (where <today> = <the have date>)" do
      assert Have.stats(t(2), d(2)) == %{one: d(2), tot: 1, hav: 1, avg: "n/a"}
    end

    test "works with 2 or more dates (white space separated)" do
      assert Have.stats("#{t(1)} #{t(2)}", d(5)) == %{one: d(1), tot: 5, hav: 2, avg: 1.5}
    end

    test "works with 2 or more dates (where <today> = <last date>)" do
      assert Have.stats(t([1, 2]), d(2)) == %{one: d(1), tot: 2, hav: 2, avg: 0}
    end

    test "works with 2 or more dates (regardless of chronological order)" do
      assert Have.stats(t([2, 1]), d(5)) == %{one: d(1), tot: 5, hav: 2, avg: 1.5}
      assert Have.stats(t([2, 1, 5]), d(7)) == %{one: d(1), tot: 7, hav: 3, avg: 1.33}
      assert Have.stats(t([9, 7, 1]), d(12)) == %{one: d(1), tot: 12, hav: 3, avg: 3.0}
    end

    test "treats duplicate dates as one date" do
      s1 = Have.stats(t([11, 11]), d(15))
      s2 = Have.stats(t([11, 11, 11]), d(15))

      assert s1 == %{one: d(11), tot: 5, hav: 1, avg: 4}
      assert s1 == s2
    end

    test "errors with bad dates" do
      assert Have.stats("2011-5-123", d(15)) == :error
      assert Have.stats("1987.3.7", d(5)) == :error
      assert Have.stats("foo-bar-biz", d(7)) == :error
    end
  end

  defp d(d) do
    Date.new!(2017, 1, d) 
  end

  defp t(day) when is_integer(day) do
    "2017-1-#{day}"
  end

  defp t(days) when is_list(days) do
    Enum.map_join(days, "\n", fn day -> "2017-1-#{day}" end)
  end
end
