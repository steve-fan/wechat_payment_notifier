defmodule WechatPaymentNotifier do
  use Application

  @moduledoc """
  使用 Elixir 实现微信支付结果通知的功能。

  新建一个支付通知

  ```elixir
  callback_url = "http://localhost:3000/payment/callback/wechat"
  transaction_id = 12323419
  total_fee = 3000
  WorkerSupervisor.add_worker({"http://localhost:3000/", transaction_id, total_fee})
  ```

  支付通知成功的时候，停止通知。
  否则重新发送通知，直到成功为止， 重新发起通知的时间间隔定义在 Worker 中。
  """

  @doc """
  Start WechatPaymentNotifier
  """
  def start(_type, _args) do
    children = [WorkerSupervisor]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
