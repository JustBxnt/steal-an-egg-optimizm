-- ========================================================
-- AUTO STEAL EGG - WIDE GUI (20 RARITIES)
-- WALK MODE | 2 Columns Layout | Compact Design
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("🥚 AUTO STEAL - WIDE GUI (WALK MODE)")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    Enabled = false,
    WalkSpeed = 200,
    SearchRadius = 500,
    
    RarityFilters = {
        Basic = true, Common = true, Uncommon = true, Rare = true, SuperRare = true,
        Epic = true, Legendary = true, Mythic = true, Limited = true, Exclusive = true,
        Exotic = true, Superior = true, Divine = true, Secret = true, Notification = true,
        Celestial = true, Rainbow = true, BrainrotCod = true, Eternal = true, Cosmic = true,
    }
}

local RARITY_COLORS = {
    Basic = Color3.fromRGB(140, 140, 140),
    Common = Color3.fromRGB(189, 195, 199),
    Uncommon = Color3.fromRGB(46, 204, 113),
    Rare = Color3.fromRGB(52, 152, 219),
    SuperRare = Color3.fromRGB(100, 180, 255),
    Epic = Color3.fromRGB(155, 89, 182),
    Legendary = Color3.fromRGB(241, 196, 15),
    Mythic = Color3.fromRGB(231, 76, 60),
    Limited = Color3.fromRGB(255, 100, 255),
    Exclusive = Color3.fromRGB(255, 0, 255),
    Exotic = Color3.fromRGB(255, 150, 0),
    Superior = Color3.fromRGB(0, 255, 255),
    Divine = Color3.fromRGB(255, 215, 0),
    Secret = Color3.fromRGB(50, 50, 50),
    Notification = Color3.fromRGB(100, 200, 255),
    Celestial = Color3.fromRGB(150, 150, 255),
    Rainbow = Color3.fromRGB(255, 0, 150),
    BrainrotCod = Color3.fromRGB(0, 255, 127),
    Eternal = Color3.fromRGB(139, 0, 139),
    Cosmic = Color3.fromRGB(75, 0, 130),
}

local EGG_RARITIES = {
    ["basic"] = "Basic", ["starter"] = "Basic",
    ["common"] = "Common", ["chicken"] = "Common", ["duck"] = "Common",
    ["uncommon"] = "Uncommon", ["bear"] = "Uncommon", ["fox"] = "Uncommon",
    ["rare"] = "Rare", ["golden"] = "Rare", ["silver"] = "Rare",
    ["superrare"] = "SuperRare", ["super rare"] = "SuperRare",
    ["epic"] = "Epic", ["dragon"] = "Epic", ["phoenix"] = "Epic",
    ["legendary"] = "Legendary", ["ancient"] = "Legendary",
    ["mythic"] = "Mythic",
    ["limited"] = "Limited",
    ["exclusive"] = "Exclusive",
    ["exotic"] = "Exotic",
    ["superior"] = "Superior",
    ["divine"] = "Divine",
    ["secret"] = "Secret",
    ["notification"] = "Notification",
    ["celestial"] = "Celestial",
    ["rainbow"] = "Rainbow",
    ["brainrot"] = "BrainrotCod", ["brainrotcod"] = "BrainrotCod",
    ["eternal"] = "Eternal",
    ["cosmic"] = "Cosmic",
}

-- ========================================================
-- CHARACTER
-- ========================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local ORIGINAL_WALKSPEED = humanoid.WalkSpeed
local SAFE_ZONE_POSITION = hrp.Position

print("✅ Character loaded | Safe zone saved")

-- ========================================================
-- CORE FUNCTIONS
-- ========================================================

local function detectEggRarity(eggName)
    local lowerName = eggName:lower()
    for pattern, rarity in pairs(EGG_RARITIES) do
        if lowerName:find(pattern) then return rarity end
    end
    return "Common"
end

local function isRarityEnabled(rarity)
    return CONFIG.RarityFilters[rarity] == true
