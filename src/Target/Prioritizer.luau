local Prioritizer = {}

function Prioritizer.sortByDistance(targets, origin)
    local items = {}
    for _, target in ipairs(targets) do
        if target then
            local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
            local pos = root and root.Position or target.Position or Vector3.zero
            table.insert(items, { target = target, distance = (pos - origin).Magnitude })
        end
    end

    table.sort(items, function(a, b)
        return a.distance < b.distance
    end)

    local output = {}
    for _, item in ipairs(items) do
        table.insert(output, item.target)
    end
    return output
end

return Prioritizer
