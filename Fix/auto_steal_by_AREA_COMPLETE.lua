-- ========================================================
-- AUTO STEAL EGG - BY AREA (with ESP)
-- ESP shows all eggs + Auto steal from selected areas
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🥚 AUTO STEAL BY AREA + ESP")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    -- ESP Config
    ESPEnabled = true,
    MaxDistance = 5000,
    ShowDistance = true,
    TextSize = 14,
    MatchRadius = 50,  -- Increased to 50 studs for better matching
    
    -- Auto Steal Config
    StealEnabled = false,
    FlySpeed = 150,  -- Fly speed (studs per second)
    SearchRadius = 5000,  -- Increased for far areas like Cosmic
    TeleportOffset = Vector3.new(0, 5, 0),
    
    -- Guard Avoidance Config
    FlyHeight = 100,  -- Height to fly above ground (avoid guards)
    SafeZoneHeight = 10,  -- Height when descending to safe zone
    
    -- Area filters (select which areas to steal from)
    AreaFilters = {
        FOREST = false,
        LAKE = false,
        DESERT = false,
        JUNGLE = false,
        SNOW = false,
        VOLCANO = false,
        ["ABYSS OCEAN"] = false,
        PREHISTORIC = false,
        COSMIC = false,
    }
}

-- ========================================================
-- TAGGED EGG POSITIONS
-- ========================================================

