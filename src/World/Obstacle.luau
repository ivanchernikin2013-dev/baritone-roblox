return function(Config, Raycast, Vector)
    local Obstacle = {}

    local function unit(v)
        if not v or v.Magnitude < 1e-4 then
            return Vector3.zero
        end
        return v.Unit
    end

    function Obstacle.Classify(root, dir, ignore)
        if not root or not dir then return "unknown" end
        local length = Config.Get("ObstacleRayLength") or 6
        local from = root.Position + Vector3.new(0, 1, 0)
        local hit = Raycast.CastDir(from, dir, length, ignore)
        if not hit then return "clear" end

        local hitTop = Raycast.CastDir(from + Vector3.new(0, 3, 0), dir, length, ignore)
        if not hitTop then return "low_wall" end
        local hitVeryHigh = Raycast.CastDir(from + Vector3.new(0, 6, 0), dir, length, ignore)
        if not hitVeryHigh then return "mid_wall" end
        return "high_wall"
    end

    function Obstacle.CheckAhead(root, dir, ignore)
        if not root or not dir then return false, nil end
        local length = Config.Get("ObstacleRayLength") or 6
        local from = root.Position + Vector3.new(0, 1, 0)
        local hit = Raycast.CastDir(from, dir, length, ignore)
        return hit ~= nil, hit
    end

    function Obstacle.CheckAbove(root, length, ignore)
        if not root then return false, nil end
        length = length or 6
        local hit = Raycast.CastDir(root.Position, Vector3.new(0, 1, 0), length, ignore)
        return hit ~= nil, hit
    end

    function Obstacle.FindClimbDir(root, dir, ignore)
        if not root or not dir then return nil end
        local boost = Config.Get("ObstacleClimbBoost") or 1.6
        local length = Config.Get("ObstacleRayLength") or 6
        local candidates = {
            unit(dir + Vector3.new(0, boost, 0)),
            unit(dir + Vector3.new(0, boost * 1.5, 0)),
            Vector3.new(0, 1, 0),
        }
        for _, d in ipairs(candidates) do
            if Raycast.IsClear(root.Position, root.Position + d * length, ignore) then
                return d
            end
        end
        return nil
    end

    function Obstacle.FindSideDir(root, dir, ignore)
        if not root or not dir then return nil end
        local length = Config.Get("ObstacleRayLength") or 6
        local samples = Config.Get("ObstacleSideSamples") or 8
        local angle = math.rad(Config.Get("ObstacleSampleAngle") or 60)
        local flatDir = Vector3.new(dir.X, 0, dir.Z)
        if flatDir.Magnitude < 1e-4 then return nil end
        flatDir = flatDir.Unit

        local best, bestScore = nil, -math.huge
        for i = 0, samples do
            local t = i / samples
            local sign = (i % 2 == 0) and 1 or -1
            local rot = angle * t * sign
            local cos, sin = math.cos(rot), math.sin(rot)
            local rd = Vector3.new(
                flatDir.X * cos + flatDir.Z * sin,
                0.3,
                -flatDir.X * sin + flatDir.Z * cos
            )
            rd = unit(rd)
            if Raycast.IsClear(root.Position, root.Position + rd * length, ignore) then
                local forwardScore = rd:Dot(flatDir)
                local score = forwardScore - math.abs(rot) * 0.3
                if score > bestScore then
                    bestScore = score
                    best = rd
                end
            end
        end
        return best
    end

    function Obstacle.FindVaultDir(root, dir, ignore)
        if not Config.Get("AutoVaultEnabled") then return nil end
        if not root or not dir then return nil end
        local maxH = Config.Get("VaultMaxHeight") or 3
        local rayLen = Config.Get("VaultRayLength") or 3
        local from = root.Position + Vector3.new(0, 0.5, 0)
        local hit = Raycast.CastDir(from, dir, rayLen, ignore)
        if not hit then return nil end

        local hitTop = hit.Position.Y + 0.5
        local myTop = root.Position.Y
        local diff = hitTop - myTop
        if diff > maxH or diff < 0 then return nil end

        local overCheck = Raycast.Cast(
            Vector3.new(hit.Position.X, hitTop + 1, hit.Position.Z),
            Vector3.new(hit.Position.X + dir.X * 3, hitTop + 1, hit.Position.Z + dir.Z * 3),
            ignore
        )
        if overCheck then return nil end
        return true, hit
    end

    function Obstacle.FindEscapeDir(root, dir, ignore)
        local vault = Obstacle.FindVaultDir(root, dir, ignore)
        if vault then return dir, "vault", true end

        local climb = Obstacle.FindClimbDir(root, dir, ignore)
        if climb then return climb, "climb", false end

        local side = Obstacle.FindSideDir(root, dir, ignore)
        if side then return side, "side", false end

        return nil, "blocked", false
    end

    function Obstacle.GetAllBlocked(root, ignore)
        local length = Config.Get("ObstacleRayLength") or 6
        local dirs = {
            Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
            Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
            Vector3.new(1, 0, 1).Unit, Vector3.new(-1, 0, 1).Unit,
            Vector3.new(1, 0, -1).Unit, Vector3.new(-1, 0, -1).Unit,
        }
        local out = {}
        for _, d in ipairs(dirs) do
            local hit = Raycast.CastDir(root.Position, d, length, ignore)
            if hit then
                table.insert(out, { dir = d, hit = hit })
            end
        end
        return out
    end

    function Obstacle.Scan360(root, length, ignore)
        length = length or 8
        local out = {}
        for i = 0, 15 do
            local angle = math.rad(i * 22.5)
            local d = Vector3.new(math.cos(angle), 0.2, math.sin(angle)).Unit
            local hit = Raycast.CastDir(root.Position, d, length, ignore)
            table.insert(out, { angle = i * 22.5, dir = d, hit = hit })
        end
        return out
    end

    function Obstacle.HasFreePath(root, dir, length, ignore)
        if not root or not dir then return false end
        return Raycast.IsClear(root.Position, root.Position + dir.Unit * (length or 6), ignore)
    end

    return Obstacle
end