end

local function findNearestEgg()
    local nearestEgg, nearestDist, nearestRarity = nil, math.huge, nil
    
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if areaEggs then
        for _, child in pairs(areaEggs:GetDescendants()) do
            if child:IsA("Model") and child.Name:lower():find("egg") then
                local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local dist = (hrp.Position - primaryPart.Position).Magnitude
                    
                    if dist < nearestDist and dist < CONFIG.SearchRadius then
                        local rarity = detectEggRarity(child.Name)
                        
                        if isRarityEnabled(rarity) then
                            nearestDist = dist
                            nearestEgg = child
                            nearestRarity = rarity
                        end
                    end
                end
            end
        end
    end
    
    return nearestEgg, nearestDist, nearestRarity
end

local function walkToPosition(position, timeout)
    timeout = timeout or 60
    
    local distance = (hrp.Position - position).Magnitude
    
    humanoid.WalkSpeed = CONFIG.WalkSpeed
    humanoid:MoveTo(position)
    
    local startTime = tick()
    local lastDist = distance
    
    while (tick() - startTime) < timeout do
        task.wait(0.5)
        
        local currentDist = (hrp.Position - position).Magnitude
        
        if currentDist < 10 then
            return true
        end
        
        if math.abs(currentDist - lastDist) < 1 then
            humanoid:MoveTo(position)
        end
        
        lastDist = currentDist
    end
    
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
                        nearestPrompt = {prompt = obj, parent = parent, distance = dist}
                    end
                end
            end
        end
    end
    
    if nearestPrompt then
        pcall(function() fireproximityprompt(nearestPrompt.prompt) end)
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

local function walkToSafeZone()
    local distance = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
    
    humanoid.WalkSpeed = CONFIG.WalkSpeed
    humanoid:MoveTo(SAFE_ZONE_POSITION)
    
    local startTime = tick()
    local lastDist = distance
    local timeout = 60
    
    while (tick() - startTime) < timeout do
        task.wait(0.5)
        
        local currentDist = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
        
        if currentDist < 15 then
            humanoid.WalkSpeed = ORIGINAL_WALKSPEED
            return true
        end
        
        if math.abs(currentDist - lastDist) < 1 then
            humanoid:MoveTo(SAFE_ZONE_POSITION)
        end
        
        lastDist = currentDist
    end
    
    humanoid.WalkSpeed = ORIGINAL_WALKSPEED
    return (hrp.Position - SAFE_ZONE_POSITION).Magnitude < 30
end

-- ========================================================
-- MAIN CYCLE
-- ========================================================

local function autoStealCycle()
    print("\n🔄 AUTO-STEAL CYCLE (WALK MODE)")
    
    local egg, distance, rarity = findNearestEgg()
    
    if not egg then
        print("❌ No eggs matching filters")
        return false
    end
    
    print("✅ Found:", egg.Name, "(" .. rarity .. ")")
    
    -- Walk to egg
    local eggPos = egg.PrimaryPart.Position
    if not walkToPosition(eggPos, 60) then
        print("❌ Walk failed")
        return false
    end
    
    task.wait(0.5)
    
    -- Fire prompt
    if not fireNearestPrompt() then
        print("❌ Prompt failed")
        return false
    end
    
    -- Instant check
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
    
    -- Walk back
    walkToSafeZone()
    print("✅ Returned!\n")
    
    return true
end

-- ========================================================
-- WIDE GUI (2 COLUMNS)
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoStealWideGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

-- Main Frame (WIDE, not tall)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 700, 0, 450)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 100, 120)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = titleBar

local titleCover = Instance.new("Frame")
titleCover.Size = UDim2.new(1, 0, 0, 15)
titleCover.Position = UDim2.new(0, 0, 1, -15)
titleCover.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
titleCover.BorderSizePixel = 0
titleCover.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -100, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🥚 AUTO STEAL - 20 RARITIES (WALK MODE)"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 15
titleText.Font = Enum.Font.SourceSansBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -75, 0, 6.5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -38, 0, 6.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Drag
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

