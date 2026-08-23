-- ========================================================
-- ROBLOX OPTIMIZATION SCRIPT V5 (EXTREME RAM REDUCTION)
-- With GitHub Auto-Sell + 10 Ultra Optimizations
-- Target: 98-108 MB RAM (down from 200 MB)
-- ========================================================
-- 0. JEDA SINGKAT (3 DETIK)
-- ========================================================
task.wait(3)

local CONFIG = {
    TargetFPS              = 60,     
    ShowBlackOverlay      = false,  
    ExtremeDestroy        = true,  -- Destroy objects completely (dangerous for steal scripts)
    HideExtreme           = false,   -- NEW: Hide objects instead of destroy (safe for steal scripts)
    AntiFallPlatform      = true,  
    DisableGameSounds     = true,  
    DisableParticles      = true,  
    DisableLightingEffects= true,  
    Disable3DRendering    = false,  
    DisableCoreGui        = false,  
    AutoCleanRAM          = true,  
    CleanRAMInterval      = 10,    -- Changed from 15 to 10 for more aggressive GC
    
    -- NEW FEATURES (v4 - Ultra RAM Reduction)
    DisableAnimations     = true,  -- Stop all character animations
    RemoveAccessories     = true,  -- Remove all character accessories (hats, clothes)
    FreezeCamera          = false,  -- Freeze camera position
    DisableCollisions     = true,  -- Disable character collisions
    
    -- EXTRA FEATURES (v5 - Extreme RAM Reduction)
    BodyTransparency      = false,  -- Make character invisible (transparency = 1)
    DisableHealthDisplay  = true,  -- Hide health bar & name display
    DisableHumanoidStates = true,  -- Disable unused humanoid states (swimming, climbing, etc)
    RemoveAnimator        = true,  -- Remove animator object (more aggressive than DisableAnimations)
    ForceMobileMode       = true   -- Force mobile rendering mode (lower quality)
}

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
-- HELPER FUNCTIONS
-- ========================================================

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function formatNumber(n)
    local num = tostring(n)
    return num:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function getSheckles()
    if LocalPlayer then
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            local money = leaderstats:FindFirstChild("Sheckles") 
                or leaderstats:FindFirstChild("Sheckel") 
                or leaderstats:FindFirstChild("Money") 
                or leaderstats:FindFirstChild("Coins")
            if money then return money.Value end
        end
        local dataFolder = LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("PlayerData")
        if dataFolder then
            local money = dataFolder:FindFirstChild("Sheckles") or dataFolder:FindFirstChild("Sheckel")
            if money then return money.Value end
        end
    end
    return 0
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- ========================================================
-- HELPER: CEK STATUS DAILY DEALS (IMPROVED - v2)
-- ========================================================
local function checkDailyDeals()
    local isReady = false
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data") 
            or LocalPlayer:FindFirstChild("PlayerData") 
            or LocalPlayer:FindFirstChild("leaderstats")

        if data then
            local daily = data:FindFirstChild("DailyDeals") 
                or data:FindFirstChild("DailyClaimed") 
                or data:FindFirstChild("DailyReward") 
                or data:FindFirstChild("Daily")
            
            if daily and daily:IsA("BoolValue") then
                if daily.Value then
                    isReady = false
                    return
                else
                    isReady = true
                    return
                end
            end
        end

        local shopData = ReplicatedStorage:FindFirstChild("ShopData") 
            or ReplicatedStorage:FindFirstChild("DailyDeals") 
            or ReplicatedStorage:FindFirstChild("DailyShop")

        if shopData then
            local resetTime = shopData:FindFirstChild("ResetTime") or shopData:FindFirstChild("Cooldown")
            if resetTime then
                if resetTime.Value <= 0 then
                    isReady = true
                    return
                else
                    isReady = false
                    return
                end
            end
        end
    end)
    return isReady
end

-- ========================================================
-- FUNGSI LOGIKA SELL BUAH (GitHub Method)
-- ========================================================
local Networking = nil
pcall(function()
    Networking = require(ReplicatedStorage.SharedModules.Networking)
end)

local function sellFruits()
    local success = false

    if Networking and Networking.NPCS and Networking.NPCS.SellAll then
        pcall(function()
            Networking.NPCS.SellAll:Fire()
            success = true
        end)
        if success then return end
    end

    pcall(function()
        local sellRemote = ReplicatedStorage:FindFirstChild("Sell", true) 
            or ReplicatedStorage:FindFirstChild("SellFruit", true)
            or ReplicatedStorage:FindFirstChild("SellFruits", true)
            or ReplicatedStorage:FindFirstChild("SellAll", true)

        if sellRemote then
            if sellRemote:IsA("RemoteEvent") then
                sellRemote:FireServer()
                success = true
            elseif sellRemote:IsA("RemoteFunction") then
                sellRemote:InvokeServer()
                success = true
            end
        end
    end)

    if success then return end

    pcall(function()
        local char = getCharacter()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") and char then
                    item.Parent = char
                    task.wait(0.1)
                    
                    local toolRemote = item:FindFirstChildOfClass("RemoteEvent") 
                        or item:FindFirstChildOfClass("RemoteFunction")
                    
                    if toolRemote then
                        if toolRemote:IsA("RemoteEvent") then
                            toolRemote:FireServer()
                        elseif toolRemote:IsA("RemoteFunction") then
                            toolRemote:InvokeServer()
                        end
                    end
                end
            end
        end
    end)
end

-- ========================================================
-- SKIP TUTORIAL FUNCTION (ALL METHODS)
-- Auto-run every 5 minutes
-- ========================================================
local function skipTutorial()
    -- Method 1: Fire RemoteEvent
    task.spawn(function()
        pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local name = remote.Name:lower()
                    if name:find("skip") or name:find("tutorial") or name:find("complete") then
                        remote:FireServer()
                        remote:FireServer(true)
                        remote:FireServer("skip")
                        return
                    end
                elseif remote:IsA("RemoteFunction") then
                    local name = remote.Name:lower()
                    if name:find("skip") or name:find("tutorial") or name:find("complete") then
                        pcall(function()
                            remote:InvokeServer()
                            remote:InvokeServer(true)
                        end)
                        return
                    end
                end
            end
        end)
    end)
    
    -- Method 2: Set tutorial flags
    task.spawn(function()
        pcall(function()
            local data = LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("PlayerData")
            if data then
                for _, flag in pairs(data:GetChildren()) do
                    local name = flag.Name:lower()
                    if name:find("tutorial") or name:find("intro") or name:find("first") then
                        if flag:IsA("BoolValue") then
                            flag.Value = true
                            return
                        elseif flag:IsA("IntValue") or flag:IsA("NumberValue") then
                            flag.Value = 1
                            return
                        end
                    end
                end
            end
        end)
    end)
    
    -- Method 3: Remove tutorial GUIs
    task.spawn(function()
        pcall(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            for _, gui in pairs(playerGui:GetChildren()) do
                local name = gui.Name:lower()
                if name:find("tutorial") or name:find("intro") or name:find("guide") or name:find("cutscene") then
                    gui:Destroy()
                    return
                end
            end
        end)
    end)
    
    -- Method 4: Click skip buttons
    task.spawn(function()
        task.wait(0.3)
        pcall(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            for _, button in pairs(playerGui:GetDescendants()) do
                if button:IsA("TextButton") or button:IsA("ImageButton") then
                    local text = (button.Text or button.Name or ""):lower()
                    if text:find("skip") or text:find("continue") or text:find("next") or 
                       text:find("close") or text:find("ok") or text:find("start") then
                        pcall(function()
                            for _, conn in pairs(getconnections(button.MouseButton1Click)) do
                                conn:Fire()
                            end
                        end)
                        return
                    end
                end
            end
        end)
    end)
    
    -- Method 5: Networking module
    task.spawn(function()
        pcall(function()
            if Networking then
                if Networking.Tutorial then
                    if Networking.Tutorial.Skip then 
                        Networking.Tutorial.Skip:Fire()
                        return
                    elseif Networking.Tutorial.Complete then 
                        Networking.Tutorial.Complete:Fire()
                        return
                    end
                end
                
                if Networking.Player then
                    if Networking.Player.SkipTutorial then 
                        Networking.Player.SkipTutorial:Fire()
                        return
                    end
                end
            end
        end)
    end)
    
    -- Method 6: Fire ProximityPrompt
    task.spawn(function()
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local name = obj.Name:lower()
                    if name:find("skip") or name:find("tutorial") then
                        fireproximityprompt(obj)
                        return
                    end
                end
            end
        end)
    end)
end

-- ========================================================
-- 1. PRE-OPTIMIZATION (ENGINE LEVEL)
-- ========================================================
pcall(function()
    if CONFIG.Disable3DRendering then
        RunService:Set3dRenderingEnabled(false)
    end

    if CONFIG.DisableGameSounds then
        UserSettings():GetService("UserGameSettings").MasterVolume = 0
    end

    -- Force Graphics Quality to Level 1 (Lowest)
    UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualityLevel.Level01

    if CONFIG.DisableCoreGui then
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    end
end)

-- ========================================================
-- 1.5. ULTRA RAM OPTIMIZATIONS (v4)
-- ========================================================

-- Feature 1: Disable All Character Animations
if CONFIG.DisableAnimations then
    task.spawn(function()
        pcall(function()
            local humanoid = Character:FindFirstChild("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                    track:Destroy()
                end
                humanoid.AnimationPlayed:Connect(function(track)
                    track:Stop()
                end)
            end
        end)
    end)
end

-- Feature 2: Remove All Character Accessories
if CONFIG.RemoveAccessories then
    task.spawn(function()
        pcall(function()
            for _, accessory in pairs(Character:GetChildren()) do
                if accessory:IsA("Accessory") then
                    accessory:Destroy()
                end
            end
        end)
    end)
end

-- Feature 3: Freeze Camera Position
if CONFIG.FreezeCamera then
    task.spawn(function()
        pcall(function()
            local camera = Workspace.CurrentCamera
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.new(0, 10000, 0)
        end)
    end)
end

-- Feature 4: Disable Character Collisions
if CONFIG.DisableCollisions then
    task.spawn(function()
        pcall(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end)
end

-- ========================================================
-- 1.6. EXTRA RAM OPTIMIZATIONS (v5 - EXTREME)
-- ========================================================

-- Feature 5: Body Transparency (Invisible Character)
if CONFIG.BodyTransparency then
    task.spawn(function()
        pcall(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 1
                end
            end
        end)
    end)
end

-- Feature 6: Disable Health & Name Display
if CONFIG.DisableHealthDisplay then
    task.spawn(function()
        pcall(function()
            local humanoid = Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.HealthDisplayDistance = 0
                humanoid.NameDisplayDistance = 0
            end
        end)
    end)
end

-- Feature 7: Disable Unused Humanoid States
if CONFIG.DisableHumanoidStates then
    task.spawn(function()
        pcall(function()
            local humanoid = Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end)
    end)
end

-- Feature 8: Remove Animator (More Aggressive)
if CONFIG.RemoveAnimator then
    task.spawn(function()
        pcall(function()
            local humanoid = Character:FindFirstChild("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    animator:Destroy()
                end
            end
        end)
    end)
end

-- Feature 9: Force Mobile Mode
if CONFIG.ForceMobileMode then
    task.spawn(function()
        pcall(function()
            local UserInputService = game:GetService("UserInputService")
            UserInputService.TouchEnabled = true
        end)
    end)
end

-- ========================================================
-- 2. FPS LIMITER (Manual Frame Timing)
-- ========================================================
local TARGET_FPS = CONFIG.TargetFPS
local FRAME_TIME = 1 / TARGET_FPS
local lastFrame = os.clock()

-- ========================================================
-- 3. BLACK OVERLAY UI
-- ========================================================
local fpsLabel, ramLabel, shecklesLabel, dailyDealsLabel, timerLabel
local startTime = os.time()

if CONFIG.ShowBlackOverlay then
    pcall(function()
        local parentGui = gethui and gethui() or game:GetService("CoreGui")
        if not pcall(function() local t = parentGui.Name end) then
            parentGui = LocalPlayer:WaitForChild("PlayerGui")
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BlackOverlayGui_Fixed"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 2147483647
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = parentGui

        local background = Instance.new("Frame")
        background.Size = UDim2.new(1, 0, 1, 0)
        background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        background.BorderSizePixel = 0
        background.Active = true
        background.Parent = screenGui

        local infoContainer = Instance.new("Frame")
        infoContainer.Size = UDim2.new(0, 250, 0, 98)  -- Reduced from 138 to 98 (removed button row)
        infoContainer.Position = UDim2.new(0, 10, 0, 10)
        infoContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        infoContainer.BackgroundTransparency = 0.3
        infoContainer.BorderSizePixel = 0
        infoContainer.Parent = screenGui

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = infoContainer

        -- 1. FPS + Player Name Label (Combined in one line)
        fpsLabel = Instance.new("TextLabel")
        fpsLabel.Size = UDim2.new(1, -10, 0, 18)
        fpsLabel.Position = UDim2.new(0, 5, 0, 3)
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        fpsLabel.TextSize = 12
        fpsLabel.Font = Enum.Font.Code
        fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
        fpsLabel.Text = "FPS : " .. TARGET_FPS .. " | " .. LocalPlayer.Name
        fpsLabel.Parent = infoContainer

        -- 2. RAM Label (Full width, no button)
        ramLabel = Instance.new("TextLabel")
        ramLabel.Size = UDim2.new(1, -10, 0, 18)
        ramLabel.Position = UDim2.new(0, 5, 0, 21)
        ramLabel.BackgroundTransparency = 1
        ramLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
        ramLabel.TextSize = 12
        ramLabel.Font = Enum.Font.Code
        ramLabel.TextXAlignment = Enum.TextXAlignment.Left
        ramLabel.Text = "RAM : Measuring..."
        ramLabel.Parent = infoContainer

        -- 3. Sheckles Label
        shecklesLabel = Instance.new("TextLabel")
        shecklesLabel.Size = UDim2.new(1, -10, 0, 18)
        shecklesLabel.Position = UDim2.new(0, 5, 0, 39)
        shecklesLabel.BackgroundTransparency = 1
        shecklesLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        shecklesLabel.TextSize = 12
        shecklesLabel.Font = Enum.Font.Code
        shecklesLabel.TextXAlignment = Enum.TextXAlignment.Left
        shecklesLabel.Text = "Sheckles : 0"
        shecklesLabel.Parent = infoContainer

        -- 4. Daily Deals Label
        dailyDealsLabel = Instance.new("TextLabel")
        dailyDealsLabel.Size = UDim2.new(1, -10, 0, 18)
        dailyDealsLabel.Position = UDim2.new(0, 5, 0, 57)
        dailyDealsLabel.BackgroundTransparency = 1
        dailyDealsLabel.TextSize = 12
        dailyDealsLabel.Font = Enum.Font.Code
        dailyDealsLabel.TextXAlignment = Enum.TextXAlignment.Left
        dailyDealsLabel.Text = "Daily Deals : Checking..."
        dailyDealsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        dailyDealsLabel.Parent = infoContainer

        -- 5. Timer Label
        timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(1, -10, 0, 18)
        timerLabel.Position = UDim2.new(0, 5, 0, 75)  -- Moved up from 107
        timerLabel.BackgroundTransparency = 1
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.TextSize = 12
        timerLabel.Font = Enum.Font.Code
        timerLabel.TextXAlignment = Enum.TextXAlignment.Left
        timerLabel.Text = "Time: 00:00:00"
        timerLabel.Parent = infoContainer
    end)
end

-- ========================================================
-- 4. FPS LIMITER & UI UPDATE LOOP (PreRender)
-- ========================================================
local lastFpsUpdate = os.clock()
local frameCount = 0

RunService.PreRender:Connect(function()
    local now = os.clock()
    local delta = now - lastFrame
    
    -- FPS Limiter: Hold frame until target frame time
    if delta < FRAME_TIME then
        local waitTill = now + (FRAME_TIME - delta)
        while os.clock() < waitTill do
            -- Hold Frame
        end
    end
    
    lastFrame = os.clock()
    frameCount = frameCount + 1
    
    -- UI Update: Every 0.5 seconds
    if CONFIG.ShowBlackOverlay and (now - lastFpsUpdate >= 0.5) then
        if fpsLabel then
            local currentFps = math.floor(frameCount / (now - lastFpsUpdate))
            fpsLabel.Text = "FPS : " .. currentFps .. " | " .. LocalPlayer.Name
        end
        
        if ramLabel then
            local memoryMB = math.floor(Stats:GetTotalMemoryUsageMb())
            ramLabel.Text = "RAM : " .. memoryMB .. " MB"
        end
        
        if shecklesLabel then 
            shecklesLabel.Text = "Sheckles : " .. formatNumber(getSheckles()) 
        end
        
        if dailyDealsLabel then
            local isReady = checkDailyDeals()
            if isReady then
                dailyDealsLabel.Text = "Daily Deals : READY"
                dailyDealsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                dailyDealsLabel.Text = "Daily Deals : NOT READY"
                dailyDealsLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
            end
        end

        if timerLabel then
            local elapsedTime = os.time() - startTime
            timerLabel.Text = "Time: " .. formatTime(elapsedTime)
        end
        
        frameCount = 0
        lastFpsUpdate = now
    end
end)

-- ========================================================
-- 5. AUTO RAM CLEANER
-- ========================================================
if CONFIG.AutoCleanRAM then
    task.spawn(function()
        while task.wait(CONFIG.CleanRAMInterval) do
            pcall(function() collectgarbage("collect") end)
        end
    end)
end

-- ========================================================
-- 6. ANTI-FALL PLATFORM (Y-LOCK VERSION)
-- ========================================================
if CONFIG.AntiFallPlatform then
    local function createPlatform()
        task.spawn(function()
            pcall(function()
                local hrp = Character and Character:WaitForChild("HumanoidRootPart", 5)
                local humanoid = Character and Character:FindFirstChild("Humanoid")
                if not hrp or not humanoid then return end

                local oldPlatform = Workspace:FindFirstChild("SafePlatform")
                if oldPlatform then oldPlatform:Destroy() end

                local platform = Instance.new("Part")
                platform.Name = "SafePlatform"
                platform.Size = Vector3.new(40, 1, 40)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 0.8
                platform.Color = Color3.fromRGB(0, 0, 0)
                platform.Material = Enum.Material.SmoothPlastic
                platform.CastShadow = false
                platform.CanTouch = false
                platform.CanQuery = false
                platform.Parent = Workspace

                platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)

                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge

                -- Track Y position (lock saat AFK)
                local lockedY = hrp.Position.Y
                local lastMoveTime = tick()
                local lastPos = hrp.Position

                local connection = game:GetService("RunService").RenderStepped:Connect(function()
                    if not hrp or not hrp.Parent or not platform.Parent then
                        connection:Disconnect()
                        return
                    end

                    local currentPos = hrp.Position

                    -- Deteksi apakah player bergerak (horizontal movement)
                    local horizontalMove = math.sqrt(
                        (currentPos.X - lastPos.X)^2 +
                        (currentPos.Z - lastPos.Z)^2
                    )

                    -- Jika bergerak horizontal (>0.1 studs), update locked Y
                    if horizontalMove > 0.1 then
                        lockedY = currentPos.Y
                        lastMoveTime = tick()
                    end

                    -- Jika tidak bergerak >2 detik (AFK), maintain Y position
                    local timeSinceMove = tick() - lastMoveTime
                    if timeSinceMove > 2 then
                        -- AFK mode: lock Y position
                        if math.abs(currentPos.Y - lockedY) > 0.5 then
                            hrp.CFrame = CFrame.new(currentPos.X, lockedY, currentPos.Z)
                        end
                        -- Platform di locked Y
                        platform.CFrame = CFrame.new(currentPos.X, lockedY - 3.5, currentPos.Z)
                    else
                        -- Normal mode: follow player Y
                        platform.CFrame = CFrame.new(currentPos.X, currentPos.Y - 3.5, currentPos.Z)
                    end

                    lastPos = currentPos

                    -- God mode
                    if humanoid.Health < humanoid.MaxHealth then
                        humanoid.Health = math.huge
                    end
                end)

                Character.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        connection:Disconnect()
                        if platform and platform.Parent then
                            platform:Destroy()
                        end
                    end
                end)
            end)
        end)
    end

    createPlatform()

    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        task.wait(0.5)
        createPlatform()
    end)
end


-- ========================================================
-- 7. EXTREME OPTIMIZATION (AGGRESSIVE CLEANUP)
-- ========================================================
task.spawn(function()
    pcall(function()
        -- Lighting cleanup
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        
        if CONFIG.DisableLightingEffects then
            for _, v in ipairs(Lighting:GetChildren()) do
                pcall(function() v:Destroy() end)
            end
        end
        
        -- Clear terrain
        if Workspace.Terrain then
            Workspace.Terrain:Clear()
        end
    end)

    -- Destroy workspace objects (except character)
    if CONFIG.ExtremeDestroy then
        local children = Workspace:GetChildren()
        for i, child in ipairs(children) do
            pcall(function()
                if child ~= Character 
                   and not Players:GetPlayerFromCharacter(child) 
                   and child.Name ~= "Camera" 
                   and child.Name ~= "Terrain" 
                   and child.Name ~= "SafePlatform" then
                   
                    child:Destroy()
                end
            end)
            
            if i % 20 == 0 then
                task.wait(0.03)
            end
        end
    end

    -- NEW: Hide workspace objects instead of destroying (safe for steal scripts)
    if CONFIG.HideExtreme then
        print("🔄 HideExtreme: Starting to hide objects...")
        local objectsHidden = 0
        local children = Workspace:GetChildren()
        
        for i, child in ipairs(children) do
            pcall(function()
                if child ~= Character 
                   and not Players:GetPlayerFromCharacter(child) 
                   and child.Name ~= "Camera" 
                   and child.Name ~= "Terrain" 
                   and child.Name ~= "SafePlatform"
                   and child.Name ~= "AreaEggSlotsClient"  -- Keep egg containers
                   and not child.Name:lower():find("egg") then  -- Keep egg objects
                   
                    -- Method 1: Make invisible + no collision (safer)
                    if child:IsA("Model") then
                        for _, part in pairs(child:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Transparency = 1
                                part.CanCollide = false
                                part.CastShadow = false
                            elseif part:IsA("Decal") or part:IsA("Texture") then
                                part.Transparency = 1
                            end
                        end
                        objectsHidden = objectsHidden + 1
                    elseif child:IsA("BasePart") then
                        child.Transparency = 1
                        child.CanCollide = false  
                        child.CastShadow = false
                        objectsHidden = objectsHidden + 1
                    end
                    
                    -- Method 2: Remove from workspace (more aggressive)
                    -- child.Parent = ReplicatedStorage  -- Move to storage instead of destroying
                end
            end)
            
            if i % 20 == 0 then
                task.wait(0.03)
            end
        end
        print("✅ HideExtreme: " .. objectsHidden .. " objects hidden (steal scripts safe)")
    end

    -- Clean descendants (particles, sounds, textures)
    local descendants = Workspace:GetDescendants()
    for i, v in ipairs(descendants) do
        pcall(function()
            if CONFIG.DisableParticles and (
                v:IsA("ParticleEmitter") or v:IsA("Trail") or 
                v:IsA("Beam") or v:IsA("Smoke") or 
                v:IsA("Fire") or v:IsA("Sparkles")) then
                v:Destroy()
            elseif CONFIG.DisableGameSounds and v:IsA("Sound") then
                v:Stop()
                v:Destroy()
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("BasePart") and not v:IsDescendantOf(Character) and v.Name ~= "SafePlatform" then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            end
        end)
        
        if i % 30 == 0 then
            task.wait(0.03)
        end
    end

    -- Final cleanup
    pcall(function()
        collectgarbage("collect")
    end)
end)

-- ========================================================
-- 8. AUTO SKIP TUTORIAL (Every 5 minutes)
-- ========================================================
task.spawn(function()
    while task.wait(300) do  -- 300 seconds = 5 minutes
        pcall(function()
            skipTutorial()
        end)
    end
end)

-- ========================================================
-- 9. AUTO SELL FRUITS (Every 10 minutes)
-- ========================================================
task.spawn(function()
    while task.wait(600) do  -- 600 seconds = 10 minutes
        pcall(function()
            print("🍎 Auto-Sell: Running sellFruits()...")
            sellFruits()
            print("✅ Auto-Sell: Complete!")
        end)
    end
end)
