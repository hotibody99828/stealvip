-- ==================================================
-- YOKUDO HUB | TAB | Auto Farming
-- ==================================================

local TabsManager = _G.YOKUDO_TabsManager
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoFarmingTab, AutoFarmingPage = TabsManager:RegisterTab("Auto Farming", 4, "AUTO_FARMING")

-- ==================================================
-- SETUP ASSETS
-- ==================================================
local Assets = ReplicatedStorage:WaitForChild("Data"):WaitForChild("Assets")
local Configs = Assets:WaitForChild("Configs")
local EggModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("Eggs")
local Container = workspace:WaitForChild("AreaEggSlotsClient")

local MeshIdToCategory = {}

local function BuildMeshIdMap()
    for _, Config in ipairs(Configs:GetChildren()) do
        local Success, Module = pcall(function()
            return require(Config)
        end)
        if Success and Module and Module.Egg then
            local ModelName = Module.Egg.ModelName or Config.Name
            local EggTemplate = EggModels:FindFirstChild(ModelName)
            if EggTemplate then
                for _, descendant in ipairs(EggTemplate:GetDescendants()) do
                    if descendant:IsA("MeshPart") and descendant.MeshId ~= "" then
                        MeshIdToCategory[descendant.MeshId] = Config.Name
                    end
                    if descendant:IsA("SpecialMesh") and descendant.MeshId ~= "" then
                        MeshIdToCategory[descendant.MeshId] = Config.Name
                    end
                end
            end
        end
    end
end

BuildMeshIdMap()

local function GetPetData(AssetCategory)
    local Config = Configs:FindFirstChild(AssetCategory)
    if not Config then return nil end
    
    local Data = {
        Name = AssetCategory,
        DisplayName = AssetCategory,
        EarningRate = 0,
        Icon = nil
    }
    
    local Success, Module = pcall(function()
        return require(Config)
    end)
    
    if Success and Module then
        Data.DisplayName = Module.DisplayName or AssetCategory
        Data.EarningRate = Module.EarningRate or 0
        Data.Icon = Module.Icon
    end
    
    return Data
end

local function FormatMoney(Amount)
    if type(Amount) ~= "number" then return tostring(Amount) end
    if Amount >= 1e12 then
        return string.format("%.2fT", Amount / 1e12)
    elseif Amount >= 1e9 then
        return string.format("%.2fB", Amount / 1e9)
    elseif Amount >= 1e6 then
        return string.format("%.2fM", Amount / 1e6)
    elseif Amount >= 1e3 then
        return string.format("%.2fK", Amount / 1e3)
    else
        return tostring(math.floor(Amount))
    end
end

local function CalculateRatePerSecond(EarningRate, Scale, Mutations)
    local PayoutFactor
    if Scale <= 5 then
        PayoutFactor = Scale ^ 1.85
    else
        PayoutFactor = (Scale / 5) ^ 1.2 * 19.637875755794113
    end
    
    local MutationMultiplier = 1
    if Mutations and #Mutations > 0 then
        local Success, MutationsModule = pcall(function()
            return require(ReplicatedStorage.Shared.Modules.Mutations)
        end)
        if Success and MutationsModule then
            MutationMultiplier = MutationsModule.EarningsFor(Mutations)
        end
    end
    
    return math.round(EarningRate * PayoutFactor * MutationMultiplier)
end

local function FindAssetCategory(EggModel)
    for _, descendant in ipairs(EggModel:GetDescendants()) do
        if descendant:IsA("MeshPart") and descendant.MeshId ~= "" then
            local Category = MeshIdToCategory[descendant.MeshId]
            if Category then return Category end
        end
        if descendant:IsA("SpecialMesh") and descendant.MeshId ~= "" then
            local Category = MeshIdToCategory[descendant.MeshId]
            if Category then return Category end
        end
    end
    return nil
end

-- ==================================================
-- CONTENT
-- ==================================================
CreateSectionTitle(AutoFarmingPage, "Auto Farming", 1)

-- Feature 1: Click Get Egg (ដាក់ខាងលើ)
local GetEggBox = Instance.new("Frame")
GetEggBox.Size = UDim2.new(1, 0, 0, 90)
GetEggBox.BackgroundColor3 = Color3.fromRGB(28, 29, 42)
GetEggBox.BorderSizePixel = 0
GetEggBox.LayoutOrder = 2
GetEggBox.Parent = AutoFarmingPage

