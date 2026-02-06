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
    buffer {}; {date}
    trim
    set #{key}
    date
    """

    Mc.m(script, mappings)
  end

  defp show(key, mappings) do
    yesterday = Date.utc_today() |> Date.add(-1)

    with \
      {:ok, date_str} <- Mc.m("get #{key}", mappings),
      false <- String.match?(date_str, ~r/^\s*$/)
    do
      date_str
      |> Mcex.Have.stats(yesterday)
      |> render()
    else
      true ->
        oops("whitespace dates")

      {:error, _not_found} ->
        oops("dates key not found")
    end
  end

  defp render(stats) do
    case stats do
      {:error, :parse} ->
        oops("bad dates")

      s->
        intervals =
          s.int
          |> Enum.reverse()
          |> Enum.join(", ")

        result = """
        one: #{s.one}
        hav: #{s.hav}
        tot: #{s.tot}
        avg: #{s.avg}
        int: #{intervals}
        """

        {:ok, String.trim_trailing(result)}
    end
  end
end
