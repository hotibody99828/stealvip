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
-- BUTTON ANIMATION FUNCTION (PRO)
-- ==================================================
local function AddButtonAnimation(Button)
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(125, 110, 220)
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        }):Play()
    end)

    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(85, 70, 170)
        }):Play()
    end)

    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(125, 110, 220)
        }):Play()
    end)
end

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
-- FEATURE 1: WALK SPEED (SHORT)
-- ==================================================
local WalkSpeedHolder = Instance.new("Frame")
WalkSpeedHolder.Size = UDim2.new(1, 0, 0, 32)
WalkSpeedHolder.BackgroundTransparency = 1
WalkSpeedHolder.LayoutOrder = 2
WalkSpeedHolder.Parent = SettingPage

local WalkSpeedLabel = Instance.new("TextLabel")
WalkSpeedLabel.Size = UDim2.new(0, 100, 1, 0)
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Text = "Walk Speed"
WalkSpeedLabel.TextColor3 = Color3.fromRGB(205, 205, 220)
WalkSpeedLabel.TextSize = 12
WalkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
WalkSpeedLabel.TextYAlignment = Enum.TextYAlignment.Center
WalkSpeedLabel.Font = Enum.Font.GothamMedium
WalkSpeedLabel.Parent = WalkSpeedHolder

local WalkSpeedTextBox = Instance.new("TextBox")
WalkSpeedTextBox.Size = UDim2.new(0, 40, 1, -6)
WalkSpeedTextBox.Position = UDim2.new(0, 105, 0, 3)
WalkSpeedTextBox.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
WalkSpeedTextBox.BorderSizePixel = 0
WalkSpeedTextBox.Text = "50"
WalkSpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedTextBox.TextSize = 12
WalkSpeedTextBox.TextXAlignment = Enum.TextXAlignment.Center
WalkSpeedTextBox.TextYAlignment = Enum.TextYAlignment.Center
WalkSpeedTextBox.Font = Enum.Font.GothamMedium
WalkSpeedTextBox.Parent = WalkSpeedHolder

local WalkSpeedBoxCorner = Instance.new("UICorner")
WalkSpeedBoxCorner.CornerRadius = UDim.new(0, 4)
WalkSpeedBoxCorner.Parent = WalkSpeedTextBox

local WalkSpeedBoxStroke = Instance.new("UIStroke")
WalkSpeedBoxStroke.Color = Color3.fromRGB(200, 200, 220)
WalkSpeedBoxStroke.Thickness = 0.5
WalkSpeedBoxStroke.Transparency = 0.2
WalkSpeedBoxStroke.Parent = WalkSpeedTextBox

local WalkSpeedCheckButton = Instance.new("TextButton")
WalkSpeedCheckButton.Size = UDim2.new(0, 26, 0, 26)
WalkSpeedCheckButton.Position = UDim2.new(1, -26, 0.5, -13)
WalkSpeedCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
WalkSpeedCheckButton.BorderSizePixel = 0
WalkSpeedCheckButton.Text = ""
WalkSpeedCheckButton.AutoButtonColor = false
WalkSpeedCheckButton.Parent = WalkSpeedHolder

local WalkSpeedCorner = Instance.new("UICorner")
WalkSpeedCorner.CornerRadius = UDim.new(0, 6)
WalkSpeedCorner.Parent = WalkSpeedCheckButton

local WalkSpeedStroke = Instance.new("UIStroke")
WalkSpeedStroke.Color = Color3.fromRGB(200, 200, 220)
WalkSpeedStroke.Thickness = 1.5
WalkSpeedStroke.Parent = WalkSpeedCheckButton

local WalkSpeedCheck = Instance.new("TextLabel")
WalkSpeedCheck.Size = UDim2.new(1, 0, 1, 0)
WalkSpeedCheck.BackgroundTransparency = 1
WalkSpeedCheck.Text = "✓"
WalkSpeedCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedCheck.TextSize = 18
WalkSpeedCheck.Font = Enum.Font.GothamBold
WalkSpeedCheck.Visible = false
WalkSpeedCheck.Parent = WalkSpeedCheckButton

local WalkSpeedEnabled = false
local WalkSpeedValue = 50

local function ToggleWalkSpeed()
    WalkSpeedEnabled = not WalkSpeedEnabled
    WalkSpeedCheck.Visible = WalkSpeedEnabled
    if WalkSpeedEnabled then
        WalkSpeedCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        WalkSpeedStroke.Color = Color3.fromRGB(135, 120, 225)
    else
        WalkSpeedCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        WalkSpeedStroke.Color = Color3.fromRGB(200, 200, 220)
    end
end

WalkSpeedCheckButton.MouseButton1Click:Connect(function()
    ToggleWalkSpeed()
end)

