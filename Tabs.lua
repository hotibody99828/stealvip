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
-- 7. SETTING PAGE (FEATURES)
-- ==================================================
CreateSectionTitle(SettingPage, "Settings", 1)

-- ==================================================
-- FEATURE 1: WALK SPEED
-- ==================================================
local WalkSpeedHolder, WalkSpeedCheck, WalkSpeedGetState, WalkSpeedTextBox, WalkSpeedGetValue = CreateTextBoxWithCheckbox(
    SettingPage,
    "Walk Speed",
    2,
    50,
    50,
    1200
)

-- ==================================================
-- FEATURE 2: BYPASS ANTI CHEAT
-- ==================================================
local BypassHolder = Instance.new("Frame")
BypassHolder.Size = UDim2.new(1, 0, 0, 32)
BypassHolder.BackgroundTransparency = 1
BypassHolder.LayoutOrder = 3
BypassHolder.Parent = SettingPage

local BypassLabel = Instance.new("TextLabel")
BypassLabel.Size = UDim2.new(1, -110, 1, 0)
BypassLabel.BackgroundTransparency = 1
BypassLabel.Text = "Bypass Anti Cheat"
BypassLabel.TextColor3 = Color3.fromRGB(205, 205, 220)
BypassLabel.TextSize = 12
BypassLabel.TextXAlignment = Enum.TextXAlignment.Left
BypassLabel.TextYAlignment = Enum.TextYAlignment.Center
BypassLabel.Font = Enum.Font.GothamMedium
BypassLabel.Parent = BypassHolder

local BypassButton = Instance.new("TextButton")
BypassButton.Size = UDim2.new(0, 100, 0, 26)
BypassButton.Position = UDim2.new(1, -100, 0.5, -13)
BypassButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
BypassButton.BorderSizePixel = 0
BypassButton.Text = "Click for"
BypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BypassButton.TextSize = 12
BypassButton.Font = Enum.Font.GothamBold
BypassButton.AutoButtonColor = false
BypassButton.Parent = BypassHolder

local BypassCorner = Instance.new("UICorner")
BypassCorner.CornerRadius = UDim.new(0, 6)
BypassCorner.Parent = BypassButton

-- ==================================================
-- FEATURE 3: ANTI TRAP
-- ==================================================
local AntiTrapHolder = Instance.new("Frame")
AntiTrapHolder.Size = UDim2.new(1, 0, 0, 32)
AntiTrapHolder.BackgroundTransparency = 1
AntiTrapHolder.LayoutOrder = 4
AntiTrapHolder.Parent = SettingPage

local AntiTrapLabel = Instance.new("TextLabel")
AntiTrapLabel.Size = UDim2.new(1, -110, 1, 0)
AntiTrapLabel.BackgroundTransparency = 1
AntiTrapLabel.Text = "Anti Trap"
AntiTrapLabel.TextColor3 = Color3.fromRGB(205, 205, 220)
AntiTrapLabel.TextSize = 12
AntiTrapLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiTrapLabel.TextYAlignment = Enum.TextYAlignment.Center
AntiTrapLabel.Font = Enum.Font.GothamMedium
AntiTrapLabel.Parent = AntiTrapHolder

local AntiTrapButton = Instance.new("TextButton")
AntiTrapButton.Size = UDim2.new(0, 100, 0, 26)
AntiTrapButton.Position = UDim2.new(1, -100, 0.5, -13)
AntiTrapButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
AntiTrapButton.BorderSizePixel = 0
AntiTrapButton.Text = "Click for"
AntiTrapButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiTrapButton.TextSize = 12
AntiTrapButton.Font = Enum.Font.GothamBold
AntiTrapButton.AutoButtonColor = false
AntiTrapButton.Parent = AntiTrapHolder

local AntiTrapCorner = Instance.new("UICorner")
AntiTrapCorner.CornerRadius = UDim.new(0, 6)
AntiTrapCorner.Parent = AntiTrapButton

-- ==================================================
-- FEATURE 4: GOD MODE
-- ==================================================
local GodModeHolder = Instance.new("Frame")
GodModeHolder.Size = UDim2.new(1, 0, 0, 32)
GodModeHolder.BackgroundTransparency = 1
GodModeHolder.LayoutOrder = 5
GodModeHolder.Parent = SettingPage

local GodModeLabel = Instance.new("TextLabel")
GodModeLabel.Size = UDim2.new(1, -110, 1, 0)
GodModeLabel.BackgroundTransparency = 1
GodModeLabel.Text = "God Mode"
GodModeLabel.TextColor3 = Color3.fromRGB(205, 205, 220)
GodModeLabel.TextSize = 12
GodModeLabel.TextXAlignment = Enum.TextXAlignment.Left
GodModeLabel.TextYAlignment = Enum.TextYAlignment.Center
GodModeLabel.Font = Enum.Font.GothamMedium
GodModeLabel.Parent = GodModeHolder

local GodModeButton = Instance.new("TextButton")
GodModeButton.Size = UDim2.new(0, 100, 0, 26)
GodModeButton.Position = UDim2.new(1, -100, 0.5, -13)
GodModeButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
GodModeButton.BorderSizePixel = 0
GodModeButton.Text = "Click for"
GodModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GodModeButton.TextSize = 12
GodModeButton.Font = Enum.Font.GothamBold
GodModeButton.AutoButtonColor = false
GodModeButton.Parent = GodModeHolder

local GodModeCorner = Instance.new("UICorner")
GodModeCorner.CornerRadius = UDim.new(0, 6)
GodModeCorner.Parent = GodModeButton

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

_G.YOKUDO_Features = {
    WalkSpeed = {
        Holder = WalkSpeedHolder,
        Check = WalkSpeedCheck,
        GetState = WalkSpeedGetState,
        TextBox = WalkSpeedTextBox,
        GetValue = WalkSpeedGetValue
    },
    BypassButton = BypassButton,
    AntiTrapButton = AntiTrapButton,
    GodModeButton = GodModeButton
}

print("✅ Tabs Loaded (7 Tabs + Setting Features)")
