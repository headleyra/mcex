defmodule Mcex.Tokenizer do
  @open_brace "{"
  @close_brace "}"

  def count(list) do
    list
    |> Enum.map(fn e -> Integer.parse(e) end)
    |> Enum.reject(fn e -> e == :error end)
    |> Enum.map(fn {int, _} -> int end)
    |> Enum.sum()
  end

  def parse(string) do
    string
    |> String.graphemes()
    |> Enum.chunk_while([], chunk_func(@open_brace, @close_brace), after_func())
    |> validate()
  end

  defp chunk_func(open_brace, close_brace) do
    fn char, acc ->
      case {char, acc} do
        {^open_brace, _acc} ->
          {:cont, {:open, []}}

        {^close_brace, {:open, chars}} ->
          ordered_chars = Enum.reverse(chars)
          {:cont, {:ok, ordered_chars}}

        {^close_brace, _acc} ->
          {:cont, [], {:open, :mismatch}}

        {_char, {:open, chars}} ->
          new_chars = [char | chars]
          {:cont, {:open, new_chars}}

        {char, acc} ->
          {:cont, char, acc}
      end
    end
  end

  defp after_func do
    fn acc ->
      {:cont, acc, []}
    end
  end

  defp validate(acc) do
    bad = Enum.any?(acc, fn char -> match?({:open, _}, char) end)

    if bad do
      {:error, :mismatch}
    else
      acc
      |> Enum.reject(fn char -> char == [] end)
    end
  end
end
