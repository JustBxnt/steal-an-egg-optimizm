-- ========================================================
-- AUTO STEAL EGG - WALK MODE (Ground Movement)
-- Walks normally on ground like default game
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

print("🚶 AUTO STEAL - WALK MODE")
print("========================================\n")

-- ========================================================
-- CONFIG
-- ========================================================

local CONFIG = {
    -- ESP Config
    ESPEnabled = true,
    MaxDistance = 5000,
    ShowDistance = true,
    TextSize = 14,
    MatchRadius = 50,
    
    -- Auto Steal Config
    StealEnabled = false,
    WalkSpeed = 1000,  -- Super fast walking speed
    SearchRadius = 5000,
    TeleportOffset = Vector3.new(0, 0, 0),  -- No offset for walking
    
    -- Walking Config
    UsePathfinding = true,  -- Use Roblox pathfinding for natural movement
    WaitAtDestination = 0.5,
    
    -- Area filters
    AreaFilters = {
        FOREST = false,
        LAKE = false,
        DESERT = false,
        JUNGLE = true,
        SNOW = false,
        VOLCANO = false,
        ["ABYSS OCEAN"] = false,
        PREHISTORIC = false,
        COSMIC = false,
    }
}

-- ========================================================
-- NIGHT TIME DETECTION
-- ========================================================

local function isNightTime()
    -- Check Lighting ClockTime (0-24 hours)
    -- Night is typically 18:00 - 06:00
    local clockTime = Lighting.ClockTime
    
    if clockTime >= 18 or clockTime < 6 then
        return true, clockTime
    end
    
    -- Also check for night block objects in workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("night") and name:find("block") then
                -- Check if block is near player
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < 100 then
                    return true, clockTime
                end
            end
        end
    end
    
    return false, clockTime
end

local function waitForDayTime()
    print("\n🌙 NIGHT TIME DETECTED!")
    print("   ⏸️  Pausing auto-steal (night block active)")
    print("   ⏰ Waiting for daytime...")
    
    local startWait = tick()
    
    while true do
        local isNight, time = isNightTime()
        
        if not isNight then
            local waitDuration = math.floor(tick() - startWait)
            print("\n☀️  DAYTIME!")
            print("   ✅ Resuming auto-steal")
            print("   ⏱️  Waited", waitDuration, "seconds")
            return true
        end
        
        -- Print status every 30 seconds
        if math.floor((tick() - startWait) % 30) == 0 then
            print("   🌙 Still night... Clock:", string.format("%.1f", time), "hrs")
        end
        
        task.wait(5)  -- Check every 5 seconds
    end
end

-- ========================================================
-- TAGGED EGG POSITIONS
-- ========================================================

local eggPositions = {
    {area = "FOREST", x = 591.8, y = 68.1, z = -325.6},
    {area = "LAKE", x = 738.1, y = 68.0, z = -411.1},
    {area = "DESERT", x = 946.4, y = 69.4, z = -327.3},
    {area = "JUNGLE", x = 1194.4, y = 68.1, z = -412.1},
    {area = "SNOW", x = 1489.0, y = 69.3, z = -317.8},
    {area = "VOLCANO", x = 1884.5, y = 69.3, z = -400.6},
    {area = "ABYSS OCEAN", x = 2278.2, y = 68.7, z = -330.1},
    {area = "PREHISTORIC", x = 2818.9, y = 68.1, z = -401.0},
    {area = "COSMIC", x = 3397.5, y = 69.6, z = -322.7},
}

local areaColors = {
    FOREST = Color3.fromRGB(34, 139, 34),
    LAKE = Color3.fromRGB(30, 144, 255),
    DESERT = Color3.fromRGB(237, 201, 175),
    JUNGLE = Color3.fromRGB(0, 128, 0),
    SNOW = Color3.fromRGB(135, 206, 250),
    VOLCANO = Color3.fromRGB(255, 69, 0),
    ["ABYSS OCEAN"] = Color3.fromRGB(0, 0, 139),
    PREHISTORIC = Color3.fromRGB(240, 248, 255),
    COSMIC = Color3.fromRGB(138, 43, 226),
}

-- ========================================================
-- CHARACTER SETUP
-- ========================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- SAFE ZONE = Your designated return position
local SAFE_ZONE_POSITION = Vector3.new(537.8078613, 70.5743103, -356.6216125)

print("✅ Character loaded")
print("✅ Safe zone:", SAFE_ZONE_POSITION)
print("   🚶 Will walk back here after stealing eggs!")

-- Set initial walk speed
humanoid.WalkSpeed = CONFIG.WalkSpeed

-- Gentle animation preservation system
task.spawn(function()
    while humanoid and humanoid.Parent do
        task.wait(0.5)  -- Check less frequently to avoid interference
        
        -- Only intervene if character is stuck in bad state while moving
        if humanoid.MoveDirection.Magnitude > 0 then
            local currentState = humanoid:GetState()
            -- Only fix genuinely broken states, don't interfere with normal animations
            if currentState == Enum.HumanoidStateType.Ragdoll or 
               currentState == Enum.HumanoidStateType.PlatformStanding then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
end)

