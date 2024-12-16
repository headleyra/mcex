defmodule Mcex.Modifier.Have do
  use Mc.Modifier

  def modify(_buffer, args, mappings) do
    case String.split(args) do
      [key] ->
        have(key, mappings)

      [key, "show"] ->
        show(key, mappings)

      _parse_error ->
        oops("parse")
    end
  end

  defp have(key, mappings) do
    script = """
    get #{key}
    trap
    b {}; {date}
    trim
    set #{key}
    date
    """

    Mc.m(script, mappings)
  end

  defp show(key, mappings) do
    script = """
    get #{key}
    trap
    """

    {:ok, date_str} = Mc.m(script, mappings)
    dates = Mcex.Have.dates(date_str)
    summary = Mcex.Have.summary(dates, Date.utc_today())

    {:ok,
      """
      1st have: #{summary.first}
      have days: #{summary.have}
      total days: #{summary.total}
      average interval: #{summary.average}
      """
    }
  end
end
