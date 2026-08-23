-- This file contains ONLY the modern UI replacement for auto_steal_HIGH_FLY.lua
-- Copy the entire GUI section and replace the old one in the main file

-- ========================================================
-- MODERN GUI WITH TABS AND MINIMIZE
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernHighFlyStealGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

-- Main Container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 550)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainShadow = Instance.new("ImageLabel")
mainShadow.Name = "Shadow"
mainShadow.Size = UDim2.new(1, 30, 1, 30)
mainShadow.Position = UDim2.new(0, -15, 0, -15)
mainShadow.BackgroundTransparency = 1
mainShadow.Image = "rbxassetid://5554236805"
mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
mainShadow.ImageTransparency = 0.5
mainShadow.ScaleType = Enum.ScaleType.Slice
mainShadow.SliceCenter = Rect.new(23, 23, 277, 277)
mainShadow.Parent = mainFrame
mainShadow.ZIndex = 0

-- Title Bar with Gradient
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleCover = Instance.new("Frame")
titleCover.Size = UDim2.new(1, 0, 0, 16)
titleCover.Position = UDim2.new(0, 0, 1, -16)
titleCover.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
titleCover.BorderSizePixel = 0
titleCover.Parent = titleBar

-- Gradient on title
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 80, 255))
}
titleGradient.Rotation = 45
titleGradient.Parent = titleBar

-- Title Icon
local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 40, 0, 40)
titleIcon.Position = UDim2.new(0, 10, 0, 10)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "🚀"
titleIcon.TextSize = 28
titleIcon.Parent = titleBar

-- Title Text
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.Position = UDim2.new(0, 55, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "High Fly Steal PRO"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local titleSubtext = Instance.new("TextLabel")
titleSubtext.Size = UDim2.new(1, -120, 0, 20)
titleSubtext.Position = UDim2.new(0, 55, 0, 30)
titleSubtext.BackgroundTransparency = 1
titleSubtext.Text = "Guard Avoidance System"
titleSubtext.TextColor3 = Color3.fromRGB(200, 200, 255)
titleSubtext.TextSize = 11
titleSubtext.Font = Enum.Font.Gotham
titleSubtext.TextXAlignment = Enum.TextXAlignment.Left
titleSubtext.Parent = titleBar

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(1, -50, 0, 10)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minimizeBtn.Text = "➖"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 10)
minimizeCorner.Parent = minimizeBtn

-- Content Container (this gets hidden on minimize)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -60)
contentFrame.Position = UDim2.new(0, 0, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Status Bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 60)
statusBar.Position = UDim2.new(0, 10, 0, 10)
statusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusBar.BorderSizePixel = 0
statusBar.Parent = contentFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = statusBar

-- ESP Counter
local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0.5, -5, 0, 25)
espLabel.Position = UDim2.new(0, 10, 0, 8)
espLabel.BackgroundTransparency = 1
espLabel.Text = "👁️ ESP: 0 eggs"
espLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
espLabel.TextSize = 12
espLabel.Font = Enum.Font.GothamBold
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Parent = statusBar

-- Night Status
local nightLabel = Instance.new("TextLabel")
nightLabel.Size = UDim2.new(0.5, -5, 0, 25)
nightLabel.Position = UDim2.new(0.5, 0, 0, 8)
nightLabel.BackgroundTransparency = 1
nightLabel.Text = "☀️ Day"
nightLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
nightLabel.TextSize = 12
nightLabel.Font = Enum.Font.GothamBold
nightLabel.TextXAlignment = Enum.TextXAlignment.Right
nightLabel.Parent = statusBar

-- Safe Zone Info
local safeZoneLabel = Instance.new("TextLabel")
safeZoneLabel.Size = UDim2.new(1, -20, 0, 20)
safeZoneLabel.Position = UDim2.new(0, 10, 0, 35)
safeZoneLabel.BackgroundTransparency = 1
safeZoneLabel.Text = "📍 Safe Zone: X=537, Y=70, Z=-356"
safeZoneLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
safeZoneLabel.TextSize = 10
safeZoneLabel.Font = Enum.Font.Gotham
safeZoneLabel.TextXAlignment = Enum.TextXAlignment.Left
safeZoneLabel.Parent = statusBar

