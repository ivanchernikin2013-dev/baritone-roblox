local State = {}
State.__index = State

State.States = {
    IDLE = "IDLE",
    SCANNING = "SCANNING",
    MOVING = "MOVING",
    CHOPPING = "CHOPPING",
    STUCK = "STUCK",
    RECOVERING = "RECOVERING",
    PAUSED = "PAUSED",
}

function State.new(initial)
    local self = setmetatable({
        name = initial or State.States.IDLE,
        data = {},
    }, State)
    return self
end

function State:Set(name)
    self.name = name
    return name
end

function State:GetName()
    return self.name
end

function State:SetValue(key, value)
    self.data[key] = value
    return value
end

function State:GetValue(key, fallback)
    if self.data[key] == nil then
        return fallback
    end
    return self.data[key]
end

function State:Reset()
    self.data = {}
    self.name = State.States.IDLE
end

return State