local GetEggBoxCorner = Instance.new("UICorner")
GetEggBoxCorner.CornerRadius = UDim.new(0, 8)
GetEggBoxCorner.Parent = GetEggBox

local GetEggBoxStroke = Instance.new("UIStroke")
GetEggBoxStroke.Color = Color3.fromRGB(105, 90, 190)
GetEggBoxStroke.Thickness = 1.5
GetEggBoxStroke.Transparency = 0.5
GetEggBoxStroke.Parent = GetEggBox

local GetEggIcon = Instance.new("ImageLabel")
GetEggIcon.Size = UDim2.new(0, 60, 0, 60)
GetEggIcon.Position = UDim2.new(0, 10, 0.5, -30)
GetEggIcon.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
GetEggIcon.BorderSizePixel = 0
GetEggIcon.Image = ""
GetEggIcon.Parent = GetEggBox

local GetEggIconCorner = Instance.new("UICorner")
GetEggIconCorner.CornerRadius = UDim.new(0, 8)
GetEggIconCorner.Parent = GetEggIcon

local GetEggName = Instance.new("TextLabel")
GetEggName.Size = UDim2.new(1, -160, 0, 20)
GetEggName.Position = UDim2.new(0, 80, 0, 15)
GetEggName.BackgroundTransparency = 1
GetEggName.Text = "No Egg Selected"
GetEggName.TextColor3 = Color3.fromRGB(255, 255, 255)
GetEggName.TextSize = 13
GetEggName.TextXAlignment = Enum.TextXAlignment.Left
GetEggName.Font = Enum.Font.GothamBold
GetEggName.Parent = GetEggBox

local GetEggRate = Instance.new("TextLabel")
GetEggRate.Size = UDim2.new(1, -160, 0, 20)
GetEggRate.Position = UDim2.new(0, 80, 0, 38)
GetEggRate.BackgroundTransparency = 1
GetEggRate.Text = "$0/s"
GetEggRate.TextColor3 = Color3.fromRGB(100, 255, 100)
GetEggRate.TextSize = 12
GetEggRate.TextXAlignment = Enum.TextXAlignment.Left
GetEggRate.Font = Enum.Font.Gotham
GetEggRate.Parent = GetEggBox

local GetEggCheckButton = Instance.new("TextButton")
GetEggCheckButton.Size = UDim2.new(0, 30, 0, 30)
GetEggCheckButton.Position = UDim2.new(1, -40, 0.5, -15)
GetEggCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
GetEggCheckButton.BorderSizePixel = 0
GetEggCheckButton.Text = ""
GetEggCheckButton.AutoButtonColor = false
GetEggCheckButton.Parent = GetEggBox

local GetEggCheckCorner = Instance.new("UICorner")
GetEggCheckCorner.CornerRadius = UDim.new(0, 6)
GetEggCheckCorner.Parent = GetEggCheckButton

local GetEggCheckStroke = Instance.new("UIStroke")
GetEggCheckStroke.Color = Color3.fromRGB(200, 200, 220)
GetEggCheckStroke.Thickness = 1.5
GetEggCheckStroke.Parent = GetEggCheckButton

local GetEggCheck = Instance.new("TextLabel")
GetEggCheck.Size = UDim2.new(1, 0, 1, 0)
GetEggCheck.BackgroundTransparency = 1
GetEggCheck.Text = "✓"
GetEggCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
GetEggCheck.TextSize = 18
GetEggCheck.Font = Enum.Font.GothamBold
GetEggCheck.Visible = false
GetEggCheck.Parent = GetEggCheckButton

local SelectedEggId = nil
local GetEggEnabled = false

local function UpdateGetEggBox(Icon, Name, Rate, EggId)
    GetEggIcon.Image = Icon or ""
    GetEggName.Text = Name or "No Egg Selected"
    GetEggRate.Text = "$" .. FormatMoney(Rate or 0) .. "/s"
    SelectedEggId = EggId
end

