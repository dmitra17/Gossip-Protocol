# Project2

Debarshi Mitra – 33813136
Aisharjya Sarkar – 44955999

Gossip Protocol:
We have used GenServer module of Elixir which initiates a main process. The main process then spawns number of actors as specified by the input parameter. All the actors are saved in a centralized list along with its pid. The topology and algorithm is also taken as user input. The main process initiates the gossip protocol by sending a rumor to any single random node. For each actor, the neighbor is calculated based on the input topology on the fly.  Upon receiving the rumor, each transmits the rumor to any of its one neighbor, selected randomly, as obtained from the topology. Simultaneously, each actor transmits the rumor periodically to one of its random neighbors. In this manner, the rumor is spread through the network. Thus, in case of failure of one route, where all the neighbors of a node dies, the rumor will proceed through another path and reach other nodes in the network. We have maintained a convergence value at 75%. That is, when 75% of the nodes receive the rumor, the system shuts down.
The Gossip protocol is executed on four different network topologies as full, line, 2D and Imperfect 2D varying the number of nodes. The table below shows all the experiments that we were able to handle in acceptable time, given the number of nodes.

Largest network on which result was generated:
Algorithm	Full Network	Line	2D Grid	Imperfect 2D Grid
Gossip		2000			2000	2000	2000
Push-Sum	10000			3000	10000	10000

Interesting Findings and Conclusion: 

Gossip Algorithm: 
1. Time taken for line topology convergence is maximum and really high compared to the other 3 topology.
2. The time taken to converge for line increases drastically when number of nodes are increased.
3. The full network topology convergence gives the best performance.

Push-sum Algorithm: 
1. 2D topology takes the least time for convergence of all the topology.
2. Time taken for line topology convergence is maximum and quite high compared to the other 3 topology.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `project2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:project2, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/project2](https://hexdocs.pm/project2).

