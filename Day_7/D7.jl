cd(@__DIR__)

function count_char(s)
    res = Dict{Char, Int}()
    for c in s
        res[c] = get(res, c, 0) + 1
    end
    return res
end

order_map = Dict('1'=>1, '2'=>2, '3'=>3, '4'=>4, '5'=>5, '6'=>6, '7'=>7, '8'=>8, '9'=>9, 'T'=>10, 'J'=>11, 'Q'=>12, 'K'=>13,'A'=>14)

function custom_compare(x, y)
    x_chars = collect(x[1])
    y_chars = collect(y[1])
    for (xc, yc) in zip(x_chars, y_chars)
        if order_map[xc] != order_map[yc]
            return order_map[xc] < order_map[yc]
        end
    end
    return length(x_chars) < length(y_chars)
end


function classify_hands(hands)
    sorted_hands = []
    kind5 = []
    kind4 = []
    full_house = []
    kind3 = []
    pair2 = []
    pair1 = []
    hc = []
    for hand in hands
        counts = count_char(hand[1])
        if length(filter(kv -> last(kv)==5,counts)) > 0
            push!(kind5,hand)
        elseif length(filter(kv -> last(kv)==4,counts)) > 0
            push!(kind4,hand)
        elseif length(filter(kv -> last(kv)==3,counts)) > 0
            if length(filter(kv -> last(kv)==2,counts)) > 0
                push!(full_house,hand)
            else
                push!(kind3,hand)
            end
        elseif length(filter(kv -> last(kv)==2,counts)) > 1
            push!(pair2,hand)
        elseif length(filter(kv -> last(kv)==2,counts)) > 0
            push!(pair1,hand)
        else
            push!(hc,hand)
        end
    end
    sorted_hands = vcat(sorted_hands,reverse(sort(kind5, by=x -> x, lt=custom_compare)))
    sorted_hands = vcat(sorted_hands,reverse(sort(kind4, by=x -> x, lt=custom_compare)))
    sorted_hands = vcat(sorted_hands,reverse(sort(full_house, by=x -> x, lt=custom_compare)))
    sorted_hands = vcat(sorted_hands,reverse(sort(kind3, by=x -> x, lt=custom_compare)))
    sorted_hands = vcat(sorted_hands,reverse(sort(pair2, by=x -> x, lt=custom_compare)))
    sorted_hands = vcat(sorted_hands,reverse(sort(pair1, by=x -> x, lt=custom_compare)))
    sorted_hands = vcat(sorted_hands,reverse(sort(hc, by=x -> x, lt=custom_compare)))
    return reverse(sorted_hands)
end

function scoring(sorted_hands)
    score=0
    for i in 1:length(hands)
        score+=(i*parse(Int32,sorted_hands[i][2]))
    end
    return score
end

order_map2 = Dict('J'=>1, '2'=>2, '3'=>3, '4'=>4, '5'=>5, '6'=>6, '7'=>7, '8'=>8, '9'=>9, 'T'=>10, 'Q'=>12, 'K'=>13,'A'=>14)

function custom_compare_pt2(x, y)
    for (xc, yc) in zip(x[1], y[1])
        if order_map2[xc] != order_map2[yc]
            return order_map2[xc] < order_map2[yc]
        end
    end
    return length(x[1]) < length(y[1])
end

function classify_hands_pt2(hands)
    sorted_hands = []
    kind5 = []
    kind4 = []
    full_house = []
    kind3 = []
    pair2 = []
    pair1 = []
    hc = []
    for hand in hands
        counts_all = count_char(hand[1])
        if length(filter(kv -> first(kv)=='J',counts_all)) > 0 && length(filter(kv -> first(kv)!='J',counts_all)) > 0
            counts_joker = counts_all['J']
            counts = filter(kv -> first(kv)!='J',counts_all)
            counts[findmax(counts)[2]] += counts_joker
        else
            counts=counts_all
        end
        if length(filter(kv -> last(kv)==5,counts)) > 0
            push!(kind5,hand)
        elseif length(filter(kv -> last(kv)==4,counts)) > 0
            push!(kind4,hand)
        elseif length(filter(kv -> last(kv)==3,counts)) > 0
            if length(filter(kv -> last(kv)==2,counts)) > 0
                push!(full_house,hand)
            else
                push!(kind3,hand)
            end
        elseif length(filter(kv -> last(kv)==2,counts)) > 1
            push!(pair2,hand)
        elseif length(filter(kv -> last(kv)==2,counts)) > 0
            push!(pair1,hand)
        else
            push!(hc,hand)
        end
    end
    sorted_hands = vcat(sorted_hands,reverse(sort(kind5, by=x -> x, lt=custom_compare_pt2)))
    sorted_hands = vcat(sorted_hands,reverse(sort(kind4, by=x -> x, lt=custom_compare_pt2)))
    sorted_hands = vcat(sorted_hands,reverse(sort(full_house, by=x -> x, lt=custom_compare_pt2)))
    sorted_hands = vcat(sorted_hands,reverse(sort(kind3, by=x -> x, lt=custom_compare_pt2)))
    sorted_hands = vcat(sorted_hands,reverse(sort(pair2, by=x -> x, lt=custom_compare_pt2)))
    sorted_hands = vcat(sorted_hands,reverse(sort(pair1, by=x -> x, lt=custom_compare_pt2)))
    sorted_hands = vcat(sorted_hands,reverse(sort(hc, by=x -> x, lt=custom_compare_pt2)))
    return reverse(sorted_hands)
end

hands = [split(i," ") for i in readlines("input.txt")]

sorted = classify_hands(hands)

println("The answer to pt 1 is $(scoring(sorted))")

sorted = classify_hands_pt2(hands)

println("The answer to pt 2 is $(scoring(sorted))")

