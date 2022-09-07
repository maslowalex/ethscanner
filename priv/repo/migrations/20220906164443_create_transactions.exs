defmodule EthereumScan.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :tx_hash, :string, null: false
      add :confirmations, :integer, null: false
      add :status, :integer, null: false

      timestamps()
    end

    create unique_index(:transactions, :tx_hash)
  end
end
