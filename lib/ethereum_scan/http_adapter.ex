defmodule EthereumScan.HttpAdapter do
  @doc """
  Generic adapter that is not depends on specific library (f.e. HTTPoison)
  """

  @type response :: String.t()
  @type url :: String.t()
  @type error :: String.t() | atom()

  @callback get(url) :: {:ok, response} | {:error, error}
end
