local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Library = loadstring(readfile("Library.lua"))()

local Toggles = Library.Toggles or {}
local Options = Library.Options or {}

local Window = Library:CreateWindow({
	Title = "Korax UI Example",
	Footer = "v1.0 | RightCtrl to toggle",
	Size = UDim2.fromOffset(500, 400),
	ToggleKeybind = Enum.KeyCode.RightControl,
	AutoShow = true,
})

local Tabs = {
	Movement = Window:AddTab("Movement", "move"),
	Visual = Window:AddTab("Visual", "eye"),
	Settings = Window:AddTab("Settings", "settings"),
}

-- ==================== MOVEMENT TAB ====================
local MoveGroup = Tabs.Movement:AddGroupbox({
	Side = 1,
	Name = "Movement",
	IconName = "activity",
})

local FLYING = false
local flyKeyDown = nil
local flyKeyUp = nil

MoveGroup:AddToggle("Flight", {
	Text = "Flight",
	Default = false,
	Keybind = Enum.KeyCode.F,
	Callback = function(Value)
		local character = LocalPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then return end

		if Value then
			FLYING = true

			local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			local SPEED = 0

			local BG = Instance.new("BodyGyro")
			BG.P = 9e4
			BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			BG.CFrame = hrp.CFrame
			BG.Parent = hrp

			local BV = Instance.new("BodyVelocity")
			BV.Velocity = Vector3.new(0, 0, 0)
			BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			BV.Parent = hrp

			humanoid.PlatformStand = true

			flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
				if processed then return end
				if input.KeyCode == Enum.KeyCode.W then
					CONTROL.F = 1
				elseif input.KeyCode == Enum.KeyCode.S then
					CONTROL.B = -1
				elseif input.KeyCode == Enum.KeyCode.A then
					CONTROL.L = -1
				elseif input.KeyCode == Enum.KeyCode.D then
					CONTROL.R = 1
				elseif input.KeyCode == Enum.KeyCode.E then
					CONTROL.Q = 2
				elseif input.KeyCode == Enum.KeyCode.Q then
					CONTROL.E = -2
				end
			end)

			flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
				if processed then return end
				if input.KeyCode == Enum.KeyCode.W then
					CONTROL.F = 0
				elseif input.KeyCode == Enum.KeyCode.S then
					CONTROL.B = 0
				elseif input.KeyCode == Enum.KeyCode.A then
					CONTROL.L = 0
				elseif input.KeyCode == Enum.KeyCode.D then
					CONTROL.R = 0
				elseif input.KeyCode == Enum.KeyCode.E then
					CONTROL.Q = 0
				elseif input.KeyCode == Enum.KeyCode.Q then
					CONTROL.E = 0
				end
			end)

			task.spawn(function()
				repeat task.wait()
					local camera = workspace.CurrentCamera
					if not hrp.Parent then break end

					local flyspeed = Toggles.FlightSpeed and Toggles.FlightSpeed.Value or 50

					if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
						SPEED = flyspeed
					elseif SPEED ~= 0 then
						SPEED = 0
					end

					if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
						BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
						lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
					elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
						BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					else
						BV.Velocity = Vector3.new(0, 0, 0)
					end

					BG.CFrame = camera.CFrame
				until not FLYING

				CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
				lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
				SPEED = 0
				BG:Destroy()
				BV:Destroy()
				if humanoid then humanoid.PlatformStand = false end
			end)
		else
			FLYING = false
			if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
			if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
			if humanoid then humanoid.PlatformStand = false end
		end
	end,
})

MoveGroup:AddSlider("FlightSpeed", {
	Text = "Flight Speed",
	Default = 50,
	Min = 10,
	Max = 200,
})

MoveGroup:AddToggle("Speed", {
	Text = "Speed",
	Default = false,
	Keybind = Enum.KeyCode.LeftShift,
	Callback = function(Value)
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = Value and (Toggles.SpeedValue and Toggles.SpeedValue.Value or 16) or 16
		end
	end,
})

MoveGroup:AddSlider("SpeedValue", {
	Text = "Speed Value",
	Default = 16,
	Min = 16,
	Max = 200,
	Callback = function(Value)
		if Toggles.Speed and Toggles.Speed.Value then
			local character = LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.WalkSpeed = Value end
		end
	end,
})