local function ToggleGetEgg()
    GetEggEnabled = not GetEggEnabled
    GetEggCheck.Visible = GetEggEnabled
    if GetEggEnabled then
        GetEggCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        GetEggCheckStroke.Color = Color3.fromRGB(135, 120, 225)
        if SelectedEggId and _G.YOKUDO_TeleportSystem then
            _G.YOKUDO_TeleportSystem.SetTargetId(SelectedEggId)
            _G.YOKUDO_TeleportSystem.Enable()
        end
    else
        GetEggCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        GetEggCheckStroke.Color = Color3.fromRGB(200, 200, 220)
        if _G.YOKUDO_TeleportSystem then
            _G.YOKUDO_TeleportSystem.Disable()
            _G.YOKUDO_TeleportSystem.ResetState()
        end
    end
end

GetEggCheckButton.MouseButton1Click:Connect(function()
    ToggleGetEgg()
end)

-- Feature 2: Start Check Egg (ដាក់ខាងក្រោម)
local CheckEggHolder = Instance.new("Frame")
CheckEggHolder.Size = UDim2.new(1, 0, 0, 32)
CheckEggHolder.BackgroundTransparency = 1
CheckEggHolder.LayoutOrder = 3
CheckEggHolder.Parent = AutoFarmingPage

local CheckEggLabel = Instance.new("TextLabel")
CheckEggLabel.Size = UDim2.new(1, -50, 1, 0)
CheckEggLabel.BackgroundTransparency = 1
CheckEggLabel.Text = "Start Check Egg"
CheckEggLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
CheckEggLabel.TextSize = 13
CheckEggLabel.TextXAlignment = Enum.TextXAlignment.Left
CheckEggLabel.TextYAlignment = Enum.TextYAlignment.Center
CheckEggLabel.Font = Enum.Font.GothamBold
CheckEggLabel.Parent = CheckEggHolder

local CheckEggCheckButton = Instance.new("TextButton")
CheckEggCheckButton.Size = UDim2.new(0, 26, 0, 26)
CheckEggCheckButton.Position = UDim2.new(1, -26, 0.5, -13)
CheckEggCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
CheckEggCheckButton.BorderSizePixel = 0
CheckEggCheckButton.Text = ""
CheckEggCheckButton.AutoButtonColor = false
CheckEggCheckButton.Parent = CheckEggHolder

local CheckEggCorner = Instance.new("UICorner")
CheckEggCorner.CornerRadius = UDim.new(0, 6)
CheckEggCorner.Parent = CheckEggCheckButton

local CheckEggStroke = Instance.new("UIStroke")
CheckEggStroke.Color = Color3.fromRGB(200, 200, 220)
CheckEggStroke.Thickness = 1.5
CheckEggStroke.Parent = CheckEggCheckButton

local CheckEggCheck = Instance.new("TextLabel")
CheckEggCheck.Size = UDim2.new(1, 0, 1, 0)
CheckEggCheck.BackgroundTransparency = 1
CheckEggCheck.Text = "✓"
CheckEggCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckEggCheck.TextSize = 18
CheckEggCheck.Font = Enum.Font.GothamBold
CheckEggCheck.Visible = false
CheckEggCheck.Parent = CheckEggCheckButton

local CheckEggEnabled = false
local EggScrollFrame = nil

