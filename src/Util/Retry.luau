local Retry = {}

function Retry.attempt(callback, retries, delaySeconds)
    local attempts = 0
    local maxAttempts = math.max(1, retries or 1)
    local waitTime = delaySeconds or 0

    while attempts < maxAttempts do
        local ok, result = pcall(callback)
        if ok then
            return result, true
        end

        attempts += 1
        if attempts >= maxAttempts then
            return result, false
        end

        if waitTime > 0 then
            task.wait(waitTime)
        end
    end

    return nil, false
end

return Retry
