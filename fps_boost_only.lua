-- ========================================================
-- ROBLOX FPS BOOSTER - STEAL AN EGG OPTIMIZED
-- Pure FPS Optimization (No Stealing Features)
-- Target: 5-15 FPS + Minimal CPU/RAM Usage
-- ========================================================

local CONFIG = {
    TargetFPS = 10,             -- Target FPS (2-15 recommended)
    ShowBlackOverlay = true,    -- Hide game visuals, show stats only
    ShowPerformanceStats = true, -- Display FPS/RAM info
    
    -- Ultra Optimizations
    DisableRendering = true,    -- Disable 3D rendering completely
    DisableAnimations = true,   -- Stop all animations
    DisableSounds = true,       -- Mute all sounds
    DisableParticles = true,    -- Remove particles/effects
    DisableLighting = true,     -- Simplify lighting
    
    -- Character Optimizations
    MakeInvisible = true,       -- Make character transparent
    RemoveAccessories = true,   -- Remove hats/clothes
    DisableCollisions = true,   -- Disable character collisions
    FreezeCamera = true,        -- Lock camera position
    
    -- World Cleanup
    CleanWorkspace = true,      -- Remove unnecessary objects
    AggressiveCleanup = true,   -- More aggressive object removal
    
    -- RAM Management
    AutoCleanRAM = true,        -- Auto garbage collection
    RAMCleanInterval = 5,       -- Clean RAM every X seconds
}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

print("🚀 Loading FPS Booster...")
task.wait(2)

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
-- ========================================================
-- 1. CORE ENGINE OPTIMIZATIONS
-- ========================================================

-- Disable 3D Rendering
if CONFIG.DisableRendering then
    pcall(function()
        RunService:Set3dRenderingEnabled(false)
        print("✅ 3D Rendering disabled")
    end)
end

-- Force lowest graphics quality
pcall(function()
    local UserGameSettings = UserSettings():GetService("UserGameSettings")
    UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.Level01
    UserGameSettings.GraphicsQualityLevel = 1
    UserGameSettings.MasterVolume = CONFIG.DisableSounds and 0 or 0.1
    print("✅ Graphics set to minimum quality")
end)

-- Disable Core GUI elements
pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    print("✅ Core GUI disabled")
end)

-- ========================================================
-- 2. LIGHTING & VISUAL OPTIMIZATIONS
-- ========================================================

if CONFIG.DisableLighting then
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.Brightness = 0.5
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
        
        -- Remove lighting effects
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or 
               effect:IsA("BloomEffect") or
               effect:IsA("BlurEffect") or
               effect:IsA("ColorCorrectionEffect") or
               effect:IsA("SunRaysEffect") then
                effect:Destroy()
            end
        end
        print("✅ Lighting optimized")
    end)
end
-- ========================================================
-- 3. CHARACTER OPTIMIZATIONS
-- ========================================================

-- Make character invisible
if CONFIG.MakeInvisible then
    task.spawn(function()
        pcall(function()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 1
                end
            end
            print("✅ Character made invisible")
        end)
    end)
end

-- Remove accessories
if CONFIG.RemoveAccessories then
    task.spawn(function()
        pcall(function()
            for _, accessory in pairs(character:GetChildren()) do
                if accessory:IsA("Accessory") or accessory:IsA("Hat") then
                    accessory:Destroy()
                end
            end
            print("✅ Accessories removed")
        end)
    end)
end

-- Disable animations
if CONFIG.DisableAnimations then
    task.spawn(function()
        pcall(function()
            -- Stop all current animations
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
                track:Destroy()
            end
            
            -- Block new animations
            humanoid.AnimationPlayed:Connect(function(track)
                track:Stop()
            end)
            
            -- Remove animator
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                animator:Destroy()
            end
            
            print("✅ Animations disabled")
        end)
    end)
end

-- Disable collisions
if CONFIG.DisableCollisions then
    task.spawn(function()
        pcall(function()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            print("✅ Character collisions disabled")
        end)
    end)
end
-- Freeze camera
if CONFIG.FreezeCamera then
    task.spawn(function()
        pcall(function()
            local camera = Workspace.CurrentCamera
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.new(0, 10000, 0) -- Move camera far away
            print("✅ Camera frozen")
        end)
    end)
end

-- ========================================================
-- 4. WORLD CLEANUP & OPTIMIZATION
-- ========================================================

