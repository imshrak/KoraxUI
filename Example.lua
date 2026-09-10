local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxUI/master/Library.lua"))()

local Options = Library.Options or {}
local Toggles = Library.Toggles or {}

local Window = Library:CreateWindow({
    Title = "KoraxUI",
    Footer = "v1.0 | RightCtrl to toggle",
    Size = UDim2.fromOffset(620, 450),
    Position = UDim2.fromOffset(100, 100),
    ToggleKeybind = Enum.KeyCode.RightControl,
    NotifySide = "Right",
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Combat = Window:AddTab("Combat", "star"),
    Misc = Window:AddTab("Misc", "settings"),
}

-- Main Tab
local LegitGroup = Tabs.Main:AddGroupbox({
    Side = 1,
    Name = "Legit",
    IconName = "user",
})

LegitGroup:AddToggle("Aimbot", {
    Text = "Aimbot",
    Default = false,
    Callback = function(Value)
        Library:Notify({ Title = "Aimbot", Text = Value and "Enabled" or "Disabled", Time = 2 })
    end,
})

LegitGroup:AddSlider("AimbotFOV", {
    Text = "FOV",
    Default = 60,
    Min = 10,
    Max = 180,
    Suffix = "°",
})

LegitGroup:AddSlider("AimbotSmoothing", {
    Text = "Smoothing",
    Default = 5,
    Min = 1,
    Max = 20,
})

LegitGroup:AddDropdown("AimbotBone", {
    Text = "Target Bone",
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Value = "Head",
})

local VisualsGroup = Tabs.Main:AddGroupbox({
    Side = 2,
    Name = "Visuals",
    IconName = "image",
})

VisualsGroup:AddToggle("ESP", {
    Text = "ESP",
    Default = false,
})

VisualsGroup:AddToggle("BoxESP", {
    Text = "Box ESP",
    Default = true,
})

VisualsGroup:AddToggle("NameESP", {
    Text = "Name ESP",
    Default = true,
})

VisualsGroup:AddToggle("HealthBar", {
    Text = "Health Bar",
    Default = false,
})

VisualsGroup:AddSlider("ESPRange", {
    Text = "ESP Range",
    Default = 500,
    Min = 50,
    Max = 2000,
    Suffix = "m",
})

VisualsGroup:AddDropdown("BoxType", {
    Text = "Box Style",
    Values = { "2D", "3D", "Corner" },
    Value = "2D",
})

-- Combat Tab
local RageGroup = Tabs.Combat:AddGroupbox({
    Side = 1,
    Name = "Rage",
    IconName = "star",
})

RageGroup:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Default = false,
})

RageGroup:AddToggle("Wallbang", {
    Text = "Wallbang",
    Default = false,
})

RageGroup:AddSlider("HitChance", {
    Text = "Hit Chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Suffix = "%",
})

RageGroup:AddDivider()

RageGroup:AddLabel("Target Settings")

RageGroup:AddDropdown("TargetPart", {
    Text = "Target Part",
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Random" },
    Value = "Head",
})

RageGroup:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = true,
})

RageGroup:AddToggle("AliveCheck", {
    Text = "Alive Check",
    Default = true,
})

local WeaponGroup = Tabs.Combat:AddGroupbox({
    Side = 2,
    Name = "Weapon",
    IconName = "wrench",
})

WeaponGroup:AddToggle("NoRecoil", {
    Text = "No Recoil",
    Default = false,
})

WeaponGroup:AddToggle("NoSpread", {
    Text = "No Spread",
    Default = false,
})

WeaponGroup:AddSlider("FireRate", {
    Text = "Fire Rate Multiplier",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Suffix = "x",
})

WeaponGroup:AddInput("CustomCFov", {
    Text = "Custom Value",
    Default = "",
    Placeholder = "Enter a value...",
})

-- Misc Tab
local MiscGroup = Tabs.Misc:AddGroupbox({
    Side = 1,
    Name = "General",
    IconName = "settings",
})

MiscGroup:AddToggle("AutoFarm", {
    Text = "Auto Farm",
    Default = false,
})

MiscGroup:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 0,
    Max = 100,
})

MiscGroup:AddSlider("JumpPower", {
    Text = "Jump Power",
    Default = 50,
    Min = 0,
    Max = 200,
})

MiscGroup:AddButton({
    Text = "Teleport to Spawn",
    Func = function()
        Library:Notify({ Title = "Teleport", Text = "Teleported to spawn!", Time = 2 })
    end,
})

MiscGroup:AddButton({
    Text = "Reset Character",
    Func = function()
        Library:Notify({ Title = "Reset", Text = "Character reset!", Time = 2 })
    end,
    Risky = true,
})

MiscGroup:AddDivider("Keybinds")

MiscGroup:AddToggle("SpeedBind", {
    Text = "Speed Toggle (Hold Shift)",
    Default = false,
})

local ConfigGroup = Tabs.Misc:AddGroupbox({
    Side = 2,
    Name = "Config",
    IconName = "folder",
})

ConfigGroup:AddInput("ConfigName", {
    Text = "Config Name",
    Default = "default",
    Placeholder = "Enter config name...",
})

ConfigGroup:AddDropdown("ConfigList", {
    Text = "Saved Configs",
    Values = { "default", "legit", "rage" },
    Value = "default",
})

ConfigGroup:AddButton({
    Text = "Load Config",
    Func = function()
        Library:Notify({ Title = "Config", Text = "Config loaded!", Time = 2 })
    end,
})

ConfigGroup:AddButton({
    Text = "Save Config",
    Func = function()
        Library:Notify({ Title = "Config", Text = "Config saved!", Time = 2 })
    end,
})

ConfigGroup:AddButton({
    Text = "Delete Config",
    Func = function()
        Library:Notify({ Title = "Config", Text = "Config deleted!", Time = 2 })
    end,
    Risky = true,
})

ConfigGroup:AddDivider()

ConfigGroup:AddButton({
    Text = "Unload Script",
    Func = function()
        if Library.ScreenGui then
            Library.ScreenGui:Destroy()
        end
    end,
    Risky = true,
})

print("KoraxUI loaded successfully!")
print("Press RightControl to toggle the menu")
