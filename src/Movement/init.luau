return function(Config, Logger, Walk, Fly, AntiStuck, WallFollow, PathFollow, Humanizer, Camera, Obstacle, Raycast, Terrain)
    local Movement = {}
    local antiStuck = AntiStuck
    local pathFollower = PathFollow
    local wallFollow = WallFollow
    local lastRelocate = 0

    function Movement.Step(root, humanoid, targetPos, currentTree)
        if not root or not humanoid then return false end
        local ignore = {}
        if currentTree then table.insert(ignore, currentTree) end

        local jittered = Humanizer.ApplyToTarget(targetPos)
        local ctx = {
            config = Config,
            raycast = Raycast,
            obstacle = Obstacle,
            terrain = Terrain,
            ignore = ignore,
        }

        if wallFollow:IsActive() then
            local dir = wallFollow:Step(root, (targetPos - root.Position).Unit, ignore)
            if dir then
                humanoid:MoveTo(root.Position + dir * 2)
                return true
            else
                wallFollow:Stop()
            end
        end

        local mode = Config.Get("MoveMode") or "Walk"
        if mode == "Fly" then
            return Fly.Step(root, humanoid, jittered, ctx)
        end

        Fly.Stop(root)
        return Walk.Step(root, humanoid, jittered, ctx)
    end

    function Movement.StepDirect(root, humanoid, dir, currentTree)
        if not root or not humanoid then return false end
        local ignore = {}
        if currentTree then table.insert(ignore, currentTree) end
        local target = root.Position + dir * 5
        return Movement.Step(root, humanoid, target, currentTree)
    end

    function Movement.Stop(root, humanoid)
        Fly.Stop(root)
        wallFollow:Stop()
        if humanoid and root then
            Walk.Stop(root, humanoid)
        end
    end

    function Movement.Jump(humanoid)
        Walk.Jump(humanoid)
    end

    function Movement.TryJump(humanoid)
        return Walk.TryJump(humanoid)
    end

    function Movement.Reset(root)
        antiStuck:Reset()
        pathFollower:Clear()
        wallFollow:Stop()
        Walk.ResetCache()
        if root then Fly.Stop(root) end
    end

    function Movement.CheckStuck(root)
        return antiStuck:Check(root)
    end

    function Movement.IsHardStuck()
        return antiStuck:IsHardStuck()
    end

    function Movement.CanJump()
        return antiStuck:CanJump()
    end

    function Movement.StartWallFollow(root, dir, ignore)
        return wallFollow:Start(root, dir, ignore or {})
    end

    function Movement.StopWallFollow()
        wallFollow:Stop()
    end

    function Movement.IsWallFollowing()
        return wallFollow:IsActive()
    end

    function Movement.TryRelocate(root)
        local cd = 1.0
        if tick() - lastRelocate < cd then return false end
        local radius = Config.Get("StuckRelocateRadius") or 6
        local angle = math.random() * math.pi * 2
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local target = root.Position + offset
        local groundY = Terrain.GetHeightAt(target, 30)
        if not groundY then return false end
        target = Vector3.new(target.X, groundY + 3, target.Z)
        root.CFrame = CFrame.new(target) * (root.CFrame - root.CFrame.Position)
        lastRelocate = tick()
        return true
    end

    function Movement.GetAntiStuck() return antiStuck end
    function Movement.GetPathFollower() return pathFollower end
    function Movement.GetWallFollow() return wallFollow end

    return Movement
end
