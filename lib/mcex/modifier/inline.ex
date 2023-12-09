defmodule Mcex.Modifier.Inline do
  use Mc.Railway, [:modify]

  def modify(buffer, _args, mappings) do
    Mc.Modifier.Buffer.modify("", buffer, mappings)
  end
end
