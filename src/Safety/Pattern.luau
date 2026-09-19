return function(Config, Time, Noise)
    local Pattern = {}
    local history = {}

    function Pattern.Record(event)
        table.insert(history, { time = Time.Now(), event = event })
    end

    function Pattern.GetRandomDelay()
        local baseMin = Config.Get("RandomDelayMin") or 0.02
        local baseMax = Config.Get("RandomDelayMax") or 0.12
        return math.random() * (baseMax - baseMin) + baseMin
    end

    return Pattern
end
