--==================================================
-- YOKUDO HUB - EGG COLLECT (2 ROUNDS Y) - WALK TP
-- Round 1: Check → Walk TP → Lock → Collect → Y Change (1)
-- Wait Y Return → Round 2: Walk TP → Lock → Collect → Y Change (2)
-- Safe Zone: Walk TP → Fast Reset
-- TARGET_ID: From Auto Farming Tab
-- Safe Zone: (533, 70, -366)
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Container = workspace:WaitForChild("AreaEggSlotsClient")

--==================================================
-- EVENT
--==================================================

local Event = nil

local success, result = pcall(function()
    return ReplicatedStorage.Packages.Networking["RF/EggWorld/AskFieldEggCarry"]
end)

if not success or not result then
    warn("[YOKUDO] Event not found")
    return
end

Event = result
print("[YOKUDO] Event found:", Event.ClassName)

--==================================================
-- SETTINGS
--==================================================

local TARGET_ID = nil
local SAFE_ZONE = Vector3.new(533, 70, -366)

local WALK_SPEED = 1000
local RETURN_SPEED = 1000
local SHOT_DISTANCE = 30
local LOCK_BEHIND = 3
local LOCK_HEIGHT = 3
local ARRIVE_DISTANCE = 2
local SAFE_LOCK_DISTANCE = 3

local MIN_FLY_DISTANCE = 4
local Y_CHANGE_THRESHOLD = 1
local Y_RETURN_THRESHOLD = 1

local LOOP_INTERVAL = 0.05

-- TARGET
local TargetEgg = nil
local YOriginal = nil
local YChanged = nil
local ConfirmCount = 0
local IsGoingSafe = false
local IsWaitingReturn = false
local LockedCFrame = nil
local IsLocked = false

--==================================================
-- STATE
--==================================================

local Running = false
local CurrentStep = "idle"
local WalkConnection = nil
local LockConnection = nil
local CollectConnection = nil
local HeartbeatConnection = nil
local MainLoopConnection = nil

local SavedWalkSpeed = nil
local SavedJumpPower = nil
local SavedJumpHeight = nil
local SavedUseJumpPower = nil

--==================================================
-- GET HUMANOID
--==================================================

local function GetHumanoid()
    local Char = Player.Character
    if not Char then return nil, nil end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    return Hum, Root
end

--==================================================
-- SAVE / RESTORE
--==================================================

local function SaveStats()
    local Hum = GetHumanoid()
    if not Hum then return end
    SavedWalkSpeed = Hum.WalkSpeed
    SavedJumpPower = Hum.JumpPower
    SavedJumpHeight = Hum.JumpHeight
    SavedUseJumpPower = Hum.UseJumpPower
end

local function RestoreStats()
    local Hum = GetHumanoid()
    if not Hum then return end
    if SavedWalkSpeed ~= nil then pcall(function() Hum.WalkSpeed = SavedWalkSpeed end) end
    if SavedJumpPower ~= nil then pcall(function() Hum.JumpPower = SavedJumpPower end) end
    if SavedJumpHeight ~= nil then pcall(function() Hum.JumpHeight = SavedJumpHeight end) end
    if SavedUseJumpPower ~= nil then pcall(function() Hum.UseJumpPower = SavedUseJumpPower end) end
end

--==================================================
-- CLEANUP
--==================================================

