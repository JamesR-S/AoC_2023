using Memoize
cd(@__DIR__)
@memoize function calc(record::Union{String, SubString{String}}, groups::Tuple{Vararg{Int}})
    # Base cases
    if isempty(groups)
        return occursin("#", record) ? 0 : 1
    elseif isempty(record)
        return 0
    end

    next_character = record[1]
    next_group = groups[1]

    function pound()
        if length(record) < next_group
            return 0
        end

        this_group = record[1:next_group]
        this_group = replace(this_group, "?" => "#")

        if this_group != "#"^next_group
            return 0
        end

        if length(record) == next_group
            return length(groups) == 1 ? 1 : 0
        end

        if next_group < length(record) && record[next_group + 1] in ['?', '.']
            return calc(record[next_group + 2:end], groups[2:end])
        end

        return 0
    end

    function dot()
        if length(record) > 1
            return calc(record[2:end], groups)
        else
            return 0
        end
    end

    if next_character == '#'
        return pound()
    elseif next_character == '.'
        return dot()
    elseif next_character == '?'
        return dot() + pound()
    else
        throw(RuntimeError("Unexpected character encountered"))
    end
end

function process_input(file_path::String)
    raw_file = read(file_path, String)
    raw_file = strip(raw_file)

    output = 0

    for entry in split(raw_file, "\n")
        record, raw_groups = split(entry)
        groups = parse.(Int, split(raw_groups, ','))
        output += calc(record, Tuple(groups))
    end

    return output
end

function process_input_pt2(file_path::String)
    raw_file = read(file_path, String)
    raw_file = strip(raw_file)

    output = 0

    for entry in split(raw_file, "\n")
        record, raw_groups = split(entry)
        
        record = join(fill(record, 5), "?")
        
        raw_groups = join(fill(raw_groups, 5), ",")
        
        groups = parse.(Int, split(raw_groups, ','))
        output += calc(record, Tuple(groups))
    end

    return output
end

input_file = "input.txt"
println("The answer to part 1 is ", process_input(input_file))
println("The answer to part 2 is ", process_input_pt2(input_file))
