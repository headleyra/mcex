defmodule Mcex.Modifier.Rest do
  use Mc.Modifier

  def modify(buffer, _args, _mappings) do
    case String.split(buffer, "\n") do
      [_ | rest] ->
        result = Enum.join(rest, "\n")
        {:ok, result}

      _ ->
        oops("no lines")
    end
  end
end
