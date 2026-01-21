defmodule Mcex.Adapter.KvRam do
  use Agent
  @behaviour Mc.Behaviour.KvAdapter

  def start_link(map: map) do
    Agent.start_link(fn -> map end, name: __MODULE__)
  end

  @impl true
  def set(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
    {:ok, value}
  end

  @impl true
  def get(key) do
    case Agent.get(__MODULE__, &Map.fetch(&1, key)) do
      {:ok, value} ->
        {:ok, value}

      :error ->
        {:error, :not_found}
    end
  end

  @impl true
  def findk(regex_str) do
    Agent.get(__MODULE__, &finder(&1, regex_str, :key))
  end

  @impl true
  def findv(regex_str) do
    Agent.get(__MODULE__, &finder(&1, regex_str, :value))
  end

  def findx(key_regx_str, value_regx_str) do
    with \
      {:regex, {:ok, kregx}} <- {:regex, Regex.compile(key_regx_str)},
      {:ok, keys} <- Agent.get(__MODULE__, &finder(&1, value_regx_str, :value))
    do
      {:ok,
        keys
        |> String.split("\n")
        |> Enum.filter(fn key -> String.match?(key, kregx) end)
        |> Enum.join("\n")
      }
    else
      {:regex, _} ->
        {:error, "bad regex"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def delete(key) do
    case get(key) do
      {:ok, _value} ->
        Agent.update(__MODULE__, fn map -> Map.delete(map, key) end)
        1

      {:error, :not_found} ->
        0
    end
  end

  defp finder(map, regx_str, by) do
    case Regex.compile(regx_str, "sm") do
      {:ok, regex} ->
        filter(map, regex, by)

      {:error, _} ->
        {:error, "bad regex"}
    end
  end

  defp filter(map, regex, :value), do: filter(map, fn {_key, value} -> Regex.match?(regex, value) end)
  defp filter(map, regex, :key), do: filter(map, fn {key, _value} -> Regex.match?(regex, key) end)

  defp filter(map, func) do
    {:ok,
      map
      |> Enum.to_list()
      |> Enum.filter(func)
      |> Enum.map_join("\n", fn {key, _value} -> key end)
    }
  end
end
