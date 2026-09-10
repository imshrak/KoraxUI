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

-- ==================== APPEARANCE (Left) ====================
local AppearanceGroup = Tabs.Settings:AddGroupbox({
	Side = 1,
	Name = "Appearance",
	IconName = "eye",
})

AppearanceGroup:AddDropdown("Theme", {
	Text = "Theme",
	Values = {"Dark", "Midnight", "AMOLED", "Light", "Rose", "Ocean"},
	Value = "Dark",
	Callback = function(Value)
		local Schemes = {
			Dark = {
				BackgroundColor = Color3.fromRGB(15, 15, 15),
				MainColor = Color3.fromRGB(25, 25, 25),
				OutlineColor = Color3.fromRGB(40, 40, 40),
			},
			Midnight = {
				BackgroundColor = Color3.fromRGB(10, 10, 30),
				MainColor = Color3.fromRGB(15, 15, 45),
				OutlineColor = Color3.fromRGB(30, 30, 60),
			},
			AMOLED = {
				BackgroundColor = Color3.fromRGB(0, 0, 0),
				MainColor = Color3.fromRGB(10, 10, 10),
				OutlineColor = Color3.fromRGB(20, 20, 20),
			},
			Light = {
				BackgroundColor = Color3.fromRGB(235, 235, 235),
				MainColor = Color3.fromRGB(250, 250, 250),
				OutlineColor = Color3.fromRGB(200, 200, 200),
			},
			Rose = {
				BackgroundColor = Color3.fromRGB(25, 10, 15),
				MainColor = Color3.fromRGB(35, 15, 20),
				OutlineColor = Color3.fromRGB(55, 25, 35),
			},
			Ocean = {
				BackgroundColor = Color3.fromRGB(10, 15, 25),
				MainColor = Color3.fromRGB(15, 22, 35),
				OutlineColor = Color3.fromRGB(25, 35, 55),
			},
		}
		local Scheme = Schemes[Value]
		if Scheme then
			for k, v in Scheme do
				Library.Scheme[k] = v
			end
			Library:Notify({Title = "Theme", Text = "Applied " .. Value .. " theme", Time = 2})
		end
	end,
})

AppearanceGroup:AddDropdown("Accent", {
	Text = "Accent Color",
	Values = {"Purple", "Blue", "Red", "Green", "Orange", "Cyan", "Pink"},
	Value = "Purple",
	Callback = function(Value)
		local Colors = {
			Purple = Color3.fromRGB(125, 85, 255),
			Blue = Color3.fromRGB(85, 140, 255),
			Red = Color3.fromRGB(255, 85, 85),
			Green = Color3.fromRGB(85, 200, 85),
			Orange = Color3.fromRGB(255, 160, 50),
			Cyan = Color3.fromRGB(85, 200, 255),
			Pink = Color3.fromRGB(255, 100, 180),
		}
		if Colors[Value] then
			Library.Scheme.AccentColor = Colors[Value]
			Library:Notify({Title = "Accent", Text = "Changed accent to " .. Value, Time = 2})
		end
	end,
})

AppearanceGroup:AddDropdown("MenuToggleKey", {
	Text = "Menu Toggle Key",
	Values = {"RightControl", "LeftAlt", "Tab", "F2", "F3", "F4", "Semicolon"},
	Value = "RightControl",
	Callback = function(Value)
		local KeyMap = {
			RightControl = Enum.KeyCode.RightControl,
			LeftAlt = Enum.KeyCode.LeftAlt,
			Tab = Enum.KeyCode.Tab,
			F2 = Enum.KeyCode.F2,
			F3 = Enum.KeyCode.F3,
			F4 = Enum.KeyCode.F4,
			Semicolon = Enum.KeyCode.Semicolon,
		}
		if KeyMap[Value] then
			Library.ToggleKeybind = KeyMap[Value]
			Library:Notify({Title = "Keybind", Text = "Menu toggles with " .. Value, Time = 2})
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
		local MainFrame = Library.Window
		if MainFrame then
			local H, S, V = Library.Scheme.BackgroundColor:ToHSV()
			MainFrame.BackgroundColor3 = Color3.fromHSV(H, S, V)
			MainFrame.BackgroundTransparency = 1 - (Value / 100)
		end
	end,
})

