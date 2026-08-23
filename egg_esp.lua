-- ========================================================
-- EGG ESP - Show all eggs with name and rarity
-- Format: "EggName [Rarity]"
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🔍 EGG ESP - LOADING...")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    Enabled = true,
    MaxDistance = 2000,  -- ESP render distance
    ShowDistance = true,
    ShowRarity = true,
    TextSize = 14,
    
    -- Rarity Colors
    RarityColors = {
        Mythic = Color3.fromRGB(231, 76, 60),
        Legendary = Color3.fromRGB(241, 196, 15),
        Epic = Color3.fromRGB(155, 89, 182),
        Rare = Color3.fromRGB(52, 152, 219),
        Uncommon = Color3.fromRGB(46, 204, 113),
        Common = Color3.fromRGB(189, 195, 199),
        Unknown = Color3.fromRGB(150, 150, 150),
    }
}

-- ========================================================
-- RARITY DETECTION
-- ========================================================

local function getEggRarity(eggModel)
    local foundRarity = nil
    local debugInfo = {}
    
    -- Method 1: Check BillboardGui text
    for _, descendant in pairs(eggModel:GetDescendants()) do
        if descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
            table.insert(debugInfo, "Found GUI: " .. descendant:GetFullName())
            for _, child in pairs(descendant:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text
                    table.insert(debugInfo, "  Text: " .. text)
                    
                    -- Check for [Rarity] pattern
                    local rarityMatch = text:match("%[([%w]+)%]")
                    if rarityMatch then
                        foundRarity = rarityMatch
                        table.insert(debugInfo, "  ✅ Found rarity in brackets: " .. rarityMatch)
                    end
                    
                    -- Check for plain rarity text
                    local lowerText = text:lower()
                    if not foundRarity then
                        if lowerText:find("mythic") then foundRarity = "Mythic" end
                        if lowerText:find("legendary") then foundRarity = "Legendary" end
                        if lowerText:find("epic") then foundRarity = "Epic" end
                        if lowerText:find("rare") and not lowerText:find("ultra") then foundRarity = "Rare" end
                        if lowerText:find("uncommon") then foundRarity = "Uncommon" end
                        if lowerText:find("common") then foundRarity = "Common" end
                        
                        if foundRarity then
                            table.insert(debugInfo, "  ✅ Found rarity in text: " .. foundRarity)
                        end
                    end
                end
            end
        end
    end
    
    -- Method 2: Check for Rarity StringValue/IntValue
    if not foundRarity then
        for _, descendant in pairs(eggModel:GetDescendants()) do
            if descendant.Name:lower():find("rarity") then
                table.insert(debugInfo, "Found object with 'rarity': " .. descendant:GetFullName() .. " (" .. descendant.ClassName .. ")")
                if descendant:IsA("StringValue") or descendant:IsA("IntValue") then
                    foundRarity = tostring(descendant.Value)
                    table.insert(debugInfo, "  ✅ Rarity value: " .. foundRarity)
                end
            end
        end
    end
    
    -- Method 3: Check Configuration folder
    if not foundRarity then
        local config = eggModel:FindFirstChild("Configuration")
        if config then
            table.insert(debugInfo, "Found Configuration folder")
            for _, child in pairs(config:GetChildren()) do
                table.insert(debugInfo, "  Child: " .. child.Name .. " (" .. child.ClassName .. ")")
                if child.Name:lower():find("rarity") then
                    if child:IsA("StringValue") or child:IsA("IntValue") then
                        foundRarity = tostring(child.Value)
                        table.insert(debugInfo, "  ✅ Rarity value: " .. foundRarity)
                    end
                end
            end
        end
    end
    
    -- Method 4: Check all StringValues/IntValues
    if not foundRarity then
        for _, descendant in pairs(eggModel:GetDescendants()) do
            if descendant:IsA("StringValue") or descendant:IsA("IntValue") then
                local value = tostring(descendant.Value):lower()
                if value:find("mythic") or value:find("legendary") or value:find("epic") or 
                   value:find("rare") or value:find("uncommon") or value:find("common") then
                    foundRarity = tostring(descendant.Value)
                    table.insert(debugInfo, "Found rarity in " .. descendant:GetFullName() .. ": " .. foundRarity)
                end
            end
        end
    end
    
    -- Method 5: Check egg name patterns
    if not foundRarity then
        local eggName = eggModel.Name:lower()
        if eggName:find("mythic") then foundRarity = "Mythic" end
        if eggName:find("legendary") then foundRarity = "Legendary" end
        if eggName:find("epic") then foundRarity = "Epic" end
        if eggName:find("rare") then foundRarity = "Rare" end
        if eggName:find("uncommon") then foundRarity = "Uncommon" end
        if eggName:find("common") then foundRarity = "Common" end
        
        if foundRarity then
            table.insert(debugInfo, "✅ Found rarity in name: " .. foundRarity)
        end
    end
    
    -- Debug: Print first egg structure
    if not foundRarity and not eggModel:GetAttribute("DebugPrinted") then
        eggModel:SetAttribute("DebugPrinted", true)
        print("\n=== EGG STRUCTURE DEBUG ===")
        print("Egg:", eggModel:GetFullName())
        for _, line in ipairs(debugInfo) do
            print(line)
        end
        print("=== END DEBUG ===\n")
    end
    
    return foundRarity or "Unknown"
end

local function getEggDisplayName(eggModel)
    -- Try to get clean egg name (remove IDs and prefixes)
    local name = eggModel.Name
    
    -- If name is just a long hex ID, show simplified version
    if name:match("^[0-9a-f]+$") and #name > 20 then
        -- Check for any child with a descriptive name
        for _, child in pairs(eggModel:GetChildren()) do
            if child:IsA("Model") or child:IsA("Part") then
                local childName = child.Name
                -- Skip generic names
                if not childName:match("^[0-9a-f]+$") and 
                   childName ~= "Hitbox" and 
                   childName ~= "HitBox" and
                   childName ~= "Part_Union" and
                   #childName < 20 then
                    return childName
                end
            end
        end
        
        -- Return shortened ID
        return "Egg_" .. name:sub(1, 8)
    end
    
    -- Remove common prefixes
    name = name:gsub("FirstAreaEgg_", "")
    name = name:gsub("AreaEgg_", "")
    
    -- Remove ID patterns
    name = name:gsub("_%d+_%d+_", " ")
    name = name:gsub("_Slot_%d+", "")
    name = name:gsub(":Slot_%d+", "")
    
    -- Extract area if present (like "Forest", "Lake")
    local area = name:match("_([%w]+):") or name:match("_([%w]+)$")
    if area and #area < 15 and not area:match("^%d+$") then
        return area .. " Egg"
    end
    
    name = name:gsub("_", " ")
    
    -- Clean up
    name = name:match("^%s*(.-)%s*$") -- Trim whitespace
    
    -- If name is still too long, simplify
    if #name > 20 then
        return "Egg " .. eggModel:GetFullName():match("([^_]+)$") or "Egg"
    end
    
    return name
end

-- ========================================================
-- ESP CREATION
-- ========================================================

local espCache = {}

local function createESP(eggModel)
    local primaryPart = eggModel.PrimaryPart or eggModel:FindFirstChild("Hitbox") or eggModel:FindFirstChild("HitBox") or eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return nil end
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESP"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = primaryPart
    
    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    -- Egg Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = CONFIG.TextSize
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = frame
    
    -- Rarity Label
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Size = UDim2.new(1, 0, 0.5, 0)
    rarityLabel.Position = UDim2.new(0, 0, 0.5, 0)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.TextSize = CONFIG.TextSize
    rarityLabel.Font = Enum.Font.SourceSansBold
    rarityLabel.TextStrokeTransparency = 0.5
    rarityLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    rarityLabel.Parent = frame
    
    -- Distance Label
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.7, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextSize = CONFIG.TextSize - 2
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Parent = frame
    
    return {
        billboard = billboard,
        nameLabel = nameLabel,
        rarityLabel = rarityLabel,
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
    
    if CONFIG.Enabled then
        -- Get egg info
        local displayName = getEggDisplayName(espData.eggModel)
        local rarity = getEggRarity(espData.eggModel)
        
        -- Update labels
        espData.nameLabel.Text = displayName
        
        if CONFIG.ShowRarity then
            espData.rarityLabel.Text = "[" .. rarity .. "]"
            espData.rarityLabel.TextColor3 = CONFIG.RarityColors[rarity] or CONFIG.RarityColors.Unknown
        else
            espData.rarityLabel.Text = ""
        end
        
        if CONFIG.ShowDistance then
            espData.distanceLabel.Text = math.floor(distance) .. " studs"
        else
            espData.distanceLabel.Text = ""
        end
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

-- Update loop
local updateConnection = RunService.RenderStepped:Connect(function()
    -- Scan for new eggs
    scanEggs()
    
    -- Update existing ESP
    for eggModel, espData in pairs(espCache) do
        if not updateESP(espData) then
            -- Remove invalid ESP
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
screenGui.Name = "EggESPGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

-- Control Frame
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 300, 0, 200)
controlFrame.Position = UDim2.new(1, -320, 0, 20)
controlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
controlFrame.BorderSizePixel = 0
controlFrame.Active = true
controlFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = controlFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 80, 200)
frameStroke.Thickness = 2
frameStroke.Parent = controlFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 35)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔍 Egg ESP"
titleLabel.TextColor3 = Color3.fromRGB(150, 130, 230)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = controlFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 50)
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
distanceToggle.Size = UDim2.new(1, -20, 0, 35)
distanceToggle.Position = UDim2.new(0, 10, 0, 100)
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

