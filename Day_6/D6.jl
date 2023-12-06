using Printf
cd(@__DIR__)

function quadratic(a, b, c)
    discr = b^2 - 4*a*c
    sq = (discr > 0) ? sqrt(discr) : sqrt(discr + 0im)
    [(-b - sq)/(2a), (-b + sq)/(2a)]
end

function binom_solver(races)
    floor(abs(quadratic(1,races[1],races[2])[1]))-ceil(abs(quadratic(1,races[1],races[2])[2])) + 1
end

function pt1_solver(races)
    array_lengths = []
    for i in races
        push!(array_lengths, binom_solver(i))
    end
    return prod(array_lengths)
end

lines = readlines("input.txt")

races = zip([parse(Int16,match.match) for match in eachmatch(r"\d+", lines[1])],[parse(Int16,match.match) for match in eachmatch(r"\d+", lines[2])])

races2 = [parse(Int32,join([match.match for match in eachmatch(r"\d+", lines[1])])),parse(Int64,join([match.match for match in eachmatch(r"\d+", lines[2])]))]

pt1_res = pt1_solver(races)
pt2_res = binom_solver(races2)


print("The answer to pt 1 is ")
@printf "%i\n" pt1_res


print("The answer to pt 2 is ")
@printf "%i\n" pt2_res