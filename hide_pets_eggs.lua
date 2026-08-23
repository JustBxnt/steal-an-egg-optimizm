-- ========================================================
-- STEAL AN EGG - HIDE PETS & EGGS (LAG REDUCER)
-- Hides pets and eggs to reduce visual lag
-- Execute this after the main optimization script
-- ========================================================

print("👻 HIDING PETS & EGGS FOR PERFORMANCE")
print("=====================================")

local CONFIG = {
    -- HIDE SETTINGS
    HidePets = true,              -- Hide all pets (including other players' pets)
    HideEggs = true,              -- Hide egg models (but keep hitboxes for stealing)
    HideOtherPlayers = false,     -- Hide other players (optional)
    HidePlayerNames = true,       -- Hide player name tags
    
    -- TOGGLE HOTKEYS
    TogglePetsKey = Enum.KeyCode.P,     -- Press P to toggle pets visibility
    ToggleEggsKey = Enum.KeyCode.E,     -- Press E to toggle eggs visibility
    ToggleAllKey = Enum.KeyCode.H,      -- Press H to toggle everything
    
    -- ADVANCED SETTINGS
    KeepEssentialParts = true,    -- Keep hitboxes for game functionality
    ShowHiddenCount = true,       -- Show count of hidden objects
    UpdateInterval = 5,           -- Check for new objects every 5 seconds
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local hiddenObjects = {}
local hiddenCount = {pets = 0, eggs = 0, players = 0}

-- ========================================================
-- HIDE/SHOW FUNCTIONS
-- ========================================================

local function hideObject(obj, category)
    if hiddenObjects[obj] then return end -- Already hidden
    
    local originalProperties = {}
    
    -- Store original properties
    pcall(function()
        if obj:IsA("BasePart") then
            originalProperties.Transparency = obj.Transparency
            originalProperties.CanCollide = obj.CanCollide
            originalProperties.CastShadow = obj.CastShadow
            
            -- Hide the part
            obj.Transparency = 1
            obj.CastShadow = false
            
            -- Keep collision for essential parts (like egg hitboxes)
            if not (CONFIG.KeepEssentialParts and (obj.Name:lower():find("hitbox") or obj.Name:lower():find("hit"))) then
                obj.CanCollide = false
            end
        elseif obj:IsA("Model") then
            -- Hide all parts in model
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    hideObject(part, category)
                end
            end
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            originalProperties.Enabled = obj.Enabled
            obj.Enabled = false
        end
    end)
    
    -- Store for restoration
    hiddenObjects[obj] = {
        category = category,
        properties = originalProperties,
        hidden = true
    }
    
    hiddenCount[category] = hiddenCount[category] + 1
end

local function showObject(obj)
    local data = hiddenObjects[obj]
    if not data or not data.hidden then return end
    
    -- Restore original properties
    pcall(function()
        if obj:IsA("BasePart") then
            obj.Transparency = data.properties.Transparency or 0
            obj.CanCollide = data.properties.CanCollide or false
            obj.CastShadow = data.properties.CastShadow or true
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj.Enabled = data.properties.Enabled or true
        end
    end)
    
    hiddenCount[data.category] = hiddenCount[data.category] - 1
    data.hidden = false
end

local function toggleObjectVisibility(obj)
    local data = hiddenObjects[obj]
    if data and data.hidden then
        showObject(obj)
    else
        hideObject(obj, data and data.category or "unknown")
    end
end

-- ========================================================
-- PET HIDING SYSTEM
-- ========================================================

local function hidePets()
    print("🐾 Hiding pets...")
    
    -- Hide pets in workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local objName = obj.Name:lower()
            local parent = obj.Parent
            
            -- Check if it's a pet
            if obj:IsA("Model") and (
                objName:find("pet") or 
                objName:find("companion") or
                objName:find("follow") or
                (parent and parent.Name:lower():find("pet"))
            ) then
                hideObject(obj, "pets")
            end
            
            -- Also hide pet-related effects
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                if parent and parent.Name:lower():find("pet") then
                    hideObject(obj, "pets")
                end
            end
        end)
    end
    
    -- Hide pets from all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, obj in pairs(player.Character:GetDescendants()) do
                pcall(function()
                    local objName = obj.Name:lower()
                    if objName:find("pet") or objName:find("companion") then
                        hideObject(obj, "pets")
                    end
                end)
            end
        end
    end
    
    print("✅ Pets hidden: " .. hiddenCount.pets)
end

local function showPets()
    print("🐾 Showing pets...")
    
    for obj, data in pairs(hiddenObjects) do
        if data.category == "pets" and data.hidden then
            showObject(obj)
        end
    end
    
    print("✅ Pets visible")
end

-- ========================================================
-- EGG HIDING SYSTEM
-- ========================================================

local function hideEggs()
    print("🥚 Hiding eggs...")
    
    -- Hide eggs in AreaEggSlotsClient
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if areaEggs then
        for _, eggModel in pairs(areaEggs:GetChildren()) do
            pcall(function()
                if eggModel:IsA("Model") then
                    -- Hide visual parts but keep hitboxes
                    for _, part in pairs(eggModel:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local partName = part.Name:lower()
                            -- Keep hitboxes visible (invisible but functional)
                            if partName:find("hitbox") or partName:find("hit") then
                                part.Transparency = 1 -- Invisible but keep collision
                            else
                                hideObject(part, "eggs")
                            end
                        elseif part:IsA("SpecialMesh") or part:IsA("Decal") then
                            hideObject(part, "eggs")
                        end
                    end
                end
            end)
        end
    end
    
    -- Hide egg-related effects
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                local parent = obj.Parent
                if parent and parent.Parent == areaEggs then
                    hideObject(obj, "eggs")
                end
            end
        end)
    end
    
    print("✅ Eggs hidden: " .. hiddenCount.eggs)
end

local function showEggs()
    print("🥚 Showing eggs...")
    
    for obj, data in pairs(hiddenObjects) do
        if data.category == "eggs" and data.hidden then
            showObject(obj)
        end
    end
    
    print("✅ Eggs visible")
end

-- ========================================================
-- PLAYER HIDING SYSTEM (OPTIONAL)
-- ========================================================

local function hideOtherPlayers()
    if not CONFIG.HideOtherPlayers then return end
    
    print("👤 Hiding other players...")
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            pcall(function()
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        hideObject(part, "players")
                    end
                end
            end)
        end
    end
    
    print("✅ Other players hidden: " .. hiddenCount.players)
end

local function hidePlayerNames()
    if not CONFIG.HidePlayerNames then return end
    
    print("🏷️ Hiding player names...")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BillboardGui") then
                local parent = obj.Parent
                if parent and parent.Parent and Players:GetPlayerFromCharacter(parent.Parent) then
                    hideObject(obj, "players")
                end
            end
        end)
    end
    
    print("✅ Player names hidden")
