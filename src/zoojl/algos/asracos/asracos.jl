type ASRacos
    rc::RacosCommon
    computer_num
    sample_set
    result_set
    asyn_result
    is_finish

    function ASRacos(ncomputer)
        new(RacosCommon(), ncomputer, RemoteChannel(()->Channel(ncomputer)),
        RemoteChannel(()->Channel(ncomputer)), RemoteChannel(()->Channel(1)), false)
    end
end

function asracos_init_sample_set!(asracos::ASRacos, ub)
    rc = asracos.rc
    data_temp = rc.parameter.init_sample
    if !isnull(data_temp)
        for i = 1:length(data_temp)
            put!(asracos.sample_set, data_temp[i])
        end
        return
    end
    classifier = RacosClassification(rc.objective.dim, rc.positive_data,
        rc.negative_data, ub=ub)
    mixed_classification(classifier)
    for i = 1:asracos.computer_num
        if rand(rng, Float64) < rc.parameter.probability
            solution, distinct_flag = distinct_sample_classifier(rc, classifier, data_num=rc.parameter.train_size)
        else
            solution, distinct_flag = distinct_sample(rc, rc.objective.dim)
        end
        # sol_print(solution)
        put!(asracos.sample_set, solution)
    end
end
