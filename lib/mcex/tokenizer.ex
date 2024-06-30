defmodule Mcex.Tokenizer do
  @open_char "{"
  @close_char "}"

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
    |> Enum.reduce([], fn char, acc -> tokenize(char, acc)  end)
    |> Enum.reverse()
    |> validate()
  end

  defp tokenize(char, acc) do
    case {char, acc} do
      {@open_char, acc} ->
        [{:open, []} | acc]

      {@close_char, [{:open, chars} | rest]} ->
        ordered_chars = Enum.reverse(chars)
        [{:ok, ordered_chars} | rest]

      {_char, [{:open, chars} | rest]} ->
        new_chars = [char | chars]
        [{:open, new_chars} | rest]

      {_char, _acc} ->
        [char | acc]
    end
  end
  
  defp validate(acc) do
    # an unclosed open character can't be detected until the end of processing, we don't mind this, but it
    # needs to be swapped out for a 'proper' one
    
    Enum.map(acc, fn
      {:open, chars} ->
        ordered_chars = Enum.reverse(chars)
        [@open_char | ordered_chars]

      char ->
        char
    end)
    |> List.flatten()
  end
end
