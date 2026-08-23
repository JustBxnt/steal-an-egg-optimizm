-- ========================================================
-- EGG ESP - AUTO AREA DETECTION
-- Uses pre-tagged coordinates to show area names
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🥚 EGG ESP - AUTO AREA DETECTION")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    Enabled = true,
    MaxDistance = 2000,
    ShowDistance = true,
    TextSize = 14,
    MatchRadius = 5,  -- Match eggs within 5 studs of tagged position
}

-- ========================================================
-- TAGGED EGG POSITIONS
-- ========================================================

local eggPositions = {
    {area = "JUNGLE", x = 1194.4, y = 68.1, z = -412.1},
    {area = "SNOW", x = 1489.0, y = 69.3, z = -317.8},
    {area = "LAKE", x = 738.1, y = 68.0, z = -411.1},
    {area = "LAKE", x = 740.8, y = 68.6, z = -405.6},
    {area = "JUNGLE", x = 1192.4, y = 68.6, z = -406.4},
    {area = "VOLCANO", x = 1884.5, y = 69.3, z = -400.6},
    {area = "FOREST", x = 591.8, y = 68.1, z = -325.6},
    {area = "DESERT", x = 946.4, y = 69.4, z = -327.3},
    {area = "ABYSS OCEAN", x = 2278.2, y = 68.7, z = -330.1},
    {area = "COSMIC", x = 3397.5, y = 69.6, z = -322.7},
    {area = "DESERT", x = 944.4, y = 68.2, z = -321.5},
    {area = "COSMIC", x = 3392.1, y = 68.1, z = -321.3},
    {area = "COSMIC", x = 3394.8, y = 68.1, z = -328.1},
    {area = "FOREST", x = 597.4, y = 68.0, z = -324.8},
    {area = "VOLCANO", x = 1879.0, y = 67.6, z = -401.4},
    {area = "PREHISTORIC", x = 2818.9, y = 68.1, z = -401.0},
    {area = "VOLCANO", x = 1882.6, y = 68.0, z = -394.8},
    {area = "DESERT", x = 955.4, y = 67.9, z = -322.0},
    {area = "FOREST", x = 593.8, y = 68.1, z = -331.4},
    {area = "FOREST", x = 602.7, y = 68.3, z = -326.1},
    {area = "ABYSS OCEAN", x = 2281.7, y = 67.9, z = -323.5},
    {area = "COSMIC", x = 3388.6, y = 69.2, z = -328.0},
    {area = "COSMIC", x = 3386.6, y = 68.0, z = -322.2},
    {area = "ABYSS OCEAN", x = 2276.2, y = 67.9, z = -324.3},
    {area = "FOREST", x = 600.1, y = 69.0, z = -331.5},
    {area = "PREHISTORIC", x = 2808.0, y = 73.1, z = -400.5},
    {area = "PREHISTORIC", x = 2810.7, y = 72.5, z = -395.0},
    {area = "ABYSS OCEAN", x = 2284.4, y = 67.8, z = -330.3},
    {area = "JUNGLE", x = 1188.8, y = 68.7, z = -413.0},
    {area = "DESERT", x = 950.0, y = 68.1, z = -320.6},
    {area = "LAKE", x = 747.1, y = 68.2, z = -405.8},
    {area = "PREHISTORIC", x = 2816.9, y = 69.8, z = -395.2},
    {area = "ABYSS OCEAN", x = 2287.1, y = 67.9, z = -324.8},
    {area = "DESERT", x = 952.7, y = 68.4, z = -327.4},
    {area = "JUNGLE", x = 1186.1, y = 68.1, z = -406.2},
    {area = "LAKE", x = 749.1, y = 68.3, z = -411.6},
    {area = "SNOW", x = 1492.5, y = 68.9, z = -311.2},
    {area = "SNOW", x = 1497.9, y = 69.2, z = -312.5},
}

-- ========================================================
-- AREA COLORS
-- ========================================================

local areaColors = {
    FOREST = Color3.fromRGB(34, 139, 34),
    LAKE = Color3.fromRGB(30, 144, 255),
    DESERT = Color3.fromRGB(237, 201, 175),
    JUNGLE = Color3.fromRGB(0, 128, 0),
    SNOW = Color3.fromRGB(135, 206, 250),
    VOLCANO = Color3.fromRGB(255, 69, 0),
    ["ABYSS OCEAN"] = Color3.fromRGB(0, 0, 139),
    PREHISTORIC = Color3.fromRGB(240, 248, 255),
    COSMIC = Color3.fromRGB(138, 43, 226),
}

