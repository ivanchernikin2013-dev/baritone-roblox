local Config = {}

local listeners = {}

local defaults = {
    TreeNames = {
        ["Small Tree"] = true,
        ["Apple Tree"] = true,
        ["Orange Tree"] = true,
        ["Lemon Tree"] = true,
        ["Banana Tree"] = true,
        ["Coconut Tree"] = true,
        ["Volcanic Tree"] = true,
        ["Swoll Tree"] = true,
        ["Palm Tree"] = true,
        ["Jungle Tree"] = true,
        ["Odd Tree"] = true,
    },
    TargetMode = "Nearest",
    SearchRange = 150,
    MoveMode = "Walk",
    WalkSpeed = 16,
    FlySpeed = 25,
    FlyHeight = 4,
    ChopDistance = 6,
    SwingCooldown = 0.3,
    ObstacleRayLength = 6,
    ObstacleClimbBoost = 1.6,
    ObstacleSideStep = 1.2,
    ObstacleSideSamples = 8,
    ObstacleSampleAngle = 60,
    CliffDetectionRange = 3,
    CliffMaxDrop = 12,
    EdgeSafetyMargin = 1.5,
    GroundCheckInterval = 0.2,
    AutoJumpEnabled = true,
    JumpGapMaxWidth = 4,
    JumpCooldown = 0.8,
    AutoVaultEnabled = true,
    VaultMaxHeight = 3,
    VaultRayLength = 3,
    StepUpEnabled = true,
    StepUpMaxHeight = 1.5,
    AvoidWater = true,
    WaterRayLength = 3,
    WaterPenalty = 10,
    SlopeMaxAngle = 45,
    SlopePenalty = 3,
    WallFollowEnabled = true,
    WallFollowMaxTime = 3,
    WallFollowStepSize = 1.5,
    MaxStuckTime = 1.5,
    HardStuckTime = 4.0,
    StuckJumpCooldown = 0.6,
    StuckRelocateRadius = 6,
    BlacklistUnreachable = true,
    TreeBlacklistTime = 15,
    SkipWhenGuiOpen = true,
    DebugLogging = false,
    TickRate = 0.05,
    PathfindEnabled = true,
    PathfindMaxNodes = 200,
    PathfindTimeout = 1.0,
    GridSize = 8,
    ReplanCooldown = 0.4,
    PathCostWater = 20,
    PathCostSlope = 5,
    PathCostNarrow = 2,
    PathCostJump = 4,
    AutoRecover = true,
    RecoverAttempts = 3,
    RecoverCooldown = 3.0,
    HealthCheck = true,
    MinHealth = 10,
    PrioritizeByDistance = true,
    PrioritizeByHealth = false,
    RandomDelay = true,
    RandomDelayMin = 0.02,
    RandomDelayMax = 0.12,
    JitterEnabled = true,
    JitterAmount = 0.15,
    JitterFrequency = 4.0,
    CameraFollow = true,
    WatchdogEnabled = true,
    WatchdogTimeout = 15.0,
    ReporterEnabled = true,
    ReporterInterval = 15,
}

local values = {}
for k, v in pairs(defaults) do
    if type(v) == "table" then
        local copy = {}
        for k2, v2 in pairs(v) do
            copy[k2] = v2
        end
        values[k] = copy
    else
        values[k] = v
    end
end

local validators = {
    MoveMode = function(v) return v == "Walk" or v == "Fly" end,
    SearchRange = function(v) return type(v) == "number" and v >= 10 and v <= 1000 end,
    WalkSpeed = function(v) return type(v) == "number" and v >= 1 and v <= 100 end,
    FlySpeed = function(v) return type(v) == "number" and v >= 1 and v <= 200 end,
    FlyHeight = function(v) return type(v) == "number" and v >= 0 and v <= 50 end,
    ChopDistance = function(v) return type(v) == "number" and v >= 2 and v <= 30 end,
    SwingCooldown = function(v) return type(v) == "number" and v >= 0.05 and v <= 5 end,
    ObstacleRayLength = function(v) return type(v) == "number" and v >= 2 and v <= 30 end,
    CliffDetectionRange = function(v) return type(v) == "number" and v >= 1 and v <= 20 end,
    CliffMaxDrop = function(v) return type(v) == "number" and v >= 1 and v <= 100 end,
    EdgeSafetyMargin = function(v) return type(v) == "number" and v >= 0 and v <= 10 end,
    VaultMaxHeight = function(v) return type(v) == "number" and v >= 0.5 and v <= 10 end,
    StepUpMaxHeight = function(v) return type(v) == "number" and v >= 0.5 and v <= 5 end,
    SlopeMaxAngle = function(v) return type(v) == "number" and v >= 5 and v <= 89 end,
    MaxStuckTime = function(v) return type(v) == "number" and v >= 0.1 and v <= 20 end,
    HardStuckTime = function(v) return type(v) == "number" and v >= 0.5 and v <= 60 end,
    TickRate = function(v) return type(v) == "number" and v >= 0.01 and v <= 1 end,
    PathfindMaxNodes = function(v) return type(v) == "number" and v >= 10 and v <= 5000 end,
    GridSize = function(v) return type(v) == "number" and v >= 2 and v <= 50 end,
    JitterAmount = function(v) return type(v) == "number" and v >= 0 and v <= 2 end,
    MinHealth = function(v) return type(v) == "number" and v >= 0 and v <= 100 end,
    WallFollowMaxTime = function(v) return type(v) == "number" and v >= 0.5 and v <= 30 end,
    WaterPenalty = function(v) return type(v) == "number" and v >= 0 and v <= 100 end,
    PathCostWater = function(v) return type(v) == "number" and v >= 0 and v <= 1000 end,
    PathCostSlope = function(v) return type(v) == "number" and v >= 0 and v <= 1000 end,
    PathCostNarrow = function(v) return type(v) == "number" and v >= 0 and v <= 1000 end,
    PathCostJump = function(v) return type(v) == "number" and v >= 0 and v <= 1000 end,
}

function Config.Get(key)
    return values[key]
end

function Config.Set(key, value)
    if values[key] == nil then
        return false, "unknown_key"
    end

    local validator = validators[key]
    if validator and not validator(value) then
        return false, "invalid_value"
    end

    local oldValue = values[key]
    values[key] = value

    for _, fn in ipairs(listeners) do
        pcall(fn, key, value, oldValue)
    end

    return true
end

function Config.All()
    local out = {}
    for key, val in pairs(values) do
        if type(val) == "table" then
            local copy = {}
            for k2, v2 in pairs(val) do
                copy[k2] = v2
            end
            out[key] = copy
        else
            out[key] = val
        end
    end
    return out
end

function Config.Reset()
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            local copy = {}
            for k2, v2 in pairs(value) do
                copy[k2] = v2
            end
            values[key] = copy
        else
            values[key] = value
        end
    end
end

function Config.OnChange(fn)
    table.insert(listeners, fn)
end

function Config.GetTrees()
    return values.TreeNames
end

return Config
