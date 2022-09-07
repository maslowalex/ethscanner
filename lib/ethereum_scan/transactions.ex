defmodule EthereumScan.Transactions do
  @moduledoc """
  The Transactions context.
  """

  @confirmations_to_confirmed Application.compile_env!(:ethereum_scan, :confirmations_to_confirmed)

  import Ecto.Query, warn: false
  alias EthereumScan.Repo

  alias EthereumScan.Transactions.Transaction
  alias EthereumScan.Transactions.Worker

  @doc """
  Starts a worker in background that will be checking confirmations number
  """
  def start_check_confirmations_worker(%Transaction{} = transaction) do
    DynamicSupervisor.start_child(EthereumScan.DynamicSupervisor, {Worker, transaction})
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Transaction
    |> order_by([t], desc: t.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, %{confirmations: confirmations})
      when is_integer(confirmations) do
    transaction
    |> Transaction.update_changeset(%{
      confirmations: confirmations,
      status: status_from_confirmations(confirmations)
    })
    |> Repo.update()
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.update_changeset(attrs)
    |> Repo.update()
  end

  defp status_from_confirmations(confirmations) when confirmations > @confirmations_to_confirmed, do: :confirmed
  defp status_from_confirmations(_), do: :pending

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.update_changeset(transaction, attrs)
  end
end
