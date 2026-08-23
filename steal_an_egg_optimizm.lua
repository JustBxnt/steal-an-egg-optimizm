-- ========================================================
-- STEAL AN EGG - ULTIMATE OPTIMIZATION SCRIPT V2
-- FPS Booster + Hide System + Performance Enhancer
-- ========================================================

print("🥚 STEAL AN EGG - ULTIMATE OPTIMIZER V2")
print("========================================")
print("⚡ Loading performance enhancements...")
task.wait(2)

-- ========================================================
-- CONFIGURATION (BOOLEAN SETTINGS)
-- ========================================================

local CONFIG = {
    -- FPS OPTIMIZATION
    TargetFPS = 240,              -- Target FPS (0 = unlimited)
    
    -- VISUAL OPTIMIZATION
    ReduceGraphicsQuality = true, -- true/false - Lower graphics settings
    OptimizeLighting = true,      -- true/false - Optimize lighting
    ReduceTextureQuality = true,  -- true/false - Reduce texture quality
    
    -- HIDE SYSTEM
    HidePets = true,              -- true/false - Hide all pets
    HideEggs = true,              -- true/false - Hide egg models (keep hitboxes)
    HideOtherPlayers = false,     -- true/false - Hide other players
    HidePlayerNames = true,       -- true/false - Hide player name tags
    ShowBlackScreen = false,      -- true/false - Black screen overlay (max FPS)
    
    -- MEMORY OPTIMIZATION
    EnableRAMCleaner = true,      -- true/false - Auto RAM cleaning
    RAMCleanInterval = 15,        -- Seconds between RAM cleaning
    OptimizeCharacterModel = true,-- true/false - Optimize character
    
    -- GAME-SPECIFIC OPTIMIZATION
    OptimizeEggModels = true,     -- true/false - Optimize egg rendering
    ReduceAreaDetails = true,     -- true/false - Simplify area decorations
    DisableWeatherEffects = true, -- true/false - Remove weather effects
    OptimizeGuardModels = true,   -- true/false - Simplify guard rendering
    
    -- DEBUG
    ShowPerformanceStats = true,  -- true/false - Show performance GUI
    ShowOptimizationLog = true,   -- true/false - Show optimization logs
}

-- ========================================================
-- SERVICES
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ========================================================
-- VARIABLES
-- ========================================================

local performanceStats = {
    startTime = tick(),
    initialFPS = 0,
    currentFPS = 0,
    initialRAM = 0,
    currentRAM = 0,
    objectsRemoved = 0,
    effectsDisabled = 0,
}

local hiddenCount = {pets = 0, eggs = 0, players = 0}

-- ========================================================
-- HELPER FUNCTIONS
-- ========================================================

local function getMemoryUsage()
    return Stats:GetTotalMemoryUsageMb()
end

local function getCurrentFPS()
    return math.floor(1 / RunService.Heartbeat:Wait())
end

local function logOptimization(message)
    if CONFIG.ShowOptimizationLog then
        print("🔧 " .. message)
    end
end

-- ========================================================
-- FPS OPTIMIZATION
-- ========================================================

local function setupFPSOptimization()
    print("\n⚡ FPS OPTIMIZATION")
    
    performanceStats.initialFPS = getCurrentFPS()
    logOptimization("Initial FPS: " .. performanceStats.initialFPS)
    
    -- Try setfpscap first
    if CONFIG.TargetFPS > 0 then
        local success = pcall(function()
            setfpscap(CONFIG.TargetFPS)
        end)
        
        if success then
            logOptimization("FPS capped to " .. CONFIG.TargetFPS)
        else
            logOptimization("setfpscap not supported")
        end
    end
    
    -- Optimize RunService connections
    for _, connection in pairs(getconnections and getconnections(RunService.Heartbeat) or {}) do
        if connection.Function then
            local source = debug.getinfo(connection.Function).source
            if source and (source:find("particle") or source:find("effect") or source:find("tween")) then
                pcall(function()
                    connection:Disconnect()
                    performanceStats.effectsDisabled = performanceStats.effectsDisabled + 1
                end)
            end
        end
    end
    
    logOptimization("FPS optimization complete")
end

-- ========================================================
-- GRAPHICS OPTIMIZATION
-- ========================================================

