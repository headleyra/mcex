defmodule Mcex.Modifier.Tee do
  use Mc.Modifier

  def m(buffer, args, mappings) do
    script = args
    Mc.m(buffer, script, mappings)
    {:ok, buffer}
  end
end
