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
-- 4. AUTO FARMING PAGE (FEATURES)
-- ==================================================
CreateSectionTitle(AutoFarmingPage, "Auto Farming", 1)

-- ==================================================
-- FEATURE 1: START CHECK EGG (CHECKBOX)
-- ==================================================
local CheckEggHolder = Instance.new("Frame")
CheckEggHolder.Size = UDim2.new(1, 0, 0, 32)
CheckEggHolder.BackgroundTransparency = 1
CheckEggHolder.LayoutOrder = 2
CheckEggHolder.Parent = AutoFarmingPage

local CheckEggLabel = Instance.new("TextLabel")
CheckEggLabel.Size = UDim2.new(1, -40, 1, 0)
CheckEggLabel.BackgroundTransparency = 1
CheckEggLabel.Text = "Start Check Egg"
CheckEggLabel.TextColor3 = Color3.fromRGB(205, 205, 220)
CheckEggLabel.TextSize = 12
CheckEggLabel.TextXAlignment = Enum.TextXAlignment.Left
CheckEggLabel.TextYAlignment = Enum.TextYAlignment.Center
CheckEggLabel.Font = Enum.Font.GothamMedium
CheckEggLabel.Parent = CheckEggHolder

local CheckEggButton = Instance.new("TextButton")
CheckEggButton.Size = UDim2.new(0, 26, 0, 26)
CheckEggButton.Position = UDim2.new(1, -26, 0.5, -13)
CheckEggButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
CheckEggButton.BorderSizePixel = 0
CheckEggButton.Text = ""
CheckEggButton.AutoButtonColor = false
CheckEggButton.Parent = CheckEggHolder

local CheckEggCorner = Instance.new("UICorner")
CheckEggCorner.CornerRadius = UDim.new(0, 6)
CheckEggCorner.Parent = CheckEggButton

local CheckEggStroke = Instance.new("UIStroke")
CheckEggStroke.Color = Color3.fromRGB(200, 200, 220)
CheckEggStroke.Thickness = 1.5
CheckEggStroke.Parent = CheckEggButton

local CheckEggCheck = Instance.new("TextLabel")
CheckEggCheck.Size = UDim2.new(1, 0, 1, 0)
CheckEggCheck.BackgroundTransparency = 1
CheckEggCheck.Text = "✓"
CheckEggCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckEggCheck.TextSize = 18
CheckEggCheck.Font = Enum.Font.GothamBold
CheckEggCheck.Visible = false
CheckEggCheck.Parent = CheckEggButton

-- ==================================================
-- FEATURE 2: AUTO FARM BOX
-- ==================================================
local FarmBoxHolder = Instance.new("Frame")
FarmBoxHolder.Size = UDim2.new(1, 0, 0, 70)
FarmBoxHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
FarmBoxHolder.BackgroundTransparency = 0.2
FarmBoxHolder.BorderSizePixel = 0
FarmBoxHolder.LayoutOrder = 3
FarmBoxHolder.Parent = AutoFarmingPage

local FarmBoxCorner = Instance.new("UICorner")
FarmBoxCorner.CornerRadius = UDim.new(0, 8)
FarmBoxCorner.Parent = FarmBoxHolder

local FarmBoxStroke = Instance.new("UIStroke")
FarmBoxStroke.Color = Color3.fromRGB(200, 200, 220)
FarmBoxStroke.Thickness = 1
FarmBoxStroke.Transparency = 0.5
FarmBoxStroke.Parent = FarmBoxHolder

-- Icon
local FarmIconFrame = Instance.new("Frame")
FarmIconFrame.Size = UDim2.new(0, 50, 0, 50)
FarmIconFrame.Position = UDim2.new(0, 10, 0, 10)
FarmIconFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
FarmIconFrame.BorderSizePixel = 0
FarmIconFrame.Parent = FarmBoxHolder

local FarmIconCorner = Instance.new("UICorner")
FarmIconCorner.CornerRadius = UDim.new(0, 6)
FarmIconCorner.Parent = FarmIconFrame

