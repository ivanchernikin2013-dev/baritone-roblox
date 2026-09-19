local Noise = {}

function Noise.value(x, y, z)
    local value = math.sin(x * 12.9898 + y * 78.233 + z * 37.719) * 43758.5453
    return value - math.floor(value)
end

function Noise.smooth(x, y, z)
    local n = Noise.value(x, y, z)
    return n
end

return Noise
