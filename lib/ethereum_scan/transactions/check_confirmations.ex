defmodule EthereumScan.Transactions.CheckConfirmations do
  @moduledoc """
  Holds the logic behind collecting confirmations data from blockcypher API
  """

  @transactions_info_url "https://api.blockcypher.com/v1/eth/main/txs/"

  alias EthereumScan.Transactions.Adapter
  alias EthereumScan.Transactions.Transaction

  def call(%Transaction{status: :pending, tx_hash: tx_hash} = pending_transaction) do
    with {:ok, response_body} <- get_transaction_info(tx_hash),
         {:ok, %{"confirmations" => confirmations} = map}
         when not is_map_key(map, "execution_error") <-
           Jason.decode(response_body) do
      {:ok, confirmations}
    else
      {:ok, %{"execution_error" => execution_error}} when not is_nil(execution_error) ->
        {:error, :transaction_failed}

      {:ok, map} when not is_map_key(map, "confirmations") ->
        {:error, "Key 'confirmations' wasn't found in response"}

      error ->
        error
    end
  end

  def call(%Transaction{}), do: {:error, :not_pending_status}

  defp get_transaction_info(tx_hash), do: adapter().get(@transactions_info_url <> tx_hash)

  defp adapter(), do: Application.fetch_env!(:ethereum_scan, :http_adapter)
end
