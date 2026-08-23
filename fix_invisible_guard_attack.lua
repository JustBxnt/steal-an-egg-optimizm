-- ========================================================
-- FIX INVISIBLE GUARD ATTACK - STOP HIDDEN GUARD HITS
-- Mengatasi guard yang masih bisa menyerang meski tidak terlihat
-- ========================================================

print("🔧 LOADING INVISIBLE GUARD ATTACK FIX...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- FIX SETTINGS & DATA
-- ========================================================

local fixSettings = {
    disableAllDamage = true,        -- Disable semua damage ke player
    destroyHiddenGuards = true,     -- Hancurkan guard yang tidak terlihat
    blockRemoteAttacks = true,      -- Block remote attack events
    makePlayerInvincible = false,   -- Buat player kebal (optional)
    showFixLog = true,              -- Show fix process log
    continuousFix = true            -- Continuous protection
}

local guardProtection = {
    blockedRemotes = {},
    destroyedGuards = 0,
    activeConnections = {}
}

-- ========================================================
-- PLAYER PROTECTION FUNCTIONS
-- ========================================================

local function makePlayerInvincible()
    if not LocalPlayer.Character then return false end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Method 1: Set MaxHealth sangat tinggi
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        -- Method 2: Hook damage events
        local originalHealth = humanoid.Health
        
        humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth < originalHealth and fixSettings.disableAllDamage then
                humanoid.Health = originalHealth
                if fixSettings.showFixLog then
                    print("🛡️ Blocked damage! Health restored")
                end
            end
        end)
        
        -- Method 3: Disable taking damage
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth and fixSettings.disableAllDamage then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        
        if fixSettings.showFixLog then
            print("🛡️ Player made invincible")
        end
        return true
    end
    
    return false
end

local function blockRemoteAttacks()
    print("📡 Blocking remote attack events...")
    local blocked = 0
    
    -- Block ReplicatedStorage remotes
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Hook all RemoteEvents
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local objName = obj.Name:lower()
                
                -- Check if it's an attack/damage remote
                if objName:find("damage") or objName:find("attack") or objName:find("hurt") or 
                   objName:find("hit") or objName:find("kill") or objName:find("combat") or
                   objName:find("guard") or objName:find("fight") or objName:find("punch") then
                    
                    -- Block the remote by destroying it
                    obj.Parent = nil
                    table.insert(guardProtection.blockedRemotes, obj.Name)
                    blocked = blocked + 1
                    
                    if fixSettings.showFixLog then
                        print("📡 Blocked remote attack: " .. obj.Name)
                    end
                end
            elseif obj:IsA("RemoteFunction") then
                local objName = obj.Name:lower()
                
                if objName:find("damage") or objName:find("attack") or objName:find("hurt") then
                    obj.Parent = nil
                    blocked = blocked + 1
                    
                    if fixSettings.showFixLog then
                        print("📡 Blocked remote function: " .. obj.Name)
                    end
                end
            end
        end
    end)
    
    print("✅ Blocked " .. blocked .. " attack remotes")
    return blocked
end

-- ========================================================
-- HIDDEN GUARD DETECTION & DESTRUCTION
-- ========================================================

