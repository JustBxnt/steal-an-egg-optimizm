-- ========================================================
-- AUTO STEAL EGG - NO GUI VERSION
-- Semua setting dari CONFIG di bawah ini
-- Mendukung TELEPORT atau WALK mode
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- !! EDIT CONFIG DI SINI !!
-- ========================================================

local CONFIG = {

    -- [ AREA YANG INGIN DI-STEAL ]
    -- Ganti false → true untuk aktifkan area
    AreaFilters = {
        FOREST      = false,
        LAKE        = false,
        DESERT      = false,
        JUNGLE      = false,   -- ← Matikan Jungle
        SNOW        = false,
        VOLCANO     = false,
        ["ABYSS OCEAN"] = false,
        PREHISTORIC = false,   -- ← Matikan Prehistoric
        COSMIC      = true,    -- ← Aktifkan COSMIC
    },

    -- [ AUTO STEAL ]
    -- true  = langsung mulai steal otomatis saat script dijalankan
    -- false = tidak mulai otomatis (perlu ketik startSteal() di console)
    AutoStart = true,

    -- [ MOVEMENT MODE ]
    -- "tween"  = smooth animated movement (paling cinematic)
    -- "slide"  = karakter slide/glide dengan velocity (cepat & smooth)
    -- "minitp" = mini teleport berulang (aman)
    -- "walk"   = jalan biasa pakai simulasi WASD (paling aman)
    MovementMode = "tween",

    -- [ TWEEN SETTINGS ] (hanya untuk mode tween)
    -- Durasi tween (detik) - auto-calculate based on distance jika 0
    TweenDuration = 0,  -- 0 = auto (based on TweenSpeed)
    
    -- Kecepatan tween (studs per detik) - digunakan jika TweenDuration = 0
    TweenSpeed = 205,
    
    -- Easing style untuk tween
    -- Linear = kecepatan konstan (tidak ada pelan-kencang) ✅
    -- Sine, Quad, Cubic = ada easing (pelan-cepat-pelan)
    TweenEasingStyle = "Linear",
    
    -- Easing direction (tidak berpengaruh untuk Linear)
    -- Out (smooth finish), In (smooth start), InOut (smooth both)
    TweenEasingDirection = "Out",

    -- [ SLIDE SETTINGS ] (hanya untuk mode slide)
    -- Kecepatan slide (studs per detik)
    SlideSpeed = 10,

    -- Tinggi dari ground saat slide (studs)
    SlideHeight = 3,

    -- [ MINI TELEPORT SETTINGS ] (hanya untuk mode minitp)
    -- Jarak per mini teleport (studs)
    MiniTpDistance = 5,

    -- Delay antar mini teleport (detik)
    MiniTpDelay = 0.05,

    -- [ SAFE ZONE - Titik kembali setelah steal ]
    SafeZoneX = 537.8078613,
    SafeZoneY = 70.5743103,
    SafeZoneZ = -356.6216125,

    -- [ ARRIVAL DISTANCE ]
    -- Jarak (studs) dianggap sudah sampai tujuan
    ArrivalDistance = 5,

    -- [ ESP - Nama egg di atas kepala ]
    ESPEnabled = true,

    -- [ PICKUP RETRY ]
    -- Berapa kali coba ambil egg jika gagal (antisipasi lag)
    PickupRetry = 5,

    -- [ FORCE AREA MODE ]
    -- true  = Paksa pergi ke koordinat area (tidak tunggu ESP scan egg)
    -- false = Tunggu ESP scan egg dulu, baru pergi (lebih akurat)
    ForceAreaMode = true,  -- ← Aktifkan untuk langsung ke area target

}

-- ========================================================
-- JANGAN EDIT DI BAWAH INI
-- ========================================================

print("========================================")
print("🥚 AUTO STEAL - NO GUI VERSION")
print("========================================")
print("CONFIG:")
for area, enabled in pairs(CONFIG.AreaFilters) do
    if enabled then
        print("  ✅ " .. area)
    end
end
if CONFIG.MovementMode == "tween" then
    print("  🎬 Movement: TWEEN (Animated)")
    print("  ⚡ Tween Speed:", CONFIG.TweenSpeed, "studs/s")
    print("  🎨 Easing:", CONFIG.TweenEasingStyle, CONFIG.TweenEasingDirection)
elseif CONFIG.MovementMode == "slide" then
    print("  🛝 Movement: SLIDE/GLIDE")
    print("  ⚡ Slide Speed:", CONFIG.SlideSpeed, "studs/s")
    print("  📏 Slide Height:", CONFIG.SlideHeight, "studs")
elseif CONFIG.MovementMode == "minitp" then
    print("  ⚡ Movement: MINI TELEPORT")
    print("  📏 Distance per TP:", CONFIG.MiniTpDistance, "studs")
    print("  ⏱️  Delay per TP:", CONFIG.MiniTpDelay, "seconds")
