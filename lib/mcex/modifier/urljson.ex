defmodule Mcex.Modifier.Urljson do
  use Mc.Railway, [:modify]
  @user_agent "Mozilla/5.0 (Windows NT 6.1; rv:52.0) Gecko/20100101 Firefox/52.0"
  @get_options [recv_timeout: 5000]
  @post_options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 5000]

  def modify(buffer, _args) do
    map = request_map(buffer)

    case check(map) do
      :ok ->
        case method(map) do
          "get" ->
            url(map)
            |> HTTPoison.get(headers(map), @get_options)
            |> reply_for()

          "post" ->
            url(map)
            |> HTTPoison.post(body(map), headers(map), @post_options)
            |> reply_for()
        end

      bad_json_error ->
        bad_json_error
    end
  end

  def request_map(buffer) do
    {:ok, json_with_replacements} = Mc.Modifier.Buffer.modify("", buffer)
    Jason.decode!(json_with_replacements)
  end

  def check(_map) do
    :ok
  end

  def method(map) do
    Map.get(map, "method")
  end

  def url(map) do
    Map.get(map, "url")
  end

  def body(map) do
    Map.get(map, "body")
  end

  def headers(map) do
    Map.get(map, "headers")
    |> Enum.map(fn %{"name" => name, "value" => value} -> {name, value} end)
    |> List.insert_at(0, {"user-agent", @user_agent})
  end

  def reply_for(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "404 (not found)"}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
