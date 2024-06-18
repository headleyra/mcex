defmodule Mcex.Modifier.PadL do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    with \
      [width, padding] <- String.split(args),
      {:ok, width_int} when width_int > 0 <- Mc.String.to_int(width)
    do
      padding_uri = URI.decode(padding)
      {:ok, String.pad_leading(buffer, width_int, padding_uri)}
    else
      _error ->
        oops("parse error")
    end
  end
end
