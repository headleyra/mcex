defmodule Mcex.Modifier.Sleep do
  use Mc.Railway, [:modify]

  def modify(buffer, args) do
    case Mc.Util.Math.str2int(args) do
      {:ok, seconds} when seconds > 0 ->
        Process.sleep(seconds * 1_000)
        {:ok, buffer}

      _bad_seconds ->
        usage(:modify, "<positive integer>")
    end
  end
end
