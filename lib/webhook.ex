defmodule Webhook do
  @alphabet ~c(0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz)
  @headers [{"Content-Type", "application/json"}]

  def run(callback_url, {txid, fee}) do
    # 平台分配到 app_id 和 app_secret
    app_id = "DSM7waT2LvYVHHHTN"
    app_secret = "ecHXxtPfHHlOqCRA0"

    body = %{
      app_id: app_id,
      txid: txid,
      fee: fee,
      nonce: nonce(),
      timestamp: timestamp()
    }

    signature = sign(body, app_secret)
    body = Map.put(body, :sign, signature) |> Jason.encode!()

    case HTTPoison.post(callback_url, body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def timestamp() do
    :os.system_time(:second) |> Integer.to_string()
  end

  def nonce() do
    1..32
    |> Enum.map(fn _ -> Enum.random(@alphabet) end)
    |> String.Chars.to_string()
  end

  def sign(params, app_secret) do
    query =
      params
      |> Enum.drop_while(&(to_string(elem(&1, 1)) === ""))
      |> Enum.sort_by(&elem(&1, 0), &</2)
      |> Enum.map(&"#{elem(&1, 0)}=#{elem(&1, 1)}")
      |> Enum.join("&")

    query = "#{query}&key=#{app_secret}"
    :crypto.hash(:md5, query) |> Base.encode16(case: :upper)
  end
end