titleBar.InputBegan:Connect(function(input)
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

titleBar.InputChanged:Connect(function(input)
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

-- Content
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 35)
statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
statusLabel.Text = "Status: Ready | All rarities enabled | Speed: 50"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Code
statusLabel.TextWrapped = true
statusLabel.Parent = contentFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

-- Filter Header
local filterHeader = Instance.new("TextLabel")
filterHeader.Size = UDim2.new(1, 0, 0, 25)
filterHeader.Position = UDim2.new(0, 0, 0, 45)
filterHeader.BackgroundTransparency = 1
filterHeader.Text = "🎯 Select Rarities to Steal:"
filterHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
filterHeader.TextSize = 14
filterHeader.Font = Enum.Font.SourceSansBold
filterHeader.TextXAlignment = Enum.TextXAlignment.Left
filterHeader.Parent = contentFrame

-- Rarities Container (2 COLUMNS)
local raritiesContainer = Instance.new("Frame")
raritiesContainer.Size = UDim2.new(1, 0, 0, 250)
raritiesContainer.Position = UDim2.new(0, 0, 0, 75)
raritiesContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
raritiesContainer.BorderSizePixel = 0
raritiesContainer.Parent = contentFrame

local raritiesCorner = Instance.new("UICorner")
raritiesCorner.CornerRadius = UDim.new(0, 8)
raritiesCorner.Parent = raritiesContainer

-- Scrolling Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
scrollFrame.Parent = raritiesContainer

-- Create 2 column layout
local rarities = {
    "Basic", "Common", "Uncommon", "Rare", "SuperRare",
    "Epic", "Legendary", "Mythic", "Limited", "Exclusive",
    "Exotic", "Superior", "Divine", "Secret", "Notification",
    "Celestial", "Rainbow", "BrainrotCod", "Eternal", "Cosmic"
}

local checkboxes = {}
local columnWidth = 0.48
local checkboxHeight = 28

for i, rarity in ipairs(rarities) do
    local column = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    
    local xPos = column * 0.52
    local yPos = 5 + row * checkboxHeight
    
    local checkFrame = Instance.new("Frame")
    checkFrame.Size = UDim2.new(columnWidth, 0, 0, 25)
    checkFrame.Position = UDim2.new(xPos, 5, 0, yPos)
    checkFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    checkFrame.BorderSizePixel = 0
    checkFrame.Parent = scrollFrame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 6)
    checkCorner.Parent = checkFrame
    
    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 25, 0, 25)
    checkBtn.BackgroundColor3 = RARITY_COLORS[rarity]
    checkBtn.Text = "✓"
    checkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkBtn.TextSize = 16
    checkBtn.Font = Enum.Font.SourceSansBold
    checkBtn.Parent = checkFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = checkBtn
    
    local checkLabel = Instance.new("TextLabel")
    checkLabel.Size = UDim2.new(1, -32, 1, 0)
    checkLabel.Position = UDim2.new(0, 30, 0, 0)
    checkLabel.BackgroundTransparency = 1
    checkLabel.Text = rarity
    checkLabel.TextColor3 = RARITY_COLORS[rarity]
    checkLabel.TextSize = 12
    checkLabel.Font = Enum.Font.SourceSansBold
    checkLabel.TextXAlignment = Enum.TextXAlignment.Left
    checkLabel.Parent = checkFrame
    
    checkboxes[rarity] = {btn = checkBtn, label = checkLabel}
    
    checkBtn.MouseButton1Click:Connect(function()
        CONFIG.RarityFilters[rarity] = not CONFIG.RarityFilters[rarity]
        
        if CONFIG.RarityFilters[rarity] then
            checkBtn.Text = "✓"
            checkBtn.BackgroundColor3 = RARITY_COLORS[rarity]
        else
            checkBtn.Text = ""
            checkBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        end
        
        local count = 0
        for r, e in pairs(CONFIG.RarityFilters) do
            if e then count = count + 1 end
        end
        
        if count == 0 then
            statusLabel.Text = "Status: Ready | ⚠️ No rarities! | Speed: " .. CONFIG.WalkSpeed
        elseif count == 20 then
            statusLabel.Text = "Status: Ready | All rarities | Speed: " .. CONFIG.WalkSpeed
        else
            statusLabel.Text = "Status: Ready | " .. count .. "/20 rarities | Speed: " .. CONFIG.WalkSpeed
        end
    end)
