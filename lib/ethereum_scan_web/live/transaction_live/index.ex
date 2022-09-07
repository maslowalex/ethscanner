defmodule EthereumScanWeb.TransactionLive.Index do
  use EthereumScanWeb, :live_view

  alias EthereumScan.Transactions
  alias EthereumScan.Transactions.Transaction
  alias EthereumScan.Transactions.PubSub

  @impl true
  def mount(_params, _session, socket) do
    :ok = PubSub.subscribe()

    transaction = %Transaction{}

    socket =
      socket
      |> assign(:transaction, transaction)
      |> assign(:changeset, Transactions.change_transaction(transaction))
      |> assign(:transactions, list_transactions())

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Transactions.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    case Transactions.create_transaction(transaction_params) do
      {:ok, transaction} ->
        Transactions.start_check_confirmations_worker(transaction)

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Transaction created successfully. Scheduled check confirmations worker in a background..."
         )
         |> push_redirect(to: "/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info(%Transaction{} = updated_transaction, socket) do
    updated_transactions =
      do_update_transactions(updated_transaction, socket.assigns.transactions)

    {:noreply, assign(socket, :transactions, updated_transactions)}
  end

  defp do_update_transactions(
         %Transaction{tx_hash: incoming_tx_hash} = incoming_transaction,
         socket_transactions
       ) do
    socket_transactions
    |> Enum.reduce([], fn
      %Transaction{tx_hash: ^incoming_tx_hash}, acc ->
        [incoming_transaction | acc]

      transaction, acc ->
        [transaction | acc]
    end)
    |> Enum.reverse()
  end

  defp list_transactions do
    Transactions.list_transactions()
  end
end
