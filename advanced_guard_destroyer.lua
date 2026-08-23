-- ========================================================
-- ADVANCED GUARD DESTROYER - COMPLETE GUARD ELIMINATION
-- Menghancurkan guard visual + NPC + scripts + detection
-- ========================================================

print("🛡️ LOADING ADVANCED GUARD DESTROYER...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- ADVANCED DESTROYER DATA
-- ========================================================

local destroyData = {
    guardNPCs = {},
    guardVisuals = {},
    guardScripts = {},
    detectionZones = {},
    eggGuards = {},
    totalDestroyed = 0,
    scanResults = {
        npcsFound = 0,
        visualsFound = 0,
        scriptsFound = 0,
        zonesFound = 0,
        totalScanned = 0
    }
}

local destroySettings = {
    destroyNPCs = true,           -- Hancurkan guard NPC/humanoid
    destroyVisuals = true,        -- Hancurkan visual guard objects  
    destroyScripts = true,        -- Disable guard scripts
    destroyZones = true,          -- Hancurkan detection zones
    disableRemotes = true,        -- Disable remote events/functions
    makeInvisible = true,         -- Buat guard invisible
    removeCollision = true,       -- Hapus collision
    continuousMode = true,        -- Mode continuous destroyer
    showDestruction = true        -- Log destruction process
}

-- ========================================================
-- ADVANCED DETECTION FUNCTIONS
-- ========================================================

local function isGuardNPC(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    local className = obj.ClassName
    
    -- Guard NPC detection patterns
    local guardPatterns = {
        "guard", "security", "police", "officer", "watchman", "defender",
        "protector", "sentinel", "keeper", "warden", "patrol", "bouncer",
        "soldier", "warrior", "fighter", "guardian", "sentry"
    }
    
    -- Check name patterns
    for _, pattern in ipairs(guardPatterns) do
        if name:find(pattern) then
            return true
        end
    end
    
    -- Check if it's a hostile NPC near egg areas
    if className == "Model" then
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Check for weapons or hostile indicators
            for _, child in pairs(obj:GetChildren()) do
                local childName = child.Name:lower()
                if childName:find("weapon") or childName:find("gun") or 
                   childName:find("sword") or childName:find("baton") or
                   childName:find("club") or childName:find("stick") then
                    return true
                end
            end
            
            -- Check for guard-like clothing/accessories
            for _, descendant in pairs(obj:GetDescendants()) do
                if descendant:IsA("Accessory") or descendant:IsA("Hat") then
                    local accName = descendant.Name:lower()
                    if accName:find("hat") or accName:find("helmet") or 
                       accName:find("cap") or accName:find("uniform") then
                        return true
                    end
                end
            end
            
            -- Check if NPC is near egg areas (likely a guard)
            if obj:FindFirstChild("HumanoidRootPart") then
                local eggArea = Workspace:FindFirstChild("AreaEggSlotsClient")
                if eggArea then
                    local npcPos = obj.HumanoidRootPart.Position
                    for _, eggObj in pairs(eggArea:GetChildren()) do
                        if eggObj:FindFirstChild("HumanoidRootPart") or eggObj:FindFirstChildOfClass("BasePart") then
                            local eggPos = (eggObj:FindFirstChild("HumanoidRootPart") or eggObj:FindFirstChildOfClass("BasePart")).Position
                            local distance = (npcPos - eggPos).Magnitude
                            if distance < 100 then -- Within 100 studs of egg area
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    
    return false
end

local function isGuardScript(obj)
    if not obj then return false end
    
    local name = obj.Name:lower()
    
    if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
        -- Guard script patterns
        local guardScriptPatterns = {
            "guard", "security", "protection", "defend", "attack", "combat",
            "hostile", "aggressive", "patrol", "chase", "hunt", "target",
            "damage", "hurt", "kill", "eliminate", "fight", "battle"
        }
        
        for _, pattern in ipairs(guardScriptPatterns) do
            if name:find(pattern) then
                return true
            end
        end
        
        -- Check script parent (if it's in a guard NPC)
        local parent = obj.Parent
        while parent do
            if isGuardNPC(parent) then
                return true
            end
            parent = parent.Parent
        end
    end
    
    return false
end

local function isDetectionZone(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    
    -- Detection zone patterns
    local zonePatterns = {
        "zone", "area", "region", "trigger", "detector", "sensor", "range",
        "radius", "field", "boundary", "perimeter", "safe", "danger", "alert"
    }
    
    for _, pattern in ipairs(zonePatterns) do
        if name:find(pattern) then
            return true
        end
    end
    
    -- Check for invisible collision parts (common for detection)
    if obj:IsA("BasePart") then
        if obj.Transparency >= 0.9 and obj.CanCollide == true then
            if obj.Size.X > 10 or obj.Size.Z > 10 then -- Large invisible parts
                return true
            end
        end
    end
    
    return false
end

local function isEggGuardVisual(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    
    -- Egg guard visual patterns (objects that look like guards)
    if name:find("guard") and (name:find("egg") or obj.Parent.Name:lower():find("egg")) then
        return true
    end
    
    -- Check if it's near egg areas
    if obj:IsA("Model") or obj:IsA("BasePart") then
        local eggArea = Workspace:FindFirstChild("AreaEggSlotsClient")
        if eggArea and obj:FindFirstChildOfClass("BasePart") then
            local objPos = obj:FindFirstChildOfClass("BasePart").Position
            for _, eggObj in pairs(eggArea:GetChildren()) do
                if eggObj:FindFirstChildOfClass("BasePart") then
                    local eggPos = eggObj:FindFirstChildOfClass("BasePart").Position
                    local distance = (objPos - eggPos).Magnitude
                    if distance < 50 then -- Very close to eggs
                        return true
                    end
                end
            end
        end
    end
    
    return false
end
-- ========================================================
-- COMPREHENSIVE SCAN FUNCTIONS
-- ========================================================

local function scanForAllGuards()
    print("🔍 Comprehensive guard scan starting...")
    
    -- Reset data
    destroyData = {
        guardNPCs = {}, guardVisuals = {}, guardScripts = {}, 
        detectionZones = {}, eggGuards = {}, totalDestroyed = 0,
        scanResults = {npcsFound = 0, visualsFound = 0, scriptsFound = 0, zonesFound = 0, totalScanned = 0}
    }
    
    local startTime = tick()
    
    -- Scan all workspace descendants
    for _, obj in pairs(Workspace:GetDescendants()) do
        destroyData.scanResults.totalScanned = destroyData.scanResults.totalScanned + 1
        
        pcall(function()
            -- Check for guard NPCs
            if isGuardNPC(obj) then
                table.insert(destroyData.guardNPCs, obj)
                destroyData.scanResults.npcsFound = destroyData.scanResults.npcsFound + 1
                if destroySettings.showDestruction then
                    print("🤖 Found Guard NPC: " .. obj.Name)
                end
                
            -- Check for guard scripts
            elseif isGuardScript(obj) then
                table.insert(destroyData.guardScripts, obj)
                destroyData.scanResults.scriptsFound = destroyData.scanResults.scriptsFound + 1
                if destroySettings.showDestruction then
                    print("📜 Found Guard Script: " .. obj.Name)
                end
                
            -- Check for detection zones
            elseif isDetectionZone(obj) then
                table.insert(destroyData.detectionZones, obj)
                destroyData.scanResults.zonesFound = destroyData.scanResults.zonesFound + 1
                if destroySettings.showDestruction then
                    print("🚨 Found Detection Zone: " .. obj.Name)
                end
                
            -- Check for egg guard visuals
            elseif isEggGuardVisual(obj) then
                table.insert(destroyData.eggGuards, obj)
                destroyData.scanResults.visualsFound = destroyData.scanResults.visualsFound + 1
                if destroySettings.showDestruction then
                    print("🛡️ Found Egg Guard Visual: " .. obj.Name)
                end
            end
        end)
    end
    
    local scanTime = math.floor((tick() - startTime) * 1000) / 1000
    local totalFound = destroyData.scanResults.npcsFound + destroyData.scanResults.scriptsFound + 
                      destroyData.scanResults.zonesFound + destroyData.scanResults.visualsFound
    
    print("✅ Comprehensive guard scan complete!")
    print("   📊 Objects scanned: " .. destroyData.scanResults.totalScanned)
    print("   🤖 Guard NPCs found: " .. destroyData.scanResults.npcsFound)
    print("   📜 Guard scripts found: " .. destroyData.scanResults.scriptsFound)  
    print("   🚨 Detection zones found: " .. destroyData.scanResults.zonesFound)
    print("   🛡️ Guard visuals found: " .. destroyData.scanResults.visualsFound)
    print("   ⏱️ Scan time: " .. scanTime .. "s")
    
    return totalFound
end

-- ========================================================
-- ADVANCED DESTRUCTION FUNCTIONS
-- ========================================================

local function destroyGuardNPCs()
    print("💀 Destroying Guard NPCs...")
    local destroyed = 0
    
    for _, guardNPC in ipairs(destroyData.guardNPCs) do
        pcall(function()
            if guardNPC and guardNPC.Parent then
                if destroySettings.showDestruction then
                    print("🔥 Destroying Guard NPC: " .. guardNPC.Name)
                end
                
                -- First disable the humanoid to stop AI
                local humanoid = guardNPC:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                    humanoid.MaxHealth = 0
                    humanoid.PlatformStand = true
                    humanoid.Sit = true
                end
                
                -- Disable all scripts in the NPC
                for _, script in pairs(guardNPC:GetDescendants()) do
                    if script:IsA("Script") or script:IsA("LocalScript") then
                        script.Enabled = false
                        script.Parent = nil
                    end
                end
                
                -- Remove weapons
                for _, child in pairs(guardNPC:GetChildren()) do
                    if child:IsA("Tool") or child.Name:lower():find("weapon") then
                        child:Destroy()
                    end
                end
                
                -- Make invisible or destroy completely
                if destroySettings.makeInvisible then
                    for _, part in pairs(guardNPC:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                            part.CanCollide = false
                        elseif part:IsA("Decal") or part:IsA("Texture") then
                            part.Transparency = 1
                        end
                    end
                else
                    guardNPC:Destroy()
                end
                
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.guardNPCs = {}
    print("✅ Guard NPCs destroyed: " .. destroyed)
    return destroyed
end

local function destroyGuardScripts()
    print("📜 Destroying Guard Scripts...")
    local destroyed = 0
    
    for _, guardScript in ipairs(destroyData.guardScripts) do
        pcall(function()
            if guardScript and guardScript.Parent then
                if destroySettings.showDestruction then
                    print("🔥 Destroying Guard Script: " .. guardScript.Name)
                end
                
                -- Disable and remove script
                guardScript.Enabled = false
                guardScript.Parent = nil
                guardScript:Destroy()
                
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.guardScripts = {}
    print("✅ Guard scripts destroyed: " .. destroyed)
    return destroyed
end

local function destroyDetectionZones()
    print("🚨 Destroying Detection Zones...")
    local destroyed = 0
    
    for _, zone in ipairs(destroyData.detectionZones) do
        pcall(function()
            if zone and zone.Parent then
                if destroySettings.showDestruction then
                    print("🔥 Destroying Detection Zone: " .. zone.Name)
                end
                
                -- Disable collision and make invisible
                if zone:IsA("BasePart") then
                    zone.CanCollide = false
                    zone.Transparency = 1
                    
                    -- Remove all scripts in the zone
                    for _, script in pairs(zone:GetDescendants()) do
                        if script:IsA("Script") or script:IsA("LocalScript") then
                            script.Enabled = false
                            script:Destroy()
                        end
                    end
                end
                
                zone:Destroy()
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.detectionZones = {}
    print("✅ Detection zones destroyed: " .. destroyed)
    return destroyed
end

local function destroyEggGuardVisuals()
    print("🛡️ Destroying Egg Guard Visuals...")
    local destroyed = 0
    
    for _, eggGuard in ipairs(destroyData.eggGuards) do
        pcall(function()
            if eggGuard and eggGuard.Parent then
                if destroySettings.showDestruction then
                    print("🔥 Destroying Egg Guard Visual: " .. eggGuard.Name)
                end
                
                eggGuard:Destroy()
                destroyed = destroyed + 1
                destroyData.totalDestroyed = destroyData.totalDestroyed + 1
            end
        end)
    end
    
    destroyData.eggGuards = {}
    print("✅ Egg guard visuals destroyed: " .. destroyed)
    return destroyed
end

-- ========================================================
-- REMOTE EVENTS DISABLER
-- ========================================================

local function disableRemoteEvents()
    print("📡 Disabling Remote Events...")
    local disabled = 0
    
    -- Disable ReplicatedStorage remotes
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("guard") or name:find("damage") or name:find("attack") or 
                   name:find("hurt") or name:find("kill") or name:find("combat") then
                    obj.Parent = nil
                    disabled = disabled + 1
                    if destroySettings.showDestruction then
                        print("📡 Disabled Remote: " .. obj.Name)
                    end
                end
            end
        end
    end)
    
    print("✅ Remote events disabled: " .. disabled)
    return disabled
end
-- ========================================================
-- MAIN DESTRUCTION FUNCTION
-- ========================================================

local function destroyAllGuards()
    print("💥 STARTING COMPLETE GUARD ELIMINATION...")
    
    local totalFound = scanForAllGuards()
    
    if totalFound == 0 then
        print("⚠️ No guards found to destroy!")
        return 0
    end
    
    local npcsDestroyed = destroySettings.destroyNPCs and destroyGuardNPCs() or 0
    local scriptsDestroyed = destroySettings.destroyScripts and destroyGuardScripts() or 0  
    local zonesDestroyed = destroySettings.destroyZones and destroyDetectionZones() or 0
    local visualsDestroyed = destroySettings.destroyVisuals and destroyEggGuardVisuals() or 0
    local remotesDisabled = destroySettings.disableRemotes and disableRemoteEvents() or 0
    
    local totalDestroyed = npcsDestroyed + scriptsDestroyed + zonesDestroyed + visualsDestroyed
    
    print("🎉 COMPLETE GUARD ELIMINATION FINISHED!")
    print("==========================================")
    print("🤖 Guard NPCs destroyed: " .. npcsDestroyed)
    print("📜 Guard scripts destroyed: " .. scriptsDestroyed)
    print("🚨 Detection zones destroyed: " .. zonesDestroyed)
    print("🛡️ Guard visuals destroyed: " .. visualsDestroyed)
    print("📡 Remote events disabled: " .. remotesDisabled)
    print("💥 Total destroyed: " .. totalDestroyed)
    print("==========================================")
    
    if totalDestroyed > 0 then
        print("🚀 Guards should no longer be able to attack you!")
        print("🛡️ All guard systems eliminated!")
    else
        print("⚠️ No guard objects were destroyed")
    end
    
    return totalDestroyed
end

-- ========================================================
-- CONTINUOUS GUARD DESTROYER
-- ========================================================

local function startContinuousDestroyer()
    print("🔄 Starting continuous guard destroyer...")
    
    local connection = RunService.Heartbeat:Connect(function()
        if not destroySettings.continuousMode then return end
        
        task.wait(5) -- Check every 5 seconds
        
        -- Quick scan for new guards
        local newGuards = 0
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if isGuardNPC(obj) or isGuardScript(obj) or isDetectionZone(obj) or isEggGuardVisual(obj) then
                    if destroySettings.showDestruction then
                        print("🎯 Auto-destroying new guard: " .. obj.Name)
                    end
                    
                    -- Instant destruction
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        obj.Enabled = false
                    end
                    
                    if obj:IsA("Model") then
                        local humanoid = obj:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.Health = 0
                        end
                    end
                    
                    obj:Destroy()
                    newGuards = newGuards + 1
                    destroyData.totalDestroyed = destroyData.totalDestroyed + 1
                end
            end)
        end
        
        if newGuards > 0 and destroySettings.showDestruction then
            print("🔄 Auto-destroyed " .. newGuards .. " new guards")
        end
    end)
    
    return connection
end

-- ========================================================
-- QUICK FUNCTIONS
-- ========================================================

local function quickGuardDestroy()
    print("⚡ QUICK GUARD DESTROY - NO GUI")
    
    local destroyed = destroyAllGuards()
    
    if destroyed > 0 then
        if destroySettings.continuousMode then
            startContinuousDestroyer()
            print("🔄 Continuous destroyer activated")
        end
        print("🎉 Quick guard destruction complete!")
        print("💥 " .. destroyed .. " guards eliminated!")
    else
        print("⚠️ No guards found to destroy")
    end
    
    return destroyed
end

-- ========================================================
-- SIMPLE GUI
-- ========================================================

local function createQuickGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AdvancedGuardDestroyer"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 150)
    frame.Position = UDim2.new(0, 20, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🛡️ GUARD DESTROYER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 35)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Ready to destroy guards"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame
    
    -- Destroy button
    local destroyButton = Instance.new("TextButton")
    destroyButton.Size = UDim2.new(1, -10, 0, 35)
    destroyButton.Position = UDim2.new(0, 5, 0, 60)
    destroyButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    destroyButton.Text = "💥 DESTROY ALL GUARDS"
    destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyButton.TextSize = 12
    destroyButton.Font = Enum.Font.SourceSansBold
    destroyButton.BorderSizePixel = 0
    destroyButton.Parent = frame
    
    local destroyCorner = Instance.new("UICorner")
    destroyCorner.CornerRadius = UDim.new(0, 6)
    destroyCorner.Parent = destroyButton
    
    -- Toggle continuous mode
    local continuousButton = Instance.new("TextButton")
    continuousButton.Size = UDim2.new(1, -10, 0, 30)
    continuousButton.Position = UDim2.new(0, 5, 0, 105)
    continuousButton.BackgroundColor3 = destroySettings.continuousMode and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(100, 100, 100)
    continuousButton.Text = "🔄 CONTINUOUS: " .. (destroySettings.continuousMode and "ON" or "OFF")
    continuousButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    continuousButton.TextSize = 11
    continuousButton.Font = Enum.Font.SourceSansBold
    continuousButton.BorderSizePixel = 0
    continuousButton.Parent = frame
    
    local continuousCorner = Instance.new("UICorner")
    continuousCorner.CornerRadius = UDim.new(0, 6)
    continuousCorner.Parent = continuousButton
    
    -- Button events
    destroyButton.MouseButton1Click:Connect(function()
        destroyButton.Text = "💀 DESTROYING..."
        destroyButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        statusLabel.Text = "💥 Destroying all guard systems..."
        
        task.wait(0.1)
        local destroyed = destroyAllGuards()
        
        destroyButton.Text = "💥 DESTROY ALL GUARDS"
        destroyButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        statusLabel.Text = "✅ " .. destroyed .. " guards destroyed!"
        
        if destroySettings.continuousMode then
            startContinuousDestroyer()
        end
    end)
    
    continuousButton.MouseButton1Click:Connect(function()
        destroySettings.continuousMode = not destroySettings.continuousMode
        continuousButton.Text = "🔄 CONTINUOUS: " .. (destroySettings.continuousMode and "ON" or "OFF")
        continuousButton.BackgroundColor3 = destroySettings.continuousMode and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(100, 100, 100)
        statusLabel.Text = "🔄 Continuous mode " .. (destroySettings.continuousMode and "enabled" or "disabled")
    end)
    
    return gui
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Creating Advanced Guard Destroyer...")

-- Create GUI
local gui = createQuickGUI()

print("✅ ADVANCED GUARD DESTROYER READY!")
print("====================================")
print("🛡️ Advanced guard elimination system loaded")
print("🎯 Targets: NPCs, Scripts, Zones, Visuals")
print("📡 Remote events will be disabled")
print("🔄 Continuous mode available")
print("====================================")
print("💡 Features:")
print("   • Complete NPC elimination")
print("   • Script disabling & removal")
print("   • Detection zone destruction")
print("   • Remote event blocking")
print("   • Continuous guard removal")
print("====================================")
print("⚡ Ready to eliminate all guard threats!")

-- Export functions
getgenv().quickDestroyAllGuards = quickGuardDestroy
getgenv().scanGuards = scanForAllGuards
getgenv().destroyGuards = destroyAllGuards