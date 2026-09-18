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

-- ==================================================
-- BUTTON ANIMATION (ច្បាស់)
-- ==================================================
GodModeButton.MouseEnter:Connect(function()
    TweenService:Create(GodModeButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(125, 110, 220),
        Size = UDim2.new(0, 72, 0, 27)
    }):Play()
end)

GodModeButton.MouseLeave:Connect(function()
    TweenService:Create(GodModeButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(105, 90, 190),
        Size = UDim2.new(0, 70, 0, 26)
    }):Play()
end)

-- ==================================================
-- NOTIFICATION FUNCTION (Glass + Left + 5s)
-- ==================================================
local function ShowNotification(Text)
    local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    local NotifyGui = Instance.new("ScreenGui")
    NotifyGui.Name = "YokudoNotify"
    NotifyGui.ResetOnSpawn = false
    NotifyGui.Parent = PlayerGui
    
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(0, 220, 0, 50)
    NotifyFrame.Position = UDim2.new(0, -250, 0, 20) -- ចាប់ផ្តើមពីឆ្វេង (ក្រៅអេក្រង់)
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NotifyFrame.BackgroundTransparency = 0.7 -- Glass
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Parent = NotifyGui
    
    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 10)
    NotifyCorner.Parent = NotifyFrame
    
    local NotifyStroke = Instance.new("UIStroke")
    NotifyStroke.Color = Color3.fromRGB(255, 255, 255)
    NotifyStroke.Thickness = 1
    NotifyStroke.Transparency = 0.5
    NotifyStroke.Parent = NotifyFrame
    
    local NotifyText = Instance.new("TextLabel")
    NotifyText.Size = UDim2.new(1, -20, 1, 0)
    NotifyText.Position = UDim2.new(0, 10, 0, 0)
    NotifyText.BackgroundTransparency = 1
    NotifyText.Text = Text
    NotifyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifyText.TextSize = 13
    NotifyText.TextXAlignment = Enum.TextXAlignment.Left
    NotifyText.TextYAlignment = Enum.TextYAlignment.Center
    NotifyText.Font = Enum.Font.GothamBold
    NotifyText.Parent = NotifyFrame
    
    -- Slide In (ពីឆ្វេង)
    TweenService:Create(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 20, 0, 20)
    }):Play()
    
    -- លូត 5s
    task.wait(5)
    
    -- Slide Out (ត្រឡប់ទៅឆ្វេង)
    TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0, -250, 0, 20),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(NotifyText, TweenInfo.new(0.3), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(NotifyStroke, TweenInfo.new(0.3), {
        Transparency = 1
    }):Play()
    
    task.wait(0.3)
    NotifyGui:Destroy()
end

-- ==================================================
-- CLICK → ENABLE GOD MODE + NOTIFY
-- ==================================================
GodModeButton.MouseButton1Click:Connect(function()
    -- Play Click Animation (Scale)
    TweenService:Create(GodModeButton, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 60, 0, 22)
    }):Play()
    
    task.wait(0.08)
    
    TweenService:Create(GodModeButton, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 70, 0, 26)
    }):Play()
    
    -- Enable God Mode
    if _G.YOKUDO_GodMode then
        _G.YOKUDO_GodMode.Enable()
    end
    
    -- Show Notification
    ShowNotification("God Mode Start")
end)

print("✅ Setting Tab Loaded")