local FarmIconImage = Instance.new("ImageLabel")
FarmIconImage.Size = UDim2.new(1, -4, 1, -4)
FarmIconImage.Position = UDim2.new(0, 2, 0, 2)
FarmIconImage.BackgroundTransparency = 1
FarmIconImage.Image = ""
FarmIconImage.Parent = FarmIconFrame

local FarmImageCorner = Instance.new("UICorner")
FarmImageCorner.CornerRadius = UDim.new(0, 6)
FarmImageCorner.Parent = FarmIconImage

-- Name
local FarmNameLabel = Instance.new("TextLabel")
FarmNameLabel.Size = UDim2.new(1, -120, 0, 20)
FarmNameLabel.Position = UDim2.new(0, 70, 0, 15)
FarmNameLabel.BackgroundTransparency = 1
FarmNameLabel.Text = "No Egg Selected"
FarmNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmNameLabel.TextSize = 13
FarmNameLabel.TextXAlignment = Enum.TextXAlignment.Left
FarmNameLabel.Font = Enum.Font.GothamBold
FarmNameLabel.Parent = FarmBoxHolder

-- $/s
local FarmRateLabel = Instance.new("TextLabel")
FarmRateLabel.Size = UDim2.new(1, -120, 0, 18)
FarmRateLabel.Position = UDim2.new(0, 70, 0, 38)
FarmRateLabel.BackgroundTransparency = 1
FarmRateLabel.Text = "$0/s"
FarmRateLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
FarmRateLabel.TextSize = 12
FarmRateLabel.TextXAlignment = Enum.TextXAlignment.Left
FarmRateLabel.Font = Enum.Font.GothamBold
FarmRateLabel.Parent = FarmBoxHolder

-- Checkbox for Start
local FarmCheckButton = Instance.new("TextButton")
FarmCheckButton.Size = UDim2.new(0, 26, 0, 26)
FarmCheckButton.Position = UDim2.new(1, -36, 0.5, -13)
FarmCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
FarmCheckButton.BorderSizePixel = 0
FarmCheckButton.Text = ""
FarmCheckButton.AutoButtonColor = false
FarmCheckButton.Parent = FarmBoxHolder

local FarmCheckCorner = Instance.new("UICorner")
FarmCheckCorner.CornerRadius = UDim.new(0, 6)
FarmCheckCorner.Parent = FarmCheckButton

local FarmCheckStroke = Instance.new("UIStroke")
FarmCheckStroke.Color = Color3.fromRGB(200, 200, 220)
FarmCheckStroke.Thickness = 1.5
FarmCheckStroke.Parent = FarmCheckButton

local FarmCheck = Instance.new("TextLabel")
FarmCheck.Size = UDim2.new(1, 0, 1, 0)
FarmCheck.BackgroundTransparency = 1
FarmCheck.Text = "✓"
FarmCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmCheck.TextSize = 18
FarmCheck.Font = Enum.Font.GothamBold
FarmCheck.Visible = false
FarmCheck.Parent = FarmCheckButton

-- ==================================================
-- FEATURE 3: EGG LIST (CARDS)
-- ==================================================
local EggListFrame = Instance.new("ScrollingFrame")
EggListFrame.Name = "EggList"
EggListFrame.Size = UDim2.new(1, 0, 0, 200)
EggListFrame.BackgroundTransparency = 1
EggListFrame.BorderSizePixel = 0
EggListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
EggListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
EggListFrame.ScrollBarThickness = 4
EggListFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 220)
EggListFrame.LayoutOrder = 4
EggListFrame.Parent = AutoFarmingPage

local EggListLayout = Instance.new("UIListLayout")
EggListLayout.Padding = UDim.new(0, 5)
EggListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EggListLayout.Parent = EggListFrame

