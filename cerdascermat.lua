-- =============================================================
-- BOT CERDAS CERMAT (CONTEKAN UI EDITION)
-- Feature: Intercept SendQuestion, Display Hidden Answers on UI
-- =============================================================

if _G.ContekanCerdasCermat then
    _G.ContekanCerdasCermat:Destroy()
end

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Bikin UI Contekan Melayang
local sg = Instance.new("ScreenGui")
sg.Name = "ContekanCerdasCermat"
sg.ResetOnSpawn = false
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
_G.ContekanCerdasCermat = sg

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 300, 0, 120)
frame.Position = UDim2.new(0.5, -150, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(255, 215, 0)
Instance.new("UIStroke", frame).Thickness = 2

local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(180, 130, 0)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "🧠 CONTEKAN VIP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

local statusLbl = Instance.new("TextLabel", frame)
statusLbl.Size = UDim2.new(1, -20, 0, 30)
statusLbl.Position = UDim2.new(0, 10, 0, 35)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Menunggu soal dari server..."
statusLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLbl.Font = Enum.Font.GothamSemibold
statusLbl.TextSize = 12
statusLbl.TextWrapped = true

local answerLbl = Instance.new("TextLabel", frame)
answerLbl.Size = UDim2.new(1, -20, 0, 45)
answerLbl.Position = UDim2.new(0, 10, 0, 70)
answerLbl.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
answerLbl.Text = "JAWABAN MUNCUL DI SINI"
answerLbl.TextColor3 = Color3.fromRGB(50, 255, 100)
answerLbl.Font = Enum.Font.GothamBold
answerLbl.TextSize = 16
answerLbl.TextWrapped = true
Instance.new("UICorner", answerLbl).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", answerLbl).Color = Color3.fromRGB(0, 150, 50)

-- Fitur Drag UI
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = frame.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (input.Position - dragStart).Y)
    end
end)
topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- ==========================================
-- SADAP JAWABAN DARI SERVER
-- ==========================================
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendQuestion = Remotes:WaitForChild("SendQuestion")

SendQuestion.OnClientEvent:Connect(function(question, options, arg3, arg4, arg5)
    -- Tampilkan cuplikan soal biar yakin
    local shortQ = tostring(question)
    if #shortQ > 40 then shortQ = string.sub(shortQ, 1, 40) .. "..." end
    statusLbl.Text = shortQ

    -- Mencari jawaban (berdasarkan screenshot-mu, jawaban ada di argumen ke-3 atau sisanya)
    local bocoran = "TIDAK KETEMU"
    
    if type(arg3) == "string" or type(arg3) == "number" or type(arg3) == "boolean" then
        if tostring(arg3) ~= "" then bocoran = tostring(arg3) end
    elseif type(arg4) == "string" or type(arg4) == "number" or type(arg4) == "boolean" then
        if tostring(arg4) ~= "" then bocoran = tostring(arg4) end
    end
    
    -- Kasus khusus: Kalau game ngasih bocoran di dalam table options
    if bocoran == "TIDAK KETEMU" and type(options) == "table" then
        for i, v in pairs(options) do
            if type(v) == "string" and string.find(string.lower(v), "benar") then
                bocoran = v
            end
        end
    end

    answerLbl.Text = string.upper(tostring(bocoran))
    
    -- Efek kedip pas jawaban masuk
    answerLbl.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    task.wait(0.2)
    answerLbl.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
end)
