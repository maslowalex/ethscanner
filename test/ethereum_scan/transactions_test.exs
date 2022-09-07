defmodule EthereumScan.TransactionsTest do
  use EthereumScan.DataCase, async: true

  alias EthereumScan.Transactions

  describe "transactions" do
    alias EthereumScan.Transactions.Transaction

    import EthereumScan.TransactionsFixtures

    @invalid_attrs %{confirmations: nil, status: nil, tx_hash: "not_a_tx_hash"}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Transactions.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{
        tx_hash: "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.confirmations == 0
      assert transaction.status == :pending

      assert transaction.tx_hash ==
               "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      update_attrs = %{confirmations: 43, tx_hash: "some updated tx_hash"}

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.confirmations == 43
      assert transaction.status == :confirmed
      assert transaction.tx_hash != "some updated tx_hash"
    end

    test "update_transaction/2 to failed status" do
      transaction = transaction_fixture()

      assert {:ok, %Transaction{status: :failed}} =
               Transactions.update_transaction(transaction, %{status: :failed})
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, @invalid_attrs)

      assert transaction == Transactions.get_transaction!(transaction.id)
    end

    test "doesn't allow to update status back to :pending" do
      transaction = transaction_fixture()

      {:ok, failed_transaction} = Transactions.update_transaction(transaction, %{status: :failed})

      assert {:error, %Ecto.Changeset{errors: [status: {"can't be reverted to pending", []}]}} =
               Transactions.update_transaction(failed_transaction, %{status: :pending})
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_transaction!(transaction.id) end
    end
  end
end
