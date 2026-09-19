return function(Config, Logger, Player, Events)
    local Guard = {}

    function Guard.CheckAll()
        local player = Player.getLocalPlayer()
        if not player then return false end
        local character = player.Character
        if not character then return false end
        return true
    end

    return Guard
end