local eggPositions = {
    -- One reference position per area (9 areas total)
    {area = "FOREST", x = 591.8, y = 68.1, z = -325.6},
    {area = "LAKE", x = 738.1, y = 68.0, z = -411.1},
    {area = "DESERT", x = 946.4, y = 69.4, z = -327.3},
    {area = "JUNGLE", x = 1194.4, y = 68.1, z = -412.1},
    {area = "SNOW", x = 1489.0, y = 69.3, z = -317.8},
    {area = "VOLCANO", x = 1884.5, y = 69.3, z = -400.6},
    {area = "ABYSS OCEAN", x = 2278.2, y = 68.7, z = -330.1},
    {area = "PREHISTORIC", x = 2818.9, y = 68.1, z = -401.0},
    {area = "COSMIC", x = 3397.5, y = 69.6, z = -322.7},
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
-- CHARACTER SETUP
-- ========================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local ORIGINAL_WALKSPEED = humanoid.WalkSpeed
local SAFE_ZONE_POSITION = hrp.Position

print("✅ Character loaded")
print("✅ Safe zone saved:", SAFE_ZONE_POSITION)

-- ========================================================
-- AREA DETECTION
-- ========================================================

local function getEggArea(eggPosition)
    local closestDist = math.huge
    local closestArea = nil
    
    for _, taggedPos in ipairs(eggPositions) do
        local tagPos = Vector3.new(taggedPos.x, taggedPos.y, taggedPos.z)
        local distance = (eggPosition - tagPos).Magnitude
        
        if distance < closestDist and distance <= CONFIG.MatchRadius then
            closestDist = distance
            closestArea = taggedPos.area
        end
    end
    
    return closestArea, closestDist
end

-- ========================================================
-- ESP SYSTEM
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
    
    local area, matchDist = getEggArea(primaryPart.Position)
    if not area then return nil end
    
    areaCounts[area] = (areaCounts[area] or 0) + 1
    local areaNumber = areaCounts[area]
    eggCounter = eggCounter + 1
    
    local displayText = "Egg #" .. areaNumber .. " [" .. area .. "]"
    
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
    
    espData.billboard.Enabled = CONFIG.ESPEnabled
    
    if CONFIG.ESPEnabled and CONFIG.ShowDistance then
        espData.distanceLabel.Text = math.floor(distance) .. " studs"
    else
        espData.distanceLabel.Text = ""
    end
    
    return true
end

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

-- ========================================================
-- AUTO STEAL FUNCTIONS
-- ========================================================

local TweenService = game:GetService("TweenService")

local function isAreaEnabled(area)
    return CONFIG.AreaFilters[area] == true
end

local function findNearestEggByArea()
    local nearestEgg = nil
    local nearestDist = math.huge
    local nearestArea = nil
    
    for eggModel, espData in pairs(espCache) do
        if eggModel.Parent and espData.primaryPart.Parent then
            local area = espData.area
            
            if isAreaEnabled(area) then
                local dist = (hrp.Position - espData.primaryPart.Position).Magnitude
                
                if dist < nearestDist and dist < CONFIG.SearchRadius then
                    nearestDist = dist
                    nearestEgg = eggModel
                    nearestArea = area
                end
            end
        end
    end
    
    return nearestEgg, nearestDist, nearestArea
end

local function flyToPosition(targetPosition, offset)
    offset = offset or CONFIG.TeleportOffset
    local finalPos = targetPosition + offset
    
    if not hrp or not hrp.Parent then return false end
    
    print("  🚀 Flying to target...")
    local totalDistance = (hrp.Position - finalPos).Magnitude
    print("     Distance:", math.floor(totalDistance), "studs")
    print("     Speed:", CONFIG.FlySpeed, "studs/s")
    
    -- Anti-cheat bypass: Split long distances into smaller chunks
    local maxChunkDistance = 500  -- Max 500 studs per tween to avoid detection
    local chunks = math.ceil(totalDistance / maxChunkDistance)
    
    if chunks > 1 then
        print("     Using", chunks, "chunks to avoid detection")
    end
    
    for i = 1, chunks do
        local startPos = hrp.Position
        local progress = i / chunks
        local chunkTarget = startPos:Lerp(finalPos, 1 / (chunks - i + 1))
        
        local chunkDistance = (startPos - chunkTarget).Magnitude
        local chunkTime = chunkDistance / CONFIG.FlySpeed
        
        -- Smooth easing to look more natural
        local tweenInfo = TweenInfo.new(
            chunkTime,
            Enum.EasingStyle.Sine,  -- Smoother easing
            Enum.EasingDirection.InOut
        )
        
        local tween = TweenService:Create(hrp, tweenInfo, {
            CFrame = CFrame.new(chunkTarget)
        })
        
        tween:Play()
        tween.Completed:Wait()
        
        -- Small delay between chunks (more natural)
        if i < chunks then
            task.wait(0.1)
        end
    end
    
    task.wait(0.2)
    
    print("  ✅ Arrived!")
    return true
end

local function fireNearestPrompt()
    local nearestPrompt = nil
    local nearestPromptDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local isEggRelated = parent.Name:lower():find("egg") or 
                                   obj.Name:lower():find("egg") or 
                                   obj.Name:lower():find("carry")
                
                if isEggRelated then
                    local dist = (hrp.Position - parent.Position).Magnitude
                    
                    if dist < nearestPromptDist then
                        nearestPromptDist = dist
                        nearestPrompt = obj
                    end
                end
            end
        end
    end
    
    if nearestPrompt then
        pcall(function()
            fireproximityprompt(nearestPrompt)
        end)
        return true
    end
    
    return false
end

local function checkIfCarrying()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then return true, tool.Name end
    
    tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then return true, tool.Name .. " (backpack)" end
    
    return false, nil
end

local function flyToSafeZone()
    print("\n🚀 FLYING back to safe zone...")
    
    local totalDistance = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
    print("  Distance:", math.floor(totalDistance), "studs")
    
    -- Anti-cheat bypass: Split into chunks
    local maxChunkDistance = 500
    local chunks = math.ceil(totalDistance / maxChunkDistance)
    
    for i = 1, chunks do
        local startPos = hrp.Position
        local chunkTarget = startPos:Lerp(SAFE_ZONE_POSITION, 1 / (chunks - i + 1))
        
        local chunkDistance = (startPos - chunkTarget).Magnitude
        local chunkTime = chunkDistance / CONFIG.FlySpeed
        
        local tweenInfo = TweenInfo.new(
            chunkTime,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )
        
        local tween = TweenService:Create(hrp, tweenInfo, {
            CFrame = CFrame.new(chunkTarget)
        })
        
        tween:Play()
        tween.Completed:Wait()
        
        if i < chunks then
            task.wait(0.1)
        end
    end
    
    task.wait(0.2)
    
    local finalDist = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
    
    if finalDist < 30 then
        print("  ✅ Returned to safe zone!")
        return true
    end
    
    return false
end

local function autoStealCycle()
    print("\n" .. string.rep("=", 60))
    print("🔄 AUTO-STEAL CYCLE (BY AREA + FLY)")
    print(string.rep("=", 60))
    
    -- Show enabled areas
    print("\n📋 Enabled areas:")
    for area, enabled in pairs(CONFIG.AreaFilters) do
        if enabled then
            print("  ✅", area)
        end
    end
    print()
    
    -- Step 1: Find egg from enabled areas
    print("[1] Searching for eggs in enabled areas...")
    local egg, distance, area = findNearestEggByArea()
    
    if not egg then
        print("❌ No eggs found in enabled areas")
        return false
    end
    
    print("✅ Found egg in:", area)
    print("   Distance:", math.floor(distance), "studs")
    
    -- Step 2: Fly to egg
    print("\n[2] Flying to egg...")
    local eggPos = egg.PrimaryPart.Position or egg:FindFirstChildWhichIsA("BasePart").Position
    
    if not flyToPosition(eggPos) then
        print("❌ Fly failed")
        return false
    end
    
    -- Step 3: Fire prompt
    print("\n[3] Firing prompt...")
    local success = fireNearestPrompt()
    
    if not success then
        print("❌ Prompt failed")
        return false
    end
    
    -- Step 4: Check carrying
    print("\n[4] Checking if egg picked up...")
    
    local carrying, eggName = false, nil
    
    for i = 1, 40 do
        carrying, eggName = checkIfCarrying()
        
        if carrying then
            local timeTaken = i * 0.05
            print("✅ Egg detected after", string.format("%.2f", timeTaken), "seconds!")
            break
        end
        
        task.wait(0.05)
    end
    
    if not carrying then
        print("❌ No egg detected")
        return false
    end
    
    print("✅✅ SUCCESS! Carrying:", eggName)
    
    -- Step 5: Fly back
    print("\n[5] Flying back to safe zone...")
    local returned = flyToSafeZone()
    
    if returned then
        print("✅ Returned!")
    end
    
    task.wait(0.5)
    local stillCarrying = checkIfCarrying()
    if stillCarrying then
        print("✅ Still carrying egg")
    end
    
    print("\n" .. string.rep("=", 60))
    print("✅✅ CYCLE COMPLETED!")
    print(string.rep("=", 60) .. "\n")
    
    return carrying
end

-- ========================================================
-- MAIN LOOP
-- ========================================================

scanEggs()
print("✅ Initial scan: " .. eggCounter .. " eggs")

RunService.RenderStepped:Connect(function()
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

-- ========================================================
-- GUI
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoStealAreaGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 550)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
titleLabel.Text = "🥚 AUTO STEAL BY AREA + ESP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

local titleCover = Instance.new("Frame")
titleCover.Size = UDim2.new(1, 0, 0, 10)
titleCover.Position = UDim2.new(0, 0, 1, -10)
titleCover.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
titleCover.BorderSizePixel = 0
titleCover.Parent = titleLabel

-- ESP Status
local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(1, -20, 0, 30)
espLabel.Position = UDim2.new(0, 10, 0, 55)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP: " .. eggCounter .. " eggs detected"
espLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
espLabel.TextSize = 12
espLabel.Font = Enum.Font.SourceSans
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Parent = mainFrame

-- Auto Steal Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 40)
statusLabel.Position = UDim2.new(0, 10, 0, 85)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Auto Steal: Ready\nNo areas selected\nFly Speed: 200 studs/s"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Code
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Area Selection Label
local areaLabel = Instance.new("TextLabel")
areaLabel.Size = UDim2.new(1, -20, 0, 25)
areaLabel.Position = UDim2.new(0, 10, 0, 130)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "🎯 Select Areas to Steal From:"
areaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
areaLabel.TextSize = 14
areaLabel.Font = Enum.Font.SourceSansBold
areaLabel.TextXAlignment = Enum.TextXAlignment.Left
areaLabel.Parent = mainFrame

