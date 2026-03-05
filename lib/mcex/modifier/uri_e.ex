defmodule Mcex.Modifier.UriE do
  use Mc.Modifier

  def m(buffer, _args, _mappings) do
    {:ok, URI.encode(buffer)}
  end
end
