-- ========================================================
-- MUIHUB STYLE GUI - Sidebar + Collapsible Sections
-- FIXED SIZE (No auto-scaling)
-- ========================================================

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MuiHubStyleGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentGui

-- Fixed dimensions (bigger, readable size)
local guiWidth = 900
local guiHeight = 400
local sidebarWidth = 220

print("📦 GUI Size:", guiWidth, "x", guiHeight, "(Fixed)")

-- Main Container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, guiWidth, 0, guiHeight)
mainFrame.Position = UDim2.new(0.5, -guiWidth/2, 0.5, -guiHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 70)
topBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local topCover = Instance.new("Frame")
topCover.Size = UDim2.new(1, 0, 0, 12)
topCover.Position = UDim2.new(0, 0, 1, -12)
topCover.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
topCover.BorderSizePixel = 0
topCover.Parent = topBar

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 300, 0, 30)
titleLabel.Position = UDim2.new(0, 20, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "EggHub | http://discord.gg/egghub"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 300, 0, 20)
subtitleLabel.Position = UDim2.new(0, 20, 0, 35)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Steal An Egg"
subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
subtitleLabel.TextSize = 14
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = topBar

-- Window Control Buttons
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 20)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local maximizeBtn = Instance.new("TextButton")
maximizeBtn.Size = UDim2.new(0, 30, 0, 30)
maximizeBtn.Position = UDim2.new(1, -75, 0, 20)
maximizeBtn.BackgroundTransparency = 1
maximizeBtn.Text = "[ ]"
maximizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
maximizeBtn.TextSize = 14
maximizeBtn.Font = Enum.Font.GothamBold
maximizeBtn.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -110, 0, 20)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = topBar

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 250, 1, -70)
sidebar.Position = UDim2.new(0, 0, 0, 70)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

-- Search Bar in Sidebar
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, -30, 0, 45)
searchFrame.Position = UDim2.new(0, 15, 0, 20)
searchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
searchFrame.BorderSizePixel = 0
searchFrame.Parent = sidebar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 10)
searchCorner.Parent = searchFrame

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 40, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextColor3 = Color3.fromRGB(120, 120, 140)
searchIcon.TextSize = 16
searchIcon.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -45, 1, 0)
searchBox.Position = UDim2.new(0, 40, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Search..."
searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = searchFrame

-- Sidebar Menu Items
local menuItems = {
    {icon = "🥚", name = "Farm", selected = true},
    {icon = "👣", name = "Movement", selected = false},
    {icon = "📦", name = "Etc", selected = false},
    {icon = "⚙️", name = "Settings", selected = false}
}

local selectedMenu = 1

for i, item in ipairs(menuItems) do
    local menuBtn = Instance.new("TextButton")
    menuBtn.Size = UDim2.new(1, -30, 0, 50)
    menuBtn.Position = UDim2.new(0, 15, 0, 80 + (i-1) * 60)
    menuBtn.BackgroundColor3 = item.selected and Color3.fromRGB(110, 70, 200) or Color3.fromRGB(30, 30, 40)
    menuBtn.BorderSizePixel = 0
    menuBtn.Text = ""
    menuBtn.Parent = sidebar
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 10)
    menuCorner.Parent = menuBtn
    
    -- Purple bar on left
    if item.selected then
        local purpleBar = Instance.new("Frame")
        purpleBar.Size = UDim2.new(0, 4, 0, 30)
        purpleBar.Position = UDim2.new(0, 5, 0.5, -15)
        purpleBar.BackgroundColor3 = Color3.fromRGB(150, 90, 255)
        purpleBar.BorderSizePixel = 0
        purpleBar.Parent = menuBtn
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = purpleBar
    end
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 15, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = item.icon
    iconLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    iconLabel.TextSize = 20
    iconLabel.Parent = menuBtn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 1, 0)
    nameLabel.Position = UDim2.new(0, 55, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = item.name
    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = menuBtn
end

-- Content Area
local contentArea = Instance.new("ScrollingFrame")
contentArea.Size = UDim2.new(1, -270, 1, -90)
contentArea.Position = UDim2.new(0, 260, 0, 80)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.ScrollBarThickness = 6
contentArea.ScrollBarImageColor3 = Color3.fromRGB(110, 70, 200)
contentArea.CanvasSize = UDim2.new(0, 0, 0, 800)
contentArea.Parent = mainFrame

-- Collapsible Section Template
local function createSection(title, yPos, content)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 60)
    section.Position = UDim2.new(0, 10, 0, yPos)
    section.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    section.BorderSizePixel = 0
    section.Parent = contentArea
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 10)
    sectionCorner.Parent = section
    
    -- Purple accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, -10)
    accentBar.Position = UDim2.new(0, 5, 0, 5)
    accentBar.BackgroundColor3 = Color3.fromRGB(150, 90, 255)
    accentBar.BorderSizePixel = 0
    accentBar.Parent = section
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accentBar
    
    -- Title Button
    local titleBtn = Instance.new("TextButton")
    titleBtn.Size = UDim2.new(1, 0, 0, 60)
    titleBtn.BackgroundTransparency = 1
    titleBtn.Text = ""
    titleBtn.Parent = section
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    local expandBtn = Instance.new("TextLabel")
    expandBtn.Size = UDim2.new(0, 40, 1, 0)
    expandBtn.Position = UDim2.new(1, -50, 0, 0)
    expandBtn.BackgroundTransparency = 1
    expandBtn.Text = "+"
    expandBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    expandBtn.TextSize = 24
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.Parent = section
    
    -- Content Frame (hidden by default)
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 60)
    contentFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    contentFrame.BorderSizePixel = 0
    contentFrame.Visible = false
    contentFrame.Parent = section
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 10)
    contentCorner.Parent = contentFrame
    
    local isExpanded = false
    
    titleBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        
        if isExpanded then
            expandBtn.Text = "-"
            contentFrame.Visible = true
            section:TweenSize(
                UDim2.new(1, -20, 0, 60 + content.height),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true
            )
            contentFrame:TweenSize(
                UDim2.new(1, 0, 0, content.height),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true
            )
        else
            expandBtn.Text = "+"
            section:TweenSize(
                UDim2.new(1, -20, 0, 60),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true
            )
            contentFrame:TweenSize(
                UDim2.new(1, 0, 0, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true,
                function()
                    if not isExpanded then
                        contentFrame.Visible = false
                    end
                end
            )
        end
    end)
    
    return contentFrame
