defmodule Mcex.Modifier.If do
  use Mc.Modifier

  def modify(buffer, args, mappings) do
    with \
      %{r: regex_str, t: true_script, f: false_script} <- Mcex.Parse.mapify(args),
      {:ok, regex} <- Regex.compile(regex_str)
    do
      script = if String.match?(buffer, regex), do: true_script, else: false_script
      Mc.modify(buffer, script, mappings)
    else
      {:error, _} ->
        oops("bad regex")

      _ ->
        oops("parse error")
    end
  end
end
