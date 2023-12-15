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

function find_dot_rows(matrix)
    return [i for i in 1:size(matrix, 1) if all(x -> x == '.', matrix[i, :])]
end

function find_dot_columns(matrix)
    return [j for j in 1:size(matrix, 2) if all(x -> x == '.', matrix[:, j])]
end

function find_pairwise_galaxies(matrix)
    galaxies = findall(x -> x=='#',matrix)
    sum_dist = 0
    for i in 1:(length(galaxies)-1)
        for j in (i+1):length(galaxies)
            sum_dist += manhattan(galaxies[i],galaxies[j])
        end
    end
    return sum_dist
end

function manhattan(X,Y,cols,rows,expansion)
    nr = sum([r ∈ minimum([X[1],Y[1]]):maximum([X[1],Y[1]]) for r in rows])*expansion
    nc = sum([c ∈ minimum([X[2],Y[2]]):maximum([X[2],Y[2]]) for c in cols])*expansion
    return abs(X[1]-Y[1])+abs(X[2]-Y[2])+nr+nc
end

function find_pairwise_galaxies(matrix,expansion)
    rows = find_dot_rows(matrix)
    cols = find_dot_columns(matrix)
    galaxies = findall(x -> x=='#',matrix)
    sum_dist = 0
    for i in 1:(length(galaxies)-1)
        for j in (i+1):length(galaxies)
            sum_dist += manhattan(galaxies[i],galaxies[j],cols,rows,expansion)
        end
    end
    return sum_dist
end

input = file_to_matrix("input.txt")

println("The answer to part 1 is ", find_pairwise_galaxies(input,1))

println("The answer to part 1 is ", find_pairwise_galaxies(input,999999))