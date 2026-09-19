local Events = {}
Events.__index = Events

function Events.new()
    return setmetatable({
        listeners = {},
    }, Events)
end

function Events:On(eventName, callback)
    self.listeners[eventName] = self.listeners[eventName] or {}
    table.insert(self.listeners[eventName], callback)
    return callback
end

function Events:Off(eventName, callback)
    local list = self.listeners[eventName] or {}
    for index, fn in ipairs(list) do
        if fn == callback then
            table.remove(list, index)
            break
        end
    end
end

function Events:Emit(eventName, ...)
    local list = self.listeners[eventName] or {}
    for _, callback in ipairs(list) do
        local ok, err = pcall(callback, ...)
        if not ok then
            warn(string.format("[Events] %s failed: %s", tostring(eventName), tostring(err)))
        end
    end
end

function Events:Clear()
    self.listeners = {}
end

return Events
