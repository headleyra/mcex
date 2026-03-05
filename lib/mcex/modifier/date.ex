defmodule Mcex.Modifier.Date do
  use Mc.Modifier

  def m(_buffer, _args, _mappings) do
    {:ok,
      Date.utc_today()
      |> Date.to_iso8601()
    }
  end
end