local InfJumpConnection = nil
local InfJumpEnabled = false
MoveGroup:AddToggle("InfJump", {
	Text = "Infinite Jump",
	Default = false,
	Keybind = Enum.KeyCode.Space,
	Callback = function(Value)
		InfJumpEnabled = Value
		if Value then
			InfJumpConnection = UserInputService.JumpRequest:Connect(function()
				if InfJumpEnabled then
					local character = LocalPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
				end
			end)
		else
			if InfJumpConnection then InfJumpConnection:Disconnect() InfJumpConnection = nil end
		end
	end,
})

-- ==================== VISUAL TAB ====================
local VisGroup = Tabs.Visual:AddGroupbox({
	Side = 1,
	Name = "Visuals",
	IconName = "eye",
})

local Highlights = {}
local function AddHighlights()
	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer and player.Character then
			if not Highlights[player] then
				local hl = Instance.new("Highlight")
				hl.FillColor = Library.Scheme.AccentColor
				hl.OutlineColor = Color3.new(1, 1, 1)
				hl.FillTransparency = 0.5
				hl.OutlineTransparency = 0
				hl.Adornee = player.Character
				hl.Parent = player.Character
				Highlights[player] = hl
			end
		end
	end
end

local function RemoveHighlights()
	for player, hl in Highlights do
		if hl then hl:Destroy() end
	end
	Highlights = {}
end

VisGroup:AddToggle("Highlight", {
	Text = "Highlight Players",
	Default = false,
	Callback = function(Value)
		if Value then AddHighlights() else RemoveHighlights() end
	end,
})

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		if Toggles.Highlight and Toggles.Highlight.Value then
			task.wait(1)
			AddHighlights()
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if Highlights[player] then
		Highlights[player]:Destroy()
		Highlights[player] = nil
	end
end)

-- ==================== SETTINGS TAB ====================

local ThemePresets = {
	Dark = {
		BackgroundColor = Color3.fromRGB(15, 15, 15),
		MainColor = Color3.fromRGB(25, 25, 25),
		OutlineColor = Color3.fromRGB(40, 40, 40),
		AccentColor = Color3.fromRGB(125, 85, 255),
	},
	Midnight = {
		BackgroundColor = Color3.fromRGB(10, 10, 30),
		MainColor = Color3.fromRGB(15, 15, 45),
		OutlineColor = Color3.fromRGB(30, 30, 60),
		AccentColor = Color3.fromRGB(100, 120, 255),
	},
	AMOLED = {
		BackgroundColor = Color3.fromRGB(0, 0, 0),
		MainColor = Color3.fromRGB(10, 10, 10),
		OutlineColor = Color3.fromRGB(20, 20, 20),
		AccentColor = Color3.fromRGB(125, 85, 255),
	},
	Rose = {
		BackgroundColor = Color3.fromRGB(25, 10, 15),
		MainColor = Color3.fromRGB(35, 15, 20),
		OutlineColor = Color3.fromRGB(55, 25, 35),
		AccentColor = Color3.fromRGB(255, 100, 130),
	},
	Ocean = {
		BackgroundColor = Color3.fromRGB(10, 15, 25),
		MainColor = Color3.fromRGB(15, 22, 35),
		OutlineColor = Color3.fromRGB(25, 35, 55),
		AccentColor = Color3.fromRGB(85, 180, 255),
	},
	Forest = {
		BackgroundColor = Color3.fromRGB(10, 18, 12),
		MainColor = Color3.fromRGB(15, 28, 18),
		OutlineColor = Color3.fromRGB(25, 45, 30),
		AccentColor = Color3.fromRGB(85, 200, 120),
	},
	Candy = {
		BackgroundColor = Color3.fromRGB(25, 12, 22),
		MainColor = Color3.fromRGB(35, 18, 30),
		OutlineColor = Color3.fromRGB(55, 28, 48),
		AccentColor = Color3.fromRGB(255, 100, 200),
	},
	Solar = {
		BackgroundColor = Color3.fromRGB(20, 18, 12),
		MainColor = Color3.fromRGB(30, 28, 18),
		OutlineColor = Color3.fromRGB(50, 45, 28),
		AccentColor = Color3.fromRGB(255, 180, 50),
	},
}

local AccentPresets = {
	Purple = Color3.fromRGB(125, 85, 255),
	Blue = Color3.fromRGB(85, 140, 255),
	Red = Color3.fromRGB(255, 85, 85),
	Green = Color3.fromRGB(85, 200, 85),
	Orange = Color3.fromRGB(255, 160, 50),
	Cyan = Color3.fromRGB(85, 200, 255),
	Pink = Color3.fromRGB(255, 100, 180),
	Yellow = Color3.fromRGB(255, 220, 60),
	Teal = Color3.fromRGB(60, 200, 180),
	Crimson = Color3.fromRGB(220, 60, 80),
}

