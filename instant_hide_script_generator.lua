-- ========================================================
-- INSTANT HIDE SCRIPT GENERATOR
-- Generates ready-to-use hide script immediately
-- ========================================================

print("⚡ INSTANT HIDE SCRIPT GENERATOR")
print("================================")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- QUICK SCAN & GENERATE
-- ========================================================

print("🔍 Quick scanning...")

local petsFound = {}
local eggsFound = {}

-- Quick pet scan
for _, obj in pairs(Workspace:GetChildren()) do
    pcall(function()
        local objName = obj.Name:lower()
        if obj:IsA("Model") and (objName:find("pet") or objName:find("companion") or objName:find("dragon")) then
            table.insert(petsFound, obj.Name)
        end
    end)
end

-- Quick egg scan
local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
if areaEggs then
    for _, eggModel in pairs(areaEggs:GetChildren()) do
        pcall(function()
            if eggModel:IsA("Model") then
                table.insert(eggsFound, eggModel.Name)
            end
        end)
    end
end

print("✅ Found:")
print("   🐾 Pets: " .. #petsFound)
print("   🥚 Eggs: " .. #eggsFound)

-- ========================================================
-- GENERATE HIDE SCRIPT
-- ========================================================

local hideScript = [[-- ========================================================
-- AUTO-GENERATED HIDE SCRIPT
-- Copy and execute this script to hide pets & eggs
-- ========================================================

print("🚀 Executing hide script...")

local hidden = {pets = 0, eggs = 0, effects = 0}

-- HIDE PETS
]]

-- Add specific pets
for _, petName in ipairs(petsFound) do
    hideScript = hideScript .. 'pcall(function() game:GetService("Workspace"):FindFirstChild("' .. petName .. '").Parent = nil; hidden.pets = hidden.pets + 1 end)\n'
end

-- Add generic pet hiding
hideScript = hideScript .. [[

-- HIDE ANY REMAINING PETS
for _, obj in pairs(game.Workspace:GetChildren()) do
    pcall(function()
        local objName = obj.Name:lower()
        if obj:IsA("Model") and (objName:find("pet") or objName:find("companion") or objName:find("dragon") or objName:find("cat") or objName:find("dog")) then
            obj.Parent = nil
            hidden.pets = hidden.pets + 1
        end
    end)
end

-- HIDE EGGS (KEEP HITBOXES FOR STEALING)
local areaEggs = game:GetService("Workspace").AreaEggSlotsClient
if areaEggs then
    for _, eggModel in pairs(areaEggs:GetChildren()) do
        pcall(function()
            if eggModel:IsA("Model") then
                for _, part in pairs(eggModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local partName = part.Name:lower()
                        if partName:find("hitbox") or partName:find("hit") or partName:find("detect") then
                            -- Keep hitbox invisible but functional for stealing
                            part.Transparency = 1
                        else
                            -- Hide visual parts completely
                            part.Transparency = 1
                            part.CanCollide = false
                            part.CastShadow = false
                            part.Size = Vector3.new(0, 0, 0)
                        end
                    elseif part:IsA("SpecialMesh") then
                        part.Scale = Vector3.new(0, 0, 0)
                    elseif part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Trail") then
                        part.Enabled = false
                    elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
                        part.Enabled = false
                    end
                end
                hidden.eggs = hidden.eggs + 1
            end
        end)
    end
end

-- HIDE ALL VISUAL EFFECTS
for _, obj in pairs(game.Workspace:GetDescendants()) do
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or 
           obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or
           obj:IsA("PointLight") or obj:IsA("SpotLight") then
            obj.Enabled = false
            hidden.effects = hidden.effects + 1
        end
    end)
end

-- RESULTS
print("✅ HIDE COMPLETE!")
print("==========================================")
print("🐾 Pets hidden: " .. hidden.pets)
print("🥚 Eggs hidden: " .. hidden.eggs .. " (hitboxes preserved)")
print("✨ Effects disabled: " .. hidden.effects)
print("==========================================")
print("🎯 Maximum performance achieved!")
print("✅ You can still steal eggs (hitboxes work)!")

-- CONTINUOUS MONITORING (OPTIONAL)
task.spawn(function()
    while task.wait(5) do
        -- Re-hide any new pets that spawn
        for _, obj in pairs(game.Workspace:GetChildren()) do
            pcall(function()
                local objName = obj.Name:lower()
                if obj:IsA("Model") and objName:find("pet") then
                    obj.Parent = nil
                end
            end)
        end
    end
end)
]]

-- ========================================================
-- DISPLAY SCRIPT
-- ========================================================

print("\n📋 READY-TO-USE HIDE SCRIPT:")
print("=============================")
print("Copy everything between the lines below:")
print("=============================")
print(hideScript)
print("=============================")

-- ========================================================
-- TRY CLIPBOARD COPY
-- ========================================================

local clipboardSuccess = false
pcall(function()
    if setclipboard then
        setclipboard(hideScript)
        clipboardSuccess = true
        print("📋 SCRIPT COPIED TO CLIPBOARD!")
    elseif toclipboard then
        toclipboard(hideScript)
        clipboardSuccess = true
        print("📋 SCRIPT COPIED TO CLIPBOARD!")
    elseif writeclipboard then
        writeclipboard(hideScript)
        clipboardSuccess = true
        print("📋 SCRIPT COPIED TO CLIPBOARD!")
    end
end)

if not clipboardSuccess then
    print("⚠️  MANUAL COPY REQUIRED")
    print("📋 Select and copy the script above manually")
end

print("\n🎯 INSTRUCTIONS:")
print("================")
if clipboardSuccess then
    print("✅ Script is in your clipboard!")
    print("📝 Paste (Ctrl+V) in your executor")
else
    print("📝 Select all the script text above")
    print("📋 Copy it (Ctrl+C)")
    print("📝 Paste (Ctrl+V) in your executor")
end
print("▶️  Execute to hide all pets & eggs")
print("🥚 Egg hitboxes will be preserved for stealing")

-- ========================================================
-- CREATE SIMPLE GUI WITH SCRIPT (FALLBACK)
-- ========================================================

if not clipboardSuccess then
    pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "HideScriptDisplay"
        gui.ResetOnSpawn = false
        gui.Parent = LocalPlayer.PlayerGui
        
        -- Main frame
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 600, 0, 400)
        frame.Position = UDim2.new(0.5, -300, 0.5, -200)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Parent = gui
        
        -- Corner
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        -- Title
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundTransparency = 1
        title.Text = "📋 HIDE SCRIPT - COPY MANUALLY"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.SourceSansBold
        title.Parent = frame
        
        -- Script area
        local scriptBox = Instance.new("TextBox")
        scriptBox.Size = UDim2.new(1, -20, 1, -80)
        scriptBox.Position = UDim2.new(0, 10, 0, 50)
        scriptBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        scriptBox.Text = hideScript
        scriptBox.TextColor3 = Color3.fromRGB(0, 255, 100)
        scriptBox.TextSize = 10
        scriptBox.Font = Enum.Font.Code
        scriptBox.TextXAlignment = Enum.TextXAlignment.Left
        scriptBox.TextYAlignment = Enum.TextYAlignment.Top
        scriptBox.TextWrapped = true
        scriptBox.MultiLine = true
        scriptBox.TextEditable = false
        scriptBox.ClearTextOnFocus = false
        scriptBox.Parent = frame
        
        local scriptCorner = Instance.new("UICorner")
        scriptCorner.CornerRadius = UDim.new(0, 5)
        scriptCorner.Parent = scriptBox
        
        -- Close button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 80, 0, 25)
        closeBtn.Position = UDim2.new(1, -90, 1, -35)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        closeBtn.Text = "Close"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextSize = 12
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = frame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 5)
        closeCorner.Parent = closeBtn
        
        -- Auto-select text when clicked
        scriptBox.Focused:Connect(function()
            scriptBox.SelectionStart = 1
            scriptBox.CursorPosition = #scriptBox.Text + 1
        end)
        
        closeBtn.MouseButton1Click:Connect(function()
            gui:Destroy()
        end)
        
        print("📱 GUI created with script for manual copy!")
    end)
end

print("\n⚡ INSTANT HIDE SCRIPT GENERATOR COMPLETE!")
print("==========================================")
print("🎯 Total processing time: ~1 second")
print("📋 Ready-to-use script generated!")
print("🚀 Execute the script to hide everything!")