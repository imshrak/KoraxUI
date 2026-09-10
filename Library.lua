local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/imshrak/KoraxUI/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "KoraxUI/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "KoraxUI/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "KoraxUI/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "KoraxUI/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("KoraxUI/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,

    Window = nil,
    WindowContainer = nil,

    --// Search \\--
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    PreviousTab = nil,
    Tabs = {},
    TabButtons = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    --// Notifications \\--
    Notifications = {},
    NotifySide = "Right",
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Context Menu \\--
    ContextMenus = {}, 

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = true,
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Pop Out \\--
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(125, 85, 255),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Code),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
    Scales = {},
    ScalesOffset = {},

    --// Mouse \\--
    OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
    ShowCursorBinding = string.sub(tostring({}), 10),

    --// Image Manager \\--
    ImageManager = CustomImageManager,

    --// Misc \\--
    Notify = nil, Toggle = nil -- we love luau lsp
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600),
        IconSize = UDim2.fromOffset(30, 30),

        AutoShow = true,
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,

        --// Window Snapping \\--
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,

        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,

        CornerRadius = 4,
        NotifySide = "Right",
        ShowCustomCursor = true,

        Font = Enum.Font.Code,
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false,
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom",
        TabButtonsStyle = {
            Gap = 0,
            Padding = 0,
            CornerRadius = 0,
            Indicator = false,
            IndicatorWidth = 2,
            IndicatorHeight = 20,
        },
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        PopOut = true,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        PopOut = true,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "KoraxUI",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Resizable = true,

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function IsSequentialArray(Table: { [any]: any })
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end

    return true
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

--// Fuzzy Search \\--
local function FuzzyScore(Text: string, Search: string): (boolean, number)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    Text = Text:lower()
    Search = Search:lower()

    local Score = 0
    local SearchIndex = 1
    local TextIndex = 1

    while SearchIndex <= #Search and TextIndex <= #Text do
        if Text:sub(TextIndex, TextIndex) == Search:sub(SearchIndex, SearchIndex) then
            Score += 1
            SearchIndex += 1
        end
        TextIndex += 1
    end

    return SearchIndex > #Search, Score
end

local function TryFuzzyMatch(Text: string, Search: string): boolean
    local Matches, _ = FuzzyScore(Text, Search)
    return Matches
end

local function FuzzyMatchScore(Text: string, Search: string): number
    local _, Score = FuzzyScore(Text, Search)
    return Score
end

--// UI Utility Functions \\--
local function GetValue(Value, Default)
    if Value == nil then
        return Default
    end

    return Value
end

local function New(Class, Properties)
    local Instance = Instance.new(Class)

    for Property, Value in Properties do
        if typeof(Value) == "function" then
            Instance[Property] = Value()
        else
            Instance[Property] = Value
        end
    end

    return Instance
end

--// Library Functions \\--
function Library:Validate(Info, Template)
    local Result = {}

    for Key, DefaultValue in Template do
        local Value = Info[Key]

        if Value == nil then
            Result[Key] = DefaultValue
        elseif typeof(DefaultValue) == "table" and typeof(Value) == "table" then
            Result[Key] = Library:Validate(Value, DefaultValue)
        else
            Result[Key] = Value
        end
    end

    return Result
end

function Library:GetBetterColor(Color, Transparency)
    if Library.Scheme.BackgroundImage ~= "" then
        return Color
    end

    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V + (0.1 * Transparency))
end

function Library:ApplyLucideIcon(ImageLabel, IconName)
    if not IconName then
        return
    end

    local IconData = Library:GetCustomIcon(IconName)
    if not IconData then
        return
    end

    if IconData.Custom then
        ImageLabel.Image = IconData.Image
        ImageLabel.ImageRectOffset = IconData.RectOffset
        ImageLabel.ImageRectSize = IconData.RectSize
    else
        ImageLabel.Image = "rbxassetid://" .. IconData.RobloxId
        ImageLabel.ImageRectOffset = Vector2.zero
        ImageLabel.ImageRectSize = Vector2.zero
    end
end

function Library:GetCustomIcon(IconName)
    if typeof(IconName) == "table" then
        return IconName
    end

    if typeof(IconName) == "number" then
        return {
            RobloxId = IconName,
            Custom = false
        }
    end

    local Icons = {
        -- Add some basic icons here
        home = { RobloxId = 6031068421, Custom = false },
        user = { RobloxId = 6031070791, Custom = false },
        settings = { RobloxId = 6031075095, Custom = false },
        star = { RobloxId = 6031075916, Custom = false },
    }

    return Icons[IconName]
end