local function findHiddenGuards()
    print("👻 Scanning for hidden guards...")
    local hiddenGuards = {}
    
    -- Scan semua objek di workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            -- Cek guard yang tidak terlihat tapi masih ada
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                
                -- Cek jika objek memiliki nama guard tapi tidak terlihat
                if name:find("guard") or name:find("security") or name:find("protector") then
                    local hasVisibleParts = false
                    
                    -- Cek apakah ada parts yang terlihat
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") and part.Transparency < 0.99 then
                            hasVisibleParts = true
                            break
                        end
                    end
                    
                    -- Jika tidak ada parts terlihat tapi objek masih ada, kemungkinan hidden guard
                    if not hasVisibleParts then
                        table.insert(hiddenGuards, obj)
                        if fixSettings.showFixLog then
                            print("👻 Found hidden guard: " .. obj.Name)
                        end
                    end
                end
                
                -- Cek guard dengan humanoid yang masih hidup
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    -- Cek jika dekat dengan egg area (kemungkinan egg guard)
                    if obj:FindFirstChild("HumanoidRootPart") then
                        local eggArea = Workspace:FindFirstChild("AreaEggSlotsClient")
                        if eggArea then
                            local guardPos = obj.HumanoidRootPart.Position
                            
                            for _, eggObj in pairs(eggArea:GetChildren()) do
                                if eggObj:FindFirstChildOfClass("BasePart") then
                                    local eggPos = eggObj:FindFirstChildOfClass("BasePart").Position
                                    local distance = (guardPos - eggPos).Magnitude
                                    
                                    if distance < 100 then -- Guard dalam radius 100 dari egg
                                        table.insert(hiddenGuards, obj)
                                        if fixSettings.showFixLog then
                                            print("👻 Found nearby guard: " .. obj.Name .. " (distance: " .. math.floor(distance) .. ")")
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Cek scripts yang masih berjalan dan mengatur damage/attack
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                local scriptName = obj.Name:lower()
                
                if scriptName:find("damage") or scriptName:find("attack") or scriptName:find("hurt") or
                   scriptName:find("guard") or scriptName:find("combat") then
                    
                    -- Disable script
                    obj.Enabled = false
                    obj.Parent = nil
                    
                    if fixSettings.showFixLog then
                        print("📜 Disabled attack script: " .. obj.Name)
                    end
                end
            end
        end)
    end
    
    return hiddenGuards
end

local function destroyHiddenGuards(hiddenGuards)
    print("💀 Destroying hidden guards...")
    local destroyed = 0
    
    for _, guard in ipairs(hiddenGuards) do
        pcall(function()
            if guard and guard.Parent then
                -- Matikan humanoid
                local humanoid = guard:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                    humanoid.MaxHealth = 0
                    humanoid.PlatformStand = true
                end
                
                -- Hancurkan semua scripts di guard
                for _, script in pairs(guard:GetDescendants()) do
                    if script:IsA("Script") or script:IsA("LocalScript") then
                        script.Enabled = false
                        script:Destroy()
                    end
                end
                
                -- Hancurkan guard sepenuhnya
                guard:Destroy()
                destroyed = destroyed + 1
                guardProtection.destroyedGuards = guardProtection.destroyedGuards + 1
                
                if fixSettings.showFixLog then
                    print("💀 Destroyed hidden guard: " .. guard.Name)
                end
            end
        end)
    end
    
    print("✅ Destroyed " .. destroyed .. " hidden guards")
    return destroyed
end
-- ========================================================
-- MAIN FIX FUNCTION
-- ========================================================

