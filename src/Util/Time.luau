local Time = {}

function Time.Now()
    return os.clock()
end

function Time.Since(start)
    return os.clock() - start
end

function Time.Delay(seconds)
    if seconds and seconds > 0 then
        task.wait(seconds)
    end
end

return Time
