local Cache = {}
Cache.__index = Cache

function Cache.new()
    return setmetatable({
        data = {},
    }, Cache)
end

function Cache:Set(key, value)
    self.data[key] = value
end

function Cache:Get(key, fallback)
    if self.data[key] == nil then
        return fallback
    end
    return self.data[key]
end

function Cache:Clear()
    self.data = {}
end

return Cache.new()
