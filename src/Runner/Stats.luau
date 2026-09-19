return function(Time)
    local Stats = {
        startedAt = Time.Now(),
        data = {
            ticks = 0,
            acquired = 0,
            chopped = 0,
            lost = 0,
            swing = 0,
            stuck = 0,
            errors = 0,
        },
    }

    function Stats.Start()
        Stats.startedAt = Time.Now()
        Stats.Reset()
    end

    function Stats.Reset()
        Stats.data = {
            ticks = 0,
            acquired = 0,
            chopped = 0,
            lost = 0,
            swing = 0,
            stuck = 0,
            errors = 0,
        }
    end

    function Stats.IncTick() Stats.data.ticks = Stats.data.ticks + 1 end
    function Stats.IncAcquired() Stats.data.acquired = Stats.data.acquired + 1 end
    function Stats.IncChopped() Stats.data.chopped = Stats.data.chopped + 1 end
    function Stats.IncLost() Stats.data.lost = Stats.data.lost + 1 end
    function Stats.IncSwing() Stats.data.swing = Stats.data.swing + 1 end
    function Stats.IncStuck() Stats.data.stuck = Stats.data.stuck + 1 end
    function Stats.IncError() Stats.data.errors = Stats.data.errors + 1 end
    function Stats.UpdatePosition(position) end

    function Stats.GetAll()
        return {
            startedAt = Stats.startedAt,
            ticks = Stats.data.ticks,
            acquired = Stats.data.acquired,
            chopped = Stats.data.chopped,
            lost = Stats.data.lost,
            swing = Stats.data.swing,
            stuck = Stats.data.stuck,
            errors = Stats.data.errors,
        }
    end

    function Stats.Format()
        local data = Stats.GetAll()
        return string.format("ticks=%d acquired=%d chopped=%d lost=%d swing=%d stuck=%d errors=%d", data.ticks, data.acquired, data.chopped, data.lost, data.swing, data.stuck, data.errors)
    end

    return Stats
end
