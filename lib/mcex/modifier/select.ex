defmodule Mcex.Modifier.Select do
  use Mc.Railway, [:modify]

  def modify(buffer, args, _mappings) do
    buffer_lines = String.split(buffer, "\n")
    line_specs = line_specs_from(args)

    if Enum.any?(line_specs, fn line_spec -> line_spec == :error end) do
      oops(:modify, "bad line spec(s)")
    else
      {:ok,
        line_specs
        |> List.flatten()
        |> Enum.reduce([], fn line, acc -> [Enum.at(buffer_lines, line) | acc] end)
        |> Enum.reverse()
        |> Enum.join("\n")
      }
    end
  end

  defp line_specs_from(args) do
    String.split(args, ",")
    |> Enum.map(fn line_spec -> parse(line_spec) end)
  end

  def parse(line_spec) do
    case String.split(line_spec, "-", parts: 2) do
      [int_str] ->
        int_from(int_str)

      [int_str_a, int_str_b] ->
        int_from(int_str_a, int_str_b)
    end
  end

  def int_from(int_str) do
    case Mc.String.to_int(int_str) do
      {:ok, int} when int > 0 ->
        int - 1

      _error ->
        :error
    end
  end

  def int_from(int_str_a, int_str_b) do
    with \
      first when is_integer(first) <- int_from(int_str_a),
      last when is_integer(last) <- int_from(int_str_b)
    do
      first..last
      |> Enum.to_list()
    end
  end
end
