-- ========================================================
-- AUTO STEAL EGG - AREA BASED
-- Alternative: Steal eggs based on area/distance
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("🥚 AUTO STEAL - AREA BASED")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    Enabled = false,
    DragSpeed = 200,
    MinDistance = 50,      -- Minimum distance to steal
    MaxDistance = 1000,    -- Maximum search radius
    DebugMode = true,
    
    -- Area filters (distance-based)
    StealNearbyOnly = false,  -- If true, only steal nearest egg
    SkipCommonArea = true,    -- Skip eggs in starting area
}

local RARITY_COLORS = {
    Nearby = Color3.fromRGB(46, 204, 113),
    Medium = Color3.fromRGB(241, 196, 15),
    Far = Color3.fromRGB(231, 76, 60),
    VeryFar = Color3.fromRGB(139, 0, 139),
}

-- ========================================================
-- CHARACTER
-- ========================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local SAFE_ZONE_POSITION = hrp.Position

print("✅ Character loaded")
print("✅ Safe zone:", SAFE_ZONE_POSITION)

-- ========================================================
-- ADVANCED EGG DETECTION
-- ========================================================

local function getEggRarity(eggModel)
    -- Method 1: Check all descendants for any rarity-related values
    for _, descendant in pairs(eggModel:GetDescendants()) do
        -- Check StringValue/IntValue
        if descendant:IsA("StringValue") or descendant:IsA("IntValue") then
            local value = tostring(descendant.Value):lower()
            if value:find("mythic") or value:find("divine") or value:find("cosmic") or 
               value:find("secret") or value:find("eternal") or value:find("legendary") or
               value:find("epic") or value:find("rare") or value:find("uncommon") then
                return tostring(descendant.Value), descendant:GetFullName()
            end
        end
        
        -- Check TextLabel
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            local text = descendant.Text:lower()
            if text:find("mythic") or text:find("divine") or text:find("cosmic") or 
               text:find("secret") or text:find("eternal") or text:find("legendary") or
               text:find("epic") or text:find("rare") or text:find("uncommon") then
                return descendant.Text, descendant:GetFullName()
            end
        end
        
        -- Check Attribute
        if descendant:IsA("BasePart") or descendant:IsA("Model") then
            for attrName, attrValue in pairs(descendant:GetAttributes()) do
                if attrName:lower():find("rarity") then
                    return tostring(attrValue), descendant:GetFullName() .. "." .. attrName
                end
            end
        end
    end
    
    -- Method 2: Check egg name parts
    local eggName = eggModel.Name
    for part in eggName:gmatch("[^_]+") do
        local lower = part:lower()
        if lower:find("mythic") or lower:find("divine") or lower:find("cosmic") or 
           lower:find("secret") or lower:find("eternal") or lower:find("legendary") or
           lower:find("epic") or lower:find("rare") or lower:find("uncommon") then
            return part, "Name"
        end
    end
    
    return nil, nil
end

local function findAllEggs()
    local eggs = {}
    
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not areaEggs then
        print("❌ AreaEggSlotsClient not found")
        return eggs
    end
    
    for _, child in pairs(areaEggs:GetDescendants()) do
        if child:IsA("Model") and child.Name:lower():find("egg") then
            local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                local dist = (hrp.Position - primaryPart.Position).Magnitude
                
                if dist >= CONFIG.MinDistance and dist <= CONFIG.MaxDistance then
                    local rarity, source = getEggRarity(child)
                    
                    table.insert(eggs, {
                        model = child,
                        position = primaryPart.Position,
                        distance = dist,
                        rarity = rarity,
                        raritySource = source,
                        name = child.Name
                    })
                end
            end
        end
    end
    
    -- Sort by distance
    table.sort(eggs, function(a, b)
        return a.distance < b.distance
    end)
    
    return eggs
end

-- ========================================================
-- DRAG MOVEMENT
-- ========================================================

