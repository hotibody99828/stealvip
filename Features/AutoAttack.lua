-- ==================================================
-- YOKUDO HUB | FEATURE | Auto Attack
-- Auto Equip Bat + Auto Fire Remote
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild("Backpack")

-- ==================================================
-- FIND REMOTE
-- ==================================================
local BatSwingRemote = nil

local function GetBatSwingRemote()
    if BatSwingRemote then return BatSwingRemote end
    
    -- ពិនិត្យ ReplicatedStorage.Shared.Remotes.BatSwing.Trigger
    local Success, Remote = pcall(function()
        return ReplicatedStorage.Shared.Remotes.BatSwing.Trigger
    end)
    
    if Success and Remote then
        BatSwingRemote = Remote
        return Remote
    end
    
    -- ស្វែងរកទូទៅ
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == "Trigger" and v:IsA("RemoteEvent") then
            if v.Parent and v.Parent.Name == "BatSwing" then
                BatSwingRemote = v
                return v
            end
        end
    end
    
    return nil
end

-- ==================================================
-- SETTINGS
-- ==================================================
local HIT_RANGE = 50
local SWING_INTERVAL = 0.1 -- លឿនបំផុត

-- ==================================================
-- STATE
-- ==================================================
local AutoEquipEnabled = false
local AutoHitEnabled = false
local EquipConnection = nil
local HitConnection = nil
local CurrentBat = nil
local LastSwing = 0
local TraceSequence = 0

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
-- FIND BAT TOOL
-- ==================================================
local function FindBatTool()
    for _, tool in ipairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.ToolTip == "Bat" then
                return tool
            end
            if tool.Name:find("Bat") then
                return tool
            end
        end
    end
    
    local Char = Player.Character
    if Char then
        for _, tool in ipairs(Char:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.ToolTip == "Bat" or tool.Name:find("Bat") then
                    return tool
                end
            end
        end
    end
    
    return nil
end

-- ==================================================
-- FEATURE 1: AUTO EQUIP BAT
-- ==================================================
local function EquipBat()
    local Bat = FindBatTool()
    if not Bat then return false end
    
    if Bat.Parent == Backpack then
        local Hum, Root = GetHumanoid()
        if Hum then
            Hum:EquipTool(Bat)
            CurrentBat = Bat
            return true
        end
    elseif Bat.Parent == Player.Character then
        CurrentBat = Bat
        return true
    end
    
    return false
end

local function EnableAutoEquip()
    if AutoEquipEnabled then return end
    AutoEquipEnabled = true
    
    if EquipConnection then
        EquipConnection:Disconnect()
        EquipConnection = nil
    end
    
    EquipConnection = RunService.Heartbeat:Connect(function()
        if not AutoEquipEnabled then return end
        
        local Bat = FindBatTool()
        if Bat and Bat.Parent == Backpack then
            EquipBat()
        end
    end)
    
    EquipBat()
    print("[YOKUDO] Auto Equip Bat: ON")
end

local function DisableAutoEquip()
    if not AutoEquipEnabled then return end
    AutoEquipEnabled = false
    
    if EquipConnection then
        EquipConnection:Disconnect()
        EquipConnection = nil
    end
    
    print("[YOKUDO] Auto Equip Bat: OFF")
end

local function ToggleAutoEquip()
    if AutoEquipEnabled then
        DisableAutoEquip()
    else
        EnableAutoEquip()
    end
end

-- ==================================================
-- FEATURE 2: AUTO FIRE REMOTE (ចំ Detection Humanoid)
-- ==================================================
local function FindClosestPlayer()
    local Hum, Root = GetHumanoid()
    if not Root then return nil end
    
    local Closest = nil
    local ClosestDist = HIT_RANGE
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= Player then
            local otherChar = otherPlayer.Character
            if otherChar then
                local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
                local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                if otherHum and otherRoot and otherHum.Health > 0 then
                    -- ចំ Detection Humanoid (HumanoidRootPart)
                    local Dist = (otherRoot.Position - Root.Position).Magnitude
                    if Dist < ClosestDist then
                        ClosestDist = Dist
                        Closest = otherPlayer
                    end
                end
            end
        end
    end
    
    return Closest
end

local function FireRemote()
    -- រក Target (Player ក្នុង Range 50)
    local Target = FindClosestPlayer()
    if not Target then return end
    
    -- រក Remote
    local Remote = GetBatSwingRemote()
    if not Remote then return end
    
    -- Fire ភ្លាមៗ (មិន Aim, មិន Click)
    TraceSequence = TraceSequence + 1
    local TraceId = tostring(Player.UserId) .. ":" .. tostring(TraceSequence) .. ":" .. tostring(math.floor(workspace:GetServerTimeNow() * 1000))
    
    pcall(function()
        Remote:FireServer(Target, TraceId)
    end)
end

local function EnableAutoHit()
    if AutoHitEnabled then return end
    AutoHitEnabled = true
    
    if HitConnection then
        HitConnection:Disconnect()
        HitConnection = nil
    end
    
    HitConnection = RunService.Heartbeat:Connect(function()
        if not AutoHitEnabled then return end
        
        local now = tick()
        if now - LastSwing < SWING_INTERVAL then return end
        LastSwing = now
        
        FireRemote()
    end)
    
    print("[YOKUDO] Auto Fire Remote: ON")
end

local function DisableAutoHit()
    if not AutoHitEnabled then return end
    AutoHitEnabled = false
    
    if HitConnection then
        HitConnection:Disconnect()
        HitConnection = nil
    end
    
    print("[YOKUDO] Auto Fire Remote: OFF")
end

local function ToggleAutoHit()
    if AutoHitEnabled then
        DisableAutoHit()
    else
        EnableAutoHit()
    end
end

-- ==================================================
-- AUTO RE-EQUIP ON CHARACTER ADDED
-- ==================================================
Player.CharacterAdded:Connect(function()
    if AutoEquipEnabled then
        task.wait(1)
        EquipBat()
    end
end)

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_AutoAttack = {
    -- Auto Equip
    ToggleAutoEquip = ToggleAutoEquip,
    EnableAutoEquip = EnableAutoEquip,
    DisableAutoEquip = DisableAutoEquip,
    IsAutoEquipEnabled = function() return AutoEquipEnabled end,
    
    -- Auto Fire Remote
    ToggleAutoHit = ToggleAutoHit,
    EnableAutoHit = EnableAutoHit,
    DisableAutoHit = DisableAutoHit,
    IsAutoHitEnabled = function() return AutoHitEnabled end,
    
    -- Utils
    FindBatTool = FindBatTool,
    GetBatSwingRemote = GetBatSwingRemote,
    FindClosestPlayer = FindClosestPlayer
}

print("✅ AutoAttack Feature Loaded (Fire Remote Only)")
