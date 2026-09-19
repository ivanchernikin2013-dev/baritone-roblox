return function(Config, Raycast, Vector, Time)
    local WallFollow = {}
    WallFollow.__index = WallFollow

    function WallFollow.new()
        return setmetatable({
            active = false,
            startTime = 0,
            side = nil,
            lastDir = nil,
        }, WallFollow)
    end

    function WallFollow:Start(root, dir, ignore)
        if not Config.Get("WallFollowEnabled") then return false end
        local left = Vector3.new(-dir.Z, 0, dir.X).Unit
        local right = -left
        local leftBlocked = Raycast.CastDir(root.Position, left, 3, ignore)
        local rightBlocked = Raycast.CastDir(root.Position, right, 3, ignore)
        if leftBlocked and not rightBlocked then
            self.side = "right"
        elseif rightBlocked and not leftBlocked then
            self.side = "left"
        else
            self.side = (math.random() > 0.5) and "left" or "right"
        end
        self.active = true
        self.startTime = Time.Now()
        self.lastDir = dir
        return true
    end

    function WallFollow:Step(root, dir, ignore)
        if not self.active then return nil end
        if Time.Now() - self.startTime > (Config.Get("WallFollowMaxTime") or 3) then
            self:Stop()
            return nil
        end

        local stepSize = Config.Get("WallFollowStepSize") or 1.5
        local perpendicular
        if self.side == "left" then
            perpendicular = Vector3.new(-dir.Z, 0, dir.X).Unit
        else
            perpendicular = Vector3.new(dir.Z, 0, -dir.X).Unit
        end

        local forward = Vector3.new(dir.X, 0, dir.Z)
        if forward.Magnitude < 1e-4 then forward = Vector3.new(1, 0, 0) end
        forward = forward.Unit

        local tryOrder = {
            (forward + perpendicular * 0.6).Unit,
            perpendicular,
            (forward + perpendicular * 0.3).Unit,
            (perpendicular - forward * 0.3).Unit,
        }

        for _, d in ipairs(tryOrder) do
            local to = root.Position + d * stepSize
            if Raycast.IsClear(root.Position, to, ignore) then
                return d
            end
        end
        return nil
    end

    function WallFollow:Stop()
        self.active = false
        self.side = nil
        self.lastDir = nil
    end

    function WallFollow:IsActive()
        return self.active
    end

    return WallFollow.new()
end
