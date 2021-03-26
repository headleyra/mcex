defmodule Mcex.Modifier.Base64 do
  use Mc.Railway, [:modify]

  def modify(buffer, _args) do
    {:ok, Base.encode64(buffer)}
  end
end
