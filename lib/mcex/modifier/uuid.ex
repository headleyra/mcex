defmodule Mcex.Modifier.Uuid do
  use Mc.Modifier

  def modify(_buffer, _args, _mappings) do
    result = UUID.uuid4()
    {:ok, result}
  end
end