local function optimizeGraphics()
    print("\n🎨 GRAPHICS OPTIMIZATION")
    
    -- Lighting optimization
    if CONFIG.OptimizeLighting then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100
            Lighting.FogStart = 0
            Lighting.Brightness = 1
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        end)
        logOptimization("Lighting optimized")
    end
    
    -- Graphics quality reduction
    if CONFIG.ReduceGraphicsQuality then
        pcall(function()
            settings().Rendering.QualityLevel = "Level01"
            settings().Rendering.MeshPartDetailLevel = "Level01"
            settings().Rendering.MaterialQualityLevel = "Level01"
            settings().Rendering.ShadowQuality = "Level01"
            settings().Rendering.ParticleQuality = "Level01"
            settings().Rendering.TextureQuality = "Level01"
        end)
        logOptimization("Graphics quality minimized")
    end
    
    -- Reduce texture quality
    if CONFIG.ReduceTextureQuality then
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 0.5
                elseif obj:IsA("BasePart") then
                    obj.Material = Enum.Material.Plastic
                    obj.CastShadow = false
                end
            end)
        end
        logOptimization("Textures optimized")
    end
end

-- ========================================================
-- GAME-SPECIFIC OPTIMIZATIONS
-- ========================================================

local function optimizeEggGame()
    print("\n🥚 GAME-SPECIFIC OPTIMIZATION")
    
    -- Optimize egg models
    if CONFIG.OptimizeEggModels then
        local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
        if areaEggs then
            for _, eggModel in pairs(areaEggs:GetChildren()) do
                pcall(function()
                    if eggModel:IsA("Model") then
                        for _, part in pairs(eggModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Material = Enum.Material.Neon
                                part.CastShadow = false
                            elseif part:IsA("SpecialMesh") then
                                part.TextureId = ""
                            elseif part:IsA("Decal") or part:IsA("Texture") then
                                part:Destroy()
                                performanceStats.objectsRemoved = performanceStats.objectsRemoved + 1
                            end
                        end
                    end
                end)
            end
            logOptimization("Egg models optimized")
        end
    end
    
    -- Remove area decorations
    if CONFIG.ReduceAreaDetails then
        local areas = {"FOREST", "LAKE", "DESERT", "JUNGLE", "SNOW", "VOLCANO", "ABYSS", "PREHISTORIC", "COSMIC"}
        
        for _, areaName in ipairs(areas) do
            local area = Workspace:FindFirstChild(areaName)
            if area then
                for _, obj in pairs(area:GetDescendants()) do
                    pcall(function()
                        local objName = obj.Name:lower()
                        if obj:IsA("BasePart") and (
                            objName:find("tree") or objName:find("rock") or objName:find("bush") or
                            objName:find("grass") or objName:find("flower") or objName:find("decoration")
                        ) then
                            obj.Transparency = 1
                            obj.CanCollide = false
                            obj.CastShadow = false
                            performanceStats.objectsRemoved = performanceStats.objectsRemoved + 1
                        end
                    end)
                end
            end
        end
        logOptimization("Area decorations optimized")
    end
    
    -- Optimize guards
    if CONFIG.OptimizeGuardModels then
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                local objName = obj.Name:lower()
                if obj:IsA("Model") and (objName:find("guard") or objName:find("npc") or objName:find("cop")) then
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.Plastic
                            part.CastShadow = false
                        elseif part:IsA("Accessory") or part:IsA("Clothing") then
                            part:Destroy()
                            performanceStats.objectsRemoved = performanceStats.objectsRemoved + 1
                        end
                    end
                end
            end)
        end
        logOptimization("Guard models optimized")
    end
    
    -- Disable weather effects
    if CONFIG.DisableWeatherEffects then
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                    local parent = obj.Parent
                    if parent and (parent.Name:lower():find("rain") or parent.Name:lower():find("snow") or 
                                  parent.Name:lower():find("weather") or parent.Name:lower():find("effect")) then
                        obj.Enabled = false
                        performanceStats.effectsDisabled = performanceStats.effectsDisabled + 1
                    end
                end
            end)
        end
        logOptimization("Weather effects disabled")
    end
end

-- ========================================================
-- MEMORY OPTIMIZATION
-- ========================================================

local function optimizeMemory()
    print("\n🧠 MEMORY OPTIMIZATION")
    
    performanceStats.initialRAM = getMemoryUsage()
    logOptimization("Initial RAM: " .. math.floor(performanceStats.initialRAM) .. " MB")
    
    -- Optimize character model
    if CONFIG.OptimizeCharacterModel and Character then
        pcall(function()
            for _, accessory in pairs(Character:GetChildren()) do
                if accessory:IsA("Accessory") and not accessory.Name:lower():find("tool") then
                    accessory:Destroy()
                    performanceStats.objectsRemoved = performanceStats.objectsRemoved + 1
                end
            end
            
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.Plastic
                    part.CastShadow = false
                end
            end
        end)
        logOptimization("Character optimized")
    end
    
    -- Setup RAM cleaner
    if CONFIG.EnableRAMCleaner then
        task.spawn(function()
            while task.wait(CONFIG.RAMCleanInterval) do
                pcall(function()
                    for i = 1, 3 do
                        game:GetService("RunService").Heartbeat:Wait()
                        collectgarbage("collect")
                    end
                    
                    performanceStats.currentRAM = getMemoryUsage()
                    
                    if CONFIG.ShowPerformanceStats then
                        local ramSaved = performanceStats.initialRAM - performanceStats.currentRAM
                        print("🧠 RAM: " .. math.floor(performanceStats.currentRAM) .. " MB (saved: " .. math.floor(ramSaved) .. " MB)")
                    end
                end)
            end
        end)
        logOptimization("RAM cleaner activated")
    end
