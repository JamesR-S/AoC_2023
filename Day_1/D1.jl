# Runs in 3.8ms

cd(@__DIR__)

lines = readlines("input.txt")

function firstlast_digits(x)
    digits = [match.match for match in eachmatch(r"\d", x)]
    return parse(Int32,digits[1]*digits[end])
end

println("The answer to part one is $(sum([firstlast_digits(line) for line in lines]))")

function replace_numbers(x)
    x = replace(x, "one" => "one1one")
    x = replace(x, "two" => "two2two")
    x = replace(x, "three" => "three3three")
    x = replace(x, "four" => "four4four")
    x = replace(x, "five" => "five5five")
    x = replace(x, "six" => "six6six")
    x = replace(x, "seven" => "seven7seven")
    x = replace(x, "eight" => "eight8eight")
    x = replace(x, "nine" => "nine9nine")
    return x
end

println("The answer to part two is $(sum([firstlast_digits(replace_numbers(line)) for line in lines]))")