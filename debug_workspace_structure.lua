-- ========================================================
-- WORKSPACE STRUCTURE DEBUG ANALYZER
-- Scans entire Workspace and generates copy-paste paths
-- ========================================================

print("🔍 WORKSPACE STRUCTURE ANALYZER")
print("===============================")
print("⏳ Scanning entire Workspace...")
task.wait(1)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- STRUCTURE STORAGE
-- ========================================================

local workspaceStructure = {}
local totalObjects = 0
local categoryStats = {
    Models = 0,
    Parts = 0,
    Scripts = 0,
    GUIs = 0,
    Effects = 0,
    Sounds = 0,
    Lights = 0,
    Meshes = 0,
    Textures = 0,
    Animations = 0,
    Players = 0,
    Pets = 0,
    Eggs = 0,
    Unknown = 0
}

-- ========================================================
-- HELPER FUNCTIONS
-- ========================================================

local function getObjectCategory(obj)
    local className = obj.ClassName
    local objName = obj.Name:lower()
    
    -- Specific game objects
    if objName:find("pet") or objName:find("companion") or objName:find("follow") then
        return "Pets"
    elseif objName:find("egg") then
        return "Eggs"
    elseif className == "Model" then
        return "Models"
    elseif className:find("Part") or className:find("Block") or className:find("Wedge") then
        return "Parts"
    elseif className:find("Script") then
        return "Scripts"
    elseif className:find("Gui") or className:find("Frame") or className:find("Label") or className:find("Button") then
        return "GUIs"
    elseif className:find("Particle") or className:find("Beam") or className:find("Trail") or className:find("Fire") or className:find("Smoke") then
        return "Effects"
    elseif className:find("Sound") or className:find("Music") then
        return "Sounds"
    elseif className:find("Light") then
        return "Lights"
    elseif className:find("Mesh") then
        return "Meshes"
    elseif className:find("Decal") or className:find("Texture") then
        return "Textures"
    elseif className:find("Animation") then
        return "Animations"
    elseif Players:GetPlayerFromCharacter(obj) then
        return "Players"
    else
        return "Unknown"
    end
end

local function getObjectPath(obj)
    local path = {}
    local current = obj
    
    while current and current ~= Workspace do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    
    return "Workspace." .. table.concat(path, ".")
end

local function analyzeObject(obj, depth, parentPath)
    depth = depth or 0
    parentPath = parentPath or ""
    
    if depth > 20 then return end -- Prevent infinite loops
    
    totalObjects = totalObjects + 1
    
    local category = getObjectCategory(obj)
    categoryStats[category] = categoryStats[category] + 1
    
    local currentPath = parentPath ~= "" and (parentPath .. "." .. obj.Name) or obj.Name
    local fullPath = "game.Workspace." .. currentPath
    
    -- Store object info
    local objInfo = {
        name = obj.Name,
        className = obj.ClassName,
        category = category,
        path = fullPath,
        copyPath = 'game:GetService("Workspace")' .. (currentPath ~= "" and ("." .. currentPath) or ""),
        depth = depth,
        children = {},
        properties = {}
    }
    
    -- Get useful properties
    pcall(function()
        if obj:IsA("BasePart") then
            objInfo.properties.Size = tostring(obj.Size)
            objInfo.properties.Material = tostring(obj.Material)
            objInfo.properties.Transparency = tostring(obj.Transparency)
            objInfo.properties.CanCollide = tostring(obj.CanCollide)
        elseif obj:IsA("ParticleEmitter") then
            objInfo.properties.Enabled = tostring(obj.Enabled)
            objInfo.properties.Rate = tostring(obj.Rate)
        elseif obj:IsA("Sound") then
            objInfo.properties.Volume = tostring(obj.Volume)
            objInfo.properties.Playing = tostring(obj.Playing)
        end
    end)
    
    -- Add to structure
    if not workspaceStructure[category] then
        workspaceStructure[category] = {}
    end
    table.insert(workspaceStructure[category], objInfo)
    
    -- Analyze children (limit depth for performance)
    if depth < 5 then
        for _, child in pairs(obj:GetChildren()) do
            pcall(function()
                objInfo.children[child.Name] = analyzeObject(child, depth + 1, currentPath)
            end)
        end
    end
    
    return objInfo
end

-- ========================================================
-- MAIN SCAN
-- ========================================================

local startTime = tick()

print("🔄 Analyzing Workspace structure...")

-- Scan all workspace children
for _, obj in pairs(Workspace:GetChildren()) do
    pcall(function()
        analyzeObject(obj, 0, "")
    end)
end

local scanTime = math.floor((tick() - startTime) * 1000) / 1000

-- ========================================================
-- GENERATE REPORT
-- ========================================================