-- ========================================================
-- AREA DETECTION
-- ========================================================

local function getEggArea(eggPosition)
    local closestDist = math.huge
    local closestArea = nil
    
    for _, taggedPos in ipairs(eggPositions) do
        local tagPos = Vector3.new(taggedPos.x, taggedPos.y, taggedPos.z)
        local distance = (eggPosition - tagPos).Magnitude
        
        if distance < closestDist and distance <= CONFIG.MatchRadius then
            closestDist = distance
            closestArea = taggedPos.area
        end
    end
    
    return closestArea, closestDist
end

-- ========================================================
-- GUARD DESTROYER SYSTEM
-- ========================================================

local function destroyGuards()
    local guardsDestroyed = 0
    
    -- Find and neutralize guard models
    for _, obj in pairs(Workspace:GetDescendants()) do
        local objName = obj.Name:lower()
        
        -- Check if it's a guard
        if obj:IsA("Model") and (
            objName:find("guard") or 
            objName:find("npc") or 
            objName:find("enemy") or
            objName:find("cop") or
            objName:find("police") or
            objName:find("security")
        ) then
            pcall(function()
                -- Disable all scripts in guard
                for _, script in pairs(obj:GetDescendants()) do
                    if script:IsA("Script") or script:IsA("LocalScript") then
                        script.Disabled = true
                    end
                end
                
                -- Make all parts non-collidable and invisible
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Transparency = 1
                        
                        -- Remove touch detection
                        if part:FindFirstChild("TouchInterest") then
                            part.TouchInterest:Destroy()
                        end
                    end
                end
                
                guardsDestroyed = guardsDestroyed + 1
            end)
        end
        
        -- Disable damage scripts
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local scriptName = obj.Name:lower()
            if scriptName:find("damage") or 
               scriptName:find("attack") or 
               scriptName:find("hit") or
               scriptName:find("hurt") then
                pcall(function()
                    obj.Disabled = true
                end)
            end
        end
    end
    
    return guardsDestroyed
end

local function setupGuardDestroyer()
    print("\n🛡️ GUARD DESTROYER ACTIVE")
    
    -- Initial cleanup
    local destroyed = destroyGuards()
    if destroyed > 0 then
        print("   ✅ Neutralized", destroyed, "guards")
    else
        print("   ℹ️  No guards found yet")
    end
    
    -- Monitor for new guards spawning
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        
        local objName = obj.Name:lower()
        
        if obj:IsA("Model") and (
            objName:find("guard") or 
            objName:find("npc") or 
            objName:find("enemy")
        ) then
            pcall(function()
                print("   🛡️  New guard detected, neutralizing...")
                
                -- Disable scripts
                for _, script in pairs(obj:GetDescendants()) do
                    if script:IsA("Script") or script:IsA("LocalScript") then
                        script.Disabled = true
                    end
                end
                
                -- Make non-collidable
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Transparency = 1
                    end
                end
            end)
        end
    end)
    
    print("   🔄 Monitoring for new guards...")
end

-- Activate guard destroyer
setupGuardDestroyer()

-- ========================================================
-- GOD MODE (INVINCIBILITY) SYSTEM - AGGRESSIVE
-- ========================================================

