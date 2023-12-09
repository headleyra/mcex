defmodule Mcex.Modifier.Trap do
  def modify({:error, _}, args, _mappings) do
    {:ok, args}
  end

  def modify({:ok, buffer}, _args, _mappings) do
    {:ok, buffer}
  end

  def modify(buffer, _args, _mappings) do
    {:ok, buffer}
  end
end
