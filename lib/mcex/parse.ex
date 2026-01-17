defmodule Mcex.Parse do
  def split(string) do
    case parse(string) do
      [separator, rest_of_string] ->
        uri_separator = URI.decode(separator)
        String.split(rest_of_string, "#{uri_separator} ")

      _unsplittable_string ->
        [string]
    end
  end

  defp parse(string) do
    string
    |> String.trim_leading()
    |> String.split(" ", parts: 2)
  end
end