-- Max Distance Slider
local distLabel = Instance.new("TextLabel")
distLabel.Size = UDim2.new(1, -20, 0, 20)
distLabel.Position = UDim2.new(0, 10, 0, 145)
distLabel.BackgroundTransparency = 1
distLabel.Text = "Max Distance: " .. CONFIG.MaxDistance
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 12
distLabel.Font = Enum.Font.SourceSans
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Parent = controlFrame

local distInput = Instance.new("TextBox")
distInput.Size = UDim2.new(1, -20, 0, 30)
distInput.Position = UDim2.new(0, 10, 0, 165)
distInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
distInput.Text = tostring(CONFIG.MaxDistance)
distInput.TextColor3 = Color3.fromRGB(255, 255, 255)
distInput.TextSize = 13
distInput.Font = Enum.Font.SourceSans
distInput.PlaceholderText = "500-5000"
distInput.Parent = controlFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = distInput

distInput.FocusLost:Connect(function()
    local newDist = tonumber(distInput.Text)
    if newDist and newDist >= 500 and newDist <= 5000 then
        CONFIG.MaxDistance = newDist
        distLabel.Text = "Max Distance: " .. CONFIG.MaxDistance
    else
        distInput.Text = tostring(CONFIG.MaxDistance)
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

-- Close on game leave
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)

print("========================================")
print("✅ EGG ESP LOADED!")
print("========================================")
print("Features:")
print("• Shows egg name and rarity")
print("• Distance display")
print("• Color-coded by rarity")
print("• Max distance: " .. CONFIG.MaxDistance .. " studs")
print("• Toggle ESP with GUI button")
print("========================================")
