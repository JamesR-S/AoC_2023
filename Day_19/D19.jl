cd(@__DIR__)
using .Threads


function parse_to_conditions(s)
    parts = split(s, ',')
    conditions = []

    for part in parts
        condition_result = split(part, ':')
        if length(condition_result) == 2
            condition, result = condition_result
            push!(conditions, (condition, result))
        else
            # For the last default value
            default_result = condition_result[1]
            push!(conditions, (nothing, default_result))
        end
    end

    return conditions
end

function store_ternaries(ternaries::Vector{SubString{String}})
    ternary_cond_dict = Dict()
    for ternary in ternaries
        # Use regex to extract the name and the ternary expression
        matched = match(r"(\w+)\{(.+)\}", ternary)
        if matched !== nothing
            name = matched.captures[1]
            conditions = parse_to_conditions(matched.captures[2])

            # Store in dictionary
            ternary_cond_dict[name] = conditions
        end
    end

    return ternary_cond_dict
end

function file_parse(path::String)
    # Read the entire file content
    file_content = read(path, String)

    # Split the content into blocks separated by empty lines
    blocks = [strip(f) for f in split(file_content, "\n\n")]
    
    parts = [(x = parse(Int16,m[1]), m = parse(Int16,m[2]), a = parse(Int16,m[3]), s = parse(Int16,m[4])) for i in split(blocks[2],"\n") for m in eachmatch(r"{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}",i)]
    conditions = store_ternaries(split(blocks[1],"\n"))

    return conditions,parts 
end


function eval_cond(nt,condition,conditions)
    for cond in conditions[condition]
        if cond[1] != nothing
            key,op, cond_value = match(r"([a-z])([<>]=?)(\d+)", cond[1]).captures
            key=Symbol(key)
            cond_value = parse(Int, cond_value)
            nt_value = getproperty(nt, key)
            if (op == "<" && nt_value<cond_value) || (op == ">" && nt_value>cond_value)
                if cond[2]== "A"
                    return sum(nt)
                elseif cond[2] != "R"
                    return eval_cond(nt,cond[2],conditions)
                end
                break               
            end
        else
            if cond[2]== "A"
                return sum(nt)
            elseif cond[2] != "R"
                return eval_cond(nt,cond[2],conditions)
            end
        end
    end
end

function sort_parts(parts, conditions)
    n_parts = Threads.Atomic{Int}(0)
    @threads for part in parts
        local_sum = eval_cond(part,"in",conditions) 
        if local_sum != nothing
            Threads.atomic_add!(n_parts, local_sum)
        end
    end
    return n_parts[]
end

function split_range(range_tuple, condition_str)
    # Parse the condition string
    key,op, value = match(r"([a-z])([<>]=?)(\d+)", condition_str).captures
    value = parse(Int, value)
    key = Symbol(key)
    # Create lambda functions based on the condition
    range = getproperty(range_tuple, key)
    start, stop = first(range), last(range)
    if op == "<"
        first_range,second_range = start:min(value - 1, stop), max(value, start):stop
    else
        first_range,second_range = max(value + 1, start):stop, start:min(value, stop)
    end
    filtered_pairs = [(k => v) for (k, v) in pairs(range_tuple) if k ≠ key]
    # Create a new named tuple from the filtered pairs
    filtered_nt = NamedTuple(filtered_pairs)
    new_tuple_1 = merge(filtered_nt,NamedTuple{(key,)}((first_range,)))
    new_tuple_2 = merge(filtered_nt,NamedTuple{(key,)}((second_range,)))
    return new_tuple_1, new_tuple_2
end

function range_process(nt,condition,conditions,accepted_ranges)
    for cond in conditions[condition]
        if cond[1] != nothing
            nt_res,nt = split_range(nt,cond[1])
            if cond[2]== "A"
                push!(accepted_ranges,nt_res)
            elseif cond[2] != "R"
                range_process(nt_res,cond[2],conditions,accepted_ranges)
            end
        else
            if cond[2]== "A"
                push!(accepted_ranges,nt)
            elseif cond[2] != "R"
                range_process(nt,cond[2],conditions,accepted_ranges)
            end
        end
    end
end

function calculate_possible_ranges(conditions)
    accepted_ranges=[]
    initial_tuple = (x=1:4000,m=1:4000,a=1:4000,s=1:4000)
    range_process(initial_tuple,"in",conditions,accepted_ranges)
    return sum([length(nt.x)*length(nt.m)*length(nt.a)*length(nt.s) for nt in accepted_ranges])
end

conditions, parts = file_parse("input.txt")

pt1_res = sort_parts(parts,conditions)

pt2_res = calculate_possible_ranges(conditions)

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)