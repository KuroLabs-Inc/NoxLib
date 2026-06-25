local NoxLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KuroLab-Inc/NoxLib/refs/heads/main/NoxLib.lua"))()

local Window = NoxLib:CreateWindow({
	Title = "Nox Hub",
	SubTitle = "Best Script Ever",
	ToggleText = "Nox Hub",
	ToggleImage = 13510032884,
})

local Main = Window:CreateTab({ Name = "Main", Icon = 10709790937 })
local Combat = Window:CreateTab({ Name = "Combat", Icon = 10723417965 })
local Visual = Window:CreateTab({ Name = "Visuals", Icon = 10734948008 })
local Misc = Window:CreateTab({ Name = "Misc", Icon = 10734950309 })

Main:AddSection("Auto Farming")

Main:AddToggle({
	Name = "Auto Farm",
	Default = false,
	Callback = function(value)
		getgenv().AutoFarm = value
		Window:Notify({ Title = "Auto Farm", Content = value and "Enabled" or "Disabled" })
	end,
})

Main:AddToggle({
	Name = "Auto Collect",
	Default = false,
	Callback = function(value)
		getgenv().AutoCollect = value
	end,
})

Main:AddSlider({
	Name = "Farm Speed",
	Min = 1,
	Max = 100,
	Default = 25,
	Callback = function(value)
		getgenv().FarmSpeed = value
	end,
})

Main:AddButton({
	Name = "Teleport To Boss",
	Callback = function()
		Window:Notify({ Title = "Teleport", Content = "Teleporting to boss..." })
	end,
})

Combat:AddSection("ESP")

Combat:AddToggle({
	Name = "Player ESP",
	Default = false,
	Callback = function(value)
		getgenv().PlayerESP = value
	end,
})

Combat:AddToggle({
	Name = "Box ESP",
	Default = false,
	Callback = function(value)
		getgenv().BoxESP = value
	end,
})

Combat:AddDropdown({
	Name = "ESP Color",
	Options = { "Red", "Green", "Blue", "White" },
	Default = "Red",
	Callback = function(option)
		getgenv().ESPColor = option
	end,
})

Combat:AddSlider({
	Name = "ESP Distance",
	Min = 50,
	Max = 5000,
	Default = 1000,
	Callback = function(value)
		getgenv().ESPDistance = value
	end,
})

Visual:AddSection("World")

Visual:AddToggle({
	Name = "Full Bright",
	Default = false,
	Callback = function(value)
		game.Lighting.Brightness = value and 5 or 1
	end,
})

Visual:AddDropdown({
	Name = "Time Of Day",
	Options = { "Morning", "Noon", "Night" },
	Default = "Noon",
	Callback = function(option)
		local map = { Morning = "06:00:00", Noon = "12:00:00", Night = "00:00:00" }
		game.Lighting.TimeOfDay = map[option]
	end,
})

Visual:AddDropdown({
	Name = "Choose Features",
	Multi = true,
	Options = { "No Fog", "Low Detail", "Disable Shadows" },
	Callback = function(selected)
		print(selected)
	end,
})

Misc:AddSection("Settings")

Misc:AddTextbox({
	Name = "Walk Speed",
	Placeholder = "16",
	Callback = function(text, enter)
		local n = tonumber(text)
		if n and game.Players.LocalPlayer.Character then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = n
		end
	end,
})

Misc:AddKeybind({
	Name = "Toggle UI Keybind",
	Default = Enum.KeyCode.RightShift,
	Callback = function()
		Window:Notify({ Title = "Keybind", Content = "Keybind pressed!" })
	end,
})

Misc:AddLabel("Made with NoxLib. Tekan tombol merah (X) di kiri atas untuk Destroy semua UI.")

Window:Notify({ Title = "Welcome", Content = "Nox Hub loaded successfully!", Duration = 5 })
