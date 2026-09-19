return function(Math)
    local Encoder = {}

    function Encoder.encodeMove(direction)
        if not direction then
            return 0
        end
        local magnitude = direction.Magnitude
        if magnitude == 0 then
            return 0
        end
        return direction.Unit
    end

    function Encoder.normalize(value)
        return value
    end

    return Encoder
end
