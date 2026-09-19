--==================================================
-- YOKUDO HUB - EGG COLLECT (LOCK 0 + REMOTE)
-- Fly TP to Egg -> Lock 0 (hold) -> Remote Collect
-- Check Y + Confirm -> Fly TP Safe
-- Uid: 26f67a4a6dcc48dda9880599bafc6f76
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

local TARGET_UID = "26f67a4a6dcc48dda9880599bafc6f76"
local SAFE_ZONE = Vector3.new(533, 70, -366)

local FLY_SPEED = 500
local RETURN_SPEED = 350
local FLY_OFFSET = 15
local SHOT_DISTANCE = 30
local ARRIVE_DISTANCE = 2
local SAFE_LOCK_DISTANCE = 3

local MIN_FLY_DISTANCE = 3
local Y_CHANGE_THRESHOLD = 1

local LOOP_INTERVAL = 0.02

-- TARGET
local TargetEgg = nil
local SavedYBefore = nil
local CollectDone = false
local CollectSent = false

--==================================================
-- STATE
--==================================================

local Running = false
local CurrentStep = "idle"
local FlyConnection = nil
local BodyVelocity = nil
local BodyGyro = nil
local ActiveHeartbeat = nil

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
MainFrame.Size = UDim2.new(0, 280, 0, 240)
MainFrame.Position = UDim2.new(0, 20, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "Lock 0 + Remote"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local DebugLabel = Instance.new("TextLabel")
DebugLabel.Size = UDim2.new(1, -20, 0, 60)
DebugLabel.Position = UDim2.new(0, 10, 0, 38)
DebugLabel.BackgroundTransparency = 1
DebugLabel.Text = "Step: idle"
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

local DoneLabel = Instance.new("TextLabel")
DoneLabel.Size = UDim2.new(1, -20, 0, 18)
DoneLabel.Position = UDim2.new(0, 10, 0, 195)
DoneLabel.BackgroundTransparency = 1
DoneLabel.Text = "Collected: NO"
DoneLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
DoneLabel.Font = Enum.Font.Code
DoneLabel.TextSize = 11
DoneLabel.Parent = MainFrame

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

--==================================================
-- FIND EGG
--==================================================

local function FindEggInContainer()
    if not Container then return nil end
    return Container:FindFirstChild(TARGET_UID)
end

local function FindEggInWorkspace()
    return workspace:FindFirstChild(TARGET_UID)
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
-- REMOTE COLLECT EGG
--==================================================

local function RemoteCollectEgg()
    if not Event then return false end
    if CollectSent then return false end

    CollectSent = true

    local success, result = pcall(function()
        return Event:InvokeServer({
            Uid = TARGET_UID
        })
    end)

    if success then
        print("[YOKUDO] Remote Collect OK:", result)
        return true
    else
        warn("[YOKUDO] Remote Collect Failed:", result)
        CollectSent = false
        return false
    end
end

--==================================================
-- FLY TP
--==================================================

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

        if HorizDist <= ARRIVE_DISTANCE and VertDist <= 2 then
            CleanupMovers()

            Hum2.PlatformStand = false
            Root2.CFrame = LockCFrame
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

--==================================================
-- HEARTBEAT
--==================================================

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

        -- ============================================
        -- FAST Y CHECK + CONFIRM
        -- ============================================
        local CurrentEgg = workspace:FindFirstChild(TARGET_UID) or (Container and Container:FindFirstChild(TARGET_UID))
        local CurrentY = nil

        if CurrentEgg then
            CurrentY = GetEggY(CurrentEgg)
        end

        if SavedYBefore and CurrentY and not CollectDone then
            if CurrentY - SavedYBefore >= Y_CHANGE_THRESHOLD then
                CollectDone = true
                StatusLabel.Text = "Status: CONFIRMED - Y Changed"
            end
        end

        -- ============================================
        -- COLLECT DONE -> FLY TP SAFE
        -- ============================================
        if CollectDone then
            if CurrentStep ~= "to_safe" and CurrentStep ~= "stop" then
                CurrentStep = "to_safe"
                StatusLabel.Text = "Status: COLLECTED - Fly Safe"

                FlyTP(SAFE_ZONE, RETURN_SPEED, false, function()
                    CurrentStep = "stop"
                end)
            end
            return
        end

        -- ============================================
        -- LOCK 0 + REMOTE (No Wait)
        -- ============================================
        if CurrentStep == "to_egg" then
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

            -- Lock 0 Distance (hold every frame)
            Root.CFrame = CFrame.new(EggPos)
            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero

            -- Save Y Before (once)
            local Y = GetEggY(TargetEgg)
            if Y and not SavedYBefore then
                SavedYBefore = Y
            end

            -- Remote Collect IMMEDIATELY (no wait)
            if not CollectSent then
                StatusLabel.Text = "Status: Locked 0 - Remote Collect!"
                RemoteCollectEgg()
            end
        end

        -- ============================================
        -- TO SAFE
        -- ============================================
        if CurrentStep == "to_safe" then
            -- Handled by FlyTP
        end

        -- ============================================
        -- STOP
        -- ============================================
        if CurrentStep == "stop" then
            StatusLabel.Text = "Status: Done - Auto Stop"
            FullReset()
        end
    end)