else
    print("  🚶 Movement: Walk Simulation (WASD-like)")
end
print("  📍 Safe Zone:", CONFIG.SafeZoneX, CONFIG.SafeZoneY, CONFIG.SafeZoneZ)
print("  🔄 Auto Start:", CONFIG.AutoStart)
print("  🔧 Force Area Mode:", CONFIG.ForceAreaMode)
print("========================================\n")

-- Character
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local SAFE_ZONE_POSITION = Vector3.new(CONFIG.SafeZoneX, CONFIG.SafeZoneY, CONFIG.SafeZoneZ)

-- ========================================================
-- NIGHT DETECTION
-- ========================================================

local function isNightTime()
    local clockTime = Lighting.ClockTime
    return (clockTime >= 18 or clockTime < 6), clockTime
end

local function waitForDayTime()
    print("\n🌙 MALAM - Menunggu siang hari...")
    while true do
        local isNight, time = isNightTime()
        if not isNight then
            print("☀️  Sudah siang! Melanjutkan steal...")
            return
        end
        print("   🌙 Masih malam... (" .. string.format("%.1f", time) .. " jam)")
        task.wait(5)
    end
end

-- ========================================================
-- EGG POSITIONS
-- ========================================================

local eggPositions = {
    {area = "FOREST",       x = 591.8,   y = 68.1, z = -325.6},
    {area = "LAKE",         x = 738.1,   y = 68.0, z = -411.1},
    {area = "DESERT",       x = 946.4,   y = 69.4, z = -327.3},
    {area = "JUNGLE",       x = 1194.4,  y = 68.1, z = -412.1},
    {area = "SNOW",         x = 1489.0,  y = 69.3, z = -317.8},
    {area = "VOLCANO",      x = 1884.5,  y = 69.3, z = -400.6},
    {area = "ABYSS OCEAN",  x = 2278.2,  y = 68.7, z = -330.1},
    {area = "PREHISTORIC",  x = 2818.9,  y = 68.1, z = -401.0},
    {area = "COSMIC",       x = 3397.5,  y = 69.6, z = -322.7},
}

local areaColors = {
    FOREST          = Color3.fromRGB(34, 139, 34),
    LAKE            = Color3.fromRGB(30, 144, 255),
    DESERT          = Color3.fromRGB(237, 201, 175),
    JUNGLE          = Color3.fromRGB(0, 128, 0),
    SNOW            = Color3.fromRGB(135, 206, 250),
    VOLCANO         = Color3.fromRGB(255, 69, 0),
    ["ABYSS OCEAN"] = Color3.fromRGB(0, 0, 139),
    PREHISTORIC     = Color3.fromRGB(240, 248, 255),
    COSMIC          = Color3.fromRGB(138, 43, 226),
}

-- ========================================================
-- AREA DETECTION
-- ========================================================

local function getEggArea(eggPosition)
    local closestDist = math.huge
    local closestArea = nil
    for _, taggedPos in ipairs(eggPositions) do
        local tagPos = Vector3.new(taggedPos.x, taggedPos.y, taggedPos.z)
        local distance = (eggPosition - tagPos).Magnitude
        if distance < closestDist and distance <= 50 then
            closestDist = distance
            closestArea = taggedPos.area
        end
    end
    return closestArea
end

-- ========================================================
-- ESP SYSTEM
-- ========================================================

local espCache = {}
local eggCounter = 0
local areaCounts = {}

local function createESP(eggModel)
    if not CONFIG.ESPEnabled then return nil end
    local primaryPart = eggModel.PrimaryPart
        or eggModel:FindFirstChild("Hitbox")
        or eggModel:FindFirstChild("HitBox")
        or eggModel:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return nil end

    local area = getEggArea(primaryPart.Position)
    if not area then return nil end

    areaCounts[area] = (areaCounts[area] or 0) + 1
    eggCounter = eggCounter + 1

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESP"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = primaryPart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🥚 [" .. area .. "] #" .. areaCounts[area]
    label.TextColor3 = areaColors[area] or Color3.fromRGB(255, 200, 100)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.TextStrokeTransparency = 0.3
    label.Parent = billboard

    return { billboard = billboard, primaryPart = primaryPart, eggModel = eggModel, area = area }
end

local function updateESP(espData)
    if not espData or not espData.eggModel.Parent or not espData.primaryPart.Parent then return false end
    local c = LocalPlayer.Character
    if not c then return true end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return true end
    local dist = (h.Position - espData.primaryPart.Position).Magnitude
    espData.billboard.Enabled = CONFIG.ESPEnabled and dist <= CONFIG.SearchRadius
    return true
end

local function scanEggs()
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not areaEggs then return end
    for _, child in pairs(areaEggs:GetChildren()) do
        if child:IsA("Model") and not espCache[child] then
            local esp = createESP(child)
            if esp then espCache[child] = esp end
        end
    end
end

