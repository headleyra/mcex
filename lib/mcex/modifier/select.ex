defmodule Mcex.Modifier.Select do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    buffer_lines = String.split(buffer, "\n")
    line_specs = Mcex.Select.line_specs(args)

    if Enum.any?(line_specs, fn line_spec -> line_spec == :error end) do
      oops("bad line spec(s)")
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
end
