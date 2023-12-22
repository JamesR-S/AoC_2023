cd(@__DIR__)

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

function traverse(input)
    start = findall(x->x=='S',input)[1]
    visited = [start]
    current = start
    loop_complete=false
    if input[start[1],(start[2]+1)] == '-'
        direction = '→'
    elseif input[start[1],(start[2]-1)] == '-'
        direction = '←'
    else
        direction = '↑'
    end
    while loop_complete == false
        if direction == '↑'
            current = CartesianIndex((current[1]-1),current[2])
            if input[current] == 'F'
                direction = '→'
            elseif input[current] == '7'
                direction = '←'
            end
        elseif direction == '↓'
            current = CartesianIndex((current[1]+1),current[2])
            if input[current] == 'L'
                direction = '→'
            elseif input[current] == 'J'
                direction = '←'
            end
        elseif direction == '←'
            current = CartesianIndex(current[1],(current[2]-1))
            if input[current] == 'F'
                direction = '↓'
            elseif input[current] == 'L'
                direction = '↑'
            end
        else
            current = CartesianIndex(current[1],(current[2]+1))
            if input[current] == '7'
                direction = '↓'
            elseif input[current] == 'J'
                direction = '↑'
            end
        end
        if current == start
            loop_complete = true
        else
            push!(visited,current)
        end
    end
    return visited
end

function determine_area(input,visited)
    filled = 0
    opposites = Dict(['7'=>'F','J'=>'L'])
    for i in 1:size(input)[1]
        inside_loop = false
        last_visited_angle = '.'
        for j in 1:size(input)[2]
            if (input[i,j] == '|') && (CartesianIndex(i,j) ∈ visited)
                inside_loop = !inside_loop
            elseif  (input[i,j] ∈ ['F','L']) && (CartesianIndex(i,j) ∈ visited)
                last_visited_angle = input[CartesianIndex(i,j)]
            elseif (input[i,j] ∈ ['7','J']) && (CartesianIndex(i,j) ∈ visited)
                if last_visited_angle != opposites[input[CartesianIndex(i,j)]]
                    inside_loop = !inside_loop
                end
                last_visited_angle = '.'
            elseif inside_loop == true && !(CartesianIndex(i,j) ∈ visited) 
                filled+=1
            end
            if input[i,j] ∈ ['|','J','7','F','L'] && (CartesianIndex(i,j) ∈ visited)
                last_visited_angle = input[CartesianIndex(i,j)]
            end
        end
    end
    return filled
end

function calculate_furthest(input)
    visited = traverse(input)
    return length(visited) ÷ 2
end

input = file_to_matrix("input.txt")

println("The result to pt 1 is $(calculate_furthest(input))")

println("The result to pt 2 is $(determine_area(input,traverse(input)))")