-- ==================================================
-- CREATE EGG CARD
-- ==================================================
local function CreateEggCard(EggData, Index)
    local Card = Instance.new("Frame")
    Card.Name = "EggCard_" .. Index
    Card.Size = UDim2.new(1, -8, 0, 60)
    Card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Card.BackgroundTransparency = 0.2
    Card.BorderSizePixel = 0
    Card.LayoutOrder = Index
    Card.Parent = EggListFrame

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(200, 200, 220)
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.5
    CardStroke.Parent = Card

    -- Icon
    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.new(0, 44, 0, 44)
    IconFrame.Position = UDim2.new(0, 8, 0, 8)
    IconFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = Card

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 6)
    IconCorner.Parent = IconFrame

    local IconImage = Instance.new("ImageLabel")
    IconImage.Size = UDim2.new(1, -4, 1, -4)
    IconImage.Position = UDim2.new(0, 2, 0, 2)
    IconImage.BackgroundTransparency = 1
    IconImage.Image = EggData.Icon or ""
    IconImage.Parent = IconFrame

    local ImageCorner = Instance.new("UICorner")
    ImageCorner.CornerRadius = UDim.new(0, 6)
    ImageCorner.Parent = IconImage

    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -140, 0, 18)
    NameLabel.Position = UDim2.new(0, 60, 0, 10)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = EggData.DisplayName
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Parent = Card

    -- $/s
    local RateLabel = Instance.new("TextLabel")
    RateLabel.Size = UDim2.new(1, -140, 0, 16)
    RateLabel.Position = UDim2.new(0, 60, 0, 30)
    RateLabel.BackgroundTransparency = 1
    RateLabel.Text = "$" .. _G.YOKUDO_AutoFarm.FormatMoney(EggData.EarningRate) .. "/s"
    RateLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    RateLabel.TextSize = 11
    RateLabel.TextXAlignment = Enum.TextXAlignment.Left
    RateLabel.Font = Enum.Font.GothamBold
    RateLabel.Parent = Card

    -- Select Button
    local SelectButton = Instance.new("TextButton")
    SelectButton.Size = UDim2.new(0, 70, 0, 26)
    SelectButton.Position = UDim2.new(1, -78, 0.5, -13)
    SelectButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    SelectButton.BorderSizePixel = 0
    SelectButton.Text = "Select"
    SelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectButton.TextSize = 12
    SelectButton.Font = Enum.Font.GothamBold
    SelectButton.AutoButtonColor = false
    SelectButton.Parent = Card

    local SelectCorner = Instance.new("UICorner")
    SelectCorner.CornerRadius = UDim.new(0, 6)
    SelectCorner.Parent = SelectButton

    local SelectStroke = Instance.new("UIStroke")
    SelectStroke.Color = Color3.fromRGB(140, 125, 240)
    SelectStroke.Thickness = 1.5
    SelectStroke.Transparency = 0.3
    SelectStroke.Parent = SelectButton

    AddButtonAnimation(SelectButton)

    SelectButton.MouseButton1Click:Connect(function()
        if _G.YOKUDO_AutoFarm then
            _G.YOKUDO_AutoFarm.SelectEgg(EggData)
            -- Update Farm Box
            FarmIconImage.Image = EggData.Icon or ""
            FarmNameLabel.Text = EggData.DisplayName
            FarmRateLabel.Text = "$" .. _G.YOKUDO_AutoFarm.FormatMoney(EggData.EarningRate) .. "/s"
        end
    end)

    return Card
end

