defmodule EthereumScan.Transactions.CheckConfirmationsTest do
  use EthereumScan.DataCase, async: true

  import Mox

  alias EthereumScan.Transactions.CheckConfirmations
  alias EthereumScan.Transactions.Transaction

  describe "call/1" do
    setup :verify_on_exit!

    setup do
      Application.put_env(:ethereum_scan, :http_adapter, EthereumScan.HttpAdapterMock)

      on_exit(fn ->
        Application.put_env(:ethereum_scan, :http_adapter, EthereumScan.HttpAdapter)
      end)

      transaction = %Transaction{
        tx_hash: "0x621ef47a6a4f1bbeb0a2a7cb573052fbaf7d1b8a9b2d8f5ede66e2c61c9a8861"
      }

      %{transaction: transaction}
    end

    test "with transaction status other than pending - return an error" do
      failed_transaction = %Transaction{status: :failed, tx_hash: "whatever"}

      assert {:error, :not_pending_status} = CheckConfirmations.call(failed_transaction)
    end

    test "with successfull response from API - returns {:ok, confirmations} tuple", %{
      transaction: transaction
    } do
      expect(EthereumScan.HttpAdapterMock, :get, fn _ ->
        {:ok, Jason.encode!(%{confirmations: 33})}
      end)

      assert {:ok, 33} = CheckConfirmations.call(transaction)
    end

    test "when execution error key is present in response - return error tuple", ctx do
      expect(EthereumScan.HttpAdapterMock, :get, fn _ ->
        {:ok, Jason.encode!(%{confirmations: 4, execution_error: "cancelled"})}
      end)

      assert {:error, :transaction_failed} = CheckConfirmations.call(ctx.transaction)
    end

    test "when confirmations key is not present in response", ctx do
      expect(EthereumScan.HttpAdapterMock, :get, fn _ -> {:ok, Jason.encode!(%{})} end)

      assert {:error, "Key 'confirmations' wasn't found in response"} =
               CheckConfirmations.call(ctx.transaction)
    end

    test "with other errors - return them unchanged", ctx do
      expect(EthereumScan.HttpAdapterMock, :get, fn _ -> {:error, "Transaction was not found"} end)

      assert {:error, "Transaction was not found"} = CheckConfirmations.call(ctx.transaction)
    end
  end
end
