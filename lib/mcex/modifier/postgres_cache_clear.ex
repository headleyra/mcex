defmodule Mcex.Modifier.PostgresCacheClear do
  use Mc.Modifier

  def modify(_buffer, args, _mappings) do
    adapter().clear_cache(args)
    {:ok, args}
  end

  defp adapter do
    Application.get_env(:mc, :kv_adapter)
  end
end