function Library:MakeResizable(Frame, Handle, Callback)
    local Dragging = false
    local StartPosition
    local StartSize

    Handle.MouseButton1Down:Connect(function()
        Dragging = true
        StartPosition = Vector2.new(Mouse.X, Mouse.Y)
        StartSize = Frame.AbsoluteSize

        local Connection
        Connection = UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
                Connection:Disconnect()
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if not Dragging or not IsMovementInput(Input) then
            return
        end

        local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartPosition
        local NewSize = UDim2.fromOffset(
            math.max(Library.MinSize.X, StartSize.X + Delta.X),
            math.max(Library.MinSize.Y, StartSize.Y + Delta.Y)
        )

        Frame.Size = NewSize

        if Callback then
            Callback()
        end
    end)
end

function Library:Notify(Info)
    -- Basic notification implementation
    print("Notification:", Info.Title or "Notification", Info.Text or "")
end

function Library:Toggle(State)
    if State == nil then
        Library.Toggled = not Library.Toggled
    else
        Library.Toggled = State
    end

    if Library.Window then
        Library.Window.Visible = Library.Toggled
    end
end

--// Window Creation \\--
function Library:CreateWindow(Info)
    Info = Library:Validate(Info, Templates.Window)

    Library.ToggleKeybind = Info.ToggleKeybind
    Library.NotifySide = Info.NotifySide
    Library.ShowCustomCursor = Info.ShowCustomCursor

    local ScreenGui = New("ScreenGui", {
        Name = "KoraxUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = gethui(),
    })

    protectgui(ScreenGui)
    Library.ScreenGui = ScreenGui

    local MainFrame = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderSizePixel = 0,
        Position = Info.Position,
        Size = Info.Size,
        Visible = Info.AutoShow,
        Parent = ScreenGui,
    })

    -- Add corner radius
    New("UICorner", {
        CornerRadius = UDim.new(0, Info.CornerRadius),
        Parent = MainFrame,
    })

    -- Header with title
    local Header = New("Frame", {
        BackgroundColor3 = "MainColor",
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = MainFrame,
    })

    New("UICorner", {
        CornerRadius = UDim.new(0, Info.CornerRadius),
        Parent = Header,
    })

    local TitleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Text = Info.Title,
        TextColor3 = "FontColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = "Font",
        Parent = Header,
    })

    -- Horizontal Tabs Container (MODIFIED FOR HORIZONTAL LAYOUT)
    local TabsContainer = New("Frame", {
        BackgroundColor3 = "MainColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 50),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainFrame,
    })

    local Tabs = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        CanvasSize = UDim2.fromScale(0, 0),
        ScrollBarThickness = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TabsContainer,
    })

    -- MODIFIED: Horizontal layout for tabs
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 2),
        Parent = Tabs,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = Tabs,
    })

    -- Content Container
    local Container = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 90),
        Size = UDim2.new(1, 0, 1, -90),
        Parent = MainFrame,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = Container,
    })

    Library.WindowContainer = Container
    Library.Window = MainFrame

    -- Window Functions
    local Window = {}

    function Window:AddTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabButton
        local TabLabel
        local TabIcon

        Icon = Library:GetCustomIcon(Icon)

        -- MODIFIED: Horizontal tab button
        TabButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Size = UDim2.fromOffset(120, 28),
            Text = "",
            LayoutOrder = Order,
            Parent = Tabs,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = TabButton,
        })

        local ButtonPadding = New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = TabButton,
        })

        if Icon then
            TabIcon = New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = "AccentColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.fromOffset(16, 16),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = TabButton,
            })
            Library:ApplyLucideIcon(TabIcon, Icon)
        end

        TabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(Icon and 20 or 0, 0),
            Size = UDim2.new(1, -(Icon and 20 or 0), 1, 0),
            Text = Name,
            TextColor3 = "FontColor",
            TextSize = 14,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Center,
            FontFace = "Font",
            Parent = TabButton,
        })

        -- Tab Content Container
        local TabContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = Container,
        })

        local TabLeft = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarThickness = 0,
            Size = UDim2.new(0.5, -3, 1, 0),
            Parent = TabContainer,
        })

        New("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = TabLeft,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = TabLeft,
        })

        local TabRight = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarThickness = 0,
            Position = UDim2.new(0.5, 3, 0, 0),
            Size = UDim2.new(0.5, -3, 1, 0),
            Parent = TabContainer,
        })

        New("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = TabRight,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = TabRight,
        })

        -- Tab functionality
        local Tab = {
            Name = Name,
            Icon = Icon,
            Description = Description,
            Container = TabContainer,
            Left = TabLeft,
            Right = TabRight,
            Button = TabButton,
            Label = TabLabel,
            IconInstance = TabIcon,
        }

        function Tab:SetActive(Active)
            if Active then
                if Library.ActiveTab and Library.ActiveTab ~= Tab then
                    Library.ActiveTab:SetActive(false)
                end

                Library.ActiveTab = Tab
                TabContainer.Visible = true
                TabButton.BackgroundColor3 = Library.Scheme.AccentColor
                TabButton.BackgroundTransparency = 0.3
                TabLabel.TextTransparency = 0
                if TabIcon then
                    TabIcon.ImageTransparency = 0
                end
            else
                TabContainer.Visible = false
                TabButton.BackgroundColor3 = Library.Scheme.MainColor
                TabButton.BackgroundTransparency = 0.5
                TabLabel.TextTransparency = 0.5
                if TabIcon then
                    TabIcon.ImageTransparency = 0.5
                end
            end
        end

        TabButton.MouseButton1Click:Connect(function()
            Tab:SetActive(true)
        end)

        table.insert(Library.Tabs, Tab)
        table.insert(Library.TabButtons, {
            Label = TabLabel,
            Padding = ButtonPadding,
            Icon = TabIcon,
            Button = TabButton,
        })

        -- First tab becomes active by default
        if #Library.Tabs == 1 then
            Tab:SetActive(true)
        end

        -- Tab Methods
        function Tab:AddGroupbox(Info)
            Info = Library:Validate(Info, Templates.Groupbox)
            local Side = Info.Side or 1
            local ParentFrame = Side == 1 and TabLeft or TabRight

            local Groupbox = New("Frame", {
                BackgroundColor3 = "MainColor",
                Size = UDim2.new(1, 0, 0, Info.Collapsed and 30 or 200),
                Visible = Info.Visible,
                Parent = ParentFrame,
            })

            New("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = Groupbox,
            })

            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Groupbox,
            })

            local GroupboxTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(8, 0),
                Size = UDim2.new(1, -16, 0, 30),
                Text = Info.Name,
                TextColor3 = "FontColor",
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = "Font",
                Parent = Groupbox,
            })

            local Content = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromOffset(0, 30),
                ScrollBarThickness = 0,
                Size = UDim2.new(1, 0, 1, -30),
                Parent = Groupbox,
            })

            New("UIListLayout", {
                Padding = UDim.new(0, 4),
                Parent = Content,
            })

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                Parent = Content,
            })

            local Group = {
                Name = Info.Name,
                Container = Content,
                Frame = Groupbox,
            }

            -- Add basic element methods
            function Group:AddToggle(Idx, Options)
                Options = Library:Validate(Options, Templates.Toggle)
                
                local Toggle = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = Content,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Toggle,
                })

                local ToggleLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Text = Options.Text,
                    TextColor3 = Options.Risky and "RedColor" or "FontColor",
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = "Font",
                    Parent = Toggle,
                })

                local ToggleButton = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    Position = UDim2.new(1, -32, 0.5, -10),
                    Size = UDim2.fromOffset(20, 20),
                    Text = "",
                    Parent = Toggle,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ToggleButton,
                })

                local ToggleObj = {
                    Value = Options.Default,
                    Index = Idx,
                }

                function ToggleObj:SetValue(Value)
                    ToggleObj.Value = Value
                    ToggleButton.BackgroundColor3 = Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
                    if Options.Callback then
                        Options.Callback(Value)
                    end
                end

                ToggleButton.MouseButton1Click:Connect(function()
                    ToggleObj:SetValue(not ToggleObj.Value)
                end)

                Toggles[Idx] = ToggleObj
                ToggleObj:SetValue(Options.Default)

                return ToggleObj
            end

            function Group:AddButton(Options)
                Options = Library:Validate(Options, Templates.Button or {})
                
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = Options.Text or "Button",
                    TextColor3 = "FontColor",
                    TextSize = 13,
                    FontFace = "Font",
                    Parent = Content,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Button,
                })

                Button.MouseButton1Click:Connect(function()
                    if Options.Func then
                        Options.Func()
                    end
                end)

                return Button
            end

            function Group:AddLabel(Text)
                local Label = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Text = Text,
                    TextColor3 = "FontColor",
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = "Font",
                    Parent = Content,
                })

                return Label
            end

            function Group:AddSlider(Idx, Options)
                Options = Library:Validate(Options, Templates.Slider)
                
                local Slider = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.new(1, 0, 0, 40),
                    Parent = Content,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Slider,
                })

                local SliderLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -16, 0, 18),
                    Text = Options.Text,
                    TextColor3 = "FontColor",
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = "Font",
                    Parent = Slider,
                })

                local SliderValue = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.fromOffset(52, 18),
                    Text = tostring(Options.Default),
                    TextColor3 = "FontColor",
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    FontFace = "Font",
                    Parent = Slider,
                })

                local SliderBar = New("Frame", {
                    BackgroundColor3 = "MainColor",
                    Position = UDim2.fromOffset(8, 22),
                    Size = UDim2.new(1, -16, 0, 8),
                    Parent = Slider,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = SliderBar,
                })

                local SliderFill = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    Size = UDim2.fromScale(0, 1),
                    Parent = SliderBar,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = SliderFill,
                })

                local SliderObj = {
                    Value = Options.Default,
                    Index = Idx,
                }

                function SliderObj:SetValue(Value)
                    Value = math.clamp(Value, Options.Min, Options.Max)
                    SliderObj.Value = Value
                    SliderValue.Text = tostring(Round(Value, Options.Rounding))
                    local Percent = (Value - Options.Min) / (Options.Max - Options.Min)
                    SliderFill.Size = UDim2.fromScale(Percent, 1)
                    if Options.Callback then
                        Options.Callback(Value)
                    end
                end

                local function UpdateSlider(input)
                    local Scale = (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                    local Value = Options.Min + (Scale * (Options.Max - Options.Min))
                    SliderObj:SetValue(Value)
                end

                SliderBar.InputBegan:Connect(function(input)
                    if IsMouseInput(input) then
                        UpdateSlider(input)
                        local connection
                        connection = UserInputService.InputChanged:Connect(function(input)
                            if IsMovementInput(input) then
                                UpdateSlider(input)
                            elseif IsMouseClickInput(input) then
                                connection:Disconnect()
                            end
                        end)
                    end
                end)

                Options[Idx] = SliderObj
                SliderObj:SetValue(Options.Default)

                return SliderObj
            end

            function Group:AddInput(Idx, Options)
                Options = Library:Validate(Options, Templates.Input)
                
                local Input = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = Content,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Input,
                })

                local InputLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -16, 0, 16),
                    Text = Options.Text,
                    TextColor3 = "FontColor",
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = "Font",
                    Parent = Input,
                })

                local InputBox = New("TextBox", {
                    BackgroundColor3 = "MainColor",
                    Position = UDim2.fromOffset(8, 18),
                    Size = UDim2.new(1, -16, 0, 14),
                    PlaceholderText = Options.Placeholder,
                    Text = Options.Default,
                    TextColor3 = "FontColor",
                    TextSize = 13,
                    FontFace = "Font",
                    Parent = Input,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = InputBox,
                })

                local InputObj = {
                    Value = Options.Default,
                    Index = Idx,
                }

                function InputObj:SetValue(Value)
                    InputObj.Value = Value
                    InputBox.Text = Value
                    if Options.Callback then
                        Options.Callback(Value)
                    end
                end

                InputBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed or not Options.ClearTextOnFocus then
                        InputObj:SetValue(InputBox.Text)
                    end
                end)

                Options[Idx] = InputObj

                return InputObj
            end

            function Group:AddDropdown(Idx, Options)
                Options = Library:Validate(Options, Templates.Dropdown)
                
                local Dropdown = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = Content,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Dropdown,
                })

                local DropdownButton = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = Options.Text or "Dropdown",
                    TextColor3 = "FontColor",
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = "Font",
                    Parent = Dropdown,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownButton,
                })

                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    Parent = DropdownButton,
                })

                local DropdownObj = {
                    Value = nil,
                    Index = Idx,
                    Options = Options.Values,
                }

                function DropdownObj:SetValue(Value)
                    DropdownObj.Value = Value
                    DropdownButton.Text = Options.Text .. ": " .. tostring(Value)
                    if Options.Callback then
                        Options.Callback(Value)
                    end
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    -- Simple dropdown implementation - in a full version, this would show a dropdown menu
                    -- For now, cycle through values
                    local currentIndex = table.find(Options.Values, DropdownObj.Value) or 0
                    local nextIndex = (currentIndex % #Options.Values) + 1
                    DropdownObj:SetValue(Options.Values[nextIndex])
                end)

                Options[Idx] = DropdownObj
                if #Options.Values > 0 then
                    DropdownObj:SetValue(Options.Values[1])
                end

                return DropdownObj
            end

            return Group
        end

        function Tab:AddLeftGroupbox(Name, Icon)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = Icon })
        end

        function Tab:AddRightGroupbox(Name, Icon)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = Icon })
        end

        return Tab
    end

    -- Window utility functions
    function Window:ToggleLibrary()
        Library:Toggle()
    end

    return Window
end

--// Initialize Library \\
Library.Notify = Library.Notify
Library.Toggle = Library.Toggle

return Library