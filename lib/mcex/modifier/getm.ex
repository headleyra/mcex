defmodule Mcex.Modifier.Getm do
  use Mc.Railway, [:modify]

  def modify(buffer, args) do
    getm(buffer, args)
  end

  def getm(buffer, ""), do: getm_(buffer, "\n---\n")
  def getm(buffer, separator), do: getm_(buffer, separator)

  def getm_(buffer, separator) do
    case Mc.String.Inline.uri_decode(separator) do
      {:ok, decoded_separator} ->
        result =
          buffer
          |> String.split()
          |> Enum.map(fn key -> {key, Mc.modify("", "get #{key}")} end)
          |> Enum.map(fn {key, {:ok, value}} -> "#{key}\n#{value}" end)
          |> Enum.join(decoded_separator)

        {:ok, result}

      _error ->
        usage(:modify, "[<uri encoded separator>]")
    end
  end
end
