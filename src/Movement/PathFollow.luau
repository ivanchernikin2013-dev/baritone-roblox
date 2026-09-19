return function(Config, Logger, AStar, Grid, Raycast)
    local PathFollow = {}
    PathFollow.__index = PathFollow

    function PathFollow.new()
        return setmetatable({
            path = {},
            index = 1,
        }, PathFollow)
    end

    function PathFollow:Clear()
        self.path = {}
        self.index = 1
    end

    function PathFollow:Build(start, goal, grid, options)
        local path, status = AStar.Find(start, goal, grid, Raycast, options)
        if not path then
            Logger.Warn("Path not found: " .. tostring(status))
            self.path = {}
            self.index = 1
            return {}
        end

        self.path = path
        self.index = 1
        return self.path
    end

    function PathFollow:Next()
        if #self.path == 0 then
            return nil
        end

        local current = self.path[self.index]
        self.index = math.min(self.index + 1, #self.path)
        return current
    end

    return PathFollow.new()
end
