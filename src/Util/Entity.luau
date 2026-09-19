local Entity = {}

function Entity.GetHumanoid(entity)
    if not entity then return nil end
    return entity:FindFirstChildOfClass("Humanoid")
end

function Entity.GetRoot(entity)
    if not entity then return nil end
    return entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart
end

function Entity.GetPrimary(entity)
    return Entity.GetRoot(entity)
end

function Entity.GetPosition(entity)
    local root = Entity.GetRoot(entity)
    if root then
        return root.Position
    end
    if entity and entity.Position then
        return entity.Position
    end
    return Vector3.zero
end

function Entity.FindID(entity)
    if not entity then return nil end
    return entity:GetAttribute("ID") or entity.Name
end

function Entity.IsAlive(entity)
    local humanoid = Entity.GetHumanoid(entity)
    return humanoid ~= nil and humanoid.Health > 0
end

return Entity
