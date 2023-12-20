# Runs in 4.1ms

cd(@__DIR__)

function card_scoring(line::String)
    winning,scratched = split(line,"|")
    winning_digits = [match.match for match in eachmatch(r"\d+", winning)][2:end]
    scratched_digits = [match.match for match in eachmatch(r"\d+", scratched)]
    n_matches = length(filter(value -> value ∈ winning_digits, scratched_digits))
    if n_matches > 0
        return 2^(n_matches-1)
    else
        return 0
    end
end

function card_scoring2!(counts::Array,index::Int,lines::Array)
    winning,scratched = split(lines[index],"|")
    winning_digits = [match.match for match in eachmatch(r"\d+", winning)][2:end]
    scratched_digits = [match.match for match in eachmatch(r"\d+", scratched)]
    n_matches = length(filter(value -> value ∈ winning_digits, scratched_digits))
    if n_matches > 0
        counts[(index+1):(index+n_matches)] .+= counts[index]
    end
end

function total_cards(lines::Array)
    cards = ones(Int32,length(lines))
    for i in 1:length(lines)
        card_scoring2!(cards,i,lines)
    end
    return sum(cards)
end

lines = readlines("input.txt")

pt1 = sum([card_scoring(line) for line in lines])

pt2 = total_cards(lines)

println("The answer to part 1 is $pt1")

println("The answer to part 2 is $pt2")