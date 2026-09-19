return function(Config, Logger, Events, Scheduler)
    local Watchdog = {}

    function Watchdog.Start(runner)
        return true
    end

    function Watchdog.Stop()
        return true
    end

    return Watchdog
end
