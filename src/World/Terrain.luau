return function(Raycast, Config)
    local Terrain = {}

    function Terrain.GetMaterialAt(pos)
        if not workspace.Terrain then
            return nil
        end

        local ok, result = pcall(function()
            local region = Region3.new(pos - Vector3.new(0.5, 0.5, 0.5), pos + Vector3.new(0.5, 0.5, 0.5))
            local voxels = workspace.Terrain:ReadVoxels(region, 4)
            return voxels
        end)

        if not ok or not result then
            return nil
        end
        return result
    end

    function Terrain.IsWater(pos)
        local material = Terrain.GetMaterialAt(pos)
        return material ~= nil and tostring(material) == "Water"
    end

    function Terrain.IsWaterAt(position, radius)
        radius = radius or 2
        local samples = {
            position,
            position + Vector3.new(radius, 0, 0),
            position + Vector3.new(-radius, 0, 0),
            position + Vector3.new(0, 0, radius),
            position + Vector3.new(0, 0, -radius),
        }

        for _, sample in ipairs(samples) do
            if Terrain.IsWater(sample) then
                return true
            end
        end
        return false
    end

    function Terrain.GetHeightAt(pos, maxDist, ignore)
        maxDist = maxDist or 100
        local hit = Raycast.Down(pos + Vector3.new(0, maxDist / 2, 0), maxDist, ignore)
        return hit and hit.Position.Y or nil
    end

    function Terrain.GetSlopeAngle(pos, radius, ignore)
        radius = radius or 3
        local center = Terrain.GetHeightAt(pos, 50, ignore)
        if not center then return nil end

        local samples = {
            Vector3.new(radius, 0, 0),
            Vector3.new(-radius, 0, 0),
            Vector3.new(0, 0, radius),
            Vector3.new(0, 0, -radius),
        }

        local maxSlope = 0
        for _, offset in ipairs(samples) do
            local height = Terrain.GetHeightAt(pos + offset, 50, ignore)
            if height then
                local slope = math.atan(math.abs(height - center) / radius) * 180 / math.pi
                if slope > maxSlope then maxSlope = slope end
            end
        end
        return maxSlope
    end

    function Terrain.IsCliffAhead(root, dir, ignore)
        if not root or not dir then return false end
        local range = Config.Get("CliffDetectionRange") or 3
        local maxDrop = Config.Get("CliffMaxDrop") or 12
        local from = root.Position + Vector3.new(0, 0.5, 0)
        local ahead = from + dir.Unit * range
        local hit = Raycast.Down(ahead, maxDrop, ignore)
        if not hit then return true end
        local drop = from.Y - hit.Position.Y
        return drop > maxDrop
    end

    return Terrain
end
