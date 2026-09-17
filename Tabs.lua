-- ==================================================
-- YOKUDO HUB | STEAL AN EGG | Tabs
-- ==================================================

local TweenService = game:GetService("TweenService")

-- ==================================================
-- CREATE PAGES
-- ==================================================
local InfoPage = CreatePage("INFO")
local FarmingPage = CreatePage("FARMING")
local CombatPage = CreatePage("COMBAT")
local AutoFarmingPage = CreatePage("AUTO_FARMING")
local EventPage = CreatePage("EVENT")
local HopServerPage = CreatePage("HOP_SERVER")
local SettingPage = CreatePage("SETTING")

-- ==================================================
-- CREATE TABS
-- ==================================================
local InfoTab = CreateTab("Info", 1)
local FarmingTab = CreateTab("Farming", 2)
local CombatTab = CreateTab("Combat", 3)
local AutoFarmingTab = CreateTab("Auto Farming", 4)
local EventTab = CreateTab("Event", 5)
local HopServerTab = CreateTab("Hop Server", 6)
local SettingTab = CreateTab("Setting", 7)

-- ==================================================
-- TAB MAP
-- ==================================================
local Tabs = {
    [InfoTab] = InfoPage,
    [FarmingTab] = FarmingPage,
    [CombatTab] = CombatPage,
    [AutoFarmingTab] = AutoFarmingPage,
    [EventTab] = EventPage,
    [HopServerTab] = HopServerPage,
    [SettingTab] = SettingPage
}

-- ==================================================
-- SELECT TAB
-- ==================================================
local function SelectTab(SelectedTab, SelectedPage)
    for Tab, Page in pairs(Tabs) do
        Page.Visible = false
        local Indicator = Tab:FindFirstChild("Indicator")
        local TabText = Tab:FindFirstChild("TabText")
        TweenService:Create(Tab, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        if Indicator then
            TweenService:Create(Indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
        if TabText then
            TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(155, 155, 175)}):Play()
        end
    end

    SelectedPage.Visible = true
    task.wait(0.05)
    pcall(function()
        SelectedPage.CanvasPosition = Vector2.new(0, 0)
    end)

    TweenService:Create(SelectedTab, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    local Indicator = SelectedTab:FindFirstChild("Indicator")
    local TabText = SelectedTab:FindFirstChild("TabText")
    if Indicator then
        TweenService:Create(Indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end
    if TabText then
        TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end
end

for Tab, Page in pairs(Tabs) do
    Tab.MouseButton1Click:Connect(function()
        SelectTab(Tab, Page)
    end)
end

SelectTab(InfoTab, InfoPage)

-- ==================================================
-- 1. INFO PAGE
-- ==================================================
CreateSectionTitle(InfoPage, "YOKUDO HUB | Steal An Egg", 1)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 60)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Telegram : @maibigber"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
InfoLabel.TextSize = 14
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.LayoutOrder = 2
InfoLabel.Parent = InfoPage

-- ==================================================
-- 2. FARMING PAGE
-- ==================================================
CreateSectionTitle(FarmingPage, "Farming", 1)

local FarmingLabel = Instance.new("TextLabel")
FarmingLabel.Size = UDim2.new(1, 0, 0, 30)
FarmingLabel.BackgroundTransparency = 1
FarmingLabel.Text = "Coming Soon..."
FarmingLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
FarmingLabel.TextSize = 12
FarmingLabel.TextXAlignment = Enum.TextXAlignment.Left
FarmingLabel.Font = Enum.Font.GothamMedium
FarmingLabel.LayoutOrder = 2
FarmingLabel.Parent = FarmingPage

-- ==================================================
-- 3. COMBAT PAGE
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

-- ==================================================
-- 4. AUTO FARMING PAGE
-- ==================================================
CreateSectionTitle(AutoFarmingPage, "Auto Farming", 1)

local AutoFarmingLabel = Instance.new("TextLabel")
AutoFarmingLabel.Size = UDim2.new(1, 0, 0, 30)
AutoFarmingLabel.BackgroundTransparency = 1
AutoFarmingLabel.Text = "Coming Soon..."
AutoFarmingLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
AutoFarmingLabel.TextSize = 12
AutoFarmingLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoFarmingLabel.Font = Enum.Font.GothamMedium
AutoFarmingLabel.LayoutOrder = 2
AutoFarmingLabel.Parent = AutoFarmingPage

-- ==================================================
-- 5. EVENT PAGE
-- ==================================================
CreateSectionTitle(EventPage, "Event", 1)

local EventLabel = Instance.new("TextLabel")
EventLabel.Size = UDim2.new(1, 0, 0, 30)
EventLabel.BackgroundTransparency = 1
EventLabel.Text = "Coming Soon..."
EventLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
EventLabel.TextSize = 12
EventLabel.TextXAlignment = Enum.TextXAlignment.Left
EventLabel.Font = Enum.Font.GothamMedium
EventLabel.LayoutOrder = 2
EventLabel.Parent = EventPage

-- ==================================================
-- 6. HOP SERVER PAGE
-- ==================================================
CreateSectionTitle(HopServerPage, "Hop Server", 1)

local HopServerLabel = Instance.new("TextLabel")
HopServerLabel.Size = UDim2.new(1, 0, 0, 30)
HopServerLabel.BackgroundTransparency = 1
HopServerLabel.Text = "Coming Soon..."
HopServerLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
HopServerLabel.TextSize = 12
HopServerLabel.TextXAlignment = Enum.TextXAlignment.Left
HopServerLabel.Font = Enum.Font.GothamMedium
HopServerLabel.LayoutOrder = 2
HopServerLabel.Parent = HopServerPage

-- ==================================================
-- 7. SETTING PAGE
-- ==================================================
CreateSectionTitle(SettingPage, "Setting", 1)

local SettingLabel = Instance.new("TextLabel")
SettingLabel.Size = UDim2.new(1, 0, 0, 30)
SettingLabel.BackgroundTransparency = 1
SettingLabel.Text = "Coming Soon..."
SettingLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
SettingLabel.TextSize = 12
SettingLabel.TextXAlignment = Enum.TextXAlignment.Left
SettingLabel.Font = Enum.Font.GothamMedium
SettingLabel.LayoutOrder = 2
SettingLabel.Parent = SettingPage

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_InfoPage = InfoPage
_G.YOKUDO_FarmingPage = FarmingPage
_G.YOKUDO_CombatPage = CombatPage
_G.YOKUDO_AutoFarmingPage = AutoFarmingPage
_G.YOKUDO_EventPage = EventPage
_G.YOKUDO_HopServerPage = HopServerPage
_G.YOKUDO_SettingPage = SettingPage

print("✅ Tabs Loaded (7 Tabs)")
