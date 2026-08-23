-- ========================================================
-- LIGHTWEIGHT GUARD FIX - ANTI LAG VERSION
-- Script ringan untuk fix masalah guard yang masih bisa hit
-- ========================================================

print("⚡ LOADING LIGHTWEIGHT GUARD FIX...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- SIMPLE & FAST GUARD FIX
-- ========================================================

local function quickGuardFix()
    print("🔧 Starting quick guard fix...")
    local fixed = 0
    
    -- Method 1: Disable all guard-related objects quickly
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("guard") or obj.Name:lower():find("security") then
                pcall(function()
                    if obj:IsA("Script") then
                        obj.Disabled = true
                        obj:Destroy()
                        fixed = fixed + 1
                    elseif obj:IsA("BasePart") then
                        obj.CanCollide = false
                        obj.Transparency = 1
                        obj.Anchored = true
                        -- Move guard far away instead of destroying
                        obj.CFrame = CFrame.new(999999, 999999, 999999)
                        fixed = fixed + 1
                    elseif obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                        -- Disable guard humanoid
                        local humanoid = obj:FindFirstChildOfClass("Humanoid")
                        humanoid.Health = 0
                        humanoid.MaxHealth = 0
                        humanoid.PlatformStand = true
                        -- Move model far away
                        if obj:FindFirstChild("HumanoidRootPart") then
                            obj.HumanoidRootPart.CFrame = CFrame.new(999999, 999999, 999999)
                        end
                        fixed = fixed + 1
                    end
                end)
            end
        end
    end)
    
    print("✅ Quick fix complete! Objects fixed: " .. fixed)
    return fixed
end

-- ========================================================
-- ANTI-DETECTION BYPASS (LIGHTWEIGHT)
-- ========================================================

local function antiDetectionBypass()
    print("🛡️ Applying anti-detection bypass...")
    
    -- Method 1: Hook touch/collision events
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Block guard detection methods
            if method == "Touched" or method == "Hit" then
                if self.Name:lower():find("guard") or self.Name:lower():find("security") then
                    return -- Block the touch event
                end
            elseif method == "GetTouchingParts" then
                local result = old(self, ...)
                -- Filter out guard parts from touching parts
                local filtered = {}
                for _, part in pairs(result) do
                    if not (part.Name:lower():find("guard") or part.Name:lower():find("security")) then
                        table.insert(filtered, part)
                    end
                end
                return filtered
            elseif method == "Raycast" then
                -- Modify raycast to ignore guards
                if args[2] and args[2].FilterDescendantsInstances then
                    -- Add guard objects to filter list
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name:lower():find("guard") then
                            table.insert(args[2].FilterDescendantsInstances, obj)
                        end
                    end
                end
            end
            
            return old(self, ...)
        end
        
        setreadonly(mt, true)
        print("✅ Anti-detection hooks applied!")
    end)
    
    -- Method 2: Simple character protection
    if LocalPlayer.Character then
        pcall(function()
            local character = LocalPlayer.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if humanoid then
                -- Make character immune to guard damage
                local oldHealthChanged
                oldHealthChanged = humanoid.HealthChanged:Connect(function(health)
                    if health < humanoid.MaxHealth then
                        -- Restore health if damaged by guards
                        task.wait(0.1)
                        humanoid.Health = humanoid.MaxHealth
                    end
                end)
            end
        end)
    end
end

-- ========================================================
-- CONTINUOUS PROTECTION (VERY LIGHT)
-- ========================================================

local function startLightProtection()
    print("🔄 Starting lightweight continuous protection...")
    
    -- Very light continuous check every 5 seconds
    task.spawn(function()
        while true do
            task.wait(5) -- Long interval to prevent lag
            
            pcall(function()
                -- Quick check for new guards and disable them
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name:lower():find("guard") then
                        pcall(function()
                            if obj:IsA("Model") then
                                -- Move away instead of complex operations
                                if obj:FindFirstChild("HumanoidRootPart") then
                                    obj.HumanoidRootPart.CFrame = CFrame.new(999999, 999999, 999999)
                                end
                            elseif obj:IsA("BasePart") then
                                obj.CanCollide = false
                                obj.Transparency = 1
                            end
                        end)
                    end
                end
            end)
        end
    end)
end

-- ========================================================
-- INSTANT FIX MODE (NO GUI)
-- ========================================================

local function instantFix()
    print("⚡ INSTANT GUARD FIX MODE")
    print("========================")
    
    -- Step 1: Quick guard neutralization
    local fixed1 = quickGuardFix()
    
    -- Step 2: Anti-detection bypass
    antiDetectionBypass()
    
    -- Step 3: Start light protection
    startLightProtection()
    
    print("🎉 INSTANT FIX COMPLETE!")
    print("💥 Guards fixed: " .. fixed1)
    print("🛡️ Anti-detection active")
    print("🔄 Continuous protection enabled")
    print("========================")
    
    return fixed1
end

-- ========================================================
-- SIMPLE GUI (OPTIONAL)
-- ========================================================

local function createSimpleGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "LightweightGuardFix"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0, 20, 0, 200)
    button.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    button.Text = "🔧 FIX GUARDS"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.SourceSansBold
    button.BorderSizePixel = 0
    button.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ FIXING..."
        button.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
        
        task.wait(0.1)
        local fixed = instantFix()
        
        button.Text = "✅ FIXED (" .. fixed .. ")"
        button.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        
        task.wait(2)
        button.Text = "🔧 FIX GUARDS"
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    end)
    
    return gui
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

print("🚀 Lightweight Guard Fix Ready!")
print("===============================")

-- Option 1: Instant fix (no GUI)
print("🔥 AUTO-EXECUTING IN 2 SECONDS...")
print("⚠️ Close script to cancel!")
task.wait(2)

-- Execute instant fix
local fixedCount = instantFix()

-- Option 2: Create simple GUI for manual control
-- local gui = createSimpleGUI()

print("✅ LIGHTWEIGHT GUARD FIX ACTIVE!")
print("================================")
print("💡 Features enabled:")
print("   🔧 Guard objects disabled")
print("   🛡️ Anti-detection bypass")
print("   🔄 Continuous protection")
print("   ⚡ Lag-free operation")
print("================================")
print("🎯 You should now be safe from guards!")

-- Export function for manual use
getgenv().quickGuardFix = quickGuardFix
getgenv().instantGuardFix = instantFix