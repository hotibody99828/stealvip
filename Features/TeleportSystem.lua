-- ==================================================
-- YOKUDO HUB | FEATURE | Teleport System
-- Egg Collect via Remote (Lock 3 + Y Base + Reset)
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Container = workspace:WaitForChild("AreaEggSlotsClient")

-- ==================================================
-- REMOTE
-- ==================================================
local function GetAskCarryRemote()
    local Success, Remote = pcall(function()
        return ReplicatedStorage.Packages.Networking["RF/EggWorld/AskFieldEggCarry"]
    end)
    if Success and Remote then
        return Remote
    end
    return nil
end

-- ==================================================
-- SETTINGS
-- ==================================================
local SAFE_ZONE = Vector3.new(533, 70, -366)

local FLY_SPEED = 500
local RETURN_SPEED = 350
local FLY_OFFSET = 15
local SHOT_DISTANCE = 30
local ARRIVE_DISTANCE = 3          -- Lock ពីលើ 3 Distance
local REMOTE_TRIGGER_DISTANCE = 6  -- Fire Remote ពេលនៅក្រោម 6 Distance
local SAFE_LOCK_DISTANCE = 3

local MIN_FLY_DISTANCE = 3
local Y_CHANGE_THRESHOLD = 1       -- Y Change ≥ 1

local REMOTE_INTERVAL = 0.01
local WAIT_AFTER_RESET = 1         -- ឈរនៅស្ងោមសិន 1s
local COLLECT_TARGET = 2

-- ==================================================
-- STATE
-- ==================================================
local TARGET_ID = nil
local CollectCount = 0

local Running = false
local CurrentStep = "idle"
local TargetEgg = nil
local BaseY = nil                   -- Y ដើមរបស់ Egg
local CurrentY = nil
local CollectDone = false
local WaitingRetry = false
local RetryStartTime = 0
local GoingToSafe = false
local LastRemoteFire = 0

local FlyConnection = nil
local BodyVelocity = nil
local BodyGyro = nil
local ActiveHeartbeat = nil
local MainLoop = nil

local SavedWalkSpeed = nil
local SavedJumpPower = nil
local SavedJumpHeight = nil
local SavedUseJumpPower = nil

-- ==================================================
-- GET HUMANOID
-- ==================================================
local function GetHumanoid()
    local Char = Player.Character
    if not Char then return nil, nil end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    return Hum, Root
end

-- ==================================================
-- SAVE / RESTORE
-- ==================================================
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

-- ==================================================
-- CLEANUP
-- ==================================================
local function CleanupMovers()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
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
end

-- ==================================================
-- FIND EGG
-- ==================================================
local function FindEggAnywhere()
    if not TARGET_ID then return nil end
    
    if Container then
        local Egg = Container:FindFirstChild(TARGET_ID)
        if Egg then return Egg end
    end
    
    local Egg = workspace:FindFirstChild(TARGET_ID)
    if Egg then return Egg end
    
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
    return Pos.Y
end

local function GetEggDistance(Egg)
    local Hum, Root = GetHumanoid()
    if not Root then return 9999 end
    local EggPos = GetEggPosition(Egg)
    if not EggPos then return 9999 end
    return (EggPos - Root.Position).Magnitude
end

-- ==================================================
-- FIRE REMOTE
-- ==================================================
local function FireAskCarry()
    if not TARGET_ID then return false end
    
    local now = tick()
    if now - LastRemoteFire < REMOTE_INTERVAL then return false end
    LastRemoteFire = now
    
    local Remote = GetAskCarryRemote()
    if not Remote then return false end
    
    local Success = pcall(function()
        Remote:InvokeServer({
            Uid = TARGET_ID
        })
    end)
    
    return Success
end