-- Tab System
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 80)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = contentFrame

local tabs = {"🎯 Areas", "⚙️ Settings", "🛡️ Protection"}
local tabButtons = {}
local tabContents = {}

for i, tabName in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1/3, -5, 1, 0)
    tabBtn.Position = UDim2.new((i-1)/3, (i-1)*5, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 170)
    tabBtn.TextSize = 13
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabBtn
    
    tabButtons[i] = tabBtn
    
    -- Tab Content Frame
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, -20, 1, -140)
    tabContent.Position = UDim2.new(0, 10, 0, 130)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 600)
    tabContent.Visible = (i == 1)
    tabContent.Parent = contentFrame
    
    tabContents[i] = tabContent
end

-- Tab switching logic
for i, btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for j, otherBtn in ipairs(tabButtons) do
            if j == i then
                otherBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                otherBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                tabContents[j].Visible = true
            else
                otherBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                otherBtn.TextColor3 = Color3.fromRGB(150, 150, 170)
                tabContents[j].Visible = false
            end
        end
    end)
end

-- Set first tab as active
tabButtons[1].BackgroundColor3 = Color3.fromRGB(138, 43, 226)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ========================================================
-- TAB 1: AREAS
-- ========================================================

local areasTab = tabContents[1]

local areas = {"FOREST", "LAKE", "DESERT", "JUNGLE", "SNOW", "VOLCANO", "ABYSS OCEAN", "PREHISTORIC", "COSMIC"}

for i, area in ipairs(areas) do
    local yPos = (i - 1) * 45
    
    local areaFrame = Instance.new("Frame")
    areaFrame.Size = UDim2.new(1, -10, 0, 40)
    areaFrame.Position = UDim2.new(0, 5, 0, yPos)
    areaFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    areaFrame.BorderSizePixel = 0
    areaFrame.Parent = areasTab
    
    local areaCorner = Instance.new("UICorner")
    areaCorner.CornerRadius = UDim.new(0, 8)
    areaCorner.Parent = areaFrame
    
    -- Checkbox
    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 35, 0, 35)
    checkBtn.Position = UDim2.new(0, 3, 0.5, -17.5)
    checkBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    checkBtn.Text = ""
    checkBtn.TextSize = 18
    checkBtn.Font = Enum.Font.GothamBold
    checkBtn.Parent = areaFrame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 8)
    checkCorner.Parent = checkBtn
    
    -- Area Name
    local areaLabel = Instance.new("TextLabel")
    areaLabel.Size = UDim2.new(1, -45, 1, 0)
    areaLabel.Position = UDim2.new(0, 45, 0, 0)
    areaLabel.BackgroundTransparency = 1
    areaLabel.Text = area
    areaLabel.TextColor3 = areaColors[area]
    areaLabel.TextSize = 14
    areaLabel.Font = Enum.Font.GothamBold
    areaLabel.TextXAlignment = Enum.TextXAlignment.Left
    areaLabel.Parent = areaFrame
    
    checkBtn.MouseButton1Click:Connect(function()
        CONFIG.AreaFilters[area] = not CONFIG.AreaFilters[area]
        
        if CONFIG.AreaFilters[area] then
            checkBtn.Text = "✓"
            checkBtn.BackgroundColor3 = areaColors[area]
            checkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            checkBtn.Text = ""
            checkBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
    end)
end

-- ========================================================
-- TAB 2: SETTINGS
-- ========================================================

local settingsTab = tabContents[2]

