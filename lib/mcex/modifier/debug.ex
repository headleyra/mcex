defmodule Go.Modifier.Debug do
  use Mc.Modifier

  def modify(buffer, args, _mappings) do
    case String.split(args, " ", parts: 2) do
      ["i", title] ->
        outp(title, inspect(buffer))

      [blob, title] ->
        outp("#{blob} #{title}", buffer)

      [title] ->
        outp(title, buffer)
    end

    {:ok, buffer}
  end

  defp outp(title, string) do
    IO.puts("\n#{title}")
    IO.puts(string)
  end
end