-- ========================================================
-- AREA DETECTION
-- ========================================================

local function getEggArea(eggPosition)
    -- Find closest tagged position
    local closestDist = math.huge
    local closestArea = nil
    local matchedPos = nil
    
    for _, taggedPos in ipairs(eggPositions) do
        local tagPos = Vector3.new(taggedPos.x, taggedPos.y, taggedPos.z)
        local distance = (eggPosition - tagPos).Magnitude
        
        if distance < closestDist and distance <= CONFIG.MatchRadius then
            closestDist = distance
            closestArea = taggedPos.area
            matchedPos = tagPos
        end
    end
    
    return closestArea, closestDist, matchedPos
end

-- ========================================================
-- ESP CREATION
-- ========================================================

local espCache = {}
local eggCounter = 0
local areaCounts = {}

local function createESP(eggModel)
    local primaryPart = eggModel.PrimaryPart or 
                        eggModel:FindFirstChild("Hitbox") or 
                        eggModel:FindFirstChild("HitBox") or 
                        eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return nil end
    
    -- Detect area from position
    local area, matchDist, matchPos = getEggArea(primaryPart.Position)
    
    if not area then
        -- Unknown egg (not in tagged list)
        return nil
    end
    
    -- Count eggs per area
    areaCounts[area] = (areaCounts[area] or 0) + 1
    local areaNumber = areaCounts[area]
    
    eggCounter = eggCounter + 1
    
    local displayText = "Egg #" .. areaNumber .. " [" .. area .. "]"
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESPArea"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = primaryPart
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    local eggLabel = Instance.new("TextLabel")
    eggLabel.Size = UDim2.new(1, 0, 0.6, 0)
    eggLabel.BackgroundTransparency = 1
    eggLabel.Text = "🥚 " .. displayText
    eggLabel.TextColor3 = areaColors[area] or Color3.fromRGB(255, 200, 100)
    eggLabel.TextSize = CONFIG.TextSize
    eggLabel.Font = Enum.Font.SourceSansBold
    eggLabel.TextStrokeTransparency = 0.5
    eggLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    eggLabel.Parent = frame
    
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
    
    print(string.format("✅ ESP: %s (matched %.1f studs)", displayText, matchDist))
    
    return {
        billboard = billboard,
        eggLabel = eggLabel,
        distanceLabel = distanceLabel,
        eggModel = eggModel,
        primaryPart = primaryPart,
        area = area,
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
print("✅ Found " .. eggCounter .. " eggs from tagged positions")

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
    areaCounts = {}
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
screenGui.Name = "EggESPAutoAreaGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 300, 0, 200)
controlFrame.Position = UDim2.new(1, -320, 0, 20)
controlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
controlFrame.BorderSizePixel = 0
controlFrame.Active = true
controlFrame.Draggable = true
controlFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = controlFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 200, 255)
frameStroke.Thickness = 2
frameStroke.Parent = controlFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 35)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🥚 Egg ESP [Auto Area]"
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = controlFrame

-- Count
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 50)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Total: " .. eggCounter .. " / " .. #eggPositions
countLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
countLabel.TextSize = 14
countLabel.Font = Enum.Font.SourceSans
countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.Parent = controlFrame

-- Area breakdown
local areaLabel = Instance.new("TextLabel")
areaLabel.Size = UDim2.new(1, -20, 0, 80)
areaLabel.Position = UDim2.new(0, 10, 0, 75)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "Loading..."
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
toggleBtn.Position = UDim2.new(0, 10, 0, 160)
toggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
toggleBtn.Text = "✅ ESP: ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = controlFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
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

-- Update counts
task.spawn(function()
    while screenGui.Parent do
        task.wait(2)
        countLabel.Text = "Total: " .. eggCounter .. " / " .. #eggPositions
        
        local areaText = ""
        for area, count in pairs(areaCounts) do
            if areaText ~= "" then areaText = areaText .. "\n" end
            areaText = areaText .. area .. ": " .. count
        end
        
        areaLabel.Text = areaText ~= "" and areaText or "No eggs detected yet"
    end
end)

print("========================================")
print("✅ EGG ESP WITH AUTO AREA LOADED!")
print("Tagged positions: " .. #eggPositions)
print("Match radius: " .. CONFIG.MatchRadius .. " studs")
print("========================================")
