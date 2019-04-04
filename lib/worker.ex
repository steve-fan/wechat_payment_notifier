defmodule Worker do
  use GenServer

  require Logger

  # 通知一直不成功的情况下，
  # 通知频率为 2s/5s/15s/15s/30s/3m/10m/20m/30m/30m/30m/60m/3h/3h/3h/6h/6h
  @durations [
    2_000,
    5_000,
    15_000,
    15_000,
    30_000,
    180_000,
    600_000,
    1_200_000,
    1_800_000,
    1_800_000,
    1_800_000,
    3_600_000,
    10_800_000,
    10_800_000,
    10_800_000,
    21_600_000,
    21_600_000
  ]

  ## public API

  def start_link({callback_url, txid, fee} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  def notify(pid) do
    GenServer.cast(pid, :notify)
  end

  def stop(worker) do
    GenServer.cast(worker, :stop)
  end

  ## callbacks

  def init(state) do
    notify(self())
    {:ok, Tuple.append(state, 0)}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_cast(:notify, {callback_url, txid, fee, count} = state) do
    _notify(state)
  end

  def handle_info(:notify_again, {callback_url, txid, fee, count} = state) do
    _notify(state)
  end

  defp _notify({callback_url, txid, fee, count} = state) do
    payload = {txid, fee}

    case _request(callback_url, payload) do
      :ok ->
        {:stop, :normal, {callback_url, txid, fee, count + 1}}

      {:error, _reason} ->
        if count < length(@durations) do
          duration = Enum.at(@durations, count)

          Logger.warn("#{txid}:#{count} failed, try again after #{duration / 1_000} seconds")

          Process.send_after(self(), :notify_again, duration)
          {:noreply, {callback_url, txid, fee, count + 1}}
        else
          Logger.error("#{txid} failed after #{count} tries!")
          {:stop, :normal, {callback_url, txid, fee, count}}
        end
    end
  end

  defp _request(callback_url, payload) do
    Webhook.run(callback_url, payload)
  end
end