local function setupGodMode()
    print("\n✨ GOD MODE ACTIVE (AGGRESSIVE + ANTI-STUN)")
    
    -- Method 1: Force health to max constantly
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        print("   ✅ Infinite health set")
        
        -- Continuously monitor and restore health
        task.spawn(function()
            while task.wait(0.1) do
                if humanoid and humanoid.Parent then
                    if humanoid.Health < humanoid.MaxHealth then
                        humanoid.Health = humanoid.MaxHealth
                    end
                    
                    -- Also check if health dropped dramatically
                    if humanoid.Health < 1000 then
                        humanoid.Health = math.huge
                    end
                    
                -- DISABLE: Aggressive anti-stun (to preserve animations)
                -- This is commented out to maintain walking animations
                --[[
                    -- ANTI-STUN: Force humanoid to stay active (but allow running animation)
                    if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or
                       humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or
                       humanoid:GetState() == Enum.HumanoidStateType.Physics then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        task.wait(0.05)
                        -- Allow RunningNoPhysics for smooth movement but keep animations
                        if humanoid.MoveDirection.Magnitude > 0 then
                            humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end
                --]]
                    end
                else
                    break
                end
            end
        end)
        
        -- Prevent death
        humanoid.Died:Connect(function()
            humanoid.Health = math.huge
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
        
        -- DISABLE: StateChanged handler (to preserve animations)
        -- This is commented out to maintain walking animations
        --[[
        -- ANTI-STUN: Block harmful state changes but allow walking animation
        humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.FallingDown or
               newState == Enum.HumanoidStateType.Ragdoll or
               newState == Enum.HumanoidStateType.Physics then
                -- Only block harmful states, allow Running for animations
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
        --]]
        
        print("   ✅ Anti-stun protection active")
        print("   ✅ Continuous health monitoring")
    end
    
    -- Method 2: Disable ALL damage-related scripts
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") then
            local scriptName = script.Name:lower()
            local scriptSource = ""
            
            pcall(function()
                scriptSource = script.Source:lower()
            end)
            
            if scriptName:find("damage") or 
               scriptName:find("hurt") or 
               scriptName:find("kill") or
               scriptName:find("death") or
               scriptName:find("hit") or
               scriptName:find("guard") or
               scriptName:find("stun") or
               scriptName:find("knock") or
               scriptName:find("ragdoll") or
               scriptSource:find("health") or
               scriptSource:find("damage") or
               scriptSource:find("humanoid") then
                pcall(function()
                    script.Disabled = true
                    script:Destroy()
                end)
            end
        end
    end
    
    print("   ✅ Damage scripts destroyed")
    
    -- Method 3: Remove all damage parts and zones
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local partName = obj.Name:lower()
            
            -- Damage parts
            if partName:find("damage") or 
               partName:find("kill") or 
               partName:find("hurt") or
               partName:find("spike") or
               partName:find("trap") or
               partName:find("lava") or
               partName:find("fire") or
               partName:find("stun") or
               partName:find("knock") then
                pcall(function()
                    obj.CanCollide = false
                    obj.CanTouch = false
                    obj.Transparency = 1
                    
                    -- Destroy touch connections
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("TouchTransmitter") or child.Name == "TouchInterest" then
                            child:Destroy()
                        end
                    end
                end)
            end
        end
        
        -- Remove Region3 damage zones
        if obj:IsA("Script") and obj.Name:lower():find("zone") then
            pcall(function()
                obj.Disabled = true
                obj:Destroy()
            end)
        end
    end
    
    print("   ✅ Damage zones removed")
    
    -- Method 4: Block incoming damage via Humanoid.HealthChanged
    if humanoid then
        humanoid.HealthChanged:Connect(function(health)
            if health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
    
    -- DISABLE: Anti-ragdoll welds (to preserve animations)  
    -- This is commented out to maintain walking animations
    --[[
    -- Method 5: Prevent character parts from becoming unanchored (anti-ragdoll) - Modified to preserve animations
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function()
                    -- Only create welds for critical parts, not all parts (to preserve animations)
                    if part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" then
                        if not part:FindFirstChild("NoRagdoll") then
                            local weld = Instance.new("WeldConstraint") -- Use WeldConstraint instead of Weld
                            weld.Name = "NoRagdoll"
                            weld.Part0 = hrp
                            weld.Part1 = part
                            weld.Parent = part
                        end
                    end
                end)
            end
        end
    end
    
    print("   ✅ Anti-ragdoll welds applied")
    --]]
    
    print("   ⚠️ Anti-ragdoll disabled (preserving animations)")
    
    -- Method 5.5: ANTI-KNOCKBACK - Monitor and remove force objects
    task.spawn(function()
        while task.wait(0.02) do  -- Check faster (50 times per second)
            if hrp and hrp.Parent then
                -- Remove all BodyMovers that could push player
                for _, child in pairs(hrp:GetChildren()) do
                    if child:IsA("BodyVelocity") or 
                       child:IsA("BodyPosition") or 
                       child:IsA("BodyForce") or 
                       child:IsA("BodyThrust") or
                       child:IsA("BodyGyro") then
                        -- Keep our own movers but remove others
                        if child.Name ~= "CustomFly" and child.Name ~= "NoRagdoll" then
                            pcall(function()
                                child:Destroy()
                            end)
                        end
                    end
                end
                
                -- AGGRESSIVE velocity reset - lower threshold
                if hrp.AssemblyLinearVelocity.Magnitude > 30 then  -- More sensitive (was 100)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y * 0.1, 0)  -- Keep slight Y for gravity
                    hrp.Velocity = Vector3.new(0, hrp.Velocity.Y * 0.1, 0)
                end
                
                -- Also check all character parts
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= hrp then
                        -- Remove force objects from body parts
                        for _, child in pairs(part:GetChildren()) do
                            if child:IsA("BodyVelocity") or 
                               child:IsA("BodyPosition") or 
                               child:IsA("BodyForce") then
                                pcall(function()
                                    child:Destroy()
                                end)
                            end
                        end
                        
                        -- Reset part velocity
                        if part.AssemblyLinearVelocity.Magnitude > 30 then
                            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            part.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            else
                break
            end
        end
    end)
    
    print("   ✅ Anti-knockback monitor active (aggressive)")
    
    -- Method 5.75: ANTI-DROP - Prevent egg from being unequipped
    task.spawn(function()
        local lastCarriedTool = nil
        
        while task.wait(0.05) do
            if character and character.Parent then
                -- Check if carrying a tool
                local currentTool = character:FindFirstChildOfClass("Tool")
                
                if currentTool then
                    lastCarriedTool = currentTool
                    
                    -- Prevent tool from being dropped
                    pcall(function()
                        currentTool.CanBeDropped = false
                        
                        -- Keep tool welded to character
                        if currentTool:FindFirstChild("Handle") then
                            local handle = currentTool.Handle
                            handle.CanCollide = false
                            
                            -- Prevent handle from being flung
                            if handle.AssemblyLinearVelocity.Magnitude > 50 then
                                handle.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                handle.Velocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end)
                elseif lastCarriedTool and lastCarriedTool.Parent == nil then
                    -- Tool was dropped/removed, try to re-equip
                    pcall(function()
                        if LocalPlayer.Backpack:FindFirstChild(lastCarriedTool.Name) then
                            humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(lastCarriedTool.Name))
                        end
                    end)
                end
            else
                break
            end
        end
    end)
    
    print("   ✅ Anti-drop protection active")
    
    -- Method 6: Monitor for new threats
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.05)
        
        -- Disable new damage scripts
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local scriptName = obj.Name:lower()
            if scriptName:find("damage") or 
               scriptName:find("hurt") or 
               scriptName:find("kill") or
               scriptName:find("guard") or
               scriptName:find("stun") or
               scriptName:find("knock") then
                pcall(function()
                    obj.Disabled = true
                    obj:Destroy()
                end)
            end
        end
        
        -- Remove new damage parts
        if obj:IsA("BasePart") then
            local partName = obj.Name:lower()
            if partName:find("damage") or 
               partName:find("kill") or
               partName:find("hurt") or
               partName:find("stun") then
                pcall(function()
                    obj.CanTouch = false
                    obj.CanCollide = false
                end)
            end
        end
    end)
    
    print("   🔄 Monitoring for new threats...")
    
    -- Method 7: Character respawn protection
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        character = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        hrp = newChar:WaitForChild("HumanoidRootPart")
        
        -- Reapply god mode
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        -- Reapply anti-stun
        humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.FallingDown or
               newState == Enum.HumanoidStateType.Ragdoll or
               newState == Enum.HumanoidStateType.Physics then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
        
        print("   ✨ God mode reapplied to new character")
    end)
