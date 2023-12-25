cd(@__DIR__)
using LightGraphs
using CommunityDetection
using GraphPlot
using Colors


# Function to parse a line and return the node and its adjacent nodes
function parse_line(line)
    node, adj_nodes_str = split(line, ": ")
    adj_nodes = split(adj_nodes_str, " ")
    return node, adj_nodes
end

function parse_input(path)
    # Initialize an empty graph
    G = SimpleGraph()

    # Initialize a dictionary to map node names to integers
    node_to_int = Dict{String, Int}()
    int_to_node = Dict{Int, String}()

    # Read the file and build the graph
    open(path, "r") do file
        node_counter = 1
        for line in eachline(file)
            node, adj_nodes = parse_line(line)
            
            # Add nodes to the graph and the mapping dictionaries
            if !haskey(node_to_int, node)
                node_to_int[node] = node_counter
                int_to_node[node_counter] = node
                add_vertex!(G)
                node_counter += 1
            end

            for adj_node in adj_nodes
                if !haskey(node_to_int, adj_node)
                    node_to_int[adj_node] = node_counter
                    int_to_node[node_counter] = adj_node
                    add_vertex!(G)
                    node_counter += 1
                end

                # Add edges to the graph
                add_edge!(G, node_to_int[node], node_to_int[adj_node])
            end
        end
    end
    return G
end
# Now G is your graph, and node_to_int and int_to_node help you keep track of node names
function solve_D25(G)
    clusters = community_detection_bethe(G,2)
    return length(filter(x -> x == 1, clusters)) * length(filter(x -> x == 2, clusters))
end

G = parse_input("input.txt")

D25 = solve_D25(G)

println("The answer to Day 25 is ",D25)