local function CleanupMovers()
    if WalkConnection then
        WalkConnection:Disconnect()
        WalkConnection = nil
    end
    if LockConnection then
        LockConnection:Disconnect()
        LockConnection = nil
    end
    local Hum, Root = GetHumanoid()
    if Hum then
        pcall(function()
            Hum.PlatformStand = false
            if Root then
                Hum:MoveTo(Root.Position)
            end
        end)
    end
    if Root then
        pcall(function()
            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    IsLocked = false
end

--==================================================
-- FIND EGG
--==================================================

local function FindEggInContainer()
    if not Container then return nil end
    if not TARGET_ID then return nil end
    local Direct = Container:FindFirstChild(TARGET_ID)
    if Direct then return Direct end
    for _, Desc in ipairs(Container:GetDescendants()) do
        if Desc.Name == TARGET_ID then return Desc end
    end
    return nil
end

local function FindEggInWorkspace()
    if not TARGET_ID then return nil end
    local WSEgg = workspace:FindFirstChild(TARGET_ID)
    if WSEgg then return WSEgg end
    for _, Desc in ipairs(workspace:GetChildren()) do
        if Desc.Name == TARGET_ID then return Desc end
    end
    return nil
end

local function GetEggPosition(Egg)
    if not Egg then return nil end
    if Egg:IsA("Model") then
        if Egg.PrimaryPart then return Egg.PrimaryPart.Position end
        local Part = Egg:FindFirstChildWhichIsA("BasePart")
        if Part then return Part.Position end
    elseif Egg:IsA("BasePart") then
        return Egg.Position
    end
    return nil
end

local function GetEggY(Egg)
    local Pos = GetEggPosition(Egg)
    if not Pos then return nil end
    return math.floor(Pos.Y)
end

local function GetEggDistance(Egg)
    local Hum, Root = GetHumanoid()
    if not Root then return 9999 end
    local EggPos = GetEggPosition(Egg)
    if not EggPos then return 9999 end
    return (EggPos - Root.Position).Magnitude
end

--==================================================
-- GET LOCK POSITION (Behind Egg 3)
--==================================================

local function GetLockCFrame(EggPos)
    local Hum, Root = GetHumanoid()
    if not Root then return CFrame.new(EggPos + Vector3.new(0, LOCK_HEIGHT, 0)) end

    local Dir = (EggPos - Root.Position)
    local FlatDir = Vector3.new(Dir.X, 0, Dir.Z)

    if FlatDir.Magnitude > 0.1 then
        FlatDir = FlatDir.Unit
    else
        FlatDir = Vector3.new(0, 0, 1)
    end

    local LockPos = EggPos - (FlatDir * LOCK_BEHIND) + Vector3.new(0, LOCK_HEIGHT, 0)

    return CFrame.new(LockPos, EggPos)
end

--==================================================
-- REMOTE COLLECT
--==================================================

local function RemoteCollectEgg()
    if not Event or not TARGET_ID then return false end

    local success, result = pcall(function()
        return Event:InvokeServer({
            Uid = TARGET_ID
        })
    end)

    return success
end

--==================================================
-- LOCK AT EGG
--==================================================

local function StartLock(TargetCFrame)
    IsLocked = true
    LockedCFrame = TargetCFrame

    if LockConnection then
        LockConnection:Disconnect()
    end

    LockConnection = RunService.Heartbeat:Connect(function()
        if not IsLocked then return end
        if not Running then
            if LockConnection then LockConnection:Disconnect() LockConnection = nil end
            return
        end

        local Hum, Root = GetHumanoid()
        if not Root then return end

        Root.CFrame = LockedCFrame
        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function StopLock()
    IsLocked = false
    LockedCFrame = nil

    if LockConnection then
        LockConnection:Disconnect()
        LockConnection = nil
    end
end

--==================================================
-- WALK TP (with Shot TP 30 + Lock)
--==================================================

local function WalkTP(Destination, Speed, UseShotTP, LockAfter, Callback)
    CleanupMovers()

    local Hum, Root = GetHumanoid()
    if not Hum or not Root then return end
    if Hum.Health <= 0 then return end

    Hum.WalkSpeed = Speed

    local LockCF = GetLockCFrame(Destination)

    local StartTime = tick()
    local ShotDone = false
    local IsFinished = false

    WalkConnection = RunService.Heartbeat:Connect(function()
        if IsFinished then return end

        if not Running then
            IsFinished = true
            CleanupMovers()
            return
        end

        local Hum2, Root2 = GetHumanoid()
        if not Hum2 or not Root2 then
            IsFinished = true
            CleanupMovers()
            return
        end
        if Hum2.Health <= 0 then return end

        if Hum2.WalkSpeed ~= Speed then
            Hum2.WalkSpeed = Speed
        end

        local CurrentPos = Root2.Position
        local Distance = (Destination - CurrentPos).Magnitude

        -- SHOT TP ពេលជិត 30 → LOCK ភ្លាម!
        if UseShotTP and Distance <= SHOT_DISTANCE and not ShotDone then
            ShotDone = true
            IsFinished = true

            if WalkConnection then WalkConnection:Disconnect() WalkConnection = nil end

            Hum2:MoveTo(Root2.Position)
            Hum2.WalkSpeed = SavedWalkSpeed or 16

            Root2.CFrame = LockCF
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero

            if LockAfter then
                StartLock(LockCF)
            end

            if Callback then Callback() end
            return
        end

        -- SAFE ZONE (Fast Reset)
        if Speed == RETURN_SPEED then
            if Distance <= SAFE_LOCK_DISTANCE then
                IsFinished = true
                if WalkConnection then WalkConnection:Disconnect() WalkConnection = nil end

                Hum2:MoveTo(Root2.Position)
                Hum2.WalkSpeed = SavedWalkSpeed or 16

                Root2.CFrame = CFrame.new(SAFE_ZONE)
                Root2.AssemblyLinearVelocity = Vector3.zero
                Root2.AssemblyAngularVelocity = Vector3.zero

                -- Fast Reset
                IsGoingSafe = false
                FullReset()

                if Callback then Callback() end
                return
            end
        end

        -- Arrived (no Shot TP)
        if not UseShotTP and Distance <= ARRIVE_DISTANCE then
            IsFinished = true
            if WalkConnection then WalkConnection:Disconnect() WalkConnection = nil end

            Hum2:MoveTo(Root2.Position)
            Hum2.WalkSpeed = SavedWalkSpeed or 16

            if LockAfter then
                StartLock(LockCF)
            end

            if Callback then Callback() end
            return
        end

        -- Timeout
        if tick() - StartTime > 15 then
            IsFinished = true
            if WalkConnection then WalkConnection:Disconnect() WalkConnection = nil end
            Hum2:MoveTo(Root2.Position)
            Hum2.WalkSpeed = SavedWalkSpeed or 16
            if Callback then Callback() end
            return
        end

        -- Move
        Hum2:MoveTo(Destination)
    end)
end

--==================================================
-- AUTO COLLECT
--==================================================

local function StartAutoCollect()
    if CollectConnection then
        CollectConnection:Disconnect()
    end

    CollectConnection = RunService.Heartbeat:Connect(function()
        if not Running then
            if CollectConnection then CollectConnection:Disconnect() CollectConnection = nil end
            return
        end
        if IsGoingSafe then return end
        if IsWaitingReturn then return end

        RemoteCollectEgg()
    end)
end

local function StopAutoCollect()
    if CollectConnection then
        CollectConnection:Disconnect()
        CollectConnection = nil
    end
end

--==================================================
-- START ROUND 2 (Walk TP + Collect)
--==================================================
local function StartRound2()
    IsWaitingReturn = false
    CurrentStep = "to_egg_2"

    local CurrentEgg = workspace:FindFirstChild(TARGET_ID) or (Container and Container:FindFirstChild(TARGET_ID))
    if CurrentEgg then
        TargetEgg = CurrentEgg
        local EggPos = GetEggPosition(CurrentEgg)
        if EggPos then
            WalkTP(EggPos, WALK_SPEED, true, true, function()
                StartAutoCollect()
                print("[YOKUDO] Round 2: Locked & Collecting")
            end)
        end
    else
        task.wait(0.5)
        StartRound2()
    end
end

--==================================================
-- HEARTBEAT - CHECK Y
--==================================================

local function StartHeartbeat()
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
    end

    HeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not Running then return end
        if IsGoingSafe then return end

        local Hum, Root = GetHumanoid()
        if not Hum or not Root then return end
        if Hum.Health <= 0 then return end

        local CurrentEgg = workspace:FindFirstChild(TARGET_ID) or (Container and Container:FindFirstChild(TARGET_ID))
        local CurrentY = nil

        if CurrentEgg then
            CurrentY = GetEggY(CurrentEgg)
        end

        -- ============================================
        -- WAIT Y RETURN (Round 2)
        -- ============================================
        if IsWaitingReturn then
            if CurrentY and YOriginal then
                local YDiff = math.abs(CurrentY - YOriginal)

                if YDiff <= Y_RETURN_THRESHOLD then
                    -- Y ត្រឡប់មកដើម → Start Round 2
                    StartRound2()
                end
            end
            return
        end

        -- ============================================
        -- CHECK Y CHANGE
        -- ============================================
        if CurrentY and YOriginal then
            local YDiff = math.abs(CurrentY - YOriginal)

            if YDiff >= Y_CHANGE_THRESHOLD then
                -- Round 1 → Y Change (1) → Wait Return
                if ConfirmCount == 0 then
                    ConfirmCount = 1
                    YChanged = CurrentY

                    StopAutoCollect()
                    StopLock()

                    IsWaitingReturn = true
                    TargetEgg = nil
                    CurrentStep = "idle"

                    print("[YOKUDO] Round 1: Y Changed! Waiting for Y Return")

                -- Round 2 → Y Change (2) → Safe Zone
                elseif ConfirmCount == 1 then
                    ConfirmCount = 2

                    StopAutoCollect()
                    StopLock()

                    IsGoingSafe = true

                    print("[YOKUDO] Round 2: Y Changed! Walk to Safe Zone")

                    WalkTP(SAFE_ZONE, RETURN_SPEED, false, false, function()
                        -- Fast Reset (WalkTP បាន FullReset រួច)
                    end)
                end
            end
        end
    end)
end

local function StopHeartbeat()
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end
end

--==================================================
-- FULL RESET (Fast)
--==================================================

function FullReset()
    -- 1. Set Flags ភ្លាមៗ
    Running = false
    CurrentStep = "idle"
    IsGoingSafe = false
    IsWaitingReturn = false
    IsLocked = false

    TargetEgg = nil
    YOriginal = nil
    YChanged = nil
    ConfirmCount = 0
    LockedCFrame = nil

    -- 2. Disconnect Connections ភ្លាមៗ
    if WalkConnection then WalkConnection:Disconnect() WalkConnection = nil end
    if LockConnection then LockConnection:Disconnect() LockConnection = nil end
    if CollectConnection then CollectConnection:Disconnect() CollectConnection = nil end
    if HeartbeatConnection then HeartbeatConnection:Disconnect() HeartbeatConnection = nil end
    if MainLoopConnection then MainLoopConnection:Disconnect() MainLoopConnection = nil end

    -- 3. Cleanup Movers ភ្លាមៗ
    local Hum, Root = GetHumanoid()
    if Hum then
        pcall(function()
            Hum.PlatformStand = false
            if Root then Hum:MoveTo(Root.Position) end
        end)
    end
    if Root then
        pcall(function()
            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    -- 4. Restore Stats
    pcall(RestoreStats)

    print("[YOKUDO] Full Reset")
end

--==================================================
-- MAIN LOOP
--==================================================

local function StartMainLoop()
    if MainLoopConnection then MainLoopConnection:Disconnect() MainLoopConnection = nil end

    MainLoopConnection = RunService.Heartbeat:Connect(function()
        if not Running then return end
        if IsGoingSafe then return end
        if IsWaitingReturn then return end

        local Hum, Root = GetHumanoid()
        if not Hum or not Root then return end
        if Hum.Health <= 0 then return end

        local CachedSpawnEgg = FindEggInContainer()
        local CachedWSEgg = FindEggInWorkspace()

        -- ROUND 1
        if CurrentStep == "idle" and ConfirmCount == 0 then
            local EggFound = CachedWSEgg or CachedSpawnEgg

            if EggFound then
                local EggPos = GetEggPosition(EggFound)
                if EggPos then
                    local Dist = GetEggDistance(EggFound)
                    if Dist > MIN_FLY_DISTANCE then
                        TargetEgg = EggFound
                        YOriginal = GetEggY(EggFound)

                        CurrentStep = "to_egg_1"

                        WalkTP(EggPos, WALK_SPEED, true, true, function()
                            StartAutoCollect()
                        end)
                    end
                end
            end
        end
    end)
end

--==================================================
-- ENABLE / DISABLE (Fast)
--==================================================

local function Enable()
    if Running then return end
    if not Event then warn("[YOKUDO] Event not found") return end
    if not TARGET_ID then warn("[YOKUDO] No Target ID") return end

    FullReset()

    Running = true
    CurrentStep = "idle"
    ConfirmCount = 0
    IsGoingSafe = false
    IsWaitingReturn = false
    YOriginal = nil
    YChanged = nil
    SaveStats()

    StartHeartbeat()
    StartMainLoop()

    print("[YOKUDO] Teleport System: ON")
end

local function Disable()
    FullReset()
    print("[YOKUDO] Teleport System: OFF (Fast Reset)")
end

local function SetTargetId(Id)
    TARGET_ID = Id
    print("[YOKUDO] Teleport System Target ID: " .. tostring(Id))
end

local function ResetState()
    FullReset()
    print("[YOKUDO] Teleport System: State Reset")
end

--==================================================
-- EXPORT
--==================================================

_G.YOKUDO_TeleportSystem = {
    Enable = Enable,
    Disable = Disable,
    SetTargetId = SetTargetId,
    ResetState = ResetState,
    IsEnabled = function() return Running end,
    GetTargetId = function() return TARGET_ID end
}

print("✅ TeleportSystem Feature Loaded (Walk TP + Round 2 Fixed)")