print("\n📊 WORKSPACE ANALYSIS COMPLETE!")
print("================================")
print("⏱️  Scan time: " .. scanTime .. " seconds")
print("📦 Total objects: " .. totalObjects)
print("\n📋 CATEGORY BREAKDOWN:")

local sortedCategories = {}
for category, count in pairs(categoryStats) do
    if count > 0 then
        table.insert(sortedCategories, {category = category, count = count})
    end
end

-- Sort by count
table.sort(sortedCategories, function(a, b) return a.count > b.count end)

for _, data in ipairs(sortedCategories) do
    print(string.format("   %s: %d objects", data.category, data.count))
end

-- ========================================================
-- DETAILED STRUCTURE OUTPUT
-- ========================================================

print("\n🔍 DETAILED STRUCTURE (COPY-PASTE READY):")
print("==========================================")

-- Function to print structure
local function printStructure(category, objects, maxShow)
    maxShow = maxShow or 10
    
    if #objects == 0 then return end
    
    print("\n📁 " .. category .. " (" .. #objects .. " total):")
    print("   " .. string.rep("-", 50))
    
    for i = 1, math.min(maxShow, #objects) do
        local obj = objects[i]
        print(string.format("   [%d] %s (%s)", i, obj.name, obj.className))
        print("       Path: " .. obj.path)
        print("       Copy: " .. obj.copyPath)
        
        if next(obj.properties) then
            print("       Props: " .. table.concat((function()
                local props = {}
                for k, v in pairs(obj.properties) do
                    table.insert(props, k .. "=" .. v)
                end
                return props
            end)(), ", "))
        end
        
        if i < #objects and i < maxShow then
            print()
        end
    end
    
    if #objects > maxShow then
        print("       ... and " .. (#objects - maxShow) .. " more objects")
    end
end

-- Print each category
for _, data in ipairs(sortedCategories) do
    local category = data.category
    printStructure(category, workspaceStructure[category], 5)
end

-- ========================================================
-- PETS & EGGS SPECIFIC ANALYSIS
-- ========================================================

print("\n🐾 PETS DETAILED ANALYSIS:")
print("==========================")

local petsFound = {}
for _, obj in pairs(Workspace:GetDescendants()) do
    pcall(function()
        local objName = obj.Name:lower()
        if obj:IsA("Model") and (objName:find("pet") or objName:find("companion") or objName:find("follow")) then
            table.insert(petsFound, {
                name = obj.Name,
                fullPath = getObjectPath(obj),
                copyPath = 'game:GetService("Workspace"):FindFirstChild("' .. obj.Name .. '")',
                parent = obj.Parent and obj.Parent.Name or "None",
                className = obj.ClassName
            })
        end
    end)
end

if #petsFound > 0 then
    for i, pet in ipairs(petsFound) do
        print(string.format("🐾 Pet %d: %s", i, pet.name))
        print("   Path: " .. pet.fullPath)
        print("   Copy: " .. pet.copyPath)
        print("   Parent: " .. pet.parent)
        print()
    end
else
    print("   No pets found with standard naming")
end

print("\n🥚 EGGS DETAILED ANALYSIS:")
print("==========================")

local eggsFound = {}
local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")

if areaEggs then
    print("✅ Found AreaEggSlotsClient!")
    print("   Path: game.Workspace.AreaEggSlotsClient")
    print("   Copy: game:GetService('Workspace').AreaEggSlotsClient")
    print()
    
    for _, eggModel in pairs(areaEggs:GetChildren()) do
        pcall(function()
            if eggModel:IsA("Model") then
                table.insert(eggsFound, {
                    name = eggModel.Name,
                    fullPath = "Workspace.AreaEggSlotsClient." .. eggModel.Name,
                    copyPath = 'game:GetService("Workspace").AreaEggSlotsClient:FindFirstChild("' .. eggModel.Name .. '")',
                    childCount = #eggModel:GetChildren()
                })
                
                -- Analyze egg parts
                for _, part in pairs(eggModel:GetChildren()) do
                    if part:IsA("BasePart") then
                        local partName = part.Name:lower()
                        if partName:find("hitbox") or partName:find("hit") then
                            print("🎯 HITBOX FOUND: " .. eggModel.Name .. "." .. part.Name)
                            print("   Copy: game.Workspace.AreaEggSlotsClient." .. eggModel.Name .. "." .. part.Name)
                        end
                    end
                end
            end
        end)
    end
    
    print("\n📋 EGG MODELS SUMMARY:")
    for i, egg in ipairs(eggsFound) do
        print(string.format("🥚 Egg %d: %s (%d children)", i, egg.name, egg.childCount))
        print("   Copy: " .. egg.copyPath)
    end
else
    print("❌ AreaEggSlotsClient not found!")
    print("   Searching for eggs in other locations...")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            if obj:IsA("Model") and objName:find("egg") then
                table.insert(eggsFound, {
                    name = obj.Name,
                    fullPath = getObjectPath(obj),
                    copyPath = 'game:GetService("Workspace"):FindFirstChild("' .. obj.Name .. '")',
                    parent = obj.Parent and obj.Parent.Name or "None"
                })
            end
        end)
    end
    
    if #eggsFound > 0 then
        print("   Alternative egg locations found:")
        for _, egg in ipairs(eggsFound) do
            print("   🥚 " .. egg.name .. " (Parent: " .. egg.parent .. ")")
            print("      Copy: " .. egg.copyPath)
        end
    end
end

-- ========================================================
-- COPY-PASTE HIDE COMMANDS
-- ========================================================

print("\n📋 COPY-PASTE HIDE COMMANDS:")
print("=============================")

print("\n-- HIDE ALL PETS:")
for _, pet in ipairs(petsFound) do
    print('pcall(function() ' .. pet.copyPath .. '.Parent = nil end)')
end

print("\n-- HIDE ALL EGGS (KEEP HITBOXES):")
if areaEggs then
    print('local areaEggs = game:GetService("Workspace").AreaEggSlotsClient')
    print('for _, eggModel in pairs(areaEggs:GetChildren()) do')
    print('    for _, part in pairs(eggModel:GetDescendants()) do')
    print('        if part:IsA("BasePart") and not part.Name:lower():find("hitbox") then')
    print('            part.Transparency = 1')
    print('            part.CanCollide = false')
    print('        end')
    print('    end')
    print('end')
end

print("\n-- HIDE ALL EFFECTS:")
print('for _, obj in pairs(game.Workspace:GetDescendants()) do')
print('    if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then')
print('        obj.Enabled = false')
print('    end')
print('end')

-- ========================================================
-- AUTO-COPY TO CLIPBOARD
-- ========================================================

-- Generate complete hide script for clipboard
local clipboardScript = [[
-- ========================================================
-- AUTO-GENERATED HIDE SCRIPT FROM WORKSPACE ANALYSIS
-- Execute this script to hide all detected pets and eggs
-- ========================================================

print("🚀 Executing auto-generated hide script...")

-- HIDE ALL PETS
local petsHidden = 0
]]

-- Add pet hide commands
for _, pet in ipairs(petsFound) do
    clipboardScript = clipboardScript .. 'pcall(function() ' .. pet.copyPath .. '.Parent = nil; petsHidden = petsHidden + 1 end)\n'
end

clipboardScript = clipboardScript .. [[

-- HIDE ALL EGGS (PRESERVE HITBOXES)
local eggsHidden = 0
]]

if areaEggs then
    clipboardScript = clipboardScript .. [[
local areaEggs = game:GetService("Workspace").AreaEggSlotsClient
if areaEggs then
    for _, eggModel in pairs(areaEggs:GetChildren()) do
        pcall(function()
            if eggModel:IsA("Model") then
                for _, part in pairs(eggModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local partName = part.Name:lower()
                        if partName:find("hitbox") or partName:find("hit") then
                            part.Transparency = 1 -- Keep hitbox invisible but functional
                        else
                            part.Transparency = 1
                            part.CanCollide = false
                            part.CastShadow = false
                            part.Size = Vector3.new(0, 0, 0)
                        end
                    elseif part:IsA("SpecialMesh") then
                        part.Scale = Vector3.new(0, 0, 0)
                    elseif part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Trail") then
                        part.Enabled = false
                    end
                end
                eggsHidden = eggsHidden + 1
            end
        end)
    end
end
]]
end

clipboardScript = clipboardScript .. [[

-- HIDE ALL EFFECTS
local effectsHidden = 0
for _, obj in pairs(game.Workspace:GetDescendants()) do
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or 
           obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
            effectsHidden = effectsHidden + 1
        end
    end)
end

-- RESULTS
print("✅ HIDE SCRIPT COMPLETE!")
print("========================")
print("🐾 Pets hidden: " .. petsHidden)
print("🥚 Eggs hidden: " .. eggsHidden .. " (hitboxes preserved)")
print("✨ Effects disabled: " .. effectsHidden)
print("🎯 Ready to steal eggs with maximum performance!")
]]

-- Try to copy to clipboard
local clipboardSuccess = false
pcall(function()
    -- Method 1: Try setclipboard (most executors)
    if setclipboard then
        setclipboard(clipboardScript)
        clipboardSuccess = true
        print("\n📋 COPIED TO CLIPBOARD! (Method: setclipboard)")
    -- Method 2: Try toclipboard (some executors)  
    elseif toclipboard then
        toclipboard(clipboardScript)
        clipboardSuccess = true
        print("\n📋 COPIED TO CLIPBOARD! (Method: toclipboard)")
    -- Method 3: Try writeclipboard (alternative)
    elseif writeclipboard then
        writeclipboard(clipboardScript)
        clipboardSuccess = true
        print("\n📋 COPIED TO CLIPBOARD! (Method: writeclipboard)")
    end
end)

if not clipboardSuccess then
    print("\n⚠️  CLIPBOARD NOT AVAILABLE")
    print("📋 Manual copy required - script generated above")
    
    -- Create a GUI with the script for easy copying
    pcall(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        if LocalPlayer and LocalPlayer.PlayerGui then
            local gui = Instance.new("ScreenGui")
            gui.Name = "WorkspaceAnalysisResults"
            gui.ResetOnSpawn = false
            gui.Parent = LocalPlayer.PlayerGui
            
            -- Background frame
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 600, 0, 400)
            frame.Position = UDim2.new(0.5, -300, 0.5, -200)
            frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            frame.BorderSizePixel = 0
            frame.Parent = gui
            
            -- Corner rounding
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame
            
            -- Title
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 40)
            title.BackgroundTransparency = 1
            title.Text = "📋 WORKSPACE ANALYSIS - COPY SCRIPT BELOW"
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextSize = 16
            title.Font = Enum.Font.SourceSansBold
            title.Parent = frame
            
            -- Scrolling frame for script
            local scrollFrame = Instance.new("ScrollingFrame")
            scrollFrame.Size = UDim2.new(1, -20, 1, -80)
            scrollFrame.Position = UDim2.new(0, 10, 0, 50)
            scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            scrollFrame.BorderSizePixel = 0
            scrollFrame.ScrollBarThickness = 8
            scrollFrame.Parent = frame
            
            -- Script text
            local scriptText = Instance.new("TextLabel")
            scriptText.Size = UDim2.new(1, -10, 0, 2000) -- Large height for scrolling
            scriptText.Position = UDim2.new(0, 5, 0, 0)
            scriptText.BackgroundTransparency = 1
            scriptText.Text = clipboardScript
            scriptText.TextColor3 = Color3.fromRGB(0, 255, 0)
            scriptText.TextSize = 12
            scriptText.Font = Enum.Font.Code
            scriptText.TextXAlignment = Enum.TextXAlignment.Left
            scriptText.TextYAlignment = Enum.TextYAlignment.Top
            scriptText.TextWrapped = true
            scriptText.Parent = scrollFrame
            
            -- Update canvas size
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scriptText.TextBounds.Y + 20)
            
            -- Close button
            local closeButton = Instance.new("TextButton")
            closeButton.Size = UDim2.new(0, 80, 0, 25)
            closeButton.Position = UDim2.new(1, -90, 0, 5)
            closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            closeButton.Text = "✕ Close"
            closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeButton.TextSize = 12
            closeButton.Font = Enum.Font.SourceSansBold
            closeButton.Parent = frame
            
            closeButton.MouseButton1Click:Connect(function()
                gui:Destroy()
            end)
            
            print("📋 GUI created with copy-ready script!")
        end
    end)
