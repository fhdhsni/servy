defmodule Servy.KickStarter do
  use GenServer

  def start_link(_arg) do
    IO.puts("Starting the kickstarter...")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:ok, start_server()}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HTTP server exited (#{inspect(reason)})")
    {:noreply, start_server()}
  end

  defp start_server do
    IO.puts("Starting the HTTP sever...")
    port = Application.get_env(:servy, :port)
    server_pid = spawn_link(Servy.HttpServer, :start, [port])
    Process.register(server_pid, :http_server)
    server_pid
  end
end
