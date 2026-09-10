local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
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

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,
    ScreenGui = nil,
    Window = nil,
    WindowContainer = nil,
    ActiveTab = nil,
    Tabs = {},
    TabButtons = {},
    Toggled = false,
    Unloaded = false,
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowCustomCursor = true,
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,
    Registry = {},
    Signals = {},
    NotifySide = "Right",
    Notifications = {},
    TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    CornerRadius = 6,
    Scheme = {
        BackgroundColor = Color3.fromRGB(18, 18, 22),
        MainColor = Color3.fromRGB(28, 28, 34),
        AccentColor = Color3.fromRGB(130, 90, 255),
        OutlineColor = Color3.fromRGB(45, 45, 52),
        FontColor = Color3.new(1, 1, 1),
        SubFontColor = Color3.fromRGB(160, 160, 170),
        Font = Font.fromEnum(Enum.Font.Gotham),
        HoverColor = Color3.fromRGB(38, 38, 46),
        RedColor = Color3.fromRGB(255, 60, 60),
    },
}

local function GetSchemeValue(Index)
    return Library.Scheme[Index]
end

local function New(Class, Properties)
    local Instance = Instance.new(Class)
    for Property, Value in Properties do
        if typeof(Value) == "function" then
            Instance[Property] = Value()
        elseif typeof(Value) == "string" then
            local SchemeValue = GetSchemeValue(Value)
            if SchemeValue ~= nil then
                Instance[Property] = SchemeValue
            else
                Instance[Property] = Value
            end
        else
            Instance[Property] = Value
        end
    end
    return Instance
end

local function Validate(Info, Template)
    if typeof(Info) ~= "table" then
        return Template
    end
    local Result = {}
    for Key, DefaultValue in Template do
        if typeof(DefaultValue) == "table" and typeof(Info[Key]) == "table" then
            Result[Key] = Validate(Info[Key], DefaultValue)
        elseif Info[Key] ~= nil then
            Result[Key] = Info[Key]
        else
            Result[Key] = DefaultValue
        end
    end
    return Result
end

local function Round(Value, Rounding)
    if Rounding == 0 then
        return math.floor(Value)
    end
    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

local function IsMouseInput(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch
end

local function IsMovementInput(Input)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function IsMouseClickInput(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.MouseButton2
end

local function GetTextSize(Text, Font, Size, Bounds)
    return TextService:GetTextSize(Text, Size, Font, Bounds)
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        if Instance and Instance.Parent then
            for Property, Index in Properties do
                local SchemeValue = GetSchemeValue(Index)
                if SchemeValue then
                    Instance[Property] = SchemeValue
                end
            end
        end
    end
end

function Library:GiveSignal(Connection)
    if Connection and (typeof(Connection) == "RBXScriptConnection" or typeof(Connection) == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end
    return Connection
end

function Library:MakeDraggable(UI, DragFrame)
    local Dragging = false
    local DragStart, StartPosition

    DragFrame.InputBegan:Connect(function(Input)
        if IsMouseInput(Input) and Library.IsRobloxFocused then
            Dragging = true
            DragStart = Input.Position
            StartPosition = UI.Position
        end
    end)

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
        if Dragging and IsMovementInput(Input) then
            local Delta = Input.Position - DragStart
            UI.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end))

    Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
        if IsMouseInput(Input) then
            Dragging = false
        end
    end))
end

function Library:MakeResizable(UI, DragFrame, Callback)
    local Dragging = false
    local StartPos, StartSize

    DragFrame.InputBegan:Connect(function(Input)
        if IsMouseInput(Input) and Library.IsRobloxFocused then
            Dragging = true
            StartPos = Vector2.new(Mouse.X, Mouse.Y)
            StartSize = UI.AbsoluteSize
        end
    end)

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
        if Dragging and IsMovementInput(Input) then
            local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartPos
            local NewWidth = math.max(480, StartSize.X + Delta.X)
            local NewHeight = math.max(320, StartSize.Y + Delta.Y)
            UI.Size = UDim2.fromOffset(NewWidth, NewHeight)
            if Callback then
                Callback()
            end
        end
    end))

    Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
        if IsMouseInput(Input) then
            Dragging = false
        end
    end))
end

function Library:Notify(Info)
    if typeof(Info) == "string" then
        Info = { Title = "Notification", Text = Info }
    end

    local NotifySide = Library.NotifySide
    local Notifications = Library.Notifications

    local NotifFrame = New("Frame", {
        BackgroundColor3 = "MainColor",
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(280, 60),
        Position = NotifySide == "Right"
            and UDim2.new(1, -290, 0, 8 + (#Notifications * 68))
            or UDim2.new(0, 10, 0, 8 + (#Notifications * 68)),
        AnchorPoint = NotifySide == "Right" and Vector2.new(0, 0) or Vector2.new(0, 0),
        ZIndex = 200,
        Parent = Library.ScreenGui,
    })

    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = NotifFrame })
    New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = NotifFrame })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -24, 0, 18),
        Text = Info.Title or "Notification",
        TextColor3 = "AccentColor",
        TextSize = 13,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 201,
        Parent = NotifFrame,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 28),
        Size = UDim2.new(1, -24, 0, 24),
        Text = Info.Text or "",
        TextColor3 = "SubFontColor",
        TextSize = 12,
        FontFace = "Font",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 201,
        Parent = NotifFrame,
    })

    table.insert(Notifications, NotifFrame)

    task.delay(Info.Time or 3, function()
        if NotifFrame and NotifFrame.Parent then
            local Tween = TweenService:Create(NotifFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = NotifySide == "Right"
                    and UDim2.new(1, 300, NotifFrame.Position.Y.Scale, NotifFrame.Position.Y.Offset)
                    or UDim2.new(0, -300, NotifFrame.Position.Y.Scale, NotifFrame.Position.Y.Offset),
            })
            Tween:Play()
            Tween.Completed:Connect(function()
                local Idx = table.find(Notifications, NotifFrame)
                if Idx then
                    table.remove(Notifications, Idx)
                end
                NotifFrame:Destroy()
            end)
        end
    end)

    return NotifFrame
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