-- ==================== TOGGLES / BEHAVIOR (Left) ====================
local BehaviorGroup = Tabs.Settings:AddGroupbox({
	Side = 1,
	Name = "Behavior",
	IconName = "settings",
})

BehaviorGroup:AddToggle("AutoShow", {
	Text = "Auto-show menu on join",
	Default = true,
	Callback = function(Value)
		Library:Notify({Title = "Behavior", Text = Value and "Menu will auto-show" or "Menu won't auto-show", Time = 2})
	end,
})

BehaviorGroup:AddToggle("ShowKeybinds", {
	Text = "Show keybind buttons",
	Default = true,
	Callback = function(Value)
		for _, toggle in Toggles do
			if toggle and toggle.KeybindBtn then
				toggle.KeybindBtn.Visible = Value and toggle.Keybind ~= nil
			end
		end
	end,
})

BehaviorGroup:AddToggle("SoundEffects", {
	Text = "Sound effects",
	Default = false,
	Callback = function(Value)
		Library:Notify({Title = "Sound", Text = Value and "Sound effects enabled" or "Sound effects disabled", Time = 2})
	end,
})

BehaviorGroup:AddSlider("NotifDuration", {
	Text = "Notification Duration",
	Default = 3,
	Min = 1,
	Max = 10,
	Suffix = "s",
})

BehaviorGroup:AddDropdown("NotifSide", {
	Text = "Notification Position",
	Values = {"Right", "Left"},
	Value = "Right",
	Callback = function(Value)
		Library.NotifySide = Value
	end,
})

-- ==================== KEYBINDS (Left) ====================
local KeybindGroup = Tabs.Settings:AddGroupbox({
	Side = 1,
	Name = "Keybinds",
	IconName = "lock",
})

KeybindGroup:AddLabel("Click a keybind button next to a toggle to rebind. Right-click to clear.")

local function RefreshKeybindLabels()
	for _, child in ipairs(KeybindGroup.Container:GetChildren()) do
		if child:IsA("TextLabel") and child.Name == "KBEntry" then
			child:Destroy()
		end
	end
	for idx, bind in Library.Keybinds do
		if bind and bind.KeyCode then
			KeybindGroup:AddLabel(idx .. "  ->  " .. bind.KeyCode.Name)
				.Holder.Name = "KBEntry"
		end
	end
end

KeybindGroup:AddButton({
	Text = "Refresh Keybind List",
	Func = function()
		RefreshKeybindLabels()
		Library:Notify({Title = "Keybinds", Text = "Keybind list refreshed", Time = 1.5})
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
})

local ConfigName = ConfigGroup:AddInput("ConfigName", {
	Text = "Config Name",
	Default = "default",
	Placeholder = "Enter config name...",
})

