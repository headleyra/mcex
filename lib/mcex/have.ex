defmodule Mcex.Have do
  def summary([], _todays_date), do: %{one: "n/a", tot: 0, hav: 0, avg: "infinity"}

  def summary([date], todays_date) when date == todays_date do
    %{one: date, tot: 1, hav: 1, avg: "n/a"}
  end

  def summary(have_dates, todays_date) do
    with \
      dates = normalize(have_dates, todays_date),
      first_date = List.first(dates),
      last_date = Enum.at(dates, -1),
      total_days = Date.diff(last_date, first_date) + 1,
      total_have_days = Enum.count(have_dates),
      intervals when intervals != 0 <- Enum.count(dates) - 1,
      average_interval_precise = (total_days - total_have_days) / intervals,
      average_interval = Float.round(average_interval_precise, 2)
    do
      %{
        one: first_date,
        tot: total_days,
        hav: total_have_days,
        avg: average_interval
      }
    else
      _error ->
        %{
          one: "undefined",
          tot: "undefined",
          hav: "undefined",
          avg: "undefined"
        }
    end
  end

  def dates(date_str) do
    date_str
    |> String.split()
    |> Enum.map(fn e -> String.split(e, "-") end)
    |> Enum.map(fn [y, m, d] -> to_date(y, m, d) end)
  end

  defp to_date(y, m, d) do
    Date.new!(String.to_integer(y), String.to_integer(m), String.to_integer(d))
  end

  defp normalize(dates, today) do
    dates ++ [today]
    |> Enum.uniq()
    |> Enum.sort(Date)
  end
end
