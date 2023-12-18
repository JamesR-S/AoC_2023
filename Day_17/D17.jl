cd(@__DIR__)

using DataStructures

function file_to_matrix(filename)
    lines = readlines(filename)
    num_rows = length(lines)
    num_cols = length(lines[1])

    int_matrix = fill(0, (num_rows, num_cols))

    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(line)
            int_matrix[i, j] = parse(Int, char)
        end
    end
    
    return int_matrix
end

function dijkstra(data::Matrix{Int}, min_dist::Int, max_dist::Int)
    DIRS = (CartesianIndex(0, -1), CartesianIndex(1, 0),
              CartesianIndex(0, 1), CartesianIndex(-1, 0))
    UP = 1; RIGHT = 2; DOWN = 3; LEFT = 4
    OPPOSITE = (DOWN, LEFT, UP, RIGHT)
    MAX_COST = typemax(Int16)
    dist = fill(MAX_COST, length(DIRS), max_dist, size(data)...)
    queue = PriorityQueue{CartesianIndex{4}, Int}()

    for p in CartesianIndices(data), dir in eachindex(DIRS), seq in 1:max_dist
        queue[CartesianIndex(dir, seq, p)] = MAX_COST
    end

    for (source, source_dist) in (
        (CartesianIndex(DOWN, 1, 1, 2), data[1, 2]),
        (CartesianIndex(RIGHT, 1, 2, 1), data[2, 1]))
        dist[source] = queue[source] = source_dist
    end

    while !isempty(queue)
        u = dequeue!(queue)
        dist_u = dist[u]
        dist_u == MAX_COST && continue

        for dir in eachindex(DIRS)
            dir == OPPOSITE[u[1]] && continue
            dir == u[1] && u[2] == max_dist && continue
            dir != u[1] && u[2] < min_dist && continue
            xy = CartesianIndex(u[3], u[4]) + DIRS[dir]
            !checkbounds(Bool, data, xy) && continue

            v = CartesianIndex(dir, dir == u[1] ? u[2] + 1 : 1, xy)
            dist_v = get(queue, v, -1)
            dist_v == -1 && continue

            alt = dist_u + data[xy]
            if alt < dist_v
                queue[v] = alt
                dist[v] = alt
            end
        end
    end
    return minimum(dist[:, min_dist:max_dist, end, end])
end

matrix = file_to_matrix("input.txt")
pt1_res = dijkstra(matrix,1,3)
pt2_res = dijkstra(matrix,4,10)

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)