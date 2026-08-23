-- ========================================================
-- EGG AREA TAGGER - MANUAL TAGGING V2
-- Walk to area, click button to tag eggs nearby
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🏷️ EGG AREA TAGGER V2")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    TagRadius = 30,  -- Tag eggs within 30 studs
    ESPEnabled = true,
    ShowDistance = true,
    TextSize = 14,
}

-- ========================================================
-- DATA STORAGE
-- ========================================================

local eggTags = {}  -- [eggModel] = {area = "Volcano", number = 1}
local areaCounts = {
    FOREST = 0,
    LAKE = 0,
    DESERT = 0,
    JUNGLE = 0,
    SNOW = 0,
    VOLCANO = 0,
    ["ABYSS OCEAN"] = 0,
    PREHISTORIC = 0,
    COSMIC = 0,
}
local espCache = {}

-- ========================================================
-- AREA COLORS
-- ========================================================

local areaColors = {
    FOREST = Color3.fromRGB(34, 139, 34),        -- Green
    LAKE = Color3.fromRGB(30, 144, 255),         -- Blue
    DESERT = Color3.fromRGB(237, 201, 175),      -- Tan/Beige
    JUNGLE = Color3.fromRGB(0, 128, 0),          -- Dark Green
    SNOW = Color3.fromRGB(135, 206, 250),        -- Light Blue
    VOLCANO = Color3.fromRGB(255, 69, 0),        -- Orange Red
    ["ABYSS OCEAN"] = Color3.fromRGB(0, 0, 139), -- Dark Blue
    PREHISTORIC = Color3.fromRGB(240, 248, 255), -- Alice Blue/White
    COSMIC = Color3.fromRGB(138, 43, 226),       -- Purple
}

-- ========================================================
-- ESP FUNCTIONS
-- ========================================================

local function createESP(eggModel, area, number)
    local primaryPart = eggModel.PrimaryPart or 
                        eggModel:FindFirstChild("Hitbox") or 
                        eggModel:FindFirstChild("HitBox") or 
                        eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return nil end
    
    local displayText = "Egg #" .. number .. " [" .. area .. "]"
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggAreaTag"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 220, 0, 50)
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
    eggLabel.TextColor3 = areaColors[area] or Color3.fromRGB(255, 255, 255)
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
    
    espData.billboard.Enabled = CONFIG.ESPEnabled
    
    if CONFIG.ESPEnabled and CONFIG.ShowDistance then
        espData.distanceLabel.Text = math.floor(distance) .. " studs"
    else
        espData.distanceLabel.Text = ""
    end
    
    return true
end

-- ========================================================
-- TAG FUNCTIONS
-- ========================================================

local function tagNearbyEggs(areaName)
    local character = LocalPlayer.Character
    if not character then 
        warn("No character found!")
        return 0
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        warn("No HumanoidRootPart found!")
        return 0
    end
    
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not areaEggs then 
        warn("AreaEggSlotsClient not found!")
        return 0
    end
    
    local tagged = 0
    
    for _, child in pairs(areaEggs:GetChildren()) do
        if child:IsA("Model") then
            local primaryPart = child.PrimaryPart or 
                              child:FindFirstChild("Hitbox") or 
                              child:FindFirstChild("HitBox") or 
                              child:FindFirstChildWhichIsA("BasePart")
            
            if primaryPart then
                local distance = (hrp.Position - primaryPart.Position).Magnitude
                
                -- Only tag if within radius and not already tagged
                if distance <= CONFIG.TagRadius and not eggTags[child] then
                    areaCounts[areaName] = areaCounts[areaName] + 1
                    
                    eggTags[child] = {
                        area = areaName,
                        number = areaCounts[areaName]
                    }
                    
                    -- Remove old ESP if exists
                    if espCache[child] and espCache[child].billboard then
                        espCache[child].billboard:Destroy()
                    end
                    
                    -- Create new ESP
                    local esp = createESP(child, areaName, areaCounts[areaName])
                    if esp then
                        espCache[child] = esp
                        tagged = tagged + 1
                    end
                end
            end
        end
    end
    
    print("✅ Tagged " .. tagged .. " eggs as [" .. areaName .. "]")
    return tagged
end

local function clearAllTags()
    for eggModel, espData in pairs(espCache) do
        if espData.billboard then
            espData.billboard:Destroy()
        end
    end
    
    eggTags = {}
    espCache = {}
    
    for area, _ in pairs(areaCounts) do
        areaCounts[area] = 0
    end
    
    print("🗑️ All tags cleared!")
end

local function exportTags()
    local totalTagged = 0
    for area, count in pairs(areaCounts) do
        totalTagged = totalTagged + count
    end
    
    local output = "-- EGG AREA TAGS EXPORT\n"
    output = output .. "-- Total eggs tagged: " .. totalTagged .. "\n\n"
    
    for area, count in pairs(areaCounts) do
        if count > 0 then
            output = output .. area .. ": " .. count .. " eggs\n"
        end
    end
    
    output = output .. "\n-- Position data:\n"
    output = output .. "local eggAreas = {\n"
    
    for eggModel, data in pairs(eggTags) do
        local primaryPart = eggModel.PrimaryPart or 
                          eggModel:FindFirstChild("Hitbox") or 
                          eggModel:FindFirstChild("HitBox") or 
                          eggModel:FindFirstChildWhichIsA("BasePart")
        
        if primaryPart then
            local pos = primaryPart.Position
            output = output .. string.format('    {area = "%s", pos = Vector3.new(%.1f, %.1f, %.1f)},\n', 
                data.area, pos.X, pos.Y, pos.Z)
        end
    end
    
    output = output .. "}\n"
    
    setclipboard(output)
    print("📋 Area data copied to clipboard!")
