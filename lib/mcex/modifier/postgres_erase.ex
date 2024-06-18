defmodule Mcex.Modifier.PostgresErase do
  use Mc.Modifier

  def modify(_buffer, args, _mappings) do
    adapter().delete(args)
  end

  defp adapter do
    Application.get_env(:mc, :kv_adapter)
  end
end
