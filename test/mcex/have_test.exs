defmodule Mcex.HaveTest do
  use ExUnit.Case, async: true
  alias Mcex.Have

  describe "summary/2" do
    test "returns have stats (expects today's date as 2nd argument)" do
      assert true
    end

    test "works with no have dates" do
      assert Have.summary([], Date.new!(2015, 1, 8)) == %{
        one: "n/a",
        tot: 0,
        hav: 0,
        avg: "infinity"
      }
    end

    test "works with 1 have date" do
      assert Have.summary([Date.new!(2016, 1, 2)], Date.new!(2016, 1, 3)) == %{
        one: Date.new!(2016, 1, 2),
        tot: 2,
        hav: 1,
        avg: 1
      }

      assert Have.summary([Date.new!(2017, 5, 11)], Date.new!(2017, 5, 15)) == %{
        one: Date.new!(2017, 5, 11),
        tot: 5,
        hav: 1,
        avg: 4
      }
    end

    test "works with 1 have date (where <today> = <the have date>" do
      assert Have.summary([Date.new!(2016, 1, 2)], Date.new!(2016, 1, 2)) == %{
        one: Date.new!(2016, 1, 2),
        tot: 1,
        hav: 1,
        avg: "n/a"
      }
    end

    test "works with 2 or more have dates (where <today> = <last have date>)" do
      d1 = Date.new!(2011, 1, 1)
      d2 = Date.new!(2011, 1, 2)

      assert Have.summary([d1, d2], d2) == %{
        one: Date.new!(2011, 1, 1),
        tot: 2,
        hav: 2,
        avg: 0
      }
    end

    test "works with 2 or more have dates (regardless of order)" do
      d1 = Date.new!(2011, 1, 2)
      d2 = Date.new!(2011, 1, 1)
      today = Date.new!(2011, 1, 5)

      assert Have.summary([d1, d2], today) == %{
        one: Date.new!(2011, 1, 1),
        tot: 5,
        hav: 2,
        avg: 1.5
      }

      d1 = Date.new!(2011, 1, 2)
      d2 = Date.new!(2011, 1, 1)
      d3 = Date.new!(2011, 1, 5)
      today = Date.new!(2011, 1, 7)

      assert Have.summary([d1, d2, d3], today) == %{
        one: Date.new!(2011, 1, 1),
        tot: 7,
        hav: 3,
        avg: 1.33
      }

      d1 = Date.new!(2011, 1, 9)
      d2 = Date.new!(2011, 1, 7)
      d3 = Date.new!(2011, 1, 1)
      today = Date.new!(2011, 1, 12)

      assert Have.summary([d1, d2, d3], today) == %{
        one: Date.new!(2011, 1, 1),
        tot: 12,
        hav: 3,
        avg: 3.0
      }
    end
  end

  describe "dates/1" do
    test "converts a string to a list of dates" do
      assert Have.dates("") == []
      assert Have.dates("2024-10-2") == [Date.new!(2024, 10, 2)]
      assert Have.dates("2024-10-2 2025-11-1") == [Date.new!(2024, 10, 2), Date.new!(2025, 11, 1)]
      assert Have.dates("2009-01-2\n2025-7-5") == [Date.new!(2009, 1, 2), Date.new!(2025, 7, 5)]
    end
  end
end
