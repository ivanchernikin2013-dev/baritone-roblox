return function(Player)
    local Camera = {}

    function Camera.Follow(camera, targetPos)
        if not camera or not targetPos then return end
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
    end

    return Camera
end
