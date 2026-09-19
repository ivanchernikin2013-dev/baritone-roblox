return function(Config, Raycast, Obstacle)
    local Fly = {}

    local function ensureBV(root)
        if not root then return nil end
        local bv = root:FindFirstChild("__BaritoneVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "__BaritoneVelocity"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.P = 3000
            bv.Parent = root
        end
        return bv
    end

    function Fly.Step(root, humanoid, targetPos, context)
        if not root or not humanoid then return false end
        local myPos = root.Position
        local delta = targetPos - myPos
        local dist = delta.Magnitude
        if dist < 0.5 then
            Fly.Stop(root)
            return true
        end

        local dir = delta.Unit
        local blocked = Obstacle.CheckAhead(root, dir, context and context.ignore)
        if blocked then
            local escape = Obstacle.FindEscapeDir(root, dir, context and context.ignore)
            if escape then
                dir = escape
            else
                Fly.Stop(root)
                return false
            end
        end

        local speed = Config.Get("FlySpeed") or 25
        local bv = ensureBV(root)
        if bv then
            bv.Velocity = dir * speed
        end
        return true
    end

    function Fly.Stop(root)
        if not root then return end
        local bv = root:FindFirstChild("__BaritoneVelocity")
        if bv then
            bv:Destroy()
        end
    end

    return Fly
end