WalkSpeedTextBox.FocusLost:Connect(function()
    local val = tonumber(WalkSpeedTextBox.Text)
    if val then
        WalkSpeedValue = math.clamp(val, 50, 1200)
        WalkSpeedTextBox.Text = tostring(WalkSpeedValue)
    else
        WalkSpeedTextBox.Text = tostring(WalkSpeedValue)
    end
end)

-- ==================================================
-- FEATURE 2: BYPASS ANTI CHEAT (BUTTON BIGGER THAN CHECKBOX)
-- ==================================================
local BypassHolder = Instance.new("Frame")
BypassHolder.Size = UDim2.new(1, 0, 0, 52)
BypassHolder.BackgroundTransparency = 1
BypassHolder.LayoutOrder = 3
BypassHolder.Parent = SettingPage

local BypassLabel = Instance.new("TextLabel")
BypassLabel.Size = UDim2.new(1, -90, 0, 20)
BypassLabel.Position = UDim2.new(0, 0, 0, 2)
BypassLabel.BackgroundTransparency = 1
BypassLabel.Text = "Bypass Anti Cheat"
BypassLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
BypassLabel.TextSize = 13
BypassLabel.TextXAlignment = Enum.TextXAlignment.Left
BypassLabel.TextYAlignment = Enum.TextYAlignment.Center
BypassLabel.Font = Enum.Font.GothamBold
BypassLabel.Parent = BypassHolder

local BypassTitle = Instance.new("TextLabel")
BypassTitle.Size = UDim2.new(1, -90, 0, 18)
BypassTitle.Position = UDim2.new(0, 0, 0, 24)
BypassTitle.BackgroundTransparency = 1
BypassTitle.Text = "When Character Dead click Bypass Anti Cheat"
BypassTitle.TextColor3 = Color3.fromRGB(150, 150, 170)
BypassTitle.TextSize = 10
BypassTitle.TextXAlignment = Enum.TextXAlignment.Left
BypassTitle.Font = Enum.Font.Gotham
BypassTitle.Parent = BypassHolder

local BypassButton = Instance.new("TextButton")
BypassButton.Size = UDim2.new(0, 70, 0, 26)
BypassButton.Position = UDim2.new(1, -70, 0.5, -13)
BypassButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
BypassButton.BorderSizePixel = 0
BypassButton.Text = "Click"
BypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BypassButton.TextSize = 12
BypassButton.Font = Enum.Font.GothamBold
BypassButton.AutoButtonColor = false
BypassButton.Parent = BypassHolder

local BypassCorner = Instance.new("UICorner")
BypassCorner.CornerRadius = UDim.new(0, 6)
BypassCorner.Parent = BypassButton

local BypassStroke = Instance.new("UIStroke")
BypassStroke.Color = Color3.fromRGB(140, 125, 240)
BypassStroke.Thickness = 1.5
BypassStroke.Transparency = 0.3
BypassStroke.Parent = BypassButton

AddButtonAnimation(BypassButton)

-- ==================================================
-- FEATURE 3: ANTI TRAP (CHECKBOX)
-- ==================================================
local AntiTrapHolder = Instance.new("Frame")
AntiTrapHolder.Size = UDim2.new(1, 0, 0, 52)
AntiTrapHolder.BackgroundTransparency = 1
AntiTrapHolder.LayoutOrder = 4
AntiTrapHolder.Parent = SettingPage

local AntiTrapLabel = Instance.new("TextLabel")
AntiTrapLabel.Size = UDim2.new(1, -50, 0, 20)
AntiTrapLabel.Position = UDim2.new(0, 0, 0, 2)
AntiTrapLabel.BackgroundTransparency = 1
AntiTrapLabel.Text = "Anti Trap"
AntiTrapLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
AntiTrapLabel.TextSize = 13
AntiTrapLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiTrapLabel.TextYAlignment = Enum.TextYAlignment.Center
AntiTrapLabel.Font = Enum.Font.GothamBold
AntiTrapLabel.Parent = AntiTrapHolder

local AntiTrapTitle = Instance.new("TextLabel")
AntiTrapTitle.Size = UDim2.new(1, -50, 0, 18)
AntiTrapTitle.Position = UDim2.new(0, 0, 0, 24)
AntiTrapTitle.BackgroundTransparency = 1
AntiTrapTitle.Text = "click for remove Trap"
AntiTrapTitle.TextColor3 = Color3.fromRGB(150, 150, 170)
AntiTrapTitle.TextSize = 10
AntiTrapTitle.TextXAlignment = Enum.TextXAlignment.Left
AntiTrapTitle.Font = Enum.Font.Gotham
AntiTrapTitle.Parent = AntiTrapHolder

local AntiTrapCheckButton = Instance.new("TextButton")
AntiTrapCheckButton.Size = UDim2.new(0, 26, 0, 26)
AntiTrapCheckButton.Position = UDim2.new(1, -26, 0.5, -13)
AntiTrapCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
AntiTrapCheckButton.BorderSizePixel = 0
AntiTrapCheckButton.Text = ""
AntiTrapCheckButton.AutoButtonColor = false
AntiTrapCheckButton.Parent = AntiTrapHolder