local function fixInvisibleGuardAttacks()
    print("🔧 STARTING INVISIBLE GUARD ATTACK FIX...")
    
    local totalFixed = 0
    
    -- 1. Block remote attacks
    if fixSettings.blockRemoteAttacks then
        local remotesBlocked = blockRemoteAttacks()
        totalFixed = totalFixed + remotesBlocked
    end
    
    -- 2. Make player invincible (optional)
    if fixSettings.makePlayerInvincible then
        makePlayerInvincible()
        totalFixed = totalFixed + 1
    end
    
    -- 3. Find and destroy hidden guards
    if fixSettings.destroyHiddenGuards then
        local hiddenGuards = findHiddenGuards()
        local guardsDestroyed = destroyHiddenGuards(hiddenGuards)
        totalFixed = totalFixed + guardsDestroyed
    end
    
    -- 4. Additional protection - disable all humanoids near egg areas
    local eggArea = Workspace:FindFirstChild("AreaEggSlotsClient")
    if eggArea then
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Humanoid") and obj.Parent ~= LocalPlayer.Character then
                    -- Check if humanoid is near egg areas
                    local rootPart = obj.Parent:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        for _, eggObj in pairs(eggArea:GetChildren()) do
                            if eggObj:FindFirstChildOfClass("BasePart") then
                                local distance = (rootPart.Position - eggObj:FindFirstChildOfClass("BasePart").Position).Magnitude
                                if distance < 150 then -- Within 150 studs of eggs
                                    obj.Health = 0
                                    obj.MaxHealth = 0
                                    obj.PlatformStand = true
                                    
                                    if fixSettings.showFixLog then
                                        print("💀 Disabled nearby humanoid: " .. obj.Parent.Name)
                                    end
                                    totalFixed = totalFixed + 1
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    
    print("🎉 INVISIBLE GUARD ATTACK FIX COMPLETE!")
    print("=====================================")
    print("📡 Remote attacks blocked: " .. #guardProtection.blockedRemotes)
    print("💀 Hidden guards destroyed: " .. guardProtection.destroyedGuards)
    print("🔧 Total fixes applied: " .. totalFixed)
    print("=====================================")
    
    if totalFixed > 0 then
        print("🛡️ You should no longer be attacked by invisible guards!")
    else
        print("⚠️ No guard threats found to fix")
    end
    
    return totalFixed
end

-- ========================================================
-- CONTINUOUS PROTECTION
-- ========================================================

local function startContinuousProtection()
    if not fixSettings.continuousFix then return end
    
    print("🔄 Starting continuous protection...")
    
    local protectionConnection = RunService.Heartbeat:Connect(function()
        task.wait(3) -- Check every 3 seconds
        
        pcall(function()
            -- Quick check for new threats
            local newThreats = 0
            
            -- Check for new attack remotes
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and obj.Parent then
                    local name = obj.Name:lower()
                    if name:find("damage") or name:find("attack") or name:find("hurt") then
                        obj.Parent = nil
                        newThreats = newThreats + 1
                        if fixSettings.showFixLog then
                            print("🔄 Auto-blocked new remote: " .. obj.Name)
                        end
                    end
                end
            end
            
            -- Check for new guards near eggs
            local eggArea = Workspace:FindFirstChild("AreaEggSlotsClient")
            if eggArea then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Humanoid") and obj.Parent ~= LocalPlayer.Character and obj.Health > 0 then
                        local rootPart = obj.Parent:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            for _, eggObj in pairs(eggArea:GetChildren()) do
                                if eggObj:FindFirstChildOfClass("BasePart") then
                                    local distance = (rootPart.Position - eggObj:FindFirstChildOfClass("BasePart").Position).Magnitude
                                    if distance < 100 then
                                        obj.Health = 0
                                        newThreats = newThreats + 1
                                        if fixSettings.showFixLog then
                                            print("🔄 Auto-disabled new guard: " .. obj.Parent.Name)
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Maintain player invincibility
            if fixSettings.makePlayerInvincible and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end)
    end)
    
    table.insert(guardProtection.activeConnections, protectionConnection)
    return protectionConnection
end

-- ========================================================
-- SIMPLE CONTROL GUI
-- ========================================================

local function createFixGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "InvisibleGuardFix"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 180)
    frame.Position = UDim2.new(1, -300, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🔧 GUARD ATTACK FIX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 35)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Ready to fix invisible guard attacks"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame
    
    -- Fix button
    local fixButton = Instance.new("TextButton")
    fixButton.Size = UDim2.new(1, -10, 0, 35)
    fixButton.Position = UDim2.new(0, 5, 0, 60)
    fixButton.BackgroundColor3 = Color3.fromRGB(80, 150, 200)
    fixButton.Text = "🔧 FIX INVISIBLE ATTACKS"
    fixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fixButton.TextSize = 12
    fixButton.Font = Enum.Font.SourceSansBold
    fixButton.BorderSizePixel = 0
    fixButton.Parent = frame
    
    local fixCorner = Instance.new("UICorner")
    fixCorner.CornerRadius = UDim.new(0, 6)
    fixCorner.Parent = fixButton
    
    -- Invincible toggle
    local invincibleButton = Instance.new("TextButton")
    invincibleButton.Size = UDim2.new(0.48, 0, 0, 30)
    invincibleButton.Position = UDim2.new(0, 5, 0, 105)
    invincibleButton.BackgroundColor3 = fixSettings.makePlayerInvincible and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(100, 100, 100)
    invincibleButton.Text = "🛡️ INVINCIBLE: " .. (fixSettings.makePlayerInvincible and "ON" or "OFF")
    invincibleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    invincibleButton.TextSize = 10
    invincibleButton.Font = Enum.Font.SourceSansBold
    invincibleButton.BorderSizePixel = 0
    invincibleButton.Parent = frame
    
    local invincibleCorner = Instance.new("UICorner")
    invincibleCorner.CornerRadius = UDim.new(0, 4)
    invincibleCorner.Parent = invincibleButton
    
    -- Continuous toggle
    local continuousButton = Instance.new("TextButton")
    continuousButton.Size = UDim2.new(0.48, 0, 0, 30)
    continuousButton.Position = UDim2.new(0.52, 0, 0, 105)
    continuousButton.BackgroundColor3 = fixSettings.continuousFix and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(100, 100, 100)
    continuousButton.Text = "🔄 AUTO: " .. (fixSettings.continuousFix and "ON" or "OFF")
    continuousButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    continuousButton.TextSize = 10
    continuousButton.Font = Enum.Font.SourceSansBold
    continuousButton.BorderSizePixel = 0
    continuousButton.Parent = frame
    
    local continuousCorner = Instance.new("UICorner")
    continuousCorner.CornerRadius = UDim.new(0, 4)
    continuousCorner.Parent = continuousButton
    
    -- Stats label
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -10, 0, 20)
    statsLabel.Position = UDim2.new(0, 5, 0, 145)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "💀 Guards destroyed: 0 | 📡 Remotes blocked: 0"
    statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statsLabel.TextSize = 10
    statsLabel.Font = Enum.Font.SourceSans
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = frame
    
    -- Button events
    fixButton.MouseButton1Click:Connect(function()
        fixButton.Text = "🔧 FIXING..."
        fixButton.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
        statusLabel.Text = "🔧 Applying fixes to invisible guard attacks..."
        
        task.wait(0.1)
        local fixed = fixInvisibleGuardAttacks()
        
        fixButton.Text = "🔧 FIX INVISIBLE ATTACKS"
        fixButton.BackgroundColor3 = Color3.fromRGB(80, 150, 200)
        statusLabel.Text = "✅ Applied " .. fixed .. " fixes!"
        
        statsLabel.Text = "💀 Guards destroyed: " .. guardProtection.destroyedGuards .. " | 📡 Remotes blocked: " .. #guardProtection.blockedRemotes
        
        if fixSettings.continuousFix then
            startContinuousProtection()
        end
    end)
    
    invincibleButton.MouseButton1Click:Connect(function()
        fixSettings.makePlayerInvincible = not fixSettings.makePlayerInvincible
        invincibleButton.Text = "🛡️ INVINCIBLE: " .. (fixSettings.makePlayerInvincible and "ON" or "OFF")
        invincibleButton.BackgroundColor3 = fixSettings.makePlayerInvincible and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(100, 100, 100)
        
        if fixSettings.makePlayerInvincible then
            makePlayerInvincible()
            statusLabel.Text = "🛡️ Player invincibility enabled"
        else
            statusLabel.Text = "🛡️ Player invincibility disabled"
        end
    end)
    
    continuousButton.MouseButton1Click:Connect(function()
        fixSettings.continuousFix = not fixSettings.continuousFix
        continuousButton.Text = "🔄 AUTO: " .. (fixSettings.continuousFix and "ON" or "OFF")
        continuousButton.BackgroundColor3 = fixSettings.continuousFix and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(100, 100, 100)
        statusLabel.Text = "🔄 Continuous protection " .. (fixSettings.continuousFix and "enabled" or "disabled")
    end)
    
    return gui
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating Invisible Guard Attack Fix...")

-- Create GUI
local gui = createFixGUI()

-- Auto-apply fix on startup
print("🔄 Auto-applying fix on startup...")
task.wait(1)
local initialFixes = fixInvisibleGuardAttacks()

if fixSettings.continuousFix then
    startContinuousProtection()
end

print("✅ INVISIBLE GUARD ATTACK FIX READY!")
print("====================================")
print("🔧 Fix system loaded successfully")
print("🛡️ Applied " .. initialFixes .. " initial fixes")
print("📡 Remote attack blocking active")
print("💀 Hidden guard destruction active")
print("🔄 Continuous protection available")
print("====================================")
print("💡 Features:")
print("   • Block remote attack events")
print("   • Destroy hidden/invisible guards")
print("   • Optional player invincibility")
print("   • Continuous threat protection")
print("   • Real-time guard elimination")
print("====================================")
print("🎯 You should now be safe from invisible guard attacks!")

-- Export functions
getgenv().fixInvisibleGuards = fixInvisibleGuardAttacks
getgenv().makeInvincible = makePlayerInvincible
getgenv().blockAttacks = blockRemoteAttacks