end

-- Update canvas size
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 5 + math.ceil(#rarities / 2) * checkboxHeight + 5)

-- Controls Container
local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(1, 0, 0, 55)
controlsFrame.Position = UDim2.new(0, 0, 1, -55)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = contentFrame

-- WalkSpeed
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0.3, -5, 0, 50)
speedFrame.Position = UDim2.new(0, 0, 0, 0)
speedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = controlsFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0, 3)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "🚶 WalkSpeed"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.Parent = speedFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, -10, 0, 23)
speedInput.Position = UDim2.new(0, 5, 0, 23)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedInput.BorderSizePixel = 0
speedInput.Text = "50"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 14
speedInput.Font = Enum.Font.SourceSansBold
speedInput.PlaceholderText = "16-500"
speedInput.ClearTextOnFocus = false
speedInput.Parent = speedFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = speedInput

speedInput.FocusLost:Connect(function()
    local value = tonumber(speedInput.Text)
    if value then
        value = math.clamp(value, 16, 500)
        CONFIG.WalkSpeed = value
        speedInput.Text = tostring(value)
        
        local count = 0
        for r, e in pairs(CONFIG.RarityFilters) do
            if e then count = count + 1 end
        end
        
        if count == 20 then
            statusLabel.Text = "Status: Ready | All rarities | Speed: " .. value
        else
            statusLabel.Text = "Status: Ready | " .. count .. "/20 rarities | Speed: " .. value
        end
    else
        speedInput.Text = tostring(CONFIG.WalkSpeed)
    end
end)

-- Steal Once Button
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(0.35, -7.5, 0, 50)
stealBtn.Position = UDim2.new(0.3, 2.5, 0, 0)
stealBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
stealBtn.Text = "🥚 STEAL ONCE"
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.TextSize = 14
stealBtn.Font = Enum.Font.SourceSansBold
stealBtn.Parent = controlsFrame

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

-- Auto Loop Button
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.35, -7.5, 0, 50)
autoBtn.Position = UDim2.new(0.65, 5, 0, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoBtn.Text = "🔄 AUTO LOOP: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 14
autoBtn.Font = Enum.Font.SourceSansBold
autoBtn.Parent = controlsFrame

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

-- Minimize
local isMinimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if isMinimized then
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 700, 0, 45)})
        tween:Play()
        minimizeBtn.Text = "+"
        contentFrame.Visible = false
    else
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 700, 0, 450)})
        tween:Play()
        minimizeBtn.Text = "−"
        tween.Completed:Connect(function()
            contentFrame.Visible = true
        end)
    end
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    CONFIG.Enabled = false
    screenGui:Destroy()
    print("🚫 GUI Closed")
end)

-- Auto Loop
task.spawn(function()
    while screenGui.Parent do
        if CONFIG.Enabled then
            local success = autoStealCycle()
            
            if success then
                CONFIG.Enabled = false
                autoBtn.Text = "🔄 AUTO LOOP: OFF"
                autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                print("🎉 EGG STOLEN! Loop stopped")
            else
                task.wait(2)
            end
        else
            task.wait(1)
        end
    end
end)

print("========================================")
print("✅ WIDE GUI LOADED!")
print("🎮 2 Column Layout | 20 Rarities")
print("🎮 WALK MODE | No Teleport")
print("🎮 Minimize | Close | Drag")
print("========================================")