end

-- ========================================================
-- HIDE SYSTEM (IMPROVED - MORE AGGRESSIVE)
-- ========================================================

local function hideSystem()
    print("\n👻 HIDE SYSTEM (AGGRESSIVE MODE)")
    
    -- Hide Pets (More comprehensive detection)
    if CONFIG.HidePets then
        logOptimization("Hiding pets (aggressive scan)...")
        
        -- Method 1: Direct workspace scan
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                local objName = obj.Name:lower()
                local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                
                -- Broader pet detection
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    if objName:find("pet") or objName:find("companion") or objName:find("follow") or
                       objName:find("buddy") or objName:find("helper") or objName:find("sidekick") or
                       parentName:find("pet") or parentName:find("companion") or 
                       (obj:FindFirstChild("Humanoid") and objName ~= game.Players.LocalPlayer.Name:lower()) then
                        
                        -- Hide the object and all its descendants
                        local function hideRecursive(item)
                            for _, child in pairs(item:GetChildren()) do
                                if child:IsA("BasePart") then
                                    child.Transparency = 1
                                    child.CanCollide = false
                                    child.CastShadow = false
                                    child.CanTouch = false
                                elseif child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
                                    child.Enabled = false
                                elseif child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                                    child.Enabled = false
                                elseif child:IsA("Sound") or child:IsA("Music") then
                                    child.Volume = 0
                                end
                                hideRecursive(child)
                            end
                        end
                        
                        hideRecursive(obj)
                        hiddenCount.pets = hiddenCount.pets + 1
                    end
                end
            end)
        end
        
        -- Method 2: Player-specific pet scan
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, obj in pairs(player.Character:GetChildren()) do
                    pcall(function()
                        local objName = obj.Name:lower()
                        if obj:IsA("Model") and (objName:find("pet") or objName:find("companion")) then
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                    part.CanCollide = false
                                    part.CastShadow = false
                                end
                            end
                            hiddenCount.pets = hiddenCount.pets + 1
                        end
                    end)
                end
            end
        end
        
        logOptimization("Pets hidden: " .. hiddenCount.pets)
    end
    
    -- Hide Eggs (More comprehensive detection)
    if CONFIG.HideEggs then
        logOptimization("Hiding eggs (aggressive scan)...")
        
        -- Method 1: AreaEggSlotsClient
        local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
        if areaEggs then
            for _, eggModel in pairs(areaEggs:GetChildren()) do
                pcall(function()
                    if eggModel:IsA("Model") then
                        for _, part in pairs(eggModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local partName = part.Name:lower()
                                -- More specific hitbox preservation
                                if partName:find("hitbox") or partName:find("hit") or 
                                   partName:find("touch") or partName:find("detect") then
                                    part.Transparency = 1 -- Keep invisible but functional
                                    part.Material = Enum.Material.ForceField
                                else
                                    part.Transparency = 1
                                    part.CanCollide = false
                                    part.CastShadow = false
                                    part.Material = Enum.Material.Air
                                end
                            elseif part:IsA("SpecialMesh") then
                                part.Scale = Vector3.new(0, 0, 0)
                            elseif part:IsA("Decal") or part:IsA("Texture") then
                                part.Transparency = 1
                            elseif part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Trail") then
                                part.Enabled = false
                            elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
                                part.Enabled = false
                            end
                        end
                        hiddenCount.eggs = hiddenCount.eggs + 1
                    end
                end)
            end
        end
        
        -- Method 2: Direct egg scan in workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                local objName = obj.Name:lower()
                if obj:IsA("Model") and (objName:find("egg") and not objName:find("eggslot")) then
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local partName = part.Name:lower()
                            if not (partName:find("hitbox") or partName:find("hit")) then
                                part.Transparency = 1
                                part.CanCollide = false
                                part.CastShadow = false
                            end
                        end
                    end
                    hiddenCount.eggs = hiddenCount.eggs + 1
                end
            end)
        end
        
        logOptimization("Eggs hidden: " .. hiddenCount.eggs .. " (hitboxes preserved)")
    end
    
    -- Hide Other Players (More thorough)
    if CONFIG.HideOtherPlayers then
        logOptimization("Hiding other players...")
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                pcall(function()
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.Transparency = 1
                            part.CastShadow = false
                            hiddenCount.players = hiddenCount.players + 1
                        elseif part:IsA("Accessory") then
                            for _, accessoryPart in pairs(part:GetDescendants()) do
                                if accessoryPart:IsA("BasePart") then
                                    accessoryPart.Transparency = 1
                                end
                            end
                        end
                    end
                end)
            end
        end
        logOptimization("Players hidden: " .. hiddenCount.players)
    end
    
    -- Hide Player Names (More comprehensive)
    if CONFIG.HidePlayerNames then
        logOptimization("Hiding player names...")
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BillboardGui") then
                    local parent = obj.Parent
                    -- Hide all player-related BillboardGuis
                    if parent and (parent.Parent and Players:GetPlayerFromCharacter(parent.Parent) or
                                  obj.Name:lower():find("name") or obj.Name:lower():find("tag") or
                                  obj.Name:lower():find("label")) then
                        obj.Enabled = false
                    end
                end
            end)
        end
        logOptimization("Player names hidden")
    end
    
    -- Black Screen
    if CONFIG.ShowBlackScreen then
        logOptimization("Activating black screen...")
        local blackScreen = Instance.new("ScreenGui")
        blackScreen.Name = "BlackScreenOptimizer"
        blackScreen.DisplayOrder = 999999
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BorderSizePixel = 0
        frame.Parent = blackScreen
        
        pcall(function()
            blackScreen.Parent = LocalPlayer.PlayerGui
        end)
        
        logOptimization("Black screen activated - MAXIMUM FPS!")
    end
    
    -- Auto-hide new objects
    task.spawn(function()
        while task.wait(3) do -- Check every 3 seconds for new objects
            if CONFIG.HidePets or CONFIG.HideEggs then
                pcall(function()
                    -- Hide new pets
                    if CONFIG.HidePets then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            local objName = obj.Name:lower()
                            if obj:IsA("Model") and objName:find("pet") then
                                for _, part in pairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.Transparency = 1
                                        part.CanCollide = false
                                        part.CastShadow = false
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Hide new eggs
                    if CONFIG.HideEggs then
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
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- ========================================================
-- PERFORMANCE GUI
-- ========================================================

local function createPerformanceGUI()
    if not CONFIG.ShowPerformanceStats then return end
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "StealEggOptimizer"
    gui.ResetOnSpawn = false
    
    pcall(function()
        gui.Parent = LocalPlayer.PlayerGui
    end)
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 240)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🥚 STEAL EGG OPTIMIZER V2"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- FPS Label
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, -10, 0, 20)
    fpsLabel.Position = UDim2.new(0, 5, 0, 35)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.TextSize = 14
    fpsLabel.Font = Enum.Font.SourceSans
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = frame
    
    -- RAM Label
    local ramLabel = Instance.new("TextLabel")
    ramLabel.Size = UDim2.new(1, -10, 0, 20)
    ramLabel.Position = UDim2.new(0, 5, 0, 55)
    ramLabel.BackgroundTransparency = 1
    ramLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    ramLabel.TextSize = 14
    ramLabel.Font = Enum.Font.SourceSans
    ramLabel.TextXAlignment = Enum.TextXAlignment.Left
    ramLabel.Parent = frame
    
    -- Optimization Label
    local optimizationLabel = Instance.new("TextLabel")
    optimizationLabel.Size = UDim2.new(1, -10, 0, 60)
    optimizationLabel.Position = UDim2.new(0, 5, 0, 80)
    optimizationLabel.BackgroundTransparency = 1
    optimizationLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    optimizationLabel.TextSize = 12
    optimizationLabel.Font = Enum.Font.SourceSans
    optimizationLabel.TextXAlignment = Enum.TextXAlignment.Left
    optimizationLabel.TextWrapped = true
    optimizationLabel.Parent = frame
    
    -- Hide Label
    local hideLabel = Instance.new("TextLabel")
    hideLabel.Size = UDim2.new(1, -10, 0, 40)
    hideLabel.Position = UDim2.new(0, 5, 0, 145)
    hideLabel.BackgroundTransparency = 1
    hideLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
    hideLabel.TextSize = 12
    hideLabel.Font = Enum.Font.SourceSans
    hideLabel.TextXAlignment = Enum.TextXAlignment.Left
    hideLabel.TextWrapped = true
    hideLabel.Parent = frame
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 0, 40)
    statusLabel.Position = UDim2.new(0, 5, 0, 190)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextWrapped = true
    statusLabel.Parent = frame
    
    -- Update loop
    task.spawn(function()
        while gui.Parent do
            pcall(function()
                performanceStats.currentFPS = getCurrentFPS()
                performanceStats.currentRAM = getMemoryUsage()
                
                local runTime = tick() - performanceStats.startTime
                local fpsImprovement = performanceStats.currentFPS - performanceStats.initialFPS
                local ramSaved = performanceStats.initialRAM - performanceStats.currentRAM
                
                fpsLabel.Text = string.format("⚡ FPS: %d (+%d)", performanceStats.currentFPS, fpsImprovement)
                ramLabel.Text = string.format("🧠 RAM: %d MB (-%d MB)", math.floor(performanceStats.currentRAM), math.floor(ramSaved))
                optimizationLabel.Text = string.format("🔧 Objects: %d | Effects: %d", performanceStats.objectsRemoved, performanceStats.effectsDisabled)
                hideLabel.Text = string.format("👻 Pets: %d | Eggs: %d | Players: %d", hiddenCount.pets, hiddenCount.eggs, hiddenCount.players)
                statusLabel.Text = "✅ Optimization Active\n🥚 Ready to Steal Eggs!"
                
                -- FPS color coding
                if performanceStats.currentFPS >= 60 then
                    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif performanceStats.currentFPS >= 30 then
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
                
                -- RAM color coding
                if ramSaved > 50 then
                    ramLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif ramSaved > 0 then
                    ramLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
                else
                    ramLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                end
            end)
            
            task.wait(1)
        end
    end)
    
    logOptimization("Performance GUI created")
