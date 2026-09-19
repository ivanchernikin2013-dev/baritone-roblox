return function(Entity)
    local Validator = {}

    function Validator.IsValid(target)
        if not target then return false end
        if not target:IsA("Model") then return false end
        local root = Entity.GetRoot(target)
        if not root then return false end
        local humanoid = Entity.GetHumanoid(target)
        if humanoid and humanoid.Health <= 0 then return false end
        return true
    end

    return Validator
end