-- Area Checkboxes
local areas = {"FOREST", "LAKE", "DESERT", "JUNGLE", "SNOW", "VOLCANO", "ABYSS OCEAN", "PREHISTORIC", "COSMIC"}
local checkboxes = {}

for i, area in ipairs(areas) do
    local yPos = 160 + (i - 1) * 32
    
    local checkFrame = Instance.new("Frame")
    checkFrame.Size = UDim2.new(1, -20, 0, 28)
    checkFrame.Position = UDim2.new(0, 10, 0, yPos)
    checkFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    checkFrame.BorderSizePixel = 0
    checkFrame.Parent = mainFrame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 6)
    checkCorner.Parent = checkFrame
    
    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 28, 0, 28)
    checkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    checkBtn.Text = ""
    checkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkBtn.TextSize = 16
    checkBtn.Font = Enum.Font.SourceSansBold
    checkBtn.Parent = checkFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = checkBtn
    
    local checkLabel = Instance.new("TextLabel")
    checkLabel.Size = UDim2.new(1, -35, 1, 0)
    checkLabel.Position = UDim2.new(0, 35, 0, 0)
    checkLabel.BackgroundTransparency = 1
    checkLabel.Text = area
    checkLabel.TextColor3 = areaColors[area]
    checkLabel.TextSize = 12
    checkLabel.Font = Enum.Font.SourceSansBold
    checkLabel.TextXAlignment = Enum.TextXAlignment.Left
    checkLabel.Parent = checkFrame
    
    checkboxes[area] = {btn = checkBtn, label = checkLabel}
    
    checkBtn.MouseButton1Click:Connect(function()
        CONFIG.AreaFilters[area] = not CONFIG.AreaFilters[area]
        
        if CONFIG.AreaFilters[area] then
            checkBtn.Text = "✓"
            checkBtn.BackgroundColor3 = areaColors[area]
        else
            checkBtn.Text = ""
            checkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
        
        local enabled = {}
        for a, e in pairs(CONFIG.AreaFilters) do
            if e then table.insert(enabled, a) end
        end
        
        if #enabled == 0 then
            statusLabel.Text = "Auto Steal: Ready\n⚠️ No areas selected!\nFly Speed: " .. CONFIG.FlySpeed .. " studs/s"
        else
            statusLabel.Text = "Auto Steal: Ready\nAreas: " .. table.concat(enabled, ", ") .. "\nFly Speed: " .. CONFIG.FlySpeed .. " studs/s"
        end
    end)
