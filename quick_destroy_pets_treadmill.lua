-- ========================================================
-- QUICK DESTROY PETAREA & TREADMILL - INSTANT VERSION
-- Versi instant tanpa GUI untuk destroy cepat
-- ========================================================

print("⚡ QUICK DESTROYER LOADING...")

local Workspace = game:GetService("Workspace")

-- ========================================================
-- INSTANT DESTROY FUNCTIONS
-- ========================================================

local function quickDestroy()
    print("💥 STARTING INSTANT DESTRUCTION...")
    
    local petAreasDestroyed = 0
    local treadmillsDestroyed = 0
    local totalDestroyed = 0
    
    -- Scan and destroy in one pass for maximum speed
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            local shouldDestroy = false
            local objType = ""
            
            -- Check for PetArea patterns
            if objName:find("petarea") or objName:find("pet_area") or objName:find("pet area") then
                shouldDestroy = true
                objType = "PetArea"
                petAreasDestroyed = petAreasDestroyed + 1
                
            -- Check for Treadmill patterns
            elseif objName:find("treadmill") or objName:find("tread_mill") or 
                   objName:find("treadmillrender") or objName:find("treadmill_render") then
                shouldDestroy = true
                objType = "Treadmill"
                treadmillsDestroyed = treadmillsDestroyed + 1
            end
            
            -- Destroy if matched
            if shouldDestroy and obj.Parent then
                print("🔥 Destroying " .. objType .. ": " .. obj.Name)
                obj:Destroy()
                totalDestroyed = totalDestroyed + 1
            end
        end)
    end
    
    -- Results
    print("✅ INSTANT DESTRUCTION COMPLETE!")
    print("====================================")
    print("🐾 PetAreas destroyed: " .. petAreasDestroyed)
    print("🏃 Treadmills destroyed: " .. treadmillsDestroyed)
    print("💥 Total destroyed: " .. totalDestroyed)
    print("====================================")
    
    if totalDestroyed > 0 then
        print("🚀 Performance should be significantly improved!")
    else
        print("⚠️ No PetArea or Treadmill objects found")
    end
    
    return totalDestroyed
end

-- ========================================================
-- SPECIFIC DESTROY FUNCTIONS
-- ========================================================

local function destroyOnlyPetAreas()
    print("🐾 DESTROYING ONLY PETAREAS...")
    local destroyed = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            
            if (objName:find("petarea") or objName:find("pet_area") or objName:find("pet area")) and obj.Parent then
                print("🔥 Destroying PetArea: " .. obj.Name)
                obj:Destroy()
                destroyed = destroyed + 1
            end
        end)
    end
    
    print("✅ PetAreas destroyed: " .. destroyed)
    return destroyed
end

local function destroyOnlyTreadmills()
    print("🏃 DESTROYING ONLY TREADMILLS...")
    local destroyed = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            
            if (objName:find("treadmill") or objName:find("tread_mill") or 
                objName:find("treadmillrender") or objName:find("treadmill_render")) and obj.Parent then
                print("🔥 Destroying Treadmill: " .. obj.Name)
                obj:Destroy()
                destroyed = destroyed + 1
            end
        end)
    end
    
    print("✅ Treadmills destroyed: " .. destroyed)
    return destroyed
end

-- ========================================================
-- SCAN ONLY FUNCTION
-- ========================================================

local function scanOnly()
    print("🔍 SCANNING FOR TARGETS...")
    
    local petAreas = 0
    local treadmills = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            
            if objName:find("petarea") or objName:find("pet_area") or objName:find("pet area") then
                petAreas = petAreas + 1
                print("🎯 Found PetArea: " .. obj.Name)
                
            elseif objName:find("treadmill") or objName:find("tread_mill") or 
                   objName:find("treadmillrender") or objName:find("treadmill_render") then
                treadmills = treadmills + 1
                print("🎯 Found Treadmill: " .. obj.Name)
            end
        end)
    end
    
    print("📊 SCAN RESULTS:")
    print("   🐾 PetAreas: " .. petAreas)
    print("   🏃 Treadmills: " .. treadmills)
    print("   📋 Total: " .. (petAreas + treadmills))
    
    return petAreas, treadmills
end

-- ========================================================
-- MAIN EXECUTION & EXPORT
-- ========================================================

print("⚡ QUICK DESTROYER READY!")
print("========================")
print("💡 Available Commands:")
print("   quickDestroy() - Destroy all")
print("   destroyOnlyPetAreas() - PetAreas only")
print("   destroyOnlyTreadmills() - Treadmills only") 
print("   scanOnly() - Scan without destroying")
print("========================")

-- Export functions to global
getgenv().quickDestroy = quickDestroy
getgenv().destroyOnlyPetAreas = destroyOnlyPetAreas
getgenv().destroyOnlyTreadmills = destroyOnlyTreadmills
getgenv().scanOnly = scanOnly

-- Auto-execute destroy (comment out if you want manual control)
print("🚀 AUTO-EXECUTING QUICK DESTROY IN 3 SECONDS...")
print("⚠️ To cancel, close this script now!")

task.wait(3)
quickDestroy()

print("🎉 QUICK DESTROYER EXECUTION COMPLETE!")