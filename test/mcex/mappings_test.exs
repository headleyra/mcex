defmodule Mcex.MappingsTest do
  use ExUnit.Case, async: true

  describe "%Mcex.Mappings{}" do
    test "defines modifiers that exist" do
      %Mcex.Mappings{}
      |> Map.from_struct()
      |> Map.values()
      |> Enum.each(fn module -> exists?(module) end)
    end
  end

  defp exists?(module) do
    Code.ensure_loaded(module)
    assert function_exported?(module, :modify, 3), "#{module} needs to define a modify/3 function"
  end
end
