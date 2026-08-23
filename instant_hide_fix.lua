-- ========================================================
-- INSTANT HIDE FIX - Execute this if pets/eggs still visible
-- ========================================================

print("👻 INSTANT HIDE FIX - AGGRESSIVE MODE")
print("=====================================")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local hiddenCount = 0

-- SUPER AGGRESSIVE PET HIDING
print("🐾 Scanning for pets...")
for _, obj in pairs(Workspace:GetDescendants()) do
    pcall(function()
        local objName = obj.Name:lower()
        local parentName = obj.Parent and obj.Parent.Name:lower() or ""
        
        -- Ultra-broad pet detection
        if (objName:find("pet") or objName:find("companion") or objName:find("follow") or
            objName:find("buddy") or objName:find("helper") or objName:find("sidekick") or
            objName:find("dragon") or objName:find("cat") or objName:find("dog") or
            objName:find("bird") or objName:find("wolf") or objName:find("fox") or
            parentName:find("pet") or parentName:find("companion")) and
           obj ~= LocalPlayer.Character then
            
            -- DESTROY METHOD (most aggressive)
            if obj:IsA("Model") then
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                        part.CanCollide = false
                        part.CastShadow = false
                        part.CanTouch = false
                        part.Size = Vector3.new(0, 0, 0) -- Make it tiny
                    elseif part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Trail") then
                        part.Enabled = false
                    elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
                        part.Enabled = false
                    elseif part:IsA("SpecialMesh") then
                        part.Scale = Vector3.new(0, 0, 0)
                    end
                end
                
                -- Move far away
                if obj.PrimaryPart then
                    obj:SetPrimaryPartCFrame(CFrame.new(99999, 99999, 99999))
                elseif obj:FindFirstChild("HumanoidRootPart") then
                    obj.HumanoidRootPart.CFrame = CFrame.new(99999, 99999, 99999)
                end
                
                hiddenCount = hiddenCount + 1
                
            elseif obj:IsA("BasePart") then
                obj.Transparency = 1
                obj.CanCollide = false
                obj.CastShadow = false
                obj.CanTouch = false
                obj.Size = Vector3.new(0, 0, 0)
                obj.CFrame = CFrame.new(99999, 99999, 99999)
                hiddenCount = hiddenCount + 1
            end
        end
    end)
end

print("✅ Pets hidden/moved: " .. hiddenCount)

-- SUPER AGGRESSIVE EGG HIDING
print("🥚 Scanning for eggs...")
local eggCount = 0

-- Method 1: AreaEggSlotsClient
local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
if areaEggs then
    for _, eggModel in pairs(areaEggs:GetChildren()) do
        pcall(function()
            if eggModel:IsA("Model") then
                for _, part in pairs(eggModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local partName = part.Name:lower()
                        -- Keep ONLY hitboxes functional
                        if partName:find("hitbox") or partName:find("hit") or 
                           partName:find("touch") or partName:find("detect") or
                           partName:find("collision") then
                            -- Make hitbox invisible but keep collision
                            part.Transparency = 1
                            part.Material = Enum.Material.ForceField
                            part.BrickColor = BrickColor.new("Really red") -- Debug color
                        else
                            -- Hide everything else
                            part.Transparency = 1
                            part.CanCollide = false
                            part.CastShadow = false
                            part.CanTouch = false
                            part.Material = Enum.Material.Air
                            part.Size = Vector3.new(0, 0, 0)
                        end
                    elseif part:IsA("SpecialMesh") then
                        part.Scale = Vector3.new(0, 0, 0)
                        part.VertexColor = Vector3.new(0, 0, 0)
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 1
                        part.Color3 = Color3.new(0, 0, 0)
                    elseif part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Trail") then
                        part.Enabled = false
                    elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
                        part.Enabled = false
                    elseif part:IsA("Sound") then
                        part.Volume = 0
                    end
                end
                eggCount = eggCount + 1
            end
        end)
    end
end

-- Method 2: Direct egg scan
for _, obj in pairs(Workspace:GetDescendants()) do
    pcall(function()
        local objName = obj.Name:lower()
        if obj:IsA("BasePart") and objName:find("egg") and not objName:find("slot") then
            if not (objName:find("hitbox") or objName:find("hit")) then
                obj.Transparency = 1
                obj.CanCollide = false
                obj.CastShadow = false
                obj.CanTouch = false
                obj.Size = Vector3.new(0, 0, 0)
                eggCount = eggCount + 1
            end
        end
    end)
end

print("✅ Eggs hidden: " .. eggCount .. " (hitboxes preserved)")

-- HIDE ALL VISUAL EFFECTS
print("✨ Hiding effects...")
local effectCount = 0
for _, obj in pairs(Workspace:GetDescendants()) do
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or 
           obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
            effectCount = effectCount + 1
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = false
            effectCount = effectCount + 1
        end
    end)
end

print("✅ Effects disabled: " .. effectCount)

-- CONTINUOUS MONITORING
print("🔄 Starting continuous hide monitoring...")
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            -- Re-hide pets that spawn
            for _, obj in pairs(Workspace:GetDescendants()) do
                local objName = obj.Name:lower()
                if obj:IsA("Model") and objName:find("pet") then
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                            part.CanCollide = false
                            part.Size = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
            
            -- Re-hide eggs that respawn
            local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
            if areaEggs then
                for _, eggModel in pairs(areaEggs:GetChildren()) do
                    if eggModel:IsA("Model") then
                        for _, part in pairs(eggModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local partName = part.Name:lower()
                                if not (partName:find("hitbox") or partName:find("hit")) then
                                    part.Transparency = 1
                                    part.CanCollide = false
                                    part.CastShadow = false
                                    part.Size = Vector3.new(0, 0, 0)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

print("\n✅ INSTANT HIDE COMPLETE!")
print("==========================================")
print("🐾 Pets hidden/moved: " .. hiddenCount)
print("🥚 Eggs hidden: " .. eggCount)
print("✨ Effects disabled: " .. effectCount)
print("🔄 Continuous monitoring active")
print("==========================================")
print("👻 Everything should be invisible now!")
print("⚠️ If still visible, the game might be using")
print("   different object names/structures")

-- Debug: Print visible objects for investigation
print("\n🔍 DEBUG - Remaining visible objects:")
for _, obj in pairs(Workspace:GetDescendants()) do
    pcall(function()
        if obj:IsA("BasePart") and obj.Transparency < 1 and obj.Size.Magnitude > 0 then
            local objName = obj.Name:lower()
            if objName:find("pet") or objName:find("egg") or objName:find("companion") then
                print("   Still visible: " .. obj.Name .. " (" .. obj.ClassName .. ") - Parent: " .. (obj.Parent and obj.Parent.Name or "None"))
            end
        end
    end)
end