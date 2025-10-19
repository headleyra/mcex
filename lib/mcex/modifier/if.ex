defmodule Mcex.Modifier.If do
  use Mc.Modifier

  def modify(buffer, args, mappings) do
    with \
      [regx_str, true_script, false_script] <- Mcex.Parse.split(args),
      {:ok, regx} <- Regex.compile(regx_str)
    do
      script = if String.match?(buffer, regx), do: true_script, else: false_script
      Mc.m(buffer, script, mappings)
    else
      {:error, _} ->
        oops("bad regex")

      _ ->
        oops("parse error")
    end
  end
end