local function dragTo(position, timeout)
    timeout = timeout or 60
    
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPos.P = CONFIG.DragSpeed * 100
    bodyPos.D = 200
    bodyPos.Position = position
    bodyPos.Parent = hrp
    
    local startTime = tick()
    
    while (tick() - startTime) < timeout do
        task.wait(0.1)
        
        local distance = (hrp.Position - position).Magnitude
        
        if distance < 5 then
            bodyPos:Destroy()
            return true
        end
        
        bodyPos.Position = position
    end
    
    bodyPos:Destroy()
    return false
end

local function fireNearestPrompt()
    local nearestPrompt, nearestPromptDist = nil, math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent then
                local isEggRelated = parent.Name:lower():find("egg") or obj.Name:lower():find("egg") or obj.Name:lower():find("carry")
                
                if isEggRelated and parent:IsA("BasePart") then
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
        pcall(function() fireproximityprompt(nearestPrompt) end)
        return true
    end
    return false
end

local function checkIfCarrying()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then return true, tool.Name end
    
    tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then return true, tool.Name end
    
    return false, nil
end

-- ========================================================
-- MAIN CYCLE
-- ========================================================

local function autoStealCycle()
    print("\n🔄 AUTO-STEAL CYCLE (AREA BASED)")
    
    local eggs = findAllEggs()
    
    if #eggs == 0 then
        print("❌ No eggs found in range")
        print("   MinDistance:", CONFIG.MinDistance)
        print("   MaxDistance:", CONFIG.MaxDistance)
        return false
    end
    
    print("✅ Found", #eggs, "eggs")
    
    -- Show first 5 eggs
    if CONFIG.DebugMode then
        print("\n📋 Available eggs:")
        for i = 1, math.min(5, #eggs) do
            local egg = eggs[i]
            print(string.format("  %d. %s (%.0f studs)", i, egg.name, egg.distance))
            if egg.rarity then
                print(string.format("     Rarity: %s (from %s)", egg.rarity, egg.raritySource or "unknown"))
            else
                print("     Rarity: NOT DETECTED")
            end
        end
    end
    
    -- Select egg to steal
    local targetEgg = eggs[1]  -- Nearest egg
    
    print("\n🎯 Target:", targetEgg.name)
    print("  Distance:", math.floor(targetEgg.distance), "studs")
    if targetEgg.rarity then
        print("  Rarity:", targetEgg.rarity)
        print("  Source:", targetEgg.raritySource)
    end
    
    -- Drag to egg
    print("🧲 Dragging to egg...")
    if not dragTo(targetEgg.position, 60) then
        print("❌ Movement failed")
        return false
    end
    
    task.wait(0.5)
    
    -- Fire prompt
    if not fireNearestPrompt() then
        print("❌ Prompt failed")
        return false
    end
    
    -- Check if carrying
    local carrying, eggName = false, nil
    
    for i = 1, 40 do
        carrying, eggName = checkIfCarrying()
        if carrying then
            print("✅ Egg detected!")
            break
        end
        task.wait(0.05)
    end
    
    if not carrying then
        print("❌ No egg detected")
        return false
    end
    
    print("✅✅ SUCCESS! Carrying:", eggName)
    
    -- Drag back
    print("🧲 Dragging back...")
    dragTo(SAFE_ZONE_POSITION, 60)
    
    print("✅ Returned!\n")
    
    return true
end

-- ========================================================
-- SIMPLE GUI
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

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 350)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 80, 200)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 40)
titleLabel.Position = UDim2.new(0, 20, 0, 20)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🥚 Auto Steal (Area Based)"
titleLabel.TextColor3 = Color3.fromRGB(150, 130, 230)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainFrame

-- Distance sliders
local minLabel = Instance.new("TextLabel")
minLabel.Size = UDim2.new(1, -40, 0, 30)
minLabel.Position = UDim2.new(0, 20, 0, 80)
minLabel.BackgroundTransparency = 1
minLabel.Text = "Min Distance: " .. CONFIG.MinDistance .. " studs"
minLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
minLabel.TextSize = 14
minLabel.Font = Enum.Font.SourceSans
minLabel.TextXAlignment = Enum.TextXAlignment.Left
minLabel.Parent = mainFrame

