return function(Player)
    local Tool = {}

    function Tool.EnsureAny()
        local player = Player.getLocalPlayer()
        if not player then return false end
        local character = player.Character
        if not character then return false end

        local tool = character:FindFirstChildOfClass("Tool")
        return tool ~= nil
    end

    function Tool.EnsureAxe()
        local player = Player.getLocalPlayer()
        if not player then return false end
        local character = player.Character
        if not character then return false end

        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            return tool
        end
        return nil
    end

    return Tool
end
