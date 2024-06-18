defmodule Mcex.Modifier.Wrap do
  use Mc.Modifier

  def modify(buffer, args, mappings) do
    Mc.Modifier.Append.modify(buffer, args, mappings)
    |> Mc.Modifier.Prepend.modify(args, mappings)
  end
end