-- ==================================================
-- FLY TP (Lock ពីលើ 3 Distance)
-- ==================================================
local function FlyTP(Destination, Speed, UseShotTP, Callback)
    CleanupMovers()

    local Hum, Root = GetHumanoid()
    if not Hum or not Root then return end
    if Hum.Health <= 0 then return end

    local FlyPos = Vector3.new(Destination.X, Destination.Y + FLY_OFFSET, Destination.Z)
    local LockCFrame = CFrame.new(Destination)

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
    local ShotDone = false

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
        local VertDist = math.abs(Direction.Y)
        local TotalDist = Direction.Magnitude

        -- SAFE ZONE
        if Speed == RETURN_SPEED then
            if HorizDist <= SAFE_LOCK_DISTANCE then
                CleanupMovers()
                Hum2.PlatformStand = false
                Root2.CFrame = CFrame.new(SAFE_ZONE)
                Root2.AssemblyLinearVelocity = Vector3.zero
                Root2.AssemblyAngularVelocity = Vector3.zero
                if Callback then Callback() end
                return
            end
        end

        if UseShotTP and HorizDist <= SHOT_DISTANCE and not ShotDone then
            ShotDone = true
            CleanupMovers()
            Hum2.PlatformStand = false
            Root2.CFrame = LockCFrame
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero
            if Callback then Callback() end
            return
        end

        -- Lock ពីលើ 3 Distance
        if HorizDist <= ARRIVE_DISTANCE and VertDist <= 3 then
            CleanupMovers()
            Hum2.PlatformStand = false
            
            local LockPos = Vector3.new(Destination.X, Destination.Y + 3, Destination.Z)
            Root2.CFrame = CFrame.new(LockPos)
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero
            if Callback then Callback() end
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

-- ==================================================
-- FLY TO SAFE ZONE
-- ==================================================
local function FlyToSafeZone()
    GoingToSafe = true
    CurrentStep = "to_safe"

    FlyTP(SAFE_ZONE, RETURN_SPEED, false, function()
        CurrentStep = "stop"
        FullReset()
    end)
end

-- ==================================================
-- RESET STATE RETRY (ឈរនៅស្ងោមសិន)
-- ==================================================
local function ResetStateRetry()
    TargetEgg = nil
    BaseY = nil
    CurrentY = nil
    CollectDone = false
    WaitingRetry = false
    RetryStartTime = 0
    GoingToSafe = false

    CleanupMovers()

    CurrentStep = "idle"
    print("[YOKUDO] State Reset - Retry #" .. (CollectCount + 1))
end

-- ==================================================
-- FULL RESET
-- ==================================================
local function FullReset()
    Running = false
    CurrentStep = "idle"

    TargetEgg = nil
    BaseY = nil
    CurrentY = nil
    CollectDone = false
    WaitingRetry = false
    RetryStartTime = 0
    GoingToSafe = false
    CollectCount = 0

    CleanupMovers()
    if ActiveHeartbeat then
        ActiveHeartbeat:Disconnect()
        ActiveHeartbeat = nil
    end
    if MainLoop then
        MainLoop:Disconnect()
        MainLoop = nil
    end
    RestoreStats()

    print("[YOKUDO] Full Reset")
end

-- ==================================================
-- HEARTBEAT (Active) - Confirm + Fire Remote
-- ==================================================
local function StartActiveHeartbeat()
    if ActiveHeartbeat then
        ActiveHeartbeat:Disconnect()
        ActiveHeartbeat = nil
    end

    ActiveHeartbeat = RunService.Heartbeat:Connect(function()
        if not Running then return end

        local Hum, Root = GetHumanoid()
        if not Hum or not Root then return end
        if Hum.Health <= 0 then return end

        -- WAIT RETRY (ឈរនៅស្ងោមសិន)
        if WaitingRetry then
            local Elapsed = tick() - RetryStartTime
            if Elapsed >= WAIT_AFTER_RESET then
                WaitingRetry = false
                -- បន្ទាប់ពីឈរស្ងោម → បន្ត Check Y Egg
            end
            return
        end

        -- ============================================
        -- CHECK Y EGG
        -- ============================================
        local CurrentEgg = FindEggAnywhere()
        CurrentY = nil

        if CurrentEgg then
            CurrentY = GetEggY(CurrentEgg)
        end

        -- ============================================
        -- CONFIRM COLLECT (Y Change)
        -- ============================================
        if BaseY and CurrentY and not CollectDone then
            if math.abs(CurrentY - BaseY) >= Y_CHANGE_THRESHOLD then
                CollectDone = true
                CollectCount = CollectCount + 1

                print("[YOKUDO] Collect Confirmed #" .. CollectCount .. " (Y: " .. BaseY .. " → " .. CurrentY .. ")")

                if CollectCount >= COLLECT_TARGET then
                    FlyToSafeZone()
                else
                    -- Reset ភ្លាម + ឈរនៅស្ងោម
                    ResetStateRetry()
                    WaitingRetry = true
                    RetryStartTime = tick()
                end
            end
        end

        -- ============================================
        -- LOCK + FIRE REMOTE
        -- ============================================
        if CurrentStep == "lock_egg" then
            if not TargetEgg then
                CurrentStep = "idle"
                return
            end

            local EggPos = GetEggPosition(TargetEgg)
            if not EggPos then
                CurrentStep = "idle"
                TargetEgg = nil
                return
            end

            -- Check Distance
            local Dist = GetEggDistance(TargetEgg)

            -- បើនៅក្រោម 6 Distance → Fire Remote
            if Dist <= REMOTE_TRIGGER_DISTANCE then
                -- Save Base Y (ពេល Lock ដំបូង)
                if not BaseY and CurrentY then
                    BaseY = CurrentY
                    print("[YOKUDO] Base Y: " .. BaseY)
                end

                FireAskCarry()
            end

        elseif CurrentStep == "to_safe" then

        elseif CurrentStep == "stop" then
            FullReset()
        end
    end)
