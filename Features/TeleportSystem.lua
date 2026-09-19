--==================================================
-- YOKUDO HUB - EGG COLLECT (2 ROUNDS Y - LOCK 0)
-- Round 1: Fly TP + Lock 0 + Save Y + Collect
-- Y Change (1) -> Save YChanged -> Wait Y Return
-- Round 2: Y Return -> Fly TP + Lock 0 + Collect
-- Y Change (2) -> Fly TP Safe Zone
-- TARGET_ID: 26f67a4a6dcc48dda9880599bafc6f76
-- Safe Zone: (533, 70, -366)
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

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

local TARGET_ID = "26f67a4a6dcc48dda9880599bafc6f76"
local SAFE_ZONE = Vector3.new(533, 70, -366)

local FLY_SPEED = 500
local RETURN_SPEED = 350
local FLY_OFFSET = 3
local SHOT_DISTANCE = 30
local ARRIVE_DISTANCE = 2
local SAFE_LOCK_DISTANCE = 3

local MIN_FLY_DISTANCE = 4
local LOCK_DISTANCE = 0          -- Lock ចំ Egg (0 distance)
local Y_CHANGE_THRESHOLD = 1
local Y_RETURN_THRESHOLD = 1

local LOOP_INTERVAL = 0.05
local COLLECT_INTERVAL = 0.01

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
local FlyConnection = nil
local LockConnection = nil
local CollectConnection = nil
local HeartbeatConnection = nil
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
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YokudoRemoteCollect"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 280)
MainFrame.Position = UDim2.new(0, 20, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "Egg Collect (2 Rounds - Lock 0)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local DebugLabel = Instance.new("TextLabel")
DebugLabel.Size = UDim2.new(1, -20, 0, 60)
DebugLabel.Position = UDim2.new(0, 10, 0, 38)
DebugLabel.BackgroundTransparency = 1
DebugLabel.Text = "Dist: ? | Y: ? | Step: idle"
DebugLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DebugLabel.Font = Enum.Font.Code
DebugLabel.TextSize = 10
DebugLabel.TextXAlignment = Enum.TextXAlignment.Left
DebugLabel.TextWrapped = true
DebugLabel.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 38)
ToggleBtn.Position = UDim2.new(0, 10, 0, 105)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Text = "START"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 155)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Stopped"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(1, -20, 0, 18)
DistLabel.Position = UDim2.new(0, 10, 0, 175)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Dist: ? | Y: ?"
DistLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
DistLabel.Font = Enum.Font.Code
DistLabel.TextSize = 11
DistLabel.Parent = MainFrame

local YLabel = Instance.new("TextLabel")
YLabel.Size = UDim2.new(1, -20, 0, 18)
YLabel.Position = UDim2.new(0, 10, 0, 195)
YLabel.BackgroundTransparency = 1
YLabel.Text = "Y Orig: ? | Y Chg: ?"
YLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
YLabel.Font = Enum.Font.Code
YLabel.TextSize = 11
YLabel.Parent = MainFrame

local RoundLabel = Instance.new("TextLabel")
RoundLabel.Size = UDim2.new(1, -20, 0, 18)
RoundLabel.Position = UDim2.new(0, 10, 0, 215)
RoundLabel.BackgroundTransparency = 1
RoundLabel.Text = "Confirm: 0 / 2"
RoundLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
RoundLabel.Font = Enum.Font.Code
RoundLabel.TextSize = 11
RoundLabel.Parent = MainFrame

local LockLabel = Instance.new("TextLabel")
LockLabel.Size = UDim2.new(1, -20, 0, 18)
LockLabel.Position = UDim2.new(0, 10, 0, 235)
LockLabel.BackgroundTransparency = 1
LockLabel.Text = "Lock: NO | Wait: NO"
LockLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
LockLabel.Font = Enum.Font.Code
LockLabel.TextSize = 11
LockLabel.Parent = MainFrame

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
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    if LockConnection then
        LockConnection:Disconnect()
        LockConnection = nil
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
    IsLocked = false
