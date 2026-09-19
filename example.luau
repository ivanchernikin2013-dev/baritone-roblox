local BASE = "https://raw.githubusercontent.com/YOUR_USERNAME/Roblox-bariton/main/src/"

local Baritone = loadstring(game:HttpGet(BASE .. "init.luau"))(BASE)

Baritone.SetPreset("balanced")
Baritone.SetConfig("TargetMode", "Nearest")
Baritone.SetConfig("SearchRange", 150)
Baritone.SetConfig("CliffDetectionRange", 4)
Baritone.SetConfig("AutoVaultEnabled", true)
Baritone.SetConfig("AvoidWater", true)

Baritone.On("target_acquired", function(tree, dist)
    print(("[Bariton] Target: %s (%.0fm)"):format(tree.Name, dist))
end)

Baritone.On("tree_chopped", function(tree)
    print("[Bariton] Chopped: " .. tree.Name)
end)

Baritone.On("stuck", function(pos)
    warn("[Bariton] Stuck at " .. tostring(pos))
end)

Baritone.On("error", function(msg)
    warn("[Bariton] Error: " .. tostring(msg))
end)

Baritone.Start()

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        if Baritone.IsRunning() then
            Baritone.Stop()
        else
            Baritone.Start()
        end
    elseif input.KeyCode == Enum.KeyCode.L then
        print("[Bariton]", Baritone.GetStatsFormatted())
    elseif input.KeyCode == Enum.KeyCode.O then
        Baritone.Pause()
    elseif input.KeyCode == Enum.KeyCode.P then
        Baritone.Resume()
    end
end)

_G.Bariton = Baritone
