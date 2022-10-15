defmodule Mcex.Client.Kv.Redis do
  @behaviour Mc.Behaviour.KvClient

  @impl true
  def get(key) do
    case Redix.command(:redix, ["GET", key]) do
      {:ok, nil} -> {:ok, ""}
      tuple -> tuple
    end
  end

  @impl true
  def set(key, value) do
    Redix.command(:redix, ["SET", key, value])
    {:ok, value}
  end

  @impl true
  def findk(pattern) do
    {:ok,
      keys(pattern)
      |> Enum.join("\n")
    }
  end

  @impl true
  def findv(regex_str) do
    case Regex.compile(regex_str) do
      {:ok, regex} ->
        {:ok,
          keys("*")
          |> Enum.map(fn key -> {key, get(key)} end)
          |> Enum.filter(fn {_key, {:ok, value}} -> Regex.match?(regex, value) end)
          |> Enum.map(fn {key, {:ok, _value}} -> key end)
          |> Enum.join("\n")
        }

      {:error, _} ->
        {:error, "bad regex"}
    end
  end

  defp keys(pattern) do
    {:ok, list} = Redix.command(:redix, ["KEYS", pattern])
    list
  end
end
