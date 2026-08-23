-- ========================================================
-- QUICK DESTROY EGG POINTS - INSTANT VERSION
-- Versi instant tanpa GUI untuk destroy cepat semua egg point
-- ========================================================

print("⚡ QUICK EGG POINT DESTROYER LOADING...")

local Workspace = game:GetService("Workspace")

-- ========================================================
-- INSTANT DESTROY FUNCTIONS
-- ========================================================

local function quickDestroyEggPoints()
    print("💥 STARTING INSTANT EGG POINT DESTRUCTION...")
    
    local eggPointsDestroyed = 0
    local eggSlotsDestroyed = 0
    local eggAreasDestroyed = 0
    local eggSpawnsDestroyed = 0
    local totalDestroyed = 0
    
    -- Scan and destroy in one pass for maximum speed
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            local shouldDestroy = false
            local objType = ""
            
            -- Check for EggPoint patterns
            if objName:find("eggpoint") or objName:find("egg_point") or objName:find("egg point") then
                shouldDestroy = true
                objType = "EggPoint"
                eggPointsDestroyed = eggPointsDestroyed + 1
                
            -- Check for EggSlot patterns
            elseif objName:find("eggslot") or objName:find("egg_slot") or objName:find("egg slot") then
                shouldDestroy = true
                objType = "EggSlot"
                eggSlotsDestroyed = eggSlotsDestroyed + 1
                
            -- Check for EggArea patterns
            elseif objName:find("eggarea") or objName:find("egg_area") or objName:find("egg area") then
                shouldDestroy = true
                objType = "EggArea"
                eggAreasDestroyed = eggAreasDestroyed + 1
                
            -- Check for EggSpawn patterns
            elseif objName:find("eggspawn") or objName:find("egg_spawn") or objName:find("egg spawn") then
                shouldDestroy = true
                objType = "EggSpawn"
                eggSpawnsDestroyed = eggSpawnsDestroyed + 1
                
            -- Check parent for AreaEggSlots
            elseif obj.Parent and obj.Parent.Name:lower():find("areaeggslot") then
                shouldDestroy = true
                objType = "AreaEggSlot"
                eggSlotsDestroyed = eggSlotsDestroyed + 1
            end
            
            -- Destroy if matched
            if shouldDestroy and obj.Parent then
                print("🔥 Destroying " .. objType .. ": " .. obj.Name)
                obj:Destroy()
                totalDestroyed = totalDestroyed + 1
            end
        end)
    end
    
    -- Special handling for AreaEggSlotsClient
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if areaEggs then
        print("🎯 Found AreaEggSlotsClient - destroying all contents...")
        for _, eggModel in pairs(areaEggs:GetChildren()) do
            pcall(function()
                print("🔥 Destroying AreaEggSlot: " .. eggModel.Name)
                eggModel:Destroy()
                eggSlotsDestroyed = eggSlotsDestroyed + 1
                totalDestroyed = totalDestroyed + 1
            end)
        end
    end
    
    -- Results
    print("✅ INSTANT EGG POINT DESTRUCTION COMPLETE!")
    print("==========================================")
    print("🥚 EggPoints destroyed: " .. eggPointsDestroyed)
    print("🎰 EggSlots destroyed: " .. eggSlotsDestroyed)
    print("📍 EggAreas destroyed: " .. eggAreasDestroyed)
    print("🌟 EggSpawns destroyed: " .. eggSpawnsDestroyed)
    print("💥 Total destroyed: " .. totalDestroyed)
    print("==========================================")
    
    if totalDestroyed > 0 then
        print("🚀 Performance should be significantly improved!")
        print("🎯 Egg collection mechanics completely removed!")
    else
        print("⚠️ No egg point objects found")
    end
    
    return totalDestroyed
end

-- ========================================================
-- SPECIFIC DESTROY FUNCTIONS
-- ========================================================

local function destroyOnlyEggPoints()
    print("🥚 DESTROYING ONLY EGG POINTS...")
    local destroyed = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            
            if (objName:find("eggpoint") or objName:find("egg_point") or objName:find("egg point")) and obj.Parent then
                print("🔥 Destroying EggPoint: " .. obj.Name)
                obj:Destroy()
                destroyed = destroyed + 1
            end
        end)
    end
    
    print("✅ EggPoints destroyed: " .. destroyed)
    return destroyed
end

