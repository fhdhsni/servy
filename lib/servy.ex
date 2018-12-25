defmodule Servy do
  use Application

  def start(_type, _arg) do
    IO.puts("Starting the application...")
    {:ok, sup_pid} = Servy.Supervisor.start_link()
    # start should return {:ok, pid}
    {:ok, sup_pid}
  end
end
