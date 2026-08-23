-- ========================================================
-- STABLE GUARD FIX - CRASH-FREE VERSION
-- Fixed version yang tidak crash saat steal
-- ========================================================

print("🛡️ LOADING STABLE GUARD FIX...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- STABLE GUARD FIX SETTINGS
-- ========================================================

local fixData = {
    guardsFixed = 0,
    activeProtection = false,
    lastCheck = 0,
    fixedObjects = {}
}

local fixSettings = {
    safeMode = true,           -- Safe mode untuk prevent crash
    quickMode = true,          -- Quick fix tanpa complex hooks
    preventCrash = true,       -- Extra crash prevention
    logFixes = false          -- Disable excessive logging
}

-- ========================================================
-- SAFE GUARD DETECTION & FIX
-- ========================================================

local function safeGuardFix()
    if fixSettings.logFixes then
        print("🔧 Starting safe guard fix...")
    end
    
    local fixed = 0
    local processed = 0
    
    -- Safe guard fixing with limits
    for _, obj in pairs(Workspace:GetDescendants()) do
        processed = processed + 1
        if processed > 1000 then break end -- Prevent excessive processing
        
        -- Skip if already fixed
        if fixData.fixedObjects[obj] then continue end
        
        pcall(function()
            local objName = obj.Name:lower()
            
            -- Simple guard detection
            if objName:find("guard") or objName:find("security") or objName:find("police") then
                
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    -- Safely disable scripts
                    obj.Disabled = true
                    -- Don't destroy immediately, just disable
                    fixed = fixed + 1
                    fixData.fixedObjects[obj] = true
                    
                elseif obj:IsA("BasePart") then
                    -- Safe part modification
                    obj.CanCollide = false
                    obj.Transparency = 0.9 -- Not fully transparent to avoid conflicts
                    
                    -- Safe position change (not too far to prevent network issues)
                    local currentPos = obj.Position
                    obj.Position = Vector3.new(currentPos.X, currentPos.Y - 50, currentPos.Z)
                    
                    fixed = fixed + 1
                    fixData.fixedObjects[obj] = true
                    
                elseif obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                    -- Safe humanoid handling
                    local humanoid = obj:FindFirstChildOfClass("Humanoid")
                    local rootPart = obj:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and rootPart then
                        -- Disable movement instead of killing
                        humanoid.WalkSpeed = 0
                        humanoid.JumpPower = 0
                        humanoid.PlatformStand = true
                        
                        -- Move underground safely
                        rootPart.Anchored = true
                        rootPart.Position = Vector3.new(rootPart.Position.X, rootPart.Position.Y - 30, rootPart.Position.Z)
                        
                        fixed = fixed + 1
                        fixData.fixedObjects[obj] = true
                    end
                end
            end
        end)
        
        -- Yield every 50 objects to prevent freezing
        if processed % 50 == 0 then
            task.wait()
        end
    end
    
    fixData.guardsFixed = fixData.guardsFixed + fixed
    
    if fixSettings.logFixes and fixed > 0 then
        print("✅ Safe fix complete! Objects fixed: " .. fixed)
    end
    
    return fixed
end

-- ========================================================
-- SIMPLE ANTI-DETECTION (CRASH-SAFE)
-- ========================================================

local function simpleByppass()
    if fixSettings.logFixes then
        print("🛡️ Applying simple bypass...")
    end
    
    -- Method 1: Character protection without complex hooks
    if LocalPlayer.Character then
        local character = LocalPlayer.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid and not fixData.activeProtection then
            fixData.activeProtection = true
            
            -- Simple health protection (safer approach)
            task.spawn(function()
                while LocalPlayer.Character == character and humanoid.Parent do
                    task.wait(0.5) -- Longer wait to prevent issues
                    
                    pcall(function()
                        if humanoid.Health < humanoid.MaxHealth * 0.8 then
                            -- Only heal if significantly damaged
                            humanoid.Health = humanoid.MaxHealth
                        end
                    end)
                end
                fixData.activeProtection = false
            end)
        end
    end
    
    -- Method 2: Simple collision bypass
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            
            -- Create simple bypass part (safer than metamethod hooks)
            if not rootPart:FindFirstChild("GuardBypass") then
                local bypass = Instance.new("BoolValue")
                bypass.Name = "GuardBypass"
                bypass.Value = true
                bypass.Parent = rootPart
            end
        end
    end)
end

-- ========================================================
-- LIGHTWEIGHT CONTINUOUS FIX
-- ========================================================

local function startLightweightProtection()
    if fixSettings.logFixes then
        print("🔄 Starting lightweight protection...")
    end
    
    -- Very light protection with long intervals
    task.spawn(function()
        while fixSettings.safeMode do
            task.wait(10) -- Very long interval to prevent performance issues
            
            local currentTime = tick()
            if currentTime - fixData.lastCheck > 8 then -- Extra check to prevent spam
                fixData.lastCheck = currentTime
                
                -- Only fix new guards, don't re-process
                pcall(function()
                    local newGuards = 0
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if not fixData.fixedObjects[obj] then
                            local objName = obj.Name:lower()
                            if objName:find("guard") and obj:IsA("Model") then
                                pcall(function()
                                    if obj:FindFirstChild("HumanoidRootPart") then
                                        obj.HumanoidRootPart.Position = Vector3.new(obj.HumanoidRootPart.Position.X, obj.HumanoidRootPart.Position.Y - 40, obj.HumanoidRootPart.Position.Z)
                                        fixData.fixedObjects[obj] = true
                                        newGuards = newGuards + 1
                                    end
                                end)
                            end
                        end
                        
                        if newGuards > 5 then break end -- Limit per cycle
                    end
                end)
            end
        end
    end)
