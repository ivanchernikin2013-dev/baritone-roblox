local StringUtil = {}

function StringUtil.trim(value)
    if value == nil then
        return ""
    end
    return tostring(value):match("^%s*(.-)%s*$")
end

function StringUtil.formatNumber(value, digits)
    digits = digits or 2
    return string.format("%." .. tostring(digits) .. "f", tonumber(value) or 0)
end

function StringUtil.split(value, separator)
    if value == nil then
        return {}
    end
    local result = {}
    for segment in string.gmatch(tostring(value), "([^" .. separator .. "]+)") do
        table.insert(result, segment)
    end
    return result
end

return StringUtil
