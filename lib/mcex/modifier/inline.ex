defmodule Mcex.Modifier.Inline do
  use Mc.Modifier

  def m(buffer, _args, mappings) do
    Mc.Modifier.Buffer.m("", buffer, mappings)
  end
end
