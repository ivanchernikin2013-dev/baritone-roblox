local Filter = {}

function Filter.new(predicate)
    return {
        predicate = predicate or function() return true end,
    }
end

function Filter:matches(value)
    return self.predicate(value)
end

function Filter.byDistance(maxDistance)
    return Filter.new(function(entity)
        if not entity then return false end
        local root = entity:FindFirstChild("HumanoidRootPart")
        local localRoot = game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and localRoot then
            return (root.Position - localRoot.Position).Magnitude <= (maxDistance or 200)
        end
        return true
    end)
end

return Filter
