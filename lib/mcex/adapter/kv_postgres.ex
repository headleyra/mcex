defmodule Mcex.Adapter.KvPostgres do
  use Agent
  require Logger

  @behaviour Mc.Behaviour.KvAdapter
  @db_pid __MODULE__
  @db_table "kvs"

  def start_link(opts \\ []) do
    Postgrex.start_link(
      hostname: Keyword.fetch!(opts, :hostname),
      username: Keyword.fetch!(opts, :username),
      password: Keyword.fetch!(opts, :password),
      database: Keyword.fetch!(opts, :database),
      queue_target: Keyword.fetch!(opts, :queue_target),
      queue_interval: Keyword.fetch!(opts, :queue_interval),
      name: @db_pid
    )
  end

  @impl true
  def get(key) do
    get_db(key)
  end

  @impl true
  def set(key, value) do
    set_db(key, value)
  end

  @impl true
  def findk(regex_str) do
    search_db("key ~ $1", [regex_str])
  end

  @impl true
  def findv(regex_str) do
    search_db("value ~ $1", [regex_str])
  end

  @impl true
  def delete(key) do
    delete_db(key)
  end

  def findx(key_regx_str, value_regx_str) do
    search_db("key ~ $1 AND value ~ $2", [key_regx_str, value_regx_str])
  end

  def create_table do
    Logger.info("===== CREATE TABLE")
    tsql = "CREATE TABLE IF NOT EXISTS #{@db_table} (key VARCHAR(48) PRIMARY KEY, value TEXT)"
    isql = "CREATE UNIQUE INDEX IF NOT EXISTS idx_key ON kvs (key)"
    Postgrex.query!(@db_pid, tsql, [])
    Postgrex.query!(@db_pid, isql, [])
  end

  defp get_db(key) do
    case Postgrex.query(@db_pid, "SELECT * FROM #{@db_table} WHERE key = $1", [key]) do
      {:ok, %Postgrex.Result{num_rows: 1, rows: [[_key, value]]}} ->
        {:ok, value}

      result ->
        tupleize(result)
    end
  end

  defp set_db(key, value) do
    upsert = "ON CONFLICT(key) DO UPDATE SET key = $1, value = $2"
    Postgrex.query!(@db_pid, "INSERT INTO #{@db_table} (key, value) VALUES ($1, $2) #{upsert}", [key, value])
    {:ok, value}
  end

  defp search_db(where, vars) do
    case Postgrex.query(@db_pid, "SELECT key FROM #{@db_table} WHERE #{where}", vars) do
      {:ok, %Postgrex.Result{num_rows: row_count, rows: rows}} when row_count > 0 ->
        stringize(rows)

      result ->
        search_tupleize(result)
    end
  end

  defp delete_db(key) do
    case Postgrex.query(@db_pid, "DELETE FROM #{@db_table} WHERE key = $1", [key]) do
      {:ok, %Postgrex.Result{num_rows: num_rows}} ->
        {:ok, inspect(num_rows)}

      result ->
        tupleize(result)
    end
  end

  defp stringize(rows) do
    {:ok,
      rows
      |> List.flatten()
      |> Enum.join("\n")
    }
  end

  defp search_tupleize(result) do
    case tupleize(result) do
      {:error, :not_found} ->
        {:ok, ""}

      other ->
        other
    end
  end

  defp tupleize(result) do
    case result do
      {:ok, %Postgrex.Result{num_rows: 0}} ->
        {:error, :not_found}

      {:error, %Postgrex.Error{postgres: %{message: reason}}} ->
        {:error, reason}

      error ->
        {:error, inspect(error)}
    end
  end
end
