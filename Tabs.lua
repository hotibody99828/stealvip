-- ==================================================
-- YOKUDO HUB | NEW PROJECT | Tabs
-- ==================================================

local TweenService = game:GetService("TweenService")

-- ==================================================
-- CREATE PAGES (ទទេ)
-- ==================================================
local HomePage = CreatePage("HOME")
local SettingPage = CreatePage("SETTING")

-- ==================================================
-- CREATE TABS
-- ==================================================
local HomeTab = CreateTab("Home", 1)
local SettingTab = CreateTab("Setting", 2)

-- ==================================================
-- TAB MAP
-- ==================================================
local Tabs = {
    [HomeTab] = HomePage,
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

SelectTab(HomeTab, HomePage)

-- ==================================================
-- HOME PAGE CONTENT (ទទេ - រង់ចាំ Features)
-- ==================================================
-- អ្នកអាចដាក់ Features នៅទីនេះតាមក្រោយ
-- ឧទាហរណ៍:
-- CreateSectionTitle(HomePage, "Main", 1)
-- local feature1 = CreateSmartCheckbox(HomePage, "Feature 1", 2, function() end, function() return false end)

-- ==================================================
-- SETTING PAGE CONTENT (ទទេ - រង់ចាំ Features)
-- ==================================================
-- អ្នកអាចដាក់ Features នៅទីនេះតាមក្រោយ

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_HomePage = HomePage
_G.YOKUDO_SettingPage = SettingPage

print("✅ Tabs Loaded (Empty - Ready for Features)")
