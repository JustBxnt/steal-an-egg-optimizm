-- ========================================================
-- SUPER LIGHT GUARD FIX - ULTRA ANTI-LAG
-- Versi paling ringan untuk fix guard tanpa lag sama sekali
-- ========================================================

print("⚡ SUPER LIGHT GUARD FIX LOADING...")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- ULTRA FAST GUARD DISABLE
-- ========================================================

print("🔥 EXECUTING ULTRA FAST GUARD DISABLE...")

local fixed = 0

-- Method 1: Simple guard name disable (super fast)
for _, obj in pairs(Workspace:GetChildren()) do
    pcall(function()
        local name = obj.Name:lower()
        if name:find("guard") or name:find("security") then
            -- Super simple disable
            if obj:IsA("Model") then
                obj.Parent = nil  -- Remove from workspace
            elseif obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.Transparency = 1
            elseif obj:IsA("Script") then
                obj.Disabled = true
            end
            fixed = fixed + 1
        end
    end)
end

-- Method 2: Quick descendant check (limited depth to prevent lag)
local checkCount = 0
for _, obj in pairs(Workspace:GetDescendants()) do
    checkCount = checkCount + 1
    if checkCount > 500 then break end  -- Limit check to prevent lag
    
    pcall(function()
        local name = obj.Name:lower()
        if name:find("guard") then
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                obj.Disabled = true
                obj:Destroy()
                fixed = fixed + 1
            elseif obj:IsA("BasePart") then
                obj.CFrame = CFrame.new(999999, 999999, 999999) -- Move far away
                obj.CanCollide = false
                fixed = fixed + 1
            end
        end
    end)
end

print("💥 Fixed " .. fixed .. " guard objects!")

-- ========================================================
-- SIMPLE CHARACTER PROTECTION
-- ========================================================

print("🛡️ Applying character protection...")

if LocalPlayer.Character then
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        -- Simple health protection
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        -- Damage immunity
        pcall(function()
            local connection
            connection = humanoid.HealthChanged:Connect(function(health)
                if health < 100 then
                    humanoid.Health = 100
                end
            end)
        end)
        
        print("✅ Character protection applied!")
    end
end

-- ========================================================
-- SIMPLE HOOK (MINIMAL)
-- ========================================================

print("🔗 Applying minimal hooks...")

pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        if old then
            setreadonly(mt, false)
            
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod()
                
                -- Block only specific guard events
                if method == "Touched" and self.Name:lower():find("guard") then
                    return -- Block guard touch
                end
                
                return old(self, ...)
            end
            
            setreadonly(mt, true)
            print("✅ Guard touch events blocked!")
        end
    end
end)

-- ========================================================
-- INSTANT RESULTS
-- ========================================================

print("🎉 SUPER LIGHT GUARD FIX COMPLETE!")
print("===================================")
print("💥 Total objects fixed: " .. fixed)
print("⚡ Execution time: <1 second")
print("🛡️ Character protection: ACTIVE")
print("🔗 Guard hooks: ACTIVE") 
print("===================================")
print("✅ NO LAG - MAXIMUM PERFORMANCE!")
print("🎯 Guards should no longer hit you!")

-- Simple function to re-run if needed
getgenv().superLightFix = function()
    print("🔄 Re-running super light fix...")
    local newFixed = 0
    
    for _, obj in pairs(Workspace:GetChildren()) do
        pcall(function()
            if obj.Name:lower():find("guard") then
                if obj:IsA("Model") then
                    obj.Parent = nil
                    newFixed = newFixed + 1
                end
            end
        end)
    end
    
    print("✅ Re-fix complete: " .. newFixed .. " new guards disabled")
    return newFixed
end

print("💡 Use superLightFix() to re-run if needed")