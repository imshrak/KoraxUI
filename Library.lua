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
    Toggled = false,
    Unloaded = false,
    ToggleKeybind = Enum.KeyCode.RightControl,
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,
    Registry = {},
    Corners = {},
    Signals = {},
    NotifySide = "Right",
    Notifications = {},
    CornerRadius = 4,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(125, 85, 255),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Code),
        RedColor = Color3.fromRGB(255, 50, 50),
    },
    Icons = {
        move = "rbxassetid://92481398073007",
        home = "rbxassetid://10723407389",
        user = "rbxassetid://10747373176",
        settings = "rbxassetid://10734950309",
        star = "rbxassetid://10734966248",
        search = "rbxassetid://10734943674",
        bell = "rbxassetid://10709775704",
        check = "rbxassetid://10709790644",
        x = "rbxassetid://10747384394",
        chevron_down = "rbxassetid://10709790948",
        chevron_right = "rbxassetid://10709791437",
        code = "rbxassetid://10709810463",
        folder = "rbxassetid://10723387563",
        image = "rbxassetid://10723415040",
        trash = "rbxassetid://10747362393",
        play = "rbxassetid://10734923549",
        wrench = "rbxassetid://10747383470",
        shield = "rbxassetid://10734951847",
        crosshair = "rbxassetid://10709818534",
        eye = "rbxassetid://10723346959",
        zap = "rbxassetid://10747384834",
        target = "rbxassetid://10734977012",
        compass = "rbxassetid://10709811445",
        globe = "rbxassetid://10723404337",
        map = "rbxassetid://10734886202",
        lock = "rbxassetid://10723434711",
        unlock = "rbxassetid://10747366027",
        save = "rbxassetid://10734941499",
        download = "rbxassetid://10723344270",
        upload = "rbxassetid://10747366434",
        copy = "rbxassetid://10709812159",
        clipboard = "rbxassetid://10709799288",
        edit = "rbxassetid://10734883598",
        terminal = "rbxassetid://10734982144",
        cpu = "rbxassetid://10709813383",
        database = "rbxassetid://10709818996",
        server = "rbxassetid://10734949856",
        users = "rbxassetid://10747373426",
        activity = "rbxassetid://10709752035",
        layers = "rbxassetid://10723424505",
        box = "rbxassetid://10709782497",
        tag = "rbxassetid://10734976528",
        bookmark = "rbxassetid://10709782154",
        clock = "rbxassetid://10709805144",
        filter = "rbxassetid://10723375128",
        flag = "rbxassetid://10723375890",
        hash = "rbxassetid://10723405975",
        link = "rbxassetid://10723426722",
        mail = "rbxassetid://10734885430",
        message_circle = "rbxassetid://10734888000",
        phone = "rbxassetid://10734921524",
        send = "rbxassetid://10734943902",
        share = "rbxassetid://10734950813",
        type = "rbxassetid://10747364761",
        alert_triangle = "rbxassetid://10709753149",
        info = "rbxassetid://10723415903",
    },
}

local function GetSchemeValue(Index)
    return Library.Scheme[Index]
end

local function AddCorner(Parent, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or Library.CornerRadius)
    Corner.Parent = Parent
    table.insert(Library.Corners, Corner)
    return Corner
end

local function AddStroke(Parent, Color, Thickness)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or Library.Scheme.OutlineColor
    Stroke.Thickness = Thickness or 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Parent
    return Stroke
end

local function New(Class, Properties)
    local Obj = Instance.new(Class)
    for Property, Value in Properties do
        if typeof(Value) == "function" then
            Obj[Property] = Value()
        elseif typeof(Value) == "string" then
            local SchemeValue = GetSchemeValue(Value)
            if SchemeValue ~= nil then
                Obj[Property] = SchemeValue
            else
                Obj[Property] = Value
            end
        else
            Obj[Property] = Value
        end
    end
    return Obj
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

