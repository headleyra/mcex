defmodule Mcex.Adapter.KvPostgresCache do
  use Agent
  require Logger

  @behaviour Mc.Behaviour.KvAdapter
  @queue_target 200
  @queue_interval 4_000
  @cache_pid Module.concat(__MODULE__, Cache)
  @db_pid __MODULE__
  @db_table Application.compile_env(:mcex, KvPostgresCache)[:db_table]

  def start_link(opts \\ []) do
    Postgrex.start_link(
      hostname: Keyword.fetch!(opts, :hostname),
      username: Keyword.fetch!(opts, :username),
      password: Keyword.fetch!(opts, :password),
      database: Keyword.fetch!(opts, :database),
      queue_target: @queue_target,
      queue_interval: @queue_interval,
      name: @db_pid
    )

    cache = Keyword.fetch!(opts, :cache)
    Agent.start_link(fn -> cache end, name: @cache_pid)
  end

  @impl true
  def get(key) do
    if Map.has_key?(cache(), key) do
      {:ok, Map.get(cache(), key)}
    else
      Logger.info("===== CACHE MISS: #{key}")

      case db_get(key) do
        {:ok, value} ->
          Agent.update(@cache_pid, fn cache -> Map.put(cache, key, value) end)
          {:ok, value}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  @impl true
  def set(key, value) do
    upsert = "ON CONFLICT(key) DO UPDATE SET key = $1, value = $2"
    Postgrex.query!(@db_pid, "INSERT INTO #{@db_table} (key, value) VALUES ($1, $2) #{upsert}", [key, value])
    Agent.update(@cache_pid, fn cache -> Map.put(cache, key, value) end)
    {:ok, value}
  end

  @impl true
  def findk(regex_str) do
    tupleize_regex_query("key", [regex_str])
  end

  @impl true
  def findv(regex_str) do
    tupleize_regex_query("value", [regex_str])
  end

  def cache, do: Agent.get(@cache_pid, &(&1))

  def clear_cache(key) do
    Agent.update(@cache_pid, fn cache -> Map.delete(cache, key) end)
  end

  def create_table do
    Logger.info("======= create table")
    result = Postgrex.query!(@db_pid, "CREATE TABLE #{@db_table} (key VARCHAR(32) PRIMARY KEY, value TEXT)", [])
    Logger.info(result)
  end

  def delete(key) do
    case Postgrex.query(@db_pid, "DELETE FROM #{@db_table} WHERE key = $1", [key]) do
      {:ok, %Postgrex.Result{num_rows: num_rows}} ->
        clear_cache(key)
        {:ok, num_rows}

      result ->
        tupleize_result(result)
    end
  end

  defp tupleize_regex_query(key_or_value, vars) do
    case Postgrex.query(@db_pid, "SELECT * FROM #{@db_table} WHERE #{key_or_value} ~ $1", vars) do
      {:ok, %Postgrex.Result{num_rows: row_count, rows: rows_list}} when row_count > 0 ->
        tupleize_rows_list(rows_list)

      result ->
        tupleize_result(result)
    end
  end

  defp tupleize_rows_list(rows_list) do
    {:ok,
      rows_list
      |> Enum.map(fn [key, _value] -> key end)
      |> Enum.join("\n")
    }
  end

  defp db_get(key) do
    case Postgrex.query(@db_pid, "SELECT * FROM #{@db_table} WHERE key = $1", [key]) do
      {:ok, %Postgrex.Result{num_rows: 1, rows: [[_key, value]]}} ->
        {:ok, value}

      result ->
        tupleize_result(result)
    end
  end

  defp tupleize_result(result) do
    case result do
      {:ok, %Postgrex.Result{num_rows: 0}} ->
        {:ok, ""}

      {:error, %Postgrex.Error{postgres: %{message: reason}}} ->
        {:error, reason}

      error ->
        {:error, inspect(error)}
    end
  end
end
