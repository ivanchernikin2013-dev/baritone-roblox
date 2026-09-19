return function(Encoder, Cooldown, Player)
    local Swing = {}

    function Swing.Send(targets)
        if not targets or #targets == 0 then
            return false
        end

        local humanoid = Player.GetHumanoid(Player.getLocalPlayer())
        if not humanoid then
            return false
        end

        if not Cooldown:canUse() then
            return false
        end

        Cooldown:use()
        return true
    end

    return Swing
end
