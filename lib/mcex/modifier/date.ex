defmodule Mcex.Modifier.Date do
  use Mc.Railway, [:modify]

  def modify(_buffer, _args, _mappings) do
    {:ok,
      Date.utc_today()
      |> Date.to_iso8601()
    }
  end
end
