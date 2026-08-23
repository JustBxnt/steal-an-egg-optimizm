-- ========================================================
-- EGG AREA TAGGER - FIXED VERSION
-- Draggable GUI with working minimize
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

print("🏷️ EGG AREA TAGGER - FIXED")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    TagRadius = 30,
    ESPEnabled = true,
    ShowDistance = true,
    TextSize = 14,
}

-- ========================================================
-- DATA STORAGE
-- ========================================================

local eggTags = {}
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
-- ESP FUNCTIONS
-- ========================================================

local function createESP(eggModel, area, number)
    local primaryPart = eggModel.PrimaryPart or 
                        eggModel:FindFirstChild("Hitbox") or 
                        eggModel:FindFirstChild("HitBox") or 
                        eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return nil end
    
    local displayText = "Egg #" .. number .. " [" .. area .. "]"
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggAreaTag"
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
    eggLabel.TextColor3 = areaColors[area] or Color3.fromRGB(255, 255, 255)
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
    if not character then return 0 end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not areaEggs then return 0 end
    
    local tagged = 0
    
    for _, child in pairs(areaEggs:GetChildren()) do
        if child:IsA("Model") then
            local primaryPart = child.PrimaryPart or 
                              child:FindFirstChild("Hitbox") or 
                              child:FindFirstChild("HitBox") or 
                              child:FindFirstChildWhichIsA("BasePart")
            
            if primaryPart then
                local distance = (hrp.Position - primaryPart.Position).Magnitude
                
                if distance <= CONFIG.TagRadius and not eggTags[child] then
                    areaCounts[areaName] = areaCounts[areaName] + 1
                    
                    eggTags[child] = {
                        area = areaName,
                        number = areaCounts[areaName]
                    }
                    
                    if espCache[child] and espCache[child].billboard then
                        espCache[child].billboard:Destroy()
                    end
                    
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

local function exportCoordinates()
    local totalTagged = 0
    for area, count in pairs(areaCounts) do
        totalTagged = totalTagged + count
    end
    
    if totalTagged == 0 then
        warn("No eggs tagged yet!")
        return
    end
    
    local output = "-- EGG COORDINATES (Total: " .. totalTagged .. " eggs)\n"
    output = output .. "local eggPositions = {\n"
    
    for eggModel, data in pairs(eggTags) do
        local primaryPart = eggModel.PrimaryPart or 
                          eggModel:FindFirstChild("Hitbox") or 
                          eggModel:FindFirstChild("HitBox") or 
                          eggModel:FindFirstChildWhichIsA("BasePart")
        
        if primaryPart then
            local pos = primaryPart.Position
            output = output .. string.format('    {area = "%s", x = %.1f, y = %.1f, z = %.1f},\n', 
                data.area, pos.X, pos.Y, pos.Z)
        end
    end
    
    output = output .. "}\n"
    
    setclipboard(output)
    print("📋 Coordinates copied! (" .. totalTagged .. " eggs)")
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
mainFrame.Size = UDim2.new(0, 340, 0, 440)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true  -- ENABLE DRAGGABLE
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 150, 255)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- Title Bar (for dragging)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🏷️ Egg Area Tagger"
titleLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.Parent = titleBar

-- Content Frame (for minimize)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -45, 0, 8)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

local isMinimized = false
local originalSize = mainFrame.Size

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 340, 0, 50)
        minimizeBtn.Text = "+"
        contentFrame.Visible = false
    else
        mainFrame.Size = originalSize
        minimizeBtn.Text = "−"
        contentFrame.Visible = true
    end
end)

-- Stats Label
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -20, 0, 75)
statsLabel.Position = UDim2.new(0, 10, 0, 0)
statsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statsLabel.BorderSizePixel = 0
statsLabel.Text = "Walk to area (30 studs)\nThen click button below"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextSize = 10
statsLabel.Font = Enum.Font.SourceSans
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.TextWrapped = true
statsLabel.Parent = contentFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsLabel

local statsPadding = Instance.new("UIPadding")
statsPadding.PaddingLeft = UDim.new(0, 8)
statsPadding.PaddingTop = UDim.new(0, 8)
statsPadding.PaddingRight = UDim.new(0, 8)
statsPadding.PaddingBottom = UDim.new(0, 8)
statsPadding.Parent = statsLabel

-- Area Buttons
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Size = UDim2.new(1, -20, 0, 220)
buttonsFrame.Position = UDim2.new(0, 10, 0, 85)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = contentFrame

local areas = {
    "FOREST", "LAKE", "DESERT",
    "JUNGLE", "SNOW", "VOLCANO",
    "ABYSS OCEAN", "PREHISTORIC", "COSMIC"
}

for i, area in ipairs(areas) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.315, 0, 0, 30)
    
    local col = (i - 1) % 3
    local row = math.floor((i - 1) / 3)
    btn.Position = UDim2.new(col * 0.34, 0, 0, row * 35)
    
    btn.BackgroundColor3 = areaColors[area]
    btn.Text = area
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.SourceSansBold
    btn.TextWrapped = true
    btn.Parent = buttonsFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        tagNearbyEggs(area)
        local originalColor = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(0.1)
        btn.BackgroundColor3 = originalColor
    end)
end

-- Clear Button
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, -20, 0, 35)
clearBtn.Position = UDim2.new(0, 10, 0, 315)
clearBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
clearBtn.Text = "🗑️ Clear All"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 12
clearBtn.Font = Enum.Font.SourceSansBold
clearBtn.Parent = contentFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 8)
clearCorner.Parent = clearBtn

clearBtn.MouseButton1Click:Connect(function()
    clearAllTags()
end)

-- Copy Button
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.64, -5, 0, 30)
copyBtn.Position = UDim2.new(0, 10, 0, 355)
copyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
copyBtn.Text = "📋 Copy Coordinates"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextSize = 11
copyBtn.Font = Enum.Font.SourceSansBold
copyBtn.Parent = contentFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyBtn

copyBtn.MouseButton1Click:Connect(function()
    exportCoordinates()
    copyBtn.Text = "✅ Copied!"
    task.wait(1)
    copyBtn.Text = "📋 Copy Coordinates"
end)

-- ESP Toggle
local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0.36, -5, 0, 30)
espToggle.Position = UDim2.new(0.64, 5, 0, 355)
espToggle.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
espToggle.Text = "👁️ ON"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.TextSize = 11
espToggle.Font = Enum.Font.SourceSansBold
espToggle.Parent = contentFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espToggle

espToggle.MouseButton1Click:Connect(function()
    CONFIG.ESPEnabled = not CONFIG.ESPEnabled
    espToggle.Text = CONFIG.ESPEnabled and "👁️ ON" or "👁️ OFF"
    espToggle.BackgroundColor3 = CONFIG.ESPEnabled and Color3.fromRGB(52, 152, 219) or Color3.fromRGB(100, 100, 100)
end)

-- Update Stats
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
            statsLabel.Text = "Walk to area (30 studs)\nThen click button below"
        else
            statsLabel.Text = "Total: " .. totalTagged .. " eggs\n" .. statsText
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

print("========================================")
print("✅ EGG AREA TAGGER - FIXED VERSION")
print("- Drag anywhere on GUI to move")
print("- Click − to minimize")
print("- Tag radius: 30 studs")
print("========================================")