function Library:CreateWindow(Info)
    Info = Info or {}
    local Title = Info.Title or "KoraxUI"
    local Footer = Info.Footer or ""
    local Size = Info.Size or UDim2.fromOffset(620, 450)
    local Position = Info.Position or UDim2.fromOffset(100, 100)
    local ToggleKeybind = Info.ToggleKeybind or Enum.KeyCode.RightControl
    local AutoShow = Info.AutoShow ~= false
    local NotifySide = Info.NotifySide or "Right"

    Library.ToggleKeybind = ToggleKeybind
    Library.NotifySide = NotifySide

    local ScreenGui = New("ScreenGui", {
        Name = "KoraxUI",
        DisplayOrder = 999,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = gethui(),
    })
    pcall(protectgui, ScreenGui)
    Library.ScreenGui = ScreenGui

    local MainFrame = New("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = "BackgroundColor",
        BorderSizePixel = 0,
        Position = Position,
        Size = Size,
        Visible = AutoShow,
        ZIndex = 1,
    })
    pcall(function()
        MainFrame.Parent = ScreenGui
    end)
    if not MainFrame.Parent then
        MainFrame.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame })
    New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = MainFrame })

    Library.Window = MainFrame
    Library.Toggled = AutoShow

    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundColor3 = "MainColor",
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 2,
        Parent = MainFrame,
    })

    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = TopBar })

    local TopBarMask = New("Frame", {
        BackgroundColor3 = "MainColor",
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -Library.CornerRadius),
        Size = UDim2.new(1, 0, 0, Library.CornerRadius),
        ZIndex = 3,
        Parent = TopBar,
    })

    local TitleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Text = Title,
        TextColor3 = "FontColor",
        TextSize = 14,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = TopBar,
    })

    Library:MakeDraggable(MainFrame, TopBar)

    local TabBar = New("Frame", {
        Name = "TabBar",
        BackgroundColor3 = "BackgroundColor",
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 38),
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 2,
        Parent = MainFrame,
    })

    local TabBarLine = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 3,
        Parent = TabBar,
    })

    local TabScroll = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        ScrollBarThickness = 0,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        ZIndex = 3,
        Parent = TabBar,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabScroll,
    })

    local ContentArea = New("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 78),
        Size = UDim2.new(1, -16, 1, -88),
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = MainFrame,
    })

    Library.WindowContainer = ContentArea

    local FooterBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -24),
        Size = UDim2.new(1, 0, 0, 24),
        ZIndex = 2,
        Parent = MainFrame,
    })

    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = FooterBar })
    local FooterMask = New("Frame", {
        BackgroundColor3 = "MainColor",
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, Library.CornerRadius),
        ZIndex = 3,
        Parent = FooterBar,
    })

    local FooterLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Text = Footer,
        TextColor3 = "SubFontColor",
        TextSize = 11,
        FontFace = "Font",
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = FooterBar,
    })

    local ResizeButton = New("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.fromOffset(16, 16),
        Text = "",
        ZIndex = 4,
        Parent = MainFrame,
    })

    local ResizeIcon = New("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031068421",
        ImageColor3 = "SubFontColor",
        ImageTransparency = 0.5,
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.fromOffset(12, 12),
        Rotation = 45,
        ZIndex = 4,
        Parent = ResizeButton,
    })

    Library:MakeResizable(MainFrame, ResizeButton)
    Library:MakeDraggable(MainFrame, MainFrame)

    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end)

    local Window = {}

    function Window:ChangeTitle(NewTitle)
        TitleLabel.Text = NewTitle
    end

    function Window:SetFooter(NewFooter)
        FooterLabel.Text = NewFooter
    end

    function Window:Toggle(State)
        Library:Toggle(State)
    end

    function Window:AddTab(...)
        local Name, Icon, Order

        if select("#", ...) == 1 and typeof(select(1, ...)) == "table" then
            local T = select(1, ...)
            Name = T.Name or "Tab"
            Icon = T.Icon
            Order = T.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Order = select(3, ...)
        end

        if not tonumber(Order) then
            Order = #Library.Tabs + 1
        end

        local TabContainer = New("Frame", {
            Name = "Tab_" .. Name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            ZIndex = 3,
            Parent = ContentArea,
        })

        local TabLeft = New("ScrollingFrame", {
            Name = "Left",
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarThickness = 0,
            Size = UDim2.new(0.5, -4, 1, 0),
            ZIndex = 4,
            Parent = TabContainer,
        })

        New("UIListLayout", { Padding = UDim.new(0, 6), Parent = TabLeft })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 10),
            Parent = TabLeft,
        })

        local TabRight = New("ScrollingFrame", {
            Name = "Right",
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.new(0.5, 4, 0, 0),
            ScrollBarThickness = 0,
            Size = UDim2.new(0.5, -4, 1, 0),
            ZIndex = 4,
            Parent = TabContainer,
        })

        New("UIListLayout", { Padding = UDim.new(0, 6), Parent = TabRight })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 10),
            Parent = TabRight,
        })

        local TabButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 0, 30),
            LayoutOrder = Order,
            Text = "",
            ZIndex = 4,
            Parent = TabScroll,
        })

        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabButton })

        local TabButtonContent = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 5,
            Parent = TabButton,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = TabButtonContent,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = TabButtonContent,
        })

        local TabIcon = nil
        if Icon then
            TabIcon = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(14, 14),
                ZIndex = 6,
                Parent = TabButtonContent,
            })

            local IconData = Library:GetCustomIcon(Icon)
            if IconData then
                if IconData.Custom then
                    TabIcon.Image = IconData.Image
                    TabIcon.ImageRectOffset = IconData.RectOffset
                    TabIcon.ImageRectSize = IconData.RectSize
                else
                    TabIcon.Image = "rbxassetid://" .. IconData.RobloxId
                end
            end
        end

        local TabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            Text = Name,
            TextColor3 = "FontColor",
            TextSize = 12,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
            TextTransparency = 0.4,
            ZIndex = 6,
            Parent = TabButtonContent,
        })

        local Tab = {
            Name = Name,
            Container = TabContainer,
            Left = TabLeft,
            Right = TabRight,
            Button = TabButton,
            Label = TabLabel,
            Icon = TabIcon,
            Groupboxes = {},
        }

        function Tab:SetActive(Active)
            if Active then
                if Library.ActiveTab and Library.ActiveTab ~= Tab then
                    Library.ActiveTab:SetActive(false)
                end

                Library.ActiveTab = Tab
                TabContainer.Visible = true
                TabButton.BackgroundColor3 = Library.Scheme.AccentColor
                TabLabel.TextTransparency = 0
                TabLabel.TextColor3 = Library.Scheme.BackgroundColor
                if TabIcon then
                    TabIcon.ImageColor3 = Library.Scheme.BackgroundColor
                end
            else
                TabContainer.Visible = false
                TabButton.BackgroundColor3 = Library.Scheme.MainColor
                TabLabel.TextTransparency = 0.4
                TabLabel.TextColor3 = "FontColor"
                if TabIcon then
                    TabIcon.ImageColor3 = "FontColor"
                end
            end
        end

        TabButton.MouseButton1Click:Connect(function()
            Tab:SetActive(true)
        end)

        TabButton.MouseEnter:Connect(function()
            if Library.ActiveTab ~= Tab then
                TweenService:Create(TabButton, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.HoverColor,
                }):Play()
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Library.ActiveTab ~= Tab then
                TweenService:Create(TabButton, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.MainColor,
                }):Play()
            end
        end)

        table.insert(Library.Tabs, Tab)

        if #Library.Tabs == 1 then
            Tab:SetActive(true)
        end

        function Tab:AddGroupbox(Info)
            Info = Validate(Info or {}, {
                Side = 1,
                Name = "Groupbox",
                IconName = nil,
                Description = nil,
                Visible = true,
                Collapsed = false,
                DisableCollapsing = false,
            })

            local Side = Info.Side
            if Side == "left" then Side = 1
            elseif Side == "right" then Side = 2 end

            local ParentFrame = Side == 1 and TabLeft or TabRight

            local BoxHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 5,
                Parent = ParentFrame,
            })

            local GroupboxFrame = New("Frame", {
                BackgroundColor3 = "MainColor",
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Visible = Info.Visible,
                ZIndex = 6,
                Parent = BoxHolder,
            })

            New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = GroupboxFrame })
            New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = GroupboxFrame })

            local HeaderHeight = 32

            local Header = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, HeaderHeight),
                ZIndex = 7,
                Parent = GroupboxFrame,
            })

            local HeaderIcon = nil
            local TextOffset = 12

            if Info.IconName then
                HeaderIcon = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, -8),
                    Size = UDim2.fromOffset(16, 16),
                    ZIndex = 8,
                    Parent = Header,
                })

                local IconData = Library:GetCustomIcon(Info.IconName)
                if IconData then
                    if IconData.Custom then
                        HeaderIcon.Image = IconData.Image
                        HeaderIcon.ImageRectOffset = IconData.RectOffset
                        HeaderIcon.ImageRectSize = IconData.RectSize
                    else
                        HeaderIcon.Image = "rbxassetid://" .. IconData.RobloxId
                    end
                end

                TextOffset = 32
            end

            local TitleLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, TextOffset, 0, 0),
                Size = UDim2.new(1, -(TextOffset + 12), 0, 18),
                Text = Info.Name,
                TextColor3 = "FontColor",
                TextSize = 13,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
                Parent = Header,
            })

            if Info.Description then
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, TextOffset, 0, 16),
                    Size = UDim2.new(1, -(TextOffset + 12), 0, 14),
                    Text = Info.Description,
                    TextColor3 = "SubFontColor",
                    TextSize = 11,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 8,
                    Parent = Header,
                })
            end

            local CollapseButton = nil
            if not Info.DisableCollapsing then
                CollapseButton = New("TextButton", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.fromOffset(30, HeaderHeight),
                    Text = "",
                    ZIndex = 8,
                    Parent = Header,
                })

                local Chevron = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031068421",
                    ImageColor3 = "SubFontColor",
                    Position = UDim2.new(0.5, -5, 0.5, -5),
                    Size = UDim2.fromOffset(10, 10),
                    Rotation = Info.Collapsed and 0 or 90,
                    ZIndex = 9,
                    Parent = CollapseButton,
                })

                local ContentHolder = nil
                local Collapsed = Info.Collapsed

                CollapseButton.MouseButton1Click:Connect(function()
                    Collapsed = not Collapsed
                    TweenService:Create(Chevron, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = Collapsed and 0 or 90,
                    }):Play()

                    if ContentHolder then
                        ContentHolder.Visible = not Collapsed
                    end
                end)
            end

            local Divider = New("Frame", {
                BackgroundColor3 = "OutlineColor",
                BorderSizePixel = 0,
                Position = UDim2.new(0, 8, 0, HeaderHeight),
                Size = UDim2.new(1, -16, 0, 1),
                ZIndex = 7,
                Parent = GroupboxFrame,
            })

            local Content = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Visible = not Info.Collapsed,
                ZIndex = 7,
                Parent = GroupboxFrame,
            })

            New("UIListLayout", { Padding = UDim.new(0, 4), Parent = Content })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                Parent = Content,
            })

            if CollapseButton then
                -- Store content holder reference for collapse toggle
                -- We use a different approach: store in closure
                local OldAddToggle = nil
            end

            local Group = {
                Name = Info.Name,
                Container = Content,
                Frame = GroupboxFrame,
                BoxHolder = BoxHolder,
                Elements = {},
            }

            function Group:Resize()
                -- Auto-size is handled by AutomaticSize
            end

            function Group:SetVisible(Visible)
                BoxHolder.Visible = Visible
            end

            function Group:Show()
                Group:SetVisible(true)
            end

            function Group:Hide()
                Group:SetVisible(false)
            end

            function Group:AddToggle(Idx, ToggleInfo)
                ToggleInfo = Validate(ToggleInfo or {}, {
                    Text = "Toggle",
                    Default = false,
                    Callback = function() end,
                    Changed = function() end,
                    Risky = false,
                    Disabled = false,
                    Visible = true,
                })

                local Holder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Visible = ToggleInfo.Visible,
                    ZIndex = 8,
                    Parent = Content,
                })

                local ToggleButton = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 9,
                    Parent = Holder,
                })

                local ToggleLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -46, 1, 0),
                    Text = ToggleInfo.Text,
                    TextColor3 = ToggleInfo.Risky and "RedColor" or "FontColor",
                    TextSize = 12,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = ToggleInfo.Disabled and 0.5 or 0,
                    ZIndex = 10,
                    Parent = ToggleButton,
                })

                local SwitchBG = New("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = "MainColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -38, 0.5, 0),
                    Size = UDim2.new(0, 36, 0, 18),
                    ZIndex = 10,
                    Parent = ToggleButton,
                })

                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchBG })
                New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = SwitchBG })

                local SwitchBall = New("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = "FontColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 3, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 11,
                    Parent = SwitchBG,
                })

                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchBall })

                local ToggleObj = {
                    Value = ToggleInfo.Default,
                    Index = Idx,
                    Type = "Toggle",
                    Text = ToggleInfo.Text,
                    Holder = Holder,
                    Disabled = ToggleInfo.Disabled,
                    Visible = ToggleInfo.Visible,
                }

                function ToggleObj:SetValue(Value)
                    ToggleObj.Value = Value

                    local TargetPos = Value and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                    local TargetColor = Value and Library.Scheme.AccentColor or Library.Scheme.MainColor

                    TweenService:Create(SwitchBall, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = TargetPos,
                    }):Play()
                    TweenService:Create(SwitchBG, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = TargetColor,
                    }):Play()

                    ToggleInfo.Callback(Value)
                    ToggleInfo.Changed(Value)
                end

                function ToggleObj:SetDisabled(Disabled)
                    ToggleObj.Disabled = Disabled
                    ToggleLabel.TextTransparency = Disabled and 0.5 or 0
                end

                function ToggleObj:SetVisible(Visible)
                    ToggleObj.Visible = Visible
                    Holder.Visible = Visible
                end

                function ToggleObj:SetText(Text)
                    ToggleObj.Text = Text
                    ToggleLabel.Text = Text
                end

                ToggleButton.MouseButton1Click:Connect(function()
                    if not ToggleObj.Disabled then
                        ToggleObj:SetValue(not ToggleObj.Value)
                    end
                end)

                ToggleButton.MouseEnter:Connect(function()
                    if not ToggleObj.Disabled then
                        TweenService:Create(ToggleLabel, Library.TweenInfo, {
                            TextTransparency = 0.1,
                        }):Play()
                    end
                end)

                ToggleButton.MouseLeave:Connect(function()
                    if not ToggleObj.Disabled then
                        TweenService:Create(ToggleLabel, Library.TweenInfo, {
                            TextTransparency = 0,
                        }):Play()
                    end
                end)

                Toggles[Idx] = ToggleObj
                table.insert(Group.Elements, ToggleObj)

                ToggleObj:SetValue(ToggleInfo.Default)
                return ToggleObj
            end

            function Group:AddButton(ButtonInfo)
                if typeof(ButtonInfo) == "string" then
                    ButtonInfo = { Text = ButtonInfo, Func = function() end }
                end
                ButtonInfo = Validate(ButtonInfo, {
                    Text = "Button",
                    Func = function() end,
                    Disabled = false,
                    Visible = true,
                    Risky = false,
                })

                local ButtonFrame = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Visible = ButtonInfo.Visible,
                    ZIndex = 8,
                    Parent = Content,
                })

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 9,
                    Parent = ButtonFrame,
                })

                New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Button })
                New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = Button })

                local BtnLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    Text = ButtonInfo.Text,
                    TextColor3 = ButtonInfo.Risky and "RedColor" or "FontColor",
                    TextSize = 12,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = ButtonInfo.Disabled and 0.5 or 0,
                    ZIndex = 10,
                    Parent = Button,
                })

                local HoverFrame = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 10,
                    Parent = Button,
                })

                if not ButtonInfo.Disabled then
                    HoverFrame.InputBegan:Connect(function(Input)
                        if IsMouseInput(Input) then
                            TweenService:Create(Button, Library.TweenInfo, {
                                BackgroundColor3 = Library.Scheme.HoverColor,
                            }):Play()
                        end
                    end)

                    HoverFrame.InputEnded:Connect(function(Input)
                        if IsMouseInput(Input) then
                            TweenService:Create(Button, Library.TweenInfo, {
                                BackgroundColor3 = Library.Scheme.MainColor,
                            }):Play()
                        end
                    end)

                    Button.MouseButton1Click:Connect(function()
                        ButtonInfo.Func()
                    end)
                end

                local BtnObj = {
                    Text = ButtonInfo.Text,
                    Holder = ButtonFrame,
                    Disabled = ButtonInfo.Disabled,
                    Visible = ButtonInfo.Visible,
                }

                function BtnObj:SetText(Text)
                    BtnLabel.Text = Text
                end

                function BtnObj:SetDisabled(Disabled)
                    BtnObj.Disabled = Disabled
                    BtnLabel.TextTransparency = Disabled and 0.5 or 0
                end

                function BtnObj:SetVisible(Visible)
                    BtnObj.Visible = Visible
                    ButtonFrame.Visible = Visible
                end

                table.insert(Group.Elements, BtnObj)
                return BtnObj
            end

            function Group:AddLabel(Text)
                local LabelHolder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    ZIndex = 8,
                    Parent = Content,
                })

                local LabelText = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = Text,
                    TextColor3 = "FontColor",
                    TextSize = 12,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                    Parent = LabelHolder,
                })

                local LabelObj = {
                    Text = Text,
                    Holder = LabelHolder,
                    Visible = true,
                }

                function LabelObj:SetText(NewText)
                    LabelObj.Text = NewText
                    LabelText.Text = NewText
                end

                function LabelObj:SetVisible(Visible)
                    LabelObj.Visible = Visible
                    LabelHolder.Visible = Visible
                end

                table.insert(Group.Elements, LabelObj)
                return LabelObj
            end

            function Group:AddSlider(Idx, SliderInfo)
                SliderInfo = Validate(SliderInfo or {}, {
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
                })

                local Holder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44),
                    Visible = SliderInfo.Visible,
                    ZIndex = 8,
                    Parent = Content,
                })

                local SliderLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -60, 0, 16),
                    Text = SliderInfo.Text,
                    TextColor3 = "FontColor",
                    TextSize = 12,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                    Parent = Holder,
                })

                local SliderValue = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -58, 0, 0),
                    Size = UDim2.fromOffset(58, 16),
                    Text = tostring(SliderInfo.Default),
                    TextColor3 = "AccentColor",
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 9,
                    Parent = Holder,
                })

                local BarBG = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 6),
                    ZIndex = 9,
                    Parent = Holder,
                })

                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = BarBG })

                local BarFill = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(0, 1),
                    ZIndex = 10,
                    Parent = BarBG,
                })

                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = BarFill })

                local BarKnob = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = "FontColor",
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.fromOffset(12, 12),
                    ZIndex = 11,
                    Parent = BarFill,
                })

                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = BarKnob })

                local SliderObj = {
                    Value = SliderInfo.Default,
                    Index = Idx,
                    Type = "Slider",
                    Text = SliderInfo.Text,
                    Holder = Holder,
                    Disabled = SliderInfo.Disabled,
                    Visible = SliderInfo.Visible,
                }

                function SliderObj:SetValue(Value)
                    Value = math.clamp(Value, SliderInfo.Min, SliderInfo.Max)
                    Value = Round(Value, SliderInfo.Rounding)
                    SliderObj.Value = Value

                    local Percent = (Value - SliderInfo.Min) / (SliderInfo.Max - SliderInfo.Min)
                    TweenService:Create(BarFill, TweenInfo.new(0.1), {
                        Size = UDim2.fromScale(Percent, 1),
                    }):Play()

                    SliderValue.Text = SliderInfo.Prefix .. tostring(Value) .. SliderInfo.Suffix

                    SliderInfo.Callback(Value)
                    SliderInfo.Changed(Value)
                end

                function SliderObj:SetMin(Value)
                    SliderInfo.Min = Value
                end

                function SliderObj:SetMax(Value)
                    SliderInfo.Max = Value
                end

                function SliderObj:SetDisabled(Disabled)
                    SliderObj.Disabled = Disabled
                    SliderLabel.TextTransparency = Disabled and 0.5 or 0
                end

                function SliderObj:SetVisible(Visible)
                    SliderObj.Visible = Visible
                    Holder.Visible = Visible
                end

                function SliderObj:SetText(Text)
                    SliderLabel.Text = Text
                end

                local function UpdateSlider(Input)
                    local Scale = math.clamp(
                        (Input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X,
                        0, 1
                    )
                    local Value = SliderInfo.Min + (Scale * (SliderInfo.Max - SliderInfo.Min))
                    SliderObj:SetValue(Value)
                end

                local DraggingBar = false

                BarBG.InputBegan:Connect(function(Input)
                    if IsMouseInput(Input) and not SliderObj.Disabled then
                        DraggingBar = true
                        UpdateSlider(Input)
                    end
                end)

                Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
                    if DraggingBar and IsMovementInput(Input) then
                        UpdateSlider(Input)
                    end
                end))

                Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
                    if IsMouseInput(Input) then
                        DraggingBar = false
                    end
                end))

                BarBG.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton2 and not SliderObj.Disabled then
                        local function EndInput(_, Enter)
                            if Enter then
                                SliderObj:SetValue(tonumber(Input.KeyCode and Input.KeyCode.Name or SliderInfo.Default) or SliderInfo.Default)
                            end
                        end
                    end
                end)

                Options[Idx] = SliderObj
                table.insert(Group.Elements, SliderObj)
                SliderObj:SetValue(SliderInfo.Default)
                return SliderObj
            end

            function Group:AddInput(Idx, InputInfo)
                InputInfo = Validate(InputInfo or {}, {
                    Text = "Input",
                    Default = "",
                    Placeholder = "",
                    Finished = false,
                    ClearTextOnFocus = true,
                    Callback = function() end,
                    Changed = function() end,
                    Disabled = false,
                    Visible = true,
                })

                local Holder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44),
                    Visible = InputInfo.Visible,
                    ZIndex = 8,
                    Parent = Content,
                })

                local InputLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = InputInfo.Text,
                    TextColor3 = "FontColor",
                    TextSize = 12,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = InputInfo.Disabled and 0.5 or 0,
                    ZIndex = 9,
                    Parent = Holder,
                })

                local InputBox = New("TextBox", {
                    BackgroundColor3 = "BackgroundColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 22),
                    PlaceholderText = InputInfo.Placeholder,
                    Text = InputInfo.Default,
                    TextColor3 = "FontColor",
                    PlaceholderColor3 = "SubFontColor",
                    TextSize = 12,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = InputInfo.ClearTextOnFocus,
                    ZIndex = 9,
                    Parent = Holder,
                })

                New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = InputBox })
                New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = InputBox })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    Parent = InputBox,
                })

                local InputObj = {
                    Value = InputInfo.Default,
                    Index = Idx,
                    Type = "Input",
                    Text = InputInfo.Text,
                    Holder = Holder,
                    Disabled = InputInfo.Disabled,
                    Visible = InputInfo.Visible,
                }

                function InputObj:SetValue(Value)
                    InputObj.Value = Value
                    InputBox.Text = Value
                    InputInfo.Callback(Value)
                    InputInfo.Changed(Value)
                end

                function InputObj:SetDisabled(Disabled)
                    InputObj.Disabled = Disabled
                    InputLabel.TextTransparency = Disabled and 0.5 or 0
                    InputBox.TextTransparency = Disabled and 0.5 or 0
                end

                function InputObj:SetVisible(Visible)
                    InputObj.Visible = Visible
                    Holder.Visible = Visible
                end

                function InputObj:SetText(Text)
                    InputLabel.Text = Text
                end

                InputBox.Focused:Connect(function()
                    TweenService:Create(InputBox, Library.TweenInfo, {
                        BackgroundColor3 = Library.Scheme.HoverColor,
                    }):Play()
                end)

                InputBox.FocusLost:Connect(function(EnterPressed)
                    TweenService:Create(InputBox, Library.TweenInfo, {
                        BackgroundColor3 = Library.Scheme.BackgroundColor,
                    }):Play()

                    if InputInfo.Finished then
                        if EnterPressed then
                            InputObj:SetValue(InputBox.Text)
                        end
                    else
                        InputObj:SetValue(InputBox.Text)
                    end
                end)

                Options[Idx] = InputObj
                table.insert(Group.Elements, InputObj)
                return InputObj
            end

            function Group:AddDropdown(Idx, DropdownInfo)
                DropdownInfo = Validate(DropdownInfo or {}, {
                    Text = "Dropdown",
                    Values = {},
                    Value = nil,
                    Multi = false,
                    Callback = function() end,
                    Changed = function() end,
                    Disabled = false,
                    Visible = true,
                    MaxVisibleItems = 6,
                })

                local Holder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44),
                    Visible = DropdownInfo.Visible,
                    ZIndex = 8,
                    Parent = Content,
                })

                local DropLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = DropdownInfo.Text,
                    TextColor3 = "FontColor",
                    TextSize = 12,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = DropdownInfo.Disabled and 0.5 or 0,
                    ZIndex = 9,
                    Parent = Holder,
                })

                local DropButton = New("TextButton", {
                    BackgroundColor3 = "BackgroundColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 22),
                    Text = "",
                    ZIndex = 9,
                    Parent = Holder,
                })

                New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = DropButton })
                New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = DropButton })

                local DropText = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -34, 1, 0),
                    Text = "---",
                    TextColor3 = "FontColor",
                    TextSize = 12,
                    FontFace = "Font",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                    Parent = DropButton,
                })

                local ArrowIcon = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031068421",
                    ImageColor3 = "SubFontColor",
                    Position = UDim2.new(1, -22, 0.5, -4),
                    Size = UDim2.fromOffset(8, 8),
                    Rotation = 0,
                    ZIndex = 10,
                    Parent = DropButton,
                })

                local DropList = New("ScrollingFrame", {
                    BackgroundColor3 = "MainColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 0),
                    CanvasSize = UDim2.fromScale(0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = "AccentColor",
                    Visible = false,
                    ZIndex = 20,
                    Parent = DropButton,
                })

                New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = DropList })
                New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = DropList })
                New("UIListLayout", { Padding = UDim.new(0, 2), Parent = DropList })
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    Parent = DropList,
                })

                local DropObj = {
                    Value = DropdownInfo.Value,
                    Index = Idx,
                    Type = "Dropdown",
                    Text = DropdownInfo.Text,
                    Holder = Holder,
                    Disabled = DropdownInfo.Disabled,
                    Visible = DropdownInfo.Visible,
                    Open = false,
                    Items = {},
                }

                local MaxHeight = DropdownInfo.MaxVisibleItems * 26
                local ItemCount = #DropdownInfo.Values
                local ListHeight = math.min(ItemCount * 26 + 8, MaxHeight)
                DropList.Size = UDim2.new(1, 0, 0, ListHeight)

                for _, Value in ipairs(DropdownInfo.Values) do
                    local Item = New("TextButton", {
                        BackgroundColor3 = "BackgroundColor",
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 22),
                        Text = "",
                        ZIndex = 21,
                        Parent = DropList,
                    })

                    New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Item })

                    local ItemLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(1, -16, 1, 0),
                        Text = tostring(Value),
                        TextColor3 = "FontColor",
                        TextSize = 12,
                        FontFace = "Font",
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 22,
                        Parent = Item,
                    })

                    Item.MouseEnter:Connect(function()
                        TweenService:Create(Item, Library.TweenInfo, {
                            BackgroundColor3 = Library.Scheme.HoverColor,
                        }):Play()
                    end)

                    Item.MouseLeave:Connect(function()
                        local IsSelected = DropObj.Value == Value
                        TweenService:Create(Item, Library.TweenInfo, {
                            BackgroundColor3 = IsSelected and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor,
                        }):Play()
                        if IsSelected then
                            ItemLabel.TextColor3 = Library.Scheme.BackgroundColor
                        else
                            ItemLabel.TextColor3 = Library.Scheme.FontColor
                        end
                    end)

                    Item.MouseButton1Click:Connect(function()
                        if DropObj.Value == Value then
                            DropObj.Value = nil
                            DropText.Text = "---"
                        else
                            DropObj.Value = Value
                            DropText.Text = tostring(Value)
                        end

                        DropList.Visible = false
                        ArrowIcon.Rotation = 0
                        DropObj.Open = false

                        DropdownInfo.Callback(DropObj.Value)
                        DropdownInfo.Changed(DropObj.Value)

                        for _, OtherItem in ipairs(DropList:GetChildren()) do
                            if OtherItem:IsA("TextButton") then
                                local OtherLabel = OtherItem:FindFirstChildOfClass("TextLabel")
                                if OtherLabel and OtherLabel.Text == tostring(DropObj.Value) then
                                    TweenService:Create(OtherItem, Library.TweenInfo, {
                                        BackgroundColor3 = Library.Scheme.AccentColor,
                                    }):Play()
                                    OtherLabel.TextColor3 = Library.Scheme.BackgroundColor
                                else
                                    TweenService:Create(OtherItem, Library.TweenInfo, {
                                        BackgroundColor3 = Library.Scheme.BackgroundColor,
                                    }):Play()
                                    if OtherLabel then
                                        OtherLabel.TextColor3 = Library.Scheme.FontColor
                                    end
                                end
                            end
                        end
                    end)

                    table.insert(DropObj.Items, { Button = Item, Label = ItemLabel, Value = Value })
                end

                function DropObj:SetValue(Value)
                    DropObj.Value = Value
                    DropText.Text = Value and tostring(Value) or "---"

                    for _, ItemData in ipairs(DropObj.Items) do
                        if ItemData.Value == Value then
                            TweenService:Create(ItemData.Button, Library.TweenInfo, {
                                BackgroundColor3 = Library.Scheme.AccentColor,
                            }):Play()
                            ItemData.Label.TextColor3 = Library.Scheme.BackgroundColor
                        else
                            TweenService:Create(ItemData.Button, Library.TweenInfo, {
                                BackgroundColor3 = Library.Scheme.BackgroundColor,
                            }):Play()
                            ItemData.Label.TextColor3 = Library.Scheme.FontColor
                        end
                    end

                    DropdownInfo.Callback(Value)
                    DropdownInfo.Changed(Value)
                end

                function DropObj:SetValues(Values)
                    DropdownInfo.Values = Values
                    for _, ItemData in ipairs(DropObj.Items) do
                        ItemData.Button:Destroy()
                    end
                    DropObj.Items = {}

                    for _, Val in ipairs(Values) do
                        local Item = New("TextButton", {
                            BackgroundColor3 = "BackgroundColor",
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 22),
                            Text = "",
                            ZIndex = 21,
                            Parent = DropList,
                        })
                        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Item })
                        local ItemLabel = New("TextLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 8, 0, 0),
                            Size = UDim2.new(1, -16, 1, 0),
                            Text = tostring(Val),
                            TextColor3 = "FontColor",
                            TextSize = 12,
                            FontFace = "Font",
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 22,
                            Parent = Item,
                        })

                        Item.MouseEnter:Connect(function()
                            TweenService:Create(Item, Library.TweenInfo, {
                                BackgroundColor3 = Library.Scheme.HoverColor,
                            }):Play()
                        end)
                        Item.MouseLeave:Connect(function()
                            local IsSel = DropObj.Value == Val
                            TweenService:Create(Item, Library.TweenInfo, {
                                BackgroundColor3 = IsSel and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor,
                            }):Play()
                            if IsSel then
                                ItemLabel.TextColor3 = Library.Scheme.BackgroundColor
                            else
                                ItemLabel.TextColor3 = Library.Scheme.FontColor
                            end
                        end)
                        Item.MouseButton1Click:Connect(function()
                            DropObj:SetValue(Val)
                            DropList.Visible = false
                            ArrowIcon.Rotation = 0
                            DropObj.Open = false
                        end)

                        table.insert(DropObj.Items, { Button = Item, Label = ItemLabel, Value = Val })
                    end

                    local NewCount = #Values
                    local NewHeight = math.min(NewCount * 26 + 8, MaxHeight)
                    DropList.Size = UDim2.new(1, 0, 0, NewHeight)
                end

                function DropObj:SetDisabled(Disabled)
                    DropObj.Disabled = Disabled
                    DropLabel.TextTransparency = Disabled and 0.5 or 0
                end

                function DropObj:SetVisible(Visible)
                    DropObj.Visible = Visible
                    Holder.Visible = Visible
                end

                function DropObj:SetText(Text)
                    DropLabel.Text = Text
                end

                DropButton.MouseButton1Click:Connect(function()
                    if DropObj.Disabled then return end

                    DropObj.Open = not DropObj.Open
                    DropList.Visible = DropObj.Open

                    TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = DropObj.Open and 180 or 0,
                    }):Play()
                end)

                UserInputService.InputBegan:Connect(function(Input, GP)
                    if GP then return end
                    if DropObj.Open and IsMouseInput(Input) then
                        local MousePos = UserInputService:GetMouseLocation()
                        local ButtonAbsPos = DropButton.AbsolutePosition
                        local ButtonAbsSize = DropButton.AbsoluteSize
                        local ListAbsPos = DropList.AbsolutePosition
                        local ListAbsSize = DropList.AbsoluteSize

                        local OverButton = MousePos.X >= ButtonAbsPos.X and MousePos.X <= ButtonAbsPos.X + ButtonAbsSize.X
                            and MousePos.Y >= ButtonAbsPos.Y and MousePos.Y <= ButtonAbsPos.Y + ButtonAbsSize.Y
                        local OverList = MousePos.X >= ListAbsPos.X and MousePos.X <= ListAbsPos.X + ListAbsSize.X
                            and MousePos.Y >= ListAbsPos.Y and MousePos.Y <= ListAbsPos.Y + ListAbsSize.Y

                        if not OverButton and not OverList then
                            DropObj.Open = false
                            DropList.Visible = false
                            TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Rotation = 0,
                            }):Play()
                        end
                    end
                end)

                Options[Idx] = DropObj
                table.insert(Group.Elements, DropObj)

                if DropdownInfo.Value then
                    DropObj:SetValue(DropdownInfo.Value)
                elseif #DropdownInfo.Values > 0 then
                    DropObj:SetValue(DropdownInfo.Values[1])
                end

                return DropObj
            end

            function Group:AddDivider(Text)
                local DividerHolder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, Text and 24 or 10),
                    ZIndex = 8,
                    Parent = Content,
                })

                local Line = New("Frame", {
                    BackgroundColor3 = "OutlineColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, Text and 0.5 or 0, Text and 8 or 4),
                    Size = UDim2.new(1, 0, 0, 1),
                    ZIndex = 9,
                    Parent = DividerHolder,
                })

                if Text then
                    local DividerText = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.new(0, 0, 0, 16),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Text = Text,
                        TextColor3 = "SubFontColor",
                        TextSize = 10,
                        FontFace = "Font",
                        BackgroundColor3 = "MainColor",
                        ZIndex = 10,
                        Parent = DividerHolder,
                    })

                    New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = DividerText })
                    DividerText.AutomaticSize = Enum.AutomaticSize.X
                end

                table.insert(Group.Elements, { Holder = DividerHolder, Visible = true })
                return DividerHolder
            end

            function Tab:AddLeftGroupbox(Name, Icon)
                return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = Icon })
            end

            function Tab:AddRightGroupbox(Name, Icon)
                return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = Icon })
            end

            table.insert(Tab.Groupboxes, Group)
            return Group
        end

        return Tab
    end

    return Window
