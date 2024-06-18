defmodule Mcex.Modifier.Tee do
  use Mc.Modifier

  def modify(buffer, args, mappings) do
    script = args
    Mc.modify(buffer, script, mappings)
    {:ok, buffer}
  end
end
