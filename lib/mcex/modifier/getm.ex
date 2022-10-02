defmodule Mcex.Modifier.Getm do
  use Mc.Railway, [:modify]

  def modify(buffer, args) do
    get_multiple(buffer, args)
  end

  defp get_multiple(buffer, ""), do: expand(buffer, "\n---\n")
  defp get_multiple(buffer, separator), do: expand(buffer, separator)

  defp expand(buffer, separator) do
    case Mc.Uri.decode(separator) do
      {:ok, decoded_separator} ->
        {:ok,
          buffer
          |> String.split()
          |> Enum.map(fn key -> {key, Mc.modify("", "get #{key}")} end)
          |> Enum.map(fn {key, {:ok, value}} -> "#{key}\n#{value}" end)
          |> Enum.join(decoded_separator)
        }

      _error ->
        oops(:modify, "bad URI separator")
    end
  end
end
