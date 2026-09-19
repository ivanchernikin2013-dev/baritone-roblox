return function(Player)
    local Raycast = {}

    local function makeParams(ignoreList)
        local params = RaycastParams.new()
        if ignoreList then
            params.FilterDescendantsInstances = ignoreList
            params.FilterType = Enum.RaycastFilterType.Exclude
        end
        return params
    end

    function Raycast.Cast(origin, direction, maxDistance, ignoreList)
        if not origin or not direction then
            return nil
        end

        maxDistance = maxDistance or 200
        local rayDirection = direction
        if typeof(rayDirection) == "Vector3" and rayDirection.Magnitude == 0 then
            rayDirection = Vector3.new(0, 0.001, 0)
        end

        local params = makeParams(ignoreList)
        return workspace:Raycast(origin, rayDirection.Unit * maxDistance, params)
    end

    function Raycast.CastDir(origin, direction, maxDistance, ignoreList)
        if not origin or not direction then
            return nil
        end

        local dir = direction
        if dir.Magnitude < 1e-4 then
            dir = Vector3.new(0, 0.001, 0)
        end
        return Raycast.Cast(origin, dir, maxDistance or 20, ignoreList)
    end

    function Raycast.Down(origin, maxDistance, ignoreList)
        return Raycast.Cast(origin, Vector3.new(0, -1, 0), maxDistance or 20, ignoreList)
    end

    function Raycast.IsClear(start, finish, ignoreList)
        if not start or not finish then
            return false
        end

        local delta = finish - start
        local params = makeParams(ignoreList)
        local result = workspace:Raycast(start, delta, params)
        return result == nil
    end

    return Raycast
end
