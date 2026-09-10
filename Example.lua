local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxUI/master/Library.lua"))()

local Options = Library.Options or {}
local Toggles = Library.Toggles or {}

local Window = Library:CreateWindow({
    Title = "KoraxUI",
    Footer = "v1.0 | RightCtrl to toggle",
    Size = UDim2.fromOffset(720, 600),
    ToggleKeybind = Enum.KeyCode.RightControl,
    NotifySide = "Right",
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "home"),
    Combat = Window:AddTab("Combat", "crosshair"),
    Visuals = Window:AddTab("Visuals", "eye"),
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

LegitGroup:AddDivider()

LegitGroup:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Default = false,
})

LegitGroup:AddSlider("HitChance", {
    Text = "Hit Chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Suffix = "%",
})

local ConfigGroup = Tabs.Main:AddGroupbox({
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
    Values = { "default", "legit", "rage", "hvh" },
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

-- Combat Tab
local RageGroup = Tabs.Combat:AddGroupbox({
    Side = 1,
    Name = "Rage",
    IconName = "zap",
})

RageGroup:AddToggle("NoRecoil", {
    Text = "No Recoil",
    Default = false,
})

RageGroup:AddToggle("NoSpread", {
    Text = "No Spread",
    Default = false,
})

RageGroup:AddSlider("FireRate", {
    Text = "Fire Rate Multiplier",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Suffix = "x",
})

RageGroup:AddDivider("Target")

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

WeaponGroup:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 0,
    Max = 100,
})

WeaponGroup:AddSlider("JumpPower", {
    Text = "Jump Power",
    Default = 50,
    Min = 0,
    Max = 200,
})

WeaponGroup:AddToggle("NoFallDamage", {
    Text = "No Fall Damage",
    Default = false,
})

WeaponGroup:AddToggle("InfiniteAmmo", {
    Text = "Infinite Ammo",
    Default = false,
})

WeaponGroup:AddButton({
    Text = "Reset Character",
    Func = function()
        Library:Notify({ Title = "Reset", Text = "Character reset!", Time = 2 })
    end,
    Risky = true,
})

-- Visuals Tab
local ESPGroup = Tabs.Visuals:AddGroupbox({
    Side = 1,
    Name = "ESP",
    IconName = "eye",
})

ESPGroup:AddToggle("EnableESP", {
    Text = "Enable ESP",
    Default = false,
})

ESPGroup:AddToggle("BoxESP", {
    Text = "Box ESP",
    Default = true,
})

ESPGroup:AddToggle("NameESP", {
    Text = "Name ESP",
    Default = true,
})

ESPGroup:AddToggle("HealthBar", {
    Text = "Health Bar",
    Default = false,
})

ESPGroup:AddToggle("DistanceESP", {
    Text = "Distance",
    Default = false,
})

ESPGroup:AddSlider("ESPRange", {
    Text = "ESP Range",
    Default = 500,
    Min = 50,
    Max = 2000,
    Suffix = "m",
})

ESPGroup:AddDivider("Colors")

ESPGroup:AddDropdown("BoxColor", {
    Text = "Box Color",
    Values = { "White", "Accent", "Rainbow", "Team" },
    Value = "Accent",
})

local ChamsGroup = Tabs.Visuals:AddGroupbox({
    Side = 2,
    Name = "Chams",
    IconName = "image",
})

ChamsGroup:AddToggle("Chams", {
    Text = "Chams",
    Default = false,
})

ChamsGroup:AddToggle("Overlay", {
    Text = "Overlay",
    Default = false,
})

ChamsGroup:AddDropdown("ChamsMaterial", {
    Text = "Material",
    Values = { "ForceField", "Neon", "Glass", "SmoothPlastic" },
    Value = "ForceField",
})

ChamsGroup:AddDivider("World")

ChamsGroup:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
})

ChamsGroup:AddToggle("NoFog", {
    Text = "No Fog",
    Default = false,
})

ChamsGroup:AddSlider("FOV", {
    Text = "Field of View",
    Default = 70,
    Min = 30,
    Max = 120,
})

-- Misc Tab
local MovementGroup = Tabs.Misc:AddGroupbox({
    Side = 1,
    Name = "Movement",
    IconName = "activity",
})

MovementGroup:AddToggle("Speed", {
    Text = "Speed Boost",
    Default = false,
})

MovementGroup:AddSlider("SpeedValue", {
    Text = "Speed",
    Default = 16,
    Min = 0,
    Max = 200,
})

MovementGroup:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
})

MovementGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 200,
})

MovementGroup:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
})

MovementGroup:AddDivider()

MovementGroup:AddButton({
    Text = "Teleport to Spawn",
    Func = function()
        Library:Notify({ Title = "Teleport", Text = "Teleported to spawn!", Time = 2 })
    end,
})

local MiscGroup = Tabs.Misc:AddGroupbox({
    Side = 2,
    Name = "Misc",
    IconName = "settings",
})

MiscGroup:AddToggle("AntiAFK", {
    Text = "Anti AFK",
    Default = false,
})

MiscGroup:AddToggle("AutoCollect", {
    Text = "Auto Collect",
    Default = false,
})

MiscGroup:AddInput("CustomValue", {
    Text = "Custom Value",
    Default = "",
    Placeholder = "Enter value...",
})

MiscGroup:AddDropdown("AutoFarm", {
    Text = "Auto Farm",
    Values = { "Disabled", "Ores", "Mobs", "Items" },
    Value = "Disabled",
})

MiscGroup:AddDivider("Keybinds")

MiscGroup:AddToggle("SpeedBind", {
    Text = "Speed Toggle (Shift)",
    Default = false,
})

MiscGroup:AddToggle("FlyBind", {
    Text = "Fly Toggle (V)",
    Default = false,
})

print("KoraxUI loaded successfully!")
print("Press RightControl to toggle the menu")
