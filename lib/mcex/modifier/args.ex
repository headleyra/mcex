defmodule Mcex.Modifier.Args do
  use Mc.Modifier

  def modify(buffer, args, mappings) do
    Mc.modify(buffer, "#{args} #{buffer}", mappings)
  end
end