end

-- FARM EGG Section
local farmContent = createSection("FARM EGG", 10, {height = 300})

local farmScroll = Instance.new("ScrollingFrame")
farmScroll.Size = UDim2.new(1, -20, 1, -20)
farmScroll.Position = UDim2.new(0, 10, 0, 10)
farmScroll.BackgroundTransparency = 1
farmScroll.BorderSizePixel = 0
farmScroll.ScrollBarThickness = 4
farmScroll.ScrollBarImageColor3 = Color3.fromRGB(110, 70, 200)
farmScroll.CanvasSize = UDim2.new(0, 0, 0, 450)
farmScroll.Parent = farmContent

-- Area Checkboxes in Farm
local areas = {"FOREST", "LAKE", "DESERT", "JUNGLE", "SNOW", "VOLCANO", "ABYSS OCEAN", "PREHISTORIC", "COSMIC"}

for i, area in ipairs(areas) do
    local areaBtn = Instance.new("TextButton")
    areaBtn.Size = UDim2.new(1, -10, 0, 35)
    areaBtn.Position = UDim2.new(0, 5, 0, (i-1) * 40)
    areaBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    areaBtn.BorderSizePixel = 0
    areaBtn.Text = ""
    areaBtn.Parent = farmScroll
    
    local areaCorner = Instance.new("UICorner")
    areaCorner.CornerRadius = UDim.new(0, 8)
    areaCorner.Parent = areaBtn
    
    local checkbox = Instance.new("Frame")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 10, 0.5, -10)
    checkbox.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    checkbox.BorderSizePixel = 0
    checkbox.Parent = areaBtn
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 5)
    checkCorner.Parent = checkbox
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = ""
    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkmark.TextSize = 14
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Parent = checkbox
    
    local areaLabel = Instance.new("TextLabel")
    areaLabel.Size = UDim2.new(1, -45, 1, 0)
    areaLabel.Position = UDim2.new(0, 40, 0, 0)
    areaLabel.BackgroundTransparency = 1
    areaLabel.Text = area
    areaLabel.TextColor3 = areaColors[area]
    areaLabel.TextSize = 14
    areaLabel.Font = Enum.Font.GothamBold
    areaLabel.TextXAlignment = Enum.TextXAlignment.Left
    areaLabel.Parent = areaBtn
    
    areaBtn.MouseButton1Click:Connect(function()
        CONFIG.AreaFilters[area] = not CONFIG.AreaFilters[area]
        
        if CONFIG.AreaFilters[area] then
            checkbox.BackgroundColor3 = areaColors[area]
            checkmark.Text = "✓"
        else
            checkbox.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            checkmark.Text = ""
        end
    end)
