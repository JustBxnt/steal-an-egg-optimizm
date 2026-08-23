-- ========================================================
-- ADVANCED PET ESP - COMPREHENSIVE PET DETECTION
-- ESP khusus untuk mendeteksi semua jenis pet
-- ========================================================

print("🐾 LOADING ADVANCED PET ESP...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========================================================
-- PET ESP DATA & SETTINGS
-- ========================================================

local petData = {
    allPets = {},
    playerPets = {},
    followingPets = {},
    freePets = {},
    totalPets = 0,
    activePetESP = {},
    espConnections = {}
}

local petSettings = {
    enabled = true,
    showPlayerPets = true,
    showFollowingPets = true,
    showFreePets = true,
    showPetNames = true,
    showPetOwners = true,
    showDistance = true,
    maxDistance = 400,
    boxThickness = 2,
    textSize = 14,
    updateRate = 0.1,
    showRarity = true,
    showLevel = true
}

-- Color coding untuk berbagai jenis pet
local petColors = {
    playerPet = Color3.fromRGB(100, 255, 100),      -- Green - Pet milik player
    followingPet = Color3.fromRGB(255, 200, 100),    -- Orange - Pet yang follow
    freePet = Color3.fromRGB(255, 100, 100),         -- Red - Pet bebas
    rarePet = Color3.fromRGB(255, 100, 255),         -- Magenta - Pet rare
    legendaryPet = Color3.fromRGB(255, 215, 0),      -- Gold - Pet legendary
    defaultPet = Color3.fromRGB(150, 150, 255)       -- Blue - Pet default
}

-- ========================================================
-- PET DETECTION FUNCTIONS
-- ========================================================

local function isPetObject(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    local className = obj.ClassName
    
    -- Advanced pet detection patterns
    local petPatterns = {
        "pet", "companion", "follow", "familiar", "buddy", "mount",
        "dragon", "unicorn", "phoenix", "wolf", "cat", "dog", "bird",
        "bear", "lion", "tiger", "eagle", "shark", "spider", "snake"
    }
    
    -- Check name patterns
    for _, pattern in ipairs(petPatterns) do
        if name:find(pattern) then
            return true
        end
    end
    
    -- Check if it's a Model with pet-like characteristics
    if className == "Model" then
        -- Check for humanoid (many pets have humanoids)
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Check if it has pet-like properties
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Root")
            if rootPart then
                -- Check size (pets are usually smaller than players)
                if rootPart.Size.Y < 10 then
                    return true
                end
            end
        end
        
        -- Check for specific pet children
        for _, child in pairs(obj:GetChildren()) do
            local childName = child.Name:lower()
            if childName:find("pet") or childName:find("follow") then
                return true
            end
        end
    end
    
    return false
end

local function getPetOwner(petObj)
    -- Try to find owner through various methods
    local owner = "Unknown"
    
    -- Method 1: Check if pet is child of a player
    local parent = petObj.Parent
    while parent do
        if parent.Parent == Players then
            return parent.Name
        end
        parent = parent.Parent
    end
    
    -- Method 2: Check for owner values/strings
    for _, child in pairs(petObj:GetDescendants()) do
        if child.Name:lower():find("owner") and child:IsA("StringValue") then
            return child.Value
        elseif child.Name:lower():find("owner") and child:IsA("ObjectValue") and child.Value then
            return child.Value.Name
        end
    end
    
    -- Method 3: Find nearest player (likely owner)
    if petObj:FindFirstChild("HumanoidRootPart") or petObj:FindFirstChild("Torso") then
        local petPos = (petObj:FindFirstChild("HumanoidRootPart") or petObj:FindFirstChild("Torso")).Position
        local closestPlayer = nil
        local closestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (player.Character.HumanoidRootPart.Position - petPos).Magnitude
                if distance < closestDistance and distance < 50 then -- Within 50 studs
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
        
        if closestPlayer then
            return closestPlayer.Name
        end
    end
    
    return owner
end

local function getPetRarity(petObj)
    local name = petObj.Name:lower()
    
    -- Simple rarity detection based on name patterns
    if name:find("legendary") or name:find("mythic") or name:find("divine") then
        return "Legendary", petColors.legendaryPet
    elseif name:find("epic") or name:find("rare") or name:find("golden") then
        return "Rare", petColors.rarePet
    elseif name:find("common") or name:find("basic") then
        return "Common", petColors.defaultPet
    else
        return "Unknown", petColors.defaultPet
    end
end
local function getPetType(petObj)
    local owner = getPetOwner(petObj)
    
    if owner == LocalPlayer.Name then
        return "playerPet", petColors.playerPet
    elseif owner ~= "Unknown" then
        return "followingPet", petColors.followingPet
    else
        return "freePet", petColors.freePet
    end
end

-- ========================================================
-- ESP CREATION FUNCTIONS
-- ========================================================

local function createPetESP(petObj)
    -- Get pet information
    local owner = getPetOwner(petObj)
    local petType, color = getPetType(petObj)
    local rarity, rarityColor = getPetRarity(petObj)
    
    -- Use rarity color if it's a rare pet
    if rarity == "Legendary" or rarity == "Rare" then
        color = rarityColor
    end
    
    -- Create main ESP folder
    local espFolder = Instance.new("Folder")
    espFolder.Name = "PetESP_Elements"
    espFolder.Parent = petObj
    
    -- Create BillboardGui for pet info
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP_Billboard"
    billboard.Adornee = petObj:FindFirstChild("HumanoidRootPart") or petObj:FindFirstChild("Torso") or petObj:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 250, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = espFolder
    
    -- Background frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Pet name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -10, 0, 25)
    nameLabel.Position = UDim2.new(0, 5, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "🐾 " .. petObj.Name
    nameLabel.TextColor3 = color
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    -- Owner label
    local ownerLabel = Instance.new("TextLabel")
    ownerLabel.Name = "OwnerLabel"
    ownerLabel.Size = UDim2.new(1, -10, 0, 20)
    ownerLabel.Position = UDim2.new(0, 5, 0, 25)
    ownerLabel.BackgroundTransparency = 1
    ownerLabel.Text = "👤 Owner: " .. owner
    ownerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ownerLabel.TextSize = 12
    ownerLabel.Font = Enum.Font.SourceSans
    ownerLabel.TextStrokeTransparency = 0
    ownerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    ownerLabel.TextXAlignment = Enum.TextXAlignment.Left
    ownerLabel.Parent = frame
    
    -- Info label (distance, rarity, etc.)
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -10, 0, 20)
    infoLabel.Position = UDim2.new(0, 5, 0, 50)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "✨ " .. rarity .. " • 📏 0m"
    infoLabel.TextColor3 = rarityColor
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextStrokeTransparency = 0
    infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = frame
    
    -- Create 3D highlight box
    local adornee = petObj:FindFirstChild("HumanoidRootPart") or petObj:FindFirstChild("Torso") or petObj
    if adornee then
        local highlight = Instance.new("SelectionBox")
        highlight.Name = "PetESP_Highlight"
        highlight.Adornee = adornee
        highlight.Color3 = color
        highlight.LineThickness = petSettings.boxThickness
        highlight.Transparency = 0.6
        highlight.Parent = espFolder
    end
    
    -- Store ESP data
    petData.activePetESP[petObj] = {
        folder = espFolder,
        billboard = billboard,
        nameLabel = nameLabel,
        ownerLabel = ownerLabel,
        infoLabel = infoLabel,
        color = color,
        rarity = rarity,
        owner = owner,
        petType = petType
    }
    
    return espFolder
end

local function updatePetESPDistance(petObj, espData)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
    local petPos
    
    -- Get pet position
    local petRoot = petObj:FindFirstChild("HumanoidRootPart") or petObj:FindFirstChild("Torso")
    if petRoot then
        petPos = petRoot.Position
    else
        return
    end
    
    local distance = math.floor((playerPos - petPos).Magnitude)
    
    -- Hide if too far
    if distance > petSettings.maxDistance then
        espData.billboard.Enabled = false
        return
    else
        espData.billboard.Enabled = true
    end
    
    -- Update info label with distance
    if espData.infoLabel then
        espData.infoLabel.Text = "✨ " .. espData.rarity .. " • 📏 " .. distance .. "m"
    end
end
-- ========================================================
-- MAIN PET ESP FUNCTIONS
-- ========================================================

local function scanForPets()
    print("🔍 Scanning for pets in workspace...")
    
    -- Clear previous data
    petData = {
        allPets = {}, playerPets = {}, followingPets = {}, freePets = {},
        totalPets = 0, activePetESP = petData.activePetESP or {},
        espConnections = petData.espConnections or {}
    }
    
    local startTime = tick()
    local scannedObjects = 0
    
    -- Scan workspace for pets
    for _, obj in pairs(Workspace:GetDescendants()) do
        scannedObjects = scannedObjects + 1
        
        pcall(function()
            if isPetObject(obj) then
                table.insert(petData.allPets, obj)
                
                local owner = getPetOwner(obj)
                local petType = getPetType(obj)
                
                -- Categorize pets
                if petType == "playerPet" then
                    table.insert(petData.playerPets, obj)
                elseif petType == "followingPet" then
                    table.insert(petData.followingPets, obj)
                else
                    table.insert(petData.freePets, obj)
                end
                
                -- Create ESP for this pet
                if petSettings.enabled then
                    createPetESP(obj)
                    petData.totalPets = petData.totalPets + 1
                end
                
                print("🐾 Found pet: " .. obj.Name .. " (Owner: " .. owner .. ")")
            end
        end)
    end
    
    -- Also scan player characters for pets
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, obj in pairs(player.Character:GetChildren()) do
                pcall(function()
                    if isPetObject(obj) then
                        table.insert(petData.allPets, obj)
                        table.insert(petData.playerPets, obj)
                        
                        if petSettings.enabled then
                            createPetESP(obj)
                            petData.totalPets = petData.totalPets + 1
                        end
                        
                        print("🐾 Found player pet: " .. obj.Name .. " (Player: " .. player.Name .. ")")
                    end
                end)
            end
        end
    end
    
    local scanTime = math.floor((tick() - startTime) * 1000) / 1000
    
    print("✅ Pet scan complete!")
    print("   📊 Objects scanned: " .. scannedObjects)
    print("   🐾 Total pets found: " .. #petData.allPets)
    print("   👤 Player pets: " .. #petData.playerPets)
    print("   🤝 Following pets: " .. #petData.followingPets)
    print("   🆓 Free pets: " .. #petData.freePets)
    print("   🎯 ESP created: " .. petData.totalPets)
    print("   ⏱️ Scan time: " .. scanTime .. "s")
    
    return #petData.allPets
end

local function removeAllPetESP()
    print("🧹 Removing all pet ESP...")
    
    for petObj, espData in pairs(petData.activePetESP) do
        if espData.folder then
            espData.folder:Destroy()
        end
    end
    
    -- Clear connections
    for _, connection in pairs(petData.espConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    petData.activePetESP = {}
    petData.espConnections = {}
    petData.totalPets = 0
    
    print("✅ All pet ESP removed!")
end

local function togglePetTypeESP(petType)
    local count = 0
    
    for petObj, espData in pairs(petData.activePetESP) do
        if espData.petType == petType then
            local isVisible = espData.billboard.Enabled
            espData.billboard.Enabled = not isVisible
            count = count + 1
        end
    end
    
    print("🎯 Toggled " .. petType .. " ESP: " .. count .. " pets")
    return count
end
-- ========================================================
-- GUI CREATION
-- ========================================================

local function createPetESPGUI()
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "AdvancedPetESP"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
    titleBar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix title bar corner
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🐾 PET ESP"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
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
    statsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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
    statsTitle.Text = "📊 PET STATISTICS"
    statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsTitle.TextSize = 14
    statsTitle.Font = Enum.Font.SourceSansBold
    statsTitle.Parent = statsFrame
    
    -- Pet count labels
    local totalLabel = Instance.new("TextLabel")
    totalLabel.Name = "TotalLabel"
    totalLabel.Size = UDim2.new(0.5, -5, 0, 20)
    totalLabel.Position = UDim2.new(0, 5, 0, 30)
    totalLabel.BackgroundTransparency = 1
    totalLabel.Text = "🎯 Total: 0"
    totalLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    totalLabel.TextSize = 12
    totalLabel.Font = Enum.Font.SourceSans
    totalLabel.TextXAlignment = Enum.TextXAlignment.Left
    totalLabel.Parent = statsFrame
    
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Name = "PlayerLabel"
    playerLabel.Size = UDim2.new(0.5, -5, 0, 20)
    playerLabel.Position = UDim2.new(0.5, 5, 0, 30)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "👤 Yours: 0"
    playerLabel.TextColor3 = petColors.playerPet
    playerLabel.TextSize = 12
    playerLabel.Font = Enum.Font.SourceSans
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.Parent = statsFrame
    
    local followingLabel = Instance.new("TextLabel")
    followingLabel.Name = "FollowingLabel"
    followingLabel.Size = UDim2.new(0.5, -5, 0, 20)
    followingLabel.Position = UDim2.new(0, 5, 0, 55)
    followingLabel.BackgroundTransparency = 1
    followingLabel.Text = "🤝 Following: 0"
    followingLabel.TextColor3 = petColors.followingPet
    followingLabel.TextSize = 12
    followingLabel.Font = Enum.Font.SourceSans
    followingLabel.TextXAlignment = Enum.TextXAlignment.Left
    followingLabel.Parent = statsFrame
    
    local freeLabel = Instance.new("TextLabel")
    freeLabel.Name = "FreeLabel"
    freeLabel.Size = UDim2.new(0.5, -5, 0, 20)
    freeLabel.Position = UDim2.new(0.5, 5, 0, 55)
    freeLabel.BackgroundTransparency = 1
    freeLabel.Text = "🆓 Free: 0"
    freeLabel.TextColor3 = petColors.freePet
    freeLabel.TextSize = 12
    freeLabel.Font = Enum.Font.SourceSans
    freeLabel.TextXAlignment = Enum.TextXAlignment.Left
    freeLabel.Parent = statsFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 85)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Click SCAN to find pets"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statsFrame
    -- Control Buttons Frame
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -20, 0, 80)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 180)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame
    
    -- Scan Button
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0.48, 0, 0, 35)
    scanButton.Position = UDim2.new(0, 0, 0, 0)
    scanButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
    scanButton.Text = "🔍 SCAN PETS"
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
    settingsButton.Size = UDim2.new(1, 0, 0, 30)
    settingsButton.Position = UDim2.new(0, 0, 0, 45)
    settingsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    settingsButton.Text = "⚙️ DISTANCE: " .. petSettings.maxDistance .. "m"
    settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsButton.TextSize = 11
    settingsButton.Font = Enum.Font.SourceSansBold
    settingsButton.BorderSizePixel = 0
    settingsButton.Parent = buttonsFrame
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 6)
    settingsCorner.Parent = settingsButton
    -- Pet Type Toggle Frame
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Size = UDim2.new(1, -20, 0, 100)
    toggleFrame.Position = UDim2.new(0, 10, 0, 270)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    toggleFrame.BorderSizePixel = 1
    toggleFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    toggleFrame.Parent = mainFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleFrame
    
    -- Toggle Title
    local toggleTitle = Instance.new("TextLabel")
    toggleTitle.Size = UDim2.new(1, 0, 0, 25)
    toggleTitle.BackgroundTransparency = 1
    toggleTitle.Text = "🎛️ PET TYPE FILTERS"
    toggleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleTitle.TextSize = 14
    toggleTitle.Font = Enum.Font.SourceSansBold
    toggleTitle.Parent = toggleFrame
    
    -- Pet Type Toggle Buttons
    local playerPetButton = Instance.new("TextButton")
    playerPetButton.Name = "PlayerPetButton"
    playerPetButton.Size = UDim2.new(1, -10, 0, 20)
    playerPetButton.Position = UDim2.new(0, 5, 0, 30)
    playerPetButton.BackgroundColor3 = petColors.playerPet
    playerPetButton.Text = "👤 Your Pets (ON)"
    playerPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerPetButton.TextSize = 11
    playerPetButton.Font = Enum.Font.SourceSansBold
    playerPetButton.BorderSizePixel = 0
    playerPetButton.Parent = toggleFrame
    
    local playerPetCorner = Instance.new("UICorner")
    playerPetCorner.CornerRadius = UDim.new(0, 4)
    playerPetCorner.Parent = playerPetButton
    
    local followingPetButton = Instance.new("TextButton")
    followingPetButton.Name = "FollowingPetButton"
    followingPetButton.Size = UDim2.new(1, -10, 0, 20)
    followingPetButton.Position = UDim2.new(0, 5, 0, 55)
    followingPetButton.BackgroundColor3 = petColors.followingPet
    followingPetButton.Text = "🤝 Other Player Pets (ON)"
    followingPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    followingPetButton.TextSize = 11
    followingPetButton.Font = Enum.Font.SourceSansBold
    followingPetButton.BorderSizePixel = 0
    followingPetButton.Parent = toggleFrame
    
    local followingPetCorner = Instance.new("UICorner")
    followingPetCorner.CornerRadius = UDim.new(0, 4)
    followingPetCorner.Parent = followingPetButton
    
    local freePetButton = Instance.new("TextButton")
    freePetButton.Name = "FreePetButton"
    freePetButton.Size = UDim2.new(1, -10, 0, 20)
    freePetButton.Position = UDim2.new(0, 5, 0, 80)
    freePetButton.BackgroundColor3 = petColors.freePet
    freePetButton.Text = "🆓 Free/Wild Pets (ON)"
    freePetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    freePetButton.TextSize = 11
    freePetButton.Font = Enum.Font.SourceSansBold
    freePetButton.BorderSizePixel = 0
    freePetButton.Parent = toggleFrame
    
    local freePetCorner = Instance.new("UICorner")
    freePetCorner.CornerRadius = UDim.new(0, 4)
    freePetCorner.Parent = freePetButton
    -- ========================================================
    -- GUI BUTTON EVENTS
    -- ========================================================
    
    local function updateGUIStats()
        totalLabel.Text = "🎯 Total: " .. #petData.allPets
        playerLabel.Text = "👤 Yours: " .. #petData.playerPets
        followingLabel.Text = "🤝 Following: " .. #petData.followingPets
        freeLabel.Text = "🆓 Free: " .. #petData.freePets
    end
    
    scanButton.MouseButton1Click:Connect(function()
        scanButton.Text = "⏳ SCANNING..."
        scanButton.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
        statusLabel.Text = "🔍 Scanning workspace for pets..."
        
        task.wait(0.1)
        local petCount = scanForPets()
        updateGUIStats()
        
        scanButton.Text = "🔍 SCAN PETS"
        scanButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
        statusLabel.Text = "✅ Found " .. petCount .. " pets!"
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        removeAllPetESP()
        petData.allPets = {}
        petData.playerPets = {}
        petData.followingPets = {}
        petData.freePets = {}
        updateGUIStats()
        statusLabel.Text = "🧹 All pet ESP cleared"
    end)
    
    -- Distance setting toggle
    local distances = {200, 300, 400, 500, 1000}
    local currentDistanceIndex = 3 -- Default 400m
    
    settingsButton.MouseButton1Click:Connect(function()
        currentDistanceIndex = currentDistanceIndex + 1
        if currentDistanceIndex > #distances then
            currentDistanceIndex = 1
        end
        
        petSettings.maxDistance = distances[currentDistanceIndex]
        settingsButton.Text = "⚙️ DISTANCE: " .. petSettings.maxDistance .. "m"
        statusLabel.Text = "📏 Max distance set to " .. petSettings.maxDistance .. "m"
    end)
    
    -- Pet type toggle events
    local playerPetVisible = true
    local followingPetVisible = true
    local freePetVisible = true
    
    playerPetButton.MouseButton1Click:Connect(function()
        playerPetVisible = not playerPetVisible
        playerPetButton.Text = "👤 Your Pets (" .. (playerPetVisible and "ON" or "OFF") .. ")"
        playerPetButton.BackgroundColor3 = playerPetVisible and petColors.playerPet or Color3.fromRGB(80, 80, 80)
        
        togglePetTypeESP("playerPet")
        statusLabel.Text = "👤 Your pets ESP " .. (playerPetVisible and "enabled" or "disabled")
    end)
    
    followingPetButton.MouseButton1Click:Connect(function()
        followingPetVisible = not followingPetVisible
        followingPetButton.Text = "🤝 Other Player Pets (" .. (followingPetVisible and "ON" or "OFF") .. ")"
        followingPetButton.BackgroundColor3 = followingPetVisible and petColors.followingPet or Color3.fromRGB(80, 80, 80)
        
        togglePetTypeESP("followingPet")
        statusLabel.Text = "🤝 Other player pets ESP " .. (followingPetVisible and "enabled" or "disabled")
    end)
    
    freePetButton.MouseButton1Click:Connect(function()
        freePetVisible = not freePetVisible
        freePetButton.Text = "🆓 Free/Wild Pets (" .. (freePetVisible and "ON" or "OFF") .. ")"
        freePetButton.BackgroundColor3 = freePetVisible and petColors.freePet or Color3.fromRGB(80, 80, 80)
        
        togglePetTypeESP("freePet")
        statusLabel.Text = "🆓 Free pets ESP " .. (freePetVisible and "enabled" or "disabled")
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        removeAllPetESP()
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
    
    return gui, totalLabel, playerLabel, followingLabel, freeLabel, statusLabel
end
-- ========================================================
-- UPDATE LOOP & MAIN EXECUTION
-- ========================================================

local function startPetESPUpdateLoop()
    -- Distance and visibility update loop
    local updateConnection = RunService.Heartbeat:Connect(function()
        if not petSettings.enabled then return end
        
        for petObj, espData in pairs(petData.activePetESP) do
            if petObj and petObj.Parent and espData then
                updatePetESPDistance(petObj, espData)
            else
                -- Clean up invalid ESP
                if espData.folder then
                    espData.folder:Destroy()
                end
                petData.activePetESP[petObj] = nil
            end
        end
    end)
    
    table.insert(petData.espConnections, updateConnection)
    
    -- Auto-scan for new pets every 10 seconds
    local autoScanConnection = task.spawn(function()
        while petSettings.enabled do
            task.wait(10)
            
            if petSettings.enabled then
                -- Quick scan for new pets
                for _, obj in pairs(Workspace:GetDescendants()) do
                    pcall(function()
                        if isPetObject(obj) and not petData.activePetESP[obj] then
                            createPetESP(obj)
                            table.insert(petData.allPets, obj)
                            petData.totalPets = petData.totalPets + 1
                            print("🐾 Auto-detected new pet: " .. obj.Name)
                        end
                    end)
                end
            end
        end
    end)
    
    table.insert(petData.espConnections, autoScanConnection)
end

-- ========================================================
-- QUICK FUNCTIONS (NO GUI)
-- ========================================================

local function quickPetESP()
    print("⚡ QUICK PET ESP - NO GUI MODE")
    
    local petCount = scanForPets()
    
    if petCount > 0 then
        startPetESPUpdateLoop()
        print("✅ Quick Pet ESP enabled!")
        print("🐾 " .. petCount .. " pets detected and ESP'd")
        print("🎯 ESP will auto-update distances")
    else
        print("⚠️ No pets found in workspace")
    end
    
    return petCount
end

local function toggleQuickESP()
    if petSettings.enabled then
        removeAllPetESP()
        petSettings.enabled = false
        print("🔴 Pet ESP DISABLED")
    else
        petSettings.enabled = true
        quickPetESP()
        print("🟢 Pet ESP ENABLED")
    end
    
    return petSettings.enabled
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating Advanced Pet ESP...")

-- Create GUI
local gui, totalLabel, playerLabel, followingLabel, freeLabel, statusLabel = createPetESPGUI()

-- Start update loop
startPetESPUpdateLoop()

-- Auto-scan on startup
print("🔄 Auto-scanning for pets on startup...")
task.wait(1)
local initialPetCount = scanForPets()

if totalLabel and playerLabel and followingLabel and freeLabel and statusLabel then
    totalLabel.Text = "🎯 Total: " .. #petData.allPets
    playerLabel.Text = "👤 Yours: " .. #petData.playerPets
    followingLabel.Text = "🤝 Following: " .. #petData.followingPets
    freeLabel.Text = "🆓 Free: " .. #petData.freePets
    statusLabel.Text = "🎯 Auto-scan found " .. initialPetCount .. " pets"
end

print("✅ ADVANCED PET ESP READY!")
print("============================")
print("🐾 Pet ESP system loaded successfully")
print("🎯 Found " .. initialPetCount .. " pets on startup")
print("📊 Real-time statistics available")
print("🎛️ Multiple filtering options")
print("============================")
print("📋 Pet Categories Detected:")
print("   👤 Your pets: " .. #petData.playerPets)
print("   🤝 Other player pets: " .. #petData.followingPets)
print("   🆓 Free/wild pets: " .. #petData.freePets)
print("============================")
print("💡 Features:")
print("   • Advanced pet pattern detection")
print("   • Owner identification system")
print("   • Rarity detection (Legendary/Rare)")
print("   • Real-time distance tracking")
print("   • Color-coded pet types")
print("   • Auto-scan for new pets")
print("   • Selective filtering controls")
print("   • Performance optimized")
print("============================")
print("🎮 Ready to track all pets!")

-- Export functions for manual use
getgenv().quickPetESP = quickPetESP
getgenv().togglePetESP = toggleQuickESP
getgenv().scanPets = scanForPets
getgenv().clearPetESP = removeAllPetESP