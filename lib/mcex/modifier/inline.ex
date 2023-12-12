defmodule Mcex.Modifier.Inline do
  use Mc.Modifier

  def modify(buffer, _args, mappings) do
    Mc.Modifier.Buffer.modify("", buffer, mappings)
  end
end
