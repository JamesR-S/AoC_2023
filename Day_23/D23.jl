cd(@__DIR__)
using DataStructures

function file_to_matrix(filename)
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

function build_graph(input)
    graph = Dict()
    for i in 1:size(input,1)
        for j in 1:size(input,2)
            if input[i,j] != '#'
                graph[CartesianIndex(i,j)] = find_neighbors(i,j,input)
            end
        end
    end
    return graph
end

function find_neighbors(i,j,input)
    if input[i,j] == '.'
        neighbors = [CartesianIndex(i,j+1),CartesianIndex(i,j-1),CartesianIndex(i+1,j),CartesianIndex(i-1,j)]
        filter!(coord -> checkbounds(Bool, input, coord),neighbors)
        filter!(coord -> input[coord] != '#',neighbors)
    elseif input[i,j] == '<' && input[i,j-1] != '#'
        neighbors = [CartesianIndex(i,j-1)]
    elseif input[i,j] == '>' && input[i,j+1] != '#'
        neighbors = [CartesianIndex(i,j+1)]
    elseif input[i,j] == '^' && input[i-1,j] != '#'
        neighbors = [CartesianIndex(i-1,j)]
    elseif input[i,j] == 'v' && input[i+1,j] != '#'
        neighbors = [CartesianIndex(i+1,j)]
    else neighbors = []
    end
    return neighbors
end

function build_graph_no_slope(input)
    graph = Dict()
    for i in 1:size(input,1)
        for j in 1:size(input,2)
            if input[i,j] != '#'
                neighbors = [CartesianIndex(i,j+1),CartesianIndex(i,j-1),CartesianIndex(i+1,j),CartesianIndex(i-1,j)]
                filter!(coord -> checkbounds(Bool, input, coord),neighbors)
                filter!(coord -> input[coord] != '#',neighbors)
                graph[CartesianIndex(i,j)] = neighbors
            end
        end
    end
    return graph
end

function simplify_graph(graph,start_node,end_node)
    intersections = Dict()
    for (key, connections) in graph
        if length(connections) > 2 || key == start_node || key == end_node
            intersections[key] = connections
        end
    end
    is_intersection = Dict(key => true for key in keys(intersections))
    simplified_graph = Dict()
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

function DFS_longest_path(graph, start_node, end_node)
    visited = Dict{Any, Bool}()
    for node in keys(graph)
        visited[node] = false
    end
    longest_path = Ref(-1)

    function dfs(current_node, current_length)
        if current_node == end_node
            longest_path[] = max(longest_path[], current_length)
            return
        end
        visited[current_node] = true

        if end_node ∈ keys(graph[current_node])
            dfs(end_node, current_length + graph[current_node][end_node])
        else
            for (neighbor, distance) in graph[current_node]
                if !visited[neighbor]
                    dfs(neighbor, current_length + distance)
                end
            end
        end
        visited[current_node] = false
    end

    dfs(start_node, 0)
    return longest_path[]
end

function find_longest(input, start_node, end_node,pt)
    if pt == 1
        graph = build_graph(input)
    elseif pt == 2
        graph = build_graph_no_slope(input)
    else
        return "Invalid part specification"
    end
    simplified = simplify_graph(graph,start_node,end_node)
    longest_path = DFS_longest_path(simplified, start_node, end_node)
    return longest_path
end


input = file_to_matrix("input.txt")

pt1_res = find_longest(input, CartesianIndex(1, 2), CartesianIndex(141, 140),1)

pt2_res = find_longest(input, CartesianIndex(1, 2), CartesianIndex(141, 140),2)

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)