-- ========================================================
-- EGG ESP - WITH NAMES
-- Shows egg names (if available) + distance
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🔍 EGG ESP - WITH NAMES")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    Enabled = true,
    MaxDistance = 2000,
    ShowDistance = true,
    TextSize = 14,
    Color = Color3.fromRGB(255, 200, 100),  -- Orange
}

-- ========================================================
-- AREA DETECTION
-- ========================================================

local function getEggArea(eggModel)
    -- Get area from egg position (comparing to known area locations)
    local primaryPart = eggModel.PrimaryPart or 
                        eggModel:FindFirstChild("Hitbox") or 
                        eggModel:FindFirstChild("HitBox") or 
                        eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return "Unknown" end
    
    local pos = primaryPart.Position
    
    -- Area detection based on position ranges (approximate)
    -- You can adjust these ranges based on actual map layout
    
    -- Starting area (usually center, low altitude)
    if pos.Y < 20 and math.abs(pos.X) < 500 and math.abs(pos.Z) < 500 then
        return "Start"
    end
    
    -- Define area boundaries (adjust these based on your game)
    local areas = {
        {name = "Forest", x = {-1000, 0}, z = {0, 1000}},
        {name = "Lake", x = {0, 1000}, z = {0, 1000}},
        {name = "Snow", x = {-1000, 0}, z = {-1000, 0}},
        {name = "Desert", x = {0, 1000}, z = {-1000, 0}},
        {name = "Jungle", x = {1000, 2000}, z = {0, 1000}},
        {name = "Volcano", x = {1000, 2000}, z = {-1000, 0}},
        {name = "Cosmic", y = {500, 2000}}, -- High altitude
    }
    
    -- Check each area
    for _, area in ipairs(areas) do
        local inArea = true
        
        if area.x then
            if pos.X < area.x[1] or pos.X > area.x[2] then
                inArea = false
            end
        end
        
        if area.z and inArea then
            if pos.Z < area.z[1] or pos.Z > area.z[2] then
                inArea = false
            end
        end
        
        if area.y and inArea then
            if pos.Y < area.y[1] or pos.Y > area.y[2] then
                inArea = false
            end
        end
        
        if inArea then
            return area.name
        end
    end
    
    return "Unknown"
end

-- ========================================================
-- ESP CREATION
-- ========================================================

local espCache = {}
local eggCounter = 0

local function createESP(eggModel)
    local primaryPart = eggModel.PrimaryPart or 
                        eggModel:FindFirstChild("Hitbox") or 
                        eggModel:FindFirstChild("HitBox") or 
                        eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return nil end
    
    eggCounter = eggCounter + 1
    
    -- Try to get descriptive name
    local eggName = getEggName(eggModel)
    local displayText = eggName or ("Egg #" .. eggCounter)
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESPWithNames"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 150, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = primaryPart
    
    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    -- Egg Label
    local eggLabel = Instance.new("TextLabel")
    eggLabel.Size = UDim2.new(1, 0, 0.6, 0)
    eggLabel.BackgroundTransparency = 1
    eggLabel.Text = "🥚 " .. displayText
    eggLabel.TextColor3 = CONFIG.Color
    eggLabel.TextSize = CONFIG.TextSize
    eggLabel.Font = Enum.Font.SourceSansBold
    eggLabel.TextStrokeTransparency = 0.5
    eggLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    eggLabel.Parent = frame
    
    -- Distance Label
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextSize = CONFIG.TextSize - 2
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Parent = frame
    
    return {
        billboard = billboard,
        eggLabel = eggLabel,
        distanceLabel = distanceLabel,
        eggModel = eggModel,
        primaryPart = primaryPart,
        hasName = eggName ~= nil
    }
end