local minSlider = Instance.new("TextBox")
minSlider.Size = UDim2.new(1, -40, 0, 35)
minSlider.Position = UDim2.new(0, 20, 0, 115)
minSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minSlider.Text = tostring(CONFIG.MinDistance)
minSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
minSlider.TextSize = 14
minSlider.Font = Enum.Font.SourceSans
minSlider.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minSlider

minSlider.FocusLost:Connect(function()
    local val = tonumber(minSlider.Text)
    if val then
        CONFIG.MinDistance = math.max(0, val)
        minLabel.Text = "Min Distance: " .. CONFIG.MinDistance .. " studs"
    else
        minSlider.Text = tostring(CONFIG.MinDistance)
    end
end)

local maxLabel = Instance.new("TextLabel")
maxLabel.Size = UDim2.new(1, -40, 0, 30)
maxLabel.Position = UDim2.new(0, 20, 0, 165)
maxLabel.BackgroundTransparency = 1
maxLabel.Text = "Max Distance: " .. CONFIG.MaxDistance .. " studs"
maxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
maxLabel.TextSize = 14
maxLabel.Font = Enum.Font.SourceSans
maxLabel.TextXAlignment = Enum.TextXAlignment.Left
maxLabel.Parent = mainFrame

local maxSlider = Instance.new("TextBox")
maxSlider.Size = UDim2.new(1, -40, 0, 35)
maxSlider.Position = UDim2.new(0, 20, 0, 200)
maxSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
maxSlider.Text = tostring(CONFIG.MaxDistance)
maxSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
maxSlider.TextSize = 14
maxSlider.Font = Enum.Font.SourceSans
maxSlider.Parent = mainFrame

local maxCorner = Instance.new("UICorner")
maxCorner.CornerRadius = UDim.new(0, 8)
maxCorner.Parent = maxSlider

maxSlider.FocusLost:Connect(function()
    local val = tonumber(maxSlider.Text)
    if val then
        CONFIG.MaxDistance = math.max(100, val)
        maxLabel.Text = "Max Distance: " .. CONFIG.MaxDistance .. " studs"
    else
        maxSlider.Text = tostring(CONFIG.MaxDistance)
    end
end)

-- Control Buttons
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(1, -40, 0, 40)
stealBtn.Position = UDim2.new(0, 20, 0, 250)
stealBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
stealBtn.Text = "🥚 STEAL ONCE"
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.TextSize = 14
stealBtn.Font = Enum.Font.SourceSansBold
stealBtn.Parent = mainFrame

local stealCorner = Instance.new("UICorner")
stealCorner.CornerRadius = UDim.new(0, 10)
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

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -40, 0, 40)
autoBtn.Position = UDim2.new(0, 20, 0, 300)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoBtn.Text = "🔄 AUTO: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 14
autoBtn.Font = Enum.Font.SourceSansBold
autoBtn.Parent = mainFrame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 10)
autoCorner.Parent = autoBtn

autoBtn.MouseButton1Click:Connect(function()
    CONFIG.Enabled = not CONFIG.Enabled
    
    if CONFIG.Enabled then
        autoBtn.Text = "🔄 AUTO: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
    else
        autoBtn.Text = "🔄 AUTO: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- Drag functionality
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

mainFrame.InputBegan:Connect(function(input)
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

mainFrame.InputChanged:Connect(function(input)
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

-- Auto Loop
task.spawn(function()
    while screenGui.Parent do
        if CONFIG.Enabled then
            local success = autoStealCycle()
            
            if success then
                task.wait(1)
            else
                task.wait(5)
            end
        else
            task.wait(1)
        end
    end
end)

print("========================================")
print("✅ AREA-BASED VERSION LOADED!")
print("🎮 Works regardless of rarity names")
print("🎮 Steals nearest eggs")
print("🎮 Debug Mode: ON")
print("========================================")