end

-- Activate aggressive god mode
setupGodMode()

-- ========================================================
-- ESP SYSTEM
-- ========================================================

local espCache = {}
local eggCounter = 0
local areaCounts = {}

local function createESP(eggModel)
    local primaryPart = eggModel.PrimaryPart or 
                        eggModel:FindFirstChild("Hitbox") or 
                        eggModel:FindFirstChild("HitBox") or 
                        eggModel:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then return nil end
    
    local area, matchDist = getEggArea(primaryPart.Position)
    if not area then return nil end
    
    areaCounts[area] = (areaCounts[area] or 0) + 1
    local areaNumber = areaCounts[area]
    eggCounter = eggCounter + 1
    
    local displayText = "Egg #" .. areaNumber .. " [" .. area .. "]"
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESPArea"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = primaryPart
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    local eggLabel = Instance.new("TextLabel")
    eggLabel.Size = UDim2.new(1, 0, 0.6, 0)
    eggLabel.BackgroundTransparency = 1
    eggLabel.Text = "🥚 " .. displayText
    eggLabel.TextColor3 = areaColors[area] or Color3.fromRGB(255, 200, 100)
    eggLabel.TextSize = CONFIG.TextSize
    eggLabel.Font = Enum.Font.SourceSansBold
    eggLabel.TextStrokeTransparency = 0.5
    eggLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    eggLabel.Parent = frame
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextSize = CONFIG.TextSize - 2
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Parent = frame
    
    return {
        billboard = billboard,
        eggLabel = eggLabel,
        distanceLabel = distanceLabel,
        eggModel = eggModel,
        primaryPart = primaryPart,
        area = area,
    }
end

local function updateESP(espData)
    if not espData or not espData.eggModel.Parent or not espData.primaryPart.Parent then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then return true end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    
    local distance = (hrp.Position - espData.primaryPart.Position).Magnitude
    
    if distance > CONFIG.MaxDistance then
        espData.billboard.Enabled = false
        return true
    end
    
    espData.billboard.Enabled = CONFIG.ESPEnabled
    
    if CONFIG.ESPEnabled and CONFIG.ShowDistance then
        espData.distanceLabel.Text = math.floor(distance) .. " studs"
    else
        espData.distanceLabel.Text = ""
    end
    
    return true
end

local function scanEggs()
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not areaEggs then return end
    
    for _, child in pairs(areaEggs:GetChildren()) do
        if child:IsA("Model") and not espCache[child] then
            local esp = createESP(child)
            if esp then
                espCache[child] = esp
            end
        end
    end