end

function Library:GetCustomIcon(IconName)
    if not IconName then
        return nil
    end

    if typeof(IconName) == "table" then
        return IconName
    end

    if typeof(IconName) == "number" then
        return { RobloxId = IconName, Custom = false }
    end

    if typeof(IconName) == "string" and (IconName:match("^rbxasset") or IconName:match("^rbxthumb")) then
        return { Image = IconName, RectOffset = Vector2.zero, RectSize = Vector2.zero, Custom = true }
    end

    local Icons = {
        home = { RobloxId = 6031068421, Custom = false },
        user = { RobloxId = 6031070791, Custom = false },
        settings = { RobloxId = 6031075095, Custom = false },
        star = { RobloxId = 6031075916, Custom = false },
        search = { RobloxId = 6031075930, Custom = false },
        bell = { RobloxId = 6031071099, Custom = false },
        check = { RobloxId = 6031068420, Custom = false },
        x = { RobloxId = 6031075916, Custom = false },
        chevron_right = { RobloxId = 6031068421, Custom = false },
        chevron_down = { RobloxId = 6031068421, Custom = false },
        gear = { RobloxId = 6031075095, Custom = false },
        wrench = { RobloxId = 6031075916, Custom = false },
        code = { RobloxId = 6031070791, Custom = false },
        folder = { RobloxId = 6031075095, Custom = false },
        image = { RobloxId = 6031075916, Custom = false },
        trash = { RobloxId = 6031068420, Custom = false },
        play = { RobloxId = 6031068421, Custom = false },
        pause = { RobloxId = 6031075930, Custom = false },
    }

    return Icons[IconName]
end

Library.Notify = Library.Notify
Library.Toggle = Library.Toggle

return Library
