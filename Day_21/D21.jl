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

function wrap_around(point,bounds)
    r, c = point.I
    r = r < 1 ? bounds[1] - (abs(r) % bounds[1]) : (r % bounds[1]) == 0 ? 131 : r > bounds[1] ? r % bounds[1] : r
    c = c < 1 ? bounds[2] - (abs(c) % bounds[2]) : (c % bounds[2]) == 0 ? 131 : c > bounds[2] ? c % bounds[2] : c
    return CartesianIndex(r, c)
end

function BFS(input, nsteps)
    start = findfirst(x -> x == 'S', input)
    directions = [CartesianIndex(1,0), CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1)]
    bounds = [size(input, 1) size(input, 2)]

    queue = Queue{Tuple{CartesianIndex{2}, Int}}()
    visited = Set{CartesianIndex{2}}()
    tot = 0
    target_parity = nsteps % 2

    enqueue!(queue, (start, 0))

    while !isempty(queue)
        (point, steps) = dequeue!(queue)

        if point in visited || steps > nsteps
            continue
        end

        push!(visited, point)

        if steps % 2 == target_parity && steps <= nsteps
            tot += 1
        end

        if steps < nsteps
            for direction in directions
                next_point = point + direction
                if input[wrap_around(next_point,bounds)] != '#' 
                        enqueue!(queue, (next_point, steps + 1))
                end
            end
        end
    end

    return tot
end

function quad_solver(input, nsteps)
    remainder = nsteps % size(input, 1)
    steps = [i for i in remainder:size(input, 1):(size(input, 1)*3 +remainder)]
    x = Int((nsteps - remainder)/size(input, 1))
    visited_squares = [BFS(input,step) for step in steps]
    a = Int((visited_squares[1] - 2*visited_squares[2] + visited_squares[3]) / 2)
    b = Int((-3*visited_squares[1] + 4*visited_squares[2] - visited_squares[3]) / 2)
    c = visited_squares[1]
    return a * x^2 + b * x + c
end

input = file_to_matrix("input.txt")

pt1_res = BFS(input,64)

pt2_res = quad_solver(input,26501365)

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)