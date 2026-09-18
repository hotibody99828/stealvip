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
GodModeButton.ClipsDescendants = true -- សម្រាប់ Animation
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
-- ANIMATION FRAME (រត់ពីស្តាំទៅឆ្វេង)
-- ==================================================
local AnimationFrame = Instance.new("Frame")
AnimationFrame.Name = "AnimationFrame"
AnimationFrame.Size = UDim2.new(0, 0, 1, 0)
AnimationFrame.Position = UDim2.new(1, 0, 0, 0) -- ចាប់ផ្តើមពីស្តាំ
AnimationFrame.BackgroundColor3 = Color3.fromRGB(180, 160, 255)
AnimationFrame.BackgroundTransparency = 0.5
AnimationFrame.BorderSizePixel = 0
AnimationFrame.ZIndex = 2
AnimationFrame.Parent = GodModeButton

local AnimationCorner = Instance.new("UICorner")
AnimationCorner.CornerRadius = UDim.new(0, 6)
AnimationCorner.Parent = AnimationFrame

-- ==================================================
-- BUTTON ANIMATION (Hover)
-- ==================================================
GodModeButton.MouseEnter:Connect(function()
    TweenService:Create(GodModeButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(125, 110, 220)
    }):Play()
end)

GodModeButton.MouseLeave:Connect(function()
    TweenService:Create(GodModeButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    }):Play()
end)

-- ==================================================
-- SLIDE ANIMATION FUNCTION
-- ==================================================
local function PlaySlideAnimation()
    -- Reset Animation Frame
    AnimationFrame.Size = UDim2.new(0, 0, 1, 0)
    AnimationFrame.Position = UDim2.new(1, 0, 0, 0) -- ចាប់ផ្តើមពីស្តាំ
    AnimationFrame.BackgroundTransparency = 0.5
    
    -- រត់ពីស្តាំទៅឆ្វេង
    local SlideTween = TweenService:Create(
        AnimationFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(1, 0, 1, 0), -- ពង្រីកពេញ
            Position = UDim2.new(0, 0, 0, 0) -- ផ្លាស់ទៅឆ្វេង
        }
    )
    
    SlideTween:Play()
    
    -- បន្ទាប់ពីរត់រួច → Fade Out
    SlideTween.Completed:Connect(function()
        TweenService:Create(
            AnimationFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                BackgroundTransparency = 1
            }
        ):Play()
        
        task.wait(0.2)
        
        -- Reset
        AnimationFrame.BackgroundTransparency = 0.5
        AnimationFrame.Size = UDim2.new(0, 0, 1, 0)
        AnimationFrame.Position = UDim2.new(1, 0, 0, 0)
    end)
end

-- ==================================================
-- CLICK → PLAY ANIMATION + ENABLE GOD MODE
-- ==================================================
GodModeButton.MouseButton1Click:Connect(function()
    -- Play Slide Animation
    PlaySlideAnimation()
    
    -- Enable God Mode
    if _G.YOKUDO_GodMode then
        _G.YOKUDO_GodMode.Enable()
    end
end)

print("✅ Setting Tab Loaded")
