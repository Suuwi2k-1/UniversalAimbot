-- UNIVERSAL ROBLOX AIMBOT
-- PC + Mobile

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ================== SETTINGS WITH SAVE ==================
local SettingsFile = "UniversalAimbot_Settings.json"

local DefaultSettings = {
    AimbotEnabled = true,
    TeamCheck = true,
    AimPart = "Head",
    FOVRadius = 250,
    Smoothness = 0.25,
    DrawFOV = true,
    FOVColor = Color3.fromRGB(255, 0, 100)
}

local Settings = {}

local function LoadSettings()
    if isfile(SettingsFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(SettingsFile))
        end)
        if success then
            Settings = data
            if Settings.FOVColor and typeof(Settings.FOVColor) == "table" then
                Settings.FOVColor = Color3.fromRGB(Settings.FOVColor.R, Settings.FOVColor.G, Settings.FOVColor.B)
            end
            return
        end
    end
    Settings = DefaultSettings
    SaveSettings()
end

local function SaveSettings()
    local dataToSave = {
        AimbotEnabled = Settings.AimbotEnabled,
        TeamCheck = Settings.TeamCheck,
        AimPart = Settings.AimPart,
        FOVRadius = Settings.FOVRadius,
        Smoothness = Settings.Smoothness,
        DrawFOV = Settings.DrawFOV,
        FOVColor = {R = Settings.FOVColor.R, G = Settings.FOVColor.G, B = Settings.FOVColor.B}
    }
    pcall(function()
        writefile(SettingsFile, HttpService:JSONEncode(dataToSave))
    end)
end

LoadSettings()

local aimbotEnabled = Settings.AimbotEnabled

-- ================== CREATE GUI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalAimbotGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 550)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(255, 80, 120)
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "UNIVERSAL AIMBOT"
Title.TextColor3 = Color3.fromRGB(255, 80, 120)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    SaveSettings()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0,0,0,0)})
    tween:Play()
    tween.Completed:Connect(function() ScreenGui:Destroy() end)
end)

-- Dragging (PC + Mobile)
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Toggle Function
local function CreateToggle(text, yOffset, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 52)
    btn.Position = UDim2.new(0.04, 0, 0, yOffset)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    btn.Text = default and "[ON] " .. text or "[OFF] " .. text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        default = not default
        local color = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = color}):Play()
        btn.Text = default and "[ON] " .. text or "[OFF] " .. text
        callback(default)
        SaveSettings()
    end)
end

-- Aimbot Toggle
CreateToggle("AIMBOT", 70, Settings.AimbotEnabled, function(state)
    aimbotEnabled = state
    Settings.AimbotEnabled = state
end)

-- Aim Part
local partY = 140
local aimParts = {"Head", "UpperTorso", "HumanoidRootPart"}
local partBtns = {}

for i, part in ipairs(aimParts) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28, 0, 0, 48)
    btn.Position = UDim2.new(0.04 + (i-1)*0.32, 0, 0, partY)
    btn.BackgroundColor3 = (Settings.AimPart == part) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(40, 40, 40)
    btn.Text = part
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Settings.AimPart = part
        for _, b in ipairs(partBtns) do
            b.BackgroundColor3 = (b.Text == part) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(40, 40, 40)
        end
        SaveSettings()
    end)
    table.insert(partBtns, btn)
end

CreateToggle("TEAM CHECK", 210, Settings.TeamCheck, function(state)
    Settings.TeamCheck = state
    SaveSettings()
end)

-- FOV
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.92, 0, 0, 28)
FOVLabel.Position = UDim2.new(0.04, 0, 0, 280)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV SIZE: " .. Settings.FOVRadius
FOVLabel.TextColor3 = Color3.new(1,1,1)
FOVLabel.TextScaled = true
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = MainFrame

local FOVBox = Instance.new("TextBox")
FOVBox.Size = UDim2.new(0.45, 0, 0, 40)
FOVBox.Position = UDim2.new(0.52, 0, 0, 275)
FOVBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FOVBox.Text = tostring(Settings.FOVRadius)
FOVBox.TextColor3 = Color3.new(1,1,1)
FOVBox.TextScaled = true
FOVBox.Font = Enum.Font.Gotham
FOVBox.Parent = MainFrame

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(0, 10)
fovCorner.Parent = FOVBox

FOVBox.FocusLost:Connect(function()
    local num = tonumber(FOVBox.Text)
    if num and num >= 50 and num <= 800 then
        Settings.FOVRadius = num
        FOVLabel.Text = "FOV SIZE: " .. num
        SaveSettings()
    else
        FOVBox.Text = tostring(Settings.FOVRadius)
    end
end)

CreateToggle("DRAW FOV CIRCLE", 330, Settings.DrawFOV, function(state)
    Settings.DrawFOV = state
    SaveSettings()
end)

-- Smoothness
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(0.92, 0, 0, 28)
SmoothLabel.Position = UDim2.new(0.04, 0, 0, 390)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "SMOOTHNESS: " .. Settings.Smoothness
SmoothLabel.TextColor3 = Color3.new(1,1,1)
SmoothLabel.TextScaled = true
SmoothLabel.Font = Enum.Font.Gotham
SmoothLabel.TextXAlignment = Enum.TextXAlignment.Left
SmoothLabel.Parent = MainFrame

local SmoothBox = Instance.new("TextBox")
SmoothBox.Size = UDim2.new(0.45, 0, 0, 40)
SmoothBox.Position = UDim2.new(0.52, 0, 0, 385)
SmoothBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SmoothBox.Text = tostring(Settings.Smoothness)
SmoothBox.TextColor3 = Color3.new(1,1,1)
SmoothBox.TextScaled = true
SmoothBox.Font = Enum.Font.Gotham
SmoothBox.Parent = MainFrame

local smoothCorner = Instance.new("UICorner")
smoothCorner.CornerRadius = UDim.new(0, 10)
smoothCorner.Parent = SmoothBox

SmoothBox.FocusLost:Connect(function()
    local num = tonumber(SmoothBox.Text)
    if num and num >= 0.05 and num <= 1 then
        Settings.Smoothness = num
        SmoothLabel.Text = "SMOOTHNESS: " .. num
        SaveSettings()
    else
        SmoothBox.Text = tostring(Settings.Smoothness)
    end
end)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2.5
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Transparency = 0.65
fovCircle.Color = Settings.FOVColor

-- ================== AIMBOT LOGIC ==================
local function getClosestPlayer()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player \~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local targetPart = player.Character:FindFirstChild(Settings.AimPart) or player.Character:FindFirstChild("Head")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortest and dist <= Settings.FOVRadius then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = Settings.DrawFOV
    if fovCircle.Visible then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Settings.FOVRadius
    end

    if not aimbotEnabled then return end

    local target = getClosestPlayer()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
        if targetPart then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
        end
    end
end)

-- Fade in
MainFrame.Size = UDim2.new(0,0,0,0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 400, 0, 550)}):Play()

print("Universal Aimbot + GUI Loaded! Drag the title bar to move.")