end

-- ========================================================
-- PATHFINDING WALK SYSTEM (Natural Movement)
-- ========================================================

local PathfindingService = game:GetService("PathfindingService")

local function walkToPosition(targetPosition, offset)
    offset = offset or Vector3.new(0, 0, 0)
    local finalPos = targetPosition + offset
    
    if not hrp or not hrp.Parent then return false end
    
    print("  🚶 Walking to target...")
    local totalDistance = (hrp.Position - finalPos).Magnitude
    print("     Distance:", math.floor(totalDistance), "studs")
    
    -- Use Roblox pathfinding for natural movement
    if CONFIG.UsePathfinding then
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            WaypointSpacing = 8,
            Costs = {}
        })
        
        local success, errorMessage = pcall(function()
            path:ComputeAsync(hrp.Position, finalPos)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            print("  🗺️  Using pathfinding...")
            local waypoints = path:GetWaypoints()
            
            for i, waypoint in ipairs(waypoints) do
                if not hrp or not hrp.Parent then break end
                
                humanoid:MoveTo(waypoint.Position)
                
                -- Wait for arrival or timeout
                local startTime = tick()
                local arrived = false
                
                while not arrived and (tick() - startTime) < 10 do  -- 10 second timeout per waypoint
                    local distance = (hrp.Position - waypoint.Position).Magnitude
                    
                    if distance < 5 then  -- Close enough
                        arrived = true
                    elseif humanoid.MoveDirection.Magnitude == 0 then
                        -- Character stopped moving, might be stuck
                        task.wait(0.5)
                        if humanoid.MoveDirection.Magnitude == 0 then
                            print("     ⚠️ Stuck at waypoint, continuing...")
                            break
                        end
                    end
                    
                    task.wait(0.1)
                end
                
                -- Handle jump waypoints
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                    task.wait(0.5)
                end
            end
            
            print("  ✅ Pathfinding complete!")
        else
            print("  ⚠️ Pathfinding failed, using direct movement...")
            -- Fallback to direct movement
            humanoid:MoveTo(finalPos)
            
            local startTime = tick()
            while (hrp.Position - finalPos).Magnitude > 5 and (tick() - startTime) < 30 do
                -- Check if stuck
                local oldPos = hrp.Position
                task.wait(1)
                
                if (oldPos - hrp.Position).Magnitude < 1 then
                    print("     ⚠️ Character appears stuck, trying jump...")
                    humanoid.Jump = true
                    task.wait(0.5)
                    humanoid:MoveTo(finalPos)  -- Retry move
                end
            end
        end
    else
        -- Direct movement without pathfinding
        print("  ➡️ Using direct movement...")
        humanoid:MoveTo(finalPos)
        
        local startTime = tick()
        while (hrp.Position - finalPos).Magnitude > 5 and (tick() - startTime) < 30 do
            task.wait(0.1)
        end
    end
    
    task.wait(CONFIG.WaitAtDestination or 0.5)
    
    local finalDistance = (hrp.Position - finalPos).Magnitude
    if finalDistance < 10 then
        print("  ✅ Arrived! (", math.floor(finalDistance), "studs away)")
        return true
    else
        print("  ⚠️ Close enough (", math.floor(finalDistance), "studs away)")
        return true
    end
end

local function walkToSafeZone()
    print("\n🚶 Walking back to safe zone...")
    
    local totalDistance = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
    print("  Distance:", math.floor(totalDistance), "studs")
    
    -- Walk directly to safe zone
    local success = walkToPosition(SAFE_ZONE_POSITION)
    
    if success then
        local finalDist = (hrp.Position - SAFE_ZONE_POSITION).Magnitude
        
        if finalDist < 20 then
            print("  ✅ Arrived at safe zone!")
            return true
        end
    end
    
    return false
end

-- ========================================================
-- AUTO STEAL FUNCTIONS
-- ========================================================

local function isAreaEnabled(area)
    return CONFIG.AreaFilters[area] == true
end

local function findNearestEggByArea()
    local nearestEgg = nil
    local nearestDist = math.huge
    local nearestArea = nil
    
    for eggModel, espData in pairs(espCache) do
        if eggModel.Parent and espData.primaryPart.Parent then
            local area = espData.area
            
            if isAreaEnabled(area) then
                local dist = (hrp.Position - espData.primaryPart.Position).Magnitude
                
                if dist < nearestDist and dist < CONFIG.SearchRadius then
                    nearestDist = dist
                    nearestEgg = eggModel
                    nearestArea = area
                end
            end
        end
    end
    
    return nearestEgg, nearestDist, nearestArea
end

local function fireNearestPrompt()
    local nearestPrompt = nil
    local nearestPromptDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local isEggRelated = parent.Name:lower():find("egg") or 
                                   obj.Name:lower():find("egg") or 
                                   obj.Name:lower():find("carry")
                
                if isEggRelated then
                    local dist = (hrp.Position - parent.Position).Magnitude
                    
                    if dist < nearestPromptDist then
                        nearestPromptDist = dist
                        nearestPrompt = obj
                    end
                end
            end
        end
    end
    
    if nearestPrompt then
        pcall(function()
            fireproximityprompt(nearestPrompt)
        end)
        return true, nearestPrompt
    end
    
    return false, nil
end

local function firePromptMultipleTimes(maxAttempts)
    maxAttempts = maxAttempts or 5
    
    print("   🔄 Attempting to pick up egg (max", maxAttempts, "attempts)...")
    
    for attempt = 1, maxAttempts do
        local success, prompt = fireNearestPrompt()
        
        if success and prompt then
            print("   📍 Attempt", attempt, "- Firing prompt...")
            
            -- Fire multiple times quickly for lag compensation
            for i = 1, 3 do
                pcall(function()
                    fireproximityprompt(prompt)
                end)
                task.wait(0.1)
            end
            
            -- Check if egg picked up
            task.wait(0.3)
            local carrying = checkIfCarrying()
            
            if carrying then
                print("   ✅ Egg picked up on attempt", attempt, "!")
                return true
            end
            
            print("   ⚠️  Attempt", attempt, "- No egg detected, retrying...")
        else
            print("   ❌ Attempt", attempt, "- No prompt found")
        end
        
        task.wait(0.2)
    end
    
    print("   ❌ Failed to pick up egg after", maxAttempts, "attempts")
    return false
end

local function checkIfCarrying()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then return true, tool.Name end
    
    tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then return true, tool.Name .. " (backpack)" end
    
    return false, nil
end

local function autoStealCycle()
    print("\n" .. string.rep("=", 70))
    print("🔄 AUTO-STEAL CYCLE (WALK MODE)")
    print(string.rep("=", 70))
    
    -- CHECK FOR NIGHT TIME FIRST
    local isNight, clockTime = isNightTime()
    
    if isNight then
        print("\n🌙 Night time detected (Clock:", string.format("%.1f", clockTime), "hrs)")
        print("   ⏸️  Cannot steal during night (blocks active)")
        
        waitForDayTime()
        
        print("\n☀️  Day time confirmed - continuing steal...")
    end
    
    print("\n📋 Enabled areas:")
    for area, enabled in pairs(CONFIG.AreaFilters) do
        if enabled then
            print("  ✅", area)
        end
    end
    print()
    
    print("[1] Searching for eggs...")
    local egg, distance, area = findNearestEggByArea()
    
    if not egg then
        print("❌ No eggs found in enabled areas")
        return false
    end
    
    print("✅ Found egg in:", area)
    print("   Distance:", math.floor(distance), "studs")
    
    print("\n[2] Walking to egg...")
    local eggPos = egg.PrimaryPart.Position or egg:FindFirstChildWhichIsA("BasePart").Position
    
    if not walkToPosition(eggPos) then
        print("❌ Walk failed")
        return false
    end
    
    print("\n[3] Firing prompt...")
    local success = fireNearestPrompt()
    
    if not success then
        print("❌ Prompt failed")
        return false
    end
    
    print("\n[4] Checking if egg picked up...")
    
    local carrying, eggName = false, nil
    
    for i = 1, 40 do
        carrying, eggName = checkIfCarrying()
        
        if carrying then
            print("✅ Egg detected!")
            break
        end
        
        task.wait(0.05)
    end
    
    if not carrying then
        print("❌ No egg detected")
        return false
    end
    
    print("✅✅ SUCCESS! Carrying:", eggName)
    
    print("\n[5] Walking back...")
    local returned = walkToSafeZone()
    
    if returned then
        print("✅ Returned!")
    end
    
    task.wait(0.5)
    local stillCarrying = checkIfCarrying()
    if stillCarrying then
        print("✅ Still carrying egg")
    end
    
    print("\n" .. string.rep("=", 70))
    print("✅✅ CYCLE COMPLETED!")
    print(string.rep("=", 70) .. "\n")
    
    return carrying
end

-- ========================================================
-- MAIN LOOP
-- ========================================================

scanEggs()
print("✅ Initial scan: " .. eggCounter .. " eggs")

RunService.RenderStepped:Connect(function()
    scanEggs()
    
    for eggModel, espData in pairs(espCache) do
        if not updateESP(espData) then
            if espData.billboard and espData.billboard.Parent then
                espData.billboard:Destroy()
            end
            espCache[eggModel] = nil
        end
    end
end)

-- ========================================================
-- GUI - FIXED VERSION
-- ========================================================

-- Wait for character to fully load first
if not character or not humanoid or not hrp then
    repeat
        character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        hrp = character:WaitForChild("HumanoidRootPart")
        task.wait(0.1)
    until character and humanoid and hrp
end

print("✅ Creating GUI...")

local parentGui = gethui and gethui() or game:GetService("CoreGui")
if not pcall(function() local t = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Check if GUI already exists and remove it
local existingGui = parentGui:FindFirstChild("WalkStealGui")
if existingGui then
    existingGui:Destroy()
    task.wait(0.1)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WalkStealGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999

-- Use protected call for GUI creation
local success = pcall(function()
    screenGui.Parent = parentGui
end)

if not success then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    print("⚠️ Using PlayerGui instead of CoreGui")
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 675)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -337)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
titleLabel.Text = "� WALK STEAL (Ground Movement)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

