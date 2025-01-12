defmodule Mcex.Modifier.Have do
  use Mc.Modifier

  def modify(_buffer, args, mappings) do
    case String.split(args) do
      [key] ->
        add_date(key, mappings)

      [key, "show"] ->
        show(key, mappings)

      _parse_error ->
        oops("parse error")
    end
  end

  defp add_date(key, mappings) do
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

    case Mcex.Have.stats(date_str, Date.utc_today()) do
      :error ->
        oops("parse")

      stats ->
        result = """
        one: #{stats.one}
        hav: #{stats.hav}
        tot: #{stats.tot}
        avg: #{stats.avg}
        cur: #{stats.cur}
        """

        {:ok, String.trim_trailing(result)}
    end
  end
end
