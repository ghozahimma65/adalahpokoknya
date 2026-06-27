--[[
    Deadly Golf — Auto Aim + Auto Angle + Auto Release (FIXED VERSION)
--]]

local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local CollectionService   = game:GetService("CollectionService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui             = game:GetService("CoreGui")

local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera
local GRAVITY = workspace.Gravity

-- ============================================================
-- KONSTANTA FISIKA
-- ============================================================
local MIN_SPEED       = 15    
local MAX_SPEED       = 235   
local MAX_CHARGE_TIME = 1.0   
local POWER_CURVE_EXP = 2.5   

local ANGLE_MIN  = 0
local ANGLE_MAX  = 60
local ANGLE_STEP = 5

-- [BARU] SHORTCUT KEYBOARD
local LOCK_HOTKEY = Enum.KeyCode.R -- Ganti huruf R dengan tombol yang kamu suka

-- ============================================================
-- STATE
-- ============================================================
local isReady      = false
local isCharging   = false
local targetHold   = 0
local connections  = {}

-- ============================================================
-- HOLE DETECTION
-- ============================================================
local function getHole()
    for _, ep in ipairs(CollectionService:GetTagged("EndPoint")) do
        if ep and ep.Parent then
            if ep:IsA("BasePart")   then return ep.Position, ep end
            if ep:IsA("Model")      then
                local p = ep.PrimaryPart
                return (p and p.Position or ep:GetPivot().Position), ep
            end
            if ep:IsA("Attachment") then return ep.WorldPosition, ep end
        end
    end
    return nil, nil
end

-- ============================================================
-- BACA ANGLE AKTIF
-- ============================================================
local function readAngle()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, v in ipairs(pg:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible then
            local n = v.Text:match("^(%d+)%°$")
            if n then
                local val = tonumber(n)
                if val and val >= ANGLE_MIN and val <= ANGLE_MAX then
                    return val
                end
            end
        end
    end
    return nil
end

-- ============================================================
-- HITUNG ANGLE OPTIMAL
-- ============================================================
local function calcOptimalAngle(ballPos, holePos)
    local diff = holePos - ballPos
    local x    = Vector3.new(diff.X, 0, diff.Z).Magnitude
    local y    = diff.Y 

    if x < 0.3 then return 30, 0.5 end

    local bestAngle = 30
    local bestRatio = nil
    local bestScore = math.huge

    for deg = ANGLE_MIN, ANGLE_MAX, ANGLE_STEP do
        local rad  = math.rad(math.max(deg, 1))
        local cosA = math.cos(rad)
        local tanA = math.tan(rad)

        local heightAbove = x * tanA - y
        if heightAbove <= 0 then continue end

        local v     = (x / cosA) * math.sqrt(GRAVITY / (2 * heightAbove))
        local ratio = (v - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
        if ratio < 0 or ratio > 1 then continue end

        local score = math.abs(ratio - 0.5)
        if score < bestScore then
            bestScore = score
            bestAngle = deg
            bestRatio = ratio
        end
    end

    if not bestRatio then
        return 30, 0.95
    end

    return bestAngle, bestRatio
end

-- ============================================================
-- KONVERSI RATIO → HOLD TIME
-- ============================================================
local function ratioToHold(ratio)
    ratio = math.clamp(ratio, 0, 1)
    return MAX_CHARGE_TIME * (ratio ^ (1 / POWER_CURVE_EXP))
end

-- ============================================================
-- AUTO SCROLL ANGLE
-- ============================================================
local function scrollToAngle(target, statusLbl)
    local cur = readAngle()
    if cur == nil then
        if statusLbl then
            statusLbl.Text = string.format("Set angle manual %d° lalu klik lagi", target)
        end
        return false
    end

    if cur == target then return true end
    local goUp   = target > cur
    local maxTry = (ANGLE_MAX / ANGLE_STEP) + 3

    for _ = 1, maxTry do
        cur = readAngle()
        if cur == nil or cur == target then break end

        local ok = pcall(function()
            VirtualInputManager:SendMouseWheelEvent(0, 0, goUp, game)
        end)

        if not ok then
            if statusLbl then
                statusLbl.Text = string.format("Auto-scroll diblokir. Set manual ke %d°.", target)
            end
            return false
        end
        task.wait(0.07)
    end
    task.wait(0.08)
    return readAngle() == target
end

-- ============================================================
-- FUNGSI UTAMA: KUNCI & HITUNG
-- ============================================================
local function lockAndCalculate(statusLbl, lockBtn)
    local holePos, holeObj = getHole()
    if not holePos then
        statusLbl.Text       = "Hole tidak ditemukan!"
        statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        return false
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        statusLbl.Text       = "Karakter tidak ditemukan!"
        statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        return false
    end

    local ballPos = root.Position

    local flatTarget = Vector3.new(holePos.X, ballPos.Y, holePos.Z)
    root.CFrame    = CFrame.lookAt(ballPos, flatTarget)
    camera.CFrame  = CFrame.lookAt(camera.CFrame.Position, holePos)

    local bestAngle, bestRatio = calcOptimalAngle(ballPos, holePos)
    local dist = Vector3.new(holePos.X-ballPos.X, 0, holePos.Z-ballPos.Z).Magnitude
    
    statusLbl.Text       = string.format("Jarak: %.0f | Menyesuaikan ke %d°...", dist, bestAngle)
    statusLbl.TextColor3 = Color3.fromRGB(255, 200, 60)

    scrollToAngle(bestAngle, statusLbl)

    local finalAngle = readAngle() or bestAngle
    local finalRad   = math.rad(math.max(finalAngle, 1))
    local cosA       = math.cos(finalRad)
    local tanA       = math.tan(finalRad)
    local heightAbove = dist * tanA - (holePos.Y - ballPos.Y)

    local finalRatio, holdTime
    if heightAbove > 0 then
        local v     = (dist / cosA) * math.sqrt(GRAVITY / (2 * heightAbove))
        finalRatio  = math.clamp((v - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), 0, 1)
        holdTime    = ratioToHold(finalRatio)
    else
        finalRatio = bestRatio
        holdTime   = ratioToHold(bestRatio)
    end

    targetHold = holdTime
    statusLbl.Text = string.format("%d° | Power %.0f%% | Tahan %.2fs\nTAHAN KLIK SEKARANG!", finalAngle, finalRatio * 100, holdTime)
    statusLbl.TextColor3 = Color3.fromRGB(80, 255, 150)

    if lockBtn then
        lockBtn.BackgroundColor3 = Color3.fromRGB(30, 160, 65)
        lockBtn.Text             = "✓  SIAP — TAHAN KLIK KIRI"
    end
    return true
end

-- ============================================================
-- GUI SETUP
-- ============================================================
local guiParent = CoreGui
pcall(function() if not CoreGui then guiParent = player.PlayerGui end end)

if guiParent:FindFirstChild("DGFinalUI") then 
    guiParent.DGFinalUI:Destroy() 
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name         = "DGFinalUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent       = guiParent

local frame = Instance.new("Frame", screenGui)
frame.Size             = UDim2.new(0, 270, 0, 152)
frame.Position         = UDim2.new(0.5, -135, 0, 18)
frame.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
frame.BorderSizePixel  = 0
frame.Active           = true
frame.Draggable        = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local fs = Instance.new("UIStroke", frame)
fs.Color = Color3.fromRGB(120, 60, 220)
fs.Thickness = 1.5

local header = Instance.new("Frame", frame)
header.Size             = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 34)
header.BorderSizePixel  = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local hp = Instance.new("Frame", header)
hp.Size = UDim2.new(1,0,0,12)
hp.Position = UDim2.new(0,0,1,-12)
hp.BackgroundColor3 = Color3.fromRGB(20,20,34)
hp.BorderSizePixel = 0

local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size = UDim2.new(1,-40,1,0)
titleLbl.Position = UDim2.new(0,10,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Text = "⛳  Deadly Golf — Auto Play"
titleLbl.TextSize = 12
titleLbl.Font = Enum.Font.GothamMedium
titleLbl.TextColor3 = Color3.fromRGB(190, 150, 255)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size             = UDim2.new(0, 26, 0, 20)
closeBtn.Position         = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 38, 38)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.fromRGB(255,255,255)
closeBtn.TextSize         = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel  = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

local statusLbl = Instance.new("TextLabel", frame)
statusLbl.Size = UDim2.new(1,-12,0,42)
statusLbl.Position = UDim2.new(0,6,0,34)
statusLbl.BackgroundColor3 = Color3.fromRGB(18,18,28)
statusLbl.BorderSizePixel = 0
statusLbl.Text = "Tekan [ R ] untuk mengunci."
statusLbl.TextColor3 = Color3.fromRGB(170,170,200)
statusLbl.TextSize = 11
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextWrapped = true
Instance.new("UICorner", statusLbl).CornerRadius = UDim.new(0,6)

local lockBtn = Instance.new("TextButton", frame)
lockBtn.Size             = UDim2.new(1,-12,0,34)
lockBtn.Position         = UDim2.new(0,6,0,82)
lockBtn.BackgroundColor3 = Color3.fromRGB(45, 95, 210)
lockBtn.Text             = "🎯  KUNCI & HITUNG (R)"
lockBtn.TextColor3       = Color3.fromRGB(225, 225, 255)
lockBtn.TextSize         = 13
lockBtn.Font = Enum.Font.GothamBold
lockBtn.BorderSizePixel  = 0
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0,7)

local infoLbl = Instance.new("TextLabel", frame)
infoLbl.Size = UDim2.new(1,-12,0,22)
infoLbl.Position = UDim2.new(0,6,0,120)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "Tekan R → Tahan Klik Kiri → Otomatis Lepas"
infoLbl.TextColor3 = Color3.fromRGB(100,100,130)
infoLbl.TextSize = 10
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextXAlignment = Enum.TextXAlignment.Center

-- ============================================================
-- EVENT HANDLER
-- ============================================================

-- Fungsi eksekusi yang bisa dipanggil lewat klik maupun shortcut
local function executeLock()
    if isCharging then return end
    isReady    = false
    targetHold = 0
    lockBtn.BackgroundColor3 = Color3.fromRGB(45, 95, 210)
    lockBtn.Text             = "🎯  KUNCI & HITUNG (R)"
    statusLbl.Text           = "Menghitung..."
    statusLbl.TextColor3     = Color3.fromRGB(170,170,200)
    
    task.spawn(function()
        local ok = lockAndCalculate(statusLbl, lockBtn)
        if ok then
            isReady = true
        else
            lockBtn.BackgroundColor3 = Color3.fromRGB(160, 38, 38)
            lockBtn.Text             = "✗  GAGAL — coba lagi"
        end
    end)
end

table.insert(connections, closeBtn.MouseButton1Click:Connect(function()
    isReady    = false
    isCharging = false
    targetHold = 0
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}
    screenGui:Destroy()
end))

