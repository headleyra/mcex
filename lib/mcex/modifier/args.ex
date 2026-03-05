defmodule Mcex.Modifier.Args do
  use Mc.Modifier

  def m(buffer, args, mappings) do
    Mc.m(buffer, "#{args} #{buffer}", mappings)
  end
end
