defmodule Mcex.Modifier.Urljson do
  use Mc.Railway, [:modify]
  @user_agent "Mozilla/5.0 (Windows NT 6.1; rv:52.0) Gecko/20100101 Firefox/52.0"
  @get_options [recv_timeout: 10_000]
  @post_options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 10_000]

  def modify(buffer, _args) do
    case Jason.decode(buffer) do
      {:ok, map} ->
        case method_from(map) do
          "get" ->
            url_from(map)
            |> HTTPoison.get(headers_from(map), @get_options)
            |> reply_for()

          "post" ->
            url_from(map)
            |> HTTPoison.post(body_from(map), headers_from(map), @post_options)
            |> reply_for()

          _bad_method ->
            oops(:modify, "bad method")
        end

      {:error, _reason} ->
        oops(:modify, "bad JSON")
    end
  end

  def request_map(buffer) do
    Jason.decode!(buffer)
  end

  def method_from(map) do
    Map.get(map, "method")
  end

  def url_from(map) do
    Map.get(map, "url")
  end

  def body_from(map) do
    Map.get(map, "body")
  end

  def headers_from(map) do
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
        oops(:reply_for, "404 (not found)")

      {:ok, %HTTPoison.Response{body: body}} ->
        oops(:reply_for, body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        oops(:reply_for, inspect(reason))
    end
  end
end
