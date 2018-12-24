defmodule Servy.GenericServer do
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(state, callback_module)

      {:cast, message} ->
        state = callback_module.handle_cast(message, state)
        listen_loop(state, callback_module)

      _ ->
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.PledgeServer do
  alias Servy.GenericServer

  @name :pledged_server

  def start do
    IO.puts("STARTING...")
    GenericServer.start(__MODULE__, %{last_three: [], total: 0}, @name)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenericServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@name, :total_pledged)
  end

  def clear do
    GenericServer.cast(@name, :clear)
  end

  def handle_cast(:clear, state) do
    %{last_three: [], total: state.total}
  end

  def handle_call(:total_pledged, state) do
    {state.total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state.last_three, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    last_three = [{name, amount} | Enum.take(state.last_three, 2)]
    {id, %{last_three: last_three, total: state.total + amount}}
  end

  def handle_call(command, _state) do
    IO.puts("no action for #{inspect(command)}")
  end

  defp send_pledge_to_service(_, _) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

pid = PledgeServer.start()

send(pid, {:stop, "hammertime"})

IO.inspect(PledgeServer.create_pledge("larry", 100))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))

PledgeServer.clear()

IO.inspect(PledgeServer.create_pledge("grace", 50))
IO.inspect(PledgeServer.create_pledge("grace", 250))

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledged())

# IO.inspect(Process.info(pid, :messages))
