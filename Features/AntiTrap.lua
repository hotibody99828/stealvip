-- ==================================================
-- YOKUDO HUB | FEATURE | Anti Trap
-- ==================================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- ==================================================
-- VARIABLES
-- ==================================================
local AntiTrapEnabled = false
local Connection = nil

-- ==================================================
-- ANTI TRAP FUNCTION
-- ==================================================
local function EnableAntiTrap()
    AntiTrapEnabled = true
    
    if Connection then
        Connection:Disconnect()
    end
    
    Connection = task.spawn(function()
        while AntiTrapEnabled do
            task.wait(1)
            
            local Debris = Workspace:FindFirstChild("__DEBRIS")
            if Debris then
                for _, child in ipairs(Debris:GetChildren()) do
                    pcall(function()
                        child:Destroy()
                    end)
                end
                print("[YOKUDO] Anti Trap: Cleared __DEBRIS")
            end
        end
    end)
    
    print("[YOKUDO] Anti Trap: ON")
end

local function DisableAntiTrap()
    AntiTrapEnabled = false
    
    if Connection then
        task.cancel(Connection)
        Connection = nil
    end
    
    print("[YOKUDO] Anti Trap: OFF")
end

-- ==================================================
-- TOGGLE FUNCTION
-- ==================================================
local function ToggleAntiTrap()
    if AntiTrapEnabled then
        DisableAntiTrap()
    else
        EnableAntiTrap()
    end
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_AntiTrap = {
    Toggle = ToggleAntiTrap,
    Enable = EnableAntiTrap,
    Disable = DisableAntiTrap,
    IsEnabled = function() return AntiTrapEnabled end
}

print("✅ AntiTrap Feature Loaded")
