defmodule Mcex.Have do
  def stats(date_str, cut_off_date) do
    get(date_str, cut_off_date, :all)
  end

  def intervals(date_str, cut_off_date) do
    get(date_str, cut_off_date)
  end

  defp get(date_str, cut_off_date, type \\ nil) do
    dates = dateify(date_str, cut_off_date)
    intervals = intervals(dates, [], cut_off_date)
    if type == :all, do: calc(dates, intervals, cut_off_date), else: intervals
  end

  defp dateify(date_str, cut_off_date) do
    date_str
    |> parse()
    |> discard_duplicates_and_sort()
    |> discard_after(cut_off_date)
  end

  defp parse(date_str) do
    date_str
    |> String.split()
    |> Enum.reduce_while([], fn str, acc -> to_date(str, acc) end)
  end

  defp intervals([], _current_intervals, _cut_off_date), do: []
  defp intervals({:error, reason}, _current_intervals, _cut_off_date), do: {:error, reason}

  defp intervals([date_1, date_2 | rest], current_intervals, cut_off_date) do
    next_interval = Date.diff(date_2, date_1) - 1
    intervals([date_2 | rest], [next_interval | current_intervals], cut_off_date)
  end

  defp intervals([date], current_intervals, cut_off_date) do
    last_interval = Date.diff(cut_off_date, date)
    Enum.reverse([last_interval | current_intervals])
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
    {first_day, last_day} = first_and_last(all_dates)
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

  defp to_date(date_str, acc) do
    case Date.from_iso8601(date_str) do
      {:ok, date} ->
        {:cont, [date | acc]}

      _parse_error ->
        {:halt, {:error, :parse}}
    end
  end

  defp discard_duplicates_and_sort(dates) do
    case dates do
      {:error, :parse} ->
        {:error, :parse}

      _ok ->
        dates
        |> Enum.sort(Date)
        |> Enum.uniq()
    end
  end

  defp discard_after({:error, :parse}, _cut_off_date), do: {:error, :parse}

  defp discard_after(dates, cut_off_date) do
    Enum.reject(dates, fn date -> Date.diff(cut_off_date, date) < 0 end)
  end

  defp first_and_last(dates) do
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
