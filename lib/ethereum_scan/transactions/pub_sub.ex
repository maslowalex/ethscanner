defmodule EthereumScan.Transactions.PubSub do
  @topic "transactions_updates"

  alias EthereumScan.Transactions.Transaction

  def subscribe do
    Phoenix.PubSub.subscribe(EthereumScan.PubSub, @topic)
  end

  def broadcast(%Transaction{} = transaction) do
    Phoenix.PubSub.broadcast(EthereumScan.PubSub, @topic, transaction)
  end
end