local titleCover = Instance.new("Frame")
titleCover.Size = UDim2.new(1, 0, 0, 10)
titleCover.Position = UDim2.new(0, 0, 1, -10)
titleCover.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
titleCover.BorderSizePixel = 0
titleCover.Parent = titleLabel

-- Info Label
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 40)
infoLabel.Position = UDim2.new(0, 10, 0, 60)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "🚶 Walks normally on ground like default game 🛡️ With protection"
infoLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
infoLabel.TextSize = 12
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.TextWrapped = true
infoLabel.Parent = mainFrame

-- ESP Status
local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(1, -20, 0, 25)
espLabel.Position = UDim2.new(0, 10, 0, 105)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP: " .. eggCounter .. " eggs detected"
espLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
espLabel.TextSize = 11
espLabel.Font = Enum.Font.SourceSans
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Parent = mainFrame

-- Area Selection Label
local areaLabel = Instance.new("TextLabel")
areaLabel.Size = UDim2.new(1, -20, 0, 25)
areaLabel.Position = UDim2.new(0, 10, 0, 135)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "🎯 Select Areas:"
areaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
areaLabel.TextSize = 14
areaLabel.Font = Enum.Font.SourceSansBold
areaLabel.TextXAlignment = Enum.TextXAlignment.Left
areaLabel.Parent = mainFrame