local AntiTrapCorner = Instance.new("UICorner")
AntiTrapCorner.CornerRadius = UDim.new(0, 6)
AntiTrapCorner.Parent = AntiTrapCheckButton

local AntiTrapStroke = Instance.new("UIStroke")
AntiTrapStroke.Color = Color3.fromRGB(200, 200, 220)
AntiTrapStroke.Thickness = 1.5
AntiTrapStroke.Parent = AntiTrapCheckButton

local AntiTrapCheck = Instance.new("TextLabel")
AntiTrapCheck.Size = UDim2.new(1, 0, 1, 0)
AntiTrapCheck.BackgroundTransparency = 1
AntiTrapCheck.Text = "✓"
AntiTrapCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiTrapCheck.TextSize = 18
AntiTrapCheck.Font = Enum.Font.GothamBold
AntiTrapCheck.Visible = false
AntiTrapCheck.Parent = AntiTrapCheckButton

local AntiTrapEnabled = false

local function ToggleAntiTrap()
    AntiTrapEnabled = not AntiTrapEnabled
    AntiTrapCheck.Visible = AntiTrapEnabled
    if AntiTrapEnabled then
        AntiTrapCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        AntiTrapStroke.Color = Color3.fromRGB(135, 120, 225)
    else
        AntiTrapCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        AntiTrapStroke.Color = Color3.fromRGB(200, 200, 220)
    end
end

AntiTrapCheckButton.MouseButton1Click:Connect(function()
    ToggleAntiTrap()
end)

-- ==================================================
-- FEATURE 4: GOD MODE (BUTTON BIGGER THAN CHECKBOX)
-- ==================================================
local GodModeHolder = Instance.new("Frame")
GodModeHolder.Size = UDim2.new(1, 0, 0, 52)
GodModeHolder.BackgroundTransparency = 1
GodModeHolder.LayoutOrder = 5
GodModeHolder.Parent = SettingPage

local GodModeLabel = Instance.new("TextLabel")
GodModeLabel.Size = UDim2.new(1, -90, 0, 20)
GodModeLabel.Position = UDim2.new(0, 0, 0, 2)
GodModeLabel.BackgroundTransparency = 1
GodModeLabel.Text = "God Mode"
GodModeLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
GodModeLabel.TextSize = 13
GodModeLabel.TextXAlignment = Enum.TextXAlignment.Left
GodModeLabel.TextYAlignment = Enum.TextYAlignment.Center
GodModeLabel.Font = Enum.Font.GothamBold
GodModeLabel.Parent = GodModeHolder

local GodModeTitle = Instance.new("TextLabel")
GodModeTitle.Size = UDim2.new(1, -90, 0, 18)
GodModeTitle.Position = UDim2.new(0, 0, 0, 24)
GodModeTitle.BackgroundTransparency = 1
GodModeTitle.Text = "When Character Dead click God Mode"
GodModeTitle.TextColor3 = Color3.fromRGB(150, 150, 170)
GodModeTitle.TextSize = 10
GodModeTitle.TextXAlignment = Enum.TextXAlignment.Left
GodModeTitle.Font = Enum.Font.Gotham
GodModeTitle.Parent = GodModeHolder

local GodModeButton = Instance.new("TextButton")
GodModeButton.Size = UDim2.new(0, 70, 0, 26)
GodModeButton.Position = UDim2.new(1, -70, 0.5, -13)
GodModeButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
GodModeButton.BorderSizePixel = 0
GodModeButton.Text = "Click"
GodModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GodModeButton.TextSize = 12
GodModeButton.Font = Enum.Font.GothamBold
GodModeButton.AutoButtonColor = false
GodModeButton.Parent = GodModeHolder

local GodModeCorner = Instance.new("UICorner")
GodModeCorner.CornerRadius = UDim.new(0, 6)
GodModeCorner.Parent = GodModeButton

local GodModeStroke = Instance.new("UIStroke")
GodModeStroke.Color = Color3.fromRGB(140, 125, 240)
GodModeStroke.Thickness = 1.5
GodModeStroke.Transparency = 0.3
GodModeStroke.Parent = GodModeButton

AddButtonAnimation(GodModeButton)

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
        Check = WalkSpeedCheckButton,
        GetState = function() return WalkSpeedEnabled end,
        TextBox = WalkSpeedTextBox,
        GetValue = function() return WalkSpeedValue end
    },
    BypassButton = BypassButton,
    AntiTrap = {
        Holder = AntiTrapHolder,
        Check = AntiTrapCheckButton,
        GetState = function() return AntiTrapEnabled end
    },
    GodModeButton = GodModeButton
}

print("✅ Tabs Loaded (7 Tabs + Setting Features)")
