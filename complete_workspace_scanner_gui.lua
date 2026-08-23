-- ========================================================
-- COMPLETE WORKSPACE SCANNER GUI - PROFESSIONAL
-- Advanced GUI with progress bar and live statistics
-- ========================================================

print("🖥️ LOADING COMPLETE WORKSPACE SCANNER GUI...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- SCANNER DATA & PROGRESS
-- ========================================================

local scanResults = {
    pets = {},
    eggs = {},
    effects = {},
    models = {},
    parts = {},
    scripts = {},
    guis = {},
    sounds = {},
    totalObjects = 0,
    processed = 0,
    scanTime = 0,
    hideScript = "",
    currentObject = ""
}

local scanProgress = {
    isScanning = false,
    totalToScan = 0,
    currentProgress = 0,
    currentObjectName = ""
}

-- ========================================================
-- ADVANCED SCANNER FUNCTIONS
-- ========================================================

local function categorizeObject(obj)
    local className = obj.ClassName
    local objName = obj.Name:lower()
    
    -- Categorize objects
    if objName:find("pet") or objName:find("companion") or objName:find("follow") then
        table.insert(scanResults.pets, {
            name = obj.Name,
            path = 'game:GetService("Workspace"):FindFirstChild("' .. obj.Name .. '")'
        })
    elseif objName:find("egg") and obj.Parent and obj.Parent.Name == "AreaEggSlotsClient" then
        table.insert(scanResults.eggs, {
            name = obj.Name,
            path = 'game:GetService("Workspace").AreaEggSlotsClient:FindFirstChild("' .. obj.Name .. '")'
        })
    elseif className == "Model" then
        table.insert(scanResults.models, obj)
    elseif className:find("Part") or className:find("Block") or className:find("Wedge") then
        table.insert(scanResults.parts, obj)
    elseif className:find("Script") then
        table.insert(scanResults.scripts, obj)
    elseif className:find("Gui") or className:find("Frame") or className:find("Label") or className:find("Button") then
        table.insert(scanResults.guis, obj)
    elseif className:find("Sound") or className:find("Music") then
        table.insert(scanResults.sounds, obj)
    elseif className:find("Particle") or className:find("Beam") or className:find("Trail") or 
           className:find("Fire") or className:find("Smoke") then
        table.insert(scanResults.effects, obj)
    end
end

local function scanWorkspaceComplete(progressCallback)
    print("🔍 Starting complete workspace scan...")
    local startTime = tick()
    
    -- Reset results
    scanResults = {
        pets = {}, eggs = {}, effects = {}, models = {}, parts = {},
        scripts = {}, guis = {}, sounds = {}, totalObjects = 0,
        processed = 0, scanTime = 0, hideScript = "", currentObject = ""
    }
    
    scanProgress.isScanning = true
    
    -- Get all objects to scan
    local allObjects = Workspace:GetDescendants()
    scanProgress.totalToScan = #allObjects
    
    -- Scan in batches to prevent freezing
    local batchSize = 25
    local currentBatch = 1
    
    local function processBatch()
        local startIdx = (currentBatch - 1) * batchSize + 1
        local endIdx = math.min(currentBatch * batchSize, #allObjects)
        
        for i = startIdx, endIdx do
            local obj = allObjects[i]
            
            pcall(function()
                scanResults.totalObjects = scanResults.totalObjects + 1
                scanResults.processed = scanResults.processed + 1
                scanResults.currentObject = obj.Name
                scanProgress.currentObjectName = obj.Name
                scanProgress.currentProgress = (scanResults.processed / scanProgress.totalToScan) * 100
                
                categorizeObject(obj)
                
                -- Update progress callback
                if progressCallback then
                    progressCallback(scanProgress.currentProgress, scanProgress.currentObjectName, scanResults)
                end
            end)
        end
        
        currentBatch = currentBatch + 1
        
        -- Continue processing or finish
        if endIdx < #allObjects then
            task.wait() -- Yield to prevent freezing
            processBatch()
        else
            -- Scan complete
            scanProgress.isScanning = false
            scanResults.scanTime = math.floor((tick() - startTime) * 1000) / 1000
            generateHideScript()
            
            print("✅ Complete scan finished!")
            print("   🐾 Pets: " .. #scanResults.pets)
            print("   🥚 Eggs: " .. #scanResults.eggs)
            print("   ✨ Effects: " .. #scanResults.effects)
            print("   📦 Models: " .. #scanResults.models)
            print("   🧱 Parts: " .. #scanResults.parts)
            print("   📜 Scripts: " .. #scanResults.scripts)
            print("   🖥️ GUIs: " .. #scanResults.guis)
            print("   🔊 Sounds: " .. #scanResults.sounds)
            print("   📊 Total: " .. scanResults.totalObjects)
            print("   ⏱️  Time: " .. scanResults.scanTime .. "s")
            
            if progressCallback then
                progressCallback(100, "Scan Complete!", scanResults)
            end
        end
    end
    
    -- Start batch processing
    processBatch()
end

local function generateHideScript()
    local script = [[-- ========================================================
-- AUTO-GENERATED COMPLETE HIDE SCRIPT
-- Generated by Complete Workspace Scanner
-- ========================================================

print("🚀 Executing complete hide script...")

local hidden = {pets = 0, eggs = 0, effects = 0, models = 0, parts = 0}

-- HIDE PETS
]]

    -- Add pet hiding
    for _, pet in ipairs(scanResults.pets) do
        script = script .. 'pcall(function() ' .. pet.path .. '.Parent = nil; hidden.pets = hidden.pets + 1 end)\n'
    end
    
    script = script .. [[

-- HIDE EGGS (KEEP HITBOXES)
local areaEggs = game:GetService("Workspace").AreaEggSlotsClient
if areaEggs then
    for _, eggModel in pairs(areaEggs:GetChildren()) do
        pcall(function()
            if eggModel:IsA("Model") then
                for _, part in pairs(eggModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local partName = part.Name:lower()
                        if partName:find("hitbox") or partName:find("hit") then
                            part.Transparency = 1 -- Keep functional
                        else
                            part.Transparency = 1
                            part.CanCollide = false
                            part.CastShadow = false
                        end
                    elseif part:IsA("ParticleEmitter") or part:IsA("Beam") then
                        part.Enabled = false
                    end
                end
                hidden.eggs = hidden.eggs + 1
            end
        end)
    end
end

-- HIDE EFFECTS AND OPTIMIZE PERFORMANCE
for _, obj in pairs(game.Workspace:GetDescendants()) do
    pcall(function()
        -- Hide effects
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or 
           obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
            hidden.effects = hidden.effects + 1
        
        -- Optimize parts
        elseif obj:IsA("BasePart") and not obj.Name:lower():find("hitbox") then
            obj.CastShadow = false
            if obj.Material ~= Enum.Material.Air then
                obj.Material = Enum.Material.Plastic
            end
            hidden.parts = hidden.parts + 1
        
        -- Optimize models  
        elseif obj:IsA("Model") and obj.Name:lower():find("decoration") then
            obj.Parent = nil
            hidden.models = hidden.models + 1
        end
    end)
end

-- RESULTS
print("✅ COMPLETE HIDE SCRIPT FINISHED!")
print("==================================")
print("🐾 Pets hidden: " .. hidden.pets)
print("🥚 Eggs hidden: " .. hidden.eggs .. " (hitboxes preserved)")
print("✨ Effects disabled: " .. hidden.effects)
print("🧱 Parts optimized: " .. hidden.parts)
print("📦 Models removed: " .. hidden.models)
print("🎯 Maximum performance achieved!")
]]

    scanResults.hideScript = script
end

local function copyToClipboard()
    if not scanResults.hideScript or scanResults.hideScript == "" then
        print("❌ No script to copy! Please scan first.")
        return false
    end
    
    local success = false
    pcall(function()
        if setclipboard then
            setclipboard(scanResults.hideScript)
            success = true
        elseif toclipboard then
            toclipboard(scanResults.hideScript)
            success = true
        elseif writeclipboard then
            writeclipboard(scanResults.hideScript)
            success = true
        end
    end)
    
    if success then
        print("📋 Complete script copied to clipboard!")
        return true
    else
        print("❌ Clipboard not available!")
        return false
    end
end

-- ========================================================
-- ADVANCED GUI CREATION
-- ========================================================

local function createAdvancedGUI()
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CompleteWorkspaceScannerGUI"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    mainFrame.Parent = gui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix title bar corner (only top)
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🔍 COMPLETE WORKSPACE SCANNER"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -35, 0, 7.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Progress Section
    local progressFrame = Instance.new("Frame")
    progressFrame.Name = "ProgressFrame"
    progressFrame.Size = UDim2.new(1, -20, 0, 50)
    progressFrame.Position = UDim2.new(0, 10, 0, 50)
    progressFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    progressFrame.BorderSizePixel = 1
    progressFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    progressFrame.Parent = mainFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 6)
    progressCorner.Parent = progressFrame
    
    -- Progress Label
    local progressLabel = Instance.new("TextLabel")
    progressLabel.Name = "ProgressLabel"
    progressLabel.Size = UDim2.new(1, -10, 0, 20)
    progressLabel.Position = UDim2.new(0, 5, 0, 5)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Text = "Progress: 0% (0/0) - Ready to scan..."
    progressLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    progressLabel.TextSize = 12
    progressLabel.Font = Enum.Font.SourceSans
    progressLabel.TextXAlignment = Enum.TextXAlignment.Left
    progressLabel.Parent = progressFrame
    
    -- Progress Bar Background
    local progressBG = Instance.new("Frame")
    progressBG.Name = "ProgressBG"
    progressBG.Size = UDim2.new(1, -10, 0, 8)
    progressBG.Position = UDim2.new(0, 5, 0, 30)
    progressBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    progressBG.BorderSizePixel = 0
    progressBG.Parent = progressFrame
    
    local progressBGCorner = Instance.new("UICorner")
    progressBGCorner.CornerRadius = UDim.new(0, 4)
    progressBGCorner.Parent = progressBG
    
    -- Progress Bar Fill
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBG
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(0, 4)
    progressFillCorner.Parent = progressFill
    
    -- Stats Section
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(1, -20, 0, 180)
    statsFrame.Position = UDim2.new(0, 10, 0, 110)
    statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    statsFrame.BorderSizePixel = 1
    statsFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    statsFrame.Parent = mainFrame
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 6)
    statsCorner.Parent = statsFrame
    
    -- Stats Title
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, 0, 0, 25)
    statsTitle.Position = UDim2.new(0, 0, 0, 5)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "📊 SCAN RESULTS (LIVE)"
    statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsTitle.TextSize = 14
    statsTitle.Font = Enum.Font.SourceSansBold
    statsTitle.Parent = statsFrame
    
    -- Create stats labels in grid
    local statsLabels = {}
    local statsData = {
        {name = "Pets", icon = "🐾", color = Color3.fromRGB(255, 200, 100)},
        {name = "Eggs", icon = "🥚", color = Color3.fromRGB(100, 255, 100)},
        {name = "Effects", icon = "✨", color = Color3.fromRGB(255, 100, 255)},
        {name = "Models", icon = "📦", color = Color3.fromRGB(100, 200, 255)},
        {name = "Parts", icon = "🧱", color = Color3.fromRGB(200, 150, 100)},
        {name = "Scripts", icon = "📜", color = Color3.fromRGB(255, 150, 150)},
        {name = "GUIs", icon = "🖥️", color = Color3.fromRGB(150, 255, 150)},
        {name = "Sounds", icon = "🔊", color = Color3.fromRGB(150, 200, 255)}
    }
    
    for i, data in ipairs(statsData) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        
        local label = Instance.new("TextLabel")
        label.Name = data.name .. "Label"
        label.Size = UDim2.new(0.48, 0, 0, 20)
        label.Position = UDim2.new(col * 0.51, 10, 0, 35 + row * 25)
        label.BackgroundTransparency = 1
        label.Text = data.icon .. " " .. data.name .. ": 0"
        label.TextColor3 = data.color
        label.TextSize = 12
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = statsFrame
        
        statsLabels[data.name:lower()] = label
    end
    
    -- Buttons Section
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -20, 0, 50)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 300)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame
    
    -- Scan Button
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0.48, 0, 0, 35)
    scanButton.Position = UDim2.new(0, 0, 0, 0)
    scanButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    scanButton.Text = "🔍 SCAN EVERYTHING"
    scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanButton.TextSize = 14
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.BorderSizePixel = 0
    scanButton.Parent = buttonsFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 6)
    scanCorner.Parent = scanButton
    
    -- Copy Button
    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyButton"
    copyButton.Size = UDim2.new(0.48, 0, 0, 35)
    copyButton.Position = UDim2.new(0.52, 0, 0, 0)
    copyButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    copyButton.Text = "📋 COPY SCRIPT"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.TextSize = 14
    copyButton.Font = Enum.Font.SourceSansBold
    copyButton.BorderSizePixel = 0
    copyButton.Parent = buttonsFrame
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 6)
    copyCorner.Parent = copyButton
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 360)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Click SCAN EVERYTHING to analyze complete workspace"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = mainFrame
    
    -- ========================================================
    -- GUI FUNCTIONS
    -- ========================================================
    
    local function updateProgress(progress, currentObj, results)
        -- Update progress label and bar
        progressLabel.Text = string.format("Progress: %d%% (%d/%d) - %s...", 
            math.floor(progress), results.processed, scanProgress.totalToScan, currentObj:sub(1, 20))
        
        -- Animate progress bar
        local targetSize = UDim2.new(progress / 100, 0, 1, 0)
        TweenService:Create(progressFill, TweenInfo.new(0.1), {Size = targetSize}):Play()
        
        -- Update stats
        statsLabels.pets.Text = "🐾 Pets: " .. #results.pets
        statsLabels.eggs.Text = "🥚 Eggs: " .. #results.eggs
        statsLabels.effects.Text = "✨ Effects: " .. #results.effects
        statsLabels.models.Text = "📦 Models: " .. #results.models
        statsLabels.parts.Text = "🧱 Parts: " .. #results.parts
        statsLabels.scripts.Text = "📜 Scripts: " .. #results.scripts
        statsLabels.guis.Text = "🖥️ GUIs: " .. #results.guis
        statsLabels.sounds.Text = "🔊 Sounds: " .. #results.sounds
    end
    
    scanButton.MouseButton1Click:Connect(function()
        if scanProgress.isScanning then
            print("⚠️ Scan already in progress!")
            return
        end
        
        -- Reset progress
        progressLabel.Text = "Progress: 0% (0/0) - Initializing..."
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        
        -- Update button
        scanButton.Text = "⏳ SCANNING..."
        scanButton.BackgroundColor3 = Color3.fromRGB(200, 150, 80)
        statusLabel.Text = "🔍 Complete workspace scan in progress..."
        
        -- Start scan
        task.spawn(function()
            scanWorkspaceComplete(updateProgress)
            
            -- Scan complete
            scanButton.Text = "🔍 SCAN EVERYTHING"
            scanButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            statusLabel.Text = "✅ Complete scan finished! Ready to copy advanced script."
            progressLabel.Text = string.format("Progress: 100%% (%d/%d) - Scan Complete!", 
                scanResults.totalObjects, scanProgress.totalToScan)
        end)
    end)
    
    copyButton.MouseButton1Click:Connect(function()
        if copyToClipboard() then
            statusLabel.Text = "📋 Advanced hide script copied! Paste and execute for maximum optimization."
            copyButton.Text = "✅ COPIED!"
            copyButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
            task.wait(2)
            copyButton.Text = "📋 COPY SCRIPT"
            copyButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        else
            statusLabel.Text = "❌ Copy failed! Clipboard not available on this executor."
        end
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
    
    print("✅ Advanced GUI loaded successfully!")
    return gui
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating Complete Workspace Scanner GUI...")
local gui = createAdvancedGUI()

print("✅ COMPLETE WORKSPACE SCANNER GUI READY!")
print("=========================================")
print("🖥️ Advanced GUI with live progress tracking")
print("📊 Detailed statistics for all object types")
print("🔍 Complete workspace analysis capability")
print("📋 Advanced hide script generation")
print("⚡ Optimized scanning with progress feedback")
print("=========================================")
print("🎯 Professional workspace scanning tool!")