-- ========================================================
-- SIMPLE WORKSPACE ESP - QUICK & LIGHTWEIGHT
-- ESP sederhana untuk semua objek di workspace
-- ========================================================

print("🎯 LOADING SIMPLE WORKSPACE ESP...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========================================================
-- ESP SETTINGS & DATA
-- ========================================================

local espActive = true
local maxDistance = 300
local espObjects = {}

local colors = {
    pets = Color3.fromRGB(255, 200, 100),      -- Orange
    eggs = Color3.fromRGB(100, 255, 100),      -- Green  
    players = Color3.fromRGB(255, 100, 100),   -- Red
    npcs = Color3.fromRGB(255, 255, 100),      -- Yellow
    tools = Color3.fromRGB(150, 255, 150),     -- Light Green
    vehicles = Color3.fromRGB(100, 100, 255),  -- Blue
    models = Color3.fromRGB(100, 200, 255),    -- Light Blue
    effects = Color3.fromRGB(255, 100, 255),   -- Magenta
    default = Color3.fromRGB(200, 200, 200)    -- Gray
}

-- ========================================================
-- SIMPLE ESP FUNCTIONS
-- ========================================================

local function createSimpleESP(obj, text, color)
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SimpleESP"
    billboard.Adornee = obj
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    
    -- Background frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Text label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = frame
    
    -- Selection box for 3D highlight
    if obj:IsA("BasePart") or obj:IsA("Model") then
        local highlight = Instance.new("SelectionBox")
        highlight.Name = "SimpleHighlight"
        highlight.Adornee = obj
        highlight.Color3 = color
        highlight.LineThickness = 0.2
        highlight.Transparency = 0.8
        highlight.Parent = billboard
    end
    
    return billboard
end

local function getObjectCategory(obj)
    local name = obj.Name:lower()
    local class = obj.ClassName
    
    -- Simple categorization
    if name:find("pet") or name:find("companion") then
        return "pets", "🐾 " .. obj.Name
    elseif name:find("egg") then
        return "eggs", "🥚 " .. obj.Name  
    elseif obj.Parent == Players then
        return "players", "👤 " .. obj.Name
    elseif name:find("npc") or name:find("bot") then
        return "npcs", "🤖 " .. obj.Name
    elseif class:find("Tool") or name:find("sword") or name:find("gun") then
        return "tools", "🔧 " .. obj.Name
    elseif name:find("car") or name:find("vehicle") or name:find("bike") then
        return "vehicles", "🚗 " .. obj.Name
    elseif class:find("Particle") or class:find("Beam") or class:find("Fire") then
        return "effects", "✨ " .. obj.Name
    elseif class == "Model" then
        return "models", "📦 " .. obj.Name
    else
        return "default", "❓ " .. obj.Name
    end
end
local function scanWorkspaceSimple()
    print("🔍 Quick ESP scan starting...")
    local count = 0
    
    -- Scan workspace descendants (limited for performance)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if count >= 500 then break end -- Limit for performance
        
        pcall(function()
            local category, displayText = getObjectCategory(obj)
            
            -- Only ESP important objects to avoid lag
            if category == "pets" or category == "eggs" or category == "npcs" or 
               category == "tools" or category == "vehicles" then
                
                local esp = createSimpleESP(obj, displayText, colors[category])
                
                if esp then
                    esp.Parent = obj
                    espObjects[obj] = esp
                    count = count + 1
                end
            end
        end)
    end
    
    -- Scan players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            pcall(function()
                local esp = createSimpleESP(player.Character, "👤 " .. player.Name, colors.players)
                if esp then
                    esp.Parent = player.Character
                    espObjects[player.Character] = esp
                    count = count + 1
                end
            end)
        end
    end
    
    print("✅ Simple ESP loaded! Objects: " .. count)
    return count
end

local function updateESPDistances()
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
        return
    end
    
    local playerPos = LocalPlayer.Character.PrimaryPart.Position
    
    for obj, esp in pairs(espObjects) do
        if obj and obj.Parent and esp then
            local objPos
            
            -- Get object position
            if obj:IsA("BasePart") then
                objPos = obj.Position
            elseif obj:IsA("Model") and obj.PrimaryPart then
                objPos = obj.PrimaryPart.Position
            elseif obj:IsA("Model") then
                local firstPart = obj:FindFirstChildOfClass("BasePart")
                if firstPart then
                    objPos = firstPart.Position
                end
            end
            
            if objPos then
                local distance = math.floor((playerPos - objPos).Magnitude)
                
                -- Show/hide based on distance
                esp.Enabled = distance <= maxDistance
                
                -- Update text with distance
                if esp.Enabled and esp.Frame and esp.Frame.TextLabel then
                    local originalText = esp.Frame.TextLabel.Text:match("^(.+) %[%d+m%]$") or esp.Frame.TextLabel.Text
                    esp.Frame.TextLabel.Text = originalText .. " [" .. distance .. "m]"
                end
            end
        else
            -- Clean up invalid ESP
            espObjects[obj] = nil
            if esp then esp:Destroy() end
        end
    end
end

local function removeAllESP()
    print("🧹 Removing all ESP...")
    
    for obj, esp in pairs(espObjects) do
        if esp then
            esp:Destroy()
        end
    end
    
    espObjects = {}
    print("✅ ESP cleared!")
end

local function toggleESP()
    espActive = not espActive
    
    for _, esp in pairs(espObjects) do
        if esp then
            esp.Enabled = espActive
        end
    end
    
    print("🎯 ESP " .. (espActive and "ENABLED" or "DISABLED"))
end

-- ========================================================
-- SIMPLE CONTROLS
-- ========================================================

-- Create simple toggle button
local function createToggleButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleESPControl"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 150, 0, 50)
    button.Position = UDim2.new(0, 20, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    button.Text = "🎯 ESP: ON"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.BorderSizePixel = 0
    button.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        toggleESP()
        button.Text = "🎯 ESP: " .. (espActive and "ON" or "OFF")
        button.BackgroundColor3 = espActive and Color3.fromRGB(60, 120, 200) or Color3.fromRGB(120, 60, 60)
    end)
    
    return gui
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Starting Simple Workspace ESP...")

-- Create toggle control
local controlGUI = createToggleButton()

-- Start ESP
local objectCount = scanWorkspaceSimple()

-- Start update loop
local updateConnection = RunService.Heartbeat:Connect(function()
    if espActive then
        updateESPDistances()
    end
end)

print("✅ SIMPLE WORKSPACE ESP READY!")
print("==============================")
print("🎯 ESP Objects: " .. objectCount)
print("📏 Max Distance: " .. maxDistance .. "m")
print("🎮 Click toggle button to control ESP")
print("==============================")
print("💡 Lightweight ESP for key objects:")
print("   🐾 Pets")
print("   🥚 Eggs") 
print("   👤 Players")
print("   🤖 NPCs")
print("   🔧 Tools")
print("   🚗 Vehicles")
print("==============================")
print("⚡ Optimized for performance!")

-- Cleanup function
local function cleanup()
    removeAllESP()
    if updateConnection then
        updateConnection:Disconnect()
    end
    if controlGUI then
        controlGUI:Destroy()
    end
end

-- Auto cleanup on character reset
if LocalPlayer.Character then
    LocalPlayer.Character.AncestryChanged:Connect(function()
        if not LocalPlayer.Character.Parent then
            cleanup()
        end
    end)
end