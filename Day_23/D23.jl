cd(@__DIR__)
using DataStructures

function file_to_matrix(filename::String)
    lines = readlines(filename)
    num_rows = length(lines)
    num_cols = length(lines[1])
    char_matrix = fill(' ', (num_rows, num_cols))
    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(line)
            char_matrix[i, j] = char
        end
    end
    return char_matrix
end

function build_graph(input::Array{Char,2})
    graph = Dict{CartesianIndex{2}, Vector{CartesianIndex{2}}}()
    for i in 1:size(input,1)
        for j in 1:size(input,2)
            if input[i,j] != '#'
                graph[CartesianIndex(i,j)] = find_neighbors(i, j, input)
            end
        end
    end
    return graph
end

function find_neighbors(i::Int, j::Int, input::Array{Char,2})
    neighbors = CartesianIndex{2}[]
    if input[i,j] == '.'
        append!(neighbors, filter(coord -> checkbounds(Bool, input, coord) && input[coord] != '#', [CartesianIndex(i,j+1), CartesianIndex(i,j-1), CartesianIndex(i+1,j), CartesianIndex(i-1,j)]))
    elseif input[i,j] == '<' && input[i,j-1] != '#'
        push!(neighbors, CartesianIndex(i,j-1))
    elseif input[i,j] == '>' && input[i,j+1] != '#'
        push!(neighbors, CartesianIndex(i,j+1))
    elseif input[i,j] == '^' && input[i-1,j] != '#'
        push!(neighbors, CartesianIndex(i-1,j))
    elseif input[i,j] == 'v' && input[i+1,j] != '#'
        push!(neighbors, CartesianIndex(i+1,j))
    end
    return neighbors
end

function build_graph_no_slope(input::Array{Char,2})
    graph = Dict{CartesianIndex{2}, Vector{CartesianIndex{2}}}()
    for i in 1:size(input,1)
        for j in 1:size(input,2)
            if input[i,j] != '#'
                neighbors = filter(coord -> checkbounds(Bool, input, coord) && input[coord] != '#', [CartesianIndex(i,j+1), CartesianIndex(i,j-1), CartesianIndex(i+1,j), CartesianIndex(i-1,j)])
                graph[CartesianIndex(i,j)] = neighbors
            end
        end
    end
    return graph
end

function simplify_graph(graph::Dict{CartesianIndex{2}, Vector{CartesianIndex{2}}}, start_node::CartesianIndex{2}, end_node::CartesianIndex{2})
    intersections = Dict()
    for (key, connections) in graph
        if length(connections) > 2 || key == start_node || key == end_node
            intersections[key] = connections
        end
    end
    is_intersection = Dict(key => true for key in keys(intersections))
    simplified_graph = Dict{CartesianIndex{2}, Dict{CartesianIndex{2}, Int}}()
    for (key, connections) in intersections
        for node in connections
            current_node = node
            previous_node = key
            distance = 1
            while !haskey(is_intersection, current_node) && !(length(graph[current_node]) < 2 && previous_node in graph[current_node])
                distance += 1
                next_node = first(filter(x -> x != previous_node, graph[current_node]))
                previous_node, current_node = current_node, next_node
            end
            valid = ((length(graph[current_node]) > 1) && current_node != node)
            if !haskey(simplified_graph, key)
                simplified_graph[key] = Dict()
            end
            if current_node == end_node
                simplified_graph[key] = Dict()
                simplified_graph[key][current_node] = distance
                break
            elseif valid
                simplified_graph[key][current_node] = distance
            end
        end
    end
    return simplified_graph
end

function DFS_longest_path(graph::Dict{CartesianIndex{2}, Dict{CartesianIndex{2}, Int}}, start_node::CartesianIndex{2}, end_node::CartesianIndex{2})
    visited = Set{CartesianIndex{2}}()
    longest_path = Ref(-1)

    function dfs(current_node::CartesianIndex{2}, current_length::Int)
        if current_node == end_node
            longest_path[] = max(longest_path[], current_length)
            return
        end
        push!(visited, current_node)

        for (neighbor, distance) in graph[current_node]
            if !in(neighbor, visited)
                dfs(neighbor, current_length + distance)
            end
        end
        pop!(visited, current_node)
    end

    dfs(start_node, 0)
    return longest_path[]
end

function find_longest(input::Array{Char,2}, start_node::CartesianIndex{2}, end_node::CartesianIndex{2}, pt::Int)
    if pt == 1
        graph = build_graph(input)
    elseif pt == 2
        graph = build_graph_no_slope(input)
    else
        return "Invalid part specification"
    end
    simplified_graph = simplify_graph(graph, start_node, end_node)
    longest_path = DFS_longest_path(simplified_graph, start_node, end_node)
    return longest_path
end

input = file_to_matrix("input.txt")

pt1_res = find_longest(input, CartesianIndex(1, 2), CartesianIndex(141, 140),1)

pt2_res = find_longest(input, CartesianIndex(1, 2), CartesianIndex(141, 140),2)

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)