local FontPresets = {
	"Code",
	"Gotham",
	"GothamBold",
	"Roboto",
	"RobotoMono",
	"SourceSans",
	"Ubuntu",
}

local KeyPresets = {
	"RightControl", "LeftAlt", "Tab", "F2", "F3", "F4",
	"F5", "F6", "Backquote", "Semicolon",
}

-- ==================== APPEARANCE (Left) ====================
local AppearanceGroup = Tabs.Settings:AddGroupbox({
	Side = 1,
	Name = "Appearance",
	IconName = "eye",
	Description = "Customize the look and feel",
})

AppearanceGroup:AddDropdown("Theme", {
	Text = "Theme Preset",
	Values = {"Dark", "Midnight", "AMOLED", "Rose", "Ocean", "Forest", "Candy", "Solar"},
	Value = "Dark",
	Callback = function(Value)
		local Scheme = ThemePresets[Value]
		if Scheme then
			for k, v in Scheme do
				Library.Scheme[k] = v
			end
			Library:Notify({Title = "Appearance", Text = "Applied " .. Value .. " theme", Time = 2})
		end
	end,
})

AppearanceGroup:AddDropdown("Accent", {
	Text = "Accent Color",
	Values = {"Purple", "Blue", "Red", "Green", "Orange", "Cyan", "Pink", "Yellow", "Teal", "Crimson"},
	Value = "Purple",
	Callback = function(Value)
		if AccentPresets[Value] then
			Library.Scheme.AccentColor = AccentPresets[Value]
			Library:Notify({Title = "Appearance", Text = "Accent: " .. Value, Time = 1.5})
		end
	end,
})

AppearanceGroup:AddSlider("MenuKeybind", {
	Text = "Menu Opacity",
	Default = 100,
	Min = 30,
	Max = 100,
	Suffix = "%",
	Callback = function(Value)
		Library:SetOpacity(Value / 100)
	end,
})

AppearanceGroup:AddDropdown("MenuToggleKey", {
	Text = "Menu Toggle Key",
	Values = KeyPresets,
	Value = "RightControl",
	Callback = function(Value)
		local KeyMap = {}
		for _, name in KeyPresets do
			local ok, kc = pcall(function() return Enum.KeyCode[name] end)
			if ok then KeyMap[name] = kc end
		end
		if KeyMap[Value] then
			Library.ToggleKeybind = KeyMap[Value]
			Library:Notify({Title = "Keybind", Text = "Menu toggles with " .. Value, Time = 1.5})
		end
	end,
})

-- ==================== EDITOR (Left) ====================
local EditorGroup = Tabs.Settings:AddGroupbox({
	Side = 1,
	Name = "Editor",
	IconName = "edit",
	Description = "Editor and interface settings",
})

EditorGroup:AddDropdown("Font", {
	Text = "UI Font",
	Values = FontPresets,
	Value = "Code",
	Callback = function(Value)
		local ok, font = pcall(function() return Font.fromEnum(Enum.Font[Value]) end)
		if ok and font then
			Library.Scheme.Font = font
			Library:Notify({Title = "Editor", Text = "Font: " .. Value, Time = 1.5})
		end
	end,
})

EditorGroup:AddSlider("FontSize", {
	Text = "Font Size",
	Default = 14,
	Min = 10,
	Max = 20,
	Suffix = "px",
})

EditorGroup:AddSlider("CornerSize", {
	Text = "Corner Radius",
	Default = 4,
	Min = 0,
	Max = 12,
	Suffix = "px",
})

EditorGroup:AddToggle("CompactMode", {
	Text = "Compact Mode",
	Default = false,
	Callback = function(Value)
		Library:Notify({Title = "Editor", Text = Value and "Compact mode on" or "Compact mode off", Time = 1.5})
	end,
})

EditorGroup:AddToggle("AnimatedToggles", {
	Text = "Animated Toggles",
	Default = true,
})

-- ==================== KEYBINDS (Left) ====================
local KeybindGroup = Tabs.Settings:AddGroupbox({
	Side = 1,
	Name = "Keybinds",
	IconName = "lock",
	Description = "Manage all keybinds",
})

KeybindGroup:AddLabel("Click a keybind button to rebind. Right-click to clear.")

local function RefreshKeybindLabels()
	for _, child in ipairs(KeybindGroup.Container:GetChildren()) do
		if child:IsA("TextLabel") and child.Name == "KBEntry" then
			child:Destroy()
		end
	end
	for idx, bind in Library.Keybinds do
		if bind and bind.KeyCode then
			KeybindGroup:AddLabel(idx .. "  →  " .. bind.KeyCode.Name)
				.Holder.Name = "KBEntry"
		end
	end
