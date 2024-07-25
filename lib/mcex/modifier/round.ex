defmodule Mcex.Modifier.Round do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    with \
      trim_buffer = String.trim(buffer),
      {:ok, number} <- Mc.String.to_num(trim_buffer),
      {:ok, precision} when precision in 0..15 <- Mc.String.to_int(args)
    do
      float = number_to_float(number)
      result = Float.round(float, precision)

      {:ok, "#{result}"}
    else
      _error ->
        oops("parse error")
    end
  end

  defp number_to_float(n) do
    if is_integer(n), do: n * 1.0, else: n
  end
end
