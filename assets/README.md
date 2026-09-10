# Assets Folder

This folder contains image assets used by the KoraxMENU library.

## Current Assets

The library currently uses placeholder Roblox asset IDs. You can:

1. **Use existing IDs**: The current IDs in Library.lua should work for basic functionality
2. **Upload your own images**: Replace the asset IDs in Library.lua with your own
3. **Add custom assets**: Use `Library.ImageManager.AddAsset()` to add custom images

## Asset IDs Used

- TransparencyTexture: 139785960036434
- SaturationMap: 4155801252
- LoadingIcon: 97544096941083
- CheckIcon: 97682394690683

## Adding Custom Assets

```lua
Library.ImageManager.AddAsset(
    "MyCustomIcon",           -- Asset name
    1234567890,              -- Your Roblox asset ID
    "https://example.com/icon.png", -- URL (optional)
    false                    -- Force redownload (optional)
)
```

## Notes

- Assets are automatically cached locally when using executors that support file operations
- If you upload custom images to this folder, update the paths in Library.lua accordingly
- For GitHub loading, ensure your asset URLs are accessible