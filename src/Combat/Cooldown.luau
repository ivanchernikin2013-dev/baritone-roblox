return function(Time, Config)
    local Cooldown = {}

    function Cooldown.new()
        return {
            last = 0,
        }
    end

    function Cooldown:canUse()
        return Time.Now() - self.last >= (Config.Get("SwingCooldown") or 0.3)
    end

    function Cooldown:use()
        self.last = Time.Now()
        return true
    end

    return Cooldown.new()
end
