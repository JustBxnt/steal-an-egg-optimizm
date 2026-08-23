-- ========================================================
-- FREEZE ALL GUARDS - IMMOBILIZE SECURITY
-- Script untuk membekukan semua guard agar berhenti bergerak
-- ========================================================

print("🧊 LOADING FREEZE ALL GUARDS...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- FREEZE DATA & SETTINGS
-- ========================================================

local freezeData = {
    frozenGuards = {},
    guardScripts = {},
    originalStates = {},
    totalFrozen = 0,
    activeConnections = {}
}

local freezeSettings = {
    freezeMovement = true,          -- Freeze pergerakan guard
    freezeRotation = true,          -- Freeze rotasi guard
    disableScripts = true,          -- Disable guard AI scripts
    freezeAnimations = true,        -- Stop semua animasi
    makeTransparent = false,        -- Buat guard transparan (optional)
    showFreezeLog = true,          -- Log proses freeze
    continuousFreeze = true,       -- Continuous freeze loop
    safeMode = true               -- Mode aman
}

-- ========================================================
-- GUARD DETECTION FUNCTIONS
-- ========================================================

local function isGuardNPC(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    local className = obj.ClassName
    
    -- Guard detection patterns
    local guardPatterns = {
        "guard", "security", "police", "officer", "cop", "sheriff",
        "soldier", "watchman", "defender", "protector", "sentinel",
        "keeper", "warden", "patrol", "bouncer", "enforcer", "agent"
    }
    
    -- Check name patterns
    for _, pattern in ipairs(guardPatterns) do
        if name:find(pattern) then
            return true
        end
    end
    
    -- Check if it's a humanoid model (likely NPC)
    if className == "Model" then
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
        
        if humanoid and rootPart then
            -- Check for guard characteristics
            -- Guards usually have weapons or uniforms
            for _, child in pairs(obj:GetChildren()) do
                local childName = child.Name:lower()
                if childName:find("weapon") or childName:find("gun") or 
                   childName:find("baton") or childName:find("sword") or
                   childName:find("badge") or childName:find("uniform") then
                    return true
                end
            end
            
            -- Check if NPC is not a player
            local player = Players:GetPlayerFromCharacter(obj)
            if not player then
                -- Check size and behavior patterns
                local humanoidSize = rootPart.Size
                if humanoidSize.Y > 4 and humanoidSize.Y < 8 then
                    -- Check for guard-specific scripts
                    for _, script in pairs(obj:GetDescendants()) do
                        if script:IsA("Script") or script:IsA("LocalScript") then
                            local scriptName = script.Name:lower()
                            if scriptName:find("guard") or scriptName:find("patrol") or 
                               scriptName:find("ai") or scriptName:find("chase") then
                                return true
                            end
                        end
                    end
                    
                    -- If has humanoid but no player, likely an NPC
                    return true
                end
            end
        end
    end
    
    return false
end

-- ========================================================
-- FREEZE FUNCTIONS
-- ========================================================

local function freezeGuardMovement(guardObj)
    local humanoid = guardObj:FindFirstChildOfClass("Humanoid")
    local rootPart = guardObj:FindFirstChild("HumanoidRootPart") or guardObj:FindFirstChild("Torso")
    
    if not humanoid or not rootPart then return false end
    
    -- Store original state
    if not freezeData.originalStates[guardObj] then
        freezeData.originalStates[guardObj] = {
            walkSpeed = humanoid.WalkSpeed,
            jumpPower = humanoid.JumpPower,
            position = rootPart.Position,
            rotation = rootPart.Rotation,
            anchored = rootPart.Anchored,
            canCollide = rootPart.CanCollide
        }
    end
    
    pcall(function()
        -- Freeze movement
        if freezeSettings.freezeMovement then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.PlatformStand = true
        end
        
        -- Anchor the root part
        rootPart.Anchored = true
        
        -- Stop all animations
        if freezeSettings.freezeAnimations then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
        
        -- Disable scripts
        if freezeSettings.disableScripts then
            for _, script in pairs(guardObj:GetDescendants()) do
                if script:IsA("Script") or script:IsA("LocalScript") then
                    script.Disabled = true
                    table.insert(freezeData.guardScripts, script)
                end
            end
        end
        
        -- Make transparent (optional)
        if freezeSettings.makeTransparent then
            for _, part in pairs(guardObj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.8
                end
            end
        end
        
        if freezeSettings.showFreezeLog then
            print("🧊 Frozen guard: " .. guardObj.Name)
        end
        
        return true
    end)
    
    return false
end

local function scanAndFreezeGuards()
    print("🔍 Scanning workspace for guards...")
    
    local frozenCount = 0
    local scannedObjects = 0
    
    -- Scan all workspace descendants
    for _, obj in pairs(Workspace:GetDescendants()) do
        scannedObjects = scannedObjects + 1
        
        pcall(function()
            if isGuardNPC(obj) then
                if freezeGuardMovement(obj) then
                    table.insert(freezeData.frozenGuards, obj)
                    frozenCount = frozenCount + 1
                    freezeData.totalFrozen = freezeData.totalFrozen + 1
                end
            end
        end)
    end
    
    print("✅ Guard freeze scan complete!")
    print("   📊 Objects scanned: " .. scannedObjects)
    print("   🧊 Guards frozen: " .. frozenCount)
    print("   🎯 Total frozen so far: " .. freezeData.totalFrozen)
    
    return frozenCount
end

local function unfreezeGuard(guardObj)
    local originalState = freezeData.originalStates[guardObj]
    if not originalState then return false end
    
    local humanoid = guardObj:FindFirstChildOfClass("Humanoid")
    local rootPart = guardObj:FindFirstChild("HumanoidRootPart") or guardObj:FindFirstChild("Torso")
    
    if not humanoid or not rootPart then return false end
    
    pcall(function()
        -- Restore original movement
        humanoid.WalkSpeed = originalState.walkSpeed
        humanoid.JumpPower = originalState.jumpPower
        humanoid.PlatformStand = false
        
        -- Unanchor
        rootPart.Anchored = originalState.anchored
        rootPart.Position = originalState.position
        
        -- Re-enable scripts
        for _, script in pairs(freezeData.guardScripts) do
            if script.Parent == guardObj then
                script.Disabled = false
            end
        end
        
        -- Restore transparency
        if freezeSettings.makeTransparent then
            for _, part in pairs(guardObj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
        
        if freezeSettings.showFreezeLog then
            print("🔥 Unfrozen guard: " .. guardObj.Name)
        end
    end)
    
    freezeData.originalStates[guardObj] = nil
    return true
end

local function unfreezeAllGuards()
    print("🔥 Unfreezing all guards...")
    
    local unfroznCount = 0
    
    for _, guardObj in ipairs(freezeData.frozenGuards) do
        if guardObj and guardObj.Parent then
            if unfreezeGuard(guardObj) then
                unfroznCount = unfroznCount + 1
            end
        end
    end
    
    -- Re-enable all scripts
    for _, script in pairs(freezeData.guardScripts) do
        if script and script.Parent then
            script.Disabled = false
        end
    end
    
    -- Clear data
    freezeData.frozenGuards = {}
    freezeData.guardScripts = {}
    freezeData.originalStates = {}
    
    print("✅ Unfrozen " .. unfroznCount .. " guards!")
    return unfroznCount
end
-- ========================================================
-- CONTINUOUS FREEZE SYSTEM
-- ========================================================

local function startContinuousFreeze()
    if not freezeSettings.continuousFreeze then return end
    
    local connection = RunService.Heartbeat:Connect(function()
        -- Maintain freeze on existing guards
        for _, guardObj in ipairs(freezeData.frozenGuards) do
            if guardObj and guardObj.Parent then
                local humanoid = guardObj:FindFirstChildOfClass("Humanoid")
                local rootPart = guardObj:FindFirstChild("HumanoidRootPart") or guardObj:FindFirstChild("Torso")
                
                if humanoid and rootPart then
                    pcall(function()
                        -- Maintain freeze state
                        humanoid.WalkSpeed = 0
                        humanoid.JumpPower = 0
                        humanoid.PlatformStand = true
                        rootPart.Anchored = true
                        
                        -- Stop any new animations
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            track:Stop()
                        end
                    end)
                end
            end
        end
        
        -- Auto-scan for new guards every 5 seconds
        task.wait(5)
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if isGuardNPC(obj) then
                    -- Check if already frozen
                    local alreadyFrozen = false
                    for _, frozenGuard in ipairs(freezeData.frozenGuards) do
                        if frozenGuard == obj then
                            alreadyFrozen = true
                            break
                        end
                    end
                    
                    -- Freeze new guard
                    if not alreadyFrozen then
                        if freezeGuardMovement(obj) then
                            table.insert(freezeData.frozenGuards, obj)
                            freezeData.totalFrozen = freezeData.totalFrozen + 1
                            if freezeSettings.showFreezeLog then
                                print("🧊 Auto-frozen new guard: " .. obj.Name)
                            end
                        end
                    end
                end
            end
        end)
    end)
    
    table.insert(freezeData.activeConnections, connection)
    return connection
end

-- ========================================================
-- GUI CREATION
-- ========================================================

local function createFreezeGUI()
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "FreezeAllGuards"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 220)
    mainFrame.Position = UDim2.new(1, -300, 0.5, -110)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
    statsFrame.Size = UDim2.new(1, -20, 0, 60)
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    statsFrame.BorderSizePixel = 1
    statsFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    statsFrame.Parent = mainFrame
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 6)
    statsCorner.Parent = statsFrame
    
    -- Stats Labels
    local frozenLabel = Instance.new("TextLabel")
    frozenLabel.Name = "FrozenLabel"
    frozenLabel.Size = UDim2.new(1, -10, 0, 20)
    frozenLabel.Position = UDim2.new(0, 5, 0, 5)
    frozenLabel.BackgroundTransparency = 1
    frozenLabel.Text = "🧊 Frozen Guards: 0"
    frozenLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    frozenLabel.TextSize = 12
    frozenLabel.Font = Enum.Font.SourceSansBold
    frozenLabel.TextXAlignment = Enum.TextXAlignment.Left
    frozenLabel.Parent = statsFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Click FREEZE to immobilize guards"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statsFrame