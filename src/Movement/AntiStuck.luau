return function(Config, Time, Vector)
    local AntiStuck = {}
    AntiStuck.__index = AntiStuck

    function AntiStuck.new()
        return setmetatable({
            lastPos = nil,
            stuckTimer = 0,
            hardStuckTimer = 0,
            lastJump = 0,
            positions = {},
            maxPositions = 12,
        }, AntiStuck)
    end

    function AntiStuck:Reset()
        self.lastPos = nil
        self.stuckTimer = 0
        self.hardStuckTimer = 0
        self.positions = {}
    end

    function AntiStuck:Check(root)
        if not root then return false end
        local pos = root.Position
        local tickRate = Config.Get("TickRate") or 0.05
        if not self.lastPos then
            self.lastPos = pos
            return false
        end

        local moved = (pos - self.lastPos).Magnitude
        self.lastPos = pos

        if moved < 0.25 then
            self.stuckTimer = self.stuckTimer + tickRate
            self.hardStuckTimer = self.hardStuckTimer + tickRate
        else
            self.stuckTimer = 0
            self.hardStuckTimer = 0
        end

        table.insert(self.positions, pos)
        if #self.positions > self.maxPositions then
            table.remove(self.positions, 1)
        end

        return self.stuckTimer >= (Config.Get("MaxStuckTime") or 1.5)
    end

    function AntiStuck:IsHardStuck()
        return self.hardStuckTimer >= (Config.Get("HardStuckTime") or 4)
    end

    function AntiStuck:CanJump()
        local cd = Config.Get("StuckJumpCooldown") or 0.6
        if Time.Now() - self.lastJump >= cd then
            self.lastJump = Time.Now()
            return true
        end
        return false
    end

    function AntiStuck:GetVariance()
        if #self.positions < 2 then return 0 end
        local minX, maxX = math.huge, -math.huge
        local minY, maxY = math.huge, -math.huge
        local minZ, maxZ = math.huge, -math.huge
        for _, pos in ipairs(self.positions) do
            minX = math.min(minX, pos.X); maxX = math.max(maxX, pos.X)
            minY = math.min(minY, pos.Y); maxY = math.max(maxY, pos.Y)
            minZ = math.min(minZ, pos.Z); maxZ = math.max(maxZ, pos.Z)
        end
        return Vector3.new(maxX - minX, maxY - minY, maxZ - minZ).Magnitude
    end

    return AntiStuck.new()
end
