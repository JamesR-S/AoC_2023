
lines = readlines("/Users/james/Documents/AoC/AoC_2023/Day_6/input.txt")

races = zip([parse(Int16,match.match) for match in eachmatch(r"\d+", lines[1])],[parse(Int16,match.match) for match in eachmatch(r"\d+", lines[2])])

races2 = [parse(Int32,join([match.match for match in eachmatch(r"\d+", lines[1])])),parse(Int64,join([match.match for match in eachmatch(r"\d+", lines[2])]))]



function equation(x, n)
    return x * (n - x)
end

function solver(races)
    array_lengths = []
    for i in races
        satisfying_integers = filter(x -> equation(x, i[1]) > i[2], 1:(i[1]-1))
        push!(array_lengths, length(satisfying_integers))
    end
    println(array_lengths)
    return prod(array_lengths)
end

solver(races)

function quadratic(a, b, c)
    discr = b^2 - 4*a*c
    sq = (discr > 0) ? sqrt(discr) : sqrt(discr + 0im)
    [(-b - sq)/(2a), (-b + sq)/(2a)]
end


function pt2_binom(races2)
    floor(abs(quadratic(1,races2[1],races2[2])[1]))-ceil(abs(quadratic(1,races2[1],races2[2])[2])) + 1
end
using Printf
pt2_res = pt2_binom(races2)
@printf "%f\n" pt2_res

races2