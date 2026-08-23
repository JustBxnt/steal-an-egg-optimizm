-- ========================================================
-- AUTO STEAL EGG - WITH RARITY FILTER
-- Select which egg rarities to steal
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("🥚 AUTO STEAL EGG - RARITY FILTER VERSION")
print("Method: Filter by egg rarity")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    Enabled = false,
    WalkSpeed = 50,
    SearchRadius = 500,
    TeleportOffset = Vector3.new(0, 5, 0),
    
    -- Rarity filters (all enabled by default)
    RarityFilters = {
        Basic = true,
        Common = true,
        Uncommon = true,
        Rare = true,
        Epic = true,
        Legendary = true,
        Mythic = true,
        Exclusive = true,
        Exotic = true,
        Superior = true,
        Divine = true,
        Secret = true,
        Notification = true,
        Celestial = true,
        Rainbow = true,
        SuperRare = true,
        BrainrotCod = true,
        Eternal = true,
        Cosmic = true,
        Limited = true,
    }
}

-- Egg name to rarity mapping (common patterns)
local EGG_RARITIES = {
    -- Common patterns
    ["chicken"] = "Common",
    ["duck"] = "Common",
    ["basic"] = "Common",
    
    -- Uncommon patterns
    ["bear"] = "Uncommon",
    ["fox"] = "Uncommon",
    ["rabbit"] = "Uncommon",
    
    -- Rare patterns
    ["golden"] = "Rare",
    ["silver"] = "Rare",
    ["crystal"] = "Rare",
    
    -- Epic patterns
    ["dragon"] = "Epic",
    ["phoenix"] = "Epic",
    ["royal"] = "Epic",
    
    -- Legendary patterns
    ["legendary"] = "Legendary",
    ["ancient"] = "Legendary",
    ["mythical"] = "Legendary",
    
    -- Mythic patterns
    ["mythic"] = "Mythic",
    ["divine"] = "Mythic",
    ["celestial"] = "Mythic",
}

-- ========================================================
-- GET CHARACTER
-- ========================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local ORIGINAL_WALKSPEED = humanoid.WalkSpeed
local SAFE_ZONE_POSITION = hrp.Position

print("✅ Character loaded")
print("✅ Original WalkSpeed:", ORIGINAL_WALKSPEED)
print("✅ Safe zone saved:", SAFE_ZONE_POSITION)
print()

-- ========================================================
-- FUNCTIONS
-- ========================================================

local function detectEggRarity(eggName)
    local lowerName = eggName:lower()
    
    -- Check each pattern
    for pattern, rarity in pairs(EGG_RARITIES) do
        if lowerName:find(pattern) then
            return rarity
        end
    end
    
    -- Default to Common if no match
    return "Common"
end

local function isRarityEnabled(rarity)
    return CONFIG.RarityFilters[rarity] == true
end

local function findNearestEgg()
    local nearestEgg = nil
    local nearestDist = math.huge
    local nearestRarity = nil
    
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if areaEggs then
        for _, child in pairs(areaEggs:GetDescendants()) do
            if child:IsA("Model") and child.Name:lower():find("egg") then
                local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local dist = (hrp.Position - primaryPart.Position).Magnitude
                    
                    if dist < nearestDist and dist < CONFIG.SearchRadius then
                        -- Detect rarity
                        local rarity = detectEggRarity(child.Name)
                        
                        -- Check if this rarity is enabled
                        if isRarityEnabled(rarity) then
                            nearestDist = dist
                            nearestEgg = child
                            nearestRarity = rarity
                        else
                            print("  Skipping", child.Name, "(", rarity, "- disabled)")
                        end
                    end
                end
            end
        end
    end
    
    return nearestEgg, nearestDist, nearestRarity
end

local function teleportTo(position, offset)
    offset = offset or CONFIG.TeleportOffset
    if hrp and hrp.Parent then
        hrp.CFrame = CFrame.new(position + offset)
        task.wait(0.5)
        return true
    end
    return false
