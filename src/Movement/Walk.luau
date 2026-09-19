return function(Config, Raycast, Terrain, Vector)
    local Walk = {}

    local lastJump = 0
    local lastGroundCheck = 0
    local cachedGroundY = nil

    function Walk.GetGroundY(pos, ignore)
        local now = tick()
        local interval = Config.Get("GroundCheckInterval") or 0.2
        if cachedGroundY and now - lastGroundCheck < interval then
            return cachedGroundY
        end

        local y = Terrain.GetHeightAt(pos, 50, ignore)
        cachedGroundY = y
        lastGroundCheck = now
        return y
    end

    function Walk.TryJump(humanoid)
        if not humanoid then return false end
        local cd = Config.Get("JumpCooldown") or 0.8
        if tick() - lastJump < cd then return false end
        if humanoid.Health <= 0 then return false end
        humanoid.Jump = true
        lastJump = tick()
        return true
    end

    function Walk.NeedsJumpOverObstacle(root, dir, ignore)
        if not Config.Get("AutoVaultEnabled") then return false end
        local maxH = Config.Get("VaultMaxHeight") or 3
        local from = root.Position + Vector3.new(0, 0.5, 0)
        local hit = Raycast.CastDir(from, dir, 2.5, ignore)
        if not hit then return false end
        local top = hit.Position.Y + 0.5
        local diff = top - from.Y
        if diff < 0.5 or diff > maxH then return false end
        local over = Raycast.Cast(
            Vector3.new(hit.Position.X, top + 1.5, hit.Position.Z),
            Vector3.new(hit.Position.X + dir.X * 2.5, top + 1.5, hit.Position.Z + dir.Z * 2.5),
            ignore
        )
        return over == nil
    end

    function Walk.NeedsJumpOverGap(root, dir, ignore)
        if not Config.Get("AutoJumpEnabled") then return false end
        local from = root.Position + Vector3.new(0, 0.5, 0)
        local samples = { 1, 2, 3, 4 }
        local firstGroundAt = nil
        local firstGapAt = nil
        for _, d in ipairs(samples) do
            local checkPos = from + dir.Unit * d
            local hit = Raycast.Down(checkPos, 3, ignore)
            if hit then
                if not firstGapAt then firstGroundAt = d end
            else
                if not firstGapAt then firstGapAt = d end
            end
        end
        if not firstGapAt then return false end
        local maxGap = Config.Get("JumpGapMaxWidth") or 4
        for d = firstGapAt, math.min(firstGapAt + maxGap, 8) do
            local checkPos = from + dir.Unit * d
            local hit = Raycast.Down(checkPos, 3, ignore)
            if hit then return true end
        end
        return false
    end

    function Walk.HandleCliff(root, dir, ignore)
        if not Terrain.IsCliffAhead(root, dir, ignore) then return false end
        local margin = Config.Get("EdgeSafetyMargin") or 1.5
        local left = Vector3.new(-dir.Z, 0, dir.X).Unit
        local right = -left
        if not Terrain.IsCliffAhead(root, left, ignore) then
            root.CFrame = CFrame.new(root.Position + left * margin) * (root.CFrame - root.CFrame.Position)
            return true
        end
        if not Terrain.IsCliffAhead(root, right, ignore) then
            root.CFrame = CFrame.new(root.Position + right * margin) * (root.CFrame - root.CFrame.Position)
            return true
        end
        return false
    end

    function Walk.HandleWater(root, dir, ignore)
        if not Config.Get("AvoidWater") then return false end
        local rayLen = Config.Get("WaterRayLength") or 3
        local checkPos = root.Position + dir.Unit * rayLen
        if not Terrain.IsWaterAt(checkPos, 1.5) then return false end
        local left = Vector3.new(-dir.Z, 0, dir.X).Unit
        local right = -left
        local leftWater = Terrain.IsWaterAt(root.Position + left * rayLen, 1.5)
        local rightWater = Terrain.IsWaterAt(root.Position + right * rayLen, 1.5)
        if not leftWater then
            root.CFrame = CFrame.new(root.Position + left * 1.5) * (root.CFrame - root.CFrame.Position)
            return true
        end
        if not rightWater then
            root.CFrame = CFrame.new(root.Position + right * 1.5) * (root.CFrame - root.CFrame.Position)
            return true
        end
        return false
    end

    function Walk.HandleSlope(root, humanoid, dir, ignore)
        local slope = Terrain.GetSlopeAngle(root.Position, 3, ignore)
        if not slope then return false end
        local maxAngle = Config.Get("SlopeMaxAngle") or 45
        if slope <= maxAngle then return false end
        if Config.Get("AutoJumpEnabled") then
            if Walk.TryJump(humanoid) then return true end
        end
        return false
    end

    function Walk.Step(root, humanoid, targetPos, context)
        if not root or not humanoid then return false end
        local ignore = context and context.ignore or {}

        if Walk.HandleWater(root, targetPos - root.Position, ignore) then return true end

        local dir = (targetPos - root.Position)
        if dir.Magnitude < 1e-4 then
            humanoid:MoveTo(root.Position)
            return true
        end
        dir = dir.Unit

        if Walk.HandleCliff(root, dir, ignore) then
            humanoid:MoveTo(root.Position + dir * 0.5)
            return true
        end

        if Walk.HandleSlope(root, humanoid, dir, ignore) then
            humanoid:MoveTo(targetPos)
            return true
        end

        if Walk.NeedsJumpOverObstacle(root, dir, ignore) then
            Walk.TryJump(humanoid)
        elseif Walk.NeedsJumpOverGap(root, dir, ignore) then
            Walk.TryJump(humanoid)
        end

        local groundY = Walk.GetGroundY(targetPos, ignore)
        local final = targetPos
        if groundY then
            final = Vector3.new(targetPos.X, groundY, targetPos.Z)
        end

        humanoid.WalkSpeed = Config.Get("WalkSpeed") or 16
        humanoid:MoveTo(final)
        return true
    end

    function Walk.Jump(humanoid)
        if humanoid and humanoid.Health > 0 then
            humanoid.Jump = true
        end
    end

    function Walk.Stop(root, humanoid)
        if humanoid and root then
            humanoid:MoveTo(root.Position)
            humanoid.WalkSpeed = 16
        end
    end

    function Walk.ResetCache()
        cachedGroundY = nil
        lastGroundCheck = 0
    end

    return Walk
end
