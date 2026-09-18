-- ==================================================
-- YOKUDO HUB | TAB | Combat
-- ==================================================

local TabsManager = _G.YOKUDO_TabsManager

local CombatTab, CombatPage = TabsManager:RegisterTab("Combat", 3, "COMBAT")

-- ==================================================
-- COMBAT CONTENT
-- ==================================================
CreateSectionTitle(CombatPage, "Combat", 1)

local CombatLabel = Instance.new("TextLabel")
CombatLabel.Size = UDim2.new(1, 0, 0, 30)
CombatLabel.BackgroundTransparency = 1
CombatLabel.Text = "Coming Soon..."
CombatLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
CombatLabel.TextSize = 12
CombatLabel.TextXAlignment = Enum.TextXAlignment.Left
CombatLabel.Font = Enum.Font.GothamMedium
CombatLabel.LayoutOrder = 2
CombatLabel.Parent = CombatPage

print("✅ Combat Tab Loaded")
