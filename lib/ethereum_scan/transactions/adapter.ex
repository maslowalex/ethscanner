defmodule EthereumScan.Transactions.Adapter do
  @behaviour EthereumScan.HttpAdapter

  @impl true
  def get(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Transaction was not found"}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "API respond with status_code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
