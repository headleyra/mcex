defmodule Mcex.Parse do
  def mapify(string) do
    args_list =
      string
      |> String.trim()
      |> String.split(~r/\s+(?=\w+:)/)

    case args_list do
      [""] ->
        %{}

      non_emtpy_args_list ->
        mapize(non_emtpy_args_list)
    end
  end

  def split(string) do
    parse_list =
      string
      |> String.trim_leading()
      |> String.split(" ", parts: 2)

    case parse_list do
      [separator, parts] ->
        uri_separator = URI.decode(separator)
        String.split(parts, uri_separator)

      [_separator] ->
        [""]
    end
  end

  defp mapize(args_list) do 
    map =
      args_list
      |> Enum.map(fn arg_str -> split_arg(arg_str) end)
      |> Enum.into(%{}, fn [k, v] -> encode(k, v) end)

    if valid(map), do: map, else: :error
  end

  defp valid(map) do
    map
    |> Map.values()
    |> Enum.any?(fn value -> value != :error end)
  end

  defp split_arg(arg_str) do
    case String.split(arg_str, ":") do
      [k, v] ->
        [k, v]

      _error ->
        [:error, nil]
    end
  end

  defp encode(:error, _value), do: {"", :error}
  defp encode(key, value) do
    key_atom = String.to_atom(key)
    value_uri = URI.decode(value)
    {key_atom, value_uri}
  end
end
