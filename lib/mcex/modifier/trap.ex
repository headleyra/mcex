defmodule Mcex.Modifier.Trap do
  def modify({:error, _}, args) do
    {:ok, args}
  end

  def modify({:ok, buffer}, _args) do
    {:ok, buffer}
  end

  def modify(buffer, _args) do
    {:ok, buffer}
  end
end
