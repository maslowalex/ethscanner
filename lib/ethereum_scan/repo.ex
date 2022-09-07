defmodule EthereumScan.Repo do
  use Ecto.Repo,
    otp_app: :ethereum_scan,
    adapter: Ecto.Adapters.Postgres
end
