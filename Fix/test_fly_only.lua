-- ========================================================
-- TEST FLY ONLY
-- Test metode fly ke egg dan kembali ke safe zone
-- ========================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local LocalPlayer  = Players.LocalPlayer

-- ========================================================
-- CONFIG - EDIT DI SINI
-- ========================================================

local CONFIG = {

    -- Area yang mau di-steal (true = aktif)
    AreaFilters = {
        FOREST          = false,
        LAKE            = false,
        DESERT          = false,
        JUNGLE          = false,
        SNOW            = false,
        VOLCANO         = false,
        ["ABYSS OCEAN"] = false,
        PREHISTORIC     = false,
        COSMIC          = true,
    },

    -- Kecepatan lari = sama seperti game (tidak diubah)
    -- WalkSpeed = default game

    -- Ketinggian fly (studs di atas posisi asal)
    -- Lebih tinggi = lebih aman dari guard
    FlyHeight = 150,

    -- Safe zone (koordinat return setelah steal)
    SafeZoneX = 537.8078613,
    SafeZoneY = 70.5743103,
    SafeZoneZ = -356.6216125,

    -- Retry ambil egg jika gagal (antisipasi lag)
    PickupRetry = 5,

    -- ESP aktif?
    ESPEnabled = true,

    -- Search radius egg
    SearchRadius = 5000,

    -- Auto mulai steal saat script jalan?
    AutoStart = true,
}

-- ========================================================
-- SETUP
-- ========================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local hrp       = character:WaitForChild("HumanoidRootPart")

local SAFE_ZONE = Vector3.new(CONFIG.SafeZoneX, CONFIG.SafeZoneY, CONFIG.SafeZoneZ)

print("========================================")
print("🛸 TEST FLY ONLY")
print("   Speed:", CONFIG.FlySpeed, "studs/s")
print("   Height:", CONFIG.FlyHeight, "studs")
print("   Safe Zone:", SAFE_ZONE)
print("========================================")

-- ========================================================
-- EGG POSITIONS & COLORS
-- ========================================================

local eggPositions = {
    {area = "FOREST",       x = 591.8,  y = 68.1, z = -325.6},
    {area = "LAKE",         x = 738.1,  y = 68.0, z = -411.1},
    {area = "DESERT",       x = 946.4,  y = 69.4, z = -327.3},
    {area = "JUNGLE",       x = 1194.4, y = 68.1, z = -412.1},
    {area = "SNOW",         x = 1489.0, y = 69.3, z = -317.8},
    {area = "VOLCANO",      x = 1884.5, y = 69.3, z = -400.6},
    {area = "ABYSS OCEAN",  x = 2278.2, y = 68.7, z = -330.1},
    {area = "PREHISTORIC",  x = 2818.9, y = 68.1, z = -401.0},
    {area = "COSMIC",       x = 3397.5, y = 69.6, z = -322.7},
}

local areaColors = {
    FOREST          = Color3.fromRGB(34, 139, 34),
    LAKE            = Color3.fromRGB(30, 144, 255),
    DESERT          = Color3.fromRGB(237, 201, 175),
    JUNGLE          = Color3.fromRGB(0, 180, 0),
    SNOW            = Color3.fromRGB(135, 206, 250),
    VOLCANO         = Color3.fromRGB(255, 69, 0),
    ["ABYSS OCEAN"] = Color3.fromRGB(0, 80, 200),
    PREHISTORIC     = Color3.fromRGB(200, 200, 220),
    COSMIC          = Color3.fromRGB(138, 43, 226),
}

local function getEggArea(pos)
    local best, bestDist = nil, math.huge
    for _, t in ipairs(eggPositions) do
        local d = (pos - Vector3.new(t.x, t.y, t.z)).Magnitude
        if d < bestDist and d <= 50 then
            bestDist = d
            best = t.area
        end
    end
    return best
end

-- ========================================================
-- ESP
-- ========================================================

local espCache  = {}
local eggCount  = 0
local areaCounts = {}

