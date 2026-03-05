defmodule Mcex.Modifier.Trap do
  def m({:error, _}, args, _mappings) do
    {:ok, args}
  end

  def m({:ok, buffer}, _args, _mappings) do
    {:ok, buffer}
  end

  def m(buffer, _args, _mappings) do
    {:ok, buffer}
  end
end
