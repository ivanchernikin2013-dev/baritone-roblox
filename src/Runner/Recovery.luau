return function(Config, Logger, Events, Player, Movement, Stats, Blacklist, Tracker)
    local Recovery = {}

    function Recovery.Reset()
        return true
    end

    function Recovery.Recover(root, humanoid, target)
        local player = Player.getLocalPlayer()
        if player and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 2, 0)
            end
        end
        if target then
            Blacklist.Add(target)
        end
        Stats.IncError()
        Logger.Warn("Recovery triggered")
        return true
    end

    return Recovery
end
