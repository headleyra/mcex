defmodule Mcex.Modifier.UriD do
  use Mc.Modifier

  def modify(buffer, _args, _mappings) do
    {:ok, URI.decode(buffer)}
  end
end
