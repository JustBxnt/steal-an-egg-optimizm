-- ========================================================
-- SIMPLE PET ESP - LIGHTWEIGHT & FAST
-- ESP sederhana khusus untuk pet detection
-- ========================================================

print("🐾 LOADING SIMPLE PET ESP...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- SIMPLE PET ESP SETTINGS
-- ========================================================

local espActive = true
local maxDistance = 300
local petESPs = {}
local updateConnection

-- Pet colors
local colors = {
    yourPet = Color3.fromRGB(100, 255, 100),     -- Green
    otherPet = Color3.fromRGB(255, 200, 100),    -- Orange  
    freePet = Color3.fromRGB(255, 100, 100),     -- Red
    rarePet = Color3.fromRGB(255, 100, 255)      -- Magenta
}

-- ========================================================
-- SIMPLE PET FUNCTIONS
-- ========================================================

local function isSimplePet(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    
    -- Simple pet patterns
    local petWords = {"pet", "companion", "follow", "dragon", "cat", "dog", "wolf", "bird", "bear"}
    
    for _, word in ipairs(petWords) do
        if name:find(word) then
            return true
        end
    end
    
    -- Check if it's a small model with humanoid
    if obj:IsA("Model") then
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
        
        if humanoid and rootPart and rootPart.Size.Y < 8 then
            return true
        end
    end
    
    return false
end

local function getSimplePetOwner(petObj)
    -- Quick owner detection
    local parent = petObj.Parent
    
    -- Check if it's in a player
    while parent do
        if parent.Parent == Players then
            return parent.Name
        end
        parent = parent.Parent
    end
    
    -- Find closest player (simple method)
    if petObj:FindFirstChild("HumanoidRootPart") then
        local petPos = petObj.HumanoidRootPart.Position
        local closestDist = math.huge
        local closestPlayer = nil
        
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (player.Character.HumanoidRootPart.Position - petPos).Magnitude
                if dist < closestDist and dist < 30 then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
        
        if closestPlayer then
            return closestPlayer.Name
        end
    end
    
    return "Free"
end

local function createSimplePetESP(petObj)
    local owner = getSimplePetOwner(petObj)
    local color = colors.otherPet
    local petType = "Other"
    
    -- Determine color based on owner
    if owner == LocalPlayer.Name then
        color = colors.yourPet
        petType = "Yours"
    elseif owner == "Free" then
        color = colors.freePet
        petType = "Free"
    end
    
    -- Check for rare pets (simple)
    local name = petObj.Name:lower()
    if name:find("legendary") or name:find("golden") or name:find("rainbow") then
        color = colors.rarePet
        petType = petType .. " (RARE)"
    end
    
    -- Create ESP
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SimplePetESP"
    billboard.Adornee = petObj:FindFirstChild("HumanoidRootPart") or petObj:FindFirstChild("Torso") or petObj
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    
    -- Background
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Pet name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "🐾 " .. petObj.Name
    nameLabel.TextColor3 = color
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Parent = frame
    
    -- Info label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0.4, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.6, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = petType .. " • 0m"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextStrokeTransparency = 0
    infoLabel.Parent = frame
    
    -- Highlight box
    if petObj:FindFirstChild("HumanoidRootPart") then
        local highlight = Instance.new("SelectionBox")
        highlight.Name = "PetHighlight"
        highlight.Adornee = petObj.HumanoidRootPart
        highlight.Color3 = color
        highlight.LineThickness = 0.2
        highlight.Transparency = 0.7
        highlight.Parent = billboard
    end
    
    billboard.Parent = petObj
    
    -- Store ESP data
    petESPs[petObj] = {
        billboard = billboard,
        infoLabel = infoLabel,
        petType = petType,
        owner = owner
    }
    
    return billboard
end
local function scanSimplePets()
    print("🔍 Quick pet scan starting...")
    local petCount = 0
    
    -- Scan workspace for pets (limited for performance)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if petCount >= 100 then break end -- Limit for performance
        
        pcall(function()
            if isSimplePet(obj) then
                createSimplePetESP(obj)
                petCount = petCount + 1
                print("🐾 Found pet: " .. obj.Name)
            end
        end)
    end
    
    -- Scan player characters
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, obj in pairs(player.Character:GetChildren()) do
                pcall(function()
                    if isSimplePet(obj) then
                        createSimplePetESP(obj)
                        petCount = petCount + 1
                        print("🐾 Found player pet: " .. obj.Name .. " (Player: " .. player.Name .. ")")
                    end
                end)
            end
        end
    end
    
    print("✅ Simple pet ESP loaded! Pets found: " .. petCount)
    return petCount
end

local function updatePetDistances()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    for petObj, espData in pairs(petESPs) do
        if petObj and petObj.Parent and espData.billboard then
            local petPos
            
            -- Get pet position
            if petObj:FindFirstChild("HumanoidRootPart") then
                petPos = petObj.HumanoidRootPart.Position
            elseif petObj:FindFirstChild("Torso") then
                petPos = petObj.Torso.Position
            end
            
            if petPos then
                local distance = math.floor((playerPos - petPos).Magnitude)
                
                -- Show/hide based on distance
                espData.billboard.Enabled = distance <= maxDistance and espActive
                
                -- Update distance text
                if espData.billboard.Enabled and espData.infoLabel then
                    espData.infoLabel.Text = espData.petType .. " • " .. distance .. "m"
                end
            end
        else
            -- Clean up invalid ESP
            petESPs[petObj] = nil
        end
    end
end

local function removeAllPetESP()
    print("🧹 Removing all pet ESP...")
    
    for petObj, espData in pairs(petESPs) do
        if espData.billboard then
            espData.billboard:Destroy()
        end
    end
    
    petESPs = {}
    print("✅ Pet ESP cleared!")
end

local function togglePetESP()
    espActive = not espActive
    
    for _, espData in pairs(petESPs) do
        if espData.billboard then
            espData.billboard.Enabled = espActive
        end
    end
    
    print("🎯 Pet ESP " .. (espActive and "ENABLED" or "DISABLED"))
    return espActive
end

local function changeMaxDistance()
    local distances = {150, 250, 350, 500}
    local currentIndex = 1
    
    for i, dist in ipairs(distances) do
        if dist == maxDistance then
            currentIndex = i
            break
        end
    end
    
    currentIndex = currentIndex + 1
    if currentIndex > #distances then
        currentIndex = 1
    end
    
    maxDistance = distances[currentIndex]
    print("📏 Max distance changed to: " .. maxDistance .. "m")
    return maxDistance
end

-- ========================================================
-- SIMPLE CONTROL GUI
-- ========================================================

local function createSimpleControl()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SimplePetESPControl"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui
    
    -- Control frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(0, 20, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "🐾 PET ESP CONTROL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 12
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, -10, 0, 25)
    toggleButton.Position = UDim2.new(0, 5, 0, 30)
    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
    toggleButton.Text = "🎯 ESP: ON"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 11
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggleButton
    
    -- Distance button
    local distanceButton = Instance.new("TextButton")
    distanceButton.Size = UDim2.new(1, -10, 0, 25)
    distanceButton.Position = UDim2.new(0, 5, 0, 60)
    distanceButton.BackgroundColor3 = Color3.fromRGB(80, 80, 150)
    distanceButton.Text = "📏 DISTANCE: " .. maxDistance .. "m"
    distanceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceButton.TextSize = 11
    distanceButton.Font = Enum.Font.SourceSansBold
    distanceButton.BorderSizePixel = 0
    distanceButton.Parent = frame
    
    local distanceCorner = Instance.new("UICorner")
    distanceCorner.CornerRadius = UDim.new(0, 4)
    distanceCorner.Parent = distanceButton
    
    -- Rescan button
    local rescanButton = Instance.new("TextButton")
    rescanButton.Size = UDim2.new(1, -10, 0, 25)
    rescanButton.Position = UDim2.new(0, 5, 0, 90)
    rescanButton.BackgroundColor3 = Color3.fromRGB(150, 80, 150)
    rescanButton.Text = "🔄 RESCAN PETS"
    rescanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rescanButton.TextSize = 11
    rescanButton.Font = Enum.Font.SourceSansBold
    rescanButton.BorderSizePixel = 0
    rescanButton.Parent = frame
    
    local rescanCorner = Instance.new("UICorner")
    rescanCorner.CornerRadius = UDim.new(0, 4)
    rescanCorner.Parent = rescanButton
    
    -- Button events
    toggleButton.MouseButton1Click:Connect(function()
        local active = togglePetESP()
        toggleButton.Text = "🎯 ESP: " .. (active and "ON" or "OFF")
        toggleButton.BackgroundColor3 = active and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(150, 80, 80)
    end)
    
    distanceButton.MouseButton1Click:Connect(function()
        local newDistance = changeMaxDistance()
        distanceButton.Text = "📏 DISTANCE: " .. newDistance .. "m"
    end)
    
    rescanButton.MouseButton1Click:Connect(function()
        rescanButton.Text = "⏳ SCANNING..."
        removeAllPetESP()
        task.wait(0.1)
        local count = scanSimplePets()
        rescanButton.Text = "🔄 RESCAN PETS"
        print("🔄 Rescanned: " .. count .. " pets found")
    end)
    
    return gui
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Starting Simple Pet ESP...")

-- Create control GUI
local controlGUI = createSimpleControl()

-- Start pet ESP
local petCount = scanSimplePets()

-- Start update loop
updateConnection = RunService.Heartbeat:Connect(function()
    if espActive then
        updatePetDistances()
    end
end)

print("✅ SIMPLE PET ESP READY!")
print("=========================")
print("🐾 Pets detected: " .. petCount)
print("📏 Max distance: " .. maxDistance .. "m")
print("🎮 Use control panel to manage ESP")
print("=========================")
print("💡 Color Coding:")
print("   🟢 Green = Your pets")
print("   🟠 Orange = Other player pets")
print("   🔴 Red = Free/wild pets")
print("   🟣 Magenta = Rare pets")
print("=========================")
print("⚡ Lightweight and fast!")

-- Export functions
getgenv().toggleSimplePetESP = togglePetESP
getgenv().rescanPets = function()
    removeAllPetESP()
    return scanSimplePets()
end
getgenv().clearPetESP = removeAllPetESP

-- Cleanup on character reset
if LocalPlayer.Character then
    LocalPlayer.Character.AncestryChanged:Connect(function()
        if not LocalPlayer.Character.Parent then
            removeAllPetESP()
            if updateConnection then
                updateConnection:Disconnect()
            end
            if controlGUI then
                controlGUI:Destroy()
            end
        end
    end)
end