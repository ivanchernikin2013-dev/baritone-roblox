return function(Config, Logger, Events, State, Scheduler,
    Player, Entity, Retry, Raycast, Obstacle,
    Scanner, Filter, Blacklist, Tracker, Prioritizer, Validator,
    Movement, Swing, Tool, Focus, Pattern, Guard,
    Stats, Recovery, Reporter)

    local Runner = {}
    local running = false
    local thread = nil
    local target = nil
    local skip = false

    local function validate()
        if not target then return false end
        if not Validator.IsValid(target) then return false end
        if Blacklist.IsBlacklisted(target) then return false end
        return true
    end

    local function acquire()
        local tree, dist = Scanner.ScanNearest(Config.Get("SearchRange"))
        if not tree then return nil end
        if Blacklist.IsBlacklisted(tree) then return nil end
        return tree, dist
    end

    local function onLost(reason)
        if target then
            Stats.IncLost()
            Events.Emit("target_lost", target, reason)
        end
        target = nil
        Tracker:Clear()
        Movement.Reset(Player.GetRoot())
    end

    local function onChopped(tree)
        Stats.IncChopped()
        Events.Emit("tree_chopped", tree)
        Logger.Info("Chopped: " .. tree.Name)
        target = nil
        Tracker:Clear()
    end

    function Runner.TickOnce()
        if not running then return end
        if skip then return end

        State:Set(State.States.SCANNING)

        if not Guard.CheckAll() then
            Movement.Stop(Player.GetRoot(), Player.GetHumanoid())
            State:Set(State.States.PAUSED)
            return
        end

        if Config.Get("SkipWhenGuiOpen") and Focus.ShouldSkip() then
           Movement.Stop(Player.GetRoot(), Player.GetHumanoid())
            State:Set(State.States.PAUSED)
            return
        end

        local root = Player.GetRoot()
        local humanoid = Player.GetHumanoid()
        if not root or not humanoid then
            Movement.Reset(nil)
            return
        end

        Stats.IncTick()

        if target and not validate() then
            onLost("invalid")
        end

        if not target then
            local newTree, dist = acquire()
            if newTree then
                target = newTree
                Tracker:Set(newTree)
                Stats.IncAcquired()
                Events.Emit("target_acquired", newTree, dist or 0)
                Logger.Info(string.format("Target: %s (%.0fm)", newTree.Name, dist or 0))
            else
                Movement.Stop(root, humanoid)
                return
            end
        end

        local primary = Entity.GetPrimary(target)
        if not primary then
            onLost("no_primary")
            return
        end

        local dist = (primary.Position - root.Position).Magnitude
        local chopDist = Config.Get("ChopDistance") or 6

        if dist <= chopDist then
            State:Set(State.States.CHOPPING)
            Movement.Stop(root, humanoid)
            Tool.EnsureAxe()
            local id = Entity.FindID(target)
            if id then
                if Swing.Send({ id }) then
                    Stats.IncSwing()
                    Pattern.Record("swing")
                end
            end
        else
            State:Set(State.States.MOVING)
            local dir = (primary.Position - root.Position)
            if dir.Magnitude < 1 then dir = Vector3.new(1, 0, 0) end
            dir = dir.Unit
            local approach = primary.Position + dir * (chopDist - 0.5)
            if Config.Get("MoveMode") == "Fly" then
                approach = approach + Vector3.new(0, Config.Get("FlyHeight") or 4, 0)
            end

            Movement.Step(root, humanoid, approach, target)

            if Movement.CheckStuck(root) then
                State:Set(State.States.STUCK)
                Stats.IncStuck()
                Events.Emit("stuck", root.Position)
                Logger.Warn("Stuck")

                if Movement.IsHardStuck() then
                    State:Set(State.States.RECOVERING)
                    Recovery.Recover(root, humanoid, target)
                    onLost("hard_stuck")
                elseif Movement.CanJump() then
                    Movement.Jump(humanoid)
                elseif not Movement.IsWallFollowing() then
                    Movement.StartWallFollow(root, (primary.Position - root.Position).Unit)
                end
            end
        end
    end

    function Runner.Start()
        if running then return end
        running = true
        Stats.Start()
        Movement.Reset(Player.GetRoot())
        State:Set(State.States.IDLE)
        Logger.Info("Runner started")

        thread = task.spawn(function()
            while running do
                local ok, err = pcall(Runner.TickOnce)
                if not ok then
                    Stats.IncError()
                    Events.Emit("error", tostring(err))
                    Logger.Error(tostring(err))
                end
                local tickRate = Config.Get("TickRate") or 0.05
                if Config.Get("RandomDelay") then
                    tickRate = tickRate + (Config.Get("RandomDelayMin") or 0.02) + math.random() * ((Config.Get("RandomDelayMax") or 0.12) - (Config.Get("RandomDelayMin") or 0.02))
                end
                task.wait(tickRate)
            end
            Movement.Stop(Player.GetRoot(), Player.GetHumanoid())
            Movement.Reset(Player.GetRoot())
            State:Set(State.States.IDLE)
        end)
    end

    function Runner.Stop()
        running = false
        if thread then pcall(task.cancel, thread); thread = nil end
        target = nil
        Tracker:Clear()
        Movement.Reset(Player.GetRoot())
        Recovery.Reset()
    end

    function Runner.IsRunning() return running end
    function Runner.GetCurrentTree() return target end

    return Runner
end
