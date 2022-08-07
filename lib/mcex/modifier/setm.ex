defmodule Mcex.Modifier.Setm do
  use Mc.Railway, [:modify]

  def modify(buffer, args) do
    setm(buffer, args)
  end

  def setm(buffer, ""), do: setm_(buffer, "\n---\n")
  def setm(buffer, separator), do: setm_(buffer, separator)

  def setm_(buffer, separator) do
    case Mc.String.Inline.uri_decode(separator) do
      {:ok, decoded_separator} ->
        String.split(buffer, decoded_separator)
        |> parse()
        |> validate()
        |> set(buffer)

      _error ->
        usage(:modify, "[<uri encoded separator>]")
    end
  end

  def parse(kv_strings_list) do
    kv_strings_list
    |> Enum.map(fn kv_string -> to_tuple(kv_string) end)
  end

  def validate(kv_tuple_list) do
    if Enum.all?(kv_tuple_list), do: kv_tuple_list, else: false
  end

  def set(kv_tuple_list, buffer) do
    if kv_tuple_list do
      Enum.each(kv_tuple_list, fn {key, value} -> Mc.modify(value, "set #{key}") end)
      {:ok, buffer}
    else
      oops(:modify, "mismatched key/value pairs")
    end
  end

  def to_tuple(kv_string) do
    case String.split(kv_string, "\n", parts: 2) do
      [key, value] ->
        {key, value}

      _error ->
        nil
    end
  end
end
