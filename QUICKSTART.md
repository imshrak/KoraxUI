# Quick Start Guide

## 1. Load the Library

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxUI/master/Library.lua"))()
```

## 2. Create a Window

```lua
local Window = Library:CreateWindow({
    Title = "My Menu",
    Footer = "v1.0",
    Size = UDim2.fromOffset(620, 450),
    NotifySide = "Right",
    ToggleKeybind = Enum.KeyCode.RightControl,
})
```

## 3. Add Tabs

```lua
local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Settings = Window:AddTab("Settings", "settings"),
}
```

## 4. Add Groupboxes

```lua
local LeftGroup = Tabs.Main:AddGroupbox({
    Side = 1,
    Name = "Features",
    IconName = "star",
})

local RightGroup = Tabs.Main:AddGroupbox({
    Side = 2,
    Name = "Settings",
    IconName = "settings",
})
```

## 5. Add Elements

```lua
LeftGroup:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end,
})

LeftGroup:AddSlider("MySlider", {
    Text = "Speed",
    Default = 50,
    Min = 0,
    Max = 100,
    Suffix = "%",
})

LeftGroup:AddDropdown("MyDropdown", {
    Text = "Mode",
    Values = {"Easy", "Medium", "Hard"},
    Value = "Medium",
})

LeftGroup:AddInput("MyInput", {
    Text = "Name",
    Placeholder = "Enter name...",
})

LeftGroup:AddButton({
    Text = "Click Me",
    Func = function()
        Library:Notify({ Title = "Clicked!", Text = "Button was pressed", Time = 2 })
    end,
})
```

## 6. Toggle the Menu

Press `RightControl` (default) to show/hide the menu.

## File Structure

- `Library.lua` - Main library file
- `Example.lua` - Example usage script
- `README.md` - Full documentation
- `QUICKSTART.md` - This file
- `SETUP.md` - Setup guide
