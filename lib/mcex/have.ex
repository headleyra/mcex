defmodule Mcex.Have do
  def stats(date_str, today) do
    dates = dateify(date_str)
    intervals = ints(dates, today)
    calc(dates, intervals, today)
  end

  def intervals(date_str, today) do
    date_str
    |> dateify()
    |> ints(today)
  end

  defp dateify(date_str) do
    if blank?(date_str) do
      {:error, :nodates}
    else
      date_str
      |> String.split()
      |> Enum.reduce_while([], fn str, acc -> to_date(str, acc) end)
      |> sort_uniqueify()
    end
  end

  defp ints({:error, reason}, _today), do: {:error, reason}

  defp ints({result, [date_1, date_2 | rest]}, today) do
    next_interval = Date.diff(date_2, date_1) - 1
    ints({[next_interval | result], [date_2 | rest]}, today)
  end

  defp ints({result, [date]}, today) do
    last_interval = Date.diff(today, date)
    Enum.reverse([last_interval | result])
  end

  defp ints(dates, today) do
    ints({[], dates}, today)
  end

  defp calc({:error, reason}, _intervals, _today), do: {:error, reason}

  defp calc(have_dates, intervals, today) do
    all_dates = concat(have_dates, today)
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

  defp first_last_day(dates) do
    first = List.first(dates)
    last = Enum.at(dates, -1)
    {first, last}
  end

  defp days_count(first_day, last_day) do
    Date.diff(last_day, first_day) + 1
  end

  defp concat(dates, today) do
    dates ++ [today]
  end
end