RunService.RenderStepped:Connect(function()
    scanEggs()
    for eggModel, espData in pairs(espCache) do
        if not updateESP(espData) then
            if espData.billboard and espData.billboard.Parent then
                espData.billboard:Destroy()
            end
            espCache[eggModel] = nil
        end
    end
end)

-- ========================================================
-- NO-COLLISION WITH GUARDS (Character menembus guard)
-- ========================================================

local PhysicsService = game:GetService("PhysicsService")

local function setupNoCollision()
    -- Buat collision group baru untuk player
    pcall(function()
        PhysicsService:RegisterCollisionGroup("Player")
        PhysicsService:RegisterCollisionGroup("Guards")
        -- Player tidak collision dengan Guards
        PhysicsService:CollisionGroupSetCollidable("Player", "Guards", false)
    end)

    -- Set semua part character ke group "Player"
    local function setCharacterGroup()
        if not character then return end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CollisionGroup = "Player"
                end)
            end
        end
    end

    setCharacterGroup()

    -- Reapply setiap respawn
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        for _, part in pairs(newChar:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CollisionGroup = "Player" end)
            end
        end
    end)

    -- Set semua guard/npc ke group "Guards"
    local function setGuardGroup(obj)
        local name = obj.Name:lower()
        if obj:IsA("Model") and (
            name:find("guard") or name:find("npc") or
            name:find("enemy") or name:find("cop") or
            name:find("security")
        ) then
            pcall(function()
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CollisionGroup = "Guards"
                        -- Juga disable touch damage
                        part.CanTouch = false
                    end
                end
                -- Disable semua script guard
                for _, s in pairs(obj:GetDescendants()) do
                    if s:IsA("Script") or s:IsA("LocalScript") then
                        s.Disabled = true
                    end
                end
            end)
        end
    end

    -- Apply ke semua guard yang sudah ada
    for _, obj in pairs(Workspace:GetDescendants()) do
        setGuardGroup(obj)
    end

    -- Monitor guard baru yang spawn
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        setGuardGroup(obj)
    end)

    print("👻 No-Collision: Player menembus guard")
end

setupNoCollision()

-- ========================================================
-- GUARD DESTROYER (Backup - matikan script guard)
-- ========================================================

local function destroyGuards()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if obj:IsA("Model") and (name:find("guard") or name:find("npc") or name:find("enemy")) then
            pcall(function()
                for _, s in pairs(obj:GetDescendants()) do
                    if s:IsA("Script") or s:IsA("LocalScript") then s.Disabled = true end
                end
                for _, p in pairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                        p.CanTouch = false
                        p.Transparency = 0.5  -- Sedikit transparan agar kelihatan tapi tidak bisa hit
                    end
                end
            end)
        end
    end
end

destroyGuards()
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    local name = obj.Name:lower()
    if obj:IsA("Model") and (name:find("guard") or name:find("npc") or name:find("enemy")) then
        pcall(function()
            for _, p in pairs(obj:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                    p.CanTouch = false
                end
            end
        end)
    end
end)
print("🛡️ Guard Destroyer: Active")

-- ========================================================
-- ANTI-STUN / ANTI-KNOCKBACK (100% Block)
-- ========================================================

-- Simpan posisi terakhir yang valid untuk reset saat terkena knockback
local lastSafePosition = hrp.Position
local lastSafeCFrame = hrp.CFrame

-- Update posisi aman setiap frame saat karakter berdiri normal
task.spawn(function()
    while task.wait(0.05) do
        if hrp and hrp.Parent and humanoid and humanoid.Parent then
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.Running
            or state == Enum.HumanoidStateType.RunningNoPhysics then
                lastSafePosition = hrp.Position
                lastSafeCFrame = hrp.CFrame
            end
        end
    end
end)

-- [1] Block StateChanged - tolak semua state stun/ragdoll/knockback
humanoid.StateChanged:Connect(function(oldState, newState)
    if newState == Enum.HumanoidStateType.FallingDown
    or newState == Enum.HumanoidStateType.Ragdoll
    or newState == Enum.HumanoidStateType.Physics
    or newState == Enum.HumanoidStateType.PlatformStanding
    or newState == Enum.HumanoidStateType.GettingUp then
        -- Langsung paksa balik ke Running
        task.defer(function()
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end)
    end
end)

-- [2] Loop 0.016s (60fps) - paksa state Running terus
task.spawn(function()
    while task.wait(0.016) do
        if not humanoid or not humanoid.Parent then break end
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.PlatformStanding then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end)
            -- Hanya reset velocity, BUKAN posisi (agar animasi tetap jalan)
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.new(
                    hrp.AssemblyLinearVelocity.X * 0.1,
                    0,
                    hrp.AssemblyLinearVelocity.Z * 0.1
                )
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
end)