end

KeybindGroup:AddButton({
	Text = "Refresh Keybind List",
	Func = function()
		RefreshKeybindLabels()
		Library:Notify({Title = "Keybinds", Text = "List refreshed", Time = 1.5})
	end,
})

KeybindGroup:AddButton({
	Text = "Reset All Keybinds",
	Func = function()
		Library:ClearKeybinds()
		for _, child in ipairs(KeybindGroup.Container:GetChildren()) do
			if child:IsA("TextLabel") and child.Name == "KBEntry" then
				child:Destroy()
			end
		end
		Library:Notify({Title = "Keybinds", Text = "All keybinds cleared", Time = 2})
	end,
	Risky = true,
})

-- ==================== CONFIGURATION (Right) ====================
local ConfigGroup = Tabs.Settings:AddGroupbox({
	Side = 2,
	Name = "Configuration",
	IconName = "save",
	Description = "Save, load, and manage configs",
})

ConfigGroup:AddDropdown("SavedConfigs", {
	Text = "Saved Configs",
	Values = {"default"},
	Value = "default",
})

ConfigGroup:AddInput("ConfigName", {
	Text = "Config Name",
	Default = "default",
	Placeholder = "Enter config name...",
})

local function RefreshConfigList()
	local configs = {}
	if isfolder("KoraxUI_Configs") then
		local ok, files = pcall(function() return listfiles("KoraxUI_Configs") end)
		if ok and files then
			for _, file in files do
				local name = file:match("([^/\\]+)%.json$")
				if name then
					table.insert(configs, name)
				end
			end
		end
	end
	if #configs == 0 then
		configs = {"default"}
	end
	if Options.SavedConfigs then
		Options.SavedConfigs:SetValues(configs)
		Options.SavedConfigs:SetValue(configs[1])
	end
end

