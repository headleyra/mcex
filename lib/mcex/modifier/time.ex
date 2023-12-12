defmodule Mcex.Modifier.Time do
  use Mc.Modifier

  def modify(_buffer, _args, _mappings) do
    result =
      Time.utc_now()
      |> Time.to_string()

    {:ok, result}
  end
end
