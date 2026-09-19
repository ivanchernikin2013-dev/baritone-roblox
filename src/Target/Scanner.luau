return function(Config, Player, Entity, Cache)
    local Scanner = {}

    local function defaultPredicate(model)
        return model and model:IsA("Model")
    end

    function Scanner.ScanAll(range)
        range = range or Config.Get("SearchRange") or 150
        local player = Player.getLocalPlayer()
        if not player then return {} end

        local root = Player.GetRoot(player)
        if not root then return {} end

        local results = {}
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and defaultPredicate(model) then
                local part = Entity.GetPrimary(model)
                if part then
                    local distance = (part.Position - root.Position).Magnitude
                    if distance <= range then
                        table.insert(results, model)
                    end
                end
            end
        end

        return results
    end

    function Scanner.ScanNearest(range)
        local found = nil
        local bestDistance = math.huge
        local player = Player.getLocalPlayer()
        if not player then return nil end

        local root = Player.GetRoot(player)
        if not root then return nil end

        for _, model in ipairs(Scanner.ScanAll(range)) do
            local part = Entity.GetPrimary(model)
            if part then
                local distance = (part.Position - root.Position).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    found = model
                end
            end
        end

        return found, bestDistance
    end

    return Scanner
end
