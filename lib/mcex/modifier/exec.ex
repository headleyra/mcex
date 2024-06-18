defmodule Mcex.Modifier.Exec do
  use Mc.Modifier

  def modify(buffer, args, mappings) do
    case Mc.Modifier.Buffer.modify(buffer, args, mappings) do
      {:ok, script} ->
        Mc.modify(buffer, script, mappings)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
