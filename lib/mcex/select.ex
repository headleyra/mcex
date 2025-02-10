defmodule Mcex.Select do
  def line_specs(string) do
    string
    |> String.split()
    |> Enum.map(fn line_spec -> parse(line_spec) end)
  end

  def parse(line_spec) do
    case String.split(line_spec, "-", parts: 2) do
      [int_str] ->
        int(int_str)

      [int_str_a, int_str_b] ->
        int(int_str_a, int_str_b)
    end
  end

  def int(int_str) do
    case Mc.String.to_int(int_str) do
      {:ok, int} when int > 0 ->
        int - 1

      _error ->
        :error
    end
  end

  def int(int_str_a, int_str_b) do
    with \
      first when is_integer(first) <- int(int_str_a),
      last when is_integer(last) <- int(int_str_b)
    do
      first..last
      |> Enum.to_list()
    end
  end
end
