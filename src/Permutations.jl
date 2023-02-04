module Permutations

#########################################################################
#   `using`  makes names that are local to a submodule visible and      #
#            accessible to the top module but NOT to submodules         #
#                                                                       #
#  `export`  makes some of the above names visible and accessible from  #
#            outside the top module, and to submodules as well          #
#                                                                       #
#  N O T E :  o r d e r  of include's is !critical! when sub-modules    #
#                        cross-reference each other functions or types  #
#                                                                       #
#########################################################################

include("MyUtils.jl")
using .MyUtils:     overlap
export              overlap

include("MyIntegers.jl")
using .MyIntegers:  divisors, divisors_in_pairs, 
                    regular_partitions, nt_regular_partitions, nt_regular_permutations
export              divisors, divisors_in_pairs, 
                    regular_partitions, nt_regular_partitions, nt_regular_permutations







end # module permutations
