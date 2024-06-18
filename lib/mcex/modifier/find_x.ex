defmodule Mcex.Modifier.FindX do
  use Mc.Modifier

  def modify(_buffer, args, _mappings) do
    with \
      {:parse, %{k: key_regx_str, v: value_regex_str}} <- {:parse, Mcex.Parse.mapify(args)},
      {:ok, result} <- apply(adapter(), :findx, [key_regx_str, value_regex_str])
    do
      {:ok, result}
    else
      {:parse, _} ->
        oops("parse error")

      {:error, reason} ->
        oops(reason)
    end
  end

  defp adapter do
    Application.get_env(:mc, :kv_adapter)
  end
end
