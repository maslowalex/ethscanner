defmodule EthereumScan.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EthereumScan.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        tx_hash: "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"
      })
      |> EthereumScan.Transactions.create_transaction()

    transaction
  end
end
