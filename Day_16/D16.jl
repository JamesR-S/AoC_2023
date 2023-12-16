cd(@__DIR__)

using .Threads

struct paramset
    position::CartesianIndex
    direction::String
end

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

direction_changes = Dict(
    ("east", '\\') => "south",
    ("south", '\\') => "east",
    ("west", '\\') => "north",
    ("north", '\\') => "west",
    ("east", '/') => "north",
    ("south", '/') => "west",
    ("west", '/') => "south",
    ("north", '/') => "east"
)

function traverse(input, position, direction, visited, params)
    if !(paramset(position, direction) ∈ params)
        push!(params, paramset(position, direction))
        new_x, new_y = position[1], position[2]
        new_y += (direction == "east") - (direction == "west")
        new_x += (direction == "south") - (direction == "north")

        if (1 <= new_x <= size(input)[1]) && (1 <= new_y <= size(input)[2])
            coords = CartesianIndex(new_x, new_y)
            push!(visited, coords)

            if input[coords] ∈ ['\\', '/']
                new_direction = direction_changes[(direction, input[coords])]
                traverse(input, coords, new_direction, visited, params)
            elseif input[coords] == '|' && direction ∈ ["east","west"]
                traverse(input,coords,"north",visited,params)
                traverse(input,coords,"south",visited,params)
            elseif input[coords] == '-' && direction ∈ ["north","south"]
                traverse(input,coords,"east",visited,params)
                traverse(input,coords,"west",visited,params)
            else
                traverse(input, coords, direction, visited, params)
            end
        end
    end
end

function energised(input)
    visited = Set([])
    params = Set([])
    traverse(input, CartesianIndex(1, 0), "east", visited, params)
    return length(visited)
end

function energised_pt2(input)
    n_energised = 0
    Threads.@threads for i in 1:size(input)[1]
        for direction in ["east", "west"]
            start_x = direction == "east" ? 0 : size(input)[2] + 1
            visited = Set([])
            params = Set([])
            traverse(input, CartesianIndex(i, start_x), direction, visited, params)
            n_energised = max(n_energised, length(visited))
        end
    end

    for j in 1:size(input)[2]
        Threads.@threads for direction in ["north", "south"]
            start_y = direction == "north" ? 0 : size(input)[1] + 1
            visited = Set([])
            params = Set([])
            traverse(input, CartesianIndex(start_y, j), direction, visited, params)
            n_energised = max(n_energised, length(visited))
        end
    end

    return n_energised
end


input = file_to_matrix("input.txt")

println("The answer to part 1 is ",energised(input))
println("The answer to part 2 is ",energised_pt2(input))

