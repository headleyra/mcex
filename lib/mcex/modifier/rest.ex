defmodule Mcex.Modifier.Rest do
  use Mc.Modifier

  def modify(buffer, _args, _mappings) do
    with \
      [_ | rest] <- String.split(buffer, "\n")
    do
      result = Enum.join(rest, "\n")
      {:ok, result}
    else
      _ ->
        oops("no lines?")
    end
  end
end
