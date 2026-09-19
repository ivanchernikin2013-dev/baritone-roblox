local Player = {}

function Player.getLocalPlayer()
    local players = game:GetService("Players")
    return players and players.LocalPlayer
end

function Player.GetHumanoid(player)
    player = player or Player.getLocalPlayer()
    if not player then return nil end
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

function Player.GetRoot(player)
    player = player or Player.getLocalPlayer()
    if not player then return nil end
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

function Player.GetCharacter(player)
    player = player or Player.getLocalPlayer()
    if not player then return nil end
    return player.Character
end

function Player.GetPosition(player)
    local root = Player.GetRoot(player)
    if root then
        return root.Position
    end
    return Vector3.zero
end

return Player
