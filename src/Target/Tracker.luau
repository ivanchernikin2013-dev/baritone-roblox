return function(Time)
    local Tracker = {}
    Tracker.__index = Tracker

    function Tracker.new()
        return setmetatable({
            current = nil,
            history = {},
        }, Tracker)
    end

    function Tracker:Set(target)
        self.current = target
        table.insert(self.history, { target = target, time = Time.Now() })
        if #self.history > 25 then
            table.remove(self.history, 1)
        end
        return target
    end

    function Tracker:GetTarget()
        return self.current
    end

    function Tracker:Clear()
        self.current = nil
        self.history = {}
    end

    function Tracker:ClearHistory()
        self.history = {}
    end

    return Tracker.new()
end
