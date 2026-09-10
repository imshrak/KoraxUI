# KoraxMENU - Roblox UI Library

A modified version of the Obsidian UI Library with horizontal tabs on top instead of vertical tabs on the right side.

## Features

- **Horizontal Tabs**: Tabs are positioned at the top of the window in a horizontal layout
- **Modern UI**: Clean, dark-themed interface with smooth animations
- **Loadstring Compatible**: Easy to load via GitHub raw URL
- **Full Feature Set**: All the original Obsidian features including:
  - Toggles, Sliders, Dropdowns, Inputs
  - Color Pickers, Keybinds
  - Groupboxes and Tabboxes
  - Notifications and Dialogs
  - Customizable themes and icons

## Usage

### Basic Example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxMENU/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "KoraxMENU",
    Icon = "home",
    NotifySide = "Right",
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Settings = Window:AddTab("Settings", "settings"),
}

local MainGroup = Tabs.Main:AddGroupbox({
    Side = "Left",
    Name = "Features",
    IconName = "star",
})

MainGroup:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end,
})
```

## Installation

Simply use the loadstring in your script:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxMENU/main/Library.lua"))()
```

## Credits

- Based on [Obsidian UI Library](https://github.com/deividcomsono/Obsidian) by deividcomsono
- Modified with horizontal tabs layout for KoraxMENU

## License

MIT License - See LICENSE file for details