-- [3] Anti-knockback: reset velocity tiap 0.016s
task.spawn(function()
    while task.wait(0.016) do
        if not hrp or not hrp.Parent then break end

        -- Hapus semua BodyMover yang ditaruh oleh server/guard
        for _, child in pairs(hrp:GetChildren()) do
            if child:IsA("BodyVelocity")
            or child:IsA("BodyPosition")
            or child:IsA("BodyForce")
            or child:IsA("BodyThrust")
            or child:IsA("VectorForce")
            or child:IsA("LinearVelocity") then
                pcall(function() child:Destroy() end)
            end
        end

        -- Jika velocity horizontal terlalu besar = kena knockback
        -- Hanya reset sumbu X dan Z, biarkan Y (gravity tetap jalan)
        local vel = hrp.AssemblyLinearVelocity
        local horizontalSpeed = Vector2.new(vel.X, vel.Z).Magnitude
        if horizontalSpeed > 60 then  -- threshold: lebih dari sprint speed
            hrp.AssemblyLinearVelocity = Vector3.new(
                vel.X * 0.05,  -- hampir stop horizontal
                vel.Y,         -- Y tetap (gravity/jump tidak terganggu)
                vel.Z * 0.05
            )
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)

-- [4] Anti-ragdoll: pastikan joints TIDAK dimatikan
-- Tidak menyentuh MaxVelocity agar animasi tetap normal
-- Hanya disable ragdoll constraint jika ada
task.spawn(function()
    while task.wait(0.1) do
        if not character or not character.Parent then break end
        for _, obj in pairs(character:GetDescendants()) do
            -- Hapus BallSocketConstraint / HingeConstraint yang dibuat oleh ragdoll system
            if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") then
                if obj.Name:lower():find("ragdoll") or obj.Name:lower():find("joint") then
                    pcall(function() obj.Enabled = false end)
                end
            end
        end
    end
end)

-- [5] Health infinity
humanoid.MaxHealth = math.huge
humanoid.Health = math.huge

humanoid.Died:Connect(function()
    task.defer(function()
        humanoid.Health = math.huge
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end)
end)

task.spawn(function()
    while task.wait(0.05) do
        if humanoid and humanoid.Parent then
            if humanoid.Health < 100 then
                humanoid.Health = math.huge
            end
        end
    end
end)

-- [6] Reapply semua proteksi saat respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    hrp = newChar:WaitForChild("HumanoidRootPart")

    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge

    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.FallingDown
        or newState == Enum.HumanoidStateType.Ragdoll
        or newState == Enum.HumanoidStateType.Physics then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end
    end)

    print("✨ Proteksi reapply setelah respawn")
end)

print("✨ Anti-Stun/Knockback: AKTIF (60fps block)")

-- Anti-drop
task.spawn(function()
    local lastTool = nil
    while task.wait(0.05) do
        if character and character.Parent then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                lastTool = tool
                pcall(function() tool.CanBeDropped = false end)
            elseif lastTool and lastTool.Parent == nil then
                pcall(function()
                    local bp = LocalPlayer.Backpack:FindFirstChild(lastTool.Name)
                    if bp then humanoid:EquipTool(bp) end
                end)
            end
        end
    end
end)

print("✨ God Mode: Active")

-- ========================================================
-- TWEEN SYSTEM (Smooth animated movement)
-- ========================================================

local function tweenToPosition(targetPos)
    if not hrp or not humanoid then return false end
    
    local startPos = hrp.Position
    local totalDistance = (targetPos - startPos).Magnitude
    
    print("   🎬 Tween ke: " .. math.floor(targetPos.X) .. ", " .. math.floor(targetPos.Y) .. ", " .. math.floor(targetPos.Z))
    print("   📏 Jarak total: " .. math.floor(totalDistance) .. " studs")
    
    -- Calculate duration
    local duration
    if CONFIG.TweenDuration > 0 then
        duration = CONFIG.TweenDuration
    else
        duration = totalDistance / CONFIG.TweenSpeed
    end
    print("   ⏱️  Durasi: " .. string.format("%.1f", duration) .. " detik")
    
    -- Parse easing style and direction
    local easingStyle = Enum.EasingStyle[CONFIG.TweenEasingStyle] or Enum.EasingStyle.Cubic
    local easingDirection = Enum.EasingDirection[CONFIG.TweenEasingDirection] or Enum.EasingDirection.InOut
    
    -- Create TweenInfo
    local tweenInfo = TweenInfo.new(
        duration,           -- Time
        easingStyle,        -- EasingStyle
        easingDirection,    -- EasingDirection
        0,                  -- RepeatCount
        false,              -- Reverses
        0                   -- DelayTime
    )
    
    -- Create tween for HumanoidRootPart
    local tween = TweenService:Create(hrp, tweenInfo, {
        CFrame = CFrame.new(targetPos)
    })
    
    -- Play tween
    tween:Play()
    
    -- Wait for tween to complete with progress updates
    local startTime = tick()
    local progressReported = {false, false, false}  -- 25%, 50%, 75%
    
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)
        
        -- Progress reports
        if not progressReported[1] and progress >= 0.25 then
            local distLeft = (hrp.Position - targetPos).Magnitude
            print("   📍 Progress: 25% - Sisa " .. math.floor(distLeft) .. " studs")
            progressReported[1] = true
        elseif not progressReported[2] and progress >= 0.50 then
            local distLeft = (hrp.Position - targetPos).Magnitude
            print("   📍 Progress: 50% - Sisa " .. math.floor(distLeft) .. " studs")
            progressReported[2] = true
        elseif not progressReported[3] and progress >= 0.75 then
            local distLeft = (hrp.Position - targetPos).Magnitude
            print("   📍 Progress: 75% - Sisa " .. math.floor(distLeft) .. " studs")
            progressReported[3] = true
        end
        
        task.wait(0.1)
    end
    
    -- Wait for tween completion
    tween.Completed:Wait()
    
    -- Final position adjustment (ensure exact position)
    hrp.CFrame = CFrame.new(targetPos)
    task.wait(0.1)
    
    local actualTime = tick() - startTime
    print("   ✅ Tween selesai! (Waktu: " .. string.format("%.1f", actualTime) .. "s)")
    
    -- Cleanup
    tween:Destroy()
    
    return true
