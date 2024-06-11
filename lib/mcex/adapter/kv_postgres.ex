defmodule Mcex.Adapter.KvPostgres do
  use Agent
  require Logger

  @behaviour Mc.Behaviour.KvAdapter
  @queue_target 200
  @queue_interval 4_000
  @cache_pid Module.concat(__MODULE__, Cache)
  @db_pid __MODULE__
  @db_table Application.compile_env(:mcex, :postgres_table)

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

    Agent.start_link(fn -> %{} end, name: @cache_pid)
  end

  @impl true
  def get(key) do
    with \
      {:ok, cached_value} <- cached_value(key)
    do
      {:ok, cached_value}
    else
      :cache_miss ->
        Logger.info("===== CACHE MISS: #{key}")

        case db_get(key) do
          {:ok, value} ->
            update_cache(key, value)
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
    update_cache(key, value)
    {:ok, value}
  end

  @impl true
  def findk(regex_str) do
    db_regex_search("key", regex_str)
  end

  @impl true
  def findv(regex_str) do
    db_regex_search("value", regex_str)
  end

  @impl true
  def delete(key) do
    case Postgrex.query(@db_pid, "DELETE FROM #{@db_table} WHERE key = $1", [key]) do
      {:ok, %Postgrex.Result{num_rows: num_rows}} ->
        clear_cache(key)
        {:ok, inspect(num_rows)}

      result ->
        tupleize_result(result)
    end
  end

  def findx(key_regx_str, value_regx_str) do
    db_regex("key ~ $1 AND value ~ $2", [key_regx_str, value_regx_str])
  end

  defp db_regex(where, vars) do
    case Postgrex.query(@db_pid, "SELECT key FROM #{@db_table} WHERE #{where}", vars) do
      {:ok, %Postgrex.Result{num_rows: row_count, rows: rows}} when row_count > 0 ->
        tupleize_rows(rows)

      result ->
        tupleize_regex_result(result)
    end
  end

  defp db_regex_search(key_or_value, regex_str) do
    case Postgrex.query(@db_pid, "SELECT key FROM #{@db_table} WHERE #{key_or_value} ~ $1", [regex_str]) do
      {:ok, %Postgrex.Result{num_rows: row_count, rows: rows}} when row_count > 0 ->
        tupleize_rows(rows)

      result ->
        tupleize_regex_result(result)
    end
  end

  defp tupleize_rows(rows) do
    {:ok,
      rows
      |> List.flatten()
      |> Enum.join("\n")
    }
  end

  defp tupleize_regex_result(result) do
    case tupleize_result(result) do
      {:error, :not_found} ->
        {:ok, ""}

      other ->
        other
    end
  end

  defp tupleize_result(result) do
    case result do
      {:ok, %Postgrex.Result{num_rows: 0}} ->
        {:error, :not_found}

      {:error, %Postgrex.Error{postgres: %{message: reason}}} ->
        {:error, reason}

      error ->
        {:error, inspect(error)}
    end
  end

  defp update_cache(key, value) do
    Agent.update(@cache_pid, fn map -> Map.put(map, key, value) end)
  end

  defp cached_value(key) do
    case Agent.get(@cache_pid, fn map -> Map.fetch(map, key) end) do
      {:ok, value} ->
        {:ok, value}

      :error ->
        :cache_miss
    end
  end

  defp db_get(key) do
    case Postgrex.query(@db_pid, "SELECT * FROM #{@db_table} WHERE key = $1", [key]) do
      {:ok, %Postgrex.Result{num_rows: 1, rows: [[_key, value]]}} ->
        {:ok, value}

      result ->
        tupleize_result(result)
    end
  end

  def cache, do: Agent.get(@cache_pid, fn map -> map end)

  def clear_cache(key) do
    Agent.update(@cache_pid, fn map -> Map.delete(map, key) end)
  end

  def create_table do
    Logger.info("===== CREATE TABLE")
    result = Postgrex.query!(@db_pid, "CREATE TABLE #{@db_table} (key VARCHAR(48) PRIMARY KEY, value TEXT)", [])
    Logger.info(result)
  end
end
