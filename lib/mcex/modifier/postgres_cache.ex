defmodule Mcex.Modifier.PostgresCache do
  use Mc.Modifier

  def modify(_buffer, _args, _mappings) do
    {:ok,
      adapter().cache()
      |> Map.keys()
      |> Enum.join("\n")
    }
  end

  defp adapter do
    Application.get_env(:mc, :kv_adapter)
  end
end