end

local function fireNearestPrompt()
    print("🔥 Finding and firing NEAREST egg prompt...")
    
    local nearestPrompt = nil
    local nearestPromptDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent then
                local isEggRelated = false
                
                if parent.Name:lower():find("egg") then
                    isEggRelated = true
                elseif obj.Name:lower():find("egg") then
                    isEggRelated = true
                elseif obj.Name:lower():find("carry") then
                    isEggRelated = true
                end
                
                if isEggRelated and parent:IsA("BasePart") then
                    local dist = (hrp.Position - parent.Position).Magnitude
                    
                    if dist < nearestPromptDist then
                        nearestPromptDist = dist
                        nearestPrompt = {
                            prompt = obj,
                            parent = parent,
                            distance = dist
                        }
                    end
                end
            end
        end
    end
    
    if nearestPrompt then
        print("  ✅ Found NEAREST prompt")
        print("     Distance:", math.floor(nearestPrompt.distance), "studs")
        
        pcall(function()
            fireproximityprompt(nearestPrompt.prompt)
        end)
        
        print("  ✅ Prompt fired!")
        return true
    else
        print("  ❌ No prompts found")
        return false
    end
end

local function checkIfCarrying()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        return true, tool.Name
    end
    
    tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        return true, tool.Name .. " (backpack)"
    end
    
    return false, nil
end

local function walkToSafeZone()
    print("\n🚶 WALKING back to safe zone...")
    
    local distance = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
    print("  Distance:", math.floor(distance), "studs")
    print("  WalkSpeed:", CONFIG.WalkSpeed)
    
    humanoid.WalkSpeed = CONFIG.WalkSpeed
    humanoid:MoveTo(SAFE_ZONE_POSITION)
    
    local startTime = tick()
    local lastDist = distance
    local timeout = 30
    
    while (tick() - startTime) < timeout do
        task.wait(0.5)
        
        local currentDist = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
        
        if currentDist < 20 then
            print("  ✅ Reached safe zone!")
            break
        end
        
        if math.abs(currentDist - lastDist) < 1 then
            humanoid:MoveTo(SAFE_ZONE_POSITION)
        end
        
        lastDist = currentDist
    end
    
    humanoid.WalkSpeed = ORIGINAL_WALKSPEED
    
    local finalDist = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
    return finalDist < 30
end

-- ========================================================
-- MAIN CYCLE
-- ========================================================

local function autoStealCycle()
    print("\n" .. string.rep("=", 60))
    print("🔄 AUTO-STEAL CYCLE (RARITY FILTER)")
    print(string.rep("=", 60))
    
    -- Show enabled rarities
    print("\n📋 Enabled rarities:")
    for rarity, enabled in pairs(CONFIG.RarityFilters) do
        if enabled then
            print("  ✅", rarity)
        end
    end
    print()
    
    -- Step 1: Find egg with rarity filter
    print("[1] Searching for eggs (with rarity filter)...")
    local egg, distance, rarity = findNearestEgg()
    
    if not egg then
        print("❌ No eggs found matching rarity filters")
        return false
    end
    
    print("✅ Found egg:", egg.Name)
    print("   Rarity:", rarity)
    print("   Distance:", math.floor(distance), "studs")
    
    -- Step 2: Teleport
    print("\n[2] Teleporting to egg...")
    local eggPos = egg.PrimaryPart.Position
    
    if not teleportTo(eggPos) then
        print("❌ Teleport failed")
        return false
    end
    
    print("✅ Teleported")
    task.wait(0.5)
    
    -- Step 3: Fire prompt
    print("\n[3] Firing prompt...")
    local success = fireNearestPrompt()
    
    if not success then
        print("❌ Prompt failed")
        return false
    end
    
    -- Step 4: INSTANT CHECK
    print("\n[4] INSTANT check for egg...")
    
    local maxAttempts = 40
    local carrying, eggName = false, nil
    
    for i = 1, maxAttempts do
        carrying, eggName = checkIfCarrying()
        
        if carrying then
            local timeTaken = (i - 1) * 0.05
            print("✅ Egg detected after", string.format("%.2f", timeTaken), "seconds!")
            break
        else
            task.wait(0.05)
        end
    end
    
    print("\n[5] Status check...")
    
    if not carrying then
        print("❌ No egg detected")
        return false
    end
    
    print("✅✅ SUCCESS! Carrying:", eggName)
    print("⚡ Immediately returning...")
    
    -- Step 6: Walk back
    print("\n[6] Returning to safe zone...")
    local returned = walkToSafeZone()
    
    if returned then
        print("✅ Returned!")
    end
    
    task.wait(0.5)
    local stillCarrying, stillEggName = checkIfCarrying()
    if stillCarrying then
        print("✅ Still carrying:", stillEggName)
    end
    
    print("\n" .. string.rep("=", 60))
    print("✅✅ CYCLE COMPLETED!")
    print(string.rep("=", 60) .. "\n")
    
    return carrying
