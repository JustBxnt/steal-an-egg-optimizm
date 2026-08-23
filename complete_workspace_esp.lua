-- ========================================================
-- COMPLETE WORKSPACE ESP - ADVANCED VISUALIZATION
-- ESP untuk semua objek di workspace dengan kategorisasi
-- ========================================================

print("🎯 LOADING COMPLETE WORKSPACE ESP...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========================================================
-- ESP DATA & SETTINGS
-- ========================================================

local espData = {
    pets = {},
    eggs = {},
    effects = {},
    models = {},
    parts = {},
    scripts = {},
    guis = {},
    sounds = {},
    players = {},
    npcs = {},
    tools = {},
    vehicles = {},
    totalObjects = 0,
    activeESP = {},
    espConnections = {}
}

local espSettings = {
    enabled = true,
    showPets = true,
    showEggs = true,
    showEffects = false,
    showModels = true,
    showParts = false,
    showScripts = false,
    showPlayers = true,
    showNPCs = true,
    showTools = true,
    showVehicles = true,
    maxDistance = 500,
    boxThickness = 2,
    textSize = 14,
    updateRate = 0.1
}

local colors = {
    pets = Color3.fromRGB(255, 200, 100),      -- Orange
    eggs = Color3.fromRGB(100, 255, 100),      -- Green
    effects = Color3.fromRGB(255, 100, 255),   -- Magenta
    models = Color3.fromRGB(100, 200, 255),    -- Light Blue
    parts = Color3.fromRGB(200, 200, 200),     -- Gray
    scripts = Color3.fromRGB(255, 150, 150),   -- Light Red
    players = Color3.fromRGB(255, 100, 100),   -- Red
    npcs = Color3.fromRGB(255, 255, 100),      -- Yellow
    tools = Color3.fromRGB(150, 255, 150),     -- Light Green
    vehicles = Color3.fromRGB(100, 100, 255)   -- Blue
}

-- ========================================================
-- ESP CREATION FUNCTIONS
-- ========================================================

local function createESPBox(object, color, text)
    -- Main ESP folder for organization
    local espFolder = object:FindFirstChild("ESP_Elements")
    if not espFolder then
        espFolder = Instance.new("Folder")
        espFolder.Name = "ESP_Elements"
        espFolder.Parent = object
    end
    
    -- Create BillboardGui for text
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = espFolder
    
    -- Background frame for text
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    -- Text label
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextSize = espSettings.textSize
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = frame
    
    -- Create selection box for 3D objects
    if object:IsA("BasePart") or object:IsA("Model") then
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "ESP_SelectionBox"
        selectionBox.Adornee = object
        selectionBox.Color3 = color
        selectionBox.LineThickness = espSettings.boxThickness
        selectionBox.Transparency = 0.7
        selectionBox.Parent = espFolder
    end
    
    return espFolder
end

local function updateESPDistance(espElement, object)
    if not espElement or not object then return end
    
    local billboard = espElement:FindFirstChild("ESP_Billboard")
    if not billboard then return end
    
    local textLabel = billboard.Frame.TextLabel
    local distance = 0
    
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        local playerPos = LocalPlayer.Character.PrimaryPart.Position
        local objectPos
        
        if object:IsA("BasePart") then
            objectPos = object.Position
        elseif object:IsA("Model") and object.PrimaryPart then
            objectPos = object.PrimaryPart.Position
        elseif object:IsA("Model") then
            local firstPart = object:FindFirstChildOfClass("BasePart")
            if firstPart then
                objectPos = firstPart.Position
            end
        end
        
        if objectPos then
            distance = math.floor((playerPos - objectPos).Magnitude)
            
            -- Hide if too far
            if distance > espSettings.maxDistance then
                billboard.Enabled = false
                return
            else
                billboard.Enabled = true
            end
            
            -- Update text with distance
            local originalText = textLabel.Text:match("^(.+) %[%d+m%]$") or textLabel.Text:match("^(.+)$")
            textLabel.Text = originalText .. " [" .. distance .. "m]"
        end
    end
end
-- ========================================================
-- OBJECT CATEGORIZATION FUNCTIONS
-- ========================================================

local function categorizeObject(obj)
    local className = obj.ClassName
    local objName = obj.Name:lower()
    local category = nil
    local displayName = obj.Name
    
    -- Advanced categorization logic
    if objName:find("pet") or objName:find("companion") or objName:find("follow") or objName:find("familiar") then
        category = "pets"
        displayName = "🐾 " .. obj.Name
        table.insert(espData.pets, obj)
        
    elseif objName:find("egg") and obj.Parent and obj.Parent.Name == "AreaEggSlotsClient" then
        category = "eggs"
        displayName = "🥚 " .. obj.Name
        table.insert(espData.eggs, obj)
        
    elseif obj.Parent == Players then
        category = "players"
        displayName = "👤 " .. obj.Name .. " (Player)"
        table.insert(espData.players, obj)
        
    elseif objName:find("npc") or objName:find("bot") or objName:find("villager") or objName:find("merchant") then
        category = "npcs"
        displayName = "🤖 " .. obj.Name .. " (NPC)"
        table.insert(espData.npcs, obj)
        
    elseif className:find("Tool") or objName:find("sword") or objName:find("gun") or objName:find("weapon") then
        category = "tools"
        displayName = "🔧 " .. obj.Name .. " (Tool)"
        table.insert(espData.tools, obj)
        
    elseif objName:find("car") or objName:find("vehicle") or objName:find("bike") or objName:find("boat") or objName:find("plane") then
        category = "vehicles"
        displayName = "🚗 " .. obj.Name .. " (Vehicle)"
        table.insert(espData.vehicles, obj)
        
    elseif className:find("Particle") or className:find("Beam") or className:find("Trail") or 
           className:find("Fire") or className:find("Smoke") or className:find("Sparkles") then
        category = "effects"
        displayName = "✨ " .. obj.Name .. " (Effect)"
        table.insert(espData.effects, obj)
        
    elseif className == "Model" then
        category = "models"
        displayName = "📦 " .. obj.Name .. " (Model)"
        table.insert(espData.models, obj)
        
    elseif className:find("Part") or className:find("Block") or className:find("Wedge") then
        category = "parts"
        displayName = "🧱 " .. obj.Name .. " (Part)"
        table.insert(espData.parts, obj)
        
    elseif className:find("Script") then
        category = "scripts"
        displayName = "📜 " .. obj.Name .. " (Script)"
        table.insert(espData.scripts, obj)
        
    else
        -- Default category for unknown objects
        category = "models"
        displayName = "❓ " .. obj.Name .. " (" .. className .. ")"
        table.insert(espData.models, obj)
    end
    
    return category, displayName
end

local function shouldShowESP(category)
    return espSettings.enabled and espSettings["show" .. category:gsub("^%l", string.upper)]
end

local function createESPForObject(obj)
    local category, displayName = categorizeObject(obj)
    
    if category and shouldShowESP(category) and colors[category] then
        local espElement = createESPBox(obj, colors[category], displayName)
        if espElement then
            espData.activeESP[obj] = {
                element = espElement,
                category = category,
                displayName = displayName
            }
            espData.totalObjects = espData.totalObjects + 1
        end
    end
end
-- ========================================================
-- MAIN ESP FUNCTIONS
-- ========================================================

local function scanAndCreateESP()
    print("🔍 Scanning workspace for ESP targets...")
    
    -- Clear previous data
    espData = {
        pets = {}, eggs = {}, effects = {}, models = {}, parts = {},
        scripts = {}, guis = {}, sounds = {}, players = {}, npcs = {},
        tools = {}, vehicles = {}, totalObjects = 0, activeESP = {},
        espConnections = espData.espConnections or {}
    }
    
    local startTime = tick()
    local objectCount = 0
    
    -- Scan all workspace descendants
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            createESPForObject(obj)
            objectCount = objectCount + 1
        end)
    end
    
    -- Scan players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            pcall(function()
                createESPForObject(player.Character)
                objectCount = objectCount + 1
            end)
        end
    end
    
    local scanTime = math.floor((tick() - startTime) * 1000) / 1000
    
    print("✅ ESP scan complete!")
    print("   📊 Objects scanned: " .. objectCount)
    print("   🎯 ESP elements created: " .. espData.totalObjects)
    print("   ⏱️ Scan time: " .. scanTime .. "s")
    print("   📋 Categories found:")
    print("      🐾 Pets: " .. #espData.pets)
    print("      🥚 Eggs: " .. #espData.eggs)
    print("      👤 Players: " .. #espData.players)
    print("      🤖 NPCs: " .. #espData.npcs)
    print("      🔧 Tools: " .. #espData.tools)
    print("      🚗 Vehicles: " .. #espData.vehicles)
    print("      ✨ Effects: " .. #espData.effects)
    print("      📦 Models: " .. #espData.models)
    print("      🧱 Parts: " .. #espData.parts)
    print("      📜 Scripts: " .. #espData.scripts)
end

local function removeAllESP()
    print("🧹 Removing all ESP elements...")
    
    for obj, data in pairs(espData.activeESP) do
        if data.element then
            data.element:Destroy()
        end
    end
    
    -- Clear connections
    for _, connection in pairs(espData.espConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    espData.activeESP = {}
    espData.espConnections = {}
    
    print("✅ All ESP elements removed!")
end

local function toggleCategoryESP(category)
    local settingKey = "show" .. category:gsub("^%l", string.upper)
    espSettings[settingKey] = not espSettings[settingKey]
    
    -- Update existing ESP elements
    for obj, data in pairs(espData.activeESP) do
        if data.category == category then
            local espElement = data.element
            if espElement then
                local billboard = espElement:FindFirstChild("ESP_Billboard")
                local selectionBox = espElement:FindFirstChild("ESP_SelectionBox")
                
                local shouldShow = espSettings[settingKey]
                if billboard then billboard.Enabled = shouldShow end
                if selectionBox then selectionBox.Visible = shouldShow end
            end
        end
    end
    
    print("🎯 " .. category:upper() .. " ESP: " .. (espSettings[settingKey] and "ON" or "OFF"))
end
-- ========================================================
-- GUI CREATION
-- ========================================================

local function createESPGUI()
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CompleteWorkspaceESP"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    mainFrame.Parent = gui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 130, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix title bar corner
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = Color3.fromRGB(60, 130, 200)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🎯 WORKSPACE ESP"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
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
    -- Stats Frame
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(1, -20, 0, 100)
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
    statsTitle.Text = "📊 ESP STATISTICS"
    statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsTitle.TextSize = 14
    statsTitle.Font = Enum.Font.SourceSansBold
    statsTitle.Parent = statsFrame
    
    -- Total Objects Label
    local totalLabel = Instance.new("TextLabel")
    totalLabel.Name = "TotalLabel"
    totalLabel.Size = UDim2.new(1, -10, 0, 20)
    totalLabel.Position = UDim2.new(0, 5, 0, 30)
    totalLabel.BackgroundTransparency = 1
    totalLabel.Text = "🎯 Total ESP Objects: 0"
    totalLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    totalLabel.TextSize = 12
    totalLabel.Font = Enum.Font.SourceSans
    totalLabel.TextXAlignment = Enum.TextXAlignment.Left
    totalLabel.Parent = statsFrame
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 55)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Click SCAN to start ESP"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statsFrame
    
    -- Distance Label
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, -10, 0, 20)
    distanceLabel.Position = UDim2.new(0, 5, 0, 75)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "📏 Max Distance: " .. espSettings.maxDistance .. "m"
    distanceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    distanceLabel.TextSize = 11
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = statsFrame
    -- Control Buttons Frame
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -20, 0, 80)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 160)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame
    
    -- Scan Button
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0.48, 0, 0, 35)
    scanButton.Position = UDim2.new(0, 0, 0, 0)
    scanButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    scanButton.Text = "🔍 SCAN ESP"
    scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanButton.TextSize = 12
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.BorderSizePixel = 0
    scanButton.Parent = buttonsFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 6)
    scanCorner.Parent = scanButton
    
    -- Clear Button
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0.48, 0, 0, 35)
    clearButton.Position = UDim2.new(0.52, 0, 0, 0)
    clearButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    clearButton.Text = "🧹 CLEAR ESP"
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.TextSize = 12
    clearButton.Font = Enum.Font.SourceSansBold
    clearButton.BorderSizePixel = 0
    clearButton.Parent = buttonsFrame
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 6)
    clearCorner.Parent = clearButton
    
    -- Settings Button
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(1, 0, 0, 35)
    settingsButton.Position = UDim2.new(0, 0, 0, 45)
    settingsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    settingsButton.Text = "⚙️ ESP SETTINGS"
    settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsButton.TextSize = 12
    settingsButton.Font = Enum.Font.SourceSansBold
    settingsButton.BorderSizePixel = 0
    settingsButton.Parent = buttonsFrame
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 6)
    settingsCorner.Parent = settingsButton
    -- Category Toggle Frame
    local categoryFrame = Instance.new("Frame")
    categoryFrame.Name = "CategoryFrame"
    categoryFrame.Size = UDim2.new(1, -20, 0, 220)
    categoryFrame.Position = UDim2.new(0, 10, 0, 250)
    categoryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    categoryFrame.BorderSizePixel = 1
    categoryFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    categoryFrame.Parent = mainFrame
    
    local categoryCorner = Instance.new("UICorner")
    categoryCorner.CornerRadius = UDim.new(0, 6)
    categoryCorner.Parent = categoryFrame
    
    -- Category Title
    local categoryTitle = Instance.new("TextLabel")
    categoryTitle.Size = UDim2.new(1, 0, 0, 25)
    categoryTitle.BackgroundTransparency = 1
    categoryTitle.Text = "🎛️ ESP CATEGORIES"
    categoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    categoryTitle.TextSize = 14
    categoryTitle.Font = Enum.Font.SourceSansBold
    categoryTitle.Parent = categoryFrame
    
    -- Create category toggle buttons
    local categories = {
        {key = "Pets", icon = "🐾", color = colors.pets},
        {key = "Eggs", icon = "🥚", color = colors.eggs},
        {key = "Players", icon = "👤", color = colors.players},
        {key = "NPCs", icon = "🤖", color = colors.npcs},
        {key = "Tools", icon = "🔧", color = colors.tools},
        {key = "Vehicles", icon = "🚗", color = colors.vehicles},
        {key = "Effects", icon = "✨", color = colors.effects},
        {key = "Models", icon = "📦", color = colors.models},
        {key = "Parts", icon = "🧱", color = colors.parts},
        {key = "Scripts", icon = "📜", color = colors.scripts}
    }
    
    local toggleButtons = {}
    
    for i, category in ipairs(categories) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        
        local button = Instance.new("TextButton")
        button.Name = category.key .. "Toggle"
        button.Size = UDim2.new(0.48, 0, 0, 30)
        button.Position = UDim2.new(col * 0.51, 5, 0, 30 + row * 35)
        button.BackgroundColor3 = espSettings["show" .. category.key] and category.color or Color3.fromRGB(60, 60, 60)
        button.Text = category.icon .. " " .. category.key
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 11
        button.Font = Enum.Font.SourceSansBold
        button.BorderSizePixel = 0
        button.Parent = categoryFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button
        
        toggleButtons[category.key:lower()] = button
        
        -- Button click event
        button.MouseButton1Click:Connect(function()
            toggleCategoryESP(category.key:lower())
            button.BackgroundColor3 = espSettings["show" .. category.key] and category.color or Color3.fromRGB(60, 60, 60)
        end)
    end
    -- ========================================================
    -- BUTTON EVENTS & GUI FUNCTIONS
    -- ========================================================
    
    local function updateGUIStats()
        totalLabel.Text = "🎯 Total ESP Objects: " .. espData.totalObjects
        statusLabel.Text = "✅ ESP Active - " .. espData.totalObjects .. " objects tracked"
        distanceLabel.Text = "📏 Max Distance: " .. espSettings.maxDistance .. "m"
    end
    
    scanButton.MouseButton1Click:Connect(function()
        scanButton.Text = "⏳ SCANNING..."
        scanButton.BackgroundColor3 = Color3.fromRGB(150, 120, 60)
        statusLabel.Text = "🔍 Scanning workspace for ESP targets..."
        
        task.wait(0.1)
        scanAndCreateESP()
        updateGUIStats()
        
        scanButton.Text = "🔍 SCAN ESP"
        scanButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        removeAllESP()
        espData.totalObjects = 0
        updateGUIStats()
        statusLabel.Text = "🧹 All ESP elements cleared"
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        removeAllESP()
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
    
    return gui, totalLabel, statusLabel, distanceLabel
end
-- ========================================================
-- UPDATE LOOP & MAIN EXECUTION
-- ========================================================

local function startESPUpdateLoop()
    -- Distance update loop
    local updateConnection = RunService.Heartbeat:Connect(function()
        if not espSettings.enabled then return end
        
        for obj, data in pairs(espData.activeESP) do
            if obj and obj.Parent and data.element then
                updateESPDistance(data.element, obj)
            else
                -- Clean up invalid ESP
                if data.element then
                    data.element:Destroy()
                end
                espData.activeESP[obj] = nil
            end
        end
    end)
    
    table.insert(espData.espConnections, updateConnection)
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating Complete Workspace ESP...")

-- Create GUI
local gui, totalLabel, statusLabel, distanceLabel = createESPGUI()

-- Start update loop
startESPUpdateLoop()

print("✅ COMPLETE WORKSPACE ESP READY!")
print("==================================")
print("🎯 Advanced ESP system loaded")
print("🔍 Click 'SCAN ESP' to start")
print("🎛️ Use category toggles to filter")
print("📏 Distance tracking enabled")
print("==================================")
print("📋 ESP Categories Available:")
print("   🐾 Pets       🥚 Eggs       👤 Players")
print("   🤖 NPCs       🔧 Tools      🚗 Vehicles")  
print("   ✨ Effects    📦 Models     🧱 Parts")
print("   📜 Scripts")
print("==================================")
print("💡 Features:")
print("   • Real-time distance tracking")
print("   • Category-based filtering") 
print("   • Color-coded ESP boxes")
print("   • Performance optimized")
print("   • Draggable GUI interface")
print("==================================")
print("🎮 Ready to visualize your workspace!")

-- Auto-scan on load (optional)
task.wait(1)
print("🔄 Auto-scanning workspace...")
scanAndCreateESP()
if totalLabel then
    totalLabel.Text = "🎯 Total ESP Objects: " .. espData.totalObjects
    statusLabel.Text = "✅ Auto-scan complete - " .. espData.totalObjects .. " objects found"
end