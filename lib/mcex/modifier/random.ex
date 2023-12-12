defmodule Mcex.Modifier.Random do
  use Mc.Modifier

  def modify(_buffer, args, _mappings) do
    case Mc.String.to_int(args) do
      {:ok, integer} when integer > 0 ->
        {:ok, "#{:rand.uniform(integer)}"}

      _bad_args ->
        oops("bad random limit")
    end
  end
end
