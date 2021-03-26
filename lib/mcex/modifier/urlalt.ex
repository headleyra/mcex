defmodule Mcex.Modifier.Urlalt do
  use Mc.Railway, [:modify]
  use Tesla
  # @user_agent "Mozilla/5.0 (Windows NT 6.1; rv:52.0) Gecko/20100101 Firefox/52.0"
  # plug Tesla.Adapter.Ibrowse
  # plug Tesla.Middleware.Headers, [{:"USER_AGENT", @user_agent}]

  def modify(_buffer, args) do
    case get(args) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: 404}} ->
        {:error, "#{args} (404)"}

      {:ok, %{body: body}} ->
        {:error, body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