end

-- ========================================================
-- HOTKEY SYSTEM
-- ========================================================

local function setupHotkeys()
    print("⌨️ Setting up hotkeys...")
    print("   P = Toggle Pets")
    print("   E = Toggle Eggs") 
    print("   H = Toggle All")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == CONFIG.TogglePetsKey then
            if CONFIG.HidePets then
                showPets()
                CONFIG.HidePets = false
                print("🐾 Pets shown")
            else
                hidePets()
                CONFIG.HidePets = true
                print("👻 Pets hidden")
            end
            
        elseif input.KeyCode == CONFIG.ToggleEggsKey then
            if CONFIG.HideEggs then
                showEggs()
                CONFIG.HideEggs = false
                print("🥚 Eggs shown")
            else
                hideEggs()
                CONFIG.HideEggs = true
                print("👻 Eggs hidden")
            end
            
        elseif input.KeyCode == CONFIG.ToggleAllKey then
            local anyVisible = not CONFIG.HidePets or not CONFIG.HideEggs
            
            if anyVisible then
                -- Hide everything
                if not CONFIG.HidePets then
                    hidePets()
                    CONFIG.HidePets = true
                end
                if not CONFIG.HideEggs then
                    hideEggs()
                    CONFIG.HideEggs = true
                end
                print("👻 Everything hidden")
            else
                -- Show everything
                showPets()
                showEggs()
                CONFIG.HidePets = false
                CONFIG.HideEggs = false
                print("👁️ Everything visible")
            end
        end
    end)
end

-- ========================================================
-- MONITORING SYSTEM
-- ========================================================