local function destroyOnlyEggSlots()
    print("🎰 DESTROYING ONLY EGG SLOTS...")
    local destroyed = 0
    
    -- Destroy AreaEggSlotsClient contents
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if areaEggs then
        for _, eggModel in pairs(areaEggs:GetChildren()) do
            pcall(function()
                print("🔥 Destroying AreaEggSlot: " .. eggModel.Name)
                eggModel:Destroy()
                destroyed = destroyed + 1
            end)
        end
    end
    
    -- Destroy other egg slots
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            
            if (objName:find("eggslot") or objName:find("egg_slot") or objName:find("egg slot")) and obj.Parent then
                print("🔥 Destroying EggSlot: " .. obj.Name)
                obj:Destroy()
                destroyed = destroyed + 1
            end
        end)
    end
    
    print("✅ EggSlots destroyed: " .. destroyed)
    return destroyed
end

local function destroyOnlyEggAreas()
    print("📍 DESTROYING ONLY EGG AREAS...")
    local destroyed = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            
            if (objName:find("eggarea") or objName:find("egg_area") or objName:find("egg area")) and obj.Parent then
                print("🔥 Destroying EggArea: " .. obj.Name)
                obj:Destroy()
                destroyed = destroyed + 1
            end
        end)
    end
    
    print("✅ EggAreas destroyed: " .. destroyed)
    return destroyed
end

-- ========================================================
-- SCAN ONLY FUNCTION
-- ========================================================

local function scanOnlyEggPoints()
    print("🔍 SCANNING FOR EGG POINTS...")
    
    local eggPoints = 0
    local eggSlots = 0
    local eggAreas = 0
    local eggSpawns = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            
            if objName:find("eggpoint") or objName:find("egg_point") or objName:find("egg point") then
                eggPoints = eggPoints + 1
                print("🎯 Found EggPoint: " .. obj.Name)
                
            elseif objName:find("eggslot") or objName:find("egg_slot") or objName:find("egg slot") then
                eggSlots = eggSlots + 1
                print("🎯 Found EggSlot: " .. obj.Name)
                
            elseif objName:find("eggarea") or objName:find("egg_area") or objName:find("egg area") then
                eggAreas = eggAreas + 1
                print("🎯 Found EggArea: " .. obj.Name)
                
            elseif objName:find("eggspawn") or objName:find("egg_spawn") or objName:find("egg spawn") then
                eggSpawns = eggSpawns + 1
                print("🎯 Found EggSpawn: " .. obj.Name)
                
            elseif obj.Parent and obj.Parent.Name:lower():find("areaeggslot") then
                eggSlots = eggSlots + 1
                print("🎯 Found AreaEggSlot: " .. obj.Name)
            end
        end)
    end
    
    -- Check AreaEggSlotsClient
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if areaEggs then
        for _, eggModel in pairs(areaEggs:GetChildren()) do
            eggSlots = eggSlots + 1
            print("🎯 Found AreaEggSlot: " .. eggModel.Name)
        end
    end
    
    print("📊 EGG POINT SCAN RESULTS:")
    print("   🥚 EggPoints: " .. eggPoints)
    print("   🎰 EggSlots: " .. eggSlots)
    print("   📍 EggAreas: " .. eggAreas)
    print("   🌟 EggSpawns: " .. eggSpawns)
    print("   📋 Total: " .. (eggPoints + eggSlots + eggAreas + eggSpawns))
    
    return eggPoints, eggSlots, eggAreas, eggSpawns
end

-- ========================================================
-- MAIN EXECUTION & EXPORT
-- ========================================================

print("⚡ QUICK EGG POINT DESTROYER READY!")
print("===================================")
print("💡 Available Commands:")
print("   quickDestroyEggPoints() - Destroy all")
print("   destroyOnlyEggPoints() - EggPoints only")
print("   destroyOnlyEggSlots() - EggSlots only")
print("   destroyOnlyEggAreas() - EggAreas only") 
print("   scanOnlyEggPoints() - Scan without destroying")
print("===================================")

-- Export functions to global
getgenv().quickDestroyEggPoints = quickDestroyEggPoints
getgenv().destroyOnlyEggPoints = destroyOnlyEggPoints
getgenv().destroyOnlyEggSlots = destroyOnlyEggSlots
getgenv().destroyOnlyEggAreas = destroyOnlyEggAreas
getgenv().scanOnlyEggPoints = scanOnlyEggPoints

-- Auto-execute destroy (comment out if you want manual control)
print("🚀 AUTO-EXECUTING EGG POINT DESTROY IN 3 SECONDS...")
print("⚠️ To cancel, close this script now!")

task.wait(3)
quickDestroyEggPoints()

print("🎉 QUICK EGG POINT DESTROYER EXECUTION COMPLETE!")