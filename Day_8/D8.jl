cd(@__DIR__)

struct node
    left::String
    right::String
end
function file_blocks(filename::String)
    # Read the entire file content
    file_content = read(filename, String)

    # Split the content into blocks separated by empty lines
    blocks = [strip(f) for f in split(file_content, "\n\n")]

    return blocks
end

function parse_nodes!(line,dict)
    nodelist = [match.match for match in eachmatch(r"\w+", line)]
    dict[nodelist[1]] = node(nodelist[2],nodelist[3])
end

function build_network(input)
    mapping = Dict([])
    for line in split(input,"\n")
        parse_nodes!(line,mapping)
    end
    return mapping
end

function traverse(directions, nodes)
    current_node = "AAA"
    steps = 0
    while current_node != "ZZZ"
        for direction in directions
            steps+=1
            if direction == 'L'
                current_node = nodes[current_node].left
            else
                current_node = nodes[current_node].right
            end
            if current_node == "ZZZ"
                break
            end
        end
    end
    return steps
end

function traverse_pt2(directions, nodes, current_node)
    steps = 0
    while current_node[3] != 'Z'
        for direction in directions
            steps+=1
            if direction == 'L'
                current_node = nodes[current_node].left
            else
                current_node = nodes[current_node].right
            end
            if current_node[3] == 'Z'
                break
            end
        end
    end
    return steps
end

directions = file_blocks("input.txt")[1]

mapping = build_network(file_blocks("input.txt")[2])

pt1 = traverse(directions,mapping)

pt2 = lcm([traverse_pt2(directions,mapping,start) for start in filter(key -> key[3] =='A', collect(keys(mapping)))])

println("The result to pt 1 is $pt1")

println("The result to pt 2 is $pt2")