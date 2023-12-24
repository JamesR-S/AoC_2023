cd(@__DIR__)
using Combinatorics
using LinearAlgebra

function parse_input(path)
    input = readlines(path)
    vectors = []
    for line in input
        matches = match(r"^(\d+),\s+(\d+),\s+(\d+)\s+@\s+(-?\d+),\s+(-?\d+),\s+(-?\d+)$", line).captures
        vector = (xt = parse(Int,matches[1]),xs = parse(Int,matches[4]),yt = parse(Int,matches[2]), ys = parse(Int,matches[5]),zt = parse(Int,matches[3]),zs = parse(Int,matches[6]))
        push!(vectors,vector)
    end
    return vectors
end

function find_parametric_intersection(v1, v2)

    x1, a1, y1, b1 = v1
    x2, a2, y2, b2 = v2

    A = [v1.xs -v2.xs; v1.ys -v2.ys]
    b = [v2.xt - v1.xt; v2.yt - v1.yt]

    if det(A) == 0
        return 0
    end

    solution = A \ b
    s, t = solution
    intersection = (x1 + a1 * s, y1 + b1 * s)
    return (200000000000000 < intersection[1] < 400000000000000) && (200000000000000 < intersection[2] < 400000000000000 && s > 0 && t > 0)
end

function count_collisions(input)
    pair_combinations = collect(combinations(input, 2))
    n=0
    for pair in pair_combinations
        n += find_parametric_intersection(pair[1], pair[2])
    end
    return n
end


function crossMatrix(v)
    return [0 -v[3] v[2];
            v[3] 0 -v[1];
            -v[2] v[1] 0]
end

function intersect_vec_init_pos(input)
    matrix = zeros(6, 6)
    right_side = zeros(6)


    # Set up the system
    right_side[1:3] = -cross([input[1].xt,input[1].yt,input[1].zt], [input[1].xs,input[1].ys,input[1].zs]) + cross([input[2].xt,input[2].yt,input[2].zt], [input[2].xs,input[2].ys,input[2].zs])
    right_side[4:6] = -cross([input[1].xt,input[1].yt,input[1].zt], [input[1].xs,input[1].ys,input[1].zs]) + cross([input[3].xt,input[3].yt,input[3].zt], [input[3].xs,input[3].ys,input[3].zs])
    matrix[1:3, 1:3] = crossMatrix([input[1].xs,input[1].ys,input[1].zs]) - crossMatrix([input[2].xs,input[2].ys,input[2].zs])
    matrix[4:6, 1:3] = crossMatrix([input[1].xs,input[1].ys,input[1].zs]) - crossMatrix([input[3].xs,input[3].ys,input[3].zs])
    matrix[1:3, 4:6] = -crossMatrix([input[1].xt,input[1].yt,input[1].zt]) + crossMatrix([input[2].xt,input[2].yt,input[2].zt])
    matrix[4:6, 4:6] = -crossMatrix([input[1].xt,input[1].yt,input[1].zt]) + crossMatrix([input[3].xt,input[3].yt,input[3].zt])

    # Solve the system
    Result = matrix \ right_side
    return Int(+(round(Result[1]),round(Result[2]),round(Result[3])))
end

input = parse_input("input.txt")

pt1_res = count_collisions(input)

pt2_res = intersect_vec_init_pos(input)

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)