end

local function StopActiveHeartbeat()
    if ActiveHeartbeat then
        ActiveHeartbeat:Disconnect()
        ActiveHeartbeat = nil
    end
end

--==================================================
-- FULL RESET
--==================================================

local function FullReset()
    Running = false
    CurrentStep = "idle"

    TargetEgg = nil
    SavedYBefore = nil
    CollectDone = false
    CollectSent = false

    CleanupMovers()
    StopActiveHeartbeat()
    RestoreStats()

    ToggleBtn.Text = "START"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    StatusLabel.Text = "Status: Stopped - All Reset"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

    print("[YOKUDO] Full Reset")
end

--==================================================
-- MAIN LOOP
--==================================================

task.spawn(function()
    while task.wait(LOOP_INTERVAL) do
        if not Running then continue end

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

        DebugLabel.Text = "Step: " .. CurrentStep ..
            " | Remote: " .. tostring(CollectSent)

        DistLabel.Text = "Dist: " .. math.floor(CurrentDist) ..
            " | Y: " .. tostring(CurrentY or 0)

        DoneLabel.Text = "Collected: " .. (CollectDone and "YES" or "NO")

        if CurrentStep == "idle" then
            if CachedWSEgg then
                local EggPos = GetEggPosition(CachedWSEgg)
                if EggPos then
                    local Dist = GetEggDistance(CachedWSEgg)
                    if Dist > MIN_FLY_DISTANCE then
                        TargetEgg = CachedWSEgg
                        SavedYBefore = nil
                        CollectSent = false

                        CurrentStep = "to_egg"
                        StatusLabel.Text = "Status: Fly TP (WS)"

                        FlyTP(EggPos, FLY_SPEED, true, function()
                            -- Arrived -> Lock 0 + Remote handled in heartbeat
                        end)
                    end
                end
            elseif CachedSpawnEgg then
                local EggPos = GetEggPosition(CachedSpawnEgg)
                if EggPos then
                    local Dist = GetEggDistance(CachedSpawnEgg)
                    if Dist > MIN_FLY_DISTANCE then
                        TargetEgg = CachedSpawnEgg
                        SavedYBefore = nil
                        CollectSent = false

                        CurrentStep = "to_egg"
                        StatusLabel.Text = "Status: Fly TP (Spawn)"

                        FlyTP(EggPos, FLY_SPEED, true, function()
                        end)
                    end
                end
            else
                StatusLabel.Text = "Status: Waiting"
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
        CollectDone = false
        CollectSent = false
        SavedYBefore = nil
        SaveStats()

        StartActiveHeartbeat()

        ToggleBtn.Text = "STOP"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        StatusLabel.Text = "Status: Searching..."
        StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 100)

        print("[YOKUDO] Started - Uid:", TARGET_UID)
    end
end)

Player.CharacterRemoving:Connect(function()
    FullReset()
end)

print("[YOKUDO] Lock 0 + Remote loaded (No Wait)")
print("[YOKUDO] Uid:", TARGET_UID)
print("[YOKUDO] Event:", Event)
