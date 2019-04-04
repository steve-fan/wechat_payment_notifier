# WechatPaymentNotifier

在写 side project 时候，使用了微信支付功能，其中有一个环节就是后端会接收到微信的支付结果通知。微信的开发文档中说明

>后台通知交互时，如果微信收到商户的应答不符合规范或超时，微信会判定本次通知失败，重新发送通知，直到成功为止（在通知一直不成功的情况下，微信总共会发起10次通知，通知频率为15s/15s/30s/3m/10m/20m/30m/30m/30m/60m/3h/3h/3h/6h/6h - 总计 24h4m），但微信不保证通知最终一定能成功。

好奇微信后台是怎么去实现这样功能的。
学完 Elixir OTP 的相关的内容之后，结合这个场景，顺手实现了这个功能。

1. 对于每一个支付结果，开一个 process（GenServer worker）
2. 开一个 process （Supervisor） 去管理这些 worker

由于 process 很轻量，所以资源消耗非常小，而且每个 process 都是隔离的，各个通知结果之间互不影响，完美！

## 体验

```shell
git clone https://github.com/steve-fan/wechat_payment_notifier.git
mix deps.get
iex -S mix
```

```elixir
# 你的回调的 URL，接受 POST 请求，只有返回 200 状态的时候表示回调成功。
# 其他状态均表示失败，会不断收到回调请求。
# 请求的内容添加的 signature，如果只是简单的测试，直接返回 200 即可。
callback_url = "http://localhost:4000/payment/callback/wechat"
transaction_id = 12314211
total_fee = 1200
WorkerSupervisor.add_worker({callback_url, transaction_id, total_fee})
```
