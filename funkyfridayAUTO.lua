-- Funky Friday Autoplay dengan Rayfield UI
-- Compatible dengan Xeno Executor
-- Original lib oleh Null-Cherry, UI oleh teman kamu

local lib = FFAutoplayLib or loadstring(game:HttpGet("https://raw.githubusercontent.com/Null-Cherry/Null-Fire/refs/heads/main/Core/Loaders/Funky-Friday/Autoplay.lua", true))()

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Buat Window
local Window = Rayfield:CreateWindow({
	Name = "FF Autoplay | by Ghoza",
	Icon = 0, -- Icon dari Roblox, bisa dikosongkan
	LoadingTitle = "FF Autoplay",
	LoadingSubtitle = "Tunggu sebentar...",
	Theme = "Default", -- bisa: Default, Amber Glow, Amethyst, Bloom, Dark Blue, etc.

	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false,

	ConfigurationSaving = {
		Enabled = true,
		FolderName = "FFAutoplay",
		FileName = "Config"
	},

	Discord = {
		Enabled = false,
	},

	KeySystem = false,
})

-- ========================
-- TAB: MAIN
-- ========================
local MainTab = Window:CreateTab("Main", 4483362458)

-- AutoPlay Toggle
MainTab:CreateToggle({
	Name = "AutoPlay",
	CurrentValue = false,
	Flag = "AutoPlay",
	Callback = function(Value)
		lib.AutoPlay = Value
	end,
})

-- Perfect Sick Slider
MainTab:CreateSlider({
	Name = "Perfect Sick",
	Range = {0, 2},
	Increment = 0.1,
	Suffix = "x",
	CurrentValue = 1,
	Flag = "PerfectSick",
	Callback = function(Value)
		lib.PerfectSick = Value
	end,
})

-- Performance Slider
MainTab:CreateSlider({
	Name = "Performance Mode",
	Range = {0, 5},
	Increment = 1,
	Suffix = "",
	CurrentValue = 0,
	Flag = "Performance",
	Callback = function(Value)
		lib.Performance = Value
	end,
})

-- Copy Enemy Notes Toggle
MainTab:CreateToggle({
	Name = "Copy Enemy Notes",
	CurrentValue = false,
	Flag = "CopyEnemyNotes",
	Callback = function(Value)
		lib.CopyEnemyNotes = Value
	end,
})

-- More Stats Toggle
MainTab:CreateToggle({
	Name = "More Stats (di HUD)",
	CurrentValue = true,
	Flag = "MoreStats",
	Callback = function(Value)
		lib.MoreStats = Value
	end,
})

-- ========================
-- TAB: HIT CHANCES
-- ========================
local ChancesTab = Window:CreateTab("Hit Chances", 4483362458)

ChancesTab:CreateSection("Distribusi Chance (total harus = 100)")

-- Sick
ChancesTab:CreateSlider({
	Name = "Sick %",
	Range = {0, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = 100,
	Flag = "ChanceSick",
	Callback = function(Value)
		lib.Chances.Sick = Value
	end,
})

-- Good
ChancesTab:CreateSlider({
	Name = "Good %",
	Range = {0, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = 0,
	Flag = "ChanceGood",
	Callback = function(Value)
		lib.Chances.Good = Value
	end,
})

-- Ok
ChancesTab:CreateSlider({
	Name = "Ok %",
	Range = {0, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = 0,
	Flag = "ChanceOk",
	Callback = function(Value)
		lib.Chances.Ok = Value
	end,
})

-- Bad
ChancesTab:CreateSlider({
	Name = "Bad %",
	Range = {0, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = 0,
	Flag = "ChanceBad",
	Callback = function(Value)
		lib.Chances.Bad = Value
	end,
})

-- Miss
ChancesTab:CreateSlider({
	Name = "Miss %",
	Range = {0, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = 0,
	Flag = "ChanceMiss",
	Callback = function(Value)
		lib.Chances.Miss = Value
	end,
})

-- ========================
-- TAB: HOLD SETTINGS
-- ========================
local HoldTab = Window:CreateTab("Hold Settings", 4483362458)

HoldTab:CreateSection("Durasi Hold Note")

HoldTab:CreateSlider({
	Name = "Hold Duration (detik)",
	Range = {0, 0.5},
	Increment = 0.005,
	Suffix = "s",
	CurrentValue = 0.075,
	Flag = "HoldDuration",
	Callback = function(Value)
		lib.HoldDuration = Value
	end,
})

HoldTab:CreateSlider({
	Name = "Hold Duration Random",
	Range = {0, 0.2},
	Increment = 0.005,
	Suffix = "s",
	CurrentValue = 0.025,
	Flag = "HoldDurationRandom",
	Callback = function(Value)
		lib.HoldDurationRandom = Value
	end,
})

-- ========================
-- TAB: KPS LIMIT
-- ========================
local KpsTab = Window:CreateTab("KPS Limit", 4483362458)

KpsTab:CreateSection("Keys Per Second Limiter")

KpsTab:CreateSlider({
	Name = "Max KPS (semua key)",
	Range = {0, 100},
	Increment = 1,
	Suffix = " kps",
	CurrentValue = 0,
	Flag = "MaxKPS",
	Callback = function(Value)
		lib.MaxKPS = Value
	end,
})

KpsTab:CreateSlider({
	Name = "Max KPS Per Key",
	Range = {0, 100},
	Increment = 1,
	Suffix = " kps",
	CurrentValue = 0,
	Flag = "MaxKPSPerKey",
	Callback = function(Value)
		lib.MaxKPSPerKey = Value
	end,
})

KpsTab:CreateParagraph({
	Title = "Info",
	Content = "Set ke 0 untuk tidak ada limit.\nMaxKPS = limit semua tombol.\nMaxKPS Per Key = limit tiap tombol masing-masing."
})

-- ========================
-- TAB: INFO
-- ========================
local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateSection("Status Autoplay")

-- Label status realtime
local StatusLabel = InfoTab:CreateLabel("Status: Menunggu lagu...")

-- Update status tiap detik
task.spawn(function()
	while true do
		task.wait(1)
		local status = lib.Playing and "🟢 Sedang bermain" or "🔴 Tidak bermain"
		local fps = math.floor(lib.FPS or 0)
		local kps = lib.KPS or 0
		local lanes = lib.Lanes or 0
		local side = lib.Side or "?"
		StatusLabel:Set("Status: " .. status .. "\nFPS: " .. fps .. " | KPS: " .. kps .. "\nLanes: " .. lanes .. " | Sisi: " .. side)
	end
end)

InfoTab:CreateParagraph({
	Title = "Cara Pakai",
	Content = "1. Masuk ke lobby Funky Friday\n2. Aktifkan AutoPlay di tab Main\n3. Pilih lagu dan mulai\n4. Autoplay akan berjalan otomatis\n\nNOTE: Script harus dijalankan SEBELUM lagu mulai!"
})

InfoTab:CreateParagraph({
	Title = "Fitur",
	Content = "✅ ModCharts didukung\n⚠️ SV kurang didukung\n✅ 60+ FPS didukung\n✅ Hindari Death & Poison notes\n✅ Bisa mulai tengah lagu (terbatas)"
})

-- Notifikasi dari lib
lib.Events.Message:Connect(function(text)
	Rayfield:Notify({
		Title = "FF Autoplay",
		Content = text,
		Duration = 6,
		Image = 4483362458,
		Actions = {},
	})
end)

-- Load config yang disimpan
Rayfield:LoadConfiguration()
