-- ========================================================
-- COMPLETE GUARD FREEZE - TOTAL MOVEMENT STOP
-- Script untuk benar-benar membekukan guard tanpa bisa bergerak
-- ========================================================

print("🧊 LOADING COMPLETE GUARD FREEZE...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- FREEZE DATA & SETTINGS
-- ========================================================

local freezeData = {
    frozenGuards = {},
    totalFrozen = 0,
    activeConnections = {},
    frozenPositions = {},
    freezeAnchors = {}
}

local freezeSettings = {
    totalFreeze = true,           -- Bekukan total semua gerakan
    disableWalkSpeed = true,      -- Set WalkSpeed ke 0
    disableJumpPower = true,      -- Set JumpPower ke 0
    anchorParts = true,          -- Anchor semua part
    disableScripts = true,        -- Disable script pergerakan
    lockPosition = true,          -- Lock posisi dengan BodyPosition
    disableAI = true,            -- Disable AI pathfinding
    continuousFreeze = true,      -- Mode continuous freeze
    showFreezeLog = true         -- Log proses freeze
}

-- ========================================================
-- ADVANCED GUARD DETECTION
-- ========================================================

local function isGuardNPC(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    
    -- Guard name patterns
    local guardPatterns = {
        "guard", "security", "police", "officer", "watchman", "npc",
        "bot", "ai", "enemy", "patrol", "defender", "protector",
        "sentinel", "keeper", "warden", "bouncer", "soldier"
    }
    
    -- Check name patterns
    for _, pattern in ipairs(guardPatterns) do
        if name:find(pattern) then
            return true
        end
    end
    
    -- Check if it's a Model with Humanoid (NPC characteristics)
    if obj:IsA("Model") then
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
        
        if humanoid and rootPart then
            -- Additional checks for guard-like NPCs
            
            -- Check if it has typical NPC size (not too small like pets)
            if rootPart.Size.Y > 3 and rootPart.Size.Y < 8 then
                
                -- Check if it's not a player
                local isPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character == obj then
                        isPlayer = true
                        break
                    end
                end
                
                if not isPlayer then
                    -- Check for guard-specific accessories or tools
                    local hasWeapon = obj:FindFirstChild("Weapon") or obj:FindFirstChild("Gun") or obj:FindFirstChild("Baton")
                    local hasUniform = obj:FindFirstChild("Shirt") or obj:FindFirstChild("Pants")
                    
                    -- If it has weapons, uniform, or is in typical guard areas, likely a guard
                    if hasWeapon or hasUniform or humanoid.WalkSpeed > 0 then
                        return true
                    end
                    
                    -- Check if it's moving (guards usually patrol)
                    if humanoid.MoveDirection.Magnitude > 0 then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- ========================================================
-- FREEZE FUNCTIONS
-- ========================================================

local function createFreezeAnchor(guard)
    local rootPart = guard:FindFirstChild("HumanoidRootPart") or guard:FindFirstChild("Torso")
    if not rootPart then return end
    
    -- Create BodyPosition to lock position
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyPosition.Position = rootPart.Position
    bodyPosition.D = 10000 -- High dampening
    bodyPosition.P = 10000 -- High power
    bodyPosition.Parent = rootPart
    
    -- Create BodyAngularVelocity to stop rotation
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    bodyAngularVelocity.P = 10000
    bodyAngularVelocity.Parent = rootPart
    
    -- Store anchors for cleanup
    freezeData.freezeAnchors[guard] = {bodyPosition, bodyAngularVelocity}
    
    return bodyPosition, bodyAngularVelocity
end

local function freezeGuardCompletely(guard)
    if freezeData.frozenGuards[guard] then
        return -- Already frozen
    end
    
    local guardName = guard.Name
    local humanoid = guard:FindFirstChildOfClass("Humanoid")
    local rootPart = guard:FindFirstChild("HumanoidRootPart") or guard:FindFirstChild("Torso")
    
    if not humanoid or not rootPart then return end
    
    print("🧊 Freezing guard: " .. guardName)
    
    -- Store original values
    local originalData = {
        walkSpeed = humanoid.WalkSpeed,
        jumpPower = humanoid.JumpPower,
        position = rootPart.Position,
        rotation = rootPart.Rotation
    }
    
    -- STEP 1: Disable Humanoid Movement
    if freezeSettings.disableWalkSpeed then
        humanoid.WalkSpeed = 0
    end
    
    if freezeSettings.disableJumpPower then
        humanoid.JumpPower = 0
    end
    
    -- STEP 2: Anchor All Parts
    if freezeSettings.anchorParts then
        for _, part in pairs(guard:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
    end
    
    -- STEP 3: Create Position Lock
    if freezeSettings.lockPosition then
        createFreezeAnchor(guard)
    end
    
    -- STEP 4: Disable Scripts
    if freezeSettings.disableScripts then
        for _, script in pairs(guard:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") then
                script.Disabled = true
            end
        end
    end
    
    -- STEP 5: Disable AI/Pathfinding
    if freezeSettings.disableAI then
        -- Disable Pathfinding
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        humanoid.PlatformStand = true
        
        -- Remove any existing pathfinding or AI scripts
        for _, child in pairs(guard:GetDescendants()) do
            local name = child.Name:lower()
            if name:find("path") or name:find("ai") or name:find("move") or name:find("walk") then
                if child:IsA("Script") or child:IsA("LocalScript") then
                    child:Destroy()
                end
            end
        end
    end
    
    -- STEP 6: Force Stop Any Movement
    if rootPart.AssemblyLinearVelocity then
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    
    if rootPart.AssemblyAngularVelocity then
        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    
    -- Store frozen guard data
    freezeData.frozenGuards[guard] = {
        originalData = originalData,
        frozenTime = tick(),
        guardName = guardName
    }
    
    freezeData.totalFrozen = freezeData.totalFrozen + 1
    
    if freezeSettings.showFreezeLog then
        print("✅ Guard frozen: " .. guardName .. " (Total: " .. freezeData.totalFrozen .. ")")
    end
end
local function maintainFreeze(guard)
    -- Continuous freeze maintenance
    local humanoid = guard:FindFirstChildOfClass("Humanoid")
    local rootPart = guard:FindFirstChild("HumanoidRootPart") or guard:FindFirstChild("Torso")
    
    if not humanoid or not rootPart then return end
    
    -- Continuously enforce freeze
    pcall(function()
        -- Keep movement disabled
        if humanoid.WalkSpeed ~= 0 then
            humanoid.WalkSpeed = 0
        end
        
        if humanoid.JumpPower ~= 0 then
            humanoid.JumpPower = 0
        end
        
        -- Keep parts anchored
        for _, part in pairs(guard:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                part.Anchored = true
            end
        end
        
        -- Force stop velocity
        if rootPart.AssemblyLinearVelocity.Magnitude > 0.1 then
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        
        if rootPart.AssemblyAngularVelocity.Magnitude > 0.1 then
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
        
        -- Maintain PlatformStand
        if not humanoid.PlatformStand then
            humanoid.PlatformStand = true
        end
    end)
end

local function scanAndFreezeAllGuards()
    print("🔍 Scanning for guards to freeze...")
    
    local guardCount = 0
    local startTime = tick()
    
    -- Scan all descendants in workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if isGuardNPC(obj) then
                freezeGuardCompletely(obj)
                guardCount = guardCount + 1
            end
        end)
    end
    
    local scanTime = math.floor((tick() - startTime) * 1000) / 1000
    
    print("✅ Guard freeze scan complete!")
    print("   🧊 Guards frozen: " .. guardCount)
    print("   ⏱️ Scan time: " .. scanTime .. "s")
    
    return guardCount
end

local function unfreezeGuard(guard)
    local frozenData = freezeData.frozenGuards[guard]
    if not frozenData then return end
    
    local humanoid = guard:FindFirstChildOfClass("Humanoid")
    local rootPart = guard:FindFirstChild("HumanoidRootPart") or guard:FindFirstChild("Torso")
    
    if humanoid and rootPart then
        print("🔥 Unfreezing guard: " .. frozenData.guardName)
        
        -- Restore original values
        humanoid.WalkSpeed = frozenData.originalData.walkSpeed
        humanoid.JumpPower = frozenData.originalData.jumpPower
        humanoid.PlatformStand = false
        
        -- Unanchor parts
        for _, part in pairs(guard:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
        
        -- Re-enable scripts
        for _, script in pairs(guard:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") then
                script.Disabled = false
            end
        end
        
        -- Remove freeze anchors
        if freezeData.freezeAnchors[guard] then
            for _, anchor in pairs(freezeData.freezeAnchors[guard]) do
                if anchor then
                    anchor:Destroy()
                end
            end
            freezeData.freezeAnchors[guard] = nil
        end
    end
    
    freezeData.frozenGuards[guard] = nil
    freezeData.totalFrozen = freezeData.totalFrozen - 1
end

local function unfreezeAllGuards()
    print("🔥 Unfreezing all guards...")
    
    for guard, _ in pairs(freezeData.frozenGuards) do
        unfreezeGuard(guard)
    end
    
    print("✅ All guards unfrozen!")
end

-- ========================================================
-- CONTINUOUS FREEZE SYSTEM
-- ========================================================

local function startContinuousFreeze()
    if not freezeSettings.continuousFreeze then return end
    
    print("🔄 Starting continuous freeze system...")
    
    -- Main freeze maintenance loop
    local freezeConnection = RunService.Heartbeat:Connect(function()
        -- Maintain freeze on existing guards
        for guard, _ in pairs(freezeData.frozenGuards) do
            if guard and guard.Parent then
                maintainFreeze(guard)
            else
                -- Clean up destroyed guards
                freezeData.frozenGuards[guard] = nil
            end
        end
        
        -- Auto-detect and freeze new guards every few seconds
        if tick() % 3 < 0.1 then -- Every 3 seconds
            for _, obj in pairs(Workspace:GetDescendants()) do
                pcall(function()
                    if isGuardNPC(obj) and not freezeData.frozenGuards[obj] then
                        freezeGuardCompletely(obj)
                        if freezeSettings.showFreezeLog then
                            print("🆕 Auto-froze new guard: " .. obj.Name)
                        end
                    end
                end)
            end
        end
    end)
    
    table.insert(freezeData.activeConnections, freezeConnection)
end
-- ========================================================
-- GUI CREATION
-- ========================================================

local function createFreezeGUI()
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CompleteGuardFreeze"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 200)
    mainFrame.Position = UDim2.new(1, -300, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix title bar corner
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🧊 GUARD FREEZE"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 12
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Stats Label
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -20, 0, 30)
    statsLabel.Position = UDim2.new(0, 10, 0, 45)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "🧊 Frozen Guards: 0"
    statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsLabel.TextSize = 14
    statsLabel.Font = Enum.Font.SourceSansBold
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = mainFrame
    
    -- Freeze All Button
    local freezeAllButton = Instance.new("TextButton")
    freezeAllButton.Name = "FreezeAllButton"
    freezeAllButton.Size = UDim2.new(1, -20, 0, 30)
    freezeAllButton.Position = UDim2.new(0, 10, 0, 80)
    freezeAllButton.BackgroundColor3 = Color3.fromRGB(80, 150, 200)
    freezeAllButton.Text = "🧊 FREEZE ALL GUARDS"
    freezeAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    freezeAllButton.TextSize = 12
    freezeAllButton.Font = Enum.Font.SourceSansBold
    freezeAllButton.BorderSizePixel = 0
    freezeAllButton.Parent = mainFrame
    
    local freezeCorner = Instance.new("UICorner")
    freezeCorner.CornerRadius = UDim.new(0, 6)
    freezeCorner.Parent = freezeAllButton
    
    -- Unfreeze All Button
    local unfreezeAllButton = Instance.new("TextButton")
    unfreezeAllButton.Name = "UnfreezeAllButton"
    unfreezeAllButton.Size = UDim2.new(1, -20, 0, 30)
    unfreezeAllButton.Position = UDim2.new(0, 10, 0, 120)
    unfreezeAllButton.BackgroundColor3 = Color3.fromRGB(200, 100, 80)
    unfreezeAllButton.Text = "🔥 UNFREEZE ALL GUARDS"
    unfreezeAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unfreezeAllButton.TextSize = 12
    unfreezeAllButton.Font = Enum.Font.SourceSansBold
    unfreezeAllButton.BorderSizePixel = 0
    unfreezeAllButton.Parent = mainFrame
    
    local unfreezeCorner = Instance.new("UICorner")
    unfreezeCorner.CornerRadius = UDim.new(0, 6)
    unfreezeCorner.Parent = unfreezeAllButton
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 160)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Click FREEZE ALL to stop guards"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextSize = 10
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- ========================================================
    -- BUTTON EVENTS
    -- ========================================================
    
    local function updateStats()
        statsLabel.Text = "🧊 Frozen Guards: " .. freezeData.totalFrozen
    end
    
    freezeAllButton.MouseButton1Click:Connect(function()
        freezeAllButton.Text = "⏳ FREEZING..."
        freezeAllButton.BackgroundColor3 = Color3.fromRGB(150, 100, 150)
        statusLabel.Text = "🧊 Freezing all guards..."
        
        task.wait(0.1)
        local frozenCount = scanAndFreezeAllGuards()
        updateStats()
        
        freezeAllButton.Text = "🧊 FREEZE ALL GUARDS"
        freezeAllButton.BackgroundColor3 = Color3.fromRGB(80, 150, 200)
        statusLabel.Text = "✅ " .. frozenCount .. " guards completely frozen!"
    end)
    
    unfreezeAllButton.MouseButton1Click:Connect(function()
        unfreezeAllButton.Text = "⏳ UNFREEZING..."
        unfreezeAllButton.BackgroundColor3 = Color3.fromRGB(150, 80, 50)
        statusLabel.Text = "🔥 Unfreezing all guards..."
        
        task.wait(0.1)
        unfreezeAllGuards()
        updateStats()
        
        unfreezeAllButton.Text = "🔥 UNFREEZE ALL GUARDS"
        unfreezeAllButton.BackgroundColor3 = Color3.fromRGB(200, 100, 80)
        statusLabel.Text = "✅ All guards unfrozen and restored!"
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        -- Cleanup connections before closing
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
    
    return gui, statsLabel, statusLabel
end
-- ========================================================
-- QUICK FREEZE FUNCTIONS (NO GUI)
-- ========================================================

local function quickFreezeAll()
    print("⚡ QUICK FREEZE - NO GUI MODE")
    
    local frozenCount = scanAndFreezeAllGuards()
    
    if frozenCount > 0 then
        startContinuousFreeze()
        print("✅ Quick freeze complete!")
        print("🧊 " .. frozenCount .. " guards completely frozen")
        print("🔄 Continuous freeze system active")
    else
        print("⚠️ No guards found to freeze")
    end
    
    return frozenCount
end

local function emergencyUnfreezeAll()
    print("🚨 EMERGENCY UNFREEZE - RESTORING ALL GUARDS")
    
    unfreezeAllGuards()
    
    -- Stop all connections
    for _, connection in pairs(freezeData.activeConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    freezeData.activeConnections = {}
    
    print("✅ Emergency unfreeze complete!")
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating Complete Guard Freeze System...")

-- Create GUI
local gui, statsLabel, statusLabel = createFreezeGUI()

-- Start continuous freeze system
startContinuousFreeze()

print("✅ COMPLETE GUARD FREEZE READY!")
print("================================")
print("🧊 Advanced guard freeze system loaded")
print("🎯 Multi-layer freeze approach:")
print("   • WalkSpeed & JumpPower = 0")
print("   • All parts anchored")
print("   • BodyPosition locks")
print("   • Script disabling")
print("   • AI/Pathfinding disabled")
print("   • Velocity force stop")
print("   • PlatformStand enabled")
print("================================")
print("💡 Features:")
print("   • Total movement elimination")
print("   • Continuous freeze maintenance")
print("   • Auto-detect new guards")
print("   • Safe unfreeze restoration")
print("   • Multi-method approach")
print("================================")
print("🎮 Guards will be COMPLETELY frozen!")

-- Export functions for manual use
getgenv().quickFreezeAllGuards = quickFreezeAll
getgenv().emergencyUnfreezeAll = emergencyUnfreezeAll
getgenv().freezeGuard = freezeGuardCompletely
getgenv().unfreezeGuard = unfreezeGuard

-- Auto-freeze on startup (optional)
task.wait(1)
print("🔄 Auto-freezing guards on startup...")
local initialFrozen = scanAndFreezeAllGuards()

if statsLabel and statusLabel then
    statsLabel.Text = "🧊 Frozen Guards: " .. freezeData.totalFrozen
    statusLabel.Text = "🎯 Auto-froze " .. initialFrozen .. " guards on startup"
end

print("🎉 " .. initialFrozen .. " guards frozen on startup!")
print("🔄 Continuous freeze system monitoring...")

-- Cleanup on character reset
if LocalPlayer.Character then
    LocalPlayer.Character.AncestryChanged:Connect(function()
        if not LocalPlayer.Character.Parent then
            emergencyUnfreezeAll()
        end
    end)
end