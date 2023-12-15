cd(@__DIR__)

struct MatrixKey{T}
    matrix::Matrix{T}
end

Base.hash(mk::MatrixKey, h::UInt) = hash(mk.matrix, h)
Base.:(==)(mk1::MatrixKey, mk2::MatrixKey) = mk1.matrix == mk2.matrix


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

function tilt(input, direction)
    modified_input = copy(input)
    if direction == 2
        modified_input = permutedims(modified_input)[:,end:-1:1]
    elseif direction == 3
        modified_input = modified_input[end:-1:1,end:-1:1]
    elseif direction == 0
        modified_input = permutedims(modified_input)[end:-1:1,:]
    end
    moving = true
    while moving
        moving = false
        boulders = findall(x -> x == 'O', modified_input)
        for boulder in filter(x -> x[1] != 1, boulders)
            if modified_input[boulder[1]-1, boulder[2]] == '.'
                modified_input[boulder] = '.'
                modified_input[boulder[1]-1, boulder[2]] = 'O'
                moving = true
            end
        end
    end
    if direction == 2
        modified_input = permutedims(modified_input)[end:-1:1,:]
    elseif direction == 3
        modified_input = modified_input[end:-1:1,end:-1:1]
    elseif direction == 0
        modified_input = permutedims(modified_input)[:,end:-1:1]
    end
    return modified_input
end

function calculate_load(input)
    input = tilt(input, 1)
    boulders = findall(x -> x == 'O', input[end:-1:1,:])
    return sum([x[1] for x in boulders])
end

function find_pattern(input)
    seen = Dict()
    seen[MatrixKey(input)] = 0
    i = 1
    while true
        input = tilt(input, 1)
        input = tilt(input, 2)
        input = tilt(input, 3)
        input = tilt(input, 0)
        key = MatrixKey(input)
        if haskey(seen, key)
            first_occurrence = seen[key]
            cycle_length = i - first_occurrence
            return i, first_occurrence, cycle_length
        end
        seen[key] = i
        i += 1
    end
end

function tilt_iterate(input, n)
    modified_input = copy(input)
    for i in 1:n*4
        modified_input = tilt(modified_input, (i % 4))
    end
    boulders = findall(x -> x == 'O', modified_input[end:-1:1,:])
    return sum([x[1] for x in boulders])
end

function cycled_load(input,large_cycle_number)
    total_cycles, first_occurrence, cycle_length = find_pattern(input)
    equivalent_cycle = (large_cycle_number - first_occurrence) % cycle_length + first_occurrence
    final_state = tilt_iterate(copy(input), equivalent_cycle)
    return final_state
end


input = file_to_matrix("input.txt")
println("The answer to part 1 is ", calculate_load(input))
println("The answer to part 2 is ", cycled_load(input,1_000_000_000))