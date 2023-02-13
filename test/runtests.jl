using Test, Permutations

for nn in [4, 6, 8, 9, 10]

    println("Regular permutations of $nn elements")
    rp_dict = nt_regular_permutations(nn)

    rp_keys = collect(keys(rp_dict))

    for key in rp_keys
        n, k = key
   
        m = div(n, k)

        rp_mk = rp_dict[key]
        for l in 1:lastindex(rp_mk)
            # println("\t$l (of $(lastindex(rp_mk))). $m cycles of $k elements")
            rp_mk_l = rp_mk[l]
            # println("\t\t$rp_mk_l")
            @test isvalid_cycle_representation(rp_mk_l)

            plain_p_1 = cycle_to_plain(rp_mk_l)
            @test isvalid_plain_representation(plain_p_1)

            cycle_p = plain_to_cycle(plain_p_1)            
            @test isvalid_cycle_representation(cycle_p)

            plain_p_2 = cycle_to_plain(cycle_p)

            @test length(plain_p_1) == length(plain_p_2)

            @test sum(plain_p_1 .!= plain_p_2) == 0

        end # for l
        
    end # for key

end # for nn