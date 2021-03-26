defmodule Mcex.Modifier.Time do
  use Mc.Railway, [:modify]

  def modify(_buffer, _args) do
    result =
      Time.utc_now()
      |> Time.to_string()

    {:ok, result}
  end
end
