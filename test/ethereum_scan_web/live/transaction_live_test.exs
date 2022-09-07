defmodule EthereumScanWeb.TransactionLiveTest do
  use EthereumScanWeb.ConnCase

  import Phoenix.LiveViewTest
  import EthereumScan.TransactionsFixtures

  @create_attrs %{tx_hash: "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"}

  defp create_transaction(_) do
    transaction = transaction_fixture()
    %{transaction: transaction}
  end

  describe "Index" do
    setup [:create_transaction]

    test "lists all transactions", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.transaction_index_path(conn, :index))

      assert html =~ "Tx hash to track"
    end

    test "saves new transaction", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.transaction_index_path(conn, :index))

      error_html =
        index_live
        |> form("#transaction-form", transaction: %{tx_hash: "ajsldka"})
        |> render_submit()

      assert error_html =~ "should be 66 character(s)"

      {:ok, _, html} =
        index_live
        |> form("#transaction-form", transaction: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.transaction_index_path(conn, :index))

      assert html =~ "Transaction created successfully"
    end
  end
end
