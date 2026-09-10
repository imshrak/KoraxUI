local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxUI/master/Library.lua"))()

local Options = Library.Options or {}
local Toggles = Library.Toggles or {}

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
}

-- Movement Tab
local MoveGroup = Tabs.Movement:AddGroupbox({
    Side = 1,
    Name = "Movement",
    IconName = "activity",
})

MoveGroup:AddToggle("Flight", {
    Text = "Flight",
    Default = false,
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
})

MoveGroup:AddSlider("SpeedValue", {
    Text = "Speed Value",
    Default = 16,
    Min = 16,
    Max = 200,
})

MoveGroup:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Default = false,
})

-- Visual Tab
local VisGroup = Tabs.Visual:AddGroupbox({
    Side = 1,
    Name = "Visuals",
    IconName = "eye",
})

VisGroup:AddToggle("Highlight", {
    Text = "Highlight Players",
    Default = false,
})

print("KoraxUI Example loaded!")
print("Press RightControl to toggle the menu")