local function GetIcon(IconName)
    if not IconName then return nil end
    if typeof(IconName) == "number" then
        return "rbxassetid://" .. tostring(IconName)
    end
    if typeof(IconName) == "string" and (IconName:match("^rbxasset") or IconName:match("^rbxthumb")) then
        return IconName
    end
    return Library.Icons[IconName]
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
                StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
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
            UI.Size = UDim2.fromOffset(
                math.max(480, StartSize.X + Delta.X),
                math.max(320, StartSize.Y + Delta.Y)
            )
            if Callback then Callback() end
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

    local Side = Library.NotifySide
    local NotifFrame = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.fromOffset(300, 60),
        Position = Side == "Right"
            and UDim2.new(1, -310, 0, 8 + (#Library.Notifications * 68))
            or UDim2.new(0, 10, 0, 8 + (#Library.Notifications * 68)),
        ZIndex = 200,
        Parent = Library.ScreenGui,
    })
    AddCorner(NotifFrame)
    AddStroke(NotifFrame)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -24, 0, 18),
        Text = Info.Title or "Notification",
        TextColor3 = "AccentColor",
        TextSize = 14,
        FontFace = Library.Scheme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 201,
        Parent = NotifFrame,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 30),
        Size = UDim2.new(1, -24, 0, 22),
        Text = Info.Text or "",
        TextColor3 = "FontColor",
        TextSize = 14,
        FontFace = Library.Scheme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 201,
        Parent = NotifFrame,
    })

    table.insert(Library.Notifications, NotifFrame)

    task.delay(Info.Time or 3, function()
        if NotifFrame and NotifFrame.Parent then
            local T = TweenService:Create(NotifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = Side == "Right"
                    and UDim2.new(1, 310, NotifFrame.Position.Y.Scale, NotifFrame.Position.Y.Offset)
                    or UDim2.new(0, -310, NotifFrame.Position.Y.Scale, NotifFrame.Position.Y.Offset),
            })
            T:Play()
            T.Completed:Connect(function()
                local Idx = table.find(Library.Notifications, NotifFrame)
                if Idx then table.remove(Library.Notifications, Idx) end
                NotifFrame:Destroy()
            end)
        end
    end)
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
    local Size = Info.Size or UDim2.fromOffset(720, 600)
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
    })
    pcall(protectgui, ScreenGui)
    ScreenGui.Parent = gethui()
    Library.ScreenGui = ScreenGui

    local CR = Library.CornerRadius

    local MainFrame = New("TextButton", {
        BackgroundColor3 = function()
            local H, S, V = Library.Scheme.BackgroundColor:ToHSV()
            return Color3.fromHSV(H, S, V - 0.01)
        end,
        Text = "",
        AutoButtonColor = false,
        Position = UDim2.fromOffset(6, 6),
        Size = Size,
        Visible = AutoShow,
    })
    pcall(function() MainFrame.Parent = ScreenGui end)
    if not MainFrame.Parent then
        MainFrame.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    AddCorner(MainFrame)
    AddStroke(MainFrame)
    Library.Window = MainFrame
    Library.Toggled = AutoShow

    New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = MainFrame,
    })

    local TopBar = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        Parent = MainFrame,
    })
    Library:MakeDraggable(MainFrame, TopBar)

    local TitleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0, 300, 1, 0),
        Text = Title,
        TextColor3 = "FontColor",
        TextSize = 20,
        FontFace = Library.Scheme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    local TabBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainFrame,
    })

    New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 39),
        Size = UDim2.new(1, 0, 0, 1),
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
        Parent = TabBar,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabScroll,
    })

    local ContentArea = New("Frame", {
        BackgroundColor3 = function()
            local H, S, V = Library.Scheme.BackgroundColor:ToHSV()
            return Color3.fromHSV(H, S, V + 0.01)
        end,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 90),
        Size = UDim2.new(1, 0, 1, -111),
        ClipsDescendants = true,
        Parent = MainFrame,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 0),
        PaddingBottom = UDim.new(0, 0),
        Parent = ContentArea,
    })

    Library.WindowContainer = ContentArea

    local BottomBar = New("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = function()
            local H, S, V = Library.Scheme.BackgroundColor:ToHSV()
            return Color3.fromHSV(H, S, V - 0.01)
        end,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 20 + CR),
        Parent = MainFrame,
    })
    AddCorner(BottomBar)

    New("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -20),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = MainFrame,
    })

    local FooterLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = Footer,
        TextColor3 = "FontColor",
        TextSize = 14,
        TextTransparency = 0.5,
        FontFace = Library.Scheme.Font,
        Parent = BottomBar,
    })

    local ResizeButton = New("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -(20 + CR), 1, -(20 + CR)),
        Size = UDim2.fromOffset(20, 20),
        Text = "",
        ZIndex = 5,
        Parent = MainFrame,
    })

    local ResizeIcon = New("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734953073",
        ImageColor3 = "FontColor",
        ImageTransparency = 0.7,
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.fromOffset(12, 12),
        Rotation = 45,
        ZIndex = 5,
        Parent = ResizeButton,
    })

    Library:MakeResizable(MainFrame, ResizeButton)

    UserInputService.InputBegan:Connect(function(Input, GP)
        if GP then return end
        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end)

    local Window = {}

    function Window:Toggle(State)
        Library:Toggle(State)
    end

    function Window:ChangeTitle(NewTitle)
        TitleLabel.Text = NewTitle
    end

    function Window:SetFooter(NewFooter)
        FooterLabel.Text = NewFooter
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
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = ContentArea,
        })

        local TabLeft = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarThickness = 0,
            Size = UDim2.new(0.5, -3, 1, 0),
            Parent = TabContainer,
        })
        New("UIListLayout", { Padding = UDim.new(0, 2), Parent = TabLeft })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = TabLeft,
        })

        local TabRight = New("ScrollingFrame", {
            AnchorPoint = Vector2.new(1, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.new(1, 0, 0, 0),
            ScrollBarThickness = 0,
            Size = UDim2.new(0.5, -3, 1, 0),
            Parent = TabContainer,
        })
        New("UIListLayout", { Padding = UDim.new(0, 2), Parent = TabRight })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = TabRight,
        })

        local TabButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 34),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            LayoutOrder = Order,
            Parent = TabScroll,
        })
        AddCorner(TabButton, CR)

        local ButtonHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = TabButton,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 8),
            Parent = ButtonHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = ButtonHolder,
        })

        local TabIcon = nil
        if Icon then
            local IconId = GetIcon(Icon)
            if IconId then
                TabIcon = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Image = IconId,
                    ImageColor3 = "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromOffset(16, 16),
                    Parent = ButtonHolder,
                })
            end
        end

        local TabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            Text = Name,
            TextColor3 = "FontColor",
            TextSize = 16,
            FontFace = Library.Scheme.Font,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ButtonHolder,
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
                TabButton.BackgroundColor3 = Library.Scheme.MainColor
                TabButton.BackgroundTransparency = 0
                TabLabel.TextTransparency = 0
                if TabIcon then
                    TabIcon.ImageTransparency = 0
                end
            else
                TabContainer.Visible = false
                TabButton.BackgroundTransparency = 1
                TabLabel.TextTransparency = 0.5
                if TabIcon then
                    TabIcon.ImageTransparency = 0.5
                end
            end
        end

        TabButton.MouseButton1Click:Connect(function()
            Tab:SetActive(true)
        end)

        TabButton.MouseEnter:Connect(function()
            if Library.ActiveTab ~= Tab then
                TabButton.BackgroundTransparency = 0.9
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Library.ActiveTab ~= Tab then
                TabButton.BackgroundTransparency = 1
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
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = ParentFrame,
            })
            New("UIListLayout", { Padding = UDim.new(0, 6), Parent = BoxHolder })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Parent = BoxHolder,
            })
            AddCorner(GroupboxHolder)
            AddStroke(GroupboxHolder)
            New("UIListLayout", { Parent = GroupboxHolder })

            local GroupboxTop = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = GroupboxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 6),
                Parent = GroupboxTop,
            })

            local RightInset = if not Info.DisableCollapsing then 22 else 0
            local TextsFrame = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.new(1, -RightInset, 0, 0),
                Parent = GroupboxTop,
            })
            New("UIListLayout", { Parent = TextsFrame })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 3),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 3),
                Parent = TextsFrame,
            })

            if Info.IconName then
                local IconId = GetIcon(Info.IconName)
                if IconId then
                    New("ImageLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        Image = IconId,
                        ImageColor3 = "AccentColor",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(22, 22),
                        Parent = GroupboxTop,
                    })
                    TextsFrame.Position = UDim2.fromOffset(24, 0)
                    TextsFrame.Size = UDim2.new(1, -24 - RightInset, 0, 0)
                end
            end

            local GroupboxLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Info.Name,
                TextColor3 = "FontColor",
                TextSize = 15,
                FontFace = Library.Scheme.Font,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TextsFrame,
            })
            New("UIPadding", { PaddingBottom = UDim.new(0, 1), Parent = GroupboxLabel })

            if Info.Description then
                New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Description,
                    TextColor3 = "FontColor",
                    TextSize = 14,
                    TextTransparency = 0.5,
                    FontFace = Library.Scheme.Font,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextsFrame,
                })
            end

            local CollapseButton = nil
            local Collapsed = Info.Collapsed

            if not Info.DisableCollapsing then
                CollapseButton = New("ImageButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://10709790948",
                    ImageColor3 = "FontColor",
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromOffset(22, 22),
                    Parent = GroupboxTop,
                })

                if Collapsed then
                    CollapseButton.Rotation = -90
                end
            end

            local GroupboxLine = New("Frame", {
                BackgroundColor3 = "OutlineColor",
                BorderSizePixel = 0,
                LayoutOrder = 1,
                Size = UDim2.new(1, 0, 0, 1),
                Parent = GroupboxHolder,
            })

            local GroupboxContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.fromScale(0, 0),
                LayoutOrder = 2,
                ScrollBarThickness = 0,
                Size = UDim2.fromScale(1, 0),
                Visible = not Info.Collapsed,
                Parent = GroupboxHolder,
            })
            New("UIListLayout", { Padding = UDim.new(0, 8), Parent = GroupboxContainer })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = GroupboxContainer,
            })

            if CollapseButton then
                CollapseButton.MouseButton1Click:Connect(function()
                    Collapsed = not Collapsed
                    TweenService:Create(CollapseButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = Collapsed and -90 or 0,
                    }):Play()
                    GroupboxContainer.Visible = not Collapsed
                end)
            end

            local Group = {
                Name = Info.Name,
                Container = GroupboxContainer,
                Frame = GroupboxHolder,
                BoxHolder = BoxHolder,
            }

            function Group:Resize() end

            function Group:SetVisible(Visible)
                BoxHolder.Visible = Visible
            end

            function Group:Show()
                BoxHolder.Visible = true
            end

            function Group:Hide()
                BoxHolder.Visible = false
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
                    Size = UDim2.new(1, 0, 0, 18),
                    Visible = ToggleInfo.Visible,
                    Parent = GroupboxContainer,
                })

                local Button = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Holder,
                })

                local ToggleLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -46, 1, 0),
                    Text = ToggleInfo.Text,
                    TextColor3 = ToggleInfo.Risky and "RedColor" or "FontColor",
                    TextSize = 14,
                    FontFace = Library.Scheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Button,
                })

                local Switch = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = "MainColor",
                    ClipsDescendants = true,
                    Position = UDim2.fromScale(1, 0),
                    Size = UDim2.fromOffset(32, 18),
                    Parent = Button,
                })
                AddCorner(Switch, 9)
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingTop = UDim.new(0, 2),
                    Parent = Switch,
                })
                local SwitchStroke = AddStroke(Switch)

                local Ball = New("Frame", {
                    BackgroundColor3 = "FontColor",
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    Parent = Switch,
                })
                AddCorner(Ball, 9)

                local ToggleObj = {
                    Value = ToggleInfo.Default,
                    Index = Idx,
                    Text = ToggleInfo.Text,
                    Holder = Holder,
                    Disabled = ToggleInfo.Disabled,
                    Visible = ToggleInfo.Visible,
                }

                function ToggleObj:SetValue(Value)
                    ToggleObj.Value = Value
                    local TargetPos = Value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    TweenService:Create(Ball, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = TargetPos,
                    }):Play()
                    local TargetColor = Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
                    TweenService:Create(Switch, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = TargetColor,
                    }):Play()
                    ToggleInfo.Callback(Value)
                    ToggleInfo.Changed(Value)
                end

                function ToggleObj:SetDisabled(Disabled)
                    ToggleObj.Disabled = Disabled
                end

                function ToggleObj:SetVisible(Visible)
                    ToggleObj.Visible = Visible
                    Holder.Visible = Visible
                end

                function ToggleObj:SetText(Text)
                    ToggleObj.Text = Text
                    ToggleLabel.Text = Text
                end

                Button.MouseButton1Click:Connect(function()
                    if not ToggleObj.Disabled then
                        ToggleObj:SetValue(not ToggleObj.Value)
                    end
                end)

                Toggles[Idx] = ToggleObj
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

                local Holder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Visible = ButtonInfo.Visible,
                    Parent = GroupboxContainer,
                })

                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDim.new(0, 9),
                    Parent = Holder,
                })

                local Base = New("TextButton", {
                    Active = not ButtonInfo.Disabled,
                    BackgroundColor3 = ButtonInfo.Disabled and "BackgroundColor" or "MainColor",
                    Size = UDim2.fromScale(1, 1),
                    Text = ButtonInfo.Text,
                    TextColor3 = ButtonInfo.Risky and "RedColor" or "FontColor",
                    TextSize = 14,
                    FontFace = Library.Scheme.Font,
                    TextTransparency = 0.4,
                    Parent = Holder,
                })
                AddCorner(Base, CR / 2)
                AddStroke(Base)

                Base.MouseEnter:Connect(function()
                    if not ButtonInfo.Disabled then
                        TweenService:Create(Base, TweenInfo.new(0.15), { TextTransparency = 0 }):Play()
                    end
                end)
                Base.MouseLeave:Connect(function()
                    if not ButtonInfo.Disabled then
                        TweenService:Create(Base, TweenInfo.new(0.15), { TextTransparency = 0.4 }):Play()
                    end
                end)

                if not ButtonInfo.Disabled then
                    Base.MouseButton1Click:Connect(function()
                        ButtonInfo.Func()
                    end)
                end

                local BtnObj = {
                    Text = ButtonInfo.Text,
                    Holder = Holder,
                    Base = Base,
                }

                function BtnObj:SetText(Text)
                    Base.Text = Text
                end

                return BtnObj
            end

            function Group:AddLabel(Text)
                local Label = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Text = Text,
                    TextColor3 = "FontColor",
                    TextSize = 14,
                    FontFace = Library.Scheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = GroupboxContainer,
                })

                local LabelObj = { Text = Text, Holder = Label }
                function LabelObj:SetText(NewText)
                    Label.Text = NewText
                end
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
                    Size = UDim2.new(1, 0, 0, 33),
                    Visible = SliderInfo.Visible,
                    Parent = GroupboxContainer,
                })

                local SliderLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Text = SliderInfo.Text,
                    TextColor3 = "FontColor",
                    TextSize = 14,
                    FontFace = Library.Scheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Holder,
                })

                local Bar = New("TextButton", {
                    Active = not SliderInfo.Disabled,
                    AnchorPoint = Vector2.new(0, 1),
                    AutoButtonColor = false,
                    BackgroundColor3 = "MainColor",
                    ClipsDescendants = true,
                    Position = UDim2.fromScale(0, 1),
                    Size = UDim2.new(1, 0, 0, 15),
                    Text = "",
                    Parent = Holder,
                })
                AddCorner(Bar, CR / 2)
                local BarStroke = AddStroke(Bar)

                local DisplayLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "",
                    TextColor3 = "FontColor",
                    TextSize = 14,
                    FontFace = Library.Scheme.Font,
                    ZIndex = Bar.ZIndex + 2,
                    Parent = Bar,
                })

                local Fill = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    Size = UDim2.fromScale(0.5, 1),
                    ZIndex = Bar.ZIndex + 1,
                    Parent = Bar,
                })

                local SliderObj = {
                    Value = SliderInfo.Default,
                    Index = Idx,
                    Text = SliderInfo.Text,
                    Holder = Holder,
                }

                function SliderObj:SetValue(Value)
                    Value = math.clamp(Value, SliderInfo.Min, SliderInfo.Max)
                    Value = Round(Value, SliderInfo.Rounding)
                    SliderObj.Value = Value
                    local Percent = (Value - SliderInfo.Min) / (SliderInfo.Max - SliderInfo.Min)
                    TweenService:Create(Fill, TweenInfo.new(0.1), { Size = UDim2.fromScale(Percent, 1) }):Play()
                    DisplayLabel.Text = SliderInfo.Prefix .. tostring(Value) .. SliderInfo.Suffix
                    SliderInfo.Callback(Value)
                    SliderInfo.Changed(Value)
                end

                function SliderObj:SetMin(Value) SliderInfo.Min = Value end
                function SliderObj:SetMax(Value) SliderInfo.Max = Value end
                function SliderObj:SetText(Text) SliderLabel.Text = Text end

                local DraggingBar = false
                local HoveringBar = false
                local function UpdateSlider(Input)
                    local Scale = math.clamp(
                        (Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1
                    )
                    local Value = SliderInfo.Min + (Scale * (SliderInfo.Max - SliderInfo.Min))
                    SliderObj:SetValue(Value)
                end

                Bar.InputBegan:Connect(function(Input)
                    if IsMouseInput(Input) and not SliderObj.Disabled then
                        DraggingBar = true
                        UpdateSlider(Input)
                        BarStroke.Color = Library.Scheme.AccentColor
                    end
                end)

                Bar.MouseEnter:Connect(function()
                    HoveringBar = true
                    if not DraggingBar and not SliderObj.Disabled then
                        BarStroke.Color = Library.Scheme.AccentColor
                    end
                end)

                Bar.MouseLeave:Connect(function()
                    HoveringBar = false
                    if not DraggingBar then
                        BarStroke.Color = Library.Scheme.OutlineColor
                    end
                end)

                Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
                    if DraggingBar and IsMovementInput(Input) then
                        UpdateSlider(Input)
                    end
                end))

                Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
                    if IsMouseInput(Input) and DraggingBar then
                        DraggingBar = false
                        if HoveringBar then
                            BarStroke.Color = Library.Scheme.AccentColor
                        else
                            BarStroke.Color = Library.Scheme.OutlineColor
                        end
                    end
                end))

                Options[Idx] = SliderObj
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
                    Size = UDim2.new(1, 0, 0, 39),
                    Visible = InputInfo.Visible,
                    Parent = GroupboxContainer,
                })

                local InputLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Text = InputInfo.Text,
                    TextColor3 = "FontColor",
                    TextSize = 14,
                    FontFace = Library.Scheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Holder,
                })

                local Box = New("TextBox", {
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundColor3 = "MainColor",
                    ClearTextOnFocus = not InputInfo.Disabled and InputInfo.ClearTextOnFocus,
                    PlaceholderText = InputInfo.Placeholder,
                    Position = UDim2.fromScale(0, 1),
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = InputInfo.Default,
                    TextEditable = not InputInfo.Disabled,
                    TextColor3 = "FontColor",
                    TextSize = 14,
                    TextScaled = true,
                    FontFace = Library.Scheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Holder,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingTop = UDim.new(0, 4),
                    Parent = Box,
                })
                local BoxStroke = AddStroke(Box)
                AddCorner(Box, CR / 2)

                local InputObj = {
                    Value = InputInfo.Default,
                    Index = Idx,
                    Text = InputInfo.Text,
                    Holder = Holder,
                }

                function InputObj:SetValue(Value)
                    InputObj.Value = Value
                    Box.Text = Value
                    InputInfo.Callback(Value)
                    InputInfo.Changed(Value)
                end

                function InputObj:SetText(Text)
                    InputLabel.Text = Text
                end

                Box.Focused:Connect(function()
                    BoxStroke.Color = Library.Scheme.AccentColor
                end)

                Box.FocusLost:Connect(function(EnterPressed)
                    BoxStroke.Color = Library.Scheme.OutlineColor
                    if InputInfo.Finished then
                        if EnterPressed then InputObj:SetValue(Box.Text) end
                    else
                        InputObj:SetValue(Box.Text)
                    end
                end)

                Options[Idx] = InputObj
                return InputObj
            end

            function Group:AddDropdown(Idx, DropdownInfo)
                DropdownInfo = Validate(DropdownInfo or {}, {
                    Text = nil,
                    Values = {},
                    Value = nil,
                    Callback = function() end,
                    Changed = function() end,
                    Disabled = false,
                    Visible = true,
                    MaxVisibleItems = 8,
                })

                local HasText = DropdownInfo.Text ~= nil
                local Holder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, HasText and 39 or 21),
                    Visible = DropdownInfo.Visible,
                    Parent = GroupboxContainer,
                })

                local DropLabel = nil
                if HasText then
                    DropLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 14),
                        Text = DropdownInfo.Text,
                        TextColor3 = "FontColor",
                        TextSize = 14,
                        FontFace = Library.Scheme.Font,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 3,
                        Parent = Holder,
                    })
                end

                local DisplayContainer = New("TextButton", {
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundColor3 = "MainColor",
                    Position = UDim2.fromScale(0, 1),
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = "",
                    TextTransparency = 1,
                    ZIndex = 2,
                    Parent = Holder,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 4),
                    Parent = DisplayContainer,
                })
                local DisplayStroke = AddStroke(DisplayContainer)
                AddCorner(DisplayContainer, CR / 2)

                local DisplayButton = New("TextButton", {
                    Active = not DropdownInfo.Disabled,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = "---",
                    TextColor3 = "FontColor",
                    TextSize = 14,
                    FontFace = Library.Scheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = DisplayContainer,
                })

                local ArrowImage = New("ImageLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://10709790948",
                    ImageColor3 = "FontColor",
                    ImageTransparency = 0.5,
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromOffset(16, 16),
                    ZIndex = 2,
                    Parent = DisplayContainer,
                })

                local DropList = New("ScrollingFrame", {
                    BackgroundColor3 = "MainColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 23),
                    Size = UDim2.new(1, 0, 0, math.min(#DropdownInfo.Values * 21 + 6, DropdownInfo.MaxVisibleItems * 21 + 6)),
                    CanvasSize = UDim2.fromScale(0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = "AccentColor",
                    Visible = false,
                    ZIndex = 20,
                    Parent = DisplayContainer,
                })
                AddCorner(DropList, CR / 2)
                AddStroke(DropList)
                New("UIListLayout", { Padding = UDim.new(0, 2), Parent = DropList })
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 3),
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 3),
                    PaddingRight = UDim.new(0, 3),
                    Parent = DropList,
                })

                local DropObj = {
                    Value = DropdownInfo.Value,
                    Index = Idx,
                    Text = DropdownInfo.Text,
                    Holder = Holder,
                    Open = false,
                }

                for _, Value in ipairs(DropdownInfo.Values) do
                    local Item = New("TextButton", {
                        BackgroundColor3 = "BackgroundColor",
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 21),
                        Text = "",
                        ZIndex = 21,
                        Parent = DropList,
                    })
                    AddCorner(Item, 0)

                    local ItemLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 7, 0, 0),
                        Size = UDim2.new(1, -14, 1, 0),
                        Text = tostring(Value),
                        TextColor3 = "FontColor",
                        TextSize = 14,
                        FontFace = Library.Scheme.Font,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 22,
                        Parent = Item,
                    })

                    Item.MouseEnter:Connect(function()
                        TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundColor3 = Library.Scheme.AccentColor }):Play()
                        ItemLabel.TextColor3 = Library.Scheme.BackgroundColor
                    end)
                    Item.MouseLeave:Connect(function()
                        local IsSelected = DropObj.Value == Value
                        TweenService:Create(Item, TweenInfo.new(0.1), {
                            BackgroundColor3 = IsSelected and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor,
                        }):Play()
                        ItemLabel.TextColor3 = IsSelected and Library.Scheme.BackgroundColor or Library.Scheme.FontColor
                    end)

                    Item.MouseButton1Click:Connect(function()
                        DropObj:SetValue(Value)
                        DropList.Visible = false
                        DropObj.Open = false
                        TweenService:Create(ArrowImage, TweenInfo.new(0.15), { Rotation = 0 }):Play()
                    end)
                end

                function DropObj:SetValue(Value)
                    DropObj.Value = Value
                    DisplayButton.Text = Value and tostring(Value) or "---"
                    for _, Item in ipairs(DropList:GetChildren()) do
                        if Item:IsA("TextButton") then
                            local Label = Item:FindFirstChildOfClass("TextLabel")
                            local ItemVal = Label and Label.Text
                            if ItemVal == tostring(Value) then
                                TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundColor3 = Library.Scheme.AccentColor }):Play()
                                if Label then Label.TextColor3 = Library.Scheme.BackgroundColor end
                            else
                                TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundColor3 = Library.Scheme.BackgroundColor }):Play()
                                if Label then Label.TextColor3 = Library.Scheme.FontColor end
                            end
                        end
                    end
                    DropdownInfo.Callback(Value)
                    DropdownInfo.Changed(Value)
                end

                function DropObj:SetValues(Values)
                    DropdownInfo.Values = Values
                    for _, Item in ipairs(DropList:GetChildren()) do
                        if Item:IsA("TextButton") then Item:Destroy() end
                    end
                    for _, Value in ipairs(Values) do
                        local Item = New("TextButton", {
                            BackgroundColor3 = "BackgroundColor",
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 21),
                            Text = "",
                            ZIndex = 21,
                            Parent = DropList,
                        })
                        AddCorner(Item, 0)
                        local ItemLabel = New("TextLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 7, 0, 0),
                            Size = UDim2.new(1, -14, 1, 0),
                            Text = tostring(Value),
                            TextColor3 = "FontColor",
                            TextSize = 14,
                            FontFace = Library.Scheme.Font,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 22,
                            Parent = Item,
                        })
                        Item.MouseEnter:Connect(function()
                            TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundColor3 = Library.Scheme.AccentColor }):Play()
                            ItemLabel.TextColor3 = Library.Scheme.BackgroundColor
                        end)
                        Item.MouseLeave:Connect(function()
                            local IsSel = DropObj.Value == Value
                            TweenService:Create(Item, TweenInfo.new(0.1), {
                                BackgroundColor3 = IsSel and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor,
                            }):Play()
                            ItemLabel.TextColor3 = IsSel and Library.Scheme.BackgroundColor or Library.Scheme.FontColor
                        end)
                        Item.MouseButton1Click:Connect(function()
                            DropObj:SetValue(Value)
                            DropList.Visible = false
                            DropObj.Open = false
                            TweenService:Create(ArrowImage, TweenInfo.new(0.15), { Rotation = 0 }):Play()
                        end)
                    end
                end

                function DropObj:SetText(Text)
                    if DropLabel then DropLabel.Text = Text end
                end

                DisplayButton.MouseButton1Click:Connect(function()
                    if DropdownInfo.Disabled then return end
                    DropObj.Open = not DropObj.Open
                    DropList.Visible = DropObj.Open
                    TweenService:Create(ArrowImage, TweenInfo.new(0.15), {
                        Rotation = DropObj.Open and 180 or 0,
                    }):Play()
                end)

                UserInputService.InputBegan:Connect(function(Input, GP)
                    if GP then return end
                    if DropObj.Open and IsMouseInput(Input) then
                        local MousePos = UserInputService:GetMouseLocation()
                        local BA = DisplayContainer.AbsolutePosition
                        local BS = DisplayContainer.AbsoluteSize
                        local LA = DropList.AbsolutePosition
                        local LS = DropList.AbsoluteSize
                        local OverBtn = MousePos.X >= BA.X and MousePos.X <= BA.X + BS.X and MousePos.Y >= BA.Y and MousePos.Y <= BA.Y + BS.Y
                        local OverList = MousePos.X >= LA.X and MousePos.X <= LA.X + LS.X and MousePos.Y >= LA.Y and MousePos.Y <= LA.Y + LS.Y
                        if not OverBtn and not OverList then
                            DropObj.Open = false
                            DropList.Visible = false
                            TweenService:Create(ArrowImage, TweenInfo.new(0.15), { Rotation = 0 }):Play()
                        end
                    end
                end)

                Options[Idx] = DropObj
                if DropdownInfo.Value then
                    DropObj:SetValue(DropdownInfo.Value)
                end
                return DropObj
            end

            function Group:AddDivider(Text)
                local DivHolder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, Text and 24 or 10),
                    Parent = GroupboxContainer,
                })

                New("Frame", {
                    BackgroundColor3 = "OutlineColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, Text and 0.5 or 0, Text and 8 or 4),
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = DivHolder,
                })

                if Text then
                    local DivText = New("TextLabel", {
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.new(0, 0, 0, 16),
                        Text = Text,
                        TextColor3 = "FontColor",
                        TextSize = 14,
                        TextTransparency = 0.5,
                        FontFace = Library.Scheme.Font,
                        BackgroundColor3 = "MainColor",
                        AutomaticSize = Enum.AutomaticSize.X,
                        Parent = DivHolder,
                    })
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        Parent = DivText,
                    })
                end
            end

            table.insert(Tab.Groupboxes, Group)
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

    return Window
end

Library.Notify = Library.Notify
Library.Toggle = Library.Toggle

return Library
