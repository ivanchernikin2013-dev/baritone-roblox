return function(Logger, Stats)
    local Reporter = {}

    function Reporter.OnStart()
        Logger.Info("Reporter started")
    end

    function Reporter.OnStop()
        Logger.Info("Reporter stopped")
    end

    function Reporter.Tick()
        local stats = Stats.GetAll()
        Logger.Info("Stats:", stats)
    end

    return Reporter
end
