defmodule EthereumScanWeb.TransactionLive.Index do
  use EthereumScanWeb, :live_view

  alias EthereumScan.Transactions
  alias EthereumScan.Transactions.Transaction
  alias EthereumScan.Transactions.PubSub

  @impl true
  def mount(_params, _session, socket) do
    :ok = PubSub.subscribe()

    {:ok, assign(socket, :transactions, list_transactions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:transaction, %Transaction{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Transactions")
    |> assign(:transaction, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Transactions.get_transaction!(id)
    {:ok, _} = Transactions.delete_transaction(transaction)

    {:noreply, assign(socket, :transactions, list_transactions())}
  end

  def handle_info(%Transaction{} = updated_transaction, socket) do
    updated_transactions = do_update_transactions(updated_transaction, socket.assigns.transactions)

    {:noreply, assign(socket, :transactions, updated_transactions)}
  end

  defp do_update_transactions(%Transaction{tx_hash: incoming_tx_hash} = incoming_transaction, socket_transactions) do
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
