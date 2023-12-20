cd(@__DIR__)

using DataStructures

function parse_input(path)
    input = readlines(path)
    nodes = Dict()
    for line in input
        features = Dict()
        parts = split(line, "->")
        src = strip(parts[1])
        dsts = Set(strip.(split(parts[2], ",")))
        
        # Determine the type and actual name of the source node
        src_type = startswith(src, "%") || startswith(src, "&") ? src[1] : "bc"
        src_name = src_type !== "bc" ? src[2:end] : src
        features["type"] = src_type
        features["memory"] = src_type == '%' ? false : src_type == '&' ? Dict() : nothing
        features["outputs"] = dsts
        features["low_sr"] = 0
        features["high_sr"] = 0
        nodes[src_name] = features
    end
    for (key, value) in nodes
        for dst in value["outputs"]
            if !haskey(nodes,dst)
                nodes[dst] = Dict("type" => "rec", "memory" => nothing, "outputs" => Set(), "low_sr" => 0,"high_sr" => 0)
            elseif nodes[dst]["type"] == '&'
                nodes[dst]["memory"][key] = 1
            end
        end
    end
    return nodes
end

function send_signal!(nodes,node,source,signal_type)
    queue = Queue{Any}()
    enqueue!(queue, (nodes,node,source,signal_type))
    while !isempty(queue)
        (nodes,node,source,signal_type) = dequeue!(queue)
        if signal_type == 1
            nodes[node]["low_sr"] +=1
        else
            nodes[node]["high_sr"] +=1
        end
        if nodes[node]["type"] == '%' && signal_type == 1
            nodes[node]["memory"] = !nodes[node]["memory"]
            signal_type = signal_type + nodes[node]["memory"]
            for dst in nodes[node]["outputs"]
                enqueue!(queue, (nodes,dst,node,signal_type))
            end
        elseif nodes[node]["type"] == '&'
            nodes[node]["memory"][source] = signal_type 
            if all(value -> value == 2, values(nodes[node]["memory"]))
                signal_type = 1
            else
                signal_type = 2
            end
            for dst in nodes[node]["outputs"]
                enqueue!(queue, (nodes,dst,node,signal_type))
            end
        elseif nodes[node]["type"] == "bc"
            for dst in nodes[node]["outputs"]
                enqueue!(queue, (nodes,dst,node,signal_type))
            end
        end
    end
end

function count_signals(nodes, n_presses)
    nodes_copy = deepcopy(nodes)
    for i in 1:n_presses
    send_signal!(nodes_copy,"broadcaster","button",1)
    end
    total_low = sum(get(node, "low_sr", 0) for node in values(nodes_copy))
    total_high = sum(get(node, "high_sr", 0) for node in values(nodes_copy))
    return total_high*total_low
end

function send_signal_pt2!(nodes,node,source,signal_type,i,all_collectors,first_occ,switched)
    queue = Queue{Any}()
    enqueue!(queue, (nodes,node,source,signal_type))
    while !isempty(queue)
        (nodes,node,source,signal_type) = dequeue!(queue)
        if signal_type == 1
            nodes[node]["low_sr"] +=1
        else
            nodes[node]["high_sr"] +=1
        end
        if nodes[node]["type"] == '%' && signal_type == 1
            nodes[node]["memory"] = !nodes[node]["memory"]
            signal_type = signal_type + nodes[node]["memory"]
            for dst in nodes[node]["outputs"]
                enqueue!(queue, (nodes,dst,node,signal_type))
            end
        elseif nodes[node]["type"] == '&'
            nodes[node]["memory"][source] = signal_type 
            if all(value -> value == 2, values(nodes[node]["memory"]))
                signal_type = 1
            else
                signal_type = 2
            end
            if node ∈ all_collectors && all(value -> value == 2, values(nodes[node]["memory"])) && first_occ[node] == 0
                first_occ[node] = i
                switched[node] = true
            end
            for dst in nodes[node]["outputs"]
                enqueue!(queue, (nodes,dst,node,signal_type))
            end
        elseif nodes[node]["type"] == "bc"
            for dst in nodes[node]["outputs"]
                enqueue!(queue, (nodes,dst,node,signal_type))
            end
        end
    end
end

function count_signals_pt2(nodes)
    feeder_node = [key for (key, value) in nodes if "rx" in value["outputs"]][1]
    all_collectors = [key for (key, value) in nodes if value["memory"] !== nothing && length(keys(value["memory"])) > 1 && value["type"] == '&']
    all_collectors = Set(filter(value -> value != feeder_node, all_collectors))
    switched = Dict()
    first_occ = Dict()
    for col in all_collectors
        switched[col] = false
        first_occ[col] = 0
    end
    nodes_copy = deepcopy(nodes)
    i = 0
    cols_to_del = []
    while any(value -> value != true, values(switched))
        i+=1
        send_signal_pt2!(nodes_copy,"broadcaster","button",1,i,all_collectors,first_occ,switched)
    end
    return lcm(values(first_occ)...)
end

nodes = parse_input("input.txt")

pt1_res = count_signals(nodes,1000)

pt2_res = count_signals_pt2(nodes)

println("The answer to part 1 is ",pt1_res)
println("The answer to part 2 is ",pt2_res)