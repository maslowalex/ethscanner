defmodule EthereumScanWeb.PageController do
  use EthereumScanWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
