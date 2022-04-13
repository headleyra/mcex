defmodule Mcex.Modifier.Random do
  use Mc.Railway, [:modify]

  def modify(_buffer, args) do
    case Mc.Math.str2int(args) do
      {:ok, integer} when integer > 0 ->
        {:ok, "#{:rand.uniform(integer)}"}

      _bad_args ->
        usage(:modify, "<positive integer>")
    end
  end
end
