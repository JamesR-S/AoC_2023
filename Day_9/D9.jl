cd(@__DIR__)

lines = [parse.(Int32, x) for x in [split(line," ") for line in readlines("input.txt")]]

function next_element(line)
    diffs = diff(line)
    if all(diff(diffs) .== 0)
        return line[end]+diffs[end]
    else
        return line[end]+next_element(diffs)
    end
end

pt1 = sum([next_element(line) for line in lines])

pt2 = sum([next_element(reverse(line)) for line in lines])

println("The result to pt 1 is $pt1")

println("The result to pt 2 is $pt2")
