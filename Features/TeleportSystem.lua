--==================================================
-- YOKUDO HUB - EGG COLLECT (2 COLLECT ONLY)
-- Logic:
-- 1. Check Egg Position (X,Y,Z) → Save YOriginal
-- 2. Calculate Distance from Character
-- 3. If > 4 → Fly TP to Egg
-- 4. Lock at Egg
-- 5. Check Y again → Save YOriginal (before Remote)
-- 6. Remote Collect (0.01s) until Egg Y Change
-- 7. Save YChanged → Wait Y Return
-- 8. Y Return → Fly TP → Lock → Collect (2)
-- 9. Collect 2 → Y Change (2) → Fly TP Safe Zone
-- 10. Safe Zone → Fast Reset
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

local FLY_SPEED = 1000
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
local COLLECT_INTERVAL = 0.01

--==================================================
-- STATE
--==================================================

local TargetEgg = nil
local YOriginal = nil      -- Y Original (Save before Remote)
local YChanged = nil       -- Y Changed (Save after Egg Y Change)
local CollectCount = 0     -- 0 = Not, 1 = Collect 1, 2 = Collect 2
local IsWaitingReturn = false
local IsGoingSafe = false
local LockedCFrame = nil
local IsLocked = false

local Running = false
local CurrentStep = "idle"
local FlyConnection = nil
local LockConnection = nil
local CollectConnection = nil
local HeartbeatConnection = nil
local MainLoopConnection = nil
local BodyVelocity = nil
local BodyGyro = nil

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
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if LockConnection then LockConnection:Disconnect() LockConnection = nil end
    if BodyVelocity then
        pcall(function()
            BodyVelocity.Velocity = Vector3.zero
            BodyVelocity.MaxForce = Vector3.zero
        end)
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    if BodyGyro then
        pcall(function() BodyGyro.MaxTorque = Vector3.zero end)
        BodyGyro:Destroy()
        BodyGyro = nil
    end
    local Hum, Root = GetHumanoid()
    if Hum then pcall(function() Hum.PlatformStand = false end) end
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

    if LockConnection then LockConnection:Disconnect() end

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
    if LockConnection then LockConnection:Disconnect() LockConnection = nil end
end

--==================================================
-- FLY TP (with Shot TP 30 + Lock)
--==================================================

local function FlyTP(Destination, Speed, UseShotTP, LockAfter, Callback)
    CleanupMovers()

    local Hum, Root = GetHumanoid()
    if not Hum or not Root then return end
    if Hum.Health <= 0 then return end

    local FlyPos = Vector3.new(Destination.X, Destination.Y + LOCK_HEIGHT, Destination.Z)
    local LockCF = GetLockCFrame(Destination)

    Hum.PlatformStand = true
    Hum.WalkSpeed = 0
    Hum.JumpPower = 0

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Name = "YokudoBV"
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.P = 1250
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = Root

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.Name = "YokudoBG"
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.P = 3000
    BodyGyro.D = 500
    BodyGyro.CFrame = Root.CFrame
    BodyGyro.Parent = Root

    local StartTime = tick()
    local Teleported = false

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Running then
            CleanupMovers()
            return
        end

        local Hum2, Root2 = GetHumanoid()
        if not Hum2 or not Root2 then
            CleanupMovers()
            return
        end
        if Hum2.Health <= 0 then return end
        if not BodyVelocity or not BodyGyro then
            CleanupMovers()
            return
        end

        local CurrentPos = Root2.Position
        local Direction = (FlyPos - CurrentPos)
        local HorizDist = Vector3.new(Direction.X, 0, Direction.Z).Magnitude
        local TotalDist = Direction.Magnitude

        -- SAFE ZONE
        if Speed == RETURN_SPEED then
            if HorizDist <= SAFE_LOCK_DISTANCE and not Teleported then
                Teleported = true
                CleanupMovers()

                Hum2.PlatformStand = false
                Root2.CFrame = CFrame.new(SAFE_ZONE)
                Root2.AssemblyLinearVelocity = Vector3.zero
                Root2.AssemblyAngularVelocity = Vector3.zero

                -- Fast Reset
                FastReset()

                if Callback then Callback() end
                return
            end
        end

        -- SHOT TP
        if UseShotTP and HorizDist <= SHOT_DISTANCE and not Teleported then
            Teleported = true
            CleanupMovers()

            Hum2.PlatformStand = false
            Root2.CFrame = LockCF
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero

            if LockAfter then
                StartLock(LockCF)
            end

            if Callback then Callback() end
            return
        end

        if Teleported then
            CleanupMovers()
            return
        end

        if tick() - StartTime > 15 then
            CleanupMovers()
            Hum2.PlatformStand = false
            if Callback then Callback() end
            return
        end

        if TotalDist > 1 then
            BodyVelocity.Velocity = Direction.Unit * Speed
        else
            BodyVelocity.Velocity = Vector3.zero
        end

        BodyGyro.CFrame = CFrame.new(CurrentPos, CurrentPos + Vector3.new(Direction.X, 0, Direction.Z))
    end)
end

--==================================================
-- AUTO COLLECT (0.01s)
--==================================================

