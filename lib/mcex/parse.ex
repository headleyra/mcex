defmodule Mcex.Parse do
  def mapify(string) do
    string
    |> String.split()
    |> Enum.reduce_while(%{}, fn kv_pair, acc -> map(kv_pair, acc) end)
  end

  defp map(kv_pair, acc) do
    case String.split(kv_pair, ":", parts: 2) do
      [key, value] ->
        key_atom = String.to_atom(key)
        value_decoded = URI.decode(value)
        {:cont, Map.put(acc, key_atom, value_decoded)}

      _parse_error ->
        {:halt, :error}
    end
  end
end
