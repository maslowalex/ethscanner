defmodule EthereumScan.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @transaction_hash_length 66

  import EctoEnum
  defenum(StatusEnum, pending: 0, confirmed: 1, failed: 2)

  schema "transactions" do
    field :confirmations, :integer, default: 0
    field :status, StatusEnum, default: :pending
    field :tx_hash, :string

    timestamps()
  end

  @doc false
  def create_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:tx_hash])
    |> validate_required([:tx_hash])
    |> validate_length(:tx_hash, is: @transaction_hash_length)
  end

  def update_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:confirmations, :status])
    |> validate_required([:confirmations, :status])
    |> validate_status_transition()
  end

  defp validate_status_transition(changeset) do
    validate_change(changeset, :status, fn :status, new_status ->
      case new_status do
        :pending -> [status: "can't be reverted to pending"]
        _ -> []
      end
    end)
  end
end
