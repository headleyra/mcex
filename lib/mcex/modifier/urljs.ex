defmodule Mcex.Modifier.Urljs do
  use Mc.Railway, [:modify]

  def modify(_buffer, args) do
    {:ok, api_key} = Mc.modify("", "get api_key")

    case String.split(args) do
      [url, wait] ->
        Mc.Client.Http.post(endpoint(), [url: url, wait: wait, api_key: api_key])

      [url] ->
        Mc.Client.Http.post(endpoint(), [url: url, api_key: api_key])

      [] ->
        usage(:modify, "<url> [<wait seconds>]")
    end
  end

  def endpoint do
    System.get_env("URLJ_ENDPOINT")
  end
end
