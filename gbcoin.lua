-- =============================================================
-- SAMBUNG KATA BOT (V67 - SAFE SNIPER EDITION)
-- FIX FATAL: Mencegah bunuh diri (Eliminasi karena 5x salah). 
-- CARA: Hapus randomizer & batasi tembakan maksimal 4x per giliran.
-- =============================================================

if _G.AutoKetik_V67_Running then return end
_G.AutoKetik_V67_Running = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Connections = {} 

-- ==========================================
-- 1. UI MOBILE (KUSTOM V67)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoKetik_V67"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 500) 
MainFrame.Position = UDim2.new(0.5, -120, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🛡️ V67 Safe Sniper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Membaca Kamus..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local WordLabel = Instance.new("TextLabel")
WordLabel.Size = UDim2.new(1, -20, 0, 20)
WordLabel.Position = UDim2.new(0, 10, 0, 50)
WordLabel.BackgroundTransparency = 1
WordLabel.Text = "Target: -"
WordLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
WordLabel.TextSize = 12
WordLabel.Font = Enum.Font.GothamBold
WordLabel.TextXAlignment = Enum.TextXAlignment.Left
WordLabel.Parent = MainFrame

local Toggles = Instance.new("Frame")
Toggles.Size = UDim2.new(1, -20, 0, 85) 
Toggles.Position = UDim2.new(0, 10, 0, 75)
Toggles.BackgroundTransparency = 1
Toggles.Parent = MainFrame

local BtnAuto = Instance.new("TextButton")
BtnAuto.Size = UDim2.new(1, 0, 0, 25) 
BtnAuto.Position = UDim2.new(0, 0, 0, 0)
BtnAuto.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
BtnAuto.Text = "⚡ Auto Sniper: OFF"
BtnAuto.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnAuto.TextSize = 11
BtnAuto.Font = Enum.Font.GothamBold
BtnAuto.Parent = Toggles
Instance.new("UICorner", BtnAuto).CornerRadius = UDim.new(0, 5)

local BtnSabotase = Instance.new("TextButton")
BtnSabotase.Size = UDim2.new(0.48, 0, 0, 25)
BtnSabotase.Position = UDim2.new(0, 0, 0, 30)
BtnSabotase.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
BtnSabotase.Text = "Sabotase: OFF"
BtnSabotase.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnSabotase.TextSize = 10
BtnSabotase.Font = Enum.Font.GothamBold
BtnSabotase.Parent = Toggles
Instance.new("UICorner", BtnSabotase).CornerRadius = UDim.new(0, 5)

local BtnBerat = Instance.new("TextButton")
BtnBerat.Size = UDim2.new(0.48, 0, 0, 25)
BtnBerat.Position = UDim2.new(0.52, 0, 0, 30)
BtnBerat.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
BtnBerat.Text = "🏋️ K. Berat: OFF"
BtnBerat.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnBerat.TextSize = 10
BtnBerat.Font = Enum.Font.GothamBold
BtnBerat.Parent = Toggles
Instance.new("UICorner", BtnBerat).CornerRadius = UDim.new(0, 5)

local BtnClear = Instance.new("TextButton")
BtnClear.Size = UDim2.new(1, 0, 0, 25) 
BtnClear.Position = UDim2.new(0, 0, 0, 60)
BtnClear.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
BtnClear.Text = "🧹 Hapus Teks Manual"
BtnClear.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnClear.TextSize = 11
BtnClear.Font = Enum.Font.GothamBold
BtnClear.Parent = Toggles
Instance.new("UICorner", BtnClear).CornerRadius = UDim.new(0, 5)

local ContekanLabel = Instance.new("TextLabel")
ContekanLabel.Size = UDim2.new(1, -20, 0, 320) 
ContekanLabel.Position = UDim2.new(0, 10, 0, 170)
ContekanLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ContekanLabel.BackgroundTransparency = 0.5
ContekanLabel.Text = "Menunggu Game..."
ContekanLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
ContekanLabel.TextSize = 11 
ContekanLabel.Font = Enum.Font.Gotham
ContekanLabel.TextXAlignment = Enum.TextXAlignment.Left
ContekanLabel.TextYAlignment = Enum.TextYAlignment.Top
ContekanLabel.TextWrapped = true
ContekanLabel.RichText = true
ContekanLabel.Parent = MainFrame
Instance.new("UICorner", ContekanLabel).CornerRadius = UDim.new(0, 5)

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingLeft = UDim.new(0, 8)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.Parent = ContekanLabel

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.AutoKetik_V67_Running = false 
    for _, conn in pairs(Connections) do conn:Disconnect() end
    ScreenGui:Destroy() 
end)

