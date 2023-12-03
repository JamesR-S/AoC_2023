#Runs in 146.003 ms

mutable struct numbercoords
    x::Int16
    y_start::Int16
    y_end::Int16
    value::Int16
    counted::Bool
end

mutable struct symbolcoords
    x::Int16
    y::Int16
    adjacent_n::Int16
    ratio::Int32
    is_gear::Bool
end

function file_to_matrix(filename)
    file_content = read(filename, String)
    lines = split(file_content, '\n')

    while !isempty(lines) && all(isspace, lines[end])
        pop!(lines)
    end

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

function find_numbers(matrix::Matrix)
    last_pos_n=false
    numbers=[]
    num_start=nothing
    for row in 1:size(matrix)[1]
        for col in 1:size(matrix)[2]
            current_pos=matrix[row,col]
            if !last_pos_n && isdigit(current_pos)
                num_start=col
                last_pos_n=true
            elseif last_pos_n && !isdigit(current_pos)
                push!(numbers,numbercoords(row,num_start,(col-1),parse(Int32,join(matrix[row,num_start:(col-1)])),false))
                last_pos_n=false
            elseif last_pos_n && col==size(matrix)[2]
                push!(numbers,numbercoords(row,num_start,(col),parse(Int32,join(matrix[row,num_start:(col)])),false))
                last_pos_n=false
            end
        end
    end
    return numbers
end

function find_symbols(matrix::Matrix)
    symbols=[]
    for row in 1:size(matrix)[1]
        for col in 1:size(matrix)[2]
            current_pos=matrix[row,col]
            if !isdigit(current_pos) && !(current_pos=='.')
                push!(symbols,symbolcoords(row,col,0,1,current_pos=='*'))
            end
        end
    end
    return symbols
end

function adjacent_numbers!(symbols,numbers)
    for symbol in symbols
        for num in 1:length(numbers)
            number=numbers[num]
            if (symbol.x ∈ (number.x-1):(number.x+1)) && (symbol.y ∈ (number.y_start-1):(number.y_end+1))
                numbers[num].counted=true
                if symbol.is_gear
                    symbol.adjacent_n +=1
                    symbol.ratio *= number.value
                end
            end
        end
    end
end

input = file_to_matrix("/Users/james/Documents/AoC/AoC_2023/Day_3/input.txt")

numbers = find_numbers(input)

symbols = find_symbols(input)

adjacent_numbers!(symbols,numbers)

println("The answer to part 1 is $(sum([number.value for number in filter(nc -> nc.counted, numbers)]))")

println("The answer to part 2 is $(sum([symbol.ratio for symbol in filter(sym -> sym.adjacent_n==2, symbols)]))")