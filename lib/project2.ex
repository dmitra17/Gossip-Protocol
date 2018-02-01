defmodule Project2 do

  use GenServer

  def main(args) do
    [nNodes, topology, algorithm] = args

    numNodes = nNodes|>String.to_integer()
    numNodes = :math.sqrt(numNodes)|> Float.floor|> round
    numNodes = numNodes*numNodes
    
    {:ok, monitor_pid} = GenServer.start_link(__MODULE__, [System.system_time(:millisecond), algorithm, 0, numNodes])
    :global.register_name(:main_server, monitor_pid)

    listNodes = []
    listNodes = for nodeNum <- 1..(numNodes) do
      {:ok, pid} = case algorithm do
        "gossip" -> GenServer.start_link(Project2.Server, 0)
        "push-sum" -> 
          s = nodeNum - 1
          w = 1
          GenServer.start_link(Project2.Server, [0, s, w])
      end      
      pid
    end

    case algorithm do
      "gossip" -> Project2.Server.sendRumor(List.first(listNodes), [], listNodes, topology)
      "push-sum" -> Project2.Server.sendRumor(List.first(listNodes), [0, 0], listNodes, topology)
    end
    :timer.sleep(:infinity)
  end

  def handle_cast({:process_died, pid}, state) do
    [start_time , algorithm | state_rem] = state

      numDeadProcess = List.first(state_rem)
      numNodes = List.last(state_rem)
      pctNumDeadProcess = ((numDeadProcess + 1) * 100)
      pctNumDeadProcess = pctNumDeadProcess / numNodes

      if pctNumDeadProcess < 75 do
        {:noreply, [start_time, algorithm, numDeadProcess + 1, numNodes]}
      else
        #IO.puts "Start: Convergence"
        end_time = System.system_time(:millisecond)
        total_time = end_time - start_time
        IO.puts "Time (in milliseconds): "
        IO.inspect total_time
        {:stop, :shutdown, []}
      end
  end
  
end