-- Fly Speed Setting
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -10, 0, 70)
speedFrame.Position = UDim2.new(0, 5, 0, 0)
speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = settingsTab

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedFrame

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -20, 0, 25)
speedTitle.Position = UDim2.new(0, 10, 0, 5)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "🚀 Flight Speed"
speedTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
speedTitle.TextSize = 14
speedTitle.Font = Enum.Font.GothamBold
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.Parent = speedFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, -20, 0, 30)
speedInput.Position = UDim2.new(0, 10, 0, 32)
speedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
speedInput.BorderSizePixel = 0
speedInput.Text = tostring(CONFIG.FlySpeed)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 16
speedInput.Font = Enum.Font.GothamBold
speedInput.PlaceholderText = "100-600"
speedInput.Parent = speedFrame

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 6)
speedInputCorner.Parent = speedInput

speedInput.FocusLost:Connect(function()
    local value = tonumber(speedInput.Text)
    if value then
        value = math.clamp(value, 100, 600)
        CONFIG.FlySpeed = value
        speedInput.Text = tostring(value)
    else
        speedInput.Text = tostring(CONFIG.FlySpeed)
    end
end)

-- Fly Height Setting
local heightFrame = Instance.new("Frame")
heightFrame.Size = UDim2.new(1, -10, 0, 70)
heightFrame.Position = UDim2.new(0, 5, 0, 80)
heightFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
heightFrame.BorderSizePixel = 0
heightFrame.Parent = settingsTab

local heightCorner = Instance.new("UICorner")
heightCorner.CornerRadius = UDim.new(0, 8)
heightCorner.Parent = heightFrame

local heightTitle = Instance.new("TextLabel")
heightTitle.Size = UDim2.new(1, -20, 0, 25)
heightTitle.Position = UDim2.new(0, 10, 0, 5)
heightTitle.BackgroundTransparency = 1
heightTitle.Text = "⬆️ Flight Height"
heightTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
heightTitle.TextSize = 14
heightTitle.Font = Enum.Font.GothamBold
heightTitle.TextXAlignment = Enum.TextXAlignment.Left
heightTitle.Parent = heightFrame

local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(1, -20, 0, 30)
heightInput.Position = UDim2.new(0, 10, 0, 32)
heightInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
heightInput.BorderSizePixel = 0
heightInput.Text = tostring(CONFIG.FlyHeight)
heightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
heightInput.TextSize = 16
heightInput.Font = Enum.Font.GothamBold
heightInput.PlaceholderText = "100-300"
heightInput.Parent = heightFrame

local heightInputCorner = Instance.new("UICorner")
heightInputCorner.CornerRadius = UDim.new(0, 6)
heightInputCorner.Parent = heightInput

heightInput.FocusLost:Connect(function()
    local value = tonumber(heightInput.Text)
    if value then
        value = math.clamp(value, 100, 300)
        CONFIG.FlyHeight = value
        heightInput.Text = tostring(value)
    else
        heightInput.Text = tostring(CONFIG.FlyHeight)
    end
end)

-- ========================================================
-- TAB 3: PROTECTION
-- ========================================================

local protectionTab = tabContents[3]

-- ESP Toggle
local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(1, -10, 0, 45)
espToggle.Position = UDim2.new(0, 5, 0, 0)
espToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
espToggle.Text = "👁️ ESP: ON"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.TextSize = 16
espToggle.Font = Enum.Font.GothamBold
espToggle.Parent = protectionTab

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 10)
espCorner.Parent = espToggle

espToggle.MouseButton1Click:Connect(function()
    CONFIG.ESPEnabled = not CONFIG.ESPEnabled
    if CONFIG.ESPEnabled then
        espToggle.Text = "👁️ ESP: ON"
        espToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        espToggle.Text = "👁️ ESP: OFF"
        espToggle.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- God Mode Toggle
local godToggle = Instance.new("TextButton")
godToggle.Size = UDim2.new(1, -10, 0, 45)
godToggle.Position = UDim2.new(0, 5, 0, 55)
godToggle.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
godToggle.Text = "✨ GOD MODE: ON"
godToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
godToggle.TextSize = 16
godToggle.Font = Enum.Font.GothamBold
godToggle.Parent = protectionTab

local godCorner = Instance.new("UICorner")
godCorner.CornerRadius = UDim.new(0, 10)
godCorner.Parent = godToggle

local godModeEnabled = true

godToggle.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        godToggle.Text = "✨ GOD MODE: ON"
        godToggle.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
        humanoid.Health = math.huge
        humanoid.MaxHealth = math.huge
        print("✨ God Mode ON")
    else
        godToggle.Text = "✨ GOD MODE: OFF"
        godToggle.BackgroundColor3 = Color3.fromRGB(127, 140, 141)
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        print("✨ God Mode OFF")
    end
end)

