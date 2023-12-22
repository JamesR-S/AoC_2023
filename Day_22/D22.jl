
cd(@__DIR__)
using DataStructures

mutable struct Brick
    id::Int
    x_start::Int
    y_start::Int
    z_start::Int
    x_end::Int
    y_end::Int
    z_end::Int
end

function read_bricks(file_name)
    bricks = Brick[]
    id = 1
    for line in readlines(file_name)
        coords = split(line, ['~', ','])
        push!(bricks, Brick(id, parse.(Int, coords)...))
        id += 1
    end
    sort!(bricks, by = b -> b.z_start)
    return bricks
end

function apply_gravity!(bricks::Vector{Brick})
    sort!(bricks, by = b -> b.z_start)

    for i in 1:length(bricks)
        current_brick = bricks[i]
        original_height = current_brick.z_end - current_brick.z_start

        min_z = 1
        for j in 1:i-1  
            if overlap(current_brick, bricks[j])
                min_z = max(min_z, bricks[j].z_end + 1)
            end
        end

        current_brick.z_start = min_z
        current_brick.z_end = min_z + original_height  
        bricks[i] = current_brick
    end
end

function overlap(brick1::Brick, brick2::Brick)
    x_overlap = length(collect(intersect(brick1.x_start:brick1.x_end,brick2.x_start:brick2.x_end))) > 0
    y_overlap = length(collect(intersect(brick1.y_start:brick1.y_end,brick2.y_start:brick2.y_end))) > 0
    return x_overlap && y_overlap
end

function find_critical_bricks(bricks::Vector{Brick})
    critical_bricks = Set{Int}()
    
    sorted_bricks = sort(bricks, by = b -> -b.z_end)

    for upper_brick in sorted_bricks
        supporting_bricks = []

        for lower_brick in bricks
            if is_beneath(upper_brick, lower_brick)
                push!(supporting_bricks, lower_brick.id)
            end
        end

        if length(supporting_bricks) == 1
            push!(critical_bricks, supporting_bricks[1])
        end
    end

    return critical_bricks
end

function is_beneath(upper_brick::Brick, lower_brick::Brick)
    x_overlap = !(upper_brick.x_end < lower_brick.x_start || upper_brick.x_start > lower_brick.x_end)
    y_overlap = !(upper_brick.y_end < lower_brick.y_start || upper_brick.y_start > lower_brick.y_end)
    vertical_alignment = upper_brick.z_start - 1 == lower_brick.z_end

    return x_overlap && y_overlap && vertical_alignment
end

function build_support_map(bricks::Vector{Brick})
    support_map = DefaultDict{Int, Set{Int}}(Set)

    for lower_brick in bricks
        for upper_brick in bricks
            if lower_brick.id != upper_brick.id && is_beneath(upper_brick, lower_brick)
                push!(support_map[lower_brick.id], upper_brick.id)
            end
        end
    end

    return support_map
end

function calculate_impact(brick_id::Int, support_map::DefaultDict{Int, Set{Int}})
    temp_support_map = deepcopy(support_map)

    support_count = Dict{Int, Int}()
    for (supporter, supported_set) in temp_support_map
        for supported in supported_set
            support_count[supported] = get(support_count, supported, 0) + 1
        end
    end

    function simulate_removal(id::Int)
        total_removed = 0
        bricks_to_remove = Set([id])

        while !isempty(bricks_to_remove)
            current_id = pop!(bricks_to_remove)
            total_removed += 1

            for supported in temp_support_map[current_id]
                support_count[supported] -= 1
                if support_count[supported] == 0
                    push!(bricks_to_remove, supported)
                end
            end
            delete!(temp_support_map, current_id)  
        end

        return total_removed
    end

    return simulate_removal(brick_id) - 1  
end

function sum_falling_bricks(critical_bricks,support_map)
    tot = 0 
    for i in critical_bricks
        tot += calculate_impact(i,support_map)
    end
    return tot
end

function pt1(path)

    bricks = read_bricks(path)

    apply_gravity!(bricks)
    
    critical_bricks =find_critical_bricks(bricks)

    pt1_res = length(bricks) - length(critical_bricks)

    
    return pt1_res, bricks, critical_bricks
end


function pt2(bricks, critical_bricks)
    support_map = build_support_map(bricks)

    return sum_falling_bricks(critical_bricks,support_map)
end


pt1_res, bricks, critical_bricks = pt1("input.txt")

pt2_res = pt2(bricks, critical_bricks)

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)