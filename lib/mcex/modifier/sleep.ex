defmodule Mcex.Modifier.Sleep do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    case Mc.String.to_int(args) do
      {:ok, ms} when ms > 0 ->
        Process.sleep(ms)
        {:ok, buffer}

      _bad_seconds ->
        oops("bad positive integer")
    end
  end
end