end

-- ========================================================
-- GUI
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoStealRarityGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

-- Main Frame (larger for checkboxes)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 450)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
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
titleLabel.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
titleLabel.Text = "🥚 AUTO STEAL - RARITY FILTER"
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
titleCover.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
titleCover.BorderSizePixel = 0
titleCover.Parent = titleLabel

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 50)
statusLabel.Position = UDim2.new(0, 10, 0, 55)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready\nFilter: All rarities enabled\nWalkSpeed: 50 studs/s"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Code
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Rarity Filter Section
local rarityLabel = Instance.new("TextLabel")
rarityLabel.Size = UDim2.new(1, -20, 0, 25)
rarityLabel.Position = UDim2.new(0, 10, 0, 115)
rarityLabel.BackgroundTransparency = 1
rarityLabel.Text = "🎯 Select Egg Rarities:"
rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rarityLabel.TextSize = 14
rarityLabel.Font = Enum.Font.SourceSansBold
rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
rarityLabel.Parent = mainFrame

-- Rarity Checkboxes
local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}
local rarityColors = {
    Common = Color3.fromRGB(189, 195, 199),
    Uncommon = Color3.fromRGB(46, 204, 113),
    Rare = Color3.fromRGB(52, 152, 219),
    Epic = Color3.fromRGB(155, 89, 182),
    Legendary = Color3.fromRGB(241, 196, 15),
    Mythic = Color3.fromRGB(231, 76, 60)
}

local checkboxes = {}

for i, rarity in ipairs(rarities) do
    local yPos = 145 + (i - 1) * 35
    
    -- Checkbox frame
    local checkFrame = Instance.new("Frame")
    checkFrame.Size = UDim2.new(1, -20, 0, 30)
    checkFrame.Position = UDim2.new(0, 10, 0, yPos)
    checkFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    checkFrame.BorderSizePixel = 0
    checkFrame.Parent = mainFrame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 8)
    checkCorner.Parent = checkFrame
    
    -- Checkbox button
    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 30, 0, 30)
    checkBtn.Position = UDim2.new(0, 0, 0, 0)
    checkBtn.BackgroundColor3 = rarityColors[rarity]
    checkBtn.Text = "✓"
    checkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkBtn.TextSize = 18
    checkBtn.Font = Enum.Font.SourceSansBold
    checkBtn.Parent = checkFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = checkBtn
    
    -- Label
    local checkLabel = Instance.new("TextLabel")
    checkLabel.Size = UDim2.new(1, -40, 1, 0)
    checkLabel.Position = UDim2.new(0, 40, 0, 0)
    checkLabel.BackgroundTransparency = 1
    checkLabel.Text = rarity
    checkLabel.TextColor3 = rarityColors[rarity]
    checkLabel.TextSize = 14
    checkLabel.Font = Enum.Font.SourceSansBold
    checkLabel.TextXAlignment = Enum.TextXAlignment.Left
    checkLabel.Parent = checkFrame
    
    -- Store reference
    checkboxes[rarity] = {btn = checkBtn, label = checkLabel}
    
    -- Click handler
    checkBtn.MouseButton1Click:Connect(function()
        CONFIG.RarityFilters[rarity] = not CONFIG.RarityFilters[rarity]
        
        if CONFIG.RarityFilters[rarity] then
            checkBtn.Text = "✓"
            checkBtn.BackgroundColor3 = rarityColors[rarity]
        else
            checkBtn.Text = ""
            checkBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        end
        
        -- Update status
        local enabled = {}
        for r, e in pairs(CONFIG.RarityFilters) do
            if e then table.insert(enabled, r) end
        end
        
        if #enabled == 0 then
            statusLabel.Text = "Status: Ready\n⚠️ No rarities selected!\nWalkSpeed: " .. CONFIG.WalkSpeed
        else
            statusLabel.Text = "Status: Ready\nFilter: " .. table.concat(enabled, ", ") .. "\nWalkSpeed: " .. CONFIG.WalkSpeed
        end
    end)
