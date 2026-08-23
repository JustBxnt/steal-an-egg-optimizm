-- ========================================================
-- DESTROY ALL EGG POINTS - PERFORMANCE BOOST
-- Script untuk menghancurkan semua egg point di workspace
-- ========================================================

print("🥚 LOADING DESTROY ALL EGG POINTS...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- EGG POINT DESTROYER DATA & SETTINGS
-- ========================================================

local destroyData = {
    eggPoints = {},
    eggSlots = {},
    eggAreas = {},
    eggSpawns = {},
    totalDestroyed = 0,
    scanResults = {
        eggPointsFound = 0,
        eggSlotsFound = 0,
        eggAreasFound = 0,
        eggSpawnsFound = 0,
        totalScanned = 0
    }
}

local destroySettings = {
    destroyEggPoints = true,       -- Hancurkan EggPoint objects
    destroyEggSlots = true,        -- Hancurkan AreaEggSlots
    destroyEggAreas = true,        -- Hancurkan EggArea objects
    destroyEggSpawns = true,       -- Hancurkan egg spawn points
    preserveHitboxes = false,      -- Jangan preserve hitbox (destroy semua)
    showDestruction = true,        -- Tampilkan proses destruksi
    continuousMode = false,        -- Mode continuous destroyer
    deepScan = true               -- Scan lebih dalam
}

-- ========================================================
-- EGG POINT DETECTION FUNCTIONS
-- ========================================================

local function isEggPoint(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    local className = obj.ClassName
    
    -- EggPoint detection patterns
    local eggPointPatterns = {
        "eggpoint", "egg_point", "egg point", "eggslot", "egg_slot", "egg slot",
        "eggarea", "egg_area", "egg area", "eggspawn", "egg_spawn", "egg spawn",
        "egglocation", "egg_location", "egg location"
    }
    
    -- Check name patterns
    for _, pattern in ipairs(eggPointPatterns) do
        if name:find(pattern) then
            return true
        end
    end
    
    -- Check if parent has egg-related names
    if obj.Parent then
        local parentName = obj.Parent.Name:lower()
        if parentName:find("egg") and (parentName:find("slot") or parentName:find("area") or parentName:find("point")) then
            return true
        end
    end
    
    -- Check for specific egg point characteristics
    if className == "Model" or className == "Part" or className == "MeshPart" then
        -- Check for egg-shaped objects or specific sizes
        if className == "Part" or className == "MeshPart" then
            local size = obj.Size
            -- Common egg point sizes (usually small and egg-shaped)
            if size.Y > size.X and size.Y > size.Z and size.Y < 10 then
                if name:find("egg") then
                    return true
                end
            end
        end
        
        -- Check children for egg indicators
        for _, child in pairs(obj:GetChildren()) do
            local childName = child.Name:lower()
            if childName:find("egg") and (childName:find("point") or childName:find("slot") or childName:find("area")) then
                return true
            end
        end
    end
    
    return false
end

local function isAreaEggSlot(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    local parentName = obj.Parent and obj.Parent.Name:lower() or ""
    
    -- Check for AreaEggSlots or similar structures
    if parentName:find("areaeggslot") or parentName:find("area_egg_slot") or 
       parentName == "areaeggslotsclient" or parentName == "areaeggslots" then
        return true
    end
    
    if name:find("areaeggslot") or name:find("area_egg_slot") then
        return true
    end
    
    return false
end

local function isEggArea(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    
    -- Egg area patterns
    local eggAreaPatterns = {
        "eggarea", "egg_area", "area.*egg", "egg.*area",
        "spawneggs", "spawn_eggs", "eggzone", "egg_zone"
    }
    
    for _, pattern in ipairs(eggAreaPatterns) do
        if name:match(pattern) then
            return true
        end
    end
    
    return false
end

local function categorizeEggObject(obj)
    local name = obj.Name:lower()
    
    if isAreaEggSlot(obj) then
        return "eggSlots"
    elseif isEggArea(obj) then
        return "eggAreas"  
    elseif name:find("spawn") then
        return "eggSpawns"
    else
        return "eggPoints"
    end
end
-- ========================================================
-- SCAN & DESTROY FUNCTIONS
-- ========================================================

local function scanWorkspaceForEggPoints()
    print("🔍 Scanning workspace for egg points...")
    
    -- Reset scan results
    destroyData.scanResults = {
        eggPointsFound = 0,
        eggSlotsFound = 0, 
        eggAreasFound = 0,
        eggSpawnsFound = 0,
        totalScanned = 0
    }
    
    -- Clear previous data
    destroyData.eggPoints = {}
    destroyData.eggSlots = {}
    destroyData.eggAreas = {}
    destroyData.eggSpawns = {}
    
    local startTime = tick()
    
    -- Scan all workspace descendants
    for _, obj in pairs(Workspace:GetDescendants()) do
        destroyData.scanResults.totalScanned = destroyData.scanResults.totalScanned + 1
        
        pcall(function()
            if isEggPoint(obj) or isAreaEggSlot(obj) or isEggArea(obj) then
                local category = categorizeEggObject(obj)
                
                if category == "eggPoints" then
                    table.insert(destroyData.eggPoints, obj)
                    destroyData.scanResults.eggPointsFound = destroyData.scanResults.eggPointsFound + 1
                    if destroySettings.showDestruction then
                        print("🎯 Found EggPoint: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    end
                    
                elseif category == "eggSlots" then
                    table.insert(destroyData.eggSlots, obj)
                    destroyData.scanResults.eggSlotsFound = destroyData.scanResults.eggSlotsFound + 1
                    if destroySettings.showDestruction then
                        print("🎯 Found EggSlot: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    end
                    
                elseif category == "eggAreas" then
                    table.insert(destroyData.eggAreas, obj)
                    destroyData.scanResults.eggAreasFound = destroyData.scanResults.eggAreasFound + 1
                    if destroySettings.showDestruction then
                        print("🎯 Found EggArea: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    end
                    
                elseif category == "eggSpawns" then
                    table.insert(destroyData.eggSpawns, obj)
                    destroyData.scanResults.eggSpawnsFound = destroyData.scanResults.eggSpawnsFound + 1
                    if destroySettings.showDestruction then
                        print("🎯 Found EggSpawn: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    end
                end
            end
        end)
    end
    
    -- Special scan for AreaEggSlotsClient
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if areaEggs then
        for _, eggModel in pairs(areaEggs:GetChildren()) do
            pcall(function()
                table.insert(destroyData.eggSlots, eggModel)
                destroyData.scanResults.eggSlotsFound = destroyData.scanResults.eggSlotsFound + 1
                if destroySettings.showDestruction then
                    print("🎯 Found AreaEggSlot: " .. eggModel.Name)
                end
            end)
        end
    end
    
    local scanTime = math.floor((tick() - startTime) * 1000) / 1000
    
    print("✅ Egg Point scan complete!")
    print("   📊 Objects scanned: " .. destroyData.scanResults.totalScanned)
    print("   🥚 EggPoints found: " .. destroyData.scanResults.eggPointsFound)
    print("   🎰 EggSlots found: " .. destroyData.scanResults.eggSlotsFound)
    print("   📍 EggAreas found: " .. destroyData.scanResults.eggAreasFound)
    print("   🌟 EggSpawns found: " .. destroyData.scanResults.eggSpawnsFound)
    print("   ⏱️ Scan time: " .. scanTime .. "s")
    
    local totalFound = destroyData.scanResults.eggPointsFound + destroyData.scanResults.eggSlotsFound + 
                      destroyData.scanResults.eggAreasFound + destroyData.scanResults.eggSpawnsFound
    
    return totalFound
end

local function destroyEggPoints()
    print("💥 Destroying EggPoints...")
    local destroyed = 0
    
    for _, eggPoint in ipairs(destroyData.eggPoints) do
        pcall(function()
            if eggPoint and eggPoint.Parent then
                if destroySettings.showDestruction then
                    print("🔥 Destroying EggPoint: " .. eggPoint.Name)
                end
                eggPoint:Destroy()
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.eggPoints = {}
    print("✅ EggPoints destroyed: " .. destroyed)
    return destroyed
end

local function destroyEggSlots()
    print("💥 Destroying EggSlots...")
    local destroyed = 0
    
    for _, eggSlot in ipairs(destroyData.eggSlots) do
        pcall(function()
            if eggSlot and eggSlot.Parent then
                if destroySettings.showDestruction then
                    print("🔥 Destroying EggSlot: " .. eggSlot.Name)
                end
                
                if destroySettings.preserveHitboxes then
                    -- Hide but preserve functionality
                    for _, part in pairs(eggSlot:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local partName = part.Name:lower()
                            if partName:find("hitbox") or partName:find("hit") then
                                part.Transparency = 1
                            else
                                part.Transparency = 1
                                part.CanCollide = false
                                part.CastShadow = false
                            end
                        elseif part:IsA("ParticleEmitter") or part:IsA("Beam") then
                            part.Enabled = false
                        end
                    end
                else
                    -- Complete destruction
                    eggSlot:Destroy()
                end
                
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.eggSlots = {}
    print("✅ EggSlots destroyed: " .. destroyed)
    return destroyed
end

local function destroyEggAreas()
    print("💥 Destroying EggAreas...")
    local destroyed = 0
    
    for _, eggArea in ipairs(destroyData.eggAreas) do
        pcall(function()
            if eggArea and eggArea.Parent then
                if destroySettings.showDestruction then
                    print("🔥 Destroying EggArea: " .. eggArea.Name)
                end
                eggArea:Destroy()
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.eggAreas = {}
    print("✅ EggAreas destroyed: " .. destroyed)
    return destroyed
end

local function destroyEggSpawns()
    print("💥 Destroying EggSpawns...")
    local destroyed = 0
    
    for _, eggSpawn in ipairs(destroyData.eggSpawns) do
        pcall(function()
            if eggSpawn and eggSpawn.Parent then
                if destroySettings.showDestruction then
                    print("🔥 Destroying EggSpawn: " .. eggSpawn.Name)
                end
                eggSpawn:Destroy()
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.eggSpawns = {}
    print("✅ EggSpawns destroyed: " .. destroyed)
    return destroyed
end
local function destroyAllEggPoints()
    print("🔥 STARTING COMPLETE EGG POINT DESTRUCTION...")
    
    local totalFound = scanWorkspaceForEggPoints()
    
    if totalFound == 0 then
        print("⚠️ No egg points found to destroy!")
        return 0
    end
    
    local eggPointsDestroyed = destroySettings.destroyEggPoints and destroyEggPoints() or 0
    local eggSlotsDestroyed = destroySettings.destroyEggSlots and destroyEggSlots() or 0
    local eggAreasDestroyed = destroySettings.destroyEggAreas and destroyEggAreas() or 0
    local eggSpawnsDestroyed = destroySettings.destroyEggSpawns and destroyEggSpawns() or 0
    
    local totalDestroyed = eggPointsDestroyed + eggSlotsDestroyed + eggAreasDestroyed + eggSpawnsDestroyed
    
    print("🎉 EGG POINT DESTRUCTION COMPLETE!")
    print("==========================================")
    print("🥚 EggPoints destroyed: " .. eggPointsDestroyed)
    print("🎰 EggSlots destroyed: " .. eggSlotsDestroyed)
    print("📍 EggAreas destroyed: " .. eggAreasDestroyed)
    print("🌟 EggSpawns destroyed: " .. eggSpawnsDestroyed)
    print("💥 Total destroyed: " .. totalDestroyed)
    print("==========================================")
    
    if totalDestroyed > 0 then
        print("🚀 Performance should be significantly improved!")
        print("🎯 Egg collection mechanics removed!")
    else
        print("⚠️ No objects were destroyed")
    end
    
    return totalDestroyed
end

-- ========================================================
-- GUI CREATION
-- ========================================================

local function createEggPointDestroyGUI()
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "EggPointDestroyer"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 320)
    mainFrame.Position = UDim2.new(1, -370, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix title bar corner
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🥚 EGG DESTROYER"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
    statsFrame.Size = UDim2.new(1, -20, 0, 120)
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    statsFrame.BorderSizePixel = 1
    statsFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    statsFrame.Parent = mainFrame
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 6)
    statsCorner.Parent = statsFrame
    
    -- Stats Title
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, 0, 0, 25)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "📊 EGG DESTRUCTION STATS"
    statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsTitle.TextSize = 14
    statsTitle.Font = Enum.Font.SourceSansBold
    statsTitle.Parent = statsFrame
    -- Stats Labels
    local eggPointsLabel = Instance.new("TextLabel")
    eggPointsLabel.Name = "EggPointsLabel"
    eggPointsLabel.Size = UDim2.new(0.5, -5, 0, 20)
    eggPointsLabel.Position = UDim2.new(0, 5, 0, 30)
    eggPointsLabel.BackgroundTransparency = 1
    eggPointsLabel.Text = "🥚 EggPoints: 0"
    eggPointsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    eggPointsLabel.TextSize = 12
    eggPointsLabel.Font = Enum.Font.SourceSans
    eggPointsLabel.TextXAlignment = Enum.TextXAlignment.Left
    eggPointsLabel.Parent = statsFrame
    
    local eggSlotsLabel = Instance.new("TextLabel")
    eggSlotsLabel.Name = "EggSlotsLabel"
    eggSlotsLabel.Size = UDim2.new(0.5, -5, 0, 20)
    eggSlotsLabel.Position = UDim2.new(0.5, 5, 0, 30)
    eggSlotsLabel.BackgroundTransparency = 1
    eggSlotsLabel.Text = "🎰 EggSlots: 0"
    eggSlotsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    eggSlotsLabel.TextSize = 12
    eggSlotsLabel.Font = Enum.Font.SourceSans
    eggSlotsLabel.TextXAlignment = Enum.TextXAlignment.Left
    eggSlotsLabel.Parent = statsFrame
    
    local eggAreasLabel = Instance.new("TextLabel")
    eggAreasLabel.Name = "EggAreasLabel"
    eggAreasLabel.Size = UDim2.new(0.5, -5, 0, 20)
    eggAreasLabel.Position = UDim2.new(0, 5, 0, 55)
    eggAreasLabel.BackgroundTransparency = 1
    eggAreasLabel.Text = "📍 EggAreas: 0"
    eggAreasLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    eggAreasLabel.TextSize = 12
    eggAreasLabel.Font = Enum.Font.SourceSans
    eggAreasLabel.TextXAlignment = Enum.TextXAlignment.Left
    eggAreasLabel.Parent = statsFrame
    
    local eggSpawnsLabel = Instance.new("TextLabel")
    eggSpawnsLabel.Name = "EggSpawnsLabel"
    eggSpawnsLabel.Size = UDim2.new(0.5, -5, 0, 20)
    eggSpawnsLabel.Position = UDim2.new(0.5, 5, 0, 55)
    eggSpawnsLabel.BackgroundTransparency = 1
    eggSpawnsLabel.Text = "🌟 EggSpawns: 0"
    eggSpawnsLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
    eggSpawnsLabel.TextSize = 12
    eggSpawnsLabel.Font = Enum.Font.SourceSans
    eggSpawnsLabel.TextXAlignment = Enum.TextXAlignment.Left
    eggSpawnsLabel.Parent = statsFrame
    
    local totalLabel = Instance.new("TextLabel")
    totalLabel.Name = "TotalLabel"
    totalLabel.Size = UDim2.new(1, -10, 0, 20)
    totalLabel.Position = UDim2.new(0, 5, 0, 85)
    totalLabel.BackgroundTransparency = 1
    totalLabel.Text = "💥 Total Destroyed: 0"
    totalLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    totalLabel.TextSize = 13
    totalLabel.Font = Enum.Font.SourceSansBold
    totalLabel.TextXAlignment = Enum.TextXAlignment.Left
    totalLabel.Parent = statsFrame
    
    -- Buttons Frame
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -20, 0, 120)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 180)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame
    
    -- Scan Button
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0.48, 0, 0, 35)
    scanButton.Position = UDim2.new(0, 0, 0, 0)
    scanButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    scanButton.Text = "🔍 SCAN EGGS"
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
    -- Individual destroy buttons
    local destroyPointsButton = Instance.new("TextButton")
    destroyPointsButton.Name = "DestroyPointsButton"
    destroyPointsButton.Size = UDim2.new(0.48, 0, 0, 30)
    destroyPointsButton.Position = UDim2.new(0, 0, 0, 45)
    destroyPointsButton.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
    destroyPointsButton.Text = "🥚 DESTROY POINTS"
    destroyPointsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyPointsButton.TextSize = 10
    destroyPointsButton.Font = Enum.Font.SourceSansBold
    destroyPointsButton.BorderSizePixel = 0
    destroyPointsButton.Parent = buttonsFrame
    
    local destroyPointsCorner = Instance.new("UICorner")
    destroyPointsCorner.CornerRadius = UDim.new(0, 6)
    destroyPointsCorner.Parent = destroyPointsButton
    
    local destroySlotsButton = Instance.new("TextButton")
    destroySlotsButton.Name = "DestroySlotsButton"
    destroySlotsButton.Size = UDim2.new(0.48, 0, 0, 30)
    destroySlotsButton.Position = UDim2.new(0.52, 0, 0, 45)
    destroySlotsButton.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
    destroySlotsButton.Text = "🎰 DESTROY SLOTS"
    destroySlotsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroySlotsButton.TextSize = 10
    destroySlotsButton.Font = Enum.Font.SourceSansBold
    destroySlotsButton.BorderSizePixel = 0
    destroySlotsButton.Parent = buttonsFrame
    
    local destroySlotsCorner = Instance.new("UICorner")
    destroySlotsCorner.CornerRadius = UDim.new(0, 6)
    destroySlotsCorner.Parent = destroySlotsButton
    
    local destroyAreasButton = Instance.new("TextButton")
    destroyAreasButton.Name = "DestroyAreasButton"
    destroyAreasButton.Size = UDim2.new(0.48, 0, 0, 30)
    destroyAreasButton.Position = UDim2.new(0, 0, 0, 85)
    destroyAreasButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    destroyAreasButton.Text = "📍 DESTROY AREAS"
    destroyAreasButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyAreasButton.TextSize = 10
    destroyAreasButton.Font = Enum.Font.SourceSansBold
    destroyAreasButton.BorderSizePixel = 0
    destroyAreasButton.Parent = buttonsFrame
    
    local destroyAreasCorner = Instance.new("UICorner")
    destroyAreasCorner.CornerRadius = UDim.new(0, 6)
    destroyAreasCorner.Parent = destroyAreasButton
    
    local destroySpawnsButton = Instance.new("TextButton")
    destroySpawnsButton.Name = "DestroySpawnsButton"
    destroySpawnsButton.Size = UDim2.new(0.48, 0, 0, 30)
    destroySpawnsButton.Position = UDim2.new(0.52, 0, 0, 85)
    destroySpawnsButton.BackgroundColor3 = Color3.fromRGB(150, 50, 100)
    destroySpawnsButton.Text = "🌟 DESTROY SPAWNS"
    destroySpawnsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroySpawnsButton.TextSize = 10
    destroySpawnsButton.Font = Enum.Font.SourceSansBold
    destroySpawnsButton.BorderSizePixel = 0
    destroySpawnsButton.Parent = buttonsFrame
    
    local destroySpawnsCorner = Instance.new("UICorner")
    destroySpawnsCorner.CornerRadius = UDim.new(0, 6)
    destroySpawnsCorner.Parent = destroySpawnsButton
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 1, -25)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Click SCAN to find egg points"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = mainFrame
    
    -- ========================================================
    -- GUI BUTTON EVENTS
    -- ========================================================
    
    local function updateStats()
        eggPointsLabel.Text = "🥚 EggPoints: " .. destroyData.scanResults.eggPointsFound
        eggSlotsLabel.Text = "🎰 EggSlots: " .. destroyData.scanResults.eggSlotsFound
        eggAreasLabel.Text = "📍 EggAreas: " .. destroyData.scanResults.eggAreasFound
        eggSpawnsLabel.Text = "🌟 EggSpawns: " .. destroyData.scanResults.eggSpawnsFound
        totalLabel.Text = "💥 Total Destroyed: " .. destroyData.totalDestroyed
    end
    
    scanButton.MouseButton1Click:Connect(function()
        scanButton.Text = "⏳ SCANNING..."
        scanButton.BackgroundColor3 = Color3.fromRGB(150, 100, 150)
        statusLabel.Text = "🔍 Scanning workspace for egg points..."
        
        task.wait(0.1)
        local found = scanWorkspaceForEggPoints()
        updateStats()
        
        scanButton.Text = "🔍 SCAN EGGS"
        scanButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        statusLabel.Text = "✅ Scan complete - " .. found .. " egg objects found"
    end)
    
    destroyAllButton.MouseButton1Click:Connect(function()
        destroyAllButton.Text = "💀 DESTROYING..."
        destroyAllButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        statusLabel.Text = "💥 Destroying all egg points..."
        
        task.wait(0.1)
        local destroyed = destroyAllEggPoints()
        updateStats()
        
        destroyAllButton.Text = "💥 DESTROY ALL"
        destroyAllButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        statusLabel.Text = "🎉 " .. destroyed .. " egg objects destroyed!"
    end)
    destroyPointsButton.MouseButton1Click:Connect(function()
        if #destroyData.eggPoints == 0 then
            statusLabel.Text = "⚠️ No EggPoints found - scan first!"
            return
        end
        
        destroyPointsButton.Text = "💀 DESTROYING..."
        local destroyed = destroyEggPoints()
        updateStats()
        destroyPointsButton.Text = "🥚 DESTROY POINTS"
        statusLabel.Text = "🎯 " .. destroyed .. " EggPoints destroyed!"
    end)
    
    destroySlotsButton.MouseButton1Click:Connect(function()
        if #destroyData.eggSlots == 0 then
            statusLabel.Text = "⚠️ No EggSlots found - scan first!"
            return
        end
        
        destroySlotsButton.Text = "💀 DESTROYING..."
        local destroyed = destroyEggSlots()
        updateStats()
        destroySlotsButton.Text = "🎰 DESTROY SLOTS"
        statusLabel.Text = "🎯 " .. destroyed .. " EggSlots destroyed!"
    end)
    
    destroyAreasButton.MouseButton1Click:Connect(function()
        if #destroyData.eggAreas == 0 then
            statusLabel.Text = "⚠️ No EggAreas found - scan first!"
            return
        end
        
        destroyAreasButton.Text = "💀 DESTROYING..."
        local destroyed = destroyEggAreas()
        updateStats()
        destroyAreasButton.Text = "📍 DESTROY AREAS"
        statusLabel.Text = "🎯 " .. destroyed .. " EggAreas destroyed!"
    end)
    
    destroySpawnsButton.MouseButton1Click:Connect(function()
        if #destroyData.eggSpawns == 0 then
            statusLabel.Text = "⚠️ No EggSpawns found - scan first!"
            return
        end
        
        destroySpawnsButton.Text = "💀 DESTROYING..."
        local destroyed = destroyEggSpawns()
        updateStats()
        destroySpawnsButton.Text = "🌟 DESTROY SPAWNS"
        statusLabel.Text = "🎯 " .. destroyed .. " EggSpawns destroyed!"
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
    
    return gui, eggPointsLabel, eggSlotsLabel, eggAreasLabel, eggSpawnsLabel, totalLabel, statusLabel
end

-- ========================================================
-- QUICK DESTROY FUNCTIONS (NO GUI)
-- ========================================================

local function quickDestroyAllEggPoints()
    print("⚡ QUICK EGG POINT DESTROY MODE - NO GUI")
    local destroyed = destroyAllEggPoints()
    
    if destroyed > 0 then
        print("🎉 Quick egg point destruction complete!")
        print("💥 " .. destroyed .. " egg objects eliminated!")
        print("🚀 Performance should be improved!")
    else
        print("⚠️ No egg points found to destroy")
    end
    
    return destroyed
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating Egg Point Destroyer...")

-- Create GUI
local gui, eggPointsLabel, eggSlotsLabel, eggAreasLabel, eggSpawnsLabel, totalLabel, statusLabel = createEggPointDestroyGUI()

-- Auto-scan on startup
print("🔄 Auto-scanning for egg points on startup...")
task.wait(1)
local found = scanWorkspaceForEggPoints()

if eggPointsLabel and eggSlotsLabel and eggAreasLabel and eggSpawnsLabel and totalLabel and statusLabel then
    eggPointsLabel.Text = "🥚 EggPoints: " .. destroyData.scanResults.eggPointsFound
    eggSlotsLabel.Text = "🎰 EggSlots: " .. destroyData.scanResults.eggSlotsFound
    eggAreasLabel.Text = "📍 EggAreas: " .. destroyData.scanResults.eggAreasFound
    eggSpawnsLabel.Text = "🌟 EggSpawns: " .. destroyData.scanResults.eggSpawnsFound
    totalLabel.Text = "💥 Total Destroyed: " .. destroyData.totalDestroyed
    statusLabel.Text = "🎯 Auto-scan found " .. found .. " egg objects"
end

print("✅ EGG POINT DESTROYER READY!")
print("===============================")
print("🥚 Egg Point destroyer loaded successfully")
print("🎯 Auto-scan found " .. found .. " targets on startup")
print("🔍 Use SCAN to find egg points")
print("💀 Use DESTROY buttons to eliminate them")
print("===============================")
print("📋 Target Detection:")
print("   🥚 EggPoint, EggSlot, EggArea patterns")
print("   🎰 AreaEggSlotsClient structures")
print("   📍 Egg spawn and location points")
print("   🌟 All egg-related mechanics")
print("===============================")
print("💡 Features:")
print("   • Comprehensive egg point detection")
print("   • Selective destruction options")
print("   • Real-time statistics")
print("   • Hitbox preservation option")
print("   • Performance optimization")
print("   • Draggable GUI interface")
print("===============================")
print("⚡ Ready to eliminate all egg mechanics!")

-- Export functions for manual use
getgenv().quickDestroyEggPoints = quickDestroyAllEggPoints
getgenv().scanEggPoints = scanWorkspaceForEggPoints