-- ==================================================
-- YOKUDO HUB | FEATURE | God Mode
-- ==================================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- ==================================================
-- VARIABLES
-- ==================================================
local GodModeEnabled = false
local Connection = nil

-- ==================================================
-- GET HUMANOID
-- ==================================================
local function GetHumanoid()
    local Char = Player.Character
    if not Char then return nil end
    return Char:FindFirstChildOfClass("Humanoid")
end

-- ==================================================
-- GOD MODE FUNCTION
-- ==================================================
local function EnableGodMode()
    GodModeEnabled = true
    
    local Hum = GetHumanoid()
    if Hum then
        Hum.MaxHealth = math.huge
        Hum.Health = math.huge
    end
    
    if Connection then
        Connection:Disconnect()
    end
    
    Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not GodModeEnabled then return end
        
        local Hum = GetHumanoid()
        if Hum then
            Hum.MaxHealth = math.huge
            Hum.Health = math.huge
        end
    end)
    
    print("[YOKUDO] God Mode: ON")
end

local function DisableGodMode()
    GodModeEnabled = false
    
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    
    local Hum = GetHumanoid()
    if Hum then
        Hum.MaxHealth = 100
        Hum.Health = 100
    end
    
    print("[YOKUDO] God Mode: OFF")
end

-- ==================================================
-- TOGGLE FUNCTION
-- ==================================================
local function ToggleGodMode()
    if GodModeEnabled then
        DisableGodMode()
    else
        EnableGodMode()
    end
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_GodMode = {
    Toggle = ToggleGodMode,
    Enable = EnableGodMode,
    Disable = DisableGodMode,
    IsEnabled = function() return GodModeEnabled end
}

print("✅ GodMode Feature Loaded")
