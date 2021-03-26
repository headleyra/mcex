defmodule Mcex.Modifier.Date do
  use Mc.Railway, [:modify]

  def modify(_buffer, _args) do
    result =
      Date.utc_today()
      |> Date.to_iso8601()

    {:ok, result}
  end
end
