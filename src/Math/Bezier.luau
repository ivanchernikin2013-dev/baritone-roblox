return function(Interpolation)
    local Bezier = {}

    function Bezier.quadratic(p0, p1, p2, t)
        local u = 1 - t
        return u * u * p0 + 2 * u * t * p1 + t * t * p2
    end

    function Bezier.cubic(p0, p1, p2, p3, t)
        local u = 1 - t
        return u * u * u * p0 + 3 * u * u * t * p1 + 3 * u * t * t * p2 + t * t * t * p3
    end

    return Bezier
end