end

-- WalkSpeed controls
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, -15, 0, 40)
speedLabel.Position = UDim2.new(0, 10, 0, 360)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "🚶 WalkSpeed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.TextYAlignment = Enum.TextYAlignment.Center
speedLabel.Parent = mainFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.5, -15, 0, 40)
speedInput.Position = UDim2.new(0.5, 5, 0, 360)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedInput.BorderSizePixel = 0
speedInput.Text = "50"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 16
speedInput.Font = Enum.Font.SourceSansBold
speedInput.PlaceholderText = "16-500"
speedInput.ClearTextOnFocus = false
speedInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = speedInput

speedInput.FocusLost:Connect(function()
    local value = tonumber(speedInput.Text)
    if value then
        value = math.clamp(value, 16, 500)
        CONFIG.WalkSpeed = value
        speedInput.Text = tostring(value)
        
        local enabled = {}
        for r, e in pairs(CONFIG.RarityFilters) do
            if e then table.insert(enabled, r) end
        end
        statusLabel.Text = "Status: Ready\nFilter: " .. (#enabled > 0 and table.concat(enabled, ", ") or "None") .. "\nWalkSpeed: " .. value
    else
        speedInput.Text = tostring(CONFIG.WalkSpeed)
    end
end)

-- Steal button
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(1, -20, 0, 35)
stealBtn.Position = UDim2.new(0, 10, 1, -80)
stealBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
stealBtn.Text = "🥚 STEAL ONCE"
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.TextSize = 14
stealBtn.Font = Enum.Font.SourceSansBold
stealBtn.Parent = mainFrame

local stealCorner = Instance.new("UICorner")
stealCorner.CornerRadius = UDim.new(0, 8)
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

-- Auto loop button
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -20, 0, 35)
autoBtn.Position = UDim2.new(0, 10, 1, -40)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoBtn.Text = "🔄 AUTO LOOP: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 14
autoBtn.Font = Enum.Font.SourceSansBold
autoBtn.Parent = mainFrame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 8)
autoCorner.Parent = autoBtn

autoBtn.MouseButton1Click:Connect(function()
    CONFIG.Enabled = not CONFIG.Enabled
    
    if CONFIG.Enabled then
        autoBtn.Text = "🔄 AUTO LOOP: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
    else
        autoBtn.Text = "🔄 AUTO LOOP: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- Auto Loop
task.spawn(function()
    while true do
        if CONFIG.Enabled then
            local success = autoStealCycle()
            
            if success then
                CONFIG.Enabled = false
                autoBtn.Text = "🔄 AUTO LOOP: OFF"
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
print("✅ AUTO STEAL (RARITY FILTER) LOADED!")
print("🎮 Select rarities with checkboxes")
print("🎮 Adjust WalkSpeed in textbox")
print("🎮 Click '🥚 STEAL ONCE' to test")
print("🎮 Click '🔄 AUTO LOOP' for auto farm")
print("========================================")
