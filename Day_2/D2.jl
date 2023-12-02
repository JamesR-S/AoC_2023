# Runs in 784.071 μs
lines = readlines("/Users/james/Documents/AoC/AoC_2023/Day_2/input.txt")

mutable struct cubes
    red::Int32
    green::Int32
    blue::Int32
end

function count_cubes(game::String)
    count = cubes(0,0,0)
    strings = split(game,";")
    reds=[0]
    greens=[0]
    blues=[0]

    for string in strings
        red = [match.match for match in eachmatch(r"\d+ red", string)]
        green = [match.match for match in eachmatch(r"\d+ green", string)]
        blue = [match.match for match in eachmatch(r"\d+ blue", string)]
        if length(red) > 0
            push!(reds, sum([parse(Int32,filter(isdigit,r)) for r in red]))
        end
        if length(green) > 0
            push!(greens, sum([parse(Int32,filter(isdigit,g)) for g in green]))
        end
        if length(blue) > 0
            push!(blues, sum([parse(Int32,filter(isdigit,b)) for b in blue]))
        end
    end    
    count.red = findmax(reds)[1]
    count.green = findmax(greens)[1]
    count.blue = findmax(blues)[1]
    return count
end

function possible(games::Array,limit::cubes)
    n_possible = 0
    index= 0
    for game in games
        index+=1
        if (game.red <= limit.red) & (game.green <= limit.green) & (game.blue <= limit.blue)
            n_possible +=index
        end
    end
    return(n_possible)
end

function powersum(games::Array)
    power = 0 
    for game in games
        power += (game.red*game.green*game.blue)
    end
    return power
end

max_cubes = [count_cubes(line) for line in lines]

possible_games = possible(max_cubes,cubes(12,13,14))

sum_of_powers = powersum(max_cubes)

println("The answer to part one is $possible_games")

println("The answer to part two is $sum_of_powers")
