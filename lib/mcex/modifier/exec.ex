defmodule Mcex.Modifier.Exec do
  use Mc.Modifier

  def m(buffer, args, mappings) do
    case Mc.Modifier.Buffer.m(buffer, args, mappings) do
      {:ok, script} ->
        Mc.m(buffer, script, mappings)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