local function createESP(model)
    if not CONFIG.ESPEnabled then return nil end
    local part = model.PrimaryPart
        or model:FindFirstChild("Hitbox")
        or model:FindFirstChildWhichIsA("BasePart")
    if not part then return nil end
    local area = getEggArea(part.Position)
    if not area then return nil end

    areaCounts[area] = (areaCounts[area] or 0) + 1
    eggCount = eggCount + 1

    local bb = Instance.new("BillboardGui")
    bb.Adornee      = part
    bb.Size         = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset  = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop  = true
    bb.Parent       = part

    local lbl = Instance.new("TextLabel")
    lbl.Size                    = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency  = 1
    lbl.Text                    = "🥚 [" .. area .. "] #" .. areaCounts[area]
    lbl.TextColor3              = areaColors[area] or Color3.new(1,1,1)
    lbl.TextSize                = 14
    lbl.Font                    = Enum.Font.GothamBold
    lbl.TextStrokeTransparency  = 0.3
    lbl.Parent                  = bb

    return { bb = bb, part = part, model = model, area = area }
end

-- Fungsi untuk memeriksa apakah sudah carrying tool
local function checkCarrying()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        return true, tool.Name
    end
    return false, nil
end

-- Cari egg terdekat dari area yang difilter
local function findNearestEgg()
    local nearest, nearestDist = nil, math.huge
    
    for _, egg in pairs(espCache) do
        if egg.area and CONFIG.AreaFilters[egg.area] then
            local d = (hrp.Position - egg.part.Position).Magnitude
            if d < nearestDist then
                nearestDist = d
                nearest = egg
            end
        end
    end
    
    return nearest, nearestDist
end

-- Ambil egg dari proximity prompt
local function pickupEgg()
    local egg, dist = findNearestEgg()
    if not egg then
        print("❌ Tidak ada egg yang difilter")
        return false
    end
    
    print("  🥚 Target: " .. egg.area .. " (" .. math.floor(dist) .. " studs)")
    
    -- Pergi ke egg
    walkTo(egg.part.Position)
    
    -- Cari proximity prompt
    local prompt = nil
    for _, child in pairs(egg.model:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            prompt = child
            break
        end
    end
    
    if not prompt then
        print("❌ Tidak ada ProximityPrompt")
        return false
    end
    
    -- Ambil egg dengan retry
    for attempt = 1, CONFIG.PickupRetry do
        print("    Attempt " .. attempt .. "/" .. CONFIG.PickupRetry)
        
        for i = 1, 4 do
            pcall(function() fireproximityprompt(prompt) end)
            task.wait(0.1)
        end
        
        task.wait(0.5)
        local carrying = checkCarrying()
        if carrying then
            print("✅ Egg berhasil diambil!")
            return true
        end
        
        if attempt < CONFIG.PickupRetry then task.wait(1) end
    end
    
    print("❌ Gagal ambil egg setelah " .. CONFIG.PickupRetry .. " attempts")
    return false
end

-- Jalan ke egg area
local function flyToEgg()
    local egg, dist = findNearestEgg() 
    if not egg then
        print("❌ Tidak ada egg yang difilter")
        return
    end
    
    local eggPos = Vector3.new(egg.part.Position.X, egg.part.Position.Y, egg.part.Position.Z)
    print("  🛸 Fly ke " .. egg.area .. " (" .. math.floor(dist) .. " studs)")
    flyTo(eggPos)
end

local function scanEggs()
    print("🔍 Scanning eggs...")
    espCache = {}
    eggCount = 0
    areaCounts = {}
    
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") then
            local name = model.Name:lower()
            if name:find("egg") and not name:find("collect") then
                local esp = createESP(model)
                if esp then
                    table.insert(espCache, esp)
                end
            end
        end
    end
    
    print("📊 Area breakdown:")
    for area, count in pairs(areaCounts) do
        local enabled = CONFIG.AreaFilters[area] and "✅" or "❌"
        print("   " .. enabled .. " " .. area .. ": " .. count .. " eggs")
    end
end
end

local function scanEggs()
    local folder = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not folder then return end
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") and not espCache[child] then
            local e = createESP(child)
            if e then espCache[child] = e end
        end
    end
end

RunService.RenderStepped:Connect(function()
    scanEggs()
    for model, e in pairs(espCache) do
        if not model.Parent or not e.part.Parent then
            if e.bb and e.bb.Parent then e.bb:Destroy() end
            espCache[model] = nil
        else
            local dist = (hrp.Position - e.part.Position).Magnitude
            e.bb.Enabled = dist <= CONFIG.SearchRadius
        end
    end
end)

-- ========================================================
-- FLY SYSTEM - TweenService chunked (anti-cheat safe)
-- ========================================================

local TweenService = game:GetService("TweenService")

-- Simulasi WASD input - seperti player lari manual
local isWalking = false
local walkConnection = nil

local function walkTo(targetPos)
    isWalking = true
    
    -- Cleanup previous connection
    if walkConnection then
        walkConnection:Disconnect()
        walkConnection = nil
    end
    
    print("  🏃 Lari ke: " .. tostring(targetPos))
    
    -- Heartbeat: arahkan karakter + inject movement
    walkConnection = RunService.Heartbeat:Connect(function()
        if not isWalking then return end
        if not hrp or not hrp.Parent then return end
        
        local flatTarget = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        local dir = flatTarget - hrp.Position
        
        if dir.Magnitude <= 8 then
            isWalking = false
            return
        end
        
        -- Face target direction
        local lookDir = dir.Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir)
        
        -- Simulate W key press (move forward)
        humanoid:Move(lookDir, false)
    end)
    
    -- Tunggu sampai sampai
    local timeout = tick() + 300
    while isWalking and tick() < timeout do
        task.wait(0.1)
        local flatTarget = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        if (hrp.Position - flatTarget).Magnitude <= 8 then
            isWalking = false
        end
    end
    
    -- Cleanup
    isWalking = false
    if walkConnection then
        walkConnection:Disconnect()
        walkConnection = nil
    end
    humanoid:Move(Vector3.zero, false)
    task.wait(0.2)
