defmodule Mcex.Modifier.Getm do
  use Mc.Modifier

  def modify(buffer, args, mappings) do
    get_multiple(buffer, args, mappings)
  end

  defp get_multiple(buffer, "", mappings), do: expand(buffer, "\n---\n", mappings)
  defp get_multiple(buffer, separator, mappings), do: expand(buffer, separator, mappings)

  defp expand(buffer, separator, mappings) do
    case Mc.Uri.decode(separator) do
      {:ok, decoded_separator} ->
        {:ok,
          buffer
          |> String.split()
          |> Enum.map(fn key -> {key, Mc.modify("", "get #{key}", mappings)} end)
          |> Enum.map(&key_valueize/1)
          |> Enum.join(decoded_separator)
        }

      _error ->
        oops("bad URI separator")
    end
  end

  defp key_valueize({key, {:ok, value}}), do: "#{key}\n#{value}"
  defp key_valueize({key, {:error, "not found"}}), do: "#{key}\n"
end
