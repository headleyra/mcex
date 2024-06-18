defmodule Mcex.Modifier.TimeU do
  use Mc.Modifier

  def modify(_buffer, _args, _mappings) do
    result =
      DateTime.utc_now()
      |> DateTime.to_unix() 
      |> to_string()

    {:ok, result}
  end
end
