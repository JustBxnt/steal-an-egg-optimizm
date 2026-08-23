-- ========================================================
-- INSTANT GUARD FREEZE - QUICK & EFFECTIVE
-- Versi instant untuk membekukan guard dengan cepat
-- ========================================================

print("⚡ LOADING INSTANT GUARD FREEZE...")

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- ========================================================
-- INSTANT FREEZE FUNCTIONS
-- ========================================================

local function instantFreezeAll()
    print("🧊 STARTING INSTANT GUARD FREEZE...")
    
    local frozenCount = 0
    local totalScanned = 0
    
    -- Scan and freeze in one pass for maximum speed
    for _, obj in pairs(Workspace:GetDescendants()) do
        totalScanned = totalScanned + 1
        
        pcall(function()
            local objName = obj.Name:lower()
            local isGuard = false
            
            -- Quick guard detection
            if objName:find("guard") or objName:find("security") or objName:find("police") or 
               objName:find("npc") or objName:find("officer") or objName:find("bot") then
                isGuard = true
            end
            
            -- Check if it's a Model with Humanoid (likely NPC)
            if not isGuard and obj:IsA("Model") then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                
                if humanoid and rootPart then
                    -- Check if it's not a player
                    local isPlayer = false
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player.Character == obj then
                            isPlayer = true
                            break
                        end
                    end
                    
                    -- If not a player and has typical NPC characteristics
                    if not isPlayer and rootPart.Size.Y > 3 and rootPart.Size.Y < 8 then
                        isGuard = true
                    end
                end
            end
            
            -- Freeze the guard if detected
            if isGuard and obj:IsA("Model") then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                
                if humanoid and rootPart then
                    -- INSTANT FREEZE METHODS
                    
                    -- Method 1: Stop movement completely
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                    humanoid.PlatformStand = true
                    
                    -- Method 2: Anchor all parts
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Anchored = true
                            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                    
                    -- Method 3: Disable scripts
                    for _, script in pairs(obj:GetDescendants()) do
                        if script:IsA("Script") or script:IsA("LocalScript") then
                            script.Disabled = true
                        end
                    end
                    
                    -- Method 4: Create position lock
                    local bodyPosition = Instance.new("BodyPosition")
                    bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyPosition.Position = rootPart.Position
                    bodyPosition.D = 10000
                    bodyPosition.P = 10000
                    bodyPosition.Parent = rootPart
                    
                    frozenCount = frozenCount + 1
                    print("🧊 Frozen: " .. obj.Name)
                end
            end
        end)
    end
    
    print("✅ INSTANT FREEZE COMPLETE!")
    print("============================")
    print("📊 Objects scanned: " .. totalScanned)
    print("🧊 Guards frozen: " .. frozenCount)
    print("============================")
    
    if frozenCount > 0 then
        print("🎉 All guards are now completely frozen!")
    else
        print("⚠️ No guards found to freeze")
    end
    
    return frozenCount
end

-- ========================================================
-- CONTINUOUS FREEZE MAINTENANCE
-- ========================================================

local function startContinuousFreeze()
    print("🔄 Starting continuous freeze maintenance...")
    
    RunService.Heartbeat:Connect(function()
        -- Maintain freeze on all NPCs every frame
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Model") then
                    local humanoid = obj:FindFirstChildOfClass("Humanoid")
                    local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                    
                    if humanoid and rootPart then
                        local objName = obj.Name:lower()
                        
                        -- Quick guard check
                        if objName:find("guard") or objName:find("security") or objName:find("npc") or objName:find("bot") then
                            -- Maintain freeze
                            if humanoid.WalkSpeed ~= 0 then
                                humanoid.WalkSpeed = 0
                            end
                            
                            if humanoid.JumpPower ~= 0 then
                                humanoid.JumpPower = 0
                            end
                            
                            if not humanoid.PlatformStand then
                                humanoid.PlatformStand = true
                            end
                            
                            -- Keep parts anchored
                            if not rootPart.Anchored then
                                rootPart.Anchored = true
                            end
                            
                            -- Stop any movement
                            if rootPart.AssemblyLinearVelocity.Magnitude > 0.1 then
                                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- ========================================================
-- SIMPLE CONTROL BUTTON
-- ========================================================

local function createSimpleControl()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "InstantGuardFreeze"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0, 20, 0, 200)
    button.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    button.Text = "🧊 INSTANT FREEZE GUARDS"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.BorderSizePixel = 0
    button.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ FREEZING..."
        button.BackgroundColor3 = Color3.fromRGB(150, 100, 150)
        
        task.wait(0.1)
        local frozenCount = instantFreezeAll()
        
        button.Text = "✅ FROZEN: " .. frozenCount
        button.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        
        task.wait(2)
        button.Text = "🧊 INSTANT FREEZE GUARDS"
        button.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    end)
    
    return gui
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Starting Instant Guard Freeze...")

-- Create control button
local controlGUI = createSimpleControl()

-- Auto-freeze on startup
print("🔄 Auto-executing instant freeze in 2 seconds...")
task.wait(2)
local initialFrozen = instantFreezeAll()

-- Start continuous maintenance
startContinuousFreeze()

print("✅ INSTANT GUARD FREEZE READY!")
print("==============================")
print("🧊 Guards frozen on startup: " .. initialFrozen)
print("🔄 Continuous freeze maintenance active")
print("🎮 Click button to re-freeze if needed")
print("==============================")
print("💡 Methods used:")
print("   • WalkSpeed = 0")
print("   • JumpPower = 0") 
print("   • PlatformStand = true")
print("   • All parts anchored")
print("   • Scripts disabled")
print("   • BodyPosition locks")
print("   • Velocity forced to 0")
print("==============================")
print("🎯 Guards are now statue-frozen!")

-- Export functions
getgenv().instantFreezeAllGuards = instantFreezeAll