-- ========================================================
-- ACTION BUTTONS (Always Visible at Bottom)
-- ========================================================

local actionBar = Instance.new("Frame")
actionBar.Size = UDim2.new(1, -20, 0, 50)
actionBar.Position = UDim2.new(0, 10, 1, -60)
actionBar.BackgroundTransparency = 1
actionBar.Parent = contentFrame

-- Steal Once Button
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(0.48, 0, 1, 0)
stealBtn.Position = UDim2.new(0, 0, 0, 0)
stealBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
stealBtn.Text = "🥚 STEAL ONCE"
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.TextSize = 15
stealBtn.Font = Enum.Font.GothamBold
stealBtn.Parent = actionBar

local stealCorner = Instance.new("UICorner")
stealCorner.CornerRadius = UDim.new(0, 10)
stealCorner.Parent = stealBtn

stealBtn.MouseButton1Click:Connect(function()
    stealBtn.Text = "⏳ Flying..."
    
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
autoBtn.Size = UDim2.new(0.48, 0, 1, 0)
autoBtn.Position = UDim2.new(0.52, 0, 0, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoBtn.Text = "🔄 AUTO: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 15
autoBtn.Font = Enum.Font.GothamBold
autoBtn.Parent = actionBar

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 10)
autoCorner.Parent = autoBtn

autoBtn.MouseButton1Click:Connect(function()
    CONFIG.StealEnabled = not CONFIG.StealEnabled
    
    if CONFIG.StealEnabled then
        autoBtn.Text = "🔄 AUTO: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
    else
        autoBtn.Text = "🔄 AUTO: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- ========================================================
-- MINIMIZE FUNCTIONALITY
-- ========================================================

local isMinimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        mainFrame:TweenSize(
            UDim2.new(0, 450, 0, 60),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        contentFrame.Visible = false
        minimizeBtn.Text = "➕"
    else
        mainFrame:TweenSize(
            UDim2.new(0, 450, 0, 550),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        task.wait(0.1)
        contentFrame.Visible = true
        minimizeBtn.Text = "➖"
    end
end)

-- ========================================================
-- STATUS UPDATERS
-- ========================================================

-- Update ESP Counter
task.spawn(function()
    while screenGui.Parent do
        task.wait(2)
        espLabel.Text = "👁️ ESP: " .. eggCounter .. " eggs"
        
        -- Update night status
        local isNight, clockTime = isNightTime()
        if isNight then
            nightLabel.Text = "🌙 Night (" .. string.format("%.1f", clockTime) .. "h)"
            nightLabel.TextColor3 = Color3.fromRGB(100, 100, 200)
        else
            nightLabel.Text = "☀️ Day (" .. string.format("%.1f", clockTime) .. "h)"
            nightLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end
end)

-- Auto Loop
task.spawn(function()
    while true do
        if CONFIG.StealEnabled then
            local success = autoStealCycle()
            
            if success then
                CONFIG.StealEnabled = false
                autoBtn.Text = "🔄 AUTO: OFF"
                autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                print("\n🎉 EGG STOLEN! Loop stopped")
            else
                task.wait(2)
            end
        else
            task.wait(1)
        end
    end
end)

print("========================================")
print("✅ MODERN GUI LOADED!")
print("🎨 Tabbed interface with minimize")
print("📁 Categories: Areas | Settings | Protection")
print("========================================")
