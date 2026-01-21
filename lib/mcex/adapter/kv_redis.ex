defmodule Mcex.Adapter.KvRedis do
  @behaviour Mc.Behaviour.KvAdapter

  def start_link(redis_uri: redis_uri) do
    Redix.start_link(redis_uri, name: __MODULE__)
  end

  @impl true
  def get(key) do
    case Redix.command(__MODULE__, ["GET", key]) do
      {:ok, nil} -> {:ok, ""}
      tuple -> tuple
    end
  end

  @impl true
  def set(key, value) do
    Redix.command(__MODULE__, ["SET", key, value])
    {:ok, value}
  end

  @impl true
  def findk(regex_string) do
    case Regex.compile(regex_string) do
      {:ok, regex} ->
        {:ok,
          keys("*")
          |> Enum.filter(fn key -> Regex.match?(regex, key) end)
          |> Enum.join("\n")
        }

      {:error, _} ->
        {:error, "bad regex"}
    end
  end

  @impl true
  def findv(regex_string) do
    case Regex.compile(regex_string) do
      {:ok, regex} ->
        {:ok,
          keys("*")
          |> Enum.map(fn key -> {key, get(key)} end)
          |> Enum.filter(fn {_key, {:ok, value}} -> Regex.match?(regex, value) end)
          |> Enum.map_join("\n", fn {key, {:ok, _value}} -> key end)
        }

      {:error, _} ->
        {:error, "bad regex"}
    end
  end

  @impl true
  def delete(_key) do
    {:error, "not yet implemeted"}
  end

  defp keys(pattern) do
    {:ok, list} = Redix.command(__MODULE__, ["KEYS", pattern])
    list
  end
end
