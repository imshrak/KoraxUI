# Setup Guide for KoraxMENU

## Getting Started with GitHub Upload

1. **Create a GitHub Repository**
   - Go to GitHub and create a new repository named "KoraxMENU"
   - Make it public if you want to share it with others
   - Initialize with README (we already have one)

2. **Update URLs in Library.lua**
   - Open `Library.lua` and find line 32
   - Replace `imshrak` with your actual GitHub username
   - Example: `https://raw.githubusercontent.com/johndoe/KoraxMENU/main/`

3. **Upload Files to GitHub**
   - Upload all files from this folder to your GitHub repository:
     - `Library.lua` (main library file)
     - `Example.lua` (example usage)
     - `README.md` (documentation)
     - `LICENSE` (license file)
     - `assets/` folder (with placeholder images)

4. **Test the Loadstring**
   - Use the following format to load your library:
   ```lua
   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxMENU/main/Library.lua"))()
   ```

## Asset Management

The library includes placeholder asset IDs. For production use:

1. **Replace Asset IDs**
   - Find the `CustomImageManagerAssets` table in Library.lua (lines 35-67)
   - Replace the RobloxId values with your own uploaded image IDs
   - Or upload your own images to the assets folder

2. **Custom Icons**
   - You can add custom icons using the `CustomImageManager.AddAsset` function
   - Icons will be cached locally for better performance

## Usage Example

```lua
-- Load the library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxMENU/main/Library.lua"))()

-- Create a window
local Window = Library:CreateWindow({
    Title = "My Menu",
    Icon = "home",
})

-- Add tabs
local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Settings = Window:AddTab("Settings", "settings"),
}

-- Add elements
local Group = Tabs.Main:AddLeftGroupbox("Features", "star")

Group:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end,
})
```

## Key Differences from Original Obsidian

1. **Horizontal Tabs**: Tabs are now arranged horizontally at the top instead of vertically on the right
2. **Layout Changes**: 
   - Tab container uses horizontal layout
   - Tab buttons are wider and shorter
   - Container positioning adjusted for horizontal layout
3. **Base URL**: Updated to point to your GitHub repository

## Customization

You can customize the library by modifying:

- **Colors**: Edit the `Library.Scheme` table (lines 277-293)
- **Animations**: Modify tween info values (lines 220-232)
- **Tab Styling**: Change `TabButtonsStyle` in window template (lines 438-445)
- **Window Settings**: Modify `Templates.Window` (lines 375-446)

## Troubleshooting

**Library not loading?**
- Check that your GitHub URL is correct
- Ensure the repository is public
- Verify the file path in the URL

**Tabs not appearing?**
- Make sure you're calling `AddTab` correctly
- Check that the window is visible
- Verify the container setup

**Elements not working?**
- Ensure you're using the correct callback syntax
- Check that element indices are unique
- Verify the element parent containers

## Support

For issues or questions:
1. Check the original Obsidian documentation: https://docs.mspaint.cc/obsidian
2. Review the Example.lua file for usage patterns
3. Make sure all URLs and file paths are correct