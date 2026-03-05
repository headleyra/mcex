defmodule Mcex.Modifier.Wrap do
  use Mc.Modifier

  def m(buffer, args, mappings) do
    Mc.Modifier.Append.m(buffer, args, mappings)
    |> Mc.Modifier.Prepend.m(args, mappings)
  end
end