end
-- ========================================================
-- CRASH-SAFE MAIN EXECUTION
-- ========================================================

local function stableGuardFix()
    print("⚡ STARTING STABLE GUARD FIX")
    print("============================")
    
    local success = true
    local totalFixed = 0
    
    -- Step 1: Safe guard fixing with error handling
    pcall(function()
        totalFixed = safeGuardFix()
    end)
    
    -- Step 2: Simple bypass with safety checks
    pcall(function()
        simpleByppass()
    end)
    
    -- Step 3: Start lightweight protection
    pcall(function()
        startLightweightProtection()
    end)
    
    print("🎉 STABLE FIX COMPLETE!")
    print("💥 Guards processed: " .. totalFixed)
    print("🛡️ Simple bypass active")
    print("🔄 Lightweight protection enabled")
    print("✅ Crash-safe mode ON")
    print("============================")
    
    return totalFixed
end

-- ========================================================
-- EMERGENCY STOP FUNCTION
-- ========================================================

local function emergencyStop()
    print("🚨 EMERGENCY STOP ACTIVATED")
    fixSettings.safeMode = false
    fixData.activeProtection = false
    
    -- Clear any problematic connections
    for obj, _ in pairs(fixData.fixedObjects) do
        pcall(function()
            if obj and obj.Parent then
                -- Reset to safe state
                if obj:IsA("BasePart") then
                    obj.CanCollide = true
                    obj.Transparency = 0
                end
            end
        end)
    end
    
    print("✅ Emergency stop complete!")
end

-- ========================================================
-- SIMPLE CRASH-SAFE GUI
-- ========================================================

local function createStableGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "StableGuardFix"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 120)
    frame.Position = UDim2.new(0, 20, 0, 250)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
    title.Text = "🛡️ STABLE GUARD FIX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Fix button
    local fixButton = Instance.new("TextButton")
    fixButton.Size = UDim2.new(1, -10, 0, 35)
    fixButton.Position = UDim2.new(0, 5, 0, 35)
    fixButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
    fixButton.Text = "🔧 START FIX"
    fixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fixButton.TextSize = 12
    fixButton.Font = Enum.Font.SourceSansBold
    fixButton.BorderSizePixel = 0
    fixButton.Parent = frame
    
    local fixCorner = Instance.new("UICorner")
    fixCorner.CornerRadius = UDim.new(0, 6)
    fixCorner.Parent = fixButton
    
    -- Emergency stop button
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(1, -10, 0, 30)
    stopButton.Position = UDim2.new(0, 5, 0, 80)
    stopButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    stopButton.Text = "🚨 EMERGENCY STOP"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextSize = 11
    stopButton.Font = Enum.Font.SourceSansBold
    stopButton.BorderSizePixel = 0
    stopButton.Parent = frame
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopButton
    
    -- Button events
    fixButton.MouseButton1Click:Connect(function()
        fixButton.Text = "⏳ FIXING..."
        fixButton.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
        
        task.spawn(function()
            local fixed = stableGuardFix()
            task.wait(1)
            
            fixButton.Text = "✅ FIXED (" .. fixed .. ")"
            fixButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
            
            task.wait(3)
            fixButton.Text = "🔧 START FIX"
            fixButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
        end)
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        emergencyStop()
        stopButton.Text = "✅ STOPPED"
        stopButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        task.wait(2)
        stopButton.Text = "🚨 EMERGENCY STOP"
        stopButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    end)
    
    return gui
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Stable Guard Fix Loading...")
print("==============================")
print("💡 Crash-safe features:")
print("   ✅ Safe guard detection")
print("   ✅ No aggressive hooks")
print("   ✅ Error handling")
print("   ✅ Performance limits")
print("   ✅ Emergency stop")
print("==============================")

-- Create GUI for manual control
local gui = createStableGUI()

-- Optional auto-fix (comment out if you want manual only)
print("🔄 Auto-fix will start in 3 seconds...")
print("⚠️ Use EMERGENCY STOP if any issues!")

task.wait(3)

-- Safe auto-execution
task.spawn(function()
    pcall(function()
        stableGuardFix()
    end)
end)

print("✅ STABLE GUARD FIX READY!")
print("🎮 Use GUI for manual control")
print("🚨 Emergency stop available if needed")

-- Export safe functions
getgenv().stableGuardFix = stableGuardFix
getgenv().emergencyStopGuards = emergencyStop

-- Cleanup on character reset
if LocalPlayer.CharacterAdded then
    LocalPlayer.CharacterAdded:Connect(function()
        fixData.activeProtection = false
        task.wait(2) -- Wait for character to load
        pcall(function()
            stableGuardFix()
        end)
    end)
end