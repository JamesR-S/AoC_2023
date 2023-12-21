#Runs in 13.86 ms

cd(@__DIR__)

struct substrate_map
    source::String
    dest::String
    ranges::UnitRange
    t::Int64
end

mutable struct item_value
    type::String
    value::Int64
    valid::Bool
end

mutable struct item_range
    type::String
    value::UnitRange
end

function file_blocks(filename::String)
    # Read the entire file content
    file_content = read(filename, String)

    # Split the content into blocks separated by empty lines
    blocks = [strip(f) for f in split(file_content, "\n\n")]

    return blocks
end

function transformations(mapping)
    maps=[]
    for obj_map in mapping
        map_items = split(obj_map,"\n")
        source, dest = [match.match for match in eachmatch(r"[a-z]+", map_items[1])][[1,3]]
        for ranges in map_items[2:end]
            values = [parse(Int64,match.match) for match in eachmatch(r"\d+", ranges)]
            source_range = values[2]:(values[2]+values[3]-1)
            t_value = values[1]-values[2]
            push!(maps,substrate_map(source,dest,source_range,t_value))
        end
    end
    return maps
end

function seed_ranges(seeds)
    seed_ranges=[]
    for i in [ i for i in 1:length(seeds) if i%2==1 ]
        push!(seed_ranges,item_range("seed",seeds[i]:(seeds[i]+seeds[(i+1)]-1)))
    end
    return seed_ranges
end

function value_pipe_pt1!(seeds)
    for seed in seeds
        while seed.type != "location" && seed.valid
            map_match = filter(s_map -> (seed.type == s_map.source && (seed.value ∈ s_map.ranges)), s_maps)
            if length(map_match) > 0
                seed.type = map_match[1].dest
                seed.value += map_match[1].t
            else
                seed.valid = false
            end
        end
    end
end

function value_pipe_pt2!(seeds)
    i=0
    while i < length(seeds)
        i+=1
            map_match = filter(s_map -> (seeds[i].type == s_map.source), s_maps)
            if length(map_match) > 0
                for match in map_match
                    overlap = intersect(seeds[i].value, match.ranges)
                    if first(overlap) <= last(overlap)
                        push!(seeds, item_range(match.dest,(first(overlap)+match.t):(last(overlap)+match.t)))
                    end
                end
            end
    end
end

seeds_pt1 = [item_value("seed",parse(Int64,match.match),true) for match in eachmatch(r"\d+", file_blocks("/Users/james/Documents/AoC/AoC_2023/Day_5/input.txt")[1])]

seeds_pt2 = seed_ranges([parse(Int64, match.match) for match in eachmatch(r"\d+", file_blocks("/Users/james/Documents/AoC/AoC_2023/Day_5/input.txt")[1])])

mapping = file_blocks("/input.txt")[2:end]

s_maps = transformations(mapping)

value_pipe_pt1!(seeds_pt1)

value_pipe_pt2!(seeds_pt2)

println("The answer to part 1 is $(minimum([s.value for s in filter(seed -> seed.type =="location",seeds_pt1)]))")

println("The answer to part 2 is $(minimum([first(i.value) for i in filter(st -> st.type=="location",seeds_pt2)]))")