end

-- Fly Speed Control
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, -15, 0, 35)
speedLabel.Position = UDim2.new(0, 10, 0, 450)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "� Fly Speed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.TextYAlignment = Enum.TextYAlignment.Center
speedLabel.Parent = mainFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.5, -15, 0, 35)
speedInput.Position = UDim2.new(0.5, 5, 0, 450)
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedInput.BorderSizePixel = 0
speedInput.Text = "200"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 14
speedInput.Font = Enum.Font.SourceSansBold
speedInput.PlaceholderText = "50-500"
speedInput.ClearTextOnFocus = false
speedInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = speedInput

speedInput.FocusLost:Connect(function()
    local value = tonumber(speedInput.Text)
    if value then
        value = math.clamp(value, 50, 500)
        CONFIG.FlySpeed = value
        speedInput.Text = tostring(value)
    else
        speedInput.Text = tostring(CONFIG.FlySpeed)
    end
end)

-- ESP Toggle
local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(1, -20, 0, 30)
espToggle.Position = UDim2.new(0, 10, 0, 495)
espToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
espToggle.Text = "👁️ ESP: ON"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.TextSize = 12
espToggle.Font = Enum.Font.SourceSansBold
espToggle.Parent = mainFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espToggle

espToggle.MouseButton1Click:Connect(function()
    CONFIG.ESPEnabled = not CONFIG.ESPEnabled
    if CONFIG.ESPEnabled then
        espToggle.Text = "👁️ ESP: ON"
        espToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        espToggle.Text = "👁️ ESP: OFF"
        espToggle.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- Steal Once Button
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(0.48, 0, 0, 30)
stealBtn.Position = UDim2.new(0, 10, 1, -35)
stealBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
stealBtn.Text = "🥚 STEAL ONCE"
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.TextSize = 12
stealBtn.Font = Enum.Font.SourceSansBold
stealBtn.Parent = mainFrame

local stealCorner = Instance.new("UICorner")
stealCorner.CornerRadius = UDim.new(0, 6)
stealCorner.Parent = stealBtn

stealBtn.MouseButton1Click:Connect(function()
    stealBtn.Text = "⏳ Working..."
    
    local success = autoStealCycle()
    
    if success then
        stealBtn.Text = "✅ Success!"
    else
        stealBtn.Text = "❌ Failed"
    end
    
    task.wait(2)
    stealBtn.Text = "🥚 STEAL ONCE"
end)

-- Auto Loop Button
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.48, 0, 0, 30)
autoBtn.Position = UDim2.new(0.52, 0, 1, -35)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoBtn.Text = "🔄 AUTO: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 12
autoBtn.Font = Enum.Font.SourceSansBold
autoBtn.Parent = mainFrame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 6)
autoCorner.Parent = autoBtn

autoBtn.MouseButton1Click:Connect(function()
    CONFIG.StealEnabled = not CONFIG.StealEnabled
    
    if CONFIG.StealEnabled then
        autoBtn.Text = "🔄 AUTO: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
    else
        autoBtn.Text = "🔄 AUTO: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- Update ESP Label
task.spawn(function()
    while screenGui.Parent do
        task.wait(2)
        espLabel.Text = "ESP: " .. eggCounter .. " eggs detected"
    end
end)

-- Auto Loop
task.spawn(function()
    while true do
        if CONFIG.StealEnabled then
            local success = autoStealCycle()
            
            if success then
                CONFIG.StealEnabled = false
                autoBtn.Text = "🔄 AUTO: OFF"
                autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                print("\n🎉 EGG STOLEN! Loop stopped")
            else
                task.wait(2)
            end
        else
            task.wait(1)
        end
    end
end)

print("========================================")
print("✅ AUTO STEAL BY AREA + ESP LOADED!")
print("🎮 ESP shows all eggs with area names")
print("🎮 Select areas to steal from")
print("🚀 Fly Speed: 200 studs/s (adjustable)")
print("🎮 Click '🥚 STEAL ONCE' to test")
print("🎮 Click '🔄 AUTO' for auto farm")
print("========================================")
