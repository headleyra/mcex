defmodule Mcex.Modifier.Uniq do
  use Mc.Modifier

  def modify(buffer, _args, _mappings) do
    {:ok,
      String.split(buffer, "\n")
      |> Enum.uniq()
      |> Enum.join("\n")
    }
  end
end
