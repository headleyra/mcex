defmodule Mcex.Modifier.Font do
  use Mc.Railway, [:modify]

  def modify(_buffer, ""), do: oops(:modify, "no font specified")

  def modify(buffer, args) do
    Mc.Client.Http.post("#{endpoint()}/#{args}.html", [text: buffer])
    |> Mc.Modifier.Hselc.modify("pre")
  end

  def endpoint do
    System.get_env("FONT_ENDPOINT")
  end
end
