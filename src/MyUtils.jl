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
function overlap(a1::Vector{<:Integer}, a2::Vector{<:Integer})
    overlap = false
    for val in a1
        t = a2 .== val
        if sum(t) > 0
            overlap = true
            break
        end
    end
    return overlap
end

end # module