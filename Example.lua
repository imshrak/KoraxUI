local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imshrak/KoraxUI/master/Library.lua"))()

local Toggles = Library.Toggles or {}

local Window = Library:CreateWindow({
    Title = "Korax UI Example",
    Footer = "v1.0 | RightCtrl to toggle",
    Size = UDim2.fromOffset(500, 400),
    ToggleKeybind = Enum.KeyCode.RightControl,
    AutoShow = true,
})

local Tabs = {
    Movement = Window:AddTab("Movement", "move"),
    Visual = Window:AddTab("Visual", "eye"),
}

-- ==================== MOVEMENT TAB ====================
local MoveGroup = Tabs.Movement:AddGroupbox({
    Side = 1,
    Name = "Movement",
    IconName = "activity",
})

local FLYING = false
local flyKeyDown = nil
local flyKeyUp = nil

MoveGroup:AddToggle("Flight", {
    Text = "Flight",
    Default = false,
    Callback = function(Value)
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        if Value then
            FLYING = true

            local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            local SPEED = 0

            local BG = Instance.new("BodyGyro")
            BG.P = 9e4
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = hrp.CFrame
            BG.Parent = hrp

            local BV = Instance.new("BodyVelocity")
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Parent = hrp

            humanoid.PlatformStand = true

            flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                local speed = Toggles.FlightSpeed and Toggles.FlightSpeed.Value or 50
                local mult = speed / 50
                if input.KeyCode == Enum.KeyCode.W then
                    CONTROL.F = mult
                elseif input.KeyCode == Enum.KeyCode.S then
                    CONTROL.B = -mult
                elseif input.KeyCode == Enum.KeyCode.A then
                    CONTROL.L = -mult
                elseif input.KeyCode == Enum.KeyCode.D then
                    CONTROL.R = mult
                elseif input.KeyCode == Enum.KeyCode.E then
                    CONTROL.Q = mult * 2
                elseif input.KeyCode == Enum.KeyCode.Q then
                    CONTROL.E = -(mult * 2)
                end
            end)

            flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.W then
                    CONTROL.F = 0
                elseif input.KeyCode == Enum.KeyCode.S then
                    CONTROL.B = 0
                elseif input.KeyCode == Enum.KeyCode.A then
                    CONTROL.L = 0
                elseif input.KeyCode == Enum.KeyCode.D then
                    CONTROL.R = 0
                elseif input.KeyCode == Enum.KeyCode.E then
                    CONTROL.Q = 0
                elseif input.KeyCode == Enum.KeyCode.Q then
                    CONTROL.E = 0
                end
            end)

            task.spawn(function()
                repeat task.wait()
                    local camera = workspace.CurrentCamera
                    if not hrp.Parent then break end

                    if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                        SPEED = 50
                    elseif SPEED ~= 0 then
                        SPEED = 0
                    end

                    if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                        BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                        lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                    elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                        BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                    else
                        BV.Velocity = Vector3.new(0, 0, 0)
                    end

                    BG.CFrame = camera.CFrame
                until not FLYING

                CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                SPEED = 0
                BG:Destroy()
                BV:Destroy()
                if humanoid then humanoid.PlatformStand = false end
            end)
        else
            FLYING = false
            if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
            if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
            if humanoid then humanoid.PlatformStand = false end
        end
    end,
})

MoveGroup:AddSlider("FlightSpeed", {
    Text = "Flight Speed",
    Default = 50,
    Min = 10,
    Max = 200,
})

MoveGroup:AddToggle("Speed", {
    Text = "Speed",
    Default = false,
    Callback = function(Value)
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Value and (Toggles.SpeedValue and Toggles.SpeedValue.Value or 16) or 16
        end
    end,
})

MoveGroup:AddSlider("SpeedValue", {
    Text = "Speed Value",
    Default = 16,
    Min = 16,
    Max = 200,
    Callback = function(Value)
        if Toggles.Speed and Toggles.Speed.Value then
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = Value end
        end
    end,
})

local InfJumpConnection = nil
local InfJumpEnabled = false
MoveGroup:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        InfJumpEnabled = Value
        if Value then
            InfJumpConnection = UserInputService.JumpRequest:Connect(function()
                if InfJumpEnabled then
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        else
            if InfJumpConnection then InfJumpConnection:Disconnect() InfJumpConnection = nil end
        end
    end,
})

-- ==================== VISUAL TAB ====================
local VisGroup = Tabs.Visual:AddGroupbox({
    Side = 1,
    Name = "Visuals",
    IconName = "eye",
})

local Highlights = {}
local function AddHighlights()
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character then
            if not Highlights[player] then
                local hl = Instance.new("Highlight")
                hl.FillColor = Library.Scheme.AccentColor
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.Adornee = player.Character
                hl.Parent = player.Character
                Highlights[player] = hl
            end
        end
    end
end

local function RemoveHighlights()
    for player, hl in Highlights do
        if hl then hl:Destroy() end
    end
    Highlights = {}
end

VisGroup:AddToggle("Highlight", {
    Text = "Highlight Players",
    Default = false,
    Callback = function(Value)
        if Value then AddHighlights() else RemoveHighlights() end
    end,
})

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if Toggles.Highlight and Toggles.Highlight.Value then
            task.wait(1)
            AddHighlights()
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if Toggles.Speed and Toggles.Speed.Value then
        humanoid.WalkSpeed = Toggles.SpeedValue and Toggles.SpeedValue.Value or 16
    end
end)

print("KoraxUI Example loaded!")
print("Press RightControl to toggle the menu")
