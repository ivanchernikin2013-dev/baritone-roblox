return function(Time)
    local RateLimit = {}

    function RateLimit.new(period)
        return setmetatable({
            period = period or 0.1,
            last = {},
        }, { __index = RateLimit })
    end

    function RateLimit:allow(key)
        local now = Time.Now()
        local last = self.last[key] or 0
        if now - last >= self.period then
            self.last[key] = now
            return true
        end
        return false
    end

    function RateLimit:reset(key)
        if key then
            self.last[key] = nil
        else
            self.last = {}
        end
    end

    return RateLimit.new()
end
