-- KoraxUI Example Script
-- This demonstrates how to use the library with loadstring

-- Load the library from GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxUI/main/Library.lua"))()

-- Access the tables (with error handling)
local Options = Library.Options or {}
local Toggles = Library.Toggles or {}

-- Create the main window
local Window = Library:CreateWindow({
    Title = "KoraxUI",
    Footer = "Example Script",
    Icon = "home",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

-- Create tabs
local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Settings = Window:AddTab("Settings", "settings"),
    Extras = Window:AddTab("Extras", "star"),
}

-- Add a groupbox to the Main tab
local MainGroup = Tabs.Main:AddLeftGroupbox("Features", "star")

-- Add a toggle
MainGroup:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("[Toggle] Feature enabled:", Value)
    end,
})

-- Add a button
MainGroup:AddButton({
    Text = "Click Me",
    Func = function()
        print("[Button] You clicked the button!")
        Library:Notify({
            Title = "Button Clicked",
            Text = "You clicked the button!"
        })
    end,
})

-- Add a label
MainGroup:AddLabel("This is a label")

-- Add a slider
MainGroup:AddSlider("MySlider", {
    Text = "Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        print("[Slider] Speed set to:", Value)
    end,
})

-- Add an input
MainGroup:AddInput("MyInput", {
    Text = "Username",
    Default = "",
    Placeholder = "Enter username...",
    Callback = function(Value)
        print("[Input] Username:", Value)
    end,
})

-- Add a dropdown
MainGroup:AddDropdown("MyDropdown", {
    Text = "Select Option",
    Values = {"Option 1", "Option 2", "Option 3"},
    Callback = function(Value)
        print("[Dropdown] Selected:", Value)
    end,
})

-- Add another groupbox to the right side
local RightGroup = Tabs.Main:AddRightGroupbox("Settings", "settings")

RightGroup:AddToggle("AnotherToggle", {
    Text = "Another Feature",
    Default = true,
    Callback = function(Value)
        print("[Toggle] Another feature:", Value)
    end,
})

-- Settings tab
local SettingsGroup = Tabs.Settings:AddLeftGroupbox("UI Settings", "settings")

SettingsGroup:AddToggle("ToggleUI", {
    Text = "Toggle UI",
    Default = true,
    Callback = function(Value)
        Library:Toggle(Value)
    end,
})

-- Keybind to toggle the menu
UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    if Input.KeyCode == Library.ToggleKeybind then
        Library:Toggle()
    end
end)

print("KoraxUI loaded successfully!")
print("Press RightControl to toggle the menu")