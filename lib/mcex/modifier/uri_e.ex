defmodule Mcex.Modifier.UriE do
  use Mc.Modifier

  def modify(buffer, _args, _mappings) do
    {:ok, URI.encode(buffer)}
  end
end