local function StartAutoCollect()
    if CollectConnection then CollectConnection:Disconnect() end

    CollectConnection = RunService.Heartbeat:Connect(function()
        if not Running then
            if CollectConnection then CollectConnection:Disconnect() CollectConnection = nil end
            return
        end
        if IsWaitingReturn then return end
        if IsGoingSafe then return end

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
-- FAST RESET
--==================================================

function FastReset()
    -- Set Flags ភ្លាមៗ
    Running = false
    CurrentStep = "idle"
    CollectCount = 0
    IsWaitingReturn = false
    IsGoingSafe = false
    IsLocked = false
    TargetEgg = nil
    YOriginal = nil
    YChanged = nil
    LockedCFrame = nil

    -- Disconnect Connections ភ្លាមៗ
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if LockConnection then LockConnection:Disconnect() LockConnection = nil end
    if CollectConnection then CollectConnection:Disconnect() CollectConnection = nil end
    if HeartbeatConnection then HeartbeatConnection:Disconnect() HeartbeatConnection = nil end
    if MainLoopConnection then MainLoopConnection:Disconnect() MainLoopConnection = nil end

    -- Cleanup Movers
    if BodyVelocity then
        pcall(function()
            BodyVelocity.Velocity = Vector3.zero
            BodyVelocity.MaxForce = Vector3.zero
        end)
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    if BodyGyro then
        pcall(function() BodyGyro.MaxTorque = Vector3.zero end)
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    local Hum, Root = GetHumanoid()
    if Hum then pcall(function() Hum.PlatformStand = false end) end
    if Root then
        pcall(function()
            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    pcall(RestoreStats)

    print("[YOKUDO] Fast Reset")
end

--==================================================
-- START COLLECT 2 (Fly TP + Lock + Collect)
--==================================================
local function StartCollect2()
    IsWaitingReturn = false
    CurrentStep = "collect_2"

    local CurrentEgg = workspace:FindFirstChild(TARGET_ID) or (Container and Container:FindFirstChild(TARGET_ID))
    if CurrentEgg then
        TargetEgg = CurrentEgg

        -- Save Y Original (មុន Remote)
        YOriginal = GetEggY(CurrentEgg)
        print("[YOKUDO] Collect 2: Y Original:", YOriginal)

        local EggPos = GetEggPosition(CurrentEgg)
        if EggPos then
            FlyTP(EggPos, FLY_SPEED, true, true, function()
                CollectCount = 2
                StartAutoCollect()
                print("[YOKUDO] Collect 2: Locked & Collecting")
            end)
        end
    else
        task.wait(0.5)
        StartCollect2()
    end
end

--==================================================
-- HEARTBEAT - CHECK Y
--==================================================

local function StartHeartbeat()
    if HeartbeatConnection then HeartbeatConnection:Disconnect() end

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

        -- WAIT Y RETURN (After Collect 1)
        if IsWaitingReturn then
            if CurrentY and YOriginal then
                local YDiff = math.abs(CurrentY - YOriginal)

                if YDiff <= Y_RETURN_THRESHOLD then
                    StartCollect2()
                end
            end
            return
        end

        -- CHECK Y CHANGE
        if CurrentY and YOriginal then
            local YDiff = math.abs(CurrentY - YOriginal)

            if YDiff >= Y_CHANGE_THRESHOLD then
                -- Collect 1 → Y Change (1) → Wait Y Return
                if CollectCount == 1 then
                    CollectCount = 1.5
                    YChanged = CurrentY

                    StopAutoCollect()
                    StopLock()

                    IsWaitingReturn = true
                    TargetEgg = nil
                    CurrentStep = "wait_return"

                    print("[YOKUDO] Collect 1: Y Changed! Waiting for Y Return")

                -- Collect 2 → Y Change (2) → Safe Zone
                elseif CollectCount == 2 then
                    CollectCount = 3
                    YChanged = CurrentY

                    StopAutoCollect()
                    StopLock()

                    IsGoingSafe = true
                    CurrentStep = "going_safe"

                    print("[YOKUDO] Collect 2: Y Changed! Fly to Safe Zone")

                    FlyTP(SAFE_ZONE, RETURN_SPEED, false, false, function()
                        -- Fast Reset (FlyTP បាន Reset រួច)
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
-- MAIN LOOP (Collect 1 Only)
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

        -- COLLECT 1
        if CurrentStep == "idle" and CollectCount == 0 then
            local EggFound = CachedWSEgg or CachedSpawnEgg

            if EggFound then
                local EggPos = GetEggPosition(EggFound)
                if EggPos then
                    local Dist = GetEggDistance(EggFound)
                    if Dist > MIN_FLY_DISTANCE then
                        TargetEgg = EggFound

                        -- Save Y Original (មុន Remote)
                        YOriginal = GetEggY(EggFound)
                        print("[YOKUDO] Collect 1: Y Original:", YOriginal)

                        CollectCount = 1
                        CurrentStep = "collect_1"

                        FlyTP(EggPos, FLY_SPEED, true, true, function()
                            StartAutoCollect()
                            print("[YOKUDO] Collect 1: Locked & Collecting")
                        end)
                    end
                end
            end
        end
    end)
end

--==================================================
-- ENABLE / DISABLE
--==================================================

local function Enable()
    if Running then return end
    if not Event then warn("[YOKUDO] Event not found") return end
    if not TARGET_ID then warn("[YOKUDO] No Target ID") return end

    -- Reset ALL
    FastReset()

    -- Start Fresh
    Running = true
    CurrentStep = "idle"
    CollectCount = 0
    SaveStats()

    StartHeartbeat()
    StartMainLoop()

    print("[YOKUDO] Teleport System: ON")
end

local function Disable()
    FastReset()
    print("[YOKUDO] Teleport System: OFF (Fast Reset)")
end

local function SetTargetId(Id)
    TARGET_ID = Id
    print("[YOKUDO] Teleport System Target ID: " .. tostring(Id))
end

local function ResetState()
    FastReset()
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

print("✅ TeleportSystem Feature Loaded (2 Collect Only - Fixed)")