end

-- ========================================================
-- GUI
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggAreaTaggerGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 560)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 150, 255)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🏷️ Egg Area Tagger"
titleLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Instructions
local instructLabel = Instance.new("TextLabel")
instructLabel.Size = UDim2.new(1, -20, 0, 40)
instructLabel.Position = UDim2.new(0, 10, 0, 55)
instructLabel.BackgroundTransparency = 1
instructLabel.Text = "Walk to area, then click button below\nto tag eggs within " .. CONFIG.TagRadius .. " studs"
instructLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
instructLabel.TextSize = 11
instructLabel.Font = Enum.Font.SourceSans
instructLabel.TextXAlignment = Enum.TextXAlignment.Left
instructLabel.TextYAlignment = Enum.TextYAlignment.Top
instructLabel.TextWrapped = true
instructLabel.Parent = mainFrame

-- Area stats
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -20, 0, 120)
statsLabel.Position = UDim2.new(0, 10, 0, 100)
statsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statsLabel.BorderSizePixel = 0
statsLabel.Text = "No eggs tagged yet"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.SourceSans
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.TextWrapped = true
statsLabel.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsLabel

local statsPadding = Instance.new("UIPadding")
statsPadding.PaddingLeft = UDim.new(0, 10)
statsPadding.PaddingTop = UDim.new(0, 10)
statsPadding.PaddingRight = UDim.new(0, 10)
statsPadding.PaddingBottom = UDim.new(0, 10)
statsPadding.Parent = statsLabel

-- Area buttons container
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Size = UDim2.new(1, -20, 0, 280)
buttonsFrame.Position = UDim2.new(0, 10, 0, 230)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

-- Create area buttons (9 areas, 3 columns x 3 rows)
local areas = {
    "FOREST", "LAKE", "DESERT",
    "JUNGLE", "SNOW", "VOLCANO",
    "ABYSS OCEAN", "PREHISTORIC", "COSMIC"
}
local buttonWidth = 0.32  -- 32% width for 3 columns
local buttonHeight = 35
local buttonSpacing = 5

for i, area in ipairs(areas) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(buttonWidth, -3, 0, buttonHeight)
    
    -- Three columns layout
    local col = (i - 1) % 3
    local row = math.floor((i - 1) / 3)
    btn.Position = UDim2.new(col * 0.34, 0, 0, row * (buttonHeight + buttonSpacing))
    
    btn.BackgroundColor3 = areaColors[area]
    btn.Text = area
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.SourceSansBold
    btn.TextWrapped = true
    btn.Parent = buttonsFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local count = tagNearbyEggs(area)
        
        -- Visual feedback
        local originalColor = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(0.1)
        btn.BackgroundColor3 = originalColor
    end)
end

-- Clear button
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, -20, 0, 40)
clearBtn.Position = UDim2.new(0, 10, 0, 465)
clearBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
clearBtn.Text = "🗑️ Clear All Tags"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 14
clearBtn.Font = Enum.Font.SourceSansBold
clearBtn.Parent = mainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 10)
clearCorner.Parent = clearBtn

clearBtn.MouseButton1Click:Connect(function()
    clearAllTags()
end)

-- Export button
local exportBtn = Instance.new("TextButton")
exportBtn.Size = UDim2.new(0.48, 0, 0, 35)
exportBtn.Position = UDim2.new(0, 10, 0, 515)
exportBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
exportBtn.Text = "📋 Copy Data"
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.TextSize = 12
exportBtn.Font = Enum.Font.SourceSansBold
exportBtn.Parent = mainFrame

local exportCorner = Instance.new("UICorner")
exportCorner.CornerRadius = UDim.new(0, 8)
exportCorner.Parent = exportBtn

exportBtn.MouseButton1Click:Connect(function()
    exportTags()
end)

-- ESP Toggle
local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0.48, 0, 0, 35)
espToggle.Position = UDim2.new(0.52, 0, 0, 515)
espToggle.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
espToggle.Text = "👁️ ESP: ON"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.TextSize = 12
espToggle.Font = Enum.Font.SourceSansBold
espToggle.Parent = mainFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = espToggle

espToggle.MouseButton1Click:Connect(function()
    CONFIG.ESPEnabled = not CONFIG.ESPEnabled
    espToggle.Text = CONFIG.ESPEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
end)

-- Update stats display
task.spawn(function()
    while screenGui.Parent do
        task.wait(1)
        
        local totalTagged = 0
        local statsText = ""
        
        for area, count in pairs(areaCounts) do
            if count > 0 then
                totalTagged = totalTagged + count
                if statsText ~= "" then statsText = statsText .. "\n" end
                statsText = statsText .. area .. ": " .. count
            end
        end
        
        if statsText == "" then
            statsLabel.Text = "No eggs tagged yet\n\nWalk to an area and click\nthe button to tag nearby eggs!"
        else
            statsLabel.Text = "Total: " .. totalTagged .. " eggs\n\n" .. statsText
        end
    end
end)

-- Update ESPs
RunService.RenderStepped:Connect(function()
    for eggModel, espData in pairs(espCache) do
        if not updateESP(espData) then
            espCache[eggModel] = nil
        end
    end
end)

-- Drag functionality
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = mainFrame.Position
        
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
        mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

print("========================================")
print("✅ EGG AREA TAGGER V2 LOADED!")
print("Areas: FOREST, LAKE, DESERT, JUNGLE, SNOW,")
print("       VOLCANO, ABYSS OCEAN, PREHISTORIC, COSMIC")
print("\nInstructions:")
print("1. Walk to an area")
print("2. Click the area button to tag nearby eggs")
print("3. Repeat for all areas")
print("4. Click 'Copy Data' to export positions")
print("========================================")
