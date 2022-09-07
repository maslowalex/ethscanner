defmodule EthereumScan.Transactions.Worker do
  use GenServer, restart: :transient

  require Logger

  alias EthereumScan.Transactions
  alias EthereumScan.Transactions.CheckConfirmations
  alias EthereumScan.Transactions.Transaction

  @pooling_interval Application.compile_env!(:ethereum_scan, :confirmations_pooling_interval)

  def start_link(%Transaction{status: :pending} = pending_transaction) do
    GenServer.start_link(__MODULE__, pending_transaction, name: via_tuple(pending_transaction))
  end

  def init(%Transaction{} = transaction) do
    Process.send_after(self(), :check_confirmations, @pooling_interval)

    {:ok, transaction}
  end

  def handle_info(:check_confirmations, %Transaction{} = transaction) do
    case CheckConfirmations.call(transaction) do
      {:ok, confirmations} ->
        transaction
        |> Transactions.update_transaction(%{confirmations: confirmations})
        |> handle_update_transaction()

      {:error, :transaction_failed} ->
        transaction
        |> Transactions.update_transaction(%{status: :failed})
        |> handle_update_transaction()

      {:error, :not_pending_status} ->
        {:stop, :normal, transaction}

      {:error, reason} ->
        Logger.error(reason)

        Process.send_after(self(), :check_confirmations, @pooling_interval)

        {:noreply, transaction}
    end
  end

  defp handle_update_transaction({:error, %Ecto.Changeset{data: transaction, errors: errors}}) do
    Logger.error("Error during updating the transaction #{transaction.tx_hash}, #{inspect(errors)}")

    {:stop, :error, transaction}
  end

  defp handle_update_transaction({:ok, %Transaction{status: :pending} = transaction}) do
    Process.send_after(self(), :check_confirmations, @pooling_interval)

    {:noreply, transaction}
  end

  defp handle_update_transaction({:ok, %Transaction{tx_hash: tx_hash, status: status} = transaction}) do
    Logger.info("Transaction #{tx_hash} is #{status}")

    :ok = EthereumScan.Transactions.PubSub.broadcast(transaction)

    {:stop, :normal, transaction}
  end

  defp via_tuple(%Transaction{tx_hash: tx_hash}), do: {:via, Registry, {EthereumScan.Transaction.WorkerRegistry, tx_hash}}
end