ConfigGroup:AddButton({
	Text = "Save Config",
	Func = function()
		local name = Options.ConfigName and Options.ConfigName.Value or "default"
		if not isfolder("KoraxUI_Configs") then
			pcall(function() makefolder("KoraxUI_Configs") end)
		end
		local config = {}
		for idx, toggle in Toggles do
			if typeof(toggle) == "table" and toggle.Value ~= nil then
				config[idx] = { Value = toggle.Value }
				if toggle.Keybind then
					config[idx].Keybind = toggle.Keybind.EnumType == "Enum.KeyCode" and toggle.Keybind.Name or nil
				end
			end
		end
		for idx, option in Options do
			if typeof(option) == "table" and option.Value ~= nil and idx ~= "ConfigName" and idx ~= "SavedConfigs" then
				config[idx] = { Value = option.Value }
			end
		end
		config._theme = Options.Theme and Options.Theme.Value or "Dark"
		config._accent = Options.Accent and Options.Accent.Value or "Purple"
		writefile("KoraxUI_Configs/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(config))
		RefreshConfigList()
		Library:Notify({Title = "Config", Text = "Saved: " .. name, Time = 2})
	end,
})

ConfigGroup:AddButton({
	Text = "Load Config",
	Func = function()
		local name = Options.SavedConfigs and Options.SavedConfigs.Value or (Options.ConfigName and Options.ConfigName.Value or "default")
		local path = "KoraxUI_Configs/" .. name .. ".json"
		if not isfile(path) then
			Library:Notify({Title = "Config", Text = "Not found: " .. name, Time = 2})
			return
		end
		local config = game:GetService("HttpService"):JSONDecode(readfile(path))
		for idx, data in config do
			if idx:sub(1, 1) == "_" then continue end
			if Toggles[idx] and typeof(Toggles[idx]) == "table" and Toggles[idx].SetValue then
				Toggles[idx]:SetValue(data.Value)
				if data.Keybind then
					local ok, key = pcall(function() return Enum.KeyCode[data.Keybind] end)
					if ok and key then Toggles[idx]:SetKeybind(key) end
				end
			end
			if Options[idx] and typeof(Options[idx]) == "table" and Options[idx].SetValue then
				Options[idx]:SetValue(data.Value)
			end
		end
		if config._theme and Options.Theme then Options.Theme:SetValue(config._theme) end
		if config._accent and Options.Accent then Options.Accent:SetValue(config._accent) end
		Library:Notify({Title = "Config", Text = "Loaded: " .. name, Time = 2})
	end,
})

ConfigGroup:AddButton({
	Text = "Delete Config",
	Func = function()
		local name = Options.SavedConfigs and Options.SavedConfigs.Value or "default"
		local path = "KoraxUI_Configs/" .. name .. ".json"
		if isfile(path) then
			delfile(path)
			RefreshConfigList()
			Library:Notify({Title = "Config", Text = "Deleted: " .. name, Time = 2})
		else
			Library:Notify({Title = "Config", Text = "Not found: " .. name, Time = 2})
		end
	end,
	Risky = true,
})

ConfigGroup:AddButton({
	Text = "Reset to Defaults",
	Func = function()
		for idx, toggle in Toggles do
			if typeof(toggle) == "table" and toggle.SetValue then
				toggle:SetValue(false)
			end
		end
		for idx, option in Options do
			if typeof(option) == "table" and option.SetValue and idx ~= "ConfigName" and idx ~= "SavedConfigs" then
				if idx == "Theme" then option:SetValue("Dark")
				elseif idx == "Accent" then option:SetValue("Purple")
				elseif idx == "MenuToggleKey" then option:SetValue("RightControl")
				elseif idx == "MenuKeybind" then option:SetValue(100)
				elseif idx == "Font" then option:SetValue("Code")
				elseif idx == "FontSize" then option:SetValue(14)
				elseif idx == "CornerSize" then option:SetValue(4) end
			end
		end
		Library.Scheme.AccentColor = ThemePresets.Dark.AccentColor
		Library.Scheme.BackgroundColor = ThemePresets.Dark.BackgroundColor
		Library.Scheme.MainColor = ThemePresets.Dark.MainColor
		Library.Scheme.OutlineColor = ThemePresets.Dark.OutlineColor
		Library:SetOpacity(1)
		Library:Notify({Title = "Config", Text = "Reset to defaults", Time = 2})
	end,
	Risky = true,
})

-- ==================== NOTIFICATIONS (Right) ====================
local NotifGroup = Tabs.Settings:AddGroupbox({
	Side = 2,
	Name = "Notifications",
	IconName = "bell",
	Description = "Notification preferences",
})

NotifGroup:AddDropdown("NotifSide", {
	Text = "Position",
	Values = {"Right", "Left"},
	Value = "Right",
	Callback = function(Value)
		Library.NotifySide = Value
	end,
})

NotifGroup:AddSlider("NotifDuration", {
	Text = "Duration",
	Default = 3,
	Min = 1,
	Max = 10,
	Suffix = "s",
})

NotifGroup:AddDropdown("NotifStyle", {
	Text = "Style",
	Values = {"Default", "Minimal", "Detailed"},
	Value = "Default",
})

NotifGroup:AddToggle("NotifSound", {
	Text = "Sound",
	Default = false,
})

NotifGroup:AddButton({
	Text = "Test Notification",
	Func = function()
		Library:Notify({Title = "Test", Text = "This is a test notification!", Time = 3})
	end,
})

NotifGroup:AddButton({
	Text = "Clear All",
	Func = function()
		for _, notif in Library.Notifications do
			if notif and notif.Parent then notif:Destroy() end
		end
		Library.Notifications = {}
	end,
})

-- ==================== ABOUT (Right) ====================
local AboutGroup = Tabs.Settings:AddGroupbox({
	Side = 2,
	Name = "About",
	IconName = "info",
	Description = "KoraxUI information",
})

AboutGroup:AddLabel("KoraxUI v1.0")
AboutGroup:AddLabel("Player: " .. LocalPlayer.Name)
AboutGroup:AddLabel("User ID: " .. LocalPlayer.UserId)

AboutGroup:AddButton({
	Text = "Copy Discord Link",
	Func = function()
		if setclipboard then
			setclipboard("https://discord.gg/koraxui")
			Library:Notify({Title = "Link", Text = "Discord link copied!", Time = 1.5})
		end
	end,
})

AboutGroup:AddButton({
	Text = "Copy GitHub Link",
	Func = function()
		if setclipboard then
			setclipboard("https://github.com/imshrak/KoraxUI")
			Library:Notify({Title = "Link", Text = "GitHub link copied!", Time = 1.5})
		end
	end,
})

-- ==================== CONNECTIONS ====================
LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	if Toggles.Speed and Toggles.Speed.Value then
		humanoid.WalkSpeed = Toggles.SpeedValue and Toggles.SpeedValue.Value or 16
	end
end)

-- Create configs folder if not present
if not isfolder("KoraxUI_Configs") then
	pcall(function() makefolder("KoraxUI_Configs") end)
end
RefreshConfigList()

print("KoraxUI Example loaded!")
print("Press RightControl to toggle the menu")