end

-- Alias untuk compatibility
local function flyTo(targetPos)
    walkTo(targetPos)
end

-- Jalan ke egg (ground level, tidak ada fly)
local function flyToEgg(eggPos)
    print("  🏃 Lari ke egg...")
    flyTo(eggPos)
end

-- Jalan balik ke safe zone
local function flyToSafeZone()
    print("  🏃 Lari ke safe zone...")
    flyTo(SAFE_ZONE)
end

-- ========================================================
-- GOD MODE - Anti stun/knockback
-- ========================================================

humanoid.MaxHealth = math.huge
humanoid.Health    = math.huge

-- Block state stun/ragdoll
humanoid.StateChanged:Connect(function(_, new)
    if new == Enum.HumanoidStateType.FallingDown
    or new == Enum.HumanoidStateType.Ragdoll
    or new == Enum.HumanoidStateType.Physics then
        task.defer(function()
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Running) end)
        end)
    end
end)

-- Loop 60fps force running + hapus BodyMover knockback
task.spawn(function()
    while task.wait(0.016) do
        if not hrp or not hrp.Parent then break end

        -- Hapus force objects
        for _, c in ipairs(hrp:GetChildren()) do
            if c:IsA("BodyVelocity") or c:IsA("BodyForce")
            or c:IsA("BodyPosition") or c:IsA("LinearVelocity") then
                pcall(function() c:Destroy() end)
            end
        end

        -- Reset velocity horizontal jika kena knockback (bukan saat fly)
        if not hrp.Anchored then
            local vel = hrp.AssemblyLinearVelocity
            local hspeed = Vector2.new(vel.X, vel.Z).Magnitude
            if hspeed > 60 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    vel.X * 0.05, vel.Y, vel.Z * 0.05
                )
            end
        end
    end
end)

-- Health monitor
task.spawn(function()
    while task.wait(0.1) do
        if humanoid and humanoid.Parent then
            if humanoid.Health < 100 then humanoid.Health = math.huge end
        end
    end
end)

print("✨ God Mode: Active")

-- ========================================================
-- EGG STICKY - Egg nempel terus di tangan
-- ========================================================

local eggLockActive = false

task.spawn(function()
    while task.wait(0.05) do
        if not eggLockActive then continue end
        if not character or not character.Parent then continue end

        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            -- Lock di tangan
            pcall(function() tool.CanBeDropped = false end)
        else
            -- Cek backpack
            local bp = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if bp then
                pcall(function()
                    bp.CanBeDropped = false
                    humanoid:EquipTool(bp)
                end)
            end
        end
    end
end)

