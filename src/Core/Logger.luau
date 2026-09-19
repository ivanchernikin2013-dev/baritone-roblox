local Logger = {}

function Logger.Info(...)
    print("[Baritone] INFO:", ...)
end

function Logger.Warn(...)
    warn("[Baritone] WARN:", ...)
end

function Logger.Error(...)
    warn("[Baritone] ERROR:", ...)
end

function Logger.Debug(...)
    if _G and _G.__BARITONE_DEBUG then
        print("[Baritone] DEBUG:", ...)
    end
end

function Logger.Flush()
    return true
end

return Logger
