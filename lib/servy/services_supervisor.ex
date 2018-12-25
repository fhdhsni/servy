defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts("Starting the services supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.PledgeServer,

      # 60 will be passed to start_link
      {Servy.SensorServer, 60}
    ]

    # for it (Supervisor) to know how to start the above childrens, it calls
    # `child_spec` of each of them, Like `Servy.SensorServer.child_spec([])` which
    # returns {id: Servy.PledgeServer, start: {Servy.PledgeServer, :start_link, [[]]}}
    Supervisor.init(children, strategy: :one_for_one)
  end
end
