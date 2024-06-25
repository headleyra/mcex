defmodule Mcex do
  @glob "*.setm.txt"
  @setm_modifier "setm"

  def setm(dir, mappings) do
    Path.join(dir, @glob)
    |> Path.wildcard()
    |> Enum.map(fn file -> {Path.basename(file), File.read!(file)} end)
    |> Enum.map(fn {file, setm} -> {file, Mc.modify(setm, @setm_modifier, mappings)} end)
    |> Enum.map(fn file_result -> summarize(file_result) end)
  end

  def summarize({file, {:ok, _}}) do
    {file, :ok}
  end

  def summarize({file, {:error, _}}) do
    {file, :error}
  end
end
