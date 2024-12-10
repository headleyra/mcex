defmodule Mcex.Have do
  def summary([], _todays_date), do: %{first: "n/a", total: 0, have: 0, average: "infinity"}

  def summary([date], todays_date) when date == todays_date do
    %{first: date, total: 1, have: 1, average: "n/a"}
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
      average_interval = Float.round(average_interval_precise, 1)
    do
      %{
        first: first_date,
        total: total_days,
        have: total_have_days,
        average: average_interval
      }
    else
      _error ->
        %{
          first: "undefined",
          total: "undefined",
          have: "undefined",
          average: "undefined"
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
