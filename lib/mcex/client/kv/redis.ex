defmodule Mcex.Client.Kv.Redis do
  @behaviour Mc.Behaviour.KvClient

  @impl true
  def get(pid, key) do
    case Redix.command(pid, ["GET", key]) do
      {:ok, nil} -> {:ok, ""}
      tuple -> tuple
    end
  end

  @impl true
  def set(pid, key, value) do
    Redix.command(pid, ["SET", key, value])
    {:ok, value}
  end

  @impl true
  def findk(pid, regex_string) do
    case Regex.compile(regex_string) do
      {:ok, regex} ->
        {:ok,
          keys(pid, "*")
          |> Enum.filter(fn key -> Regex.match?(regex, key) end)
          |> Enum.join("\n")
        }

      {:error, _} ->
        {:error, "bad regex"}
    end
  end

  @impl true
  def findv(pid, regex_string) do
    case Regex.compile(regex_string) do
      {:ok, regex} ->
        {:ok,
          keys(pid, "*")
          |> Enum.map(fn key -> {key, get(pid, key)} end)
          |> Enum.filter(fn {_key, {:ok, value}} -> Regex.match?(regex, value) end)
          |> Enum.map(fn {key, {:ok, _value}} -> key end)
          |> Enum.join("\n")
        }

      {:error, _} ->
        {:error, "bad regex"}
    end
  end

  defp keys(pid, pattern) do
    {:ok, list} = Redix.command(pid, ["KEYS", pattern])
    list
  end
end