end

-- ========================================================
-- SLIDE/GLIDE SYSTEM (Smooth movement dengan velocity)
-- ========================================================

local function slideToPosition(targetPos)
    if not hrp or not humanoid then return false end
    
    local startPos = hrp.Position
    local totalDistance = (targetPos - startPos).Magnitude
    
    print("   🛝 Slide ke: " .. math.floor(targetPos.X) .. ", " .. math.floor(targetPos.Y) .. ", " .. math.floor(targetPos.Z))
    print("   📏 Jarak total: " .. math.floor(totalDistance) .. " studs")
    
    -- Hitung durasi berdasarkan kecepatan
    local duration = totalDistance / CONFIG.SlideSpeed
    print("   ⏱️  Estimasi waktu: " .. string.format("%.1f", duration) .. " detik")
    
    -- Direction vector
    local direction = (targetPos - startPos).Unit
    
    -- Set posisi awal dengan height offset
    local slideStartPos = Vector3.new(startPos.X, targetPos.Y + CONFIG.SlideHeight, startPos.Z)
    hrp.CFrame = CFrame.new(slideStartPos)
    task.wait(0.1)
    
    -- Create BodyVelocity untuk slide smooth
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "SlideVelocity"
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = direction * CONFIG.SlideSpeed
    bodyVelocity.Parent = hrp
    
    -- Create BodyGyro untuk keep orientation
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "SlideGyro"
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
    bodyGyro.P = 10000
    bodyGyro.D = 500
    bodyGyro.Parent = hrp
    
    -- Maintain altitude saat slide
    local slideHeight = targetPos.Y + CONFIG.SlideHeight
    
    local startTime = tick()
    local progressReported = false
    
    -- Loop sampai sampai tujuan atau timeout
    while (hrp.Position - targetPos).Magnitude > CONFIG.ArrivalDistance do
        local elapsed = tick() - startTime
        
        -- Timeout safety (2x duration estimate)
        if elapsed > (duration * 2 + 5) then
            print("   ⚠️  Timeout, teleport langsung ke tujuan")
            break
        end
        
        -- Update velocity direction (re-aim setiap 0.5s untuk akurasi)
        if elapsed % 0.5 < 0.05 then
            local currentDir = (targetPos - hrp.Position).Unit
            bodyVelocity.Velocity = currentDir * CONFIG.SlideSpeed
            bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + currentDir)
        end
        
        -- Maintain altitude
        if math.abs(hrp.Position.Y - slideHeight) > 2 then
            hrp.CFrame = CFrame.new(hrp.Position.X, slideHeight, hrp.Position.Z)
        end
        
        -- Progress report (50% mark)
        if not progressReported and elapsed > duration * 0.5 then
            local distLeft = (hrp.Position - targetPos).Magnitude
            print("   📍 Progress: 50% - Sisa " .. math.floor(distLeft) .. " studs")
            progressReported = true
        end
        
        task.wait(0.05)
    end
    
    -- Cleanup BodyVelocity & BodyGyro
    pcall(function()
        if bodyVelocity and bodyVelocity.Parent then
            bodyVelocity:Destroy()
        end
        if bodyGyro and bodyGyro.Parent then
            bodyGyro:Destroy()
        end
    end)
    
    -- Final position adjustment
    hrp.CFrame = CFrame.new(targetPos)
    task.wait(0.2)
    
    local actualTime = tick() - startTime
    print("   ✅ Sampai tujuan! (Waktu: " .. string.format("%.1f", actualTime) .. "s)")
    
    return true
end

-- ========================================================
-- MINI TELEPORT SYSTEM (50 studs berulang)
-- ========================================================

