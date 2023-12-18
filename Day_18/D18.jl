cd(@__DIR__)

using DataStructures

function parse_input(path)
    input = readlines(path)
    input_array = [[m[1][1], parse(Int, m[2]), m[3]] for i in input for m in eachmatch(r"^([A-Z]) (\d+) \((#\w+)\)$", i)]
    return input_array
end

function pt2_parse(input)
    pt2 = [[m[2]=="0" ? 'R' : m[2]=="1" ? 'D' : m[2]=="2" ? 'L' : 'U',parse(Int, m[1], base=16)] for i in input for m in eachmatch(r"^#(\w{5})(\d)", i[3])]
    return pt2
end

function find_vertices(input)
    perimiter = 0
    x = 1
    y = 1
    vertices = [(1,1)]
    for line in input
        x += line[1] == 'R' ? line[2] : line[1] == 'L' ? -line[2] : 0
        y += line[1] == 'D' ? line[2] : line[1] == 'U' ? -line[2] : 0
        append!(vertices,[(x,y)])
        perimiter+=line[2]
    end
    return vertices, perimiter
end

function shoelace(vertices,perimiter)
    n = length(vertices)
    area = 0.0

    for i in 1:(n-1)
        area += vertices[i][1] * vertices[i+1][2]
        area -= vertices[i+1][1] * vertices[i][2]
    end
    area = abs(area) / 2
    # Add the last vertex to the first vertex calculatio

    return area + perimiter/2 +1
end

input = parse_input("input.txt")

vertices,perimiter = find_vertices(input)

pt1_res = Int(shoelace(vertices,perimiter))

input_pt2 = pt2_parse(input)

vertices,perimiter = find_vertices(input_pt2)

pt2_res = Int(shoelace(vertices,perimiter))

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)