end

-- ========================================================
-- MAIN EXECUTION
-- ========================================================

local function main()
    print("🚀 Starting optimization...")
    
    -- Execute all optimizations
    setupFPSOptimization()
    optimizeGraphics()
    optimizeEggGame()
    optimizeMemory()
    hideSystem()
    createPerformanceGUI()
    
    -- Final results
    task.wait(2)
    performanceStats.currentFPS = getCurrentFPS()
    performanceStats.currentRAM = getMemoryUsage()
    
    local fpsImprovement = performanceStats.currentFPS - performanceStats.initialFPS
    local ramSaved = performanceStats.initialRAM - performanceStats.currentRAM
    
    print("\n✅ OPTIMIZATION COMPLETE!")
    print("==========================================")
    print("⚡ FPS: " .. performanceStats.initialFPS .. " → " .. performanceStats.currentFPS .. " (+" .. fpsImprovement .. ")")
    print("🧠 RAM: " .. math.floor(performanceStats.initialRAM) .. " MB → " .. math.floor(performanceStats.currentRAM) .. " MB (-" .. math.floor(ramSaved) .. " MB)")
    print("🔧 Objects optimized: " .. performanceStats.objectsRemoved)
    print("✨ Effects disabled: " .. performanceStats.effectsDisabled)
    print("👻 Hidden - Pets: " .. hiddenCount.pets .. " | Eggs: " .. hiddenCount.eggs .. " | Players: " .. hiddenCount.players)
    print("==========================================")
    print("🥚 Ready to steal eggs with maximum performance!")
    
    if CONFIG.HideEggs then
        print("✅ Egg hitboxes preserved - stealing still works!")
    end
    
    if fpsImprovement > 20 then
        print("🎉 EXCELLENT FPS IMPROVEMENT!")
    elseif fpsImprovement > 0 then
        print("✅ FPS improved successfully!")
    end
    
    if ramSaved > 50 then
        print("🎉 SIGNIFICANT RAM SAVED!")
    elseif ramSaved > 0 then
        print("✅ RAM usage optimized!")
    end
end

-- ========================================================
-- ERROR HANDLING & EXECUTION
-- ========================================================

local success, error = pcall(main)
if not success then
    warn("❌ Optimization error: " .. tostring(error))
    print("🔄 Retrying with safe mode...")
    
    pcall(function()
        setupFPSOptimization()
        optimizeGraphics()
        createPerformanceGUI()
        print("✅ Safe mode optimization complete!")
    end)
end

-- Keep running
print("\n🔄 Optimizer running continuously...")
print("📊 Check performance GUI for live stats!")

-- Cleanup on respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    task.wait(2)
    print("🔄 Character respawned - reapplying optimizations...")
    pcall(function()
        optimizeMemory()
        hideSystem()
        logOptimization("Optimizations reapplied after respawn")
    end)
end)