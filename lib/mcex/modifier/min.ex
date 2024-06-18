defmodule Mcex.Modifier.Min do
  use Mc.Modifier

  def modify(buffer, _args, _mappings) do
    Mcex.Math.applyf(buffer, &Enum.min/1)
  end
end