local function CreateEggEntry(EggModel)
    local AssetCategory = FindAssetCategory(EggModel)
    if not AssetCategory then return nil end
    
    local Data = GetPetData(AssetCategory)
    if not Data then return nil end
    
    local Scale = EggModel:GetAttribute("AssetScale") or 1
    local Mutations = EggModel:GetAttribute("Mutations") or {}
    local RealRate = CalculateRatePerSecond(Data.EarningRate, Scale, Mutations)
    local EggId = EggModel.Name
    
    local Entry = Instance.new("Frame")
    Entry.Size = UDim2.new(1, -8, 0, 50)
    Entry.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
    Entry.BorderSizePixel = 0
    Entry.Parent = EggScrollFrame
    
    local EntryCorner = Instance.new("UICorner")
    EntryCorner.CornerRadius = UDim.new(0, 6)
    EntryCorner.Parent = Entry
    
    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.new(0, 40, 0, 40)
    IconFrame.Position = UDim2.new(0, 5, 0.5, -20)
    IconFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = Entry
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 6)
    IconCorner.Parent = IconFrame
    
    local IconImage = Instance.new("ImageLabel")
    IconImage.Size = UDim2.new(1, -4, 1, -4)
    IconImage.Position = UDim2.new(0, 2, 0, 2)
    IconImage.BackgroundTransparency = 1
    IconImage.Image = Data.Icon or ""
    IconImage.Parent = IconFrame
    
    local ImageCorner = Instance.new("UICorner")
    ImageCorner.CornerRadius = UDim.new(0, 6)
    ImageCorner.Parent = IconImage
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -150, 0, 18)
    NameLabel.Position = UDim2.new(0, 55, 0, 6)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Data.DisplayName
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Parent = Entry
    
    local RateLabel = Instance.new("TextLabel")
    RateLabel.Size = UDim2.new(1, -150, 0, 16)
    RateLabel.Position = UDim2.new(0, 55, 0, 26)
    RateLabel.BackgroundTransparency = 1
    RateLabel.Text = "$" .. FormatMoney(RealRate) .. "/s"
    RateLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    RateLabel.TextSize = 11
    RateLabel.TextXAlignment = Enum.TextXAlignment.Left
    RateLabel.Font = Enum.Font.Gotham
    RateLabel.Parent = Entry
    
    local SelectButton = Instance.new("TextButton")
    SelectButton.Size = UDim2.new(0, 60, 0, 24)
    SelectButton.Position = UDim2.new(1, -65, 0.5, -12)
    SelectButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    SelectButton.BorderSizePixel = 0
    SelectButton.Text = "Select"
    SelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectButton.TextSize = 11
    SelectButton.Font = Enum.Font.GothamBold
    SelectButton.AutoButtonColor = false
    SelectButton.Parent = Entry
    
    local SelectCorner = Instance.new("UICorner")
    SelectCorner.CornerRadius = UDim.new(0, 4)
    SelectCorner.Parent = SelectButton
    
    SelectButton.MouseButton1Click:Connect(function()
        UpdateGetEggBox(Data.Icon, Data.DisplayName, RealRate, EggId)
    end)
    
    return Entry
end

local function RefreshEggList()
    if not CheckEggEnabled then return end
    
    for _, child in ipairs(EggScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local EggDataList = {}
    
    for _, child in ipairs(Container:GetChildren()) do
        if child:IsA("Model") then
            local AssetCategory = FindAssetCategory(child)
            if AssetCategory then
                local Data = GetPetData(AssetCategory)
                if Data then
                    local Scale = child:GetAttribute("AssetScale") or 1
                    local Mutations = child:GetAttribute("Mutations") or {}
                    local RealRate = CalculateRatePerSecond(Data.EarningRate, Scale, Mutations)
                    table.insert(EggDataList, {
                        Model = child,
                        Data = Data,
                        Rate = RealRate
                    })
                end
            end
        end
    end
    
    table.sort(EggDataList, function(a, b)
        return a.Rate > b.Rate
    end)
    
    for _, EggData in ipairs(EggDataList) do
        CreateEggEntry(EggData.Model)
    end
    
    EggScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #EggDataList * 55)
end

local function ToggleCheckEgg()
    CheckEggEnabled = not CheckEggEnabled
    CheckEggCheck.Visible = CheckEggEnabled
    if CheckEggEnabled then
        CheckEggCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        CheckEggStroke.Color = Color3.fromRGB(135, 120, 225)
        RefreshEggList()
    else
        CheckEggCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        CheckEggStroke.Color = Color3.fromRGB(200, 200, 220)
        for _, child in ipairs(EggScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
end

CheckEggCheckButton.MouseButton1Click:Connect(function()
    ToggleCheckEgg()
end)

-- Egg List
EggScrollFrame = Instance.new("ScrollingFrame")
EggScrollFrame.Size = UDim2.new(1, 0, 0, 220)
EggScrollFrame.BackgroundTransparency = 1
EggScrollFrame.BorderSizePixel = 0
EggScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
EggScrollFrame.ScrollBarThickness = 4
EggScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 220)
EggScrollFrame.LayoutOrder = 4
EggScrollFrame.Parent = AutoFarmingPage

local EggListLayout = Instance.new("UIListLayout")
EggListLayout.Padding = UDim.new(0, 4)
EggListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EggListLayout.Parent = EggScrollFrame

Container.ChildAdded:Connect(function()
    task.wait(0.5)
    if CheckEggEnabled then
        RefreshEggList()
    end
end)

Container.ChildRemoved:Connect(function()
    task.wait(0.5)
    if CheckEggEnabled then
        RefreshEggList()
    end
end)

print("✅ Auto Farming Tab Loaded")