table.insert(connections, lockBtn.MouseButton1Click:Connect(executeLock))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if not (isReady and isCharging) then return end
    local holePos = getHole()
    if holePos then
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, holePos)
    end
end))

-- Deteksi Shortcut & Tahan Klik Kiri
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- [BARU] Deteksi tombol Shortcut (R)
    if input.KeyCode == LOCK_HOTKEY then
        executeLock()
        return
    end
    
    -- Deteksi Mouse
    if not isReady or targetHold <= 0 then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    
    isCharging = true
    statusLbl.Text       = string.format("Mengisi power... %.2f dtk", targetHold)
    statusLbl.TextColor3 = Color3.fromRGB(255, 210, 50)
    
    local holdSnap = targetHold
    task.wait(holdSnap)
    
    if isCharging then
        if mouse1release then
            mouse1release()
            statusLbl.Text       = string.format("✓ LEPAS! Pukulan sempurna (%.2fs)", holdSnap)
            statusLbl.TextColor3 = Color3.fromRGB(60, 255, 130)
        else
            statusLbl.Text       = "✗ mouse1release() tidak tersedia"
            statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    isCharging = false
    isReady    = false
    targetHold = 0
    task.wait(0.5)
    lockBtn.BackgroundColor3 = Color3.fromRGB(45, 95, 210)
    lockBtn.Text             = "🎯  KUNCI & HITUNG (R)"
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isCharging = false
    end
end))
