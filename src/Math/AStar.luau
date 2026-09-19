return function(Vector, Config)
    local AStar = {}

    local function heuristic(a, b)
        local x = a.X - b.X
        local y = a.Y - b.Y
        local z = a.Z - b.Z
        return math.sqrt(x * x + y * y + z * z)
    end

    local function makeNode(pos, g, h, parent)
        return {
            pos = pos,
            g = g or 0,
            h = h or 0,
            f = (g or 0) + (h or 0),
            parent = parent,
        }
    end

    function AStar.Find(start, goal, grid, raycast, options)
        options = options or {}
        local maxNodes = options.maxNodes or 200
        local timeout = options.timeout or 1.0
        local ignore = options.ignore
        local startT = tick()

        local startNode = makeNode(start, 0, heuristic(start, goal), nil)
        local open = { startNode }
        local openKeys = { [grid:ToKey(start)] = startNode }
        local closed = {}
        local expanded = 0

        while #open > 0 do
            if tick() - startT > timeout then
                return nil, "timeout"
            end
            if expanded > maxNodes then
                return nil, "max_nodes"
            end

            local bestIndex = 1
            for i = 2, #open do
                if open[i].f < open[bestIndex].f then
                    bestIndex = i
                end
            end

            local current = table.remove(open, bestIndex)
            local currentKey = grid:ToKey(current.pos)
            openKeys[currentKey] = nil

            if heuristic(current.pos, goal) < grid.size then
                local path = {}
                local node = current
                while node do
                    table.insert(path, 1, node.pos)
                    node = node.parent
                end
                return path, "ok"
            end

            closed[currentKey] = true
            expanded = expanded + 1

            for _, nextNode in ipairs(grid:Neighbors(current.pos)) do
                if closed[nextNode.key] then continue end
                if nextNode.weight > 0 then continue end

                local from = current.pos + Vector3.new(0, grid.size / 2, 0)
                local to = nextNode.pos + Vector3.new(0, grid.size / 2, 0)
                if raycast and not raycast.IsClear(from, to, ignore) then
                    local above = raycast.IsClear(from + Vector3.new(0, grid.size, 0), to + Vector3.new(0, grid.size, 0), ignore)
                    if not above then continue end
                end

                local step = heuristic(current.pos, nextNode.pos)
                local tentative = current.g + step
                local existing = openKeys[nextNode.key]

                if not existing then
                    local node = makeNode(nextNode.pos, tentative, heuristic(nextNode.pos, goal), current)
                    table.insert(open, node)
                    openKeys[nextNode.key] = node
                elseif tentative < existing.g then
                    existing.g = tentative
                    existing.f = tentative + existing.h
                    existing.parent = current
                end
            end
        end

        return nil, "no_path"
    end

    function AStar.Simplify(path)
        if not path or #path < 3 then
            return path
        end

        local output = { path[1] }
        local index = 1
        while index < #path do
            local nextIndex = math.min(index + 2, #path)
            while nextIndex <= #path and (path[nextIndex] - path[index]).Magnitude < 100 do
                nextIndex = nextIndex + 1
            end
            table.insert(output, path[nextIndex - 1])
            index = nextIndex - 1
        end

        if output[#output] ~= path[#path] then
            table.insert(output, path[#path])
        end
        return output
    end

    return AStar
end
