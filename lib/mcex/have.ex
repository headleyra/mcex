defmodule Mcex.Have do
  def stats(date_str, cut_off_date) do
    dates = dateify(date_str, cut_off_date)
    intervals = intervals(dates, [], cut_off_date)
    calc(dates, intervals, cut_off_date)
  end

  def intervals(date_str, cut_off_date) do
    date_str
    |> dateify(cut_off_date)
    |> intervals([], cut_off_date)
  end

  defp dateify(date_str, cut_off_date) do
    if blank?(date_str) do
      {:error, :no_dates}
    else
      date_str
      |> String.split()
      |> Enum.reduce_while([], fn str, acc -> to_date(str, acc) end)
      |> sort_uniqueify()
      |> discard_after_cut_off(cut_off_date)
    end
  end

  defp intervals({:error, reason}, _current_intervals, _cut_off_date), do: {:error, reason}

  defp intervals([date_1, date_2 | rest], current_intervals, cut_off_date) do
    next_interval = Date.diff(date_2, date_1) - 1
    intervals([date_2 | rest], [next_interval | current_intervals], cut_off_date)
  end

  defp intervals([date], current_intervals, cut_off_date) do
    last_interval = Date.diff(cut_off_date, date)
    Enum.reverse([last_interval | current_intervals])
  end

  defp intervals(_dates, _current_intervals, _cut_off_date) do
    []
  end

  defp calc({:error, reason}, _intervals, _cut_off_date), do: {:error, reason}

  defp calc([], _intervals, _cut_off_date) do
    %{
      one: "n/a",
      tot: 0,
      hav: 0,
      avg: 0,
      int: []
    }
  end

  defp calc(have_dates, intervals, cut_off_date) do
    all_dates = concat(have_dates, cut_off_date)
    {first_day, last_day} = first_last_day(all_dates)
    days_count = days_count(first_day, last_day)
    have_days_count = Enum.count(have_dates)

    intervals_count = Enum.count(intervals)
    recent_intervals = Enum.take(intervals, -3)

    average_interval_precise = Enum.sum(intervals) / intervals_count
    average_interval = Float.round(average_interval_precise, 2)

    %{
      one: first_day,
      tot: days_count,
      hav: have_days_count,
      avg: average_interval,
      int: recent_intervals
    }
  end

  defp blank?(str) do
    String.match?(str, ~r/^\s*$/)
  end

  defp to_date(str, acc) do
    import Mc.String, only: [to_int: 1]

    with \
      [yy, mm, dd] <- String.split(str, "-"),
      {:ok, y} <- to_int(yy),
      {:ok, m} <- to_int(mm),
      {:ok, d} <- to_int(dd),
      {:ok, date} <- Date.new(y, m, d)
    do
      {:cont, [date | acc]}
    else
      _parse_error ->
        {:halt, {:error, :parse}}
    end
  end

  defp sort_uniqueify(dates) do
    case dates do
      {:error, :parse} ->
        {:error, :parse}

      _ok ->
        dates
        |> Enum.sort(Date)
        |> Enum.uniq()
    end
  end

  defp discard_after_cut_off({:error, :parse}, _cut_off_date), do: {:error, :parse}

  defp discard_after_cut_off(dates, cut_off_date) do
    Enum.reject(dates, fn date -> Date.diff(cut_off_date, date) < 0 end)
  end

  defp first_last_day(dates) do
    first = List.first(dates)
    last = Enum.at(dates, -1)
    {first, last}
  end

  defp days_count(first_day, last_day) do
    Date.diff(last_day, first_day) + 1
  end

  defp concat(dates, cut_off_date) do
    dates ++ [cut_off_date]
  end
end
