defmodule Mcex.MappingsTest do
  use ExUnit.Case, async: true
  alias Mcex.Mappings

  describe "standard/0" do
    test "defines modifiers that exist" do
      Mappings.standard()
      |> Map.values()
      |> Enum.each(fn module -> exists?(module) end)
    end
  end

  defp exists?(module) do
    Code.ensure_loaded(module)
    assert function_exported?(module, :m, 3), "Module #{inspect(module)} does not exist or is missing a m/3 function"
  end
end
