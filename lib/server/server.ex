defmodule Project2.Server do
  @moduledoc """
  Documentation for Project1.Server module.
  """
  use GenServer
  
  def sendRumor(pid, rumor, listNodes, topology) do
    neigh_pid = fetchRandNeigh(pid, listNodes, topology)
    GenServer.cast(neigh_pid, {:send_rumor, rumor, listNodes, topology})
    if length(rumor) == 0 do
      sendRumor(pid, rumor, listNodes, topology)
    end
  end

  def fetchRandNeigh(pid, listNodes, topology) do
    case topology do
      "line" -> 
        if List.first(listNodes) == pid do
          neigh_pid = Enum.at(listNodes, 1)
        else 
          if List.last(listNodes) == pid do
            neigh_pid = Enum.at(listNodes, length(listNodes) - 1)
          else
            rand_val = Enum.random([true,false])
            adder = case rand_val do 
              true -> 1 
              false -> -1 
            end
            pid_idx = Enum.find_index(listNodes, fn(x) -> x==pid end)
            n_idx = pid_idx + adder
            neigh_pid = Enum.at(listNodes, n_idx)
          end
        end
      "full" ->
        neigh_pid = Enum.random(List.delete(listNodes, pid))
      "2D" ->
        numNodes = length(listNodes)
        n = round(Float.floor(:math.sqrt(numNodes)))
        pid_idx = Enum.find_index(listNodes, fn(x) -> x==pid end)
        rowNum = round(Float.floor(pid_idx/n))
        colNum = rem(pid_idx,n)
        neighbours = []

        if (rowNum == 0) || (rowNum == n-1) do        
          if (colNum == 0) || (colNum == n-1) do
            x = n - 1
            neighbours = case {rowNum, colNum} do
              {0, 0} -> [{0,1}, {1,0}]
              {x, x} -> [{x, x-1}, {x-1, x}]
              {0, x} -> [{0, x-1}, {1, x}]
              {x, 0} -> [{x-1, 0}, {x, 1}]
            end
          else
            x = n - 1
            neighbours = if rowNum == 0 do
              [{0,colNum-1}, {0, colNum+1}, {1, colNum}]
            else
              if rowNum == x do
                [{x,colNum-1}, {x, colNum+1}, {x-1, colNum}]
              end  
            end
          end
        else
          if (colNum == 0 ) || (colNum == n-1) do
            x = n - 1
            neighbours = if colNum == 0 do
              [{rowNum-1,0}, {rowNum+1, 0}, {rowNum, 1}]
            else
               if colNum == x do
                [{rowNum-1,x}, {rowNum+1, x}, {rowNum, x-1}] 
              end
            end
          else
            x = n - 1
            neighbours = [{rowNum-1,colNum}, {rowNum+1, colNum}, {rowNum, colNum-1}, {rowNum, colNum+1}]
          end
        end
        rand_neighbour = Enum.random(neighbours)
        randRow = elem(rand_neighbour, 0)
        randCol = elem(rand_neighbour, 1)
        neighbour_index = n * randRow + randCol
        neigh_pid = Enum.at(listNodes, neighbour_index)
      "imp2D" ->
        numNodes = length(listNodes)
        n = round(Float.floor(:math.sqrt(numNodes)))
        pid_idx = Enum.find_index(listNodes, fn(x) -> x==pid end)
        rowNum = round(Float.floor(pid_idx/n))
        colNum = rem(pid_idx,n)
        neighbours = []

        if (rowNum == 0) || (rowNum == n-1) do        
          if (colNum == 0) || (colNum == n-1) do
            x = n - 1
            neighbours = case {rowNum, colNum} do
              {0, 0} -> [{0,1}, {1,0}]
              {0, x} -> [{0, x-1}, {1, x}]
              {x, 0} -> [{x-1, 0}, {x, 1}]
              {x, x} -> [{x, x-1}, {x-1, x}]
            end
          else
            x = n - 1
            neighbours = if rowNum == 0 do
              [{0,colNum-1}, {0, colNum+1}, {1, colNum}]
            else
              if rowNum == x do
                [{x,colNum-1}, {x, colNum+1}, {x-1, colNum}]
              end  
            end 

          end
        else
          if (colNum == 0 ) || (colNum == n-1) do
            x = n - 1
            neighbours = if colNum == 0 do
              [{rowNum-1,0}, {rowNum+1, 0}, {rowNum, 1}]
            else
               if colNum == x do
                  [{rowNum-1, x}, {rowNum+1, x}, {rowNum, x-1}] 
              end
            end

          else
            x = n - 1
            neighbours = [{rowNum-1,colNum}, {rowNum+1, colNum}, {rowNum, colNum-1}, {rowNum, colNum+1}]
          end
        end

        neighProcess = for i <- neighbours do
          row = elem(i, 0)
          col = elem(i, 1)
          neigh_idx = n * row + col
          neigh_pid = Enum.at(listNodes, neigh_idx)
        end

        remNodes = listNodes -- neighProcess
        remNodes = remNodes -- [pid]
        remNodes_rand = Enum.random(remNodes)
        neighProcess = neighProcess ++ [remNodes_rand]
        neigh_pid = Enum.random(neighProcess)
      end
  end
  
  def init(messages) do
    {:ok, messages}
  end
  
  def handle_cast({:send_rumor, rumor, listNodes, topology}, state) do
    pid = self()
    if is_list(state) do
      [count | s_w] = state
      rum_s = List.first(rumor)
      rum_w = List.last(rumor)
      state_s = List.first(s_w)
      state_w = List.last(s_w)
      new_state_s = (state_s + rum_s)
      new_state_w = (state_w + rum_w)

      curr_count = count + 1

      if curr_count < 4 do
        if ((new_state_s/new_state_w) - (state_s/state_w) <= :math.pow(10, -10)) do      
          if (curr_count == 3) do
            var1 = state_s/state_w
            :global.sync()
            spawn(fn -> sendRumor(pid, [rum_s, rum_w], listNodes, topology) end)
            spawn(fn -> notifyDeadProc(pid) end)
            {:noreply, [curr_count, state_s, state_w]}
          else
            spawn(fn -> sendRumor(pid, [new_state_s/2, new_state_w/2], listNodes, topology) end)
            {:noreply, [curr_count, new_state_s/2, new_state_w/2]}
          end
        else
          spawn(fn -> sendRumor(pid, [new_state_s/2, new_state_w/2], listNodes, topology) end)
          {:noreply, [0, new_state_s/2, new_state_w/2]}
        end
      else
        var1 = state_s/state_w
        spawn(fn -> sendRumor(pid, [rum_s, rum_w], listNodes, topology) end)
        {:noreply, [curr_count, state_s, state_w]}
      end
    else
      if state <= 10 do
        if state == 10 do
          :global.sync()
          spawn(fn -> notifyDeadProc(pid) end)
          {:noreply, state + 1}
        else
          spawn(fn -> sendRumor(pid, [], listNodes, topology) end)
          {:noreply, state+1}
        end
      else
        {:noreply, state}
      end
    end
  end

  def notifyDeadProc(pid) do
    GenServer.cast(:global.whereis_name(:main_server), {:process_died, pid})
  end

end