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

local FlightConnection = nil
local FlightAnim = nil
MoveGroup:AddToggle("Flight", {
    Text = "Flight",
    Default = false,
    Callback = function(Value)
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        if Value then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.zero
            bv.P = 1e4
            bv.Name = "KoraxFlight"
            bv.Parent = hrp

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 5e4
            bg.D = 500
            bg.Name = "KoraxFlightGyro"
            bg.Parent = hrp

            humanoid.PlatformStand = true
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)

            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {character}

            local lastVelocity = Vector3.zero

            FlightConnection = RunService.RenderStepped:Connect(function(dt)
                local bv = hrp:FindFirstChild("KoraxFlight")
                local bg = hrp:FindFirstChild("KoraxFlightGyro")
                if not bv or not bg or not hrp.Parent then return end

                local speed = Toggles.FlightSpeed and Toggles.FlightSpeed.Value or 50
                local cam = workspace.CurrentCamera
                local cf = cam.CFrame

                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

                if dir.Magnitude > 0 then
                    dir = dir.Unit
                end

                local targetVelocity = dir * speed
                local smoothSpeed = 10 * dt
                lastVelocity = lastVelocity:Lerp(targetVelocity, math.clamp(smoothSpeed, 0, 1))
                bv.Velocity = lastVelocity

                local targetCF = cf * CFrame.Angles(0, 0, 0)
                local currentCF = hrp.CFrame
                local targetLook = targetCF.LookVector
                local targetRight = targetCF.RightVector
                local targetUp = targetCF.UpVector

                if dir.Magnitude > 0 then
                    local moveCF = CFrame.lookAt(Vector3.zero, dir)
                    local blendedCF = CFrame.fromMatrix(
                        Vector3.zero,
                        currentCF.RightVector:Lerp(moveCF.RightVector, 6 * dt),
                        currentCF.UpVector:Lerp(moveCF.UpVector, 6 * dt),
                        currentCF.LookVector:Lerp(moveCF.LookVector, 6 * dt)
                    )
                    bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + blendedCF.LookVector, blendedCF.UpVector)
                else
                    bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + currentCF.LookVector, Vector3.new(0, 1, 0))
                end
            end)
        else
            if FlightConnection then
                FlightConnection:Disconnect()
                FlightConnection = nil
            end

            if hrp then
                local bv = hrp:FindFirstChild("KoraxFlight")
                if bv then bv:Destroy() end
                local bg = hrp:FindFirstChild("KoraxFlightGyro")
                if bg then bg:Destroy() end
            end

            if humanoid then
                humanoid.PlatformStand = false
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
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
            if humanoid then
                humanoid.WalkSpeed = Value
            end
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
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if InfJumpConnection then
                InfJumpConnection:Disconnect()
                InfJumpConnection = nil
            end
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
        if Value then
            AddHighlights()
        else
            RemoveHighlights()
        end
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
