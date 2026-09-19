local Vector = {}

function Vector.new(x, y, z)
    return Vector3.new(x or 0, y or 0, z or 0)
end

function Vector.add(a, b)
    return a + b
end

function Vector.sub(a, b)
    return a - b
end

function Vector.mul(a, scalar)
    return a * scalar
end

function Vector.div(a, scalar)
    return a / scalar
end

function Vector.magnitude(v)
    return v.Magnitude
end

function Vector.distance(a, b)
    return (a - b).Magnitude
end

function Vector.normalize(v)
    if not v then
        return Vector3.zero
    end

    local magnitude = v.Magnitude
    if magnitude == 0 then
        return Vector3.zero
    end

    return v / magnitude
end

function Vector.lerp(a, b, t)
    return a:Lerp(b, t)
end

function Vector.clampMagnitude(v, maxMagnitude)
    local length = v.Magnitude
    if length <= maxMagnitude or length == 0 then
        return v
    end
    return (v / length) * maxMagnitude
end

return Vector
