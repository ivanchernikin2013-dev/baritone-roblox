local Pool = {}

function Pool.new(factory)
    return {
        factory = factory or function() return {} end,
        items = {},
    }
end

function Pool:Acquire(...)
    local item = table.remove(self.items)
    if item then
        return item
    end
    return self.factory(...)
end

function Pool:Release(item)
    if item then
        table.insert(self.items, item)
    end
end

function Pool:Clear()
    self.items = {}
end

return Pool