-- Clean workspace objects
if CONFIG.CleanWorkspace then
    task.spawn(function()
        print("🧹 Starting workspace cleanup...")
        
        local keepObjects = {
            "Camera", "CurrentCamera", "Terrain",
            "AreaEggSlotsClient", -- Keep egg containers for game functionality
        }
        
        local objectsRemoved = 0
        
        for _, child in pairs(Workspace:GetChildren()) do
            pcall(function()
                local shouldKeep = false
                
                -- Keep player characters
                if Players:GetPlayerFromCharacter(child) then
                    shouldKeep = true
                end
                
                -- Keep essential objects
                for _, essential in pairs(keepObjects) do
                    if child.Name == essential then
                        shouldKeep = true
                        break
                    end
                end
                
                -- Keep objects with "egg" in name (important for game)
                if child.Name:lower():find("egg") then
                    shouldKeep = true
                end
                
                if not shouldKeep then
                    child:Destroy()
                    objectsRemoved = objectsRemoved + 1
                end
            end)
            
            -- Small delay to prevent lag
            if objectsRemoved % 20 == 0 then
                task.wait(0.01)
            end
        end
        
        print("✅ Removed " .. objectsRemoved .. " workspace objects")
    end)
end
-- Clean particles, sounds, and effects
if CONFIG.DisableParticles or CONFIG.DisableSounds then
    task.spawn(function()
        local effectsRemoved = 0
        local descendants = Workspace:GetDescendants()
        
        for i, obj in pairs(descendants) do
            pcall(function()
                if CONFIG.DisableParticles and (
                    obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
                    obj:IsA("Beam") or obj:IsA("Smoke") or 
                    obj:IsA("Fire") or obj:IsA("Sparkles") or
                    obj:IsA("Explosion")) then
                    obj:Destroy()
                    effectsRemoved = effectsRemoved + 1
                elseif CONFIG.DisableSounds and obj:IsA("Sound") then
                    obj:Stop()
                    obj:Destroy()
                    effectsRemoved = effectsRemoved + 1
                end
            end)
            
            -- Prevent lag with large loops
            if i % 100 == 0 then
                task.wait(0.01)
            end
        end
        
        print("✅ Removed " .. effectsRemoved .. " effects/sounds")
    end)
end

-- Aggressive cleanup (textures, decals, etc.)
if CONFIG.AggressiveCleanup then
    task.spawn(function()
        local texturesRemoved = 0
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceGui") then
                    -- Don't remove if it's part of player character
                    if not obj:IsDescendantOf(character) then
                        obj:Destroy()
                        texturesRemoved = texturesRemoved + 1
                    end
                elseif obj:IsA("BasePart") and not obj:IsDescendantOf(character) then
                    -- Optimize remaining parts
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                end
            end)
        end
        
        print("✅ Aggressive cleanup: " .. texturesRemoved .. " textures removed")
    end)
end
-- ========================================================
-- 5. FPS LIMITER & UI SYSTEM
-- ========================================================

local TARGET_FPS = CONFIG.TargetFPS
local FRAME_TIME = 1 / TARGET_FPS
local lastFrame = os.clock()

-- UI Elements for performance monitoring
local fpsLabel, ramLabel, statusLabel, timerLabel
local startTime = os.time()

