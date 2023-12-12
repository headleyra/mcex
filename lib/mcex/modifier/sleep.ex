defmodule Mcex.Modifier.Sleep do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    case Mc.String.to_int(args) do
      {:ok, seconds} when seconds > 0 ->
        Process.sleep(seconds * 1_000)
        {:ok, buffer}

      _bad_seconds ->
        oops("bad positive integer")
    end
  end
end
