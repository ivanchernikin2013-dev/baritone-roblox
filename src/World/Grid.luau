return function(Vector, Config)
    local Grid = {}
    Grid.__index = Grid

    function Grid.new(size, origin)
        return setmetatable({
            size = size or Config.Get("GridSize") or 8,
            origin = origin or Vector3.zero,
            cells = {},
            costOverrides = {},
        }, Grid)
    end

    function Grid:ToKey(pos)
        local s = self.size
        local x = math.floor((pos.X - self.origin.X) / s)
        local y = math.floor((pos.Y - self.origin.Y) / s)
        local z = math.floor((pos.Z - self.origin.Z) / s)
        return string.format("%d_%d_%d", x, y, z)
    end

    function Grid:ToPos(x, y, z)
        local s = self.size
        return Vector3.new(
            x * s + self.origin.X + s / 2,
            y * s + self.origin.Y + s / 2,
            z * s + self.origin.Z + s / 2
        )
    end

    function Grid:Mark(pos, weight)
        self.cells[self:ToKey(pos)] = weight or 1
    end

    function Grid:Unmark(pos)
        self.cells[self:ToKey(pos)] = nil
    end

    function Grid:GetWeight(pos)
        local key = self:ToKey(pos)
        if self.costOverrides[key] then return self.costOverrides[key] end
        return self.cells[key] or 0
    end

    function Grid:SetCost(pos, cost)
        self.costOverrides[self:ToKey(pos)] = cost
    end

    function Grid:IsBlocked(pos)
        return self:GetWeight(pos) > 0
    end

    function Grid:Clear()
        self.cells = {}
        self.costOverrides = {}
    end

    function Grid:ClearRegion(center, radius)
        local s = self.size
        local r = math.ceil(radius / s)
        local cx = math.floor((center.X - self.origin.X) / s)
        local cy = math.floor((center.Y - self.origin.Y) / s)
        local cz = math.floor((center.Z - self.origin.Z) / s)
        for dx = -r, r do
            for dy = -r, r do
                for dz = -r, r do
                    local key = string.format("%d_%d_%d", cx + dx, cy + dy, cz + dz)
                    self.cells[key] = nil
                    self.costOverrides[key] = nil
                end
            end
        end
    end

    function Grid:Neighbors(pos)
        local s = self.size
        local x = math.floor((pos.X - self.origin.X) / s)
        local y = math.floor((pos.Y - self.origin.Y) / s)
        local z = math.floor((pos.Z - self.origin.Z) / s)
        local offsets = {
            {1,0,0},{-1,0,0},{0,0,1},{0,0,-1},
            {1,0,1},{1,0,-1},{-1,0,1},{-1,0,-1},
            {0,1,0},{0,-1,0},
        }

        local out = {}
        for _, offset in ipairs(offsets) do
            local nx, ny, nz = x + offset[1], y + offset[2], z + offset[3]
            local key = string.format("%d_%d_%d", nx, ny, nz)
            table.insert(out, {
                pos = self:ToPos(nx, ny, nz),
                x = nx, y = ny, z = nz,
                weight = self:GetWeight(self:ToPos(nx, ny, nz)),
                key = key,
            })
        end
        return out
    end

    return Grid
end
