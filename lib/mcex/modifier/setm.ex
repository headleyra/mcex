defmodule Mcex.Modifier.Setm do
  use Mc.Modifier

  def modify(buffer, args, mappings) do
    set_multiple(buffer, args, mappings)
  end

  defp set_multiple(buffer, "", mappings), do: update(buffer, "\n---\n", mappings)
  defp set_multiple(buffer, separator, mappings), do: update(buffer, separator, mappings)

  defp update(buffer, separator, mappings) do
    case Mc.Uri.decode(separator) do
      {:ok, decoded_separator} ->
        String.split(buffer, decoded_separator)
        |> parse()
        |> validate()
        |> set(buffer, mappings)

      _error ->
        oops("bad URI separator")
    end
  end

  defp parse(kv_strings_list) do
    kv_strings_list
    |> Enum.map(fn kv_string -> to_tuple(kv_string) end)
  end

  defp validate(kv_tuple_list) do
    if Enum.all?(kv_tuple_list), do: kv_tuple_list, else: false
  end

  defp set(kv_tuple_list, buffer, mappings) do
    if kv_tuple_list do
      Enum.each(kv_tuple_list, fn {key, value} -> Mc.modify(value, "set #{key}", mappings) end)
      {:ok, buffer}
    else
      oops("mismatched key/value pairs")
    end
  end

  defp to_tuple(kv_string) do
    case String.split(kv_string, "\n", parts: 2) do
      [key, value] ->
        {key, value}

      _error ->
        nil
    end
  end
end
