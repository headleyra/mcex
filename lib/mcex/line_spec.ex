defmodule Mcex.LineSpec do
  def parse(spec) do
    spec
    |> String.split()
    |> Enum.map(fn e -> intify(e) end)
    |> result()
  end

  defp intify(spec_fragment) do
    case String.split(spec_fragment, "-", parts: 2) do
      [a] ->
        int(a)

      [a, b] ->
        int(a, b)
    end
  end

  defp int(a) do
    case Mc.String.to_int(a) do
      {:ok, int} when int > 0 ->
        int - 1

      _error ->
        :error
    end
  end

  defp int(a, b) do
    with \
      first when is_integer(first) <- int(a),
      last when is_integer(last) <- int(b)
    do
      expand(first, last)
    end
  end

  defp expand(first, last) do
    step = if last >= first, do: 1, else: -1

    Range.new(first, last, step)
    |> Enum.to_list()
  end

  defp result([]), do: :error

  defp result(list) do
    if Enum.any?(list, &(&1 == :error)), do: :error, else: list
  end
end
