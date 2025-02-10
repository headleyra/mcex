defmodule Mcex.Modifier.Select do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    buffer_lines = String.split(buffer, "\n")

    args
    |> Mcex.Select.line_specs()
    |> List.flatten()
    |> Enum.reduce_while([], fn index, acc -> lineify(buffer_lines, index, acc) end)
    |> result()
  end

  defp lineify(_buffer_lines, :error, _acc) do
    {:halt, oops("bad line spec(s)")}
  end

  defp lineify(buffer_lines, index, acc) do
    {:cont, [Enum.at(buffer_lines, index) | acc]}
  end

  defp result({:error, reason}), do: {:error, reason}

  defp result(lines) do
    {:ok,
      lines
      |> Enum.reverse()
      |> Enum.join("\n")
    }
  end
end
