defmodule Mcex.Modifier.Select do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    buffer_lines = String.split(buffer, "\n")
    parsed_spec = Mcex.LineSpec.parse(args)

    if parsed_spec == :error do
      oops("bad line spec")
    else
      parsed_spec
      |> List.flatten()
      |> Enum.reduce([], fn index, acc -> lineify(buffer_lines, index, acc) end)
      |> result()
    end
  end

  defp lineify(buffer_lines, index, acc) do
    [Enum.at(buffer_lines, index) | acc]
  end

  defp result(lines) do
    {:ok,
      lines
      |> Enum.reverse()
      |> Enum.join("\n")
    }
  end
end
