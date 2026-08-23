-- ========================================================
-- UNIVERSAL GUARD BYPASS - ALL NPC DETECTION SYSTEMS
-- Bypass untuk semua jenis NPC guard di semua area
-- ========================================================

print("🛡️ LOADING UNIVERSAL GUARD BYPASS...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- UNIVERSAL BYPASS DATA
-- ========================================================

local bypassData = {
    allNPCs = {},
    guardNPCs = {},
    detectionScripts = {},
    raycastingSystems = {},
    proximityDetectors = {},
    totalBypassed = 0,
    activeConnections = {},
    bypassedAreas = {}
}

local bypassSettings = {
    destroyNPCVision = true,        -- Hancurkan sistem vision NPC
    disableRaycasting = true,       -- Disable raycasting detection
    disableProximity = true,        -- Disable proximity detection
    disableAllScripts = true,       -- Disable semua script NPC
    makeNPCsBlind = true,          -- Buat NPC tidak bisa melihat
    disableAttackSystems = true,    -- Disable sistem attack NPC
    universalMode = true,          -- Mode universal untuk semua area
    showBypassInfo = true,         -- Tampilkan info bypass
    continuousScanning = true      -- Scan terus-menerus
}

-- ========================================================
-- UNIVERSAL NPC DETECTION
-- ========================================================

local function isNPCGuard(obj)
    if not obj or not obj.Name then return false end
    
    local name = obj.Name:lower()
    local className = obj.ClassName
    
    -- Universal NPC patterns (lebih luas)
    local npcPatterns = {
        -- Basic NPCs
        "npc", "bot", "ai", "character", "mob", "enemy", "hostile",
        
        -- Guards
        "guard", "security", "police", "officer", "defender", "protector",
        "sentinel", "keeper", "warden", "patrol", "watchman",
        
        -- Animals/creatures that can be guards
        "chicken", "ayam", "dog", "cat", "wolf", "bear", "lion", "tiger",
        "dragon", "bird", "eagle", "hawk", "snake", "spider", "shark",
        
        -- Humanoid NPCs
        "villager", "citizen", "resident", "merchant", "trader", "seller",
        "worker", "farmer", "miner", "hunter", "soldier", "warrior",
        
        -- Game specific
        "bandit", "thief", "robber", "outlaw", "criminal", "pirate",
        "zombie", "skeleton", "ghost", "spirit", "demon", "monster"
    }
    
    -- Check name patterns
    for _, pattern in ipairs(npcPatterns) do
        if name:find(pattern) then
            return true, "name_match"
        end
    end
    
    -- Check if it's a Model with Humanoid (most NPCs)
    if className == "Model" then
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Check if it's NOT a real player
            local isPlayer = false
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character == obj then
                    isPlayer = true
                    break
                end
            end
            
            if not isPlayer then
                -- It's an NPC - check additional characteristics
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if rootPart then
                    -- Check for typical NPC features
                    local hasBodyVelocity = obj:FindFirstChildOfClass("BodyVelocity") or obj:FindFirstChildOfClass("BodyPosition")
                    local hasPathfindingScript = false
                    
                    -- Check for pathfinding or AI scripts
                    for _, child in pairs(obj:GetDescendants()) do
                        if child:IsA("Script") or child:IsA("LocalScript") then
                            local scriptName = child.Name:lower()
                            if scriptName:find("ai") or scriptName:find("pathfind") or 
                               scriptName:find("follow") or scriptName:find("chase") or
                               scriptName:find("attack") or scriptName:find("detect") then
                                hasPathfindingScript = true
                                break
                            end
                        end
                    end
                    
                    if hasBodyVelocity or hasPathfindingScript then
                        return true, "ai_npc"
                    else
                        -- Generic humanoid NPC detection
                        return true, "generic_npc"
                    end
                end
            end
        end
    end
    
    return false, nil
end

local function findDetectionScripts(npcObj)
    local detectionScripts = {}
    
    -- Scan all descendants for detection-related scripts
    for _, child in pairs(npcObj:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") then
            local scriptName = child.Name:lower()
            
            -- Detection script patterns
            local detectionPatterns = {
                "detect", "vision", "sight", "see", "look", "watch", "observe",
                "scan", "search", "find", "spot", "notice", "alert", "alarm",
                "chase", "follow", "pursue", "track", "hunt", "patrol",
                "attack", "damage", "hurt", "kill", "fight", "combat",
                "raycast", "ray", "cast", "line", "check", "test", "validate"
            }
            
            for _, pattern in ipairs(detectionPatterns) do
                if scriptName:find(pattern) then
                    table.insert(detectionScripts, child)
                    break
                end
            end
        end
    end
    
    return detectionScripts
end

local function findProximityDetectors(npcObj)
    local proximityObjects = {}
    
    -- Look for proximity detection objects
    for _, child in pairs(npcObj:GetDescendants()) do
        -- Check for Region3 detectors
        if child.Name:lower():find("region") or child.Name:lower():find("zone") then
            table.insert(proximityObjects, child)
        end
        
        -- Check for invisible parts used for detection
        if child:IsA("BasePart") then
            if child.Transparency >= 0.9 and child.CanCollide == false then
                local size = child.Size
                if size.X > 5 or size.Y > 5 or size.Z > 5 then
                    table.insert(proximityObjects, child)
                end
            end
        end
    end
    
    return proximityObjects
end
-- ========================================================
-- UNIVERSAL BYPASS FUNCTIONS
-- ========================================================

local function bypassNPCDetection(npcObj)
    local bypassCount = 0
    local bypassMethods = {}
    
    if bypassSettings.showBypassInfo then
        print("🎯 Bypassing NPC: " .. npcObj.Name)
    end
    
    -- Method 1: Disable all scripts
    if bypassSettings.disableAllScripts then
        local detectionScripts = findDetectionScripts(npcObj)
        for _, script in pairs(detectionScripts) do
            pcall(function()
                script.Disabled = true
                script.Parent = nil  -- Move script away
                bypassCount = bypassCount + 1
                table.insert(bypassMethods, "Script: " .. script.Name)
            end)
        end
        
        -- Also disable ALL scripts in the NPC (aggressive approach)
        for _, script in pairs(npcObj:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") then
                pcall(function()
                    script.Disabled = true
                    bypassCount = bypassCount + 1
                end)
            end
        end
    end
    
    -- Method 2: Destroy/disable humanoid (makes NPC unable to move/attack)
    local humanoid = npcObj:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            -- Don't destroy, just disable critical functions
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.MaxHealth = 0
            humanoid.Health = 0
            humanoid.PlatformStand = true
            bypassCount = bypassCount + 1
            table.insert(bypassMethods, "Humanoid disabled")
        end)
    end
    
    -- Method 3: Disable proximity detectors
    if bypassSettings.disableProximity then
        local proximityObjects = findProximityDetectors(npcObj)
        for _, obj in pairs(proximityObjects) do
            pcall(function()
                obj.Parent = nil
                bypassCount = bypassCount + 1
                table.insert(bypassMethods, "Proximity: " .. obj.Name)
            end)
        end
    end
    
    -- Method 4: Remove/disable body parts that could contain detection
    local bodyParts = {"Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
    for _, partName in pairs(bodyParts) do
        local part = npcObj:FindFirstChild(partName)
        if part then
            -- Remove any Touched connections or similar
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("Script") or child:IsA("LocalScript") then
                    pcall(function()
                        child.Disabled = true
                        child.Parent = nil
                        bypassCount = bypassCount + 1
                    end)
                end
            end
        end
    end
    
    -- Method 5: Disable raycasting by removing/disabling raycast objects
    if bypassSettings.disableRaycasting then
        for _, child in pairs(npcObj:GetDescendants()) do
            -- Look for objects that might be used for raycasting
            if child.Name:lower():find("ray") or child.Name:lower():find("cast") or
               child.Name:lower():find("line") or child.Name:lower():find("beam") then
                pcall(function()
                    child.Parent = nil
                    bypassCount = bypassCount + 1
                    table.insert(bypassMethods, "Raycast: " .. child.Name)
                end)
            end
        end
    end
    
    -- Method 6: Make NPC completely invisible and non-functional
    if bypassSettings.makeNPCsBlind then
        pcall(function()
            -- Make all parts invisible
            for _, part in pairs(npcObj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    part.CanCollide = false
                    part.Anchored = true
                end
            end
            
            -- Remove animations and sounds
            for _, obj in pairs(npcObj:GetDescendants()) do
                if obj:IsA("Sound") or obj:IsA("Animation") or obj:IsA("AnimationTrack") then
                    obj:Destroy()
                    bypassCount = bypassCount + 1
                end
            end
        end)
    end
    
    -- Method 7: Teleport NPC away (nuclear option)
    local rootPart = npcObj:FindFirstChild("HumanoidRootPart") or npcObj:FindFirstChild("Torso")
    if rootPart then
        pcall(function()
            rootPart.CFrame = CFrame.new(0, -10000, 0)  -- Teleport underground
            bypassCount = bypassCount + 1
            table.insert(bypassMethods, "Teleported away")
        end)
    end
    
    if bypassSettings.showBypassInfo and bypassCount > 0 then
        print("✅ Bypassed " .. bypassCount .. " detection systems on " .. npcObj.Name)
        for _, method in pairs(bypassMethods) do
            print("   📌 " .. method)
        end
    end
    
    return bypassCount
end

local function scanAndBypassAllNPCs()
    print("🔍 Scanning for ALL NPCs in workspace...")
    
    local totalNPCs = 0
    local totalBypassed = 0
    
    -- Scan entire workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local isNPC, detectionType = isNPCGuard(obj)
            if isNPC then
                totalNPCs = totalNPCs + 1
                table.insert(bypassData.allNPCs, obj)
                
                local bypassed = bypassNPCDetection(obj)
                if bypassed > 0 then
                    totalBypassed = totalBypassed + 1
                    bypassData.totalBypassed = bypassData.totalBypassed + 1
                end
                
                if bypassSettings.showBypassInfo then
                    print("🤖 Found NPC: " .. obj.Name .. " (Type: " .. (detectionType or "unknown") .. ")")
                end
            end
        end)
    end
    
    print("✅ Universal NPC Bypass Complete!")
    print("   🤖 Total NPCs found: " .. totalNPCs)
    print("   🛡️ NPCs bypassed: " .. totalBypassed)
    print("   🎯 All guard detection systems disabled!")
    
    return totalNPCs, totalBypassed
end

local function continuousBypassMode()
    if not bypassSettings.continuousScanning then return end
    
    print("🔄 Starting continuous bypass mode...")
    
    local connection = RunService.Heartbeat:Connect(function()
        if not bypassSettings.continuousScanning then return end
        
        -- Scan for new NPCs every few seconds
        task.wait(2)
        
        -- Quick scan for new NPCs
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                local isNPC, _ = isNPCGuard(obj)
                if isNPC then
                    -- Check if we haven't bypassed this NPC yet
                    local alreadyBypassed = false
                    for _, bypassedNPC in pairs(bypassData.allNPCs) do
                        if bypassedNPC == obj then
                            alreadyBypassed = true
                            break
                        end
                    end
                    
                    if not alreadyBypassed then
                        local bypassed = bypassNPCDetection(obj)
                        if bypassed > 0 then
                            table.insert(bypassData.allNPCs, obj)
                            bypassData.totalBypassed = bypassData.totalBypassed + 1
                            
                            if bypassSettings.showBypassInfo then
                                print("🔄 Auto-bypassed new NPC: " .. obj.Name)
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    table.insert(bypassData.activeConnections, connection)
    return connection
end
-- ========================================================
-- QUICK BYPASS FUNCTIONS
-- ========================================================

local function quickUniversalBypass()
    print("⚡ QUICK UNIVERSAL BYPASS MODE")
    
    local npcCount, bypassedCount = scanAndBypassAllNPCs()
    
    if bypassedCount > 0 then
        -- Start continuous mode
        continuousBypassMode()
        
        print("🎉 SUCCESS!")
        print("   🤖 " .. npcCount .. " NPCs processed")
        print("   🛡️ " .. bypassedCount .. " NPCs bypassed")
        print("   🔄 Continuous bypass mode active")
        print("   🎯 You should now be immune to ALL guard detection!")
    else
        print("⚠️ No NPCs found or bypass failed")
    end
    
    return npcCount, bypassedCount
end

local function targetSpecificArea(areaName)
    print("🎯 Targeting specific area: " .. areaName)
    
    local areaFolder = Workspace:FindFirstChild(areaName)
    if not areaFolder then
        print("❌ Area '" .. areaName .. "' not found!")
        return 0
    end
    
    local bypassed = 0
    
    for _, obj in pairs(areaFolder:GetDescendants()) do
        pcall(function()
            local isNPC, _ = isNPCGuard(obj)
            if isNPC then
                local bypassCount = bypassNPCDetection(obj)
                if bypassCount > 0 then
                    bypassed = bypassed + 1
                end
            end
        end)
    end
    
    print("✅ Area bypass complete! NPCs bypassed: " .. bypassed)
    return bypassed
end

-- ========================================================
-- EMERGENCY FUNCTIONS
-- ========================================================

local function emergencyBypass()
    print("🚨 EMERGENCY BYPASS - NUCLEAR MODE")
    
    -- Nuclear approach: disable EVERYTHING that could be a detection system
    local disabled = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            -- Disable all scripts
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                obj.Disabled = true
                disabled = disabled + 1
            end
            
            -- Destroy all humanoids except player's
            if obj:IsA("Humanoid") and obj.Parent ~= LocalPlayer.Character then
                obj.Health = 0
                obj.MaxHealth = 0
                obj.WalkSpeed = 0
                disabled = disabled + 1
            end
            
            -- Remove all proximity prompts and detectors
            if obj:IsA("ProximityPrompt") or obj.Name:lower():find("detect") then
                obj:Destroy()
                disabled = disabled + 1
            end
        end)
    end
    
    print("💥 NUCLEAR BYPASS COMPLETE!")
    print("   🛡️ " .. disabled .. " potential detection systems disabled")
    print("   ⚠️ This may cause game instability, but you should be fully protected")
    
    return disabled
end

local function stopAllBypass()
    print("🛑 Stopping all bypass systems...")
    
    -- Disconnect all connections
    for _, connection in pairs(bypassData.activeConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    bypassData.activeConnections = {}
    bypassSettings.continuousScanning = false
    
    print("✅ All bypass systems stopped")
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Starting Universal Guard Bypass...")

-- Execute immediate bypass
local npcCount, bypassedCount = quickUniversalBypass()

print("✅ UNIVERSAL GUARD BYPASS READY!")
print("====================================")
print("🛡️ Universal bypass system loaded")
print("🤖 Processed " .. npcCount .. " NPCs")
print("🎯 Bypassed " .. bypassedCount .. " detection systems")
print("🔄 Continuous scanning active")
print("====================================")
print("💡 Available Commands:")
print("   quickUniversalBypass() - Run bypass again")
print("   targetSpecificArea('AreaName') - Target specific area")
print("   emergencyBypass() - Nuclear bypass mode")
print("   stopAllBypass() - Stop all bypass systems")
print("====================================")
print("🎮 You should now be protected from ALL guard types!")

-- Export functions for manual use
getgenv().quickUniversalBypass = quickUniversalBypass
getgenv().targetSpecificArea = targetSpecificArea
getgenv().emergencyBypass = emergencyBypass
getgenv().stopAllBypass = stopAllBypass
getgenv().bypassSpecificNPC = bypassNPCDetection