-- ========================================================
-- STEAL LOGIC
-- ========================================================

local function isNight()
    local t = Lighting.ClockTime
    return t >= 18 or t < 6
end

local function waitDay()
    print("🌙 Malam - menunggu siang...")
    while isNight() do
        print("   ⏳ Clock:", string.format("%.1f", Lighting.ClockTime))
        task.wait(5)
    end
    print("☀️  Siang! Lanjut steal...")
end

local function checkCarrying()
    local t = character:FindFirstChildOfClass("Tool")
    if t then return true, t.Name end
    t = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if t then return true, t.Name end
    return false, nil
end

local function findNearestEgg()
    local best, bestDist, bestArea = nil, math.huge, nil
    for model, e in pairs(espCache) do
        if model.Parent and e.part.Parent then
            if CONFIG.AreaFilters[e.area] then
                local d = (hrp.Position - e.part.Position).Magnitude
                if d < bestDist and d < CONFIG.SearchRadius then
                    bestDist = d
                    best     = model
                    bestArea = e.area
                end
            end
        end
    end
    return best, bestDist, bestArea
end

local function pickupEgg()
    for attempt = 1, CONFIG.PickupRetry do
        -- Cari proximity prompt terdekat
        local nearestPrompt, nearestDist = nil, math.huge
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local parent = obj.Parent
                if parent and parent:IsA("BasePart") then
                    local n = (parent.Name .. obj.Name):lower()
                    if n:find("egg") or n:find("carry") then
                        local d = (hrp.Position - parent.Position).Magnitude
                        if d < nearestDist then
                            nearestDist  = d
                            nearestPrompt = obj
                        end
                    end
                end
            end
        end

        if nearestPrompt then
            for _ = 1, 3 do
                pcall(function() fireproximityprompt(nearestPrompt) end)
                task.wait(0.1)
            end
            task.wait(0.4)
            if checkCarrying() then
                print("   ✅ Egg diambil (attempt " .. attempt .. ")")
                return true
            end
        end

        print("   ⚠️  Attempt " .. attempt .. " gagal...")
        task.wait(0.2)
    end
    return false
end

local function stealCycle()
    print("\n" .. string.rep("─", 45))
    print("🔄 STEAL CYCLE")
    print(string.rep("─", 45))

    -- Night check
    if isNight() then waitDay() end

    -- Cari egg
    print("[1] Mencari egg...")
    task.wait(1)  -- beri waktu scan
    local egg, dist, area = findNearestEgg()
    if not egg then
        print("❌ Tidak ada egg di area aktif")
        return false
    end
    print("✅ " .. area .. " - " .. math.floor(dist) .. " studs")

    -- Fly ke egg
    print("\n[2] Fly ke egg...")
    local eggPos = (egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")).Position
    flyToEgg(eggPos)

    -- Ambil egg
    print("\n[3] Ambil egg...")
    local ok = pickupEgg()
    if not ok then
        print("❌ Gagal ambil egg")
        return false
    end

    -- Aktifkan egg lock
    eggLockActive = true

    -- Fly balik
    print("\n[4] Fly ke safe zone...")
    flyToSafeZone()

    -- Nonaktifkan egg lock
    eggLockActive = false

    local carrying, name = checkCarrying()
    if carrying then
        print("🎉 BERHASIL! Egg: " .. tostring(name))
    else
        print("⚠️  Egg tidak ada di tangan setelah sampai")
    end

    print(string.rep("─", 45))
    return carrying
end

-- ========================================================
-- START
-- ========================================================

task.wait(2)
scanEggs()
print("✅ Scan: " .. eggCount .. " egg ditemukan")

function startSteal()
    while true do
        local ok = stealCycle()
        if ok then
            print("✅ Selesai! Jalankan startSteal() lagi untuk cycle berikutnya.")
            break
        end
        task.wait(3)
    end
end

function stealOnce()
    stealCycle()
end

if CONFIG.AutoStart then
    task.spawn(function()
        task.wait(1)
        startSteal()
    end)
else
    print("\n💡 Ketik startSteal() untuk mulai")
    print("   Ketik stealOnce()  untuk sekali")
end
