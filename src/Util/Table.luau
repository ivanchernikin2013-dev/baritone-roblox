local Table = {}

function Table.copy(value)
    if type(value) ~= "table" then
        return value
    end

    local clone = {}
    for key, item in pairs(value) do
        clone[key] = Table.copy(item)
    end
    return clone
end

function Table.merge(a, b)
    local result = Table.copy(a or {})
    if type(b) ~= "table" then
        return result
    end

    for key, value in pairs(b) do
        result[key] = Table.copy(value)
    end
    return result
end

function Table.hasValue(list, value)
    if type(list) ~= "table" then
        return false
    end

    for _, item in pairs(list) do
        if item == value then
            return true
        end
    end
    return false
end

function Table.keys(list)
    local result = {}
    if type(list) ~= "table" then
        return result
    end

    for key in pairs(list) do
        table.insert(result, key)
    end
    return result
end

return Table