-- ==================================================
-- REFRESH EGG LIST
-- ==================================================
local function RefreshEggList()
    for _, child in ipairs(EggListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    if not _G.YOKUDO_AutoFarm then return end
    
    local EggList = _G.YOKUDO_AutoFarm.ScanEggs()
    for i, EggData in ipairs(EggList) do
        CreateEggCard(EggData, i)
    end
end

-- ==================================================
-- CHECK EGG TOGGLE
-- ==================================================
local CheckEggEnabled = false

local function ToggleCheckEgg()
    CheckEggEnabled = not CheckEggEnabled
    CheckEggCheck.Visible = CheckEggEnabled
    if CheckEggEnabled then
        CheckEggButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        CheckEggStroke.Color = Color3.fromRGB(135, 120, 225)
        if _G.YOKUDO_AutoFarm then
            _G.YOKUDO_AutoFarm.Enable()
        end
        RefreshEggList()
        task.spawn(function()
            while CheckEggEnabled do
                task.wait(3)
                if CheckEggEnabled then
                    RefreshEggList()
                end
            end
        end)
    else
        CheckEggButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        CheckEggStroke.Color = Color3.fromRGB(200, 200, 220)
        if _G.YOKUDO_AutoFarm then
            _G.YOKUDO_AutoFarm.Disable()
        end
    end
end

CheckEggButton.MouseButton1Click:Connect(function()
    ToggleCheckEgg()
end)

-- ==================================================
-- FARM BOX TOGGLE
-- ==================================================
local FarmEnabled = false

local function ToggleFarm()
    FarmEnabled = not FarmEnabled
    FarmCheck.Visible = FarmEnabled
    if FarmEnabled then
        FarmCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        FarmCheckStroke.Color = Color3.fromRGB(135, 120, 225)
        local Selected = _G.YOKUDO_AutoFarm.GetSelectedEgg()
        if Selected then
            _G.YOKUDO_AutoFarm.SelectEgg(Selected)
        end
    else
        FarmCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        FarmCheckStroke.Color = Color3.fromRGB(200, 200, 220)
        if _G.YOKUDO_TeleportSystem then
            _G.YOKUDO_TeleportSystem.Disable()
        end
    end
end

FarmCheckButton.MouseButton1Click:Connect(function()
    ToggleFarm()
end)

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
        if _G.YOKUDO_WalkSpeed then
            _G.YOKUDO_WalkSpeed.SetValue(WalkSpeedValue)
            _G.YOKUDO_WalkSpeed.Enable()
        end
    else
        WalkSpeedCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        WalkSpeedStroke.Color = Color3.fromRGB(200, 200, 220)
        if _G.YOKUDO_WalkSpeed then
            _G.YOKUDO_WalkSpeed.Disable()
        end
    end
end

WalkSpeedCheckButton.MouseButton1Click:Connect(function()
    ToggleWalkSpeed()
end)

WalkSpeedTextBox.FocusLost:Connect(function()
    local val = tonumber(WalkSpeedTextBox.Text)
    if val then
        WalkSpeedValue = math.clamp(val, 50, 1000)
        WalkSpeedTextBox.Text = tostring(WalkSpeedValue)
        if WalkSpeedEnabled and _G.YOKUDO_WalkSpeed then
            _G.YOKUDO_WalkSpeed.SetValue(WalkSpeedValue)
        end
    else
        WalkSpeedTextBox.Text = tostring(WalkSpeedValue)
    end
end)

-- ==================================================
-- FEATURE 2: ANTI TRAP (CHECKBOX)
-- ==================================================
local AntiTrapHolder = Instance.new("Frame")
AntiTrapHolder.Size = UDim2.new(1, 0, 0, 52)
AntiTrapHolder.BackgroundTransparency = 1
AntiTrapHolder.LayoutOrder = 3
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
        if _G.YOKUDO_AntiTrap then
            _G.YOKUDO_AntiTrap.Enable()
        end
    else
        AntiTrapCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        AntiTrapStroke.Color = Color3.fromRGB(200, 200, 220)
        if _G.YOKUDO_AntiTrap then
            _G.YOKUDO_AntiTrap.Disable()
        end
    end
end

AntiTrapCheckButton.MouseButton1Click:Connect(function()
    ToggleAntiTrap()
end)

-- ==================================================
-- FEATURE 3: GOD MODE (BUTTON)
-- ==================================================
local GodModeHolder = Instance.new("Frame")
GodModeHolder.Size = UDim2.new(1, 0, 0, 52)
GodModeHolder.BackgroundTransparency = 1
GodModeHolder.LayoutOrder = 4
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

GodModeButton.MouseButton1Click:Connect(function()
    if _G.YOKUDO_GodMode then
        _G.YOKUDO_GodMode.Toggle()
        if _G.YOKUDO_GodMode.IsEnabled() then
            GodModeButton.Text = "ON"
        else
            GodModeButton.Text = "Click"
        end
    end
end)

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
    AntiTrap = {
        Holder = AntiTrapHolder,
        Check = AntiTrapCheckButton,
        GetState = function() return AntiTrapEnabled end
    },
    GodModeButton = GodModeButton
}

print("✅ Tabs Loaded (7 Tabs + Auto Farming + Setting Features)")
