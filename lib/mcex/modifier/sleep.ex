defmodule Mcex.Modifier.Sleep do
  use Mc.Railway, [:modify]

  def modify(buffer, args) do
    case Mc.String.to_int(args) do
      {:ok, seconds} when seconds > 0 ->
        Process.sleep(seconds * 1_000)
        {:ok, buffer}

      _bad_seconds ->
        oops(:modify, "bad positive integer")
    end
  end
end