if CONFIG.ShowBlackOverlay and CONFIG.ShowPerformanceStats then
    pcall(function()
        local parentGui = gethui and gethui() or game:GetService("CoreGui")
        if not pcall(function() local t = parentGui.Name end) then
            parentGui = LocalPlayer:WaitForChild("PlayerGui")
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FPSBoosterUI"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 2147483647
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = parentGui

        -- Black background overlay
        local background = Instance.new("Frame")
        background.Size = UDim2.new(1, 0, 1, 0)
        background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        background.BorderSizePixel = 0
        background.Parent = screenGui

        -- Performance info panel
        local infoPanel = Instance.new("Frame")
        infoPanel.Size = UDim2.new(0, 280, 0, 100)
        infoPanel.Position = UDim2.new(0, 10, 0, 10)
        infoPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        infoPanel.BackgroundTransparency = 0.1
        infoPanel.BorderSizePixel = 0
        infoPanel.Parent = screenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = infoPanel

        -- FPS Label
        fpsLabel = Instance.new("TextLabel")
        fpsLabel.Size = UDim2.new(1, -10, 0, 20)
        fpsLabel.Position = UDim2.new(0, 5, 0, 5)
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        fpsLabel.TextSize = 14
        fpsLabel.Font = Enum.Font.RobotoMono
        fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
        fpsLabel.Text = "FPS: " .. TARGET_FPS .. " (Target)"
        fpsLabel.Parent = infoPanel
        -- RAM Label
        ramLabel = Instance.new("TextLabel")
        ramLabel.Size = UDim2.new(1, -10, 0, 20)
        ramLabel.Position = UDim2.new(0, 5, 0, 25)
        ramLabel.BackgroundTransparency = 1
        ramLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        ramLabel.TextSize = 14
        ramLabel.Font = Enum.Font.RobotoMono
        ramLabel.TextXAlignment = Enum.TextXAlignment.Left
        ramLabel.Text = "RAM: Calculating..."
        ramLabel.Parent = infoPanel

        -- Status Label
        statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -10, 0, 20)
        statusLabel.Position = UDim2.new(0, 5, 0, 45)
        statusLabel.BackgroundTransparency = 1
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        statusLabel.TextSize = 14
        statusLabel.Font = Enum.Font.RobotoMono
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Text = "Status: Optimizing..."
        statusLabel.Parent = infoPanel

        -- Timer Label
        timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(1, -10, 0, 20)
        timerLabel.Position = UDim2.new(0, 5, 0, 65)
        timerLabel.BackgroundTransparency = 1
        timerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        timerLabel.TextSize = 14
        timerLabel.Font = Enum.Font.RobotoMono
        timerLabel.TextXAlignment = Enum.TextXAlignment.Left
        timerLabel.Text = "Runtime: 00:00:00"
        timerLabel.Parent = infoPanel

        print("✅ Performance UI created")
    end)
elseif CONFIG.ShowBlackOverlay then
    -- Just black overlay without stats
    pcall(function()
        local parentGui = gethui and gethui() or game:GetService("CoreGui")
        if not pcall(function() local t = parentGui.Name end) then
            parentGui = LocalPlayer:WaitForChild("PlayerGui")
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BlackOverlay"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 2147483647
        screenGui.Parent = parentGui

        local background = Instance.new("Frame")
        background.Size = UDim2.new(1, 0, 1, 0)
        background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        background.BorderSizePixel = 0
        background.Parent = screenGui
        
        print("✅ Black overlay enabled")
    end)
end
-- ========================================================
-- 6. FPS LIMITER & PERFORMANCE MONITORING
-- ========================================================

local lastFpsUpdate = os.clock()
local frameCount = 0

-- Helper function to format time
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- Helper function to format numbers
local function formatNumber(num)
    return tostring(math.floor(num)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Main FPS limiter and UI update loop
RunService.PreRender:Connect(function()
    local now = os.clock()
    local delta = now - lastFrame
    
    -- FPS Limiter: Hold frame until target frame time is reached
    if delta < FRAME_TIME then
        local waitUntil = now + (FRAME_TIME - delta)
        while os.clock() < waitUntil do
            -- Hold the frame
        end
    end
    
    lastFrame = os.clock()
    frameCount = frameCount + 1
    
    -- Update UI every 0.5 seconds
    if CONFIG.ShowPerformanceStats and (now - lastFpsUpdate >= 0.5) then
        pcall(function()
            if fpsLabel then
                local currentFps = math.floor(frameCount / (now - lastFpsUpdate))
                fpsLabel.Text = "FPS: " .. currentFps .. " / " .. TARGET_FPS .. " (Target)"
                
                -- Color coding for FPS
                if currentFps >= TARGET_FPS * 0.8 then
                    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 100) -- Green
                elseif currentFps >= TARGET_FPS * 0.5 then
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0) -- Yellow
                else
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red
                end
            end
            
            if ramLabel then
                local memoryMB = Stats:GetTotalMemoryUsageMb()
                ramLabel.Text = "RAM: " .. formatNumber(memoryMB) .. " MB"
                
                -- Color coding for RAM usage
                if memoryMB < 150 then
                    ramLabel.TextColor3 = Color3.fromRGB(0, 255, 100) -- Green
                elseif memoryMB < 250 then
                    ramLabel.TextColor3 = Color3.fromRGB(255, 200, 0) -- Yellow
                else
                    ramLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red
                end
            end
            
            if statusLabel then
                statusLabel.Text = "Status: FPS Boost Active"
            end
            
            if timerLabel then
                local runtime = os.time() - startTime
                timerLabel.Text = "Runtime: " .. formatTime(runtime)
            end
        end)
        
        frameCount = 0
        lastFpsUpdate = now
    end
end)
-- ========================================================
-- 7. AUTO RAM CLEANER
-- ========================================================