local function miniTeleportToPosition(targetPos)
    if not hrp or not humanoid then return false end
    
    local startPos = hrp.Position
    local totalDistance = (targetPos - startPos).Magnitude
    
    print("   ⚡ Mini Teleport ke: " .. math.floor(targetPos.X) .. ", " .. math.floor(targetPos.Y) .. ", " .. math.floor(targetPos.Z))
    print("   📏 Jarak total: " .. math.floor(totalDistance) .. " studs")
    
    local tpCount = 0
    local maxIterations = 1000  -- Safety limit
    local stuckCounter = 0
    local lastPos = hrp.Position
    
    -- Loop mini teleport sampai sampai tujuan
    while (hrp.Position - targetPos).Magnitude > CONFIG.ArrivalDistance and tpCount < maxIterations do
        local currentPos = hrp.Position
        local direction = (targetPos - currentPos).Unit
        local remainingDistance = (targetPos - currentPos).Magnitude
        
        -- Safety check: jika tidak bergerak (stuck), skip
        if (currentPos - lastPos).Magnitude < 1 then
            stuckCounter = stuckCounter + 1
            if stuckCounter > 3 then
                print("   ⚠️  Terdeteksi stuck, coba teleport lebih jauh...")
                -- Teleport lebih jauh untuk keluar dari stuck
                local bigJump = currentPos + (direction * (CONFIG.MiniTpDistance * 2))
                hrp.CFrame = CFrame.new(bigJump)
                stuckCounter = 0
                task.wait(CONFIG.MiniTpDelay * 2)
                continue
            end
        else
            stuckCounter = 0
        end
        lastPos = currentPos
        
        -- Tentukan jarak teleport berikutnya (max MiniTpDistance atau sisa jarak)
        local tpDistance = math.min(CONFIG.MiniTpDistance, remainingDistance)
        
        -- Hitung posisi baru
        local newPos = currentPos + (direction * tpDistance)
        
        -- Teleport ke posisi baru (keep Y position untuk ground level)
        -- Tapi jika jarak masih jauh, gunakan Y dari target
        local newY = targetPos.Y
        if remainingDistance > 100 then
            -- Kalau masih jauh, terbang sedikit untuk avoid obstacle
            newY = math.max(currentPos.Y, targetPos.Y) + 3
        end
        
        local safeNewPos = Vector3.new(newPos.X, newY, newPos.Z)
        hrp.CFrame = CFrame.new(safeNewPos)
        
        tpCount = tpCount + 1
        
        -- Progress report setiap 5 teleport
        if tpCount % 5 == 0 then
            local distLeft = (hrp.Position - targetPos).Magnitude
            print("   📍 TP #" .. tpCount .. " - Sisa: " .. math.floor(distLeft) .. " studs")
        end
        
        -- Delay antar teleport
        task.wait(CONFIG.MiniTpDelay)
    end
    
    -- Final teleport ke posisi target yang tepat
    hrp.CFrame = CFrame.new(targetPos)
    task.wait(0.1)
    
    print("   ✅ Sampai tujuan! (Total: " .. tpCount .. " mini teleports)")
    
    return true
end

-- ========================================================
-- MOVEMENT WRAPPER (Teleport atau Walk)
-- ========================================================

local function moveToPosition(targetPos)
    if CONFIG.MovementMode == "tween" then
        return tweenToPosition(targetPos)
    elseif CONFIG.MovementMode == "slide" then
        return slideToPosition(targetPos)
    elseif CONFIG.MovementMode == "minitp" then
        return miniTeleportToPosition(targetPos)
    else
        return walkToPosition(targetPos)
    end
end

-- ========================================================
-- WALK SYSTEM - Input simulation (seperti tekan WASD manual)
-- Tidak ubah WalkSpeed, pakai kecepatan game asli
-- ========================================================

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local isWalking = false
local walkConnection = nil

local function simulateWASDMovement(targetPos)
    isWalking = true
    
    -- Cleanup previous connection
    if walkConnection then
        walkConnection:Disconnect()
        walkConnection = nil
    end
    
    -- Heartbeat: arahkan karakter + inject movement seperti tekan W
    walkConnection = RunService.Heartbeat:Connect(function()
        if not isWalking then return end
        if not hrp or not hrp.Parent then return end
        
        local flatTarget = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        local dir = flatTarget - hrp.Position
        
        if dir.Magnitude <= CONFIG.ArrivalDistance then
            isWalking = false
            return
        end
        
        -- Face target direction (sama seperti player manual)
        local lookDir = dir.Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir)
        
        -- Simulate W key press (move forward) - ini yang bikin kecepatan sama seperti manual
        humanoid:Move(lookDir, false)
    end)
    
    -- Tunggu sampai sampai dengan timeout
    local timeout = tick() + 300  -- 5 menit max untuk jarak jauh
    while isWalking and tick() < timeout do
        task.wait(0.1)
        local flatTarget = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        if (hrp.Position - flatTarget).Magnitude <= CONFIG.ArrivalDistance then
            isWalking = false
        end
    end
    
    -- Cleanup
    isWalking = false
    if walkConnection then
        walkConnection:Disconnect()
        walkConnection = nil
    end
    humanoid:Move(Vector3.zero, false)  -- Stop movement
    task.wait(0.2)
