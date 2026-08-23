-- ========================================================
-- EGG ESP - WITH AREA NAMES
-- Shows "Egg #X [Area]" format
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🔍 EGG ESP - AREA DETECTION")
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
    local primaryPart = eggModel.PrimaryPart or 
                        eggModel:FindFirstChild("Hitbox") or 
                        eggModel:FindFirstChild("HitBox") or 
                        eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return "Unknown" end
    
    local pos = primaryPart.Position
    
    -- Starting area (center, low altitude)
    if pos.Y < 20 and math.abs(pos.X) < 500 and math.abs(pos.Z) < 500 then
        return "Start"
    end
    
    -- High altitude = Cosmic
    if pos.Y > 500 then
        return "Cosmic"
    end
    
    -- Area detection by X/Z coordinates
    local x, z = pos.X, pos.Z
    
    -- Forest: Left-Front quadrant
    if x >= -1000 and x < 0 and z >= 0 and z < 1000 then
        return "Forest"
    end
    
    -- Lake: Right-Front quadrant
    if x >= 0 and x < 1000 and z >= 0 and z < 1000 then
        return "Lake"
    end
    
    -- Snow: Left-Back quadrant
    if x >= -1000 and x < 0 and z >= -1000 and z < 0 then
        return "Snow"
    end
    
    -- Desert: Right-Back quadrant
    if x >= 0 and x < 1000 and z >= -1000 and z < 0 then
        return "Desert"
    end
    
    -- Jungle: Far Right-Front
    if x >= 1000 and x < 2000 and z >= 0 and z < 1000 then
        return "Jungle"
    end
    
    -- Volcano: Far Right-Back
    if x >= 1000 and x < 2000 and z >= -1000 and z < 0 then
        return "Volcano"
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
    
    -- Get area and create display text
    local area = getEggArea(eggModel)
    local displayText = "Egg #" .. eggCounter .. " [" .. area .. "]"
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESPArea"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
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
        area = area
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
    for _, espData in pairs(espCache) do
        if espData.billboard then
            espData.billboard:Destroy()
        end
    end
    espCache = {}
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
screenGui.Name = "EggESPAreaGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 300, 0, 220)
controlFrame.Position = UDim2.new(1, -320, 0, 20)
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
titleLabel.Text = "🥚 Egg ESP [Area]"
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = controlFrame

-- Count
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 50)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Total: " .. eggCounter
countLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
countLabel.TextSize = 14
countLabel.Font = Enum.Font.SourceSans
countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.Parent = controlFrame

-- Area breakdown
local areaLabel = Instance.new("TextLabel")
areaLabel.Size = UDim2.new(1, -20, 0, 60)
areaLabel.Position = UDim2.new(0, 10, 0, 75)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "Areas: Loading..."
areaLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
areaLabel.TextSize = 11
areaLabel.Font = Enum.Font.SourceSans
areaLabel.TextXAlignment = Enum.TextXAlignment.Left
areaLabel.TextYAlignment = Enum.TextYAlignment.Top
areaLabel.TextWrapped = true
areaLabel.Parent = controlFrame

-- Toggle ESP
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 35)
toggleBtn.Position = UDim2.new(0, 10, 0, 140)
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
distToggle.Size = UDim2.new(1, -20, 0, 35)
distToggle.Position = UDim2.new(0, 10, 0, 180)
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

-- Update GUI stats
task.spawn(function()
    while screenGui.Parent do
        task.wait(2)
        countLabel.Text = "Total: " .. eggCounter
        
        -- Count by area
        local areaCounts = {}
        for _, espData in pairs(espCache) do
            local area = espData.area or "Unknown"
            areaCounts[area] = (areaCounts[area] or 0) + 1
        end
        
        local areaText = ""
        for area, count in pairs(areaCounts) do
            if areaText ~= "" then areaText = areaText .. "\n" end
            areaText = areaText .. area .. ": " .. count
        end
        
        areaLabel.Text = areaText ~= "" and areaText or "No eggs detected"
    end
end)

-- Drag functionality
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
print("✅ EGG ESP WITH AREA NAMES LOADED!")
print("Format: Egg #X [Area]")
print("========================================")
