"""
    MyIntegers

    Module for arithmetic functions.
"""
module MyIntegers

    using Combinatorics:    combinations
    using ..Permutations:   overlap
"""
    divisors_in_pairs(n::Int)

    Compute divisors of `n` and returns them in a
    vector of pairs (j,k) where j <= k and n = j*k
    The returned pairs are ordered by increasing
    values of their first element `j`
"""
function divisors_in_pairs(n::Int)::Vector{Tuple{Int, Int}}

    divisors = Vector{Tuple{Int, Int}}()

    s = floor(Int, sqrt(n))

    for j in 1:s
        if n % j == 0
            k = div(n, j)
            push!(divisors, (j,k))
        end
    end

    return divisors
end

"""
    divisors(n::Int)

    Compute divisors of `n` and returns them sorted in a vector
"""
function divisors(n::Int)::Vector{Int}

    divs = divisors_in_pairs(n)                 # return them in pairs
    sdiv = nothing                              # return them sorted

    if divs[end][1] == divs[end][2]             # n is a square integer
        sdiv = zeros(Int, 2*length(divs)-1)
        for k in 1:lastindex(divs)-1
            sdiv[k]       = divs[k][1]
            sdiv[end-k+1] = divs[k][2]
        end
        sdiv[length(divs)] = divs[end][1]
    else                                        # n is NOT a square integer
        sdiv = zeros(Int, 2*length(divs))
        for k in 1:lastindex(divs)
            sdiv[k]       = divs[k][1]
            sdiv[end-k+1] = divs[k][2]
        end
    end

    return sdiv
end


"""
    regular_partitions(n)

The integer partition of n into a sum of equal terms can be
interpreted as the cycle structure of a `regular` permutation
on n symbols. Indeed, a permutation is said to be `regular`
when it can be decomposed into independent cycles of identical
length.

Returns a vector of partitions of n including
    - the partition [1,1, ..., 1] (n 1-cycles) ~ identity permutation
    - the partition      [n]      (1 n-cycle ) ~ cyclic n-permutation
    - other partitions   [k,..,k]   with n/k equal terms
"""
function regular_partitions(n::Int)::Vector{Vector{Int}}

    #   Get all divisors of n (in pairs)
    div_pairs = divisors_in_pairs(n)
    r = Vector{Vector{Int}}()

    for dp in div_pairs
        j, k = dp
        push!(r, j * ones(Int, k))  # value of j repeated k times
        push!(r, k * ones(Int, j))  # value of k repeated j times
    end

    return r
end

"""
    nt_regular_partitions(n)

Like regular_partitions(n) without the two trivial partitions. 
"""
function nt_regular_partitions(n::Int)::Vector{Vector{Int}}

    #   Get all divisors of n (in pairs)
    div_pairs = divisors_in_pairs(n)
    r = Vector{Vector{Int}}()

    for dp in div_pairs[2:end]
        j, k = dp
        push!(r, j * ones(Int, k))  # value of j repeated k times
        push!(r, k * ones(Int, j))  # value of k repeated j times
    end

    return r
end

"""
    nt_regular_permutations(n)

For n the cardinality of a set, generate all distinct, 
non-trivial, regular permutations of the n integers in 1:n  
Recall that a permutations is called 'regular' if it leaves 
no fixed point and all of its cycles have the same length.
This implementation depends on Combinatorics.combinations().     
"""
function nt_regular_permutations(n)

    # Output produced as a Dictionary:
    #   key: Tuple{Int, Int} = (n, k)  with n a constant across all keys
    #   val: Array of regular permutations of 1:n with cycles of length k
    nt_rp_dictionary = Dict{Tuple{Int, Int}, Vector{Vector{Vector{UInt8}}}}() 
    
    for k in divisors(n)[2:end-1]
        combin_nk = collect(combinations(UnitRange{UInt8}(1:n), k))
        mk_blocks = build_mk_blocks(n, k, combin_nk)
        nt_rp_dictionary[(n, k)] = mk_blocks
    end

    return nt_rp_dictionary
end

"""
    build_mk_blocks(n, k, combin_nk)

    for n the cardinality of the set of integers in the range 1:n;
    for k a divisor of n;
    for combin_nk an array of distinct combinations of k integers in the 1:n range;
    m = n/k the number of disjoint combinations whose union equals the 1:n set
    Produce all distinct m⋅k blocks of combin_nk elements whose union is {1,...,n}
"""
function build_mk_blocks(n, k, combin_nk::Vector{Vector{UInt8}})::Vector{Vector{Vector{UInt8}}}
    # nof k-element combinations to be joined in each m⋅k block
    m = div(n,k)

    # Strategy: 1⋅k blocks  ⟶  2⋅k blocks  ⟶  ⋯  ⟶  l⋅k blocks  ⟶  ⋯  ⟶  m⋅k blocks
    lk_dict =  Dict{Int, Vector{Vector{Vector{UInt8}}}}()
    
    # Represent the input combin_nk as a vector of 1⋅k-blocks
    # thus converting [--][--]⋯[--]  into  [[--]][[--]]⋯[[--]]
    lk_dict[1] = [[combin_nk[j]] for j in 1:lastindex(combin_nk)] 

    for l in 2:m

        # build l⋅k blocks from i⋅k blocks where i=(l-1)
        i = l-1
        ik_blocks = lk_dict[i]                

        # generate all distinct l⋅k blocks from i⋅k blocks
        lk_blocks = Vector{Vector{Vector{UInt8}}}(undef, 0)

        # Since by construction any integer found in each of the i⋅k blocks appears only once in that block

        #  i) iterate over all i⋅k blocks 
        for ik_block in ik_blocks
            #  ii) take all integers from the i⋅k block (Vector{Vector{}}}) and put then into a Vector{}
            ik_block_integers = reduce(vcat, ik_block)
            #  iii) iterate over all combinations (k-blocks) in combin_nk
            for k_block in combin_nk
                #  iv) test whether integers at ii) overlap with those in the k-block at iii)
                if !overlap(ik_block_integers, k_block)
                    #  v) iff there is no overlap, test that i⋅k block[end] < k_block, in order to avoid
                    #     generating m! equivalent representations of each permutation, which would only 
                    #     differ by a different ordering of the m k-cycles entering into its definition.     
                    if isless(ik_block[end], k_block)
                        #  vi) with no overlap and ordering guaranteeing uniqueness, create an l⋅k block 
                        #      by adding the k-block at iii) to the i⋅k block at i)   
                        lk_block = vcat(ik_block, [k_block])
                        push!(lk_blocks,lk_block)
                    end # if isless
                end # if !overlap()
            end
        end

        # save l⋅k blocks in the dictionary
        lk_dict[l] = lk_blocks
    end

    return lk_dict[m]
end    

end # module

