defmodule Mcex.Have do
  def stats(date_str, today) do
    cond do
      blank?(date_str) ->
        %{one: "n/a", tot: 0, hav: 0, avg: "infinity", cur: "n/a"}

      true ->
        calc_or_error(date_str, today)
    end
  end

  defp blank?(str) do
    String.match?(str, ~r/^\s*$/)
  end

  defp calc_or_error(date_str, today) do
    case dates(date_str) do
      {:error, _} ->
        :error

      valid_dates ->
        calc(valid_dates, today)
    end
  end

  defp calc([date], today) when date == today do
    %{one: date, tot: 1, hav: 1, avg: "n/a", cur: 0}
  end

  defp calc(have_dates, today) do
    all_dates = concat(have_dates, today)
    {first_day, last_day} = first_last_day(all_dates)
    {_, last_have_day} = first_last_day(have_dates)
    days_count = days_count(first_day, last_day)
    have_days_count = have_days(have_dates)
    intervals = intervals(all_dates)
    current_interval = current_interval(last_have_day, today)

    if intervals > 0 do
      average_interval_precise = (days_count - have_days_count) / intervals
      average_interval = Float.round(average_interval_precise, 2)

      %{
        one: first_day,
        tot: days_count,
        hav: have_days_count,
        avg: average_interval,
        cur: current_interval
      }
    else
      %{
        one: "undefined",
        tot: "undefined",
        hav: "undefined",
        avg: "undefined",
        cur: "undefined"
      }
    end
  end

  defp dates(date_str) do
    date_str
    |> String.split()
    |> Enum.reduce_while([], fn str, acc -> to_date(str, acc) end)
    |> sort_uniqueify()
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
      _foo ->
        {:halt, {:error, :parse}}
    end
  end

  defp sort_uniqueify(dates) do
    case dates do
      {:error, _} ->
        dates

      _ok ->
        dates
        |> Enum.sort(Date)
        |> Enum.uniq()
    end
  end

  defp have_days(dates) do
    Enum.count(dates)
  end

  defp current_interval(last_have_day, today) do
    Date.diff(today, last_have_day)
  end

  defp first_last_day(dates) do
    first = List.first(dates)
    last = Enum.at(dates, -1)
    {first, last}
  end

  defp days_count(first_day, last_day) do
    Date.diff(last_day, first_day) + 1
  end

  defp intervals(dates) do
    Enum.count(dates) - 1
  end

  defp concat(dates, today) do
    dates ++ [today]
  end
end
