defmodule Mcex.HaveTest do
  use ExUnit.Case, async: true
  alias Mcex.Have

  describe "stats/2" do
    result = """
    returns a map with the following keys:
    one: first 'have' date
    tot: total number of days up to (and including) the `cut_off_date`
    hav: number of 'have' days
    avg: average interval between 'have' days
    int: last 3 intervals (most recent, last)
    """
    test result, do: true

    test "works with 1 'have' date" do
      assert Have.stats(ds(2), d(3)) == %{one: d(2), tot: 2, hav: 1, avg: 1, int: [1]}
      assert Have.stats(ds(11), d(15)) == %{one: d(11), tot: 5, hav: 1, avg: 4, int: [4]}
    end

    test "works with 1 'have' date (where <today> == <the have date>)" do
      assert Have.stats(ds(2), d(2)) == %{one: d(2), tot: 1, hav: 1, avg: 0.0, int: [0]}
    end

    test "works with 2 or more 'have' dates (white space separated)" do
      assert Have.stats("#{ds(1)} #{ds(2)}", d(5)) == %{one: d(1), tot: 5, hav: 2, avg: 1.5, int: [0, 3]}
    end

    test "works with 2 or more 'have' dates (where <today> == <last have date>)" do
      assert Have.stats(ds([1, 2]), d(2)) == %{one: d(1), tot: 2, hav: 2, avg: 0, int: [0, 0]}
      assert Have.stats(ds([2, 5, 11]), d(11)) == %{one: d(2), tot: 10, hav: 3, avg: 2.33, int: [2, 5, 0]}
    end

    test "works with 2 or more 'have' dates (regardless of chronological order)" do
      assert Have.stats(ds([2, 1]), d(5)) == %{one: d(1), tot: 5, hav: 2, avg: 1.5, int: [0, 3]}
      assert Have.stats(ds([2, 1, 5]), d(7)) == %{one: d(1), tot: 7, hav: 3, avg: 1.33, int: [0, 2, 2]}
      assert Have.stats(ds([9, 7, 1]), d(12)) == %{one: d(1), tot: 12, hav: 3, avg: 3.0, int: [5, 1, 3]}
    end

    test "works with 'have' dates in the future" do
      assert Have.stats(ds(7), d(5)) == %{one: "n/a", tot: 0, hav: 0, avg: 0, int: []}
      assert Have.stats(ds(2), d(1)) == %{one: "n/a", tot: 0, hav: 0, avg: 0, int: []}
    end

    test "treats duplicate 'have' dates as one date" do
      s1 = Have.stats(ds([11, 11]), d(15))
      s2 = Have.stats(ds([11, 11, 11]), d(15))

      assert s1 == %{one: d(11), tot: 5, hav: 1, avg: 4, int: [4]}
      assert s1 == s2
    end

    test "works with 'empty' dates" do
      assert Have.stats("", d(5)) == %{avg: 0, hav: 0, int: [], one: "n/a", tot: 0}
      assert Have.stats("\n \t ", d(8)) == %{avg: 0, hav: 0, int: [], one: "n/a", tot: 0}
    end

    test "errors with bad 'have' dates" do
      assert Have.stats("2014-01-05 2011-5-123", d(15)) == {:error, :parse}
      assert Have.stats("1987.3.7", d(5)) == {:error, :parse}
      assert Have.stats("foo-bar-biz", d(7)) == {:error, :parse}
    end
  end

  describe "intervals/2" do
    test "works with 1 'have' date" do
      assert Have.intervals(ds(2), d(3)) == [1]
      assert Have.intervals(ds(11), d(15)) == [4]
    end

    test "works with 1 'have' date (where <cut off date> == <the have date>)" do
      assert Have.intervals(ds(2), d(2)) == [0]
    end

    test "works with 2 or more dates (where <cut off date> == <last have date>)" do
      assert Have.intervals(ds([1, 2]), d(2)) == [0, 0]
      assert Have.intervals(ds([2, 5, 11]), d(11)) == [2, 5, 0]
    end

    test "works with 2 or more dates (regardless of chronological order)" do
      assert Have.intervals(ds([2, 1]), d(5)) == [0, 3]
      assert Have.intervals(ds([2, 1, 5]), d(7)) == [0, 2, 2]
      assert Have.intervals(ds([9, 7, 1]), d(12)) == [5, 1, 3]
    end

    test "ignores 'have' dates past the cut off date" do
      assert Have.intervals(ds([1, 3, 19]), d(7)) == [1, 4]
      assert Have.intervals(ds([3, 5, 8, 11, 15, 17]), d(8)) == [1, 2, 0]
    end

    test "treats duplicate dates as one date" do
      int1 = Have.intervals(ds([11, 11]), d(15))
      int2 = Have.intervals(ds([11, 11, 11]), d(15))

      assert int1 == [4]
      assert int1 == int2
    end

    test "returns [] with an empty date string" do
      assert Have.intervals("\n \t", d(8)) == []
      assert Have.intervals("", d(7)) == []
    end

    test "errors with bad dates" do
      assert Have.intervals("2014-01-05 2011-5-123", d(15)) == {:error, :parse}
      assert Have.intervals("1987.3.7", d(5)) == {:error, :parse}
      assert Have.intervals("foo-bar-biz", d(7)) == {:error, :parse}
    end
  end

  defp d(day), do: Date.new!(2017, 1, day) 

  defp ds(days) when is_list(days) do
    Enum.map_join(days, "\n", fn day -> ds(day) end)
  end

  defp ds(day) when day < 10, do: "2017-01-0#{day}"
  defp ds(day), do: "2017-01-#{day}"
end
