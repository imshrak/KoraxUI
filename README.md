# KoraxUI - Roblox UI Library

A clean, modern Roblox UI library with horizontal tabs on top.

## Features

- **Horizontal Tabs**: Tabs positioned at the top in a clean horizontal layout
- **Smooth Animations**: Tween-based animations for toggles, dropdowns, and tab switching
- **Modern Dark Theme**: Clean dark UI with accent colors
- **Loadstring Compatible**: One-line load from GitHub
- **Full Feature Set**:
  - Toggles (switch style)
  - Sliders with drag support
  - Dropdowns with animated arrow
  - Text inputs
  - Buttons with hover effects
  - Labels and dividers
  - Notifications
  - Window dragging and resizing
  - Toggle keybind (RightCtrl)

## Quick Start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxUI/master/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "My Menu",
    Footer = "v1.0",
    NotifySide = "Right",
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Settings = Window:AddTab("Settings", "settings"),
}

local Group = Tabs.Main:AddGroupbox({
    Side = 1,
    Name = "Features",
    IconName = "star",
})

Group:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end,
})
```

## Elements

### Toggle
```lua
Group:AddToggle("Idx", {
    Text = "Toggle Label",
    Default = false,
    Callback = function(Value) end,
    Risky = false,
})
```

### Slider
```lua
Group:AddSlider("Idx", {
    Text = "Slider Label",
    Default = 50,
    Min = 0,
    Max = 100,
    Suffix = "%",
    Callback = function(Value) end,
})
```

### Dropdown
```lua
Group:AddDropdown("Idx", {
    Text = "Dropdown Label",
    Values = {"Option 1", "Option 2", "Option 3"},
    Value = "Option 1",
    Callback = function(Value) end,
})
```

### Input
```lua
Group:AddInput("Idx", {
    Text = "Input Label",
    Default = "",
    Placeholder = "Type here...",
    Callback = function(Value) end,
})
```

### Button
```lua
Group:AddButton({
    Text = "Click Me",
    Func = function() end,
    Risky = false,
})
```

## API

### Window
- `Library:CreateWindow(Info)` - Creates the main window
- `Window:AddTab(Name, Icon)` - Adds a tab
- `Window:Toggle()` - Toggles visibility
- `Window:ChangeTitle(Title)` - Changes title
- `Window:SetFooter(Footer)` - Changes footer

### Tab
- `Tab:AddGroupbox(Info)` - Adds a groupbox
- `Tab:AddLeftGroupbox(Name, Icon)` - Shortcut for left groupbox
- `Tab:AddRightGroupbox(Name, Icon)` - Shortcut for right groupbox

### Groupbox
- `Group:AddToggle(Idx, Info)` - Adds a toggle
- `Group:AddSlider(Idx, Info)` - Adds a slider
- `Group:AddInput(Idx, Info)` - Adds a text input
- `Group:AddDropdown(Idx, Info)` - Adds a dropdown
- `Group:AddButton(Info)` - Adds a button
- `Group:AddLabel(Text)` - Adds a label
- `Group:AddDivider(Text)` - Adds a divider

### Element Methods
- `:SetValue(Value)` - Sets the element value
- `:SetDisabled(Disabled)` - Disables/enables the element
- `:SetVisible(Visible)` - Shows/hides the element
- `:SetText(Text)` - Changes the label text

## Keybind

Press `RightControl` to toggle the menu.

## Credits

Based on [Obsidian UI Library](https://github.com/deividcomsono/Obsidian) by deividcomsono.

## License

MIT License
