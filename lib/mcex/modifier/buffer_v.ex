defmodule Mcex.Modifier.BufferV do
  use Mc.Modifier

  def modify(_buffer, args, _mappings) do
    {:ok, args}
  end
end
