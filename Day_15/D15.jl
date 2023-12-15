cd(@__DIR__)

using DataStructures

function read_input(path)
    input = read(path, String)
    input = [i for i in split(strip(input, '\n'),",")]
    return input
end

function hashing(string)
    value = 0
    for char in string
        value += Int(char)
        value = value * 17
        value = value % 256
    end
    return value
end

function value_sum(input)
   return sum([hashing(string) for string in input]) 
end

function fill_boxes(input)
    boxes = [OrderedDict() for _ in 1:256]
    for string in input
        ID = [x.match for x in eachmatch(r"[a-z]+", string)][1]
        box = hashing(ID) + 1
        if string[end] == '-' && haskey(boxes[box],ID)
            delete!(boxes[box],ID)
        elseif string[end] != '-'
            boxes[box][ID] = parse(Int16,string[end])
        end
    end
    total_focus = 0
    for i in 1:256
        if length(boxes[i]) > 0
            keys = [k for k in Base.keys(boxes[i])]
            for j in 1:length(boxes[i])
                total_focus += (i*j*boxes[i][keys[j]])
            end
        end
    end
    return total_focus
end


input = read_input("input.txt")
println("The answer to part 1 is $(value_sum(input))")
println("The answer to part 2 is $(fill_boxes(input))")
