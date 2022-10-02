defmodule Mcex.Modifier.Setm do
  use Mc.Railway, [:modify]

  def modify(buffer, args) do
    set_multiple(buffer, args)
  end

  defp set_multiple(buffer, ""), do: update(buffer, "\n---\n")
  defp set_multiple(buffer, separator), do: update(buffer, separator)

  defp update(buffer, separator) do
    case Mc.Uri.decode(separator) do
      {:ok, decoded_separator} ->
        String.split(buffer, decoded_separator)
        |> parse()
        |> validate()
        |> set(buffer)

      _error ->
        oops(:modify, "bad URI separator")
    end
  end

  defp parse(kv_strings_list) do
    kv_strings_list
    |> Enum.map(fn kv_string -> to_tuple(kv_string) end)
  end

  defp validate(kv_tuple_list) do
    if Enum.all?(kv_tuple_list), do: kv_tuple_list, else: false
  end

  defp set(kv_tuple_list, buffer) do
    if kv_tuple_list do
      Enum.each(kv_tuple_list, fn {key, value} -> Mc.modify(value, "set #{key}") end)
      {:ok, buffer}
    else
      oops(:modify, "mismatched key/value pairs")
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