-- ==========================================
-- 2. LOGIKA KATA & FAST DICTIONARY
-- ==========================================
local Config = { Active = false, Sabotase = false, KelasBerat = false }
local FastDictionary = {} 
local UsedWords = {}
local CurrentPrefix = ""
_G.IsTyping_V67 = false

local LetterRarity = { z=1, x=2, q=3, w=4, v=5, f=6, p=7, c=8, y=9, j=10, a=100, i=99, e=98, u=97, o=96 }
local function getRarity(char) return LetterRarity[char] or 50 end

local BeratSuffixes = {"isasi", "isme", "nomi", "itas", "tif", "mik", "istri"}
local BeratPrefixes = {"ekstra", "makro", "mikro", "meta", "auto"}

local function IsKelasBerat(w)
    for _, s in ipairs(BeratSuffixes) do if w:find(s .. "$") then return true end end
    for _, p in ipairs(BeratPrefixes) do if w:find("^" .. p) then return true end end
    if #w > 10 then return true end 
    return false
end

local function GetSortedWords(prefix)
    local validWords = {}
    local firstLetter = string.sub(prefix, 1, 1)
    
    local searchPool = FastDictionary[firstLetter] or {}
    for _, word in ipairs(searchPool) do
        if string.sub(word, 1, #prefix) == prefix and #word > #prefix and not UsedWords[word] then
            table.insert(validWords, word)
        end
    end

    if #validWords > 0 then
        if Config.KelasBerat then
            table.sort(validWords, function(a, b)
                local bA, bB = IsKelasBerat(a), IsKelasBerat(b)
                if bA ~= bB then return bA end 
                return #a > #b 
            end)
        elseif not Config.Sabotase then
            local awamWords, otherWords = {}, {}
            local langka = {z=true, x=true, q=true, v=true, f=true, y=true} 
            for _, w in ipairs(validWords) do
                local isAwam = true
                if #w < 3 or #w > 7 then isAwam = false end
                if isAwam then
                    for i = 1, #w do if langka[string.sub(w, i, i)] then isAwam = false break end end
                end
                if isAwam then
                    if string.match(w, "nya$") or string.match(w, "ku$") or string.match(w, "mu$") 
                       or string.match(w, "lah$") or string.match(w, "kah$") or string.match(w, "pun$") then
                        isAwam = false
                    end
                end
                if isAwam then table.insert(awamWords, w) else table.insert(otherWords, w) end
            end
            table.sort(awamWords, function(a, b) return #a > #b end)
            table.sort(otherWords, function(a, b) return #a > #b end)
            
            local final = {}
            for _, w in ipairs(awamWords) do table.insert(final, w) end
            for _, w in ipairs(otherWords) do table.insert(final, w) end
            return final
        else
            table.sort(validWords, function(a, b)
                local rA, rB = getRarity(string.sub(a, -1)), getRarity(string.sub(b, -1))
                if Config.Sabotase and rA ~= rB then return rA < rB end
                return #a > #b
            end)
        end
    end
    return validWords
end

local function UpdateContekanUI(prefix)
    if prefix == "" then ContekanLabel.Text = "Menunggu Game..." return end
    local sortedWords = GetSortedWords(prefix)
    if #sortedWords == 0 then ContekanLabel.Text = "⚠️ Kata Habis!" return end
    
    local header = Config.KelasBerat and "Istilah Berat" or "Rekomendasi Bot"
    local txt = "💡 " .. header .. " (Aman):\n"
    local maxDisplay = math.min(25, #sortedWords) 
    for i = 1, maxDisplay do txt = txt .. i .. ". " .. string.upper(sortedWords[i]) .. "\n" end
    ContekanLabel.Text = txt
end

-- ==========================================
-- 3. UTILS & TOGGLES
-- ==========================================
local function ClearTextBox()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local matchUI = pg and pg:FindFirstChild("MatchUI")
    if matchUI then
        local typeBox = matchUI:FindFirstChild("TypeBox", true)
        if typeBox and typeBox:IsA("TextBox") then
            typeBox.Text = ""
        end
    end
end

BtnAuto.MouseButton1Click:Connect(function() 
    Config.Active = not Config.Active
    BtnAuto.BackgroundColor3 = Config.Active and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    BtnAuto.Text = Config.Active and "⚡ Auto Sniper: ON" or "⚡ Auto Sniper: OFF"
end)
BtnSabotase.MouseButton1Click:Connect(function() 
    Config.Sabotase = not Config.Sabotase
    BtnSabotase.BackgroundColor3 = Config.Sabotase and Color3.fromRGB(180, 50, 180) or Color3.fromRGB(150, 50, 50)
    BtnSabotase.Text = Config.Sabotase and "Sabotase: ON" or "Sabotase: OFF"
    if CurrentPrefix ~= "" then UpdateContekanUI(CurrentPrefix) end
end)
BtnBerat.MouseButton1Click:Connect(function() 
    Config.KelasBerat = not Config.KelasBerat
    BtnBerat.BackgroundColor3 = Config.KelasBerat and Color3.fromRGB(50, 100, 200) or Color3.fromRGB(150, 50, 50)
    BtnBerat.Text = Config.KelasBerat and "🏋️ K. Berat: ON" or "🏋️ K. Berat: OFF"
    if CurrentPrefix ~= "" then UpdateContekanUI(CurrentPrefix) end
end)
BtnClear.MouseButton1Click:Connect(function() 
    ClearTextBox()
    StatusLabel.Text = "Status: 🧹 Layar dibersihkan!"
end)

local function LoadLocalDictionary()
    task.spawn(function()
        local targetFile = "kamus.txt"
        if not readfile or not isfile then return end
        local success, data = pcall(function() return readfile(targetFile) end)
        if success and data then
            local count = 0
            for line in string.gmatch(data, "[^\r\n]+") do
                local word = string.match(line, "^([a-zA-Z]+)")
                if word and #word >= 2 then 
                    local cleanW = string.lower(word)
                    local fLetter = string.sub(cleanW, 1, 1)
                    if not FastDictionary[fLetter] then FastDictionary[fLetter] = {} end
                    table.insert(FastDictionary[fLetter], cleanW)
                    count = count + 1
                end
                if count % 2000 == 0 then task.wait() end 
            end
            StatusLabel.Text = "⚡ System Ready (".. math.floor(count/1000) .."k+ Words)"
            StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        end
    end)
end

-- ==========================================
-- 4. FIRE SERVER & ANTI SUICIDE RETRY
-- ==========================================
local function ReadRequiredLetters(ws)
    local letters = {}
    for _, child in pairs(ws:GetChildren()) do
        if child:IsA("TextLabel") and child.Visible and child.Text ~= "" then
            table.insert(letters, {text = child.Text, order = child.LayoutOrder})
        end
    end
    table.sort(letters, function(a, b) return a.order < b.order end)
    local p = ""
    for _, l in ipairs(letters) do p = p .. l.text end
    return string.lower(p)
end

local function CheckMyTurn()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local matchUI = PlayerGui and PlayerGui:FindFirstChild("MatchUI")
    if matchUI and matchUI.Enabled then
        local ws = matchUI:FindFirstChild("WordSubmit", true)
        if ws and ws.Visible then
            local p = ReadRequiredLetters(ws)
            if p ~= "" then return true, p, matchUI end
        end
    end
    return false, "", nil
end

local function AutoSubmitWithSafeRetry(prefix, MatchUI)
    if _G.IsTyping_V67 then return end
    _G.IsTyping_V67 = true
    
    local words = GetSortedWords(prefix)
    if #words == 0 then _G.IsTyping_V67 = false return end

    -- DIHAPUS PENGACAKAN (math.random) DI SINI. 
    -- Bot akan selalu mengambil kata paling standar/baku dari urutan teratas.

    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local submitRemote = Remotes and Remotes:FindFirstChild("SubmitWord")
    
    -- LIMIT NYAWA: Hanya mencoba 4 kali. Menyisakan 1 nyawa manual untuk pemain jika darurat!
    for attempt = 1, math.min(4, #words) do
        if not Config.Active or not CheckMyTurn() then break end
        
        local fullWord = words[attempt]
        WordLabel.Text = "Menembak: " .. string.upper(fullWord)
        
        ClearTextBox()
        
        if submitRemote then
            submitRemote:FireServer(fullWord)
            StatusLabel.Text = "Status: 🚀 SNIPED " .. string.upper(fullWord)
        end
        
        -- Tunggu verifikasi server 0.6 detik
        local timeout = 0
        local turnEnded = false
        while timeout < 0.6 do
            task.wait(0.1)
            timeout = timeout + 0.1
            if not CheckMyTurn() then 
                turnEnded = true 
                break 
            end
        end
        
        if turnEnded then
            UsedWords[fullWord] = true
            break
        else
            UsedWords[fullWord] = true -- Kata ditolak, jangan dipakai lagi
            StatusLabel.Text = "Status: ❌ Ditolak! Sisa " .. (4 - attempt) .. " Coba..."
            ClearTextBox()
            
            -- Jika sudah attempt ke-4 dan gagal, bot nyerah biar ngga mati konyol
            if attempt == 4 then
                StatusLabel.Text = "Status: ⚠️ BOT NYERAH! KETIK MANUAL!"
            end
        end
    end
    
    _G.IsTyping_V67 = false
end

-- ==========================================
-- 5. EVENT WATCHER & LOOP UTAMA
-- ==========================================
local function WatchGameEvents()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    -- Deteksi Instan jika kata tertolak/terpakai
    local usedWarn = Remotes:FindFirstChild("UsedWordWarn")
    if usedWarn then
        local conn = usedWarn.OnClientEvent:Connect(function(w)
            if type(w) == "string" then
                local cleanWord = string.match(string.lower(w), "^%s*(.-)%s*$")
                if cleanWord then UsedWords[cleanWord] = true end
            end
        end)
        table.insert(Connections, conn)
    end

    local ucw = Remotes:FindFirstChild("UpdateCurrentWord")
    if ucw then 
        local conn = ucw.OnClientEvent:Connect(function(w) 
            if type(w) == "string" then 
                local cleanWord = string.match(string.lower(w), "^%s*(.-)%s*$")
                if cleanWord then
                    UsedWords[cleanWord] = true 
                    if CurrentPrefix ~= "" then UpdateContekanUI(CurrentPrefix) end
                end
            end 
        end) 
        table.insert(Connections, conn)
    end
    
    local be = Remotes:FindFirstChild("BillboardEnd")
    if be then 
        local conn2 = be.OnClientEvent:Connect(function() 
            UsedWords = {} 
            _G.IsTyping_V67 = false
            CurrentPrefix = ""
            UpdateContekanUI("")
            WordLabel.Text = "Target: -"
            StatusLabel.Text = "Status: Ronde Selesai (Memori Di-reset!)"
        end) 
        table.insert(Connections, conn2)
    end
end

task.spawn(function()
    local wasEmpty = true
    while task.wait(0.1) do
        if not _G.AutoKetik_V67_Running then break end
        local isMine, myPrefix, matchUI = CheckMyTurn()
        
        if isMine then
            if myPrefix ~= CurrentPrefix or wasEmpty then
                wasEmpty = false
                CurrentPrefix = myPrefix
                WordLabel.Text = "Target: " .. string.upper(CurrentPrefix)
                UpdateContekanUI(CurrentPrefix)
                
                if Config.Active and not _G.IsTyping_V67 then 
                    task.spawn(AutoSubmitWithSafeRetry, CurrentPrefix, matchUI) 
                end
            end
        else
            wasEmpty = true
        end
    end
end)

task.spawn(WatchGameEvents)
LoadLocalDictionary()
