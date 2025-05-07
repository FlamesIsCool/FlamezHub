local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Hide or Die - SwirlHub",
    SubTitle = "By Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local humanoid = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")

local infJumpConn, noclipConn

lp.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
end)

Tabs.Main:AddButton({
    Title = "Invisible",
    Description = "Makes you invisible by setting morph rotate to math.huge.",
    Callback = function()
        local args = { math.huge }
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("morph"):WaitForChild("rotate"):FireServer(unpack(args))
        end)
        if success then
            Fluent:Notify({
                Title = "Invisible",
                Content = "Invisible triggered with math.huge!",
                Duration = 5
            })
        else
            warn("Failed to fire invisible:", err)
            Fluent:Notify({
                Title = "Error",
                Content = "Could not fire server event.",
                Duration = 5
            })
        end
    end
})

local espEnabled = false
local espConnections = {}
local espBoxes = {}

local function createESPBox(player)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local box = Drawing.new("Square")
    box.Visible = true
    box.Color = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
    box.Thickness = 1
    box.Filled = false

    espBoxes[player] = box

    espConnections[player] = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local hrpPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local size = Vector2.new(50, 100) -- box size
                box.Size = size
                box.Position = Vector2.new(hrpPos.X - size.X/2, hrpPos.Y - size.Y/2)
                box.Color = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end)
end

local function clearESP()
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    for _, box in pairs(espBoxes) do
        box:Remove()
    end
    espConnections = {}
    espBoxes = {}
end

Tabs.Main:AddToggle("ESP", {
    Title = "ESP",
    Default = false
}):OnChanged(function(state)
    espEnabled = state
    if espEnabled then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                createESPBox(player)
            end
        end

        game.Players.PlayerAdded:Connect(function(player)
            if espEnabled then
                player.CharacterAdded:Connect(function()
                    task.wait(1)
                    createESPBox(player)
                end)
            end
        end)

        game.Players.PlayerRemoving:Connect(function(player)
            if espBoxes[player] then
                espBoxes[player]:Remove()
                espBoxes[player] = nil
            end
            if espConnections[player] then
                espConnections[player]:Disconnect()
                espConnections[player] = nil
            end
        end)

    else
        clearESP()
    end
end)

local autoCollectEnabled = false
local autoCollectConnection
local autoCollectCoins = {}

local function startAutoCollect()
    local TweenService = game:GetService("TweenService")
    local Trash = workspace:WaitForChild("Trash")
    local CoinsFolder = Trash:FindFirstChild("Coins")

    local function handleCoin(coin)
        if not coin:IsA("Model") or not coin.PrimaryPart then return end
        local tween = TweenService:Create(coin.PrimaryPart, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = Vector3.new(0, 0, 0)})
        tween:Play()

        autoCollectCoins[coin] = RunService.Heartbeat:Connect(function()
            if not coin.Parent or not coin.PrimaryPart then return end
            coin.PrimaryPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        end)

        coin.Destroying:Connect(function()
            if autoCollectCoins[coin] then
                autoCollectCoins[coin]:Disconnect()
                autoCollectCoins[coin] = nil
            end
        end)
    end

    if CoinsFolder then
        for _, coin in ipairs(CoinsFolder:GetChildren()) do
            handleCoin(coin)
        end
        autoCollectConnection = CoinsFolder.ChildAdded:Connect(handleCoin)
    end
end

local function stopAutoCollect()
    if autoCollectConnection then
        autoCollectConnection:Disconnect()
        autoCollectConnection = nil
    end
    for _, conn in pairs(autoCollectCoins) do
        conn:Disconnect()
    end
    autoCollectCoins = {}
end

Tabs.Main:AddToggle("AutoCollect", {
    Title = "Auto Collect Coins",
    Default = false
}):OnChanged(function(state)
    autoCollectEnabled = state
    if autoCollectEnabled then
        startAutoCollect()
        Fluent:Notify({Title = "Auto Collect", Content = "Started auto collecting coins.", Duration = 4})
    else
        stopAutoCollect()
        Fluent:Notify({Title = "Auto Collect", Content = "Stopped auto collecting coins.", Duration = 4})
    end
end)

local WalkSpeedSlider = Tabs.Main:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Description = "Set your movement speed.",
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 0
})
WalkSpeedSlider:OnChanged(function(val)
    if humanoid then
        humanoid.WalkSpeed = val
    end
end)

local JumpPowerSlider = Tabs.Main:AddSlider("JumpPower", {
    Title = "JumpPower",
    Description = "How high you jump.",
    Min = 50,
    Max = 300,
    Default = 50,
    Rounding = 0
})
JumpPowerSlider:OnChanged(function(val)
    if humanoid then
        humanoid.JumpPower = val
    end
end)

local GravitySlider = Tabs.Main:AddSlider("Gravity", {
    Title = "Gravity",
    Description = "Set the world gravity.",
    Min = 0,
    Max = 196.2,
    Default = workspace.Gravity,
    Rounding = 1
})
GravitySlider:OnChanged(function(val)
    workspace.Gravity = val
end)

local InfJumpToggle = Tabs.Main:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false
})
InfJumpToggle:OnChanged(function(state)
    if state then
        infJumpConn = UIS.JumpRequest:Connect(function()
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConn then
            infJumpConn:Disconnect()
            infJumpConn = nil
        end
    end
end)

local NoclipToggle = Tabs.Main:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false
})
NoclipToggle:OnChanged(function(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if lp.Character then
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)