if CONFIG.AutoCleanRAM then
    task.spawn(function()
        print("🗑️ Auto RAM cleaner started (every " .. CONFIG.RAMCleanInterval .. "s)")
        
        while task.wait(CONFIG.RAMCleanInterval) do
            pcall(function()
                -- Force garbage collection
                collectgarbage("collect")
                
                -- Additional cleanup for new objects that might have spawned
                if CONFIG.DisableParticles or CONFIG.DisableSounds then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        pcall(function()
                            if CONFIG.DisableParticles and (
                                obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
                                obj:IsA("Beam") or obj:IsA("Smoke") or 
                                obj:IsA("Fire") or obj:IsA("Sparkles")) then
                                obj:Destroy()
                            elseif CONFIG.DisableSounds and obj:IsA("Sound") and obj.IsPlaying then
                                obj:Stop()
                                obj:Destroy()
                            end
                        end)
                    end
                end
            end)
        end
    end)
end

-- ========================================================
-- 8. CHARACTER RESPAWN HANDLER
-- ========================================================

-- Reapply optimizations when character respawns
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.wait(2) -- Wait for character to fully load
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    hrp = newCharacter:WaitForChild("HumanoidRootPart")
    
    print("🔄 Character respawned - reapplying optimizations...")
    
    -- Reapply character optimizations
    if CONFIG.MakeInvisible then
        task.spawn(function()
            pcall(function()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                    end
                end
            end)
        end)
    end
    
    if CONFIG.RemoveAccessories then
        task.spawn(function()
            pcall(function()
                for _, accessory in pairs(character:GetChildren()) do
                    if accessory:IsA("Accessory") then
                        accessory:Destroy()
                    end
                end
            end)
        end)
    end
    
    if CONFIG.DisableAnimations then
        task.spawn(function()
            pcall(function()
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then animator:Destroy() end
            end)
        end)
    end
    
    if CONFIG.DisableCollisions then
        task.spawn(function()
            pcall(function()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end)
    end
end)
-- ========================================================
-- 9. FINAL CLEANUP & STATUS
-- ========================================================

-- Final garbage collection
task.spawn(function()
    task.wait(5)
    pcall(function()
        collectgarbage("collect")
    end)
end)

-- Anti-fall platform (optional safety feature)
task.spawn(function()
    pcall(function()
        local platform = Instance.new("Part")
        platform.Name = "FPSBoostPlatform"
        platform.Size = Vector3.new(1000, 1, 1000)
        platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 10, hrp.Position.Z)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0.9
        platform.Color = Color3.fromRGB(100, 100, 100)
        platform.Material = Enum.Material.SmoothPlastic
        platform.Parent = Workspace
        
        print("🛡️ Anti-fall platform created")
    end)
end)

-- Status reporting
task.spawn(function()
    task.wait(8) -- Wait for all optimizations to complete
    
    print("\n" .. string.rep("=", 50))
    print("🎯 FPS BOOSTER - OPTIMIZATION COMPLETE!")
    print(string.rep("=", 50))
    print("✅ Target FPS: " .. CONFIG.TargetFPS)
    print("✅ 3D Rendering: " .. (CONFIG.DisableRendering and "DISABLED" or "ENABLED"))
    print("✅ Animations: " .. (CONFIG.DisableAnimations and "DISABLED" or "ENABLED"))
    print("✅ Sounds: " .. (CONFIG.DisableSounds and "DISABLED" or "ENABLED"))
    print("✅ Particles: " .. (CONFIG.DisableParticles and "DISABLED" or "ENABLED"))
    print("✅ Character: " .. (CONFIG.MakeInvisible and "INVISIBLE" or "VISIBLE"))
    print("✅ Workspace: " .. (CONFIG.CleanWorkspace and "CLEANED" or "UNCHANGED"))
    print("✅ RAM Cleaner: " .. (CONFIG.AutoCleanRAM and "ACTIVE" or "DISABLED"))
    
    if CONFIG.ShowPerformanceStats then
        print("📊 Performance stats visible on screen")
    end
    
    print("\n💡 Tips:")
    print("   - Use other steal scripts separately if needed")
    print("   - Adjust CONFIG.TargetFPS (2-15) for different performance")
    print("   - Lower FPS = better performance but choppier movement")
    print(string.rep("=", 50) .. "\n")
    
    -- Update status in UI
    if statusLabel then
        statusLabel.Text = "Status: Optimization Complete ✅"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end)

print("🚀 FPS Booster loaded! Optimizations running...")
print("⏱️ Full optimization will complete in ~8 seconds")