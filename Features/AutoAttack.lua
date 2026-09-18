-- ==================================================
-- YOKUDO HUB | FEATURE | Auto Attack (Bat)
-- Uses Remotes.BatSwing.Trigger + ClickToMoveController
-- ==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ==================================================
-- GET REMOTES
-- ==================================================
local Remotes
pcall(function()
    Remotes = require(ReplicatedStorage.Shared.Remotes)
end)

if not Remotes or not Remotes.BatSwing then
    warn("[YOKUDO] BatSwing Remote not found")
    return
end

-- ==================================================
-- GET PLAYER MODULE (ClickToMoveController)
-- ==================================================
local Controls = nil
pcall(function()
    local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
    Controls = PlayerModule:GetControls()
end)

-- ==================================================
-- CONFIG
-- ==================================================
local CONFIG = {
    Range = 17,           -- (15 + 2) from BatController Config
    Cooldown = 0.65,      -- Client cooldown 0.6s + buffer
    AutoMove = true,      -- Auto move to target using ClickToMove
    AutoEquip = true,     -- Auto equip Bat tool
    MinDistance = 3,      -- Min distance to attack
    MoveDelay = 0.1,      -- Delay before re-moving
}

-- ==================================================
-- STATE
-- ==================================================
local Enabled = false
local LastAttack = 0
local LastMove = 0
local CurrentTarget = nil
local BatTool = nil
local Connection = nil
local MoveConnection = nil

-- ==================================================
-- GET HUMANOID
-- ==================================================
local function GetHumanoid()
    local Char = LocalPlayer.Character
    if not Char then return nil, nil end
    return Char:FindFirstChildOfClass("Humanoid"), Char:FindFirstChild("HumanoidRootPart")
end

-- ==================================================
-- FIND BAT TOOL
-- ==================================================
local function FindBatTool()
    local Char = LocalPlayer.Character
    if not Char then return nil end
    
    -- Check Character (equipped)
    for _, child in ipairs(Char:GetChildren()) do
        if child:IsA("Tool") and child:GetAttribute("IsBat") then
            return child
        end
    end
    
    -- Check Backpack
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if Backpack then
        for _, child in ipairs(Backpack:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("IsBat") then
                return child
            end
        end
    end
    
    return nil
end

-- ==================================================
-- EQUIP BAT
-- ==================================================
local function EquipBat()
    local Hum = GetHumanoid()
    if not Hum then return false end
    
    -- Already equipped?
    local Char = LocalPlayer.Character
    for _, child in ipairs(Char:GetChildren()) do
        if child:IsA("Tool") and child:GetAttribute("IsBat") then
            BatTool = child
            return true
        end
    end
    
    -- Find and equip
    local Tool = FindBatTool()
    if Tool then
        Hum:EquipTool(Tool)
        BatTool = Tool
        return true
    end
    
    return false
end

-- ==================================================
-- FIND CLOSEST TARGET
-- ==================================================
local function GetClosestTarget()
    local Hum, Root = GetHumanoid()
    if not Hum or not Root then return nil end
    if Hum.Health <= 0 then return nil end
    
    local closest = nil
    local minDist = CONFIG.Range
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = plr.Character:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and targetHum and targetHum.Health > 0 then
                -- Check if target is ragdolled (skip if ragdolled)
                local isRagdolled = plr.Character:GetAttribute("IsRagdolled") 
                    or plr:GetAttribute("RagdollEndTime")
                
                if not isRagdolled then
                    local dist = (targetRoot.Position - Root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    
    return closest, minDist
end

-- ==================================================
-- ATTACK TARGET
-- ==================================================
local function AttackTarget(Target)
    if not Target then return false end
    
    local traceId = tostring(LocalPlayer.UserId) .. ":" .. tostring(tick()) .. ":" .. tostring(math.floor(tick() * 1000))
    
    local success, err = pcall(function()
        Remotes.BatSwing.Trigger:FireServer(Target, traceId)
    end)
    
    if success then
        LastAttack = tick()
        return true
    else
        warn("[YOKUDO] Attack failed: " .. tostring(err))
        return false
    end
end

-- ==================================================
-- MOVE TO TARGET (using ClickToMoveController)
-- ==================================================
local function MoveToTarget(Target)
    if not CONFIG.AutoMove then return end
    if not Controls then return end
    if tick() - LastMove < CONFIG.MoveDelay then return end
    
    local targetRoot = Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    LastMove = tick()
    
    pcall(function()
        Controls:MoveTo(targetRoot.Position, false)
    end)
end

-- ==================================================
-- MAIN LOOP
-- ==================================================
local function StartLoop()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    
    Connection = RunService.Heartbeat:Connect(function()
        if not Enabled then return end
        
        local Hum, Root = GetHumanoid()
        if not Hum or Hum.Health <= 0 then return end
        
        -- Auto Equip
        if CONFIG.AutoEquip then
            local equipped = false
            for _, child in ipairs(LocalPlayer.Character:GetChildren()) do
                if child:IsA("Tool") and child:GetAttribute("IsBat") then
                    equipped = true
                    BatTool = child
                    break
                end
            end
            
            if not equipped then
                EquipBat()
                return
            end
        end
        
        -- Check cooldown
        if tick() - LastAttack < CONFIG.Cooldown then return end
        
        -- Find target
        local target, dist = GetClosestTarget()
        if target then
            CurrentTarget = target
            
            -- If too far, move closer
            if dist > CONFIG.MinDistance and CONFIG.AutoMove then
                MoveToTarget(target)
            end
            
            -- Attack if in range
            if dist <= CONFIG.Range then
                AttackTarget(target)
            end
        else
            CurrentTarget = nil
        end
    end)
end

-- ==================================================
-- ENABLE / DISABLE
-- ==================================================
local function Enable()
    Enabled = true
    LastAttack = 0
    LastMove = 0
    StartLoop()
    print("[YOKUDO] Auto Attack: ON")
end

local function Disable()
    Enabled = false
    CurrentTarget = nil
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    if Controls then
        pcall(function()
            Controls:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position, false)
        end)
    end
    print("[YOKUDO] Auto Attack: OFF")
end

local function Toggle()
    if Enabled then
        Disable()
    else
        Enable()
    end
end

-- ==================================================
-- AUTO RE-APPLY ON CHARACTER ADDED
-- ==================================================
LocalPlayer.CharacterAdded:Connect(function()
    if Enabled then
        task.wait(1)
        EquipBat()
        StartLoop()
    end
end)

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_AutoAttack = {
    Toggle = Toggle,
    Enable = Enable,
    Disable = Disable,
    IsEnabled = function() return Enabled end,
    SetRange = function(v) CONFIG.Range = v end,
    SetCooldown = function(v) CONFIG.Cooldown = v end,
    SetAutoMove = function(v) CONFIG.AutoMove = v end,
    SetAutoEquip = function(v) CONFIG.AutoEquip = v end,
    GetTarget = function() return CurrentTarget end,
    GetConfig = function() return CONFIG end,
}

print("✅ AutoAttack Feature Loaded")
