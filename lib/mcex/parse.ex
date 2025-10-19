defmodule Mcex.Parse do
  def split(string) do
    case parse(string) do
      [separator, parts] ->
        uri_separator = URI.decode(separator)
        String.split(parts, "#{uri_separator} ")

      [_separator] ->
        [""]
    end
  end

  defp parse(string) do
    string
    |> String.trim_leading()
    |> String.split(" ", parts: 2)
  end
end
