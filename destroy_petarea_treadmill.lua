-- ========================================================
-- DESTROY PETAREA & TREADMILL RENDER - PERFORMANCE BOOST
-- Script untuk menghapus PetArea dan Treadmill Render
-- ========================================================

print("🔥 LOADING PETAREA & TREADMILL DESTROYER...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- DESTROYER DATA & SETTINGS
-- ========================================================

local destroyData = {
    petAreas = {},
    treadmills = {},
    totalDestroyed = 0,
    scanResults = {
        petAreasFound = 0,
        treadmillsFound = 0,
        totalScanned = 0
    }
}

local destroySettings = {
    autoContinuous = false,
    showDestroy = true,
    scanOnStart = true
}

-- ========================================================
-- DETECTION FUNCTIONS
-- ========================================================

local function isPetArea(obj)
    local name = obj.Name:lower()
    local className = obj.ClassName
    
    -- Check for PetArea patterns
    if name:find("petarea") or name:find("pet_area") or name:find("pet area") then
        return true
    end
    
    -- Check for specific PetArea model characteristics
    if obj:IsA("Model") then
        -- Check for children that indicate it's a pet area
        for _, child in pairs(obj:GetChildren()) do
            local childName = child.Name:lower()
            if childName:find("petarea") or childName:find("pet_area") then
                return true
            end
        end
        
        -- Check parent name for pet area context
        if obj.Parent and obj.Parent.Name:lower():find("petarea") then
            return true
        end
    end
    
    return false
end

local function isTreadmill(obj)
    local name = obj.Name:lower()
    local className = obj.ClassName
    
    -- Check for Treadmill patterns
    if name:find("treadmill") or name:find("tread_mill") or 
       name:find("treadmillrender") or name:find("treadmill_render") then
        return true
    end
    
    -- Check for specific Treadmill model characteristics
    if obj:IsA("Model") then
        -- Check for children that indicate it's a treadmill
        for _, child in pairs(obj:GetChildren()) do
            local childName = child.Name:lower()
            if childName:find("treadmill") or childName:find("render") then
                return true
            end
        end
        
        -- Check parent name for treadmill context
        if obj.Parent and obj.Parent.Name:lower():find("treadmill") then
            return true
        end
    end
    
    return false
end

-- ========================================================
-- SCAN & DESTROY FUNCTIONS
-- ========================================================

local function scanWorkspaceForTargets()
    print("🔍 Scanning workspace for PetArea and Treadmill objects...")
    
    -- Reset scan results
    destroyData.scanResults = {
        petAreasFound = 0,
        treadmillsFound = 0,
        totalScanned = 0
    }
    
    local startTime = tick()
    
    -- Scan all workspace descendants
    for _, obj in pairs(Workspace:GetDescendants()) do
        destroyData.scanResults.totalScanned = destroyData.scanResults.totalScanned + 1
        
        pcall(function()
            if isPetArea(obj) then
                table.insert(destroyData.petAreas, obj)
                destroyData.scanResults.petAreasFound = destroyData.scanResults.petAreasFound + 1
                if destroySettings.showDestroy then
                    print("🎯 Found PetArea: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                end
            elseif isTreadmill(obj) then
                table.insert(destroyData.treadmills, obj)
                destroyData.scanResults.treadmillsFound = destroyData.scanResults.treadmillsFound + 1
                if destroySettings.showDestroy then
                    print("🎯 Found Treadmill: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                end
            end
        end)
    end
    
    local scanTime = math.floor((tick() - startTime) * 1000) / 1000
    
    print("✅ Scan complete!")
    print("   📊 Objects scanned: " .. destroyData.scanResults.totalScanned)
    print("   🐾 PetAreas found: " .. destroyData.scanResults.petAreasFound)
    print("   🏃 Treadmills found: " .. destroyData.scanResults.treadmillsFound)
    print("   ⏱️ Scan time: " .. scanTime .. "s")
    
    return destroyData.scanResults.petAreasFound + destroyData.scanResults.treadmillsFound
end

local function destroyPetAreas()
    print("💥 Destroying PetAreas...")
    local destroyed = 0
    
    for _, petArea in ipairs(destroyData.petAreas) do
        pcall(function()
            if petArea and petArea.Parent then
                if destroySettings.showDestroy then
                    print("🔥 Destroying PetArea: " .. petArea.Name)
                end
                petArea:Destroy()
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.petAreas = {} -- Clear the list
    print("✅ PetAreas destroyed: " .. destroyed)
    return destroyed
end

local function destroyTreadmills()
    print("💥 Destroying Treadmills...")
    local destroyed = 0
    
    for _, treadmill in ipairs(destroyData.treadmills) do
        pcall(function()
            if treadmill and treadmill.Parent then
                if destroySettings.showDestroy then
                    print("🔥 Destroying Treadmill: " .. treadmill.Name)
                end
                treadmill:Destroy()
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.treadmills = {} -- Clear the list
    print("✅ Treadmills destroyed: " .. destroyed)
    return destroyed
end
local function destroyAllTargets()
    print("🔥 STARTING MASS DESTRUCTION...")
    
    local totalFound = scanWorkspaceForTargets()
    
    if totalFound == 0 then
        print("⚠️ No PetAreas or Treadmills found to destroy!")
        return 0
    end
    
    local petDestroyed = destroyPetAreas()
    local treadmillDestroyed = destroyTreadmills()
    local totalDestroyed = petDestroyed + treadmillDestroyed
    
    print("🎉 DESTRUCTION COMPLETE!")
    print("==========================================")
    print("🐾 PetAreas destroyed: " .. petDestroyed)
    print("🏃 Treadmills destroyed: " .. treadmillDestroyed)
    print("💥 Total destroyed: " .. totalDestroyed)
    print("🚀 Performance should be improved!")
    print("==========================================")
    
    return totalDestroyed
end

-- ========================================================
-- GUI CREATION
-- ========================================================

local function createDestroyGUI()
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "PetAreaTreadmillDestroyer"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 280)
    mainFrame.Position = UDim2.new(1, -340, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    mainFrame.Parent = gui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix title bar corner
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "💥 DESTROYER"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Stats Frame
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(1, -20, 0, 100)
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    statsFrame.BorderSizePixel = 1
    statsFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    statsFrame.Parent = mainFrame
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 6)
    statsCorner.Parent = statsFrame
    
    -- Stats Labels
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, 0, 0, 25)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "📊 DESTRUCTION STATS"
    statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsTitle.TextSize = 14
    statsTitle.Font = Enum.Font.SourceSansBold
    statsTitle.Parent = statsFrame
    
    local petAreasLabel = Instance.new("TextLabel")
    petAreasLabel.Name = "PetAreasLabel"
    petAreasLabel.Size = UDim2.new(1, -10, 0, 20)
    petAreasLabel.Position = UDim2.new(0, 5, 0, 30)
    petAreasLabel.BackgroundTransparency = 1
    petAreasLabel.Text = "🐾 PetAreas Found: 0"
    petAreasLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    petAreasLabel.TextSize = 12
    petAreasLabel.Font = Enum.Font.SourceSans
    petAreasLabel.TextXAlignment = Enum.TextXAlignment.Left
    petAreasLabel.Parent = statsFrame
    
    local treadmillsLabel = Instance.new("TextLabel")
    treadmillsLabel.Name = "TreadmillsLabel"
    treadmillsLabel.Size = UDim2.new(1, -10, 0, 20)
    treadmillsLabel.Position = UDim2.new(0, 5, 0, 55)
    treadmillsLabel.BackgroundTransparency = 1
    treadmillsLabel.Text = "🏃 Treadmills Found: 0"
    treadmillsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    treadmillsLabel.TextSize = 12
    treadmillsLabel.Font = Enum.Font.SourceSans
    treadmillsLabel.TextXAlignment = Enum.TextXAlignment.Left
    treadmillsLabel.Parent = statsFrame
    
    local totalLabel = Instance.new("TextLabel")
    totalLabel.Name = "TotalLabel"
    totalLabel.Size = UDim2.new(1, -10, 0, 20)
    totalLabel.Position = UDim2.new(0, 5, 0, 75)
    totalLabel.BackgroundTransparency = 1
    totalLabel.Text = "💥 Total Destroyed: 0"
    totalLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    totalLabel.TextSize = 12
    totalLabel.Font = Enum.Font.SourceSans
    totalLabel.TextXAlignment = Enum.TextXAlignment.Left
    totalLabel.Parent = statsFrame
    -- Buttons Frame
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -20, 0, 100)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 160)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame
    
    -- Scan Button
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0.48, 0, 0, 35)
    scanButton.Position = UDim2.new(0, 0, 0, 0)
    scanButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    scanButton.Text = "🔍 SCAN"
    scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanButton.TextSize = 12
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.BorderSizePixel = 0
    scanButton.Parent = buttonsFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 6)
    scanCorner.Parent = scanButton
    
    -- Destroy All Button
    local destroyAllButton = Instance.new("TextButton")
    destroyAllButton.Name = "DestroyAllButton"
    destroyAllButton.Size = UDim2.new(0.48, 0, 0, 35)
    destroyAllButton.Position = UDim2.new(0.52, 0, 0, 0)
    destroyAllButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    destroyAllButton.Text = "💥 DESTROY ALL"
    destroyAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyAllButton.TextSize = 11
    destroyAllButton.Font = Enum.Font.SourceSansBold
    destroyAllButton.BorderSizePixel = 0
    destroyAllButton.Parent = buttonsFrame
    
    local destroyAllCorner = Instance.new("UICorner")
    destroyAllCorner.CornerRadius = UDim.new(0, 6)
    destroyAllCorner.Parent = destroyAllButton
    
    -- Destroy PetAreas Button
    local destroyPetButton = Instance.new("TextButton")
    destroyPetButton.Name = "DestroyPetButton"
    destroyPetButton.Size = UDim2.new(0.48, 0, 0, 30)
    destroyPetButton.Position = UDim2.new(0, 0, 0, 45)
    destroyPetButton.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
    destroyPetButton.Text = "🐾 DESTROY PETS"
    destroyPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyPetButton.TextSize = 10
    destroyPetButton.Font = Enum.Font.SourceSansBold
    destroyPetButton.BorderSizePixel = 0
    destroyPetButton.Parent = buttonsFrame
    
    local destroyPetCorner = Instance.new("UICorner")
    destroyPetCorner.CornerRadius = UDim.new(0, 6)
    destroyPetCorner.Parent = destroyPetButton
    
    -- Destroy Treadmills Button
    local destroyTreadButton = Instance.new("TextButton")
    destroyTreadButton.Name = "DestroyTreadButton"
    destroyTreadButton.Size = UDim2.new(0.48, 0, 0, 30)
    destroyTreadButton.Position = UDim2.new(0.52, 0, 0, 45)
    destroyTreadButton.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
    destroyTreadButton.Text = "🏃 DESTROY TREAD"
    destroyTreadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyTreadButton.TextSize = 10
    destroyTreadButton.Font = Enum.Font.SourceSansBold
    destroyTreadButton.BorderSizePixel = 0
    destroyTreadButton.Parent = buttonsFrame
    
    local destroyTreadCorner = Instance.new("UICorner")
    destroyTreadCorner.CornerRadius = UDim.new(0, 6)
    destroyTreadCorner.Parent = destroyTreadButton
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 1, -25)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Click SCAN to find targets"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = mainFrame
    
    -- ========================================================
    -- GUI BUTTON EVENTS
    -- ========================================================
    
    local function updateStats()
        petAreasLabel.Text = "🐾 PetAreas Found: " .. destroyData.scanResults.petAreasFound
        treadmillsLabel.Text = "🏃 Treadmills Found: " .. destroyData.scanResults.treadmillsFound
        totalLabel.Text = "💥 Total Destroyed: " .. destroyData.totalDestroyed
    end
    
    scanButton.MouseButton1Click:Connect(function()
        scanButton.Text = "⏳ SCANNING..."
        scanButton.BackgroundColor3 = Color3.fromRGB(150, 100, 150)
        statusLabel.Text = "🔍 Scanning workspace..."
        
        task.wait(0.1)
        local found = scanWorkspaceForTargets()
        updateStats()
        
        scanButton.Text = "🔍 SCAN"
        scanButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        statusLabel.Text = "✅ Scan complete - " .. found .. " targets found"
    end)
    
    destroyAllButton.MouseButton1Click:Connect(function()
        destroyAllButton.Text = "💀 DESTROYING..."
        destroyAllButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        statusLabel.Text = "💥 Destroying all targets..."
        
        task.wait(0.1)
        local destroyed = destroyAllTargets()
        updateStats()
        
        destroyAllButton.Text = "💥 DESTROY ALL"
        destroyAllButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        statusLabel.Text = "🎉 " .. destroyed .. " objects destroyed!"
    end)
    
    destroyPetButton.MouseButton1Click:Connect(function()
        if #destroyData.petAreas == 0 then
            statusLabel.Text = "⚠️ No PetAreas found - scan first!"
            return
        end
        
        destroyPetButton.Text = "💀 DESTROYING..."
        local destroyed = destroyPetAreas()
        updateStats()
        destroyPetButton.Text = "🐾 DESTROY PETS"
        statusLabel.Text = "🎯 " .. destroyed .. " PetAreas destroyed!"
    end)
    
    destroyTreadButton.MouseButton1Click:Connect(function()
        if #destroyData.treadmills == 0 then
            statusLabel.Text = "⚠️ No Treadmills found - scan first!"
            return
        end
        
        destroyTreadButton.Text = "💀 DESTROYING..."
        local destroyed = destroyTreadmills()
        updateStats()
        destroyTreadButton.Text = "🏃 DESTROY TREAD"
        statusLabel.Text = "🎯 " .. destroyed .. " Treadmills destroyed!"
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                         startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return gui, petAreasLabel, treadmillsLabel, totalLabel, statusLabel
end

-- ========================================================
-- AUTO CONTINUOUS DESTROYER (OPTIONAL)
-- ========================================================

local function startContinuousDestroyer()
    if not destroySettings.autoContinuous then return end
    
    print("🔄 Starting continuous destroyer...")
    
    local connection = RunService.Heartbeat:Connect(function()
        if not destroySettings.autoContinuous then return end
        
        -- Scan for new objects every few seconds
        task.wait(3)
        
        local newTargets = 0
        
        -- Quick scan for new PetAreas
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if isPetArea(obj) or isTreadmill(obj) then
                    if destroySettings.showDestroy then
                        print("🎯 Auto-destroying: " .. obj.Name)
                    end
                    obj:Destroy()
                    newTargets = newTargets + 1
                    destroyData.totalDestroyed = destroyData.totalDestroyed + 1
                end
            end)
        end
        
        if newTargets > 0 and destroySettings.showDestroy then
            print("🔄 Auto-destroyed " .. newTargets .. " new objects")
        end
    end)
    
    return connection
