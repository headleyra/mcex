defmodule Mcex.Modifier.Redis do
  use Mc.Railway, [:set, :get, :appendk, :prependk, :find, :findv]
  @behaviour Mc.Behaviour.KvServer

  @impl true
  def set(buffer, args) do
    Redix.command(:redix, ["SET", args, buffer])
    {:ok, buffer}
  end

  @impl true
  def get(_buffer, args) do
    case Redix.command(:redix, ["GET", args]) do
      {:ok, nil} -> {:ok, ""}
      tuple -> tuple
    end
  end

  @impl true
  def appendk(buffer, args) do
    {:ok, data} = get("", args)
    result = buffer <> data
    {:ok, result}
  end

  @impl true
  def prependk(buffer, args) do
    {:ok, data} = get("", args)
    result = data <> buffer
    {:ok, result}
  end

  @impl true
  def find(_buffer, args) do
    case Regex.compile(args) do
      {:ok, regex} ->
        result =
          allkeys()
          |> Enum.filter(fn key -> Regex.match?(regex, key) end)
          |> Enum.join("\n")

        {:ok, result}

      {:error, _} ->
        oops("bad regex", :find)
    end
  end

  @impl true
  def findv(_buffer, args) do
    case Regex.compile(args) do
      {:ok, regex} ->
        result =
          allkeys()
          |> Enum.map(fn key -> {key, get("", key)} end)
          |> Enum.filter(fn {_key, {:ok, value}} -> Regex.match?(regex, value) end)
          |> Enum.map(fn {key, {:ok, _value}} -> key end)
          |> Enum.join("\n")

        {:ok, result}

      {:error, _} ->
        oops("bad regex", :findv)
    end
  end

  defp allkeys do
    {:ok, result_list} = Redix.command(:redix, ["KEYS", "*"])
    result_list
  end
end