end

-- Action Buttons in Farm
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(0.48, -5, 0, 40)
stealBtn.Position = UDim2.new(0, 5, 0, 370)
stealBtn.BackgroundColor3 = Color3.fromRGB(110, 70, 200)
stealBtn.Text = "🥚 STEAL ONCE"
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.TextSize = 14
stealBtn.Font = Enum.Font.GothamBold
stealBtn.Parent = farmScroll

local stealCorner = Instance.new("UICorner")
stealCorner.CornerRadius = UDim.new(0, 8)
stealCorner.Parent = stealBtn

stealBtn.MouseButton1Click:Connect(function()
    stealBtn.Text = "⏳ Working..."
    local success = autoStealCycle()
    if success then
        stealBtn.Text = "✅ Success!"
    else
        stealBtn.Text = "❌ Failed"
    end
    task.wait(2)
    stealBtn.Text = "🥚 STEAL ONCE"
end)

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.48, -5, 0, 40)
autoBtn.Position = UDim2.new(0.52, 0, 0, 370)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
autoBtn.Text = "🔄 AUTO: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 14
autoBtn.Font = Enum.Font.GothamBold
autoBtn.Parent = farmScroll

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 8)
autoCorner.Parent = autoBtn

autoBtn.MouseButton1Click:Connect(function()
    CONFIG.StealEnabled = not CONFIG.StealEnabled
    if CONFIG.StealEnabled then
        autoBtn.Text = "🔄 AUTO: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
    else
        autoBtn.Text = "🔄 AUTO: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    end
end)

-- AUTO SPEED Section
local speedContent = createSection("AUTO SPEED", 80, {height = 150})

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "🚀 Flight Speed (100-600)"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedContent

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, -20, 0, 40)
speedInput.Position = UDim2.new(0, 10, 0, 40)
speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
speedInput.BorderSizePixel = 0
speedInput.Text = tostring(CONFIG.FlySpeed)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 16
speedInput.Font = Enum.Font.GothamBold
speedInput.Parent = speedContent

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 8)
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

local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(1, -20, 0, 25)
heightLabel.Position = UDim2.new(0, 10, 0, 90)
heightLabel.BackgroundTransparency = 1
heightLabel.Text = "⬆️ Flight Height (100-300)"
heightLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
heightLabel.TextSize = 14
heightLabel.Font = Enum.Font.GothamBold
heightLabel.TextXAlignment = Enum.TextXAlignment.Left
heightLabel.Parent = speedContent

-- AUTO SELL Section
createSection("AUTO SELL", 150, {height = 100})

-- Protection Section
local protectContent = createSection("PROTECTION", 220, {height = 150})

local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(1, -20, 0, 40)
espToggle.Position = UDim2.new(0, 10, 0, 10)
espToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
espToggle.Text = "👁️ ESP: ON"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.TextSize = 14
espToggle.Font = Enum.Font.GothamBold
espToggle.Parent = protectContent

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
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

local godToggle = Instance.new("TextButton")
godToggle.Size = UDim2.new(1, -20, 0, 40)
godToggle.Position = UDim2.new(0, 10, 0, 60)
godToggle.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
godToggle.Text = "✨ GOD MODE: ON"
godToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
godToggle.TextSize = 14
godToggle.Font = Enum.Font.GothamBold
godToggle.Parent = protectContent

local godCorner = Instance.new("UICorner")
godCorner.CornerRadius = UDim.new(0, 8)
godCorner.Parent = godToggle

local godModeEnabled = true

godToggle.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        godToggle.Text = "✨ GOD MODE: ON"
        godToggle.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
        humanoid.Health = math.huge
        humanoid.MaxHealth = math.huge
    else
        godToggle.Text = "✨ GOD MODE: OFF"
        godToggle.BackgroundColor3 = Color3.fromRGB(127, 140, 141)
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end
end)

-- Minimize/Maximize Logic
local isMinimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(
            UDim2.new(0, 900, 0, 70),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        sidebar.Visible = false
        contentArea.Visible = false
    else
        mainFrame:TweenSize(
            UDim2.new(0, 900, 0, 550),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        task.wait(0.1)
        sidebar.Visible = true
        contentArea.Visible = true
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
                autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            else
                task.wait(2)
            end
        else
            task.wait(1)
        end
    end
end)

print("========================================")
print("✅ MUIHUB STYLE GUI LOADED!")
print("🎨 Sidebar + Collapsible Sections")
print("========================================")
