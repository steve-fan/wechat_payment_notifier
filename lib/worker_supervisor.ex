defmodule WorkerSupervisor do
  use DynamicSupervisor

  ## public API

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_worker({callback_url, txid, fee} = payload) do
    child_spec = {Worker, payload}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def stop_worker(worker_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, worker_pid)
  end

  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_children() do
    DynamicSupervisor.count_children(__MODULE__)
  end

  ## callbacks

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