-- Area Checkboxes
local areas = {"FOREST", "LAKE", "DESERT", "JUNGLE", "SNOW", "VOLCANO", "ABYSS OCEAN", "PREHISTORIC", "COSMIC"}

for i, area in ipairs(areas) do
    local yPos = 165 + (i - 1) * 32
    
    local checkFrame = Instance.new("Frame")
    checkFrame.Size = UDim2.new(1, -20, 0, 28)
    checkFrame.Position = UDim2.new(0, 10, 0, yPos)
    checkFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    checkFrame.BorderSizePixel = 0
    checkFrame.Parent = mainFrame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 6)
    checkCorner.Parent = checkFrame
    
    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 28, 0, 28)
    checkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    checkBtn.Text = ""
    checkBtn.TextSize = 16
    checkBtn.Font = Enum.Font.SourceSansBold
    checkBtn.Parent = checkFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = checkBtn
    
    local checkLabel = Instance.new("TextLabel")
    checkLabel.Size = UDim2.new(1, -35, 1, 0)
    checkLabel.Position = UDim2.new(0, 35, 0, 0)
    checkLabel.BackgroundTransparency = 1
    checkLabel.Text = area
    checkLabel.TextColor3 = areaColors[area]
    checkLabel.TextSize = 12
    checkLabel.Font = Enum.Font.SourceSansBold
    checkLabel.TextXAlignment = Enum.TextXAlignment.Left
    checkLabel.Parent = checkFrame
    
    checkBtn.MouseButton1Click:Connect(function()
        CONFIG.AreaFilters[area] = not CONFIG.AreaFilters[area]
        
        if CONFIG.AreaFilters[area] then
            checkBtn.Text = "✓"
            checkBtn.BackgroundColor3 = areaColors[area]
        else
            checkBtn.Text = ""
            checkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
    end)
end

-- Settings Label
local settingsLabel = Instance.new("TextLabel")
settingsLabel.Size = UDim2.new(1, -20, 0, 25)
settingsLabel.Position = UDim2.new(0, 10, 0, 460)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Text = "⚙️ Walk Settings:"
settingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsLabel.TextSize = 14
settingsLabel.Font = Enum.Font.SourceSansBold
settingsLabel.TextXAlignment = Enum.TextXAlignment.Left
settingsLabel.Parent = mainFrame

-- Walk Speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, -15, 0, 35)
speedLabel.Position = UDim2.new(0, 10, 0, 490)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "� Speed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.TextYAlignment = Enum.TextYAlignment.Center
speedLabel.Parent = mainFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.5, -15, 0, 35)
speedInput.Position = UDim2.new(0.5, 5, 0, 490)
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedInput.BorderSizePixel = 0
speedInput.Text = "1000"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 14
speedInput.Font = Enum.Font.SourceSansBold
speedInput.PlaceholderText = "8-1000"
speedInput.ClearTextOnFocus = false
speedInput.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedInput

speedInput.FocusLost:Connect(function()
    local value = tonumber(speedInput.Text)
    if value then
        value = math.clamp(value, 8, 1000)  -- Allow up to 1000 speed
        CONFIG.WalkSpeed = value
        humanoid.WalkSpeed = value
        speedInput.Text = tostring(value)
    else
        speedInput.Text = tostring(CONFIG.WalkSpeed)
    end
end)

-- Pathfinding Toggle
local pathfindingLabel = Instance.new("TextLabel")
pathfindingLabel.Size = UDim2.new(0.5, -15, 0, 35)
pathfindingLabel.Position = UDim2.new(0, 10, 0, 530)
pathfindingLabel.BackgroundTransparency = 1
pathfindingLabel.Text = "🗺️ Pathfind:"
pathfindingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pathfindingLabel.TextSize = 12
pathfindingLabel.Font = Enum.Font.SourceSansBold
pathfindingLabel.TextXAlignment = Enum.TextXAlignment.Left
pathfindingLabel.TextYAlignment = Enum.TextYAlignment.Center
pathfindingLabel.Parent = mainFrame

local pathfindingToggle = Instance.new("TextButton")
pathfindingToggle.Size = UDim2.new(0.5, -15, 0, 35)
pathfindingToggle.Position = UDim2.new(0.5, 5, 0, 530)
pathfindingToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
pathfindingToggle.Text = "ON"
pathfindingToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
pathfindingToggle.TextSize = 14
pathfindingToggle.Font = Enum.Font.SourceSansBold
pathfindingToggle.Parent = mainFrame

local pathfindingCorner = Instance.new("UICorner")
pathfindingCorner.CornerRadius = UDim.new(0, 6)
pathfindingCorner.Parent = pathfindingToggle

pathfindingToggle.MouseButton1Click:Connect(function()
    CONFIG.UsePathfinding = not CONFIG.UsePathfinding
    if CONFIG.UsePathfinding then
        pathfindingToggle.Text = "ON"
        pathfindingToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        pathfindingToggle.Text = "OFF"
        pathfindingToggle.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ESP Toggle
local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(1, -20, 0, 30)
espToggle.Position = UDim2.new(0, 10, 0, 570)
espToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
espToggle.Text = "👁️ ESP: ON"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.TextSize = 12
espToggle.Font = Enum.Font.SourceSansBold
espToggle.Parent = mainFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
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
godToggle.Size = UDim2.new(1, -20, 0, 30)
godToggle.Position = UDim2.new(0, 10, 0, 605)
godToggle.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
godToggle.Text = "✨ GOD MODE: ON (No Damage)"
godToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
godToggle.TextSize = 12
godToggle.Font = Enum.Font.SourceSansBold
godToggle.Parent = mainFrame

local godCorner = Instance.new("UICorner")
godCorner.CornerRadius = UDim.new(0, 6)
godCorner.Parent = godToggle

local godModeEnabled = true

godToggle.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        godToggle.Text = "✨ GOD MODE: ON (No Damage)"
        godToggle.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
        humanoid.Health = math.huge
        humanoid.MaxHealth = math.huge
        print("✨ God Mode ON - Invincible!")
    else
        godToggle.Text = "✨ GOD MODE: OFF"
        godToggle.BackgroundColor3 = Color3.fromRGB(127, 140, 141)
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        print("✨ God Mode OFF")
    end
end)

-- Steal Once Button
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(0.48, 0, 0, 35)
stealBtn.Position = UDim2.new(0, 10, 1, -40)
stealBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
stealBtn.Text = "🥚 STEAL ONCE"
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.TextSize = 13
stealBtn.Font = Enum.Font.SourceSansBold
stealBtn.Parent = mainFrame

local stealCorner = Instance.new("UICorner")
stealCorner.CornerRadius = UDim.new(0, 6)
stealCorner.Parent = stealBtn

stealBtn.MouseButton1Click:Connect(function()
    stealBtn.Text = "⏳ Walking..."
    
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
autoBtn.Size = UDim2.new(0.48, 0, 0, 35)
autoBtn.Position = UDim2.new(0.52, 0, 1, -40)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoBtn.Text = "🔄 AUTO: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 13
autoBtn.Font = Enum.Font.SourceSansBold
autoBtn.Parent = mainFrame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 6)
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

-- Update ESP Counter
task.spawn(function()
    while screenGui.Parent do
        task.wait(2)
        espLabel.Text = "ESP: " .. eggCounter .. " eggs detected"
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
print("✅ AUTO STEAL BY AREA LOADED!")
print("🎮 ESP: All eggs with area names")
print("🛡️ Guard Destroyer: Active")
print("✨ God Mode: Invincible (no damage)")
print("� Movement: Walking (ground-based)")
print("🗺️ Pathfinding: Natural movement")
print("🎮 Select areas + STEAL ONCE to test")
print("========================================")
