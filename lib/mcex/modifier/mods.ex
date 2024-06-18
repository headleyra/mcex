defmodule Mcex.Modifier.Mods do
  use Mc.Modifier

  def modify(_buffer, _args, mappings) do
    result =
      mappings
      |> Map.from_struct()
      |> Map.to_list()
      |> Enum.map(fn {name, module} -> "#{name}: #{inspect(module)}" end)
      |> Enum.join("\n")

    {:ok, result}
  end
end
