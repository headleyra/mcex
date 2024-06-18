defmodule Mcex.Modifier.Truncate do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    with \
      chars = String.graphemes(buffer),
      char_count = chars |> Enum.count(),
      {:ok, truncate_count} when truncate_count >= 1 <- Mc.String.to_int(args)
    do
      if truncate?(char_count, truncate_count), do: truncate(chars, truncate_count), else: {:ok, buffer}
    else
      _error ->
        oops("bad character count")
    end
  end

  def truncate?(string_count, truncate_count) do
    (string_count - truncate_count) > 0
  end

  defp truncate(buffer_list_chars, truncate_count) do
    {:ok,
      buffer_list_chars
      |> Enum.take(truncate_count - 1)
      |> List.insert_at(-1, "~")
      |> Enum.join()
    }
  end
end
