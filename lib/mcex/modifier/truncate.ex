defmodule Mcex.Modifier.Truncate do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    chars = String.graphemes(buffer)
    char_count = chars |> Enum.count()

    case Mc.String.to_int(args) do
      {:ok, truncate_count} when truncate_count >= 1 ->
        if truncatable?(char_count, truncate_count) do
          truncate(chars, truncate_count)
        else
          {:ok, buffer}
        end

      _error ->
        oops("bad truncate count")
    end
  end

  def truncatable?(char_count, truncate_count) do
    (char_count - truncate_count) > 0
  end

  defp truncate(list_of_chars, truncate_count) do
    {:ok,
      list_of_chars
      |> Enum.take(truncate_count - 1)
      |> List.insert_at(-1, "~")
      |> Enum.join()
    }
  end
end
