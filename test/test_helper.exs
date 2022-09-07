Mox.defmock(EthereumScan.HttpAdapterMock, for: EthereumScan.HttpAdapter)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(EthereumScan.Repo, :manual)
