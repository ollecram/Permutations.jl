"""
    MyUtils

    Module for generic utility functions.
"""
module MyUtils

"""
        overlap(a1, a2)
        a1 and a2 must be vectors with element type a subtype of Integer
        return true iff the same integer value is found in both vectors
"""
function overlap(a1::Vector{<:Integer}, a2::Vector{<:Integer})::Bool
    overlap = false
    for val in a1
        t = a2 .== val
        if sum(t) > 0
            overlap = true
            break
        end
    end
    return overlap
end # overlap()

"""
    isless(a1, a2)
    a1 and a2 must be vectors of same length with element type a subtype of Integer
    return true iff 'lexicographycally, a1 < a2 
"""
function isless(a1::Vector{<:Integer}, a2::Vector{<:Integer})::Bool
    pass = true
    if length(a1) != length(a2)
        error("The input vectors must have the same length. Found $(length(a1)) and $(length(a2)).") 
    end

    for i in 1:lastindex(a1)
        if a1[i] >= a2[i]
            pass = false
            break
        end
    end

    return pass

end # isless()

"""
    isvalid_plain_representation(plain_p)

    Test whether the input vector of integers qualifies 
    as the plain representation of a permutation. 

"""
function isvalid_plain_representation(plain_p::Vector{<:Integer})
    n = length(plain_p)
    if n==0 
        return false
    end        
    
    if minimum(plain_p) != 1 
        return false
    end

    if maximum(plain_p) != n 
        return false
    end

    psum_test = Base.iseven(n) ? (n * (n+1))/2 : (n+1)*(n-1)/2 + (n+1)/2
    if (sum(plain_p) != psum_test) 
        return false
    end

    true
end # isvalid_plain_representation()

"""
    isvalid_cycle_representation(cycle_p)

    Test whether the input vector of integers qualifies 
    as the valid representation of a permutation's cycles. 

"""
function isvalid_cycle_representation(cycle_p::Vector{Vector{T}} where{T <: Integer}) 
    r = reduce(vcat, cycle_p)
    # Caveat! r[] is NOT the plain equivalent of cycle_p[],
    #         however, it will pass the test for being a valid plain representation of a 
    #         permutation p if and only if cycle_p is a valid cycle representation of it.  
    isvalid_plain_representation(r)
end # isvalid_cycle_representation()


"""
    plain_to_cycle(plain_p)

    Convert from the plain representation of a permutation p to its cycle representation 
"""
function plain_to_cycle(plain_p::Vector{T})::Vector{Vector{T}} where{T <: Integer}
    if !isvalid_plain_representation(plain_p)
        error("The input vector 'p' is not a valid plain representation of a permutation.")
    end

    # Work in the same integer representation used for the input plain representation
    intType = eltype(plain_p)

    # Create a copy of the input plain_p vector to keep track of elements still not part of a cycle
    _copy = copy(plain_p)

    n = length(plain_p)  
    
    # Prepare the (empty) vector to hold cycles of the alternative representation
    cycle_p = Vector{Vector{intType}}(undef, 0)

    # Here we assume n < typemax(intType). Of course, is is not an issue, since surely n << 255
    max_type_val = typemax(intType)

    # Instantiate the 1st cycle
    cycle = Vector{intType}(undef, 0)
    push!(cycle, intType(1))            # Note that 1st cycle is the one which contains the integer '1'
    next = _copy[1]                     # The next in cycle in a cycle starting with 1 is just _copy[1]
    _copy[1] = max_type_val             # This assures that '1' will never be inserted again in any cycle

    total_moved = 0
    
    while true
        if next != cycle[1]
            # Keep filling the current cycle
            push!(cycle, next)
            next = _copy[cycle[end]]
            _copy[cycle[end]] = max_type_val   # This assures that 'next' will never be inserted again in a cycle
            continue
        else
            # Add the complete cycle to cycle_p
            push!(cycle_p, cycle)
            total_moved += length(cycle)
            if (total_moved == n)
                break
            else
                # Start a new cycle with the least element still not part of a cycle
                cycle = Vector{intType}(undef, 0)
                # Start each new cycle with the least element that is not part of previous cycles
                minValue, indexof_min = findmin(_copy)
                push!(cycle, minValue)
                next = _copy[minValue] 
                _copy[minValue] = max_type_val   # This assures that 'next' will never be inserted again in a cycle
                continue
            end 
        end
    
    end # while true     
    
    # println("***\ttypeof(plain_p): $(typeof(plain_p))\n\t plain_p: $(plain_p)")
    # println("***\ttypeof(cycle_p): $(typeof(cycle_p))\n\t cycle_p: $(cycle_p)")

    return cycle_p
end # plain_to_cycle()


"""
    cycle_to_plain(cycle_p)

    Convert from the cycle representation of a permutation p to its plain representation 
"""
function cycle_to_plain(cycle_p::Vector{Vector{T}})::Vector{T} where{T <: Integer}
    if !isvalid_cycle_representation(cycle_p)
        error("The input vector of vectors 'cycle_p' is not a valid cycle representation of a permutation.")
    end

    intType = eltype(cycle_p[1])
    n = length(reduce(vcat, cycle_p))

    plain_p = Vector{intType}(undef, n)

    for cycle in 1:length(cycle_p)
        cyclength = length(cycle_p[cycle])
        for i in 1:cyclength
            perm_source = cycle_p[cycle][i] 
            perm_target = i == cyclength ? cycle_p[cycle][1] : cycle_p[cycle][i+1]
            plain_p[perm_source] = perm_target
        end
    end # for cycle
    
    return plain_p
end # cycle_to_plain()

end # module