local function updateESP(espData)
    if not espData or not espData.eggModel.Parent or not espData.primaryPart.Parent then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then return true end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    
    local distance = (hrp.Position - espData.primaryPart.Position).Magnitude
    
    if distance > CONFIG.MaxDistance then
        espData.billboard.Enabled = false
        return true
    end
    
    espData.billboard.Enabled = CONFIG.Enabled
    
    if CONFIG.Enabled and CONFIG.ShowDistance then
        espData.distanceLabel.Text = math.floor(distance) .. " studs"
    else
        espData.distanceLabel.Text = ""
    end
    
    return true
end

-- ========================================================
-- SCAN AND UPDATE
-- ========================================================

local function scanEggs()
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not areaEggs then return end
    
    for _, child in pairs(areaEggs:GetChildren()) do
        if child:IsA("Model") and not espCache[child] then
            local esp = createESP(child)
            if esp then
                espCache[child] = esp
            end
        end
    end
end

scanEggs()
print("✅ Found " .. eggCounter .. " eggs")

local updateConnection = RunService.RenderStepped:Connect(function()
    scanEggs()
    
    for eggModel, espData in pairs(espCache) do
        if not updateESP(espData) then
            if espData.billboard and espData.billboard.Parent then
                espData.billboard:Destroy()
            end
            espCache[eggModel] = nil
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    eggCounter = 0
    scanEggs()
end)

-- ========================================================
-- GUI
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggESPWithNamesGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 280, 0, 200)
controlFrame.Position = UDim2.new(1, -300, 0, 20)
controlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
controlFrame.BorderSizePixel = 0
controlFrame.Active = true
controlFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = controlFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 200, 100)
frameStroke.Thickness = 2
frameStroke.Parent = controlFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 35)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🥚 Egg ESP"
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = controlFrame

-- Count
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 45)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Total: " .. eggCounter
countLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
countLabel.TextSize = 14
countLabel.Font = Enum.Font.SourceSans
countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.Parent = controlFrame

-- Count named eggs
local namedCount = 0
for _, espData in pairs(espCache) do
    if espData.hasName then
        namedCount = namedCount + 1
    end
end

local namedLabel = Instance.new("TextLabel")
namedLabel.Size = UDim2.new(1, -20, 0, 20)
namedLabel.Position = UDim2.new(0, 10, 0, 70)
namedLabel.BackgroundTransparency = 1
namedLabel.Text = "With names: " .. namedCount
namedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
namedLabel.TextSize = 12
namedLabel.Font = Enum.Font.SourceSans
namedLabel.TextXAlignment = Enum.TextXAlignment.Left
namedLabel.Parent = controlFrame

-- Toggle
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
toggleBtn.Text = "✅ ESP: ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = controlFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    CONFIG.Enabled = not CONFIG.Enabled
    if CONFIG.Enabled then
        toggleBtn.Text = "✅ ESP: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        toggleBtn.Text = "❌ ESP: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- Distance Toggle
local distToggle = Instance.new("TextButton")
distToggle.Size = UDim2.new(1, -20, 0, 40)
distToggle.Position = UDim2.new(0, 10, 0, 150)
distToggle.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
distToggle.Text = "📏 Distance: ON"
distToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
distToggle.TextSize = 13
distToggle.Font = Enum.Font.SourceSansBold
distToggle.Parent = controlFrame

local distCorner = Instance.new("UICorner")
distCorner.CornerRadius = UDim.new(0, 8)
distCorner.Parent = distToggle

distToggle.MouseButton1Click:Connect(function()
    CONFIG.ShowDistance = not CONFIG.ShowDistance
    distToggle.Text = CONFIG.ShowDistance and "📏 Distance: ON" or "📏 Distance: OFF"
end)

-- Update counts
task.spawn(function()
    while screenGui.Parent do
        task.wait(2)
        countLabel.Text = "Total: " .. eggCounter
        
        local named = 0
        for _, espData in pairs(espCache) do
            if espData.hasName then
                named = named + 1
            end
        end
        namedLabel.Text = "With names: " .. named
    end
end)

-- Drag
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = controlFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        controlFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

print("========================================")
print("✅ EGG ESP WITH NAMES LOADED!")
print("========================================")
