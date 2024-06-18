defmodule Mcex.Modifier.Max do
  use Mc.Modifier

  def modify(buffer, _args, _mappings) do
    Mcex.Math.applyf(buffer, &Enum.max/1)
  end
end
