# Quick Start Guide

## 1. Upload to GitHub

1. Create a GitHub repository called "KoraxMENU"
2. Upload all files from this folder
3. **Important**: Edit `Library.lua` line 32 and replace `imshrak` with your GitHub username

## 2. Use in Your Script

```lua
-- Load the library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxMENU/main/Library.lua"))()

-- Create window
local Window = Library:CreateWindow({
    Title = "My Menu",
    Icon = "home",
})

-- Add tabs
local Tabs = {
    Main = Window:AddTab("Main", "user"),
}

-- Add groupbox
local Group = Tabs.Main:AddLeftGroupbox("Features", "star")

-- Add toggle
Group:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print(Value)
    end,
})
```

## 3. Toggle Keybind

Press `RightControl` to toggle the menu (default)

## Key Features

- ✅ Horizontal tabs at the top (modified from original Obsidian)
- ✅ Loadstring compatible
- ✅ All standard UI elements (toggles, sliders, inputs, dropdowns)
- ✅ Left and right groupboxes
- ✅ Customizable themes
- ✅ Easy GitHub upload

## Files Overview

- `Library.lua` - Main library file (edit line 32 with your GitHub username)
- `Example.lua` - Example usage script
- `README.md` - Full documentation
- `SETUP.md` - Detailed setup guide
- `LICENSE` - MIT License
- `assets/` - Image assets folder
- `.gitignore` - Git ignore file

## Need Help?

See `SETUP.md` for detailed setup instructions and troubleshooting.