return function(BASE)
    local cache = {}

    local function resolvePath(name)
        if type(BASE) == "string" and (BASE:sub(1, 4) == "http" or BASE:sub(1, 5) == "https") then
            return BASE .. name .. ".luau"
        end

        if type(BASE) == "string" and BASE ~= "" then
            return BASE .. name .. ".luau"
        end

        return name .. ".luau"
    end

    local function load(name)
        if cache[name] then
            return cache[name]
        end

        local url = resolvePath(name)
        local ok, src = pcall(function()
            return game:HttpGet(url)
        end)

        if not ok or type(src) ~= "string" or #src < 10 then
            local module = script:FindFirstChild(name)
            if module and module:IsA("ModuleScript") then
                src = module.Source
            else
                error("[Baritone] Failed to load: " .. name .. " (URL: " .. tostring(url) .. ")")
            end
        end

        local chunk = loadstring(src)
        if not chunk then
            error("[Baritone] Compile failed: " .. name)
        end

        local result = chunk()
        if type(result) == "function" then
            result = result()
        end

        cache[name] = result
        return result
    end

    local Config = load("Core/Config")
    local Logger = load("Core/Logger")
    local Events = load("Core/Events")
    local State = load("Core/State")
    local Scheduler = load("Core/Scheduler")(Logger)
    local Feature = load("Core/Feature")

    local Vector = load("Util/Vector")
    local Table = load("Util/Table")
    local StringUtil = load("Util/String")
    local Time = load("Util/Time")
    local Player = load("Util/Player")
    local Entity = load("Util/Entity")
    local Retry = load("Util/Retry")
    local RateLimit = load("Util/RateLimit")(Time)
    local Signal = load("Util/Signal")
    local Pool = load("Util/Pool")

    local Raycast = load("World/Raycast")(Player)
    local Obstacle = load("World/Obstacle")(Config, Raycast, Vector)
    local Grid = load("World/Grid")(Vector, Config)
    local Cache = load("World/Cache")
    local Terrain = load("World/Terrain")(Raycast, Config)

    local AStar = load("Math/AStar")(Vector, Config)
    local Interpolation = load("Math/Interpolation")
    local Bezier = load("Math/Bezier")(Interpolation)
    local Noise = load("Math/Noise")

    local Scanner = load("Target/Scanner")(Config, Player, Entity, Cache)
    local Filter = load("Target/Filter")
    local Blacklist = load("Target/Blacklist")(Time)
    local Tracker = load("Target/Tracker")(Time)
    local Prioritizer = load("Target/Prioritizer")
    local Validator = load("Target/Validator")(Entity)

    local Walk = load("Movement/Walk")(Config, Raycast, Terrain, Vector)
    local Fly = load("Movement/Fly")(Config, Raycast, Obstacle)
    local AntiStuck = load("Movement/AntiStuck")(Config, Time, Vector)
    local WallFollow = load("Movement/WallFollow")(Config, Raycast, Vector, Time)
    local PathFollow = load("Movement/PathFollow")(Config, Logger, AStar, Grid, Raycast)
    local Humanizer = load("Movement/Humanizer")(Config, Noise, Interpolation, Time)
    local Camera = load("Movement/Camera")(Player)
    local Movement = load("Movement/init")(Config, Logger, Walk, Fly, AntiStuck, WallFollow, PathFollow, Humanizer, Camera, Obstacle, Raycast, Terrain)

    local Encoder = load("Combat/Encoder")(Math)
    local Cooldown = load("Combat/Cooldown")(Time, Config)
    local Swing = load("Combat/Swing")(Encoder, Cooldown, Player)
    local Tool = load("Combat/Tool")(Player)

    local AntiAFK = load("Safety/AntiAFK")(Player)
    local Focus = load("Safety/Focus")(Player)
    local Pattern = load("Safety/Pattern")(Config, Time, Noise)
    local Guard = load("Safety/Guard")(Config, Logger, Player, Events)

    local Stats = load("Runner/Stats")(Time)
    local Recovery = load("Runner/Recovery")(Config, Logger, Events, Player, Movement, Stats, Blacklist, Tracker)
    local Reporter = load("Runner/Reporter")(Logger, Stats)
    local Watchdog = load("Runner/Watchdog")(Config, Logger, Events, Scheduler)
    local Runner = load("Runner/Runner")(Config, Logger, Events, State, Scheduler,
        Player, Entity, Retry, Raycast, Obstacle,
        Scanner, Filter, Blacklist, Tracker, Prioritizer, Validator,
        Movement, Swing, Tool, Focus, Pattern, Guard,
        Stats, Recovery, Reporter)

    local Baritone = {}
    Baritone.Version = "3.1.0"
    Baritone.Config = Config
    Baritone.Logger = Logger
    Baritone.Events = Events
    Baritone.State = State
    Baritone.Stats = Stats
    Baritone.Scanner = Scanner
    Baritone._paused = false
    Baritone._destroyed = false

    function Baritone.Start()
        if Baritone._destroyed then return end
        if Runner.IsRunning() then return end
        Baritone._paused = false
        Stats.Reset()
        Reporter.OnStart()
        Watchdog.Start(Runner)
        AntiAFK.Start()
        Runner.Start()
        Events.Emit("start")
        Logger.Info("Bariton v" .. Baritone.Version .. " started")
    end

    function Baritone.Stop()
        if not Runner.IsRunning() then return end
        Runner.Stop()
        Watchdog.Stop()
        AntiAFK.Stop()
        Reporter.OnStop()
        Baritone._paused = false
        Events.Emit("stop")
        Logger.Info("Bariton stopped")
    end

    function Baritone.Pause()
        if not Runner.IsRunning() then return end
        Baritone._paused = true
        State.Set(State.States.PAUSED)
        Events.Emit("pause")
    end

    function Baritone.Resume()
        if not Runner.IsRunning() then return end
        Baritone._paused = false
        Events.Emit("resume")
    end

    function Baritone.IsPaused() return Baritone._paused end
    function Baritone.IsRunning() return Runner.IsRunning() and not Baritone._paused end
    function Baritone.Tick() Runner.TickOnce() end

    function Baritone.Destroy()
        Baritone.Stop()
        pcall(function() Config.Reset() end)
        pcall(function() Events.Clear() end)
        pcall(function() State.Reset() end)
        pcall(function() Blacklist.Clear() end)
        pcall(function() Tracker.ClearHistory() end)
        pcall(function() Tool.EnsureAny() end)
        Baritone._destroyed = true
    end

    function Baritone.SetConfig(key, value) return Config.Set(key, value) end
    function Baritone.GetConfig(key) return Config.Get(key) end
    function Baritone.GetAllConfig() return Config.All() end
    function Baritone.GetStats() return Stats.GetAll() end
    function Baritone.GetStatsFormatted() return Stats.Format() end
    function Baritone.GetCurrentTree() return Runner.GetCurrentTree() end
    function Baritone.GetState() return State.GetName() end
    function Baritone.GetBlacklist() return Blacklist.GetAll() end
    function Baritone.ClearBlacklist() Blacklist.Clear() end
    function Baritone.Scan() return Scanner.ScanAll() end

    function Baritone.On(event, callback) return Events.On(event, callback) end
    function Baritone.Off(event, callback) return Events.Off(event, callback) end
    function Baritone.SetCallback(event, callback) return Events.On(event, callback) end
    function Baritone.Emit(event, ...) Events.Emit(event, ...) end

    local PRESETS = {
        safe = {
            MoveMode = "Walk", WalkSpeed = 14, FlySpeed = 18, FlyHeight = 3,
            ChopDistance = 5, SwingCooldown = 0.5, ObstacleRayLength = 8,
            MaxStuckTime = 1.0, HardStuckTime = 3.0, SearchRange = 100,
            PathfindEnabled = true, PathfindMaxNodes = 300, GridSize = 6,
            JitterEnabled = true, JitterAmount = 0.25,
            RandomDelay = true, RandomDelayMin = 0.05, RandomDelayMax = 0.2,
            CliffDetectionRange = 4, CliffMaxDrop = 10, EdgeSafetyMargin = 2,
            AvoidWater = true, AutoVaultEnabled = true, AutoJumpEnabled = true,
        },
        balanced = {
            MoveMode = "Walk", WalkSpeed = 18, FlySpeed = 25, FlyHeight = 4,
            ChopDistance = 6, SwingCooldown = 0.35, ObstacleRayLength = 6,
            MaxStuckTime = 1.5, HardStuckTime = 4.0, SearchRange = 150,
            PathfindEnabled = true, PathfindMaxNodes = 200, GridSize = 8,
            JitterEnabled = true, JitterAmount = 0.15,
            RandomDelay = true, RandomDelayMin = 0.02, RandomDelayMax = 0.12,
            CliffDetectionRange = 3, CliffMaxDrop = 12, EdgeSafetyMargin = 1.5,
        },
        fast = {
            MoveMode = "Fly", WalkSpeed = 22, FlySpeed = 40, FlyHeight = 6,
            ChopDistance = 7, SwingCooldown = 0.25, ObstacleRayLength = 5,
            MaxStuckTime = 2.0, HardStuckTime = 4.0, SearchRange = 250,
            PathfindEnabled = false, PathfindMaxNodes = 100, GridSize = 10,
            JitterEnabled = true, JitterAmount = 0.1,
            RandomDelay = true, RandomDelayMin = 0, RandomDelayMax = 0.08,
        },
    }

    function Baritone.SetPreset(name)
        local p = PRESETS[name]
        if not p then
            Logger.Warn("Unknown preset: " .. tostring(name))
            return false
        end

        for k, v in pairs(p) do
            Config.Set(k, v)
        end

        Logger.Info("Preset applied: " .. name)
        return true
    end

    function Baritone.SetWalkMode() Config.Set("MoveMode", "Walk") end
    function Baritone.SetFlyMode() Config.Set("MoveMode", "Fly") end
    function Baritone.GetPresets()
        local out = {}
        for key in pairs(PRESETS) do
            table.insert(out, key)
        end
        return out
    end

    return Baritone
end