local function createMonitoringGUI()
    if not CONFIG.ShowHiddenCount then return end
    
    -- Find existing optimization GUI
    local existingGUI = LocalPlayer.PlayerGui:FindFirstChild("StealEggOptimizer")
    if not existingGUI then
        print("⚠️ Main optimizer GUI not found, creating new one...")
        existingGUI = Instance.new("ScreenGui")
        existingGUI.Name = "StealEggOptimizer"
        existingGUI.Parent = LocalPlayer.PlayerGui
    end
    
    -- Add hide status to existing frame or create new one
    local existingFrame = existingGUI:FindFirstChild("Frame")
    if existingFrame then
        -- Add to existing frame
        local hideLabel = Instance.new("TextLabel")
        hideLabel.Name = "HideStatus"
        hideLabel.Size = UDim2.new(1, -10, 0, 40)
        hideLabel.Position = UDim2.new(0, 5, 0, 190)
        hideLabel.BackgroundTransparency = 1
        hideLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
        hideLabel.TextSize = 12
        hideLabel.Font = Enum.Font.SourceSans
        hideLabel.TextXAlignment = Enum.TextXAlignment.Left
        hideLabel.TextWrapped = true
        hideLabel.Parent = existingFrame
        
        -- Expand frame size
        existingFrame.Size = UDim2.new(0, 300, 0, 240)
        
        -- Update function
        task.spawn(function()
            while hideLabel.Parent do
                pcall(function()
                    hideLabel.Text = string.format("👻 Hidden - Pets: %d | Eggs: %d\n⌨️ Hotkeys: P, E, H", 
                        hiddenCount.pets, hiddenCount.eggs)
                end)
                task.wait(2)
            end
        end)
    end
end

-- ========================================================
-- AUTO-UPDATE SYSTEM
-- ========================================================

local function setupAutoUpdate()
    print("🔄 Setting up auto-update...")
    
    task.spawn(function()
        while task.wait(CONFIG.UpdateInterval) do
            pcall(function()
                if CONFIG.HidePets then
                    -- Check for new pets
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local objName = obj.Name:lower()
                        if obj:IsA("Model") and objName:find("pet") and not hiddenObjects[obj] then
                            hideObject(obj, "pets")
                        end
                    end
                end
                
                if CONFIG.HideEggs then
                    -- Check for new eggs
                    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
                    if areaEggs then
                        for _, eggModel in pairs(areaEggs:GetChildren()) do
                            if eggModel:IsA("Model") and not hiddenObjects[eggModel] then
                                hideObject(eggModel, "eggs")
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

local function main()
    print("🚀 Starting Hide System...")
    
    -- Initialize counters
    hiddenCount = {pets = 0, eggs = 0, players = 0}
    
    -- Apply hiding based on config
    if CONFIG.HidePets then
        hidePets()
    end
    
    if CONFIG.HideEggs then
        hideEggs()
    end
    
    hideOtherPlayers()
    hidePlayerNames()
    
    -- Setup systems
    setupHotkeys()
    createMonitoringGUI()
    setupAutoUpdate()
    
    -- Show results
    print("\n✅ HIDING SYSTEM ACTIVE!")
    print("================================")
    print("👻 Pets hidden: " .. hiddenCount.pets)
    print("🥚 Eggs hidden: " .. hiddenCount.eggs)
    print("👤 Players hidden: " .. hiddenCount.players)
    print("⌨️ Hotkeys: P (pets), E (eggs), H (all)")
    print("================================")
    print("🎮 Game should be much smoother now!")
    
    -- Performance boost estimate
    local totalHidden = hiddenCount.pets + hiddenCount.eggs + hiddenCount.players
    if totalHidden > 50 then
        print("🚀 EXCELLENT! " .. totalHidden .. " objects hidden!")
    elseif totalHidden > 20 then
        print("✅ GOOD! " .. totalHidden .. " objects hidden!")
    else
        print("ℹ️ " .. totalHidden .. " objects hidden")
    end
end

-- Execute with error handling
local success, error = pcall(main)
if not success then
    warn("❌ Hide system error: " .. tostring(error))
    print("🔄 Retrying with basic mode...")
    
    -- Fallback - basic hiding
    pcall(function()
        hidePets()
        hideEggs()
        print("✅ Basic hide mode active!")
    end)
end

-- Keep running
print("🔄 Hide system running continuously...")
print("⚠️ Objects will auto-hide as they spawn!")

-- Cleanup on character respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    print("🔄 Character respawned - reapplying hide settings...")
    pcall(function()
        if CONFIG.HidePets then hidePets() end
        if CONFIG.HideEggs then hideEggs() end
    end)
end)