end

--==================================================
-- FIND EGG
--==================================================

local function FindEggInContainer()
    if not Container then return nil end
    local Direct = Container:FindFirstChild(TARGET_ID)
    if Direct then return Direct end
    for _, Desc in ipairs(Container:GetDescendants()) do
        if Desc.Name == TARGET_ID then return Desc end
    end
    return nil
end

local function FindEggInWorkspace()
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
-- GET LOCK CFRAME (LOCK 0 DISTANCE)
--==================================================

local function GetLockCFrame(EggPos)
    -- Lock ចំ Egg (0 distance)
    local LockPos = EggPos + Vector3.new(0, LOCK_DISTANCE, 0)
    return CFrame.new(LockPos)
end

--==================================================
-- REMOTE COLLECT
--==================================================

local function RemoteCollectEgg()
    if not Event then return false end

    local success, result = pcall(function()
        return Event:InvokeServer({
            Uid = TARGET_ID
        })
    end)

    if success then
        return true
    else
        return false
    end
end

--==================================================
-- LOCK AT EGG (LOCK 0)
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
-- FLY TP
--==================================================

local function FlyTP(Destination, Speed, UseShotTP, LockAfter, Callback)
    CleanupMovers()

    local Hum, Root = GetHumanoid()
    if not Hum or not Root then return end
    if Hum.Health <= 0 then return end

    local FlyPos = Vector3.new(Destination.X, Destination.Y + FLY_OFFSET, Destination.Z)
    local LockCFrame = CFrame.new(FlyPos)

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

            if LockAfter then
                StartLock(LockCFrame)
            end

            if Callback then Callback() end
            return
        end

        if HorizDist <= ARRIVE_DISTANCE and VertDist <= 2 then
            CleanupMovers()

            Hum2.PlatformStand = false
            Root2.CFrame = LockCFrame
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero

            if LockAfter then
                StartLock(LockCFrame)
            end

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
                    StatusLabel.Text = "Status: Y Returned - Round 2"
                    IsWaitingReturn = false

                    TargetEgg = CurrentEgg
                    YChanged = nil

                    CurrentStep = "to_egg_2"

                    local EggPos = GetEggPosition(CurrentEgg)
                    if EggPos then
                        local LockCF = GetLockCFrame(EggPos)
                        FlyTP(EggPos, FLY_SPEED, false, false, function()
                            StartLock(LockCF)
                            StatusLabel.Text = "Status: Locked Round 2"
                            StartAutoCollect()
                        end)
                    end
                else
                    StatusLabel.Text = "Status: Wait Y (" .. YDiff .. ")"
                end
            else
                StatusLabel.Text = "Status: Wait Egg Return"
            end
            return
        end

        -- ============================================
        -- CHECK Y CHANGE
        -- ============================================
        if CurrentY and YOriginal and not IsGoingSafe then
            local YDiff = math.abs(CurrentY - YOriginal)

            if YDiff >= Y_CHANGE_THRESHOLD then
                if ConfirmCount == 0 then
                    ConfirmCount = 1
                    YChanged = CurrentY

                    StatusLabel.Text = "Status: Confirm 1!"
                    print("[YOKUDO] Confirm 1! Orig:", YOriginal, "Changed:", CurrentY)

                    StopAutoCollect()
                    StopLock()

                    IsWaitingReturn = true
                    TargetEgg = nil
                    CurrentStep = "idle"

                elseif ConfirmCount == 1 then
                    ConfirmCount = 2

                    StatusLabel.Text = "Status: Confirm 2! Fly Safe!"
                    print("[YOKUDO] Confirm 2! Fly Safe!")

                    StopAutoCollect()
                    StopLock()

                    IsGoingSafe = true

                    FlyTP(SAFE_ZONE, RETURN_SPEED, false, false, function()
                        StatusLabel.Text = "Status: At Safe Zone"
                        IsGoingSafe = false
                        FullReset()
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
-- FULL RESET
--==================================================

function FullReset()
    Running = false
    CurrentStep = "idle"

    TargetEgg = nil
    YOriginal = nil
    YChanged = nil
    ConfirmCount = 0
    IsGoingSafe = false
    IsWaitingReturn = false
    LockedCFrame = nil
    IsLocked = false

    CleanupMovers()
    StopLock()
    StopAutoCollect()
    StopHeartbeat()
    RestoreStats()

    ToggleBtn.Text = "START"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    StatusLabel.Text = "Status: Stopped - All Reset"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    YLabel.Text = "Y Orig: ? | Y Chg: ?"
    RoundLabel.Text = "Confirm: 0 / 2"
    LockLabel.Text = "Lock: NO | Wait: NO"

    print("[YOKUDO] Full Reset")
end

--==================================================
-- MAIN LOOP
--==================================================

task.spawn(function()
    while task.wait(LOOP_INTERVAL) do
        if not Running then continue end
        if IsGoingSafe then continue end
        if IsWaitingReturn then continue end

        local Hum, Root = GetHumanoid()
        if not Hum or not Root then continue end
        if Hum.Health <= 0 then continue end

        local CachedSpawnEgg = FindEggInContainer()
        local CachedWSEgg = FindEggInWorkspace()

        local CurrentEgg = CachedWSEgg or CachedSpawnEgg
        local CurrentY = nil
        local CurrentDist = 9999

        if CurrentEgg then
            CurrentY = GetEggY(CurrentEgg)
            CurrentDist = GetEggDistance(CurrentEgg)
        end

        DebugLabel.Text = "Dist: " .. math.floor(CurrentDist) ..
            " | Y: " .. tostring(CurrentY or 0) ..
            " | Step: " .. CurrentStep

        DistLabel.Text = "Dist: " .. math.floor(CurrentDist) ..
            " | Y: " .. tostring(CurrentY or 0)

        YLabel.Text = "Y Orig: " .. tostring(YOriginal or "?") ..
            " | Y Chg: " .. tostring(YChanged or "?")

        RoundLabel.Text = "Confirm: " .. ConfirmCount .. " / 2"
        LockLabel.Text = "Lock: " .. (IsLocked and "YES" or "NO") ..
            " | Wait: " .. (IsWaitingReturn and "YES" or "NO")

        -- ============================================
        -- ROUND 1: IDLE
        -- ============================================
        if CurrentStep == "idle" and ConfirmCount == 0 then
            local EggFound = CachedWSEgg or CachedSpawnEgg

            if EggFound then
                local EggPos = GetEggPosition(EggFound)
                if EggPos then
                    local Dist = GetEggDistance(EggFound)
                    if Dist > MIN_FLY_DISTANCE then
                        TargetEgg = EggFound

                        YOriginal = GetEggY(EggFound)
                        print("[YOKUDO] Y Original:", YOriginal)

                        CurrentStep = "to_egg_1"
                        StatusLabel.Text = "Status: Fly TP Round 1"

                        FlyTP(EggPos, FLY_SPEED, false, false, function()
                            local LockCF = GetLockCFrame(EggPos)
                            StartLock(LockCF)
                            StatusLabel.Text = "Status: Locked Round 1"
                            StartAutoCollect()
                        end)
                    end
                end
            else
                StatusLabel.Text = "Status: Waiting Egg"
            end
        end
    end
end)

--==================================================
-- TOGGLE
--==================================================

ToggleBtn.MouseButton1Click:Connect(function()
    if Running then
        FullReset()
    else
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

        ToggleBtn.Text = "STOP"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        StatusLabel.Text = "Status: Searching..."
        StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 100)

        print("[YOKUDO] Started - 2 Rounds Y (Lock 0)")
    end
end)

Player.CharacterRemoving:Connect(function()
    FullReset()
end)

print("[YOKUDO] Remote Collect loaded (2 Rounds Y - Lock 0)")
print("[YOKUDO] TARGET_ID:", TARGET_ID)
print("[YOKUDO] Event:", Event)
