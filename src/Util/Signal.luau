local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({
        callbacks = {},
    }, Signal)
end

function Signal:Connect(callback)
    table.insert(self.callbacks, callback)
    return function()
        for index, value in ipairs(self.callbacks) do
            if value == callback then
                table.remove(self.callbacks, index)
                return true
            end
        end
        return false
    end
end

function Signal:Fire(...)
    for _, callback in ipairs(self.callbacks) do
        local ok, err = pcall(callback, ...)
        if not ok then
            warn("[Signal] callback error: " .. tostring(err))
        end
    end
end

return Signal
