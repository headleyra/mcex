defmodule Mcex.Modifier.Inline do
  use Mc.Railway, [:modify]

  def modify(buffer, _args) do
    Mc.Modifier.Buffer.modify("", buffer)
  end
end
