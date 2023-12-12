defmodule Mcex.Modifier.Date do
  use Mc.Modifier

  def modify(_buffer, _args, _mappings) do
    {:ok,
      Date.utc_today()
      |> Date.to_iso8601()
    }
  end
end
