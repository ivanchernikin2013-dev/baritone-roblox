return function(Config, Noise, Interpolation, Time)
    local Humanizer = {}
    local lastStep = 0

    function Humanizer.ApplyToTarget(targetPos)
        local jitterEnabled = Config.Get("JitterEnabled")
        if not jitterEnabled then
            return targetPos
        end

        local amount = Config.Get("JitterAmount") or 0.15
        local t = Time.Now()
        if t - lastStep > 0.25 then
            lastStep = t
        end

        local dx = Noise.value(t, targetPos.X, targetPos.Z) * amount
        local dz = Noise.value(targetPos.Y, t, targetPos.X) * amount
        local offset = Vector3.new(dx, 0, dz)
        return targetPos + offset
    end

    return Humanizer
end