end

-- ==================================================
-- MAIN LOOP (Check Egg → Fly TP)
-- ==================================================
local function StartMainLoop()
    if MainLoop then
        MainLoop:Disconnect()
        MainLoop = nil
    end

    MainLoop = RunService.Heartbeat:Connect(function()
        if not Running then return end

        local Hum, Root = GetHumanoid()
        if not Hum or not Root then return end
        if Hum.Health <= 0 then return end

        if WaitingRetry then return end
        if GoingToSafe then return end

        local CachedEgg = FindEggAnywhere()

        if CurrentStep == "idle" and CachedEgg then
            -- ពេល Start ដំបូង → Check Y Egg យក Y ដើម
            local EggY = GetEggY(CachedEgg)
            
            -- បើ Y Egg នៅក្រោម 70 → Fly TP ទៅ Lock
            if EggY and EggY < 70 then
                local EggPos = GetEggPosition(CachedEgg)
                if EggPos then
                    local Dist = GetEggDistance(CachedEgg)
                    if Dist > MIN_FLY_DISTANCE then
                        TargetEgg = CachedEgg
                        BaseY = EggY
                        CollectDone = false

                        print("[YOKUDO] Base Y: " .. BaseY)

                        CurrentStep = "to_egg"

                        FlyTP(EggPos, FLY_SPEED, true, function()
                            CurrentStep = "lock_egg"
                        end)
                    end
                end
            else
                -- បើ Y Egg នៅលើ 70 → Fly TP ម្តងទៀត
                local EggPos = GetEggPosition(CachedEgg)
                if EggPos then
                    local Dist = GetEggDistance(CachedEgg)
                    if Dist > MIN_FLY_DISTANCE then
                        TargetEgg = CachedEgg
                        BaseY = EggY
                        CollectDone = false

                        CurrentStep = "to_egg"

                        FlyTP(EggPos, FLY_SPEED, true, function()
                            CurrentStep = "lock_egg"
                        end)
                    end
                end
            end
        end
    end)
end

-- ==================================================
-- ENABLE / DISABLE
-- ==================================================
local function Enable()
    if Running then return end
    
    FullReset()
    
    Running = true
    CurrentStep = "idle"
    CollectDone = false
    BaseY = nil
    WaitingRetry = false
    GoingToSafe = false
    CollectCount = 0
    SaveStats()

    StartActiveHeartbeat()
    StartMainLoop()

    print("[YOKUDO] Teleport System: ON")
end

local function Disable()
    FullReset()
    print("[YOKUDO] Teleport System: OFF")
end

local function SetTargetId(Id)
    TARGET_ID = Id
    print("[YOKUDO] Teleport System Target ID: " .. tostring(Id))
end

local function ResetState()
    FullReset()
    print("[YOKUDO] Teleport System: State Reset")
end

local function GetState()
    return {
        Running = Running,
        CurrentStep = CurrentStep,
        CollectCount = CollectCount,
        TargetId = TARGET_ID,
        BaseY = BaseY,
        CurrentY = CurrentY
    }
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_TeleportSystem = {
    Enable = Enable,
    Disable = Disable,
    SetTargetId = SetTargetId,
    ResetState = ResetState,
    GetState = GetState,
    IsEnabled = function() return Running end,
    GetTargetId = function() return TARGET_ID end,
    GetAskCarryRemote = GetAskCarryRemote
}

print("✅ TeleportSystem Feature Loaded (Lock 3 + Y Base + Reset)")
