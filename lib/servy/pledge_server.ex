defmodule Servy.PledgeServer do
  use GenServer
  @name :pledge_server

  defmodule State do
    defstruct cache_size: 3, total: 0, pledges: []
  end

  def start_link(_args) do
    IO.puts("Starting the pledge server...")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@name, :total_pledged)
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def set_cache_size(new_cache_size) do
    GenServer.call(@name, {:set_cache_size, new_cache_size})
  end

  # Server Callbacks

  def init(state) do
    pledges = fetch_recent_pledges_from_service() |> Enum.take(state.cache_size)
    total = pledges |> Enum.reduce(0, fn {_, amount}, acc -> amount + acc end)

    state = %State{state | pledges: pledges, total: total}

    {:ok, state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %State{state | pledges: []}}
  end

  def handle_call({:set_cache_size, new_cache_size}, _from, state) do
    {:reply, new_cache_size, %State{state | cache_size: new_cache_size}}
  end

  def handle_call(:total_pledged, _from, state) do
    {:reply, state.total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    pledges = [{name, amount} | Enum.take(state.pledges, state.cache_size - 1)]
    {:reply, id, %State{state | pledges: pledges, total: state.total + amount}}
  end

  def handle_info(message, state) do
    IO.puts("What's this? #{inspect(message)}")

    {:noreply, state}
  end

  defp send_pledge_to_service(_, _) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    [{"Pence", 0}, {"Trump", 1}]
  end
end

# alias Servy.PledgeServer

# {:ok, pid} = PledgeServer.start()

# send(pid, {:stop, "hammertime"})

# PledgeServer.set_cache_size(5)

# IO.inspect(PledgeServer.create_pledge("larry", 100))
# # PledgeServer.clear()
# # IO.inspect(PledgeServer.create_pledge("moe", 20))
# # IO.inspect(PledgeServer.create_pledge("curly", 30))
# # IO.inspect(PledgeServer.create_pledge("daisy", 40))

# # IO.inspect(PledgeServer.create_pledge("Farhad", 50))
# # IO.inspect(PledgeServer.create_pledge("grace", 250))

# IO.inspect(PledgeServer.recent_pledges())

# IO.inspect(PledgeServer.total_pledged())
