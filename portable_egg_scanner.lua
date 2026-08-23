-- ========================================================
-- PORTABLE EGG SCANNER
-- Scan eggs di sekitar player secara real-time
-- Walk to each area and press SCAN button
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("🔍 PORTABLE EGG SCANNER")
print("========================================")
print("Walk to different areas and press SCAN")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    ScanRadius = 200,  -- Scan radius around player
    ShowDistance = true,
}

-- Full debug log
local fullDebugLog = {}

local function addToLog(text)
    print(text)
    table.insert(fullDebugLog, text)
end

-- ========================================================
-- CHARACTER
-- ========================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ========================================================
-- SCAN FUNCTION
-- ========================================================

local function scanNearbyEggs()
    local results = {
        eggs = {},
        position = hrp.Position,
        timestamp = os.date("%H:%M:%S")
    }
    
    addToLog("\n🔍 SCANNING...")
    addToLog("─────────────────────────────────────")
    addToLog("Time: " .. results.timestamp)
    addToLog("Your Position: " .. tostring(results.position))
    addToLog("Scan Radius: " .. CONFIG.ScanRadius .. " studs")
    addToLog("")
    
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    
    if not areaEggs then
        addToLog("❌ AreaEggSlotsClient not found")
        return results
    end
    
    -- Scan all eggs
    for _, child in pairs(areaEggs:GetChildren()) do
        if child:IsA("Model") then
            local primaryPart = child.PrimaryPart or child:FindFirstChild("Hitbox") or child:FindFirstChildWhichIsA("BasePart")
            
            if primaryPart then
                local distance = (hrp.Position - primaryPart.Position).Magnitude
                
                -- Only show eggs within scan radius
                if distance <= CONFIG.ScanRadius then
                    table.insert(results.eggs, {
                        name = child.Name,
                        distance = distance,
                        position = primaryPart.Position,
                        fullPath = child:GetFullName()
                    })
                end
            end
        end
    end
    
    -- Sort by distance
    table.sort(results.eggs, function(a, b)
        return a.distance < b.distance
    end)
    
    addToLog("✅ Found " .. #results.eggs .. " eggs nearby")
    addToLog("")
    
    -- Show results
    if #results.eggs > 0 then
        for i, egg in ipairs(results.eggs) do
            addToLog("─────────────────────────────────────")
            addToLog(string.format("EGG #%d", i))
            addToLog("─────────────────────────────────────")
            addToLog("Name: " .. egg.name)
            addToLog("Distance: " .. math.floor(egg.distance) .. " studs")
            addToLog("Position: " .. tostring(egg.position))
            addToLog("Path: " .. egg.fullPath)
            addToLog("")
            
            -- Area detection attempts
            addToLog("Area Detection Tests:")
            
            -- Method 1: Extract from pattern
            local area1 = egg.name:match("_([%w%s]+):") or egg.name:match("_([%w]+)_Slot")
            if area1 then
                area1 = area1:gsub("Slot", ""):match("^%s*(.-)%s*$")
                addToLog("  • Pattern Extract: " .. area1)
            end
            
            -- Method 2: Split by underscore
            local parts = {}
            for part in egg.name:gmatch("[^_]+") do
                table.insert(parts, part)
            end
            if #parts >= 3 then
                local possibleArea = parts[#parts]:gsub(":.*", ""):gsub("Slot.*", "")
                addToLog("  • Last Part: " .. possibleArea)
            end
            
            -- Method 3: Keyword search
            local keywords = {"Forest", "Lake", "Snow", "Desert", "Jungle", "Volcano", "Prehistoric", "Ocean", "Abyss", "Cosmic"}
            for _, keyword in ipairs(keywords) do
                if egg.name:lower():find(keyword:lower()) then
                    addToLog("  • Keyword Found: " .. keyword)
                end
            end
            
            addToLog("")
        end
    else
        addToLog("❌ No eggs found in " .. CONFIG.ScanRadius .. " studs radius")
        addToLog("   Walk to different area and scan again")
    end
    
    addToLog("========================================\n")
    
    return results
end

-- ========================================================
-- GUI
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PortableScannerGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(1, -420, 0, 20)  -- Top right corner
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 80, 200)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🔍 Portable Scanner"
titleText.TextColor3 = Color3.fromRGB(150, 130, 230)
titleText.TextSize = 18
titleText.Font = Enum.Font.SourceSansBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 7.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Info Display
local infoContainer = Instance.new("Frame")
infoContainer.Size = UDim2.new(1, -30, 0, 90)
infoContainer.Position = UDim2.new(0, 15, 0, 55)
infoContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
infoContainer.BorderSizePixel = 0
infoContainer.Parent = mainFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 10)
infoCorner.Parent = infoContainer

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready to scan"
statusLabel.TextColor3 = Color3.fromRGB(150, 230, 150)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = infoContainer

local eggCountLabel = Instance.new("TextLabel")
eggCountLabel.Size = UDim2.new(1, -20, 0, 20)
eggCountLabel.Position = UDim2.new(0, 10, 0, 35)
eggCountLabel.BackgroundTransparency = 1
eggCountLabel.Text = "Eggs found: 0"
eggCountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
eggCountLabel.TextSize = 13
eggCountLabel.Font = Enum.Font.SourceSans
eggCountLabel.TextXAlignment = Enum.TextXAlignment.Left
eggCountLabel.Parent = infoContainer

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(1, -20, 0, 20)
radiusLabel.Position = UDim2.new(0, 10, 0, 55)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Scan radius: " .. CONFIG.ScanRadius .. " studs"
radiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusLabel.TextSize = 13
radiusLabel.Font = Enum.Font.SourceSans
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = infoContainer

-- Radius Slider
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -30, 0, 20)
sliderLabel.Position = UDim2.new(0, 15, 0, 155)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Adjust Radius:"
sliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
sliderLabel.TextSize = 12
sliderLabel.Font = Enum.Font.SourceSans
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = mainFrame

local radiusInput = Instance.new("TextBox")
radiusInput.Size = UDim2.new(1, -30, 0, 30)
radiusInput.Position = UDim2.new(0, 15, 0, 175)
radiusInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
radiusInput.Text = tostring(CONFIG.ScanRadius)
radiusInput.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusInput.TextSize = 14
radiusInput.Font = Enum.Font.SourceSans
radiusInput.PlaceholderText = "Enter radius (50-1000)"
radiusInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = radiusInput

radiusInput.FocusLost:Connect(function()
    local newRadius = tonumber(radiusInput.Text)
    if newRadius and newRadius >= 50 and newRadius <= 1000 then
        CONFIG.ScanRadius = newRadius
        radiusLabel.Text = "Scan radius: " .. CONFIG.ScanRadius .. " studs"
        statusLabel.Text = "Radius updated to " .. CONFIG.ScanRadius
        statusLabel.TextColor3 = Color3.fromRGB(150, 230, 150)
    else
        radiusInput.Text = tostring(CONFIG.ScanRadius)
        statusLabel.Text = "Invalid radius (50-1000)"
        statusLabel.TextColor3 = Color3.fromRGB(230, 150, 150)
    end
end)

-- Scan Button
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.48, -10, 0, 40)
scanBtn.Position = UDim2.new(0, 15, 1, -50)
scanBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
scanBtn.Text = "🔍 SCAN"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 16
scanBtn.Font = Enum.Font.SourceSansBold
scanBtn.Parent = mainFrame

local scanCorner = Instance.new("UICorner")
scanCorner.CornerRadius = UDim.new(0, 10)
scanCorner.Parent = scanBtn

-- Copy Button
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.48, -10, 0, 40)
copyBtn.Position = UDim2.new(0.52, 5, 1, -50)
copyBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
copyBtn.Text = "📋 COPY"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextSize = 16
copyBtn.Font = Enum.Font.SourceSansBold
copyBtn.Parent = mainFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 10)
copyCorner.Parent = copyBtn

-- Scan Button Logic
local lastScanResults = nil

scanBtn.MouseButton1Click:Connect(function()
    scanBtn.Text = "⏳ Scanning..."
    scanBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
    statusLabel.Text = "Scanning..."
    statusLabel.TextColor3 = Color3.fromRGB(230, 200, 100)
    
    task.wait(0.1)
    
    lastScanResults = scanNearbyEggs()
    
    if #lastScanResults.eggs > 0 then
        scanBtn.Text = "✅ Done!"
        scanBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        statusLabel.Text = "Scan complete!"
        statusLabel.TextColor3 = Color3.fromRGB(150, 230, 150)
        eggCountLabel.Text = "Eggs found: " .. #lastScanResults.eggs
    else
        scanBtn.Text = "❌ None"
        scanBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        statusLabel.Text = "No eggs nearby"
        statusLabel.TextColor3 = Color3.fromRGB(230, 150, 150)
        eggCountLabel.Text = "Eggs found: 0"
    end
    
    task.wait(2)
    scanBtn.Text = "🔍 SCAN"
    scanBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
end)

-- Copy Button Logic
copyBtn.MouseButton1Click:Connect(function()
    if #fullDebugLog == 0 then
        copyBtn.Text = "❌ No Data"
        copyBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        statusLabel.Text = "Scan first!"
        statusLabel.TextColor3 = Color3.fromRGB(230, 150, 150)
        
        task.wait(2)
        copyBtn.Text = "📋 COPY"
        copyBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
        return
    end
    
    local fullOutput = table.concat(fullDebugLog, "\n")
    
    local success = pcall(function()
        setclipboard(fullOutput)
    end)
    
    if success then
        copyBtn.Text = "✅ Copied!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        statusLabel.Text = "Copied to clipboard!"
        statusLabel.TextColor3 = Color3.fromRGB(150, 230, 150)
    else
        copyBtn.Text = "❌ Failed"
        copyBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        statusLabel.Text = "Clipboard not available"
        statusLabel.TextColor3 = Color3.fromRGB(230, 150, 150)
    end
    
    task.wait(2)
    copyBtn.Text = "📋 COPY"
    copyBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
end)

-- Close Button
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("🚫 Scanner closed")
end)

-- Drag functionality
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

print("========================================")
print("✅ PORTABLE SCANNER READY!")
print("========================================")
print("Instructions:")
print("1. Walk to different areas in game")
print("2. Press SCAN button when at each area")
print("3. Results show in console + GUI")
print("4. Press COPY to copy all scan data")
print("5. Send copied data to developer")
print("========================================")
