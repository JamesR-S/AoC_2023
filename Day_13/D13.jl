cd(@__DIR__)

function string_to_matrix(string)
    lines = split(strip(string, '\n'),"\n")

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

function read_input(path)
    input = read(path, String)
    matrices = [string_to_matrix(i) for i in split(strip(input, '\n'),"\n\n")]
    return matrices
end

function find_symmetry_line(matrix)
    for line in 1:(size(matrix)[2]-1)
        if line <= (size(matrix)[2]/2)
            left_pane = matrix[:,1:line]
            right_pane = matrix[:,(line*2):-1:(line+1)]
            if left_pane == right_pane
                return line
            end
        else
            left_pane = matrix[:,(line-(size(matrix)[2]-line)+1):line]
            right_pane = matrix[:,end:-1:(line+1)]
            if left_pane == right_pane
                return line
            end
        end
    end
    return find_symmetry_line(permutedims(matrix))*100
end

function find_symmetry_line_pt2(matrix)
    for line in 1:(size(matrix)[2]-1)
        if line <= (size(matrix)[2]/2)
            left_pane = matrix[:,1:line]
            right_pane = matrix[:,(line*2):-1:(line+1)]
            if sum(left_pane .!= right_pane) == 1
                return line
            end
        else
            left_pane = matrix[:,(line-(size(matrix)[2]-line)+1):line]
            right_pane = matrix[:,end:-1:(line+1)]
            if sum(left_pane .!= right_pane) == 1
                return line
            end
        end
    end
    return find_symmetry_line_pt2(permutedims(matrix))*100
end

function get_sum_symmetry(matrices)
    total=0
    for matrix in matrices
        total += find_symmetry_line(matrix)
    end
    return total
end

function get_sum_symmetry_pt2(matrices)
    total=0
    for matrix in matrices
        total += find_symmetry_line_pt2(matrix)
    end
    return total
end

matrices = read_input("input.txt")

println("The answer to part 1 is ", get_sum_symmetry(matrices))
println("The answer to part 2 is ", get_sum_symmetry_pt2(matrices))