end

local function walkToPosition(targetPos)
    if not hrp or not humanoid then return false end
    
    print("   🚶 Jalan ke: " .. math.floor(targetPos.X) .. ", " .. math.floor(targetPos.Y) .. ", " .. math.floor(targetPos.Z))
    simulateWASDMovement(targetPos)
    print("   ✅ Sampai tujuan")
    
    return true
end

-- ========================================================
-- ========================================================
-- EGG STICKY SYSTEM
-- Egg nempel 100% di tangan, jika lepas langsung ambil lagi
-- ========================================================

local isCarryingEgg = false
local lastEggName = nil
local eggRecoveryActive = false

local function checkIfCarrying()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then return true, tool.Name end
    tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then return true, tool.Name end
    return false, nil
end

local function startEggMonitor(eggName, eggPos)
    lastEggName = eggName
    eggRecoveryActive = true
    print("🔒 Egg lock aktif: " .. tostring(eggName))
end

local function stopEggMonitor()
    eggRecoveryActive = false
    lastEggName = nil
    print("🔓 Egg lock off")
end

-- Background loop: paksa egg nempel terus
task.spawn(function()
    while true do
        task.wait(0.05)
        if not eggRecoveryActive then continue end
        if not character or not character.Parent then continue end

        local tool = character:FindFirstChildOfClass("Tool")

        if tool then
            -- Egg di tangan → lock supaya tidak bisa drop
            pcall(function() tool.CanBeDropped = false end)

        else
            -- Egg tidak di tangan → cek backpack dulu
            local bp = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if bp then
                -- Ada di backpack → equip balik
                pcall(function()
                    bp.CanBeDropped = false
                    humanoid:EquipTool(bp)
                end)
                print("🔄 Re-equip dari backpack: " .. bp.Name)

            else
                -- Tidak di tangan & tidak di backpack
                -- → Cari proximity prompt egg terdekat dan ambil lagi
                local nearestPrompt, nearestDist, nearestPos = nil, math.huge, nil

                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local parent = obj.Parent
                        if parent and parent:IsA("BasePart") then
                            local n = (parent.Name .. obj.Name):lower()
                            if n:find("egg") or n:find("carry") then
                                local d = (hrp.Position - parent.Position).Magnitude
                                if d < nearestDist then
                                    nearestDist = d
                                    nearestPrompt = obj
                                    nearestPos = parent.Position
                                end
                            end
                        end
                    end
                end

                if nearestPrompt and nearestPos then
                    print("⚠️  Egg lepas! Lari ambil lagi (" .. math.floor(nearestDist) .. " studs)...")

                    -- Lari ke egg pakai MoveTo biasa
                    local t = tick()
                    while (hrp.Position - nearestPos).Magnitude > 4 and tick() - t < 15 do
                        humanoid:MoveTo(nearestPos)
                        task.wait(0.5)
                    end

                    -- Ambil egg
                    for _ = 1, 4 do
                        pcall(function() fireproximityprompt(nearestPrompt) end)
                        task.wait(0.1)
                    end

                    task.wait(0.3)
                    local ok, n = checkIfCarrying()
                    if ok then
                        print("✅ Egg diambil ulang: " .. tostring(n))
                    else
                        print("❌ Gagal ambil ulang")
                    end
                end
            end
        end
    end
end)

-- ========================================================
-- STEAL LOGIC
-- ========================================================

local function findNearestEgg()
    -- Collect all eggs from enabled areas first
    local eggsInEnabledAreas = {}
    
    for eggModel, espData in pairs(espCache) do
        if eggModel.Parent and espData.primaryPart.Parent then
            local area = espData.area
            if CONFIG.AreaFilters[area] then
                table.insert(eggsInEnabledAreas, {
                    model = eggModel,
                    area = area,
                    position = espData.primaryPart.Position,
                    distance = (hrp.Position - espData.primaryPart.Position).Magnitude
                })
            end
        end
    end
    
    -- If no eggs found in enabled areas
    if #eggsInEnabledAreas == 0 then
        return nil, 0, nil
    end
    
    -- Sort by distance (nearest first)
    table.sort(eggsInEnabledAreas, function(a, b)
        return a.distance < b.distance
    end)
    
    -- Return the nearest egg within search radius
    local nearest = eggsInEnabledAreas[1]
    if nearest.distance < CONFIG.SearchRadius then
        return nearest.model, nearest.distance, nearest.area
    end
    
    return nil, 0, nil
end

-- Function to get hardcoded area position
local function getAreaPosition()
    -- Cari area pertama yang aktif di CONFIG
    for _, areaData in ipairs(eggPositions) do
        if CONFIG.AreaFilters[areaData.area] then
            local pos = Vector3.new(areaData.x, areaData.y, areaData.z)
            return pos, areaData.area
        end
    end
    return nil, nil
