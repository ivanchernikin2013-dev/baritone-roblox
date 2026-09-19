local Interpolation = {}

function Interpolation.linear(a, b, t)
    return a + (b - a) * t
end

function Interpolation.smoothstep(a, b, t)
    local x = math.clamp(t, 0, 1)
    return a + (b - a) * (x * x * (3 - 2 * x))
end

function Interpolation.vector(a, b, t)
    return a:Lerp(b, t)
end

return Interpolation
