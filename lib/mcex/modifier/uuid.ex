defmodule Mcex.Modifier.Uuid do
  use Mc.Modifier

  def m(_buffer, _args, _mappings) do
    result = UUID.uuid4()
    {:ok, result}
  end
end