end

-- ========================================================
-- QUICK DESTROY FUNCTIONS (NO GUI)
-- ========================================================

local function quickDestroyAll()
    print("⚡ QUICK DESTROY MODE - NO GUI")
    local destroyed = destroyAllTargets()
    
    if destroyed > 0 then
        print("🎉 Quick destruction complete!")
        print("💥 " .. destroyed .. " objects eliminated!")
    else
        print("⚠️ No targets found to destroy")
    end
    
    return destroyed
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating PetArea & Treadmill Destroyer...")

-- Create GUI
local gui, petLabel, treadLabel, totalLabel, statusLabel = createDestroyGUI()

-- Auto-scan on startup if enabled
if destroySettings.scanOnStart then
    print("🔄 Auto-scanning on startup...")
    task.wait(1)
    local found = scanWorkspaceForTargets()
    if petLabel and treadLabel and totalLabel then
        petLabel.Text = "🐾 PetAreas Found: " .. destroyData.scanResults.petAreasFound
        treadLabel.Text = "🏃 Treadmills Found: " .. destroyData.scanResults.treadmillsFound
        totalLabel.Text = "💥 Total Destroyed: " .. destroyData.totalDestroyed
    end
    if statusLabel then
        statusLabel.Text = "🎯 Auto-scan found " .. found .. " targets"
    end
end

print("✅ PETAREA & TREADMILL DESTROYER READY!")
print("=========================================")
print("💥 Destroyer GUI loaded successfully")
print("🎯 Auto-scan found targets on startup")
print("🔍 Use SCAN to find PetAreas & Treadmills")
print("💀 Use DESTROY buttons to eliminate them")
print("=========================================")
print("📋 Target Detection:")
print("   🐾 PetArea, Pet_Area, petarea")
print("   🏃 Treadmill, TreadmillRender, treadmill_render")
print("=========================================")
print("💡 Features:")
print("   • Smart detection algorithms")
print("   • Selective destruction options")
print("   • Real-time statistics")
print("   • Performance optimization")
print("   • Draggable GUI interface")
print("=========================================")
print("⚡ Ready to boost your FPS!")

-- Export functions for manual use
getgenv().quickDestroyPetAreaTreadmill = quickDestroyAll
getgenv().scanPetAreaTreadmill = scanWorkspaceForTargets