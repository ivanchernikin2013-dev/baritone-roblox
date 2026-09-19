return function(Logger)
    local Scheduler = {}
    Scheduler.__index = Scheduler

    function Scheduler.new()
        return setmetatable({
            queue = {},
        }, Scheduler)
    end

    function Scheduler:Schedule(name, delay, callback)
        table.insert(self.queue, {
            name = name,
            due = os.clock() + (delay or 0),
            callback = callback,
        })
        return name
    end

    function Scheduler:Cancel(name)
        for index, entry in ipairs(self.queue) do
            if entry.name == name then
                table.remove(self.queue, index)
                return true
            end
        end
        return false
    end

    function Scheduler:Flush()
        local now = os.clock()
        for index = #self.queue, 1, -1 do
            local entry = self.queue[index]
            if entry and entry.due <= now then
                table.remove(self.queue, index)
                if type(entry.callback) == "function" then
                    local ok, err = pcall(entry.callback)
                    if not ok and Logger then
                        Logger.Warn("Scheduler callback error: " .. tostring(err))
                    end
                end
            end
        end
    end

    return Scheduler.new()
end