ConfigGroup:AddButton({
	Text = "Save Config",
	Func = function()
		local name = Options.ConfigName and Options.ConfigName.Value or "default"
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
			if typeof(option) == "table" and option.Value ~= nil and idx ~= "ConfigName" then
				config[idx] = { Value = option.Value }
			end
		end
		writefile("KoraxUI_Configs/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(config))
		Library:Notify({Title = "Config", Text = "Saved config: " .. name, Time = 2})
	end,
})

ConfigGroup:AddButton({
	Text = "Load Config",
	Func = function()
		local name = Options.ConfigName and Options.ConfigName.Value or "default"
		local path = "KoraxUI_Configs/" .. name .. ".json"
		if not isfile(path) then
			Library:Notify({Title = "Config", Text = "Config not found: " .. name, Time = 2})
			return
		end
		local config = game:GetService("HttpService"):JSONDecode(readfile(path))
		for idx, data in config do
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
		Library:Notify({Title = "Config", Text = "Loaded config: " .. name, Time = 2})
	end,
})

ConfigGroup:AddButton({
	Text = "Delete Config",
	Func = function()
		local name = Options.ConfigName and Options.ConfigName.Value or "default"
		local path = "KoraxUI_Configs/" .. name .. ".json"
		if isfile(path) then
			delfile(path)
			Library:Notify({Title = "Config", Text = "Deleted config: " .. name, Time = 2})
		else
			Library:Notify({Title = "Config", Text = "Config not found: " .. name, Time = 2})
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
			if typeof(option) == "table" and option.SetValue and idx ~= "ConfigName" then
				if idx == "Theme" then option:SetValue("Dark")
				elseif idx == "Accent" then option:SetValue("Purple")
				elseif idx == "MenuToggleKey" then option:SetValue("RightControl")
				elseif idx == "MenuKeybind" then option:SetValue(100)
				elseif idx == "NotifDuration" then option:SetValue(3)
				elseif idx == "NotifSide" then option:SetValue("Right") end
			end
		end
		Library.Scheme.AccentColor = Color3.fromRGB(125, 85, 255)
		Library.Scheme.BackgroundColor = Color3.fromRGB(15, 15, 15)
		Library.Scheme.MainColor = Color3.fromRGB(25, 25, 25)
		Library.Scheme.OutlineColor = Color3.fromRGB(40, 40, 40)
		Library:Notify({Title = "Config", Text = "Reset to defaults", Time = 2})
	end,
	Risky = true,
})

-- ==================== INFORMATION (Right) ====================
local InfoGroup = Tabs.Settings:AddGroupbox({
	Side = 2,
	Name = "Information",
	IconName = "info",
})

InfoGroup:AddLabel("KoraxUI v1.0")

InfoGroup:AddButton({
	Text = "Copy Discord Link",
	Func = function()
		if setclipboard then
			setclipboard("https://discord.gg/koraxui")
			Library:Notify({Title = "Discord", Text = "Discord link copied!", Time = 2})
		end
	end,
})

InfoGroup:AddButton({
	Text = "Copy GitHub Link",
	Func = function()
		if setclipboard then
			setclipboard("https://github.com/imshrak/KoraxUI")
			Library:Notify({Title = "GitHub", Text = "GitHub link copied!", Time = 2})
		end
	end,
})

InfoGroup:AddButton({
	Text = "Join Discord Server",
	Func = function()
		if request then
			request({Url = "https://discord.gg/koraxui", Method = "GET"})
		end
	end,
})

InfoGroup:AddLabel("Player: " .. LocalPlayer.Name)
InfoGroup:AddLabel("User ID: " .. LocalPlayer.UserId)

-- ==================== NOTIFICATIONS (Right) ====================
local NotifGroup = Tabs.Settings:AddGroupbox({
	Side = 2,
	Name = "Notifications",
	IconName = "bell",
})

NotifGroup:AddButton({
	Text = "Test Notification",
	Func = function()
		Library:Notify({Title = "Test", Text = "This is a test notification!", Time = 3})
	end,
})

NotifGroup:AddButton({
	Text = "Clear All Notifications",
	Func = function()
		for _, notif in Library.Notifications do
			if notif and notif.Parent then notif:Destroy() end
		end
		Library.Notifications = {}
	end,
})

NotifGroup:AddDropdown("NotifStyle", {
	Text = "Notification Style",
	Values = {"Default", "Minimal", "Detailed"},
	Value = "Default",
	Callback = function(Value)
		Library:Notify({Title = "Style", Text = "Notification style: " .. Value, Time = 2})
	end,
})

NotifGroup:AddToggle("NotifSound", {
	Text = "Notification Sound",
	Default = false,
	Callback = function(Value)
		Library:Notify({Title = "Sound", Text = Value and "Notification sounds on" or "Notification sounds off", Time = 1.5})
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

print("KoraxUI Example loaded!")
print("Press RightControl to toggle the menu")