end

print("\n💾 ANALYSIS COMPLETE!")
print("====================")
print("📊 Total scanned: " .. totalObjects .. " objects")
print("🐾 Pets found: " .. #petsFound)
print("🥚 Eggs found: " .. #eggsFound)
print("⏱️  Analysis time: " .. scanTime .. "s")

if clipboardSuccess then
    print("✅ Hide script automatically copied to clipboard!")
    print("📋 Just paste and execute to hide everything!")
else
    print("📋 Copy the script from GUI or console output above")
end

print("🔄 This script updates every 10 seconds...")

-- Auto-refresh every 10 seconds
task.spawn(function()
    while task.wait(10) do
        print("\n🔄 Refreshing analysis...")
        -- Reset counters and re-analyze
        totalObjects = 0
        categoryStats = {
            Models = 0, Parts = 0, Scripts = 0, GUIs = 0, Effects = 0,
            Sounds = 0, Lights = 0, Meshes = 0, Textures = 0,
            Animations = 0, Players = 0, Pets = 0, Eggs = 0, Unknown = 0
        }
        workspaceStructure = {}
        
        -- Quick re-scan
        for _, obj in pairs(Workspace:GetChildren()) do
            pcall(function()
                analyzeObject(obj, 0, "")
            end)
        end
        
        print("📊 Updated totals:")
        for category, count in pairs(categoryStats) do
            if count > 0 then
                print("   " .. category .. ": " .. count)
            end
        end
    end
end)