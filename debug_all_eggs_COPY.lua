-- ========================================================
-- DEBUG ALL EGGS - Auto Copy to Clipboard
-- Scan semua eggs + area detection
-- ========================================================

print("🔍 DEBUG ALL EGGS - SCANNING...")
print("========================================\n")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local outputBuffer = {}

local function log(text)
    print(text)
    table.insert(outputBuffer, text)
end

-- ========================================================
-- AREA DETECTION TEST
-- ========================================================

local function testAreaDetection(eggName)
    local results = {}
    
    -- Method 1: Extract from pattern "_AREA:" or "_AREA_Slot"
    local area1 = eggName:match("_([%w%s]+):") or eggName:match("_([%w%s]+)_Slot")
    if area1 then
        area1 = area1:gsub("Slot", ""):gsub("_", " "):match("^%s*(.-)%s*$")
        table.insert(results, "Method 1 (Pattern): " .. area1)
    end
    
    -- Method 2: Last part before colon
    local area2 = eggName:match(":"):gsub(":", "")
    if eggName:find(":") then
        local parts = {}
        for part in eggName:gmatch("[^:]+") do
            table.insert(parts, part)
        end
        if #parts > 0 then
            local lastPart = parts[1]:match("_([%w%s]+)$") or "N/A"
            table.insert(results, "Method 2 (Last Part): " .. lastPart)
        end
    end
    
    -- Method 3: Simple keyword search
    local keywords = {"Forest", "Lake", "Snow", "Desert", "Jungle", "Volcano", "Prehistoric", "Ocean", "Abyss", "Cosmic"}
    for _, keyword in ipairs(keywords) do
        if eggName:lower():find(keyword:lower()) then
            table.insert(results, "Method 3 (Keyword): " .. keyword)
            break
        end
    end
    
    return results
end

-- ========================================================
-- SCAN ALL EGGS
-- ========================================================

log("⏳ Scanning AreaEggSlotsClient...\n")

local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")

if not areaEggs then
    log("❌ AreaEggSlotsClient not found!")
    log("========================================")
    
    local fullOutput = table.concat(outputBuffer, "\n")
    pcall(function() setclipboard(fullOutput) end)
    return
end

log("✅ Found: " .. areaEggs:GetFullName())
log("   Total children: " .. #areaEggs:GetChildren())
log("\n========================================")
log("📋 ALL EGGS IN MAP")
log("========================================\n")

local eggs = {}

for _, child in pairs(areaEggs:GetChildren()) do
    if child:IsA("Model") then
        local primaryPart = child.PrimaryPart or child:FindFirstChild("Hitbox") or child:FindFirstChildWhichIsA("BasePart")
        
        if primaryPart then
            table.insert(eggs, {
                name = child.Name,
                fullPath = child:GetFullName(),
                position = primaryPart.Position,
                children = #child:GetChildren()
            })
        end
    end
end

log("Total eggs found: " .. #eggs .. "\n")

-- Group eggs by pattern
local grouped = {}

for i, egg in ipairs(eggs) do
    log("─────────────────────────────────────")
    log(string.format("EGG #%d", i))
    log("─────────────────────────────────────")
    log("Name: " .. egg.name)
    log("Path: " .. egg.fullPath)
    log("Position: " .. tostring(egg.position))
    log("Children: " .. egg.children)
    log("")
    
    -- Test area detection
    log("Area Detection Tests:")
    local detectionResults = testAreaDetection(egg.name)
    
    if #detectionResults > 0 then
        for _, result in ipairs(detectionResults) do
            log("  • " .. result)
        end
    else
        log("  • No area detected")
    end
    
    log("")
    
    -- Extract pattern for grouping
    local pattern = egg.name:match("(.+)_Slot") or egg.name:match("(.+):")
    if pattern then
        if not grouped[pattern] then
            grouped[pattern] = 0
        end
        grouped[pattern] = grouped[pattern] + 1
    end
end

log("========================================")
log("📊 PATTERN SUMMARY")
log("========================================\n")

local sortedPatterns = {}
for pattern, count in pairs(grouped) do
    table.insert(sortedPatterns, {pattern = pattern, count = count})
end

table.sort(sortedPatterns, function(a, b)
    return a.count > b.count
end)

for i, data in ipairs(sortedPatterns) do
    log(string.format("%d. %s (%d eggs)", i, data.pattern, data.count))
end

log("\n========================================")
log("💡 AREA EXTRACTION EXAMPLES")
log("========================================\n")

-- Show unique examples
local seen = {}
for _, egg in ipairs(eggs) do
    local pattern = egg.name:match("(.+)_Slot") or egg.name:match("(.+):")
    
    if pattern and not seen[pattern] then
        seen[pattern] = true
        
        log("Example: " .. egg.name)
        
        -- Try different extraction methods
        local methods = {
            {"Split by ':'", egg.name:match("_([^:]+):") or "N/A"},
            {"Split by '_Slot'", egg.name:match("_([^_]+)_Slot") or egg.name:match("_([^_]+)$") or "N/A"},
            {"Last underscore part", egg.name:match("_([%w]+)$") or egg.name:match("_([%w]+):") or "N/A"},
        }
        
        for _, method in ipairs(methods) do
            log(string.format("  %s: %s", method[1], method[2]))
        end
        
        log("")
    end
end

log("========================================")
log("✅ SCAN COMPLETE")
log("========================================")
log("")

-- Character position
local character = LocalPlayer.Character
if character then
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        log("📍 Your Position: " .. tostring(hrp.Position))
        log("")
        
        -- Find closest egg
        local closestEgg, closestDist = nil, math.huge
        
        for _, egg in ipairs(eggs) do
            local dist = (hrp.Position - egg.position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestEgg = egg
            end
        end
        
        if closestEgg then
            log("🎯 Closest Egg:")
            log("   Name: " .. closestEgg.name)
            log("   Distance: " .. math.floor(closestDist) .. " studs")
        end
    end
end

log("\n========================================")
log("📋 COPIED TO CLIPBOARD!")
log("========================================")
log("Paste this output (Ctrl+V) and send to developer")

-- Copy to clipboard
local fullOutput = table.concat(outputBuffer, "\n")

local copySuccess = pcall(function()
    setclipboard(fullOutput)
end)

if not copySuccess then
    print("\n⚠️  Clipboard not available - please copy manually")
end

-- Create GUI notification
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugNotification"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end
screenGui.Parent = parentGui

local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 400, 0, 200)
notifFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
notifFrame.BorderSizePixel = 0
notifFrame.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 15)
notifCorner.Parent = notifFrame

local notifStroke = Instance.new("UIStroke")
notifStroke.Color = Color3.fromRGB(100, 80, 200)
notifStroke.Thickness = 2
notifStroke.Parent = notifFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 40)
titleLabel.Position = UDim2.new(0, 20, 0, 20)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✅ Debug Complete!"
titleLabel.TextColor3 = Color3.fromRGB(150, 230, 150)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = notifFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -40, 0, 60)
infoLabel.Position = UDim2.new(0, 20, 0, 60)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = string.format("Found %d eggs\nResults copied to clipboard!\nPaste with Ctrl+V", #eggs)
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextSize = 14
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = notifFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -40, 0, 45)
copyBtn.Position = UDim2.new(0, 20, 1, -65)
copyBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
copyBtn.Text = "📋 COPY AGAIN"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextSize = 16
copyBtn.Font = Enum.Font.SourceSansBold
copyBtn.Parent = notifFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 10)
copyCorner.Parent = copyBtn

copyBtn.MouseButton1Click:Connect(function()
    local success = pcall(function()
        setclipboard(fullOutput)
    end)
    
    if success then
        copyBtn.Text = "✅ COPIED!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        task.wait(2)
        copyBtn.Text = "📋 COPY AGAIN"
        copyBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
    else
        copyBtn.Text = "❌ Failed"
        copyBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- Auto close after 15 seconds
task.delay(15, function()
    if screenGui.Parent then
        screenGui:Destroy()
    end
end)

print("\n🎮 GUI notification shown")
print("🎮 Results ready to paste!")
