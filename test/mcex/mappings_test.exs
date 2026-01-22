defmodule Mcex.MappingsTest do
  use ExUnit.Case, async: true
  alias Mcex.Mappings

  describe "standard/0, s/0" do
    test "specify modifiers that exist" do
      Enum.each([:standard, :s], fn func ->
        apply(Mappings, func, [])
        |> Map.values()
        |> Enum.each(fn module -> exists?(module) end)
      end)
    end
  end

  defp exists?(module) do
    Code.ensure_loaded(module)
    assert function_exported?(module, :modify, 3), "Module #{inspect(module)} does not exist or is missing a modify/3 function"
  end
end
