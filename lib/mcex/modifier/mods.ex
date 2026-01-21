defmodule Mcex.Modifier.Mods do
  use Mc.Modifier

  def modify(_buffer, _args, mappings) do
    result =
      mappings
      |> Map.to_list()
      |> Enum.map_join("\n", fn {name, module} -> "#{name}: #{inspect(module)}" end)

    {:ok, result}
  end
end
