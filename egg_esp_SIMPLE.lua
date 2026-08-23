-- ========================================================
-- EGG ESP - SIMPLE VERSION
-- Shows egg count and distance only (no rarity - server-sided)
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🔍 EGG ESP - SIMPLE")
print("========================================")
print("Note: Rarity is server-sided")
print("Showing: Distance + Egg ID only")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    Enabled = true,
    MaxDistance = 2000,
    ShowDistance = true,
    TextSize = 14,
    Color = Color3.fromRGB(255, 200, 100),  -- Orange for all eggs
}

-- ========================================================
-- ESP CREATION
-- ========================================================

local espCache = {}
local eggCounter = 0

local function getEggName(eggModel)
    -- Try to find a descriptive name from egg children
    
    -- Method 1: Check for a Model child with descriptive name
    for _, child in pairs(eggModel:GetChildren()) do
        if child:IsA("Model") then
            local name = child.Name
            -- Skip generic names
            if not name:match("^[0-9a-f]+$") and 
               name ~= "Hitbox" and 
               name ~= "HitBox" and
               name ~= "Part_Union" and
               #name < 30 then
                return name
            end
        end
    end
    
    -- Method 2: Check for any Part with a descriptive name
    for _, child in pairs(eggModel:GetChildren()) do
        if child:IsA("BasePart") or child:IsA("UnionOperation") then
            local name = child.Name
            if not name:match("^[0-9a-f]+$") and 
               name ~= "Hitbox" and 
               name ~= "HitBox" and
               name ~= "Part" and
               name ~= "Part_Union" and
               #name < 30 and
               #name > 3 then
                return name
            end
        end
    end
    
    -- Method 3: Check attributes
    for attrName, attrValue in pairs(eggModel:GetAttributes()) do
        if attrName:lower():find("name") or attrName:lower():find("egg") then
            local value = tostring(attrValue)
            if #value < 30 and #value > 2 then
                return value
            end
        end
    end
    
    -- Method 4: Parse from workspace path (area name)
    local fullName = eggModel:GetFullName()
    local area = fullName:match("([%w]+):")
    if area and #area < 20 then
        return area .. " Egg"
    end
    
    -- Fallback: return nil (will show as "Egg #X")
    return nil
end
    local primaryPart = eggModel.PrimaryPart or eggModel:FindFirstChild("Hitbox") or eggModel:FindFirstChild("HitBox") or eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return nil end
    
    eggCounter = eggCounter + 1
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SimpleEggESP"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = primaryPart
    
    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    -- Egg Label (simple)
    local eggLabel = Instance.new("TextLabel")
    eggLabel.Size = UDim2.new(1, 0, 0.6, 0)
    eggLabel.Position = UDim2.new(0, 0, 0, 0)
    eggLabel.BackgroundTransparency = 1
    eggLabel.Text = "🥚 Egg #" .. eggCounter
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
        distanceLabel = distanceLabel,
        eggModel = eggModel,
        primaryPart = primaryPart
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
    
    -- Hide if too far
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
-- SCAN AND UPDATE LOOP
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

-- Initial scan
scanEggs()
print("✅ Found " .. eggCounter .. " eggs")

-- Update loop
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

-- Cleanup on death
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    eggCounter = 0
    scanEggs()
end)

-- ========================================================
-- GUI CONTROLS
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleEggESPGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

-- Control Frame
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 280, 0, 180)
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
titleLabel.Text = "🥚 Simple Egg ESP"
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = controlFrame

-- Egg Count
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 45)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Total Eggs: " .. eggCounter
countLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
countLabel.TextSize = 14
countLabel.Font = Enum.Font.SourceSans
countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.Parent = controlFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 75)
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
local distanceToggle = Instance.new("TextButton")
distanceToggle.Size = UDim2.new(1, -20, 0, 40)
distanceToggle.Position = UDim2.new(0, 10, 0, 125)
distanceToggle.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
distanceToggle.Text = "📏 Distance: ON"
distanceToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceToggle.TextSize = 13
distanceToggle.Font = Enum.Font.SourceSansBold
distanceToggle.Parent = controlFrame

local distCorner = Instance.new("UICorner")
distCorner.CornerRadius = UDim.new(0, 8)
distCorner.Parent = distanceToggle

distanceToggle.MouseButton1Click:Connect(function()
    CONFIG.ShowDistance = not CONFIG.ShowDistance
    distanceToggle.Text = CONFIG.ShowDistance and "📏 Distance: ON" or "📏 Distance: OFF"
end)

-- Update egg count periodically
task.spawn(function()
    while screenGui.Parent do
        task.wait(2)
        countLabel.Text = "Total Eggs: " .. eggCounter
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

-- Cleanup function
local function cleanup()
    if updateConnection then
        updateConnection:Disconnect()
    end
    
    for _, espData in pairs(espCache) do
        if espData.billboard and espData.billboard.Parent then
            espData.billboard:Destroy()
        end
    end
    
    espCache = {}
    
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end

print("========================================")
print("✅ SIMPLE EGG ESP LOADED!")
print("========================================")
print("⚠️  Rarity detection not available")
print("   (Server-sided data)")
print("Showing: Egg counter + distance")
print("========================================")
