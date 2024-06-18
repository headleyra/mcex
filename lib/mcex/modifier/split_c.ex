defmodule Mcex.Modifier.SplitC do
  use Mc.Modifier

  def modify(buffer, _args, _mappings) do
    {:ok,
      String.graphemes(buffer)
      |> Enum.join("\n")
    }
  end
end
