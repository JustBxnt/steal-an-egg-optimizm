-- ========================================================
-- FREEZE & DISABLE ALL GUARDS - COMPLETE GUARD SHUTDOWN
-- Script untuk membekukan dan menonaktifkan semua guard
-- ========================================================

print("🧊 LOADING FREEZE & DISABLE GUARDS...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- GUARD FREEZE DATA & SETTINGS
-- ========================================================

local freezeData = {
    frozenGuards = {},
    disabledScripts = {},
    frozenHumanoids = {},
    totalFrozen = 0,
    activeConnections = {}
}

local freezeSettings = {
    freezeMovement = true,          -- Bekukan gerakan guard
    disableAttacks = true,          -- Nonaktifkan serangan
    disableScripts = true,          -- Nonaktifkan semua script guard
    disableAI = true,              -- Nonaktifkan AI guard
    makeInvisible = false,         -- Buat invisible (optional)
    continuousFreeze = true,       -- Mode continuous freeze
    showFreezeLog = true          -- Log proses freeze
}

-- ========================================================
-- GUARD DETECTION & FREEZE FUNCTIONS
-- ========================================================

local function isGuardNPC(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    
    -- Guard detection patterns
    local guardPatterns = {
        "guard", "security", "police", "officer", "cop", "sheriff",
        "soldier", "knight", "warrior", "defender", "protector",
        "npc", "bot", "ai", "enemy", "hostile", "patrol", "sentry"
    }
    
    -- Check name patterns
    for _, pattern in ipairs(guardPatterns) do
        if name:find(pattern) then
            return true
        end
    end
    
    -- Check if it's a Model with Humanoid (typical NPC structure)
    if obj:IsA("Model") then
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
        
        if humanoid and rootPart then
            -- Additional checks for guard characteristics
            -- Check for weapons or security equipment
            for _, child in pairs(obj:GetChildren()) do
                local childName = child.Name:lower()
                if childName:find("weapon") or childName:find("gun") or 
                   childName:find("baton") or childName:find("sword") or
                   childName:find("taser") or childName:find("badge") then
                    return true
                end
            end
            
            -- Check if humanoid has specific properties indicating it's a guard
            if humanoid.WalkSpeed > 0 and humanoid.MaxHealth > 50 then
                -- Check if it's not a player character
                local player = Players:GetPlayerFromCharacter(obj)
                if not player then
                    return true -- Likely an NPC guard
                end
            end
        end
    end
    
    return false
end

local function freezeGuard(guardObj)
    if not guardObj or freezeData.frozenGuards[guardObj] then return false end
    
    local humanoid = guardObj:FindFirstChildOfClass("Humanoid")
    local rootPart = guardObj:FindFirstChild("HumanoidRootPart") or guardObj:FindFirstChild("Torso")
    
    if not humanoid or not rootPart then return false end
    
    pcall(function()
        -- FREEZE MOVEMENT COMPLETELY
        if freezeSettings.freezeMovement then
            -- Stop all movement
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.JumpHeight = 0
            
            -- Freeze position by anchoring
            rootPart.Anchored = true
            
            -- Stop any ongoing animations/tweens
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.AngularVelocity = Vector3.new(0, 0, 0)
            
            -- Disable physics
            rootPart.CanCollide = false
            
            if freezeSettings.showFreezeLog then
                print("🧊 Frozen movement: " .. guardObj.Name)
            end
        end
        
        -- DISABLE AI & ATTACKS
        if freezeSettings.disableAI then
            -- Disable humanoid states that allow AI behavior
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            humanoid.PlatformStand = true
            
            -- Remove or disable common AI-related objects
            for _, child in pairs(guardObj:GetChildren()) do
                if child:IsA("BodyVelocity") or child:IsA("BodyPosition") or 
                   child:IsA("BodyAngularVelocity") or child:IsA("AlignPosition") or
                   child:IsA("AlignOrientation") then
                    child:Destroy()
                end
            end
            
            if freezeSettings.showFreezeLog then
                print("🤖 Disabled AI: " .. guardObj.Name)
            end
        end
        
        -- DISABLE SCRIPTS
        if freezeSettings.disableScripts then
            for _, script in pairs(guardObj:GetDescendants()) do
                if script:IsA("Script") or script:IsA("LocalScript") then
                    script.Disabled = true
                    table.insert(freezeData.disabledScripts, script)
                    
                    if freezeSettings.showFreezeLog then
                        print("📜 Disabled script: " .. script.Name)
                    end
                end
            end
        end
        
        -- MAKE INVISIBLE (OPTIONAL)
        if freezeSettings.makeInvisible then
            for _, part in pairs(guardObj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 1
                end
            end
            
            if freezeSettings.showFreezeLog then
                print("👻 Made invisible: " .. guardObj.Name)
            end
        end
        
        -- Store frozen guard data
        freezeData.frozenGuards[guardObj] = {
            humanoid = humanoid,
            rootPart = rootPart,
            originalWalkSpeed = humanoid.WalkSpeed,
            originalJumpPower = humanoid.JumpPower,
            frozenTime = tick()
        }
        
        freezeData.totalFrozen = freezeData.totalFrozen + 1
        
        if freezeSettings.showFreezeLog then
            print("✅ Successfully frozen guard: " .. guardObj.Name)
        end
    end)
    
    return true
end

local function scanAndFreezeAllGuards()
    print("🔍 Scanning for guards to freeze...")
    
    local guardsFound = 0
    local guardsFrozen = 0
    
    -- Scan entire workspace for guards
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if isGuardNPC(obj) then
                guardsFound = guardsFound + 1
                
                if freezeGuard(obj) then
                    guardsFrozen = guardsFrozen + 1
                end
            end
        end)
    end
    
    print("✅ Scan complete!")
    print("   👮 Guards found: " .. guardsFound)
    print("   🧊 Guards frozen: " .. guardsFrozen)
    print("   💥 Total disabled: " .. freezeData.totalFrozen)
    
    return guardsFrozen
end
local function maintainFreeze()
    -- Continuous freeze maintenance to prevent guards from unfreezing
    for guardObj, guardData in pairs(freezeData.frozenGuards) do
        if guardObj and guardObj.Parent then
            pcall(function()
                local humanoid = guardData.humanoid
                local rootPart = guardData.rootPart
                
                -- Ensure they stay frozen
                if humanoid and humanoid.Parent then
                    if humanoid.WalkSpeed ~= 0 then
                        humanoid.WalkSpeed = 0
                    end
                    if humanoid.JumpPower ~= 0 then
                        humanoid.JumpPower = 0
                    end
                    if not humanoid.PlatformStand then
                        humanoid.PlatformStand = true
                    end
                end
                
                if rootPart and rootPart.Parent then
                    if not rootPart.Anchored then
                        rootPart.Anchored = true
                    end
                    -- Reset velocity if it somehow gets set
                    if rootPart.Velocity.Magnitude > 0.1 then
                        rootPart.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        else
            -- Clean up invalid guards
            freezeData.frozenGuards[guardObj] = nil
        end
    end
end

local function unfreezeAllGuards()
    print("🔓 Unfreezing all guards...")
    
    local unfrozen = 0
    
    for guardObj, guardData in pairs(freezeData.frozenGuards) do
        pcall(function()
            if guardObj and guardObj.Parent and guardData then
                local humanoid = guardData.humanoid
                local rootPart = guardData.rootPart
                
                -- Restore original properties
                if humanoid and humanoid.Parent then
                    humanoid.WalkSpeed = guardData.originalWalkSpeed or 16
                    humanoid.JumpPower = guardData.originalJumpPower or 50
                    humanoid.PlatformStand = false
                end
                
                if rootPart and rootPart.Parent then
                    rootPart.Anchored = false
                    rootPart.CanCollide = true
                end
                
                -- Re-enable scripts
                for _, script in pairs(guardObj:GetDescendants()) do
                    if script:IsA("Script") or script:IsA("LocalScript") then
                        script.Disabled = false
                    end
                end
                
                unfrozen = unfrozen + 1
                
                if freezeSettings.showFreezeLog then
                    print("🔓 Unfrozen: " .. guardObj.Name)
                end
            end
        end)
    end
    
    freezeData.frozenGuards = {}
    freezeData.totalFrozen = 0
    
    print("✅ Unfrozen " .. unfrozen .. " guards")
    return unfrozen
end

-- ========================================================
-- ADVANCED GUARD DISABLING
-- ========================================================

local function disableGuardScripts()
    print("📜 Disabling all guard-related scripts...")
    
    local scriptsDisabled = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                local name = obj.Name:lower()
                
                -- Script patterns that might control guards
                local guardScriptPatterns = {
                    "guard", "security", "police", "npc", "ai", "bot",
                    "patrol", "attack", "chase", "follow", "enemy",
                    "combat", "fight", "damage", "hurt", "kill"
                }
                
                for _, pattern in ipairs(guardScriptPatterns) do
                    if name:find(pattern) then
                        obj.Disabled = true
                        table.insert(freezeData.disabledScripts, obj)
                        scriptsDisabled = scriptsDisabled + 1
                        
                        if freezeSettings.showFreezeLog then
                            print("📜 Disabled guard script: " .. obj.Name)
                        end
                        break
                    end
                end
            end
        end)
    end
    
    print("✅ Disabled " .. scriptsDisabled .. " guard scripts")
    return scriptsDisabled
end

local function destroyGuardWeapons()
    print("⚔️ Destroying guard weapons...")
    
    local weaponsDestroyed = 0
    
    for guardObj, _ in pairs(freezeData.frozenGuards) do
        pcall(function()
            if guardObj and guardObj.Parent then
                -- Remove weapons and tools
                for _, child in pairs(guardObj:GetChildren()) do
                    local childName = child.Name:lower()
                    
                    if child:IsA("Tool") or childName:find("weapon") or 
                       childName:find("gun") or childName:find("sword") or
                       childName:find("baton") or childName:find("taser") then
                        child:Destroy()
                        weaponsDestroyed = weaponsDestroyed + 1
                        
                        if freezeSettings.showFreezeLog then
                            print("⚔️ Destroyed weapon: " .. child.Name)
                        end
                    end
                end
            end
        end)
    end
    
    print("✅ Destroyed " .. weaponsDestroyed .. " weapons")
    return weaponsDestroyed
end
-- ========================================================
-- GUI CREATION
-- ========================================================

local function createFreezeGUI()
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "GuardFreezerGUI"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 320)
    mainFrame.Position = UDim2.new(1, -300, 0.5, -160)
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
    titleBar.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix title bar corner
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🧊 GUARD FREEZER"
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
    statsFrame.Size = UDim2.new(1, -20, 0, 80)
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statsFrame.BorderSizePixel = 1
    statsFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    statsFrame.Parent = mainFrame
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 6)
    statsCorner.Parent = statsFrame
    
    -- Stats Labels
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, 0, 0, 25)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "📊 FREEZE STATISTICS"
    statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsTitle.TextSize = 14
    statsTitle.Font = Enum.Font.SourceSansBold
    statsTitle.Parent = statsFrame
    
    local frozenLabel = Instance.new("TextLabel")
    frozenLabel.Name = "FrozenLabel"
    frozenLabel.Size = UDim2.new(1, -10, 0, 20)
    frozenLabel.Position = UDim2.new(0, 5, 0, 30)
    frozenLabel.BackgroundTransparency = 1
    frozenLabel.Text = "🧊 Guards Frozen: 0"
    frozenLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    frozenLabel.TextSize = 12
    frozenLabel.Font = Enum.Font.SourceSans
    frozenLabel.TextXAlignment = Enum.TextXAlignment.Left
    frozenLabel.Parent = statsFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 55)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Ready to freeze guards"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statsFrame
    -- Control Buttons Frame
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -20, 0, 160)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 140)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame
    
    -- Freeze All Button
    local freezeAllButton = Instance.new("TextButton")
    freezeAllButton.Name = "FreezeAllButton"
    freezeAllButton.Size = UDim2.new(1, 0, 0, 35)
    freezeAllButton.Position = UDim2.new(0, 0, 0, 0)
    freezeAllButton.BackgroundColor3 = Color3.fromRGB(80, 150, 200)
    freezeAllButton.Text = "🧊 FREEZE ALL GUARDS"
    freezeAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    freezeAllButton.TextSize = 12
    freezeAllButton.Font = Enum.Font.SourceSansBold
    freezeAllButton.BorderSizePixel = 0
    freezeAllButton.Parent = buttonsFrame
    
    local freezeCorner = Instance.new("UICorner")
    freezeCorner.CornerRadius = UDim.new(0, 6)
    freezeCorner.Parent = freezeAllButton
    
    -- Disable Scripts Button
    local disableScriptsButton = Instance.new("TextButton")
    disableScriptsButton.Name = "DisableScriptsButton"
    disableScriptsButton.Size = UDim2.new(1, 0, 0, 30)
    disableScriptsButton.Position = UDim2.new(0, 0, 0, 45)
    disableScriptsButton.BackgroundColor3 = Color3.fromRGB(150, 100, 80)
    disableScriptsButton.Text = "📜 DISABLE GUARD SCRIPTS"
    disableScriptsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    disableScriptsButton.TextSize = 11
    disableScriptsButton.Font = Enum.Font.SourceSansBold
    disableScriptsButton.BorderSizePixel = 0
    disableScriptsButton.Parent = buttonsFrame
    
    local scriptsCorner = Instance.new("UICorner")
    scriptsCorner.CornerRadius = UDim.new(0, 6)
    scriptsCorner.Parent = disableScriptsButton
    
    -- Destroy Weapons Button
    local destroyWeaponsButton = Instance.new("TextButton")
    destroyWeaponsButton.Name = "DestroyWeaponsButton"
    destroyWeaponsButton.Size = UDim2.new(1, 0, 0, 30)
    destroyWeaponsButton.Position = UDim2.new(0, 0, 0, 85)
    destroyWeaponsButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    destroyWeaponsButton.Text = "⚔️ DESTROY WEAPONS"
    destroyWeaponsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyWeaponsButton.TextSize = 11
    destroyWeaponsButton.Font = Enum.Font.SourceSansBold
    destroyWeaponsButton.BorderSizePixel = 0
    destroyWeaponsButton.Parent = buttonsFrame
    
    local weaponsCorner = Instance.new("UICorner")
    weaponsCorner.CornerRadius = UDim.new(0, 6)
    weaponsCorner.Parent = destroyWeaponsButton
    
    -- Unfreeze All Button
    local unfreezeButton = Instance.new("TextButton")
    unfreezeButton.Name = "UnfreezeButton"
    unfreezeButton.Size = UDim2.new(1, 0, 0, 30)
    unfreezeButton.Position = UDim2.new(0, 0, 0, 125)
    unfreezeButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    unfreezeButton.Text = "🔓 UNFREEZE ALL"
    unfreezeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unfreezeButton.TextSize = 11
    unfreezeButton.Font = Enum.Font.SourceSansBold
    unfreezeButton.BorderSizePixel = 0
    unfreezeButton.Parent = buttonsFrame
    
    local unfreezeCorner = Instance.new("UICorner")
    unfreezeCorner.CornerRadius = UDim.new(0, 6)
    unfreezeCorner.Parent = unfreezeButton
    
    -- ========================================================
    -- BUTTON EVENTS
    -- ========================================================
    
    local function updateStats()
        frozenLabel.Text = "🧊 Guards Frozen: " .. freezeData.totalFrozen
    end
    
    freezeAllButton.MouseButton1Click:Connect(function()
        freezeAllButton.Text = "⏳ FREEZING..."
        freezeAllButton.BackgroundColor3 = Color3.fromRGB(150, 100, 150)
        statusLabel.Text = "🧊 Freezing all guards..."
        
        task.wait(0.1)
        local frozen = scanAndFreezeAllGuards()
        updateStats()
        
        freezeAllButton.Text = "🧊 FREEZE ALL GUARDS"
        freezeAllButton.BackgroundColor3 = Color3.fromRGB(80, 150, 200)
        statusLabel.Text = "✅ Frozen " .. frozen .. " guards!"
    end)
    
    disableScriptsButton.MouseButton1Click:Connect(function()
        disableScriptsButton.Text = "⏳ DISABLING..."
        local disabled = disableGuardScripts()
        disableScriptsButton.Text = "📜 DISABLE GUARD SCRIPTS"
        statusLabel.Text = "📜 Disabled " .. disabled .. " scripts"
    end)
    
    destroyWeaponsButton.MouseButton1Click:Connect(function()
        destroyWeaponsButton.Text = "💀 DESTROYING..."
        local destroyed = destroyGuardWeapons()
        destroyWeaponsButton.Text = "⚔️ DESTROY WEAPONS"
        statusLabel.Text = "⚔️ Destroyed " .. destroyed .. " weapons"
    end)
    
    unfreezeButton.MouseButton1Click:Connect(function()
        unfreezeButton.Text = "⏳ UNFREEZING..."
        local unfrozen = unfreezeAllGuards()
        updateStats()
        unfreezeButton.Text = "🔓 UNFREEZE ALL"
        statusLabel.Text = "🔓 Unfrozen " .. unfrozen .. " guards"
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        -- Stop continuous freeze when closing
        for _, connection in pairs(freezeData.activeConnections) do
            if connection then
                connection:Disconnect()
            end
        end
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
    
    return gui, frozenLabel, statusLabel
end
-- ========================================================
-- CONTINUOUS FREEZE MODE & MAIN EXECUTION
-- ========================================================

local function startContinuousFreeze()
    if not freezeSettings.continuousMode then return end
    
    print("🔄 Starting continuous freeze mode...")
    
    -- Continuous maintenance loop
    local maintenanceConnection = RunService.Heartbeat:Connect(function()
        maintainFreeze()
    end)
    
    -- Auto-scan for new guards every 5 seconds
    local scanConnection = task.spawn(function()
        while freezeSettings.continuousMode do
            task.wait(5)
            
            -- Quick scan for new guards
            for _, obj in pairs(Workspace:GetDescendants()) do
                pcall(function()
                    if isGuardNPC(obj) and not freezeData.frozenGuards[obj] then
                        if freezeGuard(obj) then
                            print("🧊 Auto-frozen new guard: " .. obj.Name)
                        end
                    end
                end)
            end
        end
    end)
    
    table.insert(freezeData.activeConnections, maintenanceConnection)
    table.insert(freezeData.activeConnections, scanConnection)
    
    return maintenanceConnection, scanConnection
end

-- ========================================================
-- QUICK FUNCTIONS (NO GUI)
-- ========================================================

local function quickFreezeAll()
    print("⚡ QUICK FREEZE ALL GUARDS - NO GUI")
    
    local frozen = scanAndFreezeAllGuards()
    local scriptsDisabled = disableGuardScripts()
    local weaponsDestroyed = destroyGuardWeapons()
    
    if freezeSettings.continuousMode then
        startContinuousFreeze()
    end
    
    print("🎉 QUICK FREEZE COMPLETE!")
    print("   🧊 Guards frozen: " .. frozen)
    print("   📜 Scripts disabled: " .. scriptsDisabled)
    print("   ⚔️ Weapons destroyed: " .. weaponsDestroyed)
    
    if frozen > 0 then
        print("✅ All guards are now completely disabled!")
    else
        print("⚠️ No guards found to freeze")
    end
    
    return frozen
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating Guard Freezer...")

-- Create GUI
local gui, frozenLabel, statusLabel = createFreezeGUI()

-- Start continuous freeze mode if enabled
if freezeSettings.continuousMode then
    startContinuousFreeze()
end

-- Auto-freeze on startup
print("🔄 Auto-freezing guards on startup...")
task.wait(1)
local initialFrozen = scanAndFreezeAllGuards()
local initialScriptsDisabled = disableGuardScripts()

if frozenLabel and statusLabel then
    frozenLabel.Text = "🧊 Guards Frozen: " .. freezeData.totalFrozen
    statusLabel.Text = "🎯 Auto-freeze: " .. initialFrozen .. " guards frozen"
end

print("✅ GUARD FREEZER READY!")
print("=========================")
print("🧊 Guard freeze system loaded")
print("🎯 Auto-frozen " .. initialFrozen .. " guards")
print("📜 Disabled " .. initialScriptsDisabled .. " scripts")
print("🔄 Continuous freeze mode: " .. (freezeSettings.continuousMode and "ON" or "OFF"))
print("=========================")
print("💡 Functions:")
print("   • Complete movement freeze")
print("   • AI & attack disabling")
print("   • Script disabling")
print("   • Weapon destruction")
print("   • Continuous monitoring")
print("=========================")
print("🎮 Guards should now be completely helpless!")

-- Export functions for manual use
getgenv().quickFreezeAllGuards = quickFreezeAll
getgenv().unfreezeAllGuards = unfreezeAllGuards
getgenv().freezeGuard = freezeGuard
getgenv().scanGuards = scanAndFreezeAllGuards

print("📋 Available Commands:")
print("   quickFreezeAllGuards() - Instant freeze all")
print("   unfreezeAllGuards() - Restore all guards")
print("   scanGuards() - Scan and freeze new guards")