end

local function pickupEgg()
    for attempt = 1, CONFIG.PickupRetry do
        -- Cari proximity prompt terdekat
        local nearestPrompt, nearestDist = nil, math.huge
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local parent = obj.Parent
                if parent and parent:IsA("BasePart") then
                    local name = (parent.Name .. obj.Name):lower()
                    if name:find("egg") or name:find("carry") then
                        local dist = (hrp.Position - parent.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestPrompt = obj
                        end
                    end
                end
            end
        end

        if nearestPrompt then
            -- Fire 3x untuk antisipasi lag
            for _ = 1, 3 do
                pcall(function() fireproximityprompt(nearestPrompt) end)
                task.wait(0.1)
            end
            task.wait(0.3)
            if checkIfCarrying() then
                print("   ✅ Egg diambil! (attempt " .. attempt .. ")")
                return true
            end
        end

        print("   ⚠️  Attempt " .. attempt .. " gagal, retry...")
        task.wait(0.2)
    end
    return false
end

local function stealCycle()
    print("\n" .. string.rep("─", 50))
    print("🔄 STEAL CYCLE")
    print(string.rep("─", 50))

    -- Cek malam hari
    local isNight = isNightTime()
    if isNight then
        waitForDayTime()
    end

    -- Cari egg
    print("[1] Mencari egg...")
    
    local eggPos, area, dist
    
    if CONFIG.ForceAreaMode then
        -- Mode 1: Force ke koordinat area (tidak perlu tunggu ESP)
        print("   🔧 ForceAreaMode: ON - Menggunakan koordinat hardcoded")
        local pos, areaName = getAreaPosition()
        if not pos then
            print("❌ Tidak ada area yang diaktifkan di CONFIG")
            return false
        end
        eggPos = pos
        area = areaName
        dist = (hrp.Position - eggPos).Magnitude
        print("✅ Target area: " .. area .. " (" .. math.floor(dist) .. " studs)")
    else
        -- Mode 2: Tunggu ESP scan egg dulu (lebih akurat)
        local egg
        egg, dist, area = findNearestEgg()
        if not egg then
            print("❌ Tidak ada egg di area yang diaktifkan")
            print("   💡 TIP: Aktifkan ForceAreaMode = true untuk langsung ke koordinat area")
            return false
        end
        print("✅ Egg ditemukan: " .. area .. " (" .. math.floor(dist) .. " studs)")
        eggPos = egg.PrimaryPart and egg.PrimaryPart.Position
            or egg:FindFirstChildWhichIsA("BasePart").Position
    end

    -- Lari ke egg
    print("\n[2] Pindah ke egg area...")
    moveToPosition(eggPos)

    -- Ambil egg
    print("\n[3] Mengambil egg...")
    local success = pickupEgg()
    if not success then
        print("❌ Gagal ambil egg setelah " .. CONFIG.PickupRetry .. " percobaan")
        return false
    end

    -- Aktifkan egg recovery monitor agar egg tidak hilang saat dipukul
    local carriedTool = character:FindFirstChildOfClass("Tool")
        or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    startEggMonitor(carriedTool and carriedTool.Name or nil, eggPos)

    -- Lari kembali ke safe zone
    print("\n[4] Kembali ke safe zone (recovery aktif jika egg lepas)...")
    moveToPosition(SAFE_ZONE_POSITION)

    -- Matikan recovery monitor setelah sampai safe zone
    stopEggMonitor()

    -- Verifikasi
    local stillCarrying, toolName = checkIfCarrying()
    if stillCarrying then
        print("✅ Egg berhasil dibawa ke safe zone: " .. tostring(toolName))
    else
        print("⚠️  Egg tidak ada di tangan setelah sampai safe zone")
    end

    print("\n✅✅ SELESAI!")
    print(string.rep("─", 50) .. "\n")
    return stillCarrying
end

-- ========================================================
-- START
-- ========================================================

-- Scan awal
task.wait(1)
scanEggs()
print("✅ Scan awal: " .. eggCounter .. " egg ditemukan")

-- Fungsi manual (bisa dipanggil dari console)
function startSteal()
    print("🚀 Starting auto steal...")
    while true do
        local ok = stealCycle()
        if ok then
            print("🎉 Egg berhasil dicuri! Berhenti.")
            break
        end
        task.wait(2)
    end
end

function stealOnce()
    stealCycle()
end

-- Auto start jika diaktifkan
if CONFIG.AutoStart then
    task.spawn(function()
        task.wait(2)  -- Tunggu scan selesai
        startSteal()
    end)
else
    print("\n💡 AutoStart = false")
    print("   Ketik startSteal() untuk mulai otomatis")
    print("   Ketik stealOnce() untuk steal satu kali")
end

print("\n========================================")
print("✅ SCRIPT LOADED!")
print("   Edit CONFIG di baris atas untuk setting")
print("========================================")
