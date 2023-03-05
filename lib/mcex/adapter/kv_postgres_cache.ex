defmodule Mcex.Adapter.KvPostgresCache do
  use Agent
  require Logger

  @behaviour Mc.Behaviour.KvAdapter
  @queue_target 200
  @queue_interval 4_000
  @db __MODULE__
  @me Module.concat(__MODULE__, Me)

  def start_link(opts \\ []) do
    Postgrex.start_link(
      hostname: Keyword.fetch!(opts, :hostname),
      username: Keyword.fetch!(opts, :username),
      password: Keyword.fetch!(opts, :password),
      database: Keyword.fetch!(opts, :database),
      queue_target: @queue_target,
      queue_interval: @queue_interval,
      name: @db
    )

    cache = Keyword.fetch!(opts, :cache)
    table = Keyword.fetch!(opts, :table)
    Agent.start_link(fn -> %{cache: cache, table: table} end, name: @me)
  end

  @impl true
  def get(key) do
    if Map.has_key?(cache(), key) do
      {:ok, Map.get(cache(), key)}
    else
      Logger.info("===== CACHE MISS: #{key}")

      case db_get(key) do
        {:ok, value} ->
          Agent.update(@me, fn x -> update_cache(x, key, value) end)
          {:ok, value}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  @impl true
  def set(key, value) do
    upsert = "ON CONFLICT(key) DO UPDATE SET key = $1, value = $2"
    Postgrex.query!(@db, "INSERT INTO #{table()} (key, value) VALUES ($1, $2) #{upsert}", [key, value])
    Agent.update(@me, fn state -> update_cache(state, key, value) end)
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

  def create_table do
    Logger.info("create table =======")
    result = Postgrex.query!(@db, "CREATE TABLE #{table()} (key VARCHAR(32) PRIMARY KEY, value TEXT)", [])
    Logger.info(result)
  end

  def delete(key) do
    case Postgrex.query(@db, "DELETE FROM #{table()} WHERE key = $1", [key]) do
      {:ok, %Postgrex.Result{num_rows: num_rows}} ->
        {:ok, num_rows}

      result ->
        tupleize_result(result)
    end
  end

  def get_cache do
    {:ok,
      Map.keys(cache())
      |> Enum.join("\n")
    }
  end

  defp tupleize_regex_query(key_or_value, vars) do
    case Postgrex.query(@db, "SELECT * FROM #{table()} WHERE #{key_or_value} ~ $1", vars) do
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
    case Postgrex.query(@db, "SELECT * FROM #{table()} WHERE key = $1", [key]) do
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

  defp me, do: Agent.get(@me, &(&1))
  defp table, do: me().table
  defp cache, do: me().cache

  defp update_cache(%{cache: cache} = state, key, new_value) do
    {_, new_cache} = Map.get_and_update(cache, key, fn current_value -> {current_value, new_value} end)
    Map.put(state, :cache, new_cache)
  end
end
