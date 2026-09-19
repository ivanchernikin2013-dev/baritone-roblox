return function(Time)
    local Blacklist = {}
    local data = {}

    function Blacklist.Add(instance)
        if not instance then return false end
        data[instance] = Time.Now()
        return true
    end

    function Blacklist.Remove(instance)
        if instance then
            data[instance] = nil
        end
    end

    function Blacklist.IsBlacklisted(instance)
        return instance ~= nil and data[instance] ~= nil
    end

    function Blacklist.GetAll()
        local result = {}
        for key in pairs(data) do
            table.insert(result, key)
        end
        return result
    end

    function Blacklist.Clear()
        data = {}
    end

    return Blacklist
end
