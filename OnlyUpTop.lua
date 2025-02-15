local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Only Up Top! " .. Fluent.Version,
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

    Tabs.Main:AddParagraph({
        Title = "NOTE",
        Content = "Auto Win may take a while before it actually starts."
    })

local autoWinEnabled = false
local autoWinLoop

local AutoWinToggle = Tabs.Main:AddToggle("AutoWinToggle", {
    Title = "Auto Win",
    Default = false
})

AutoWinToggle:OnChanged(function(state)
    autoWinEnabled = state
    if autoWinEnabled then
        Fluent:Notify({ Title = "Auto Win", Content = "Auto Win Enabled!", Duration = 3 })
        autoWinLoop = task.spawn(function()
            while autoWinEnabled do
                local TeleportPart = workspace:FindFirstChild("TeleportPart1")
                if TeleportPart then
                    local player = game.Players.LocalPlayer
                    local character = player and player.Character
                    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

                    if humanoidRootPart then
                        for _, obj in ipairs(TeleportPart:GetChildren()) do
                            if obj:IsA("TouchTransmitter") then
                                firetouchinterest(humanoidRootPart, TeleportPart, 0)
                                task.wait(0)
                                firetouchinterest(humanoidRootPart, TeleportPart, 1)
                            end
                        end
                    end
                end
                task.wait(0)
            end
        end)
    else
        Fluent:Notify({ Title = "Auto Win", Content = "Auto Win Disabled!", Duration = 3 })
        if autoWinLoop then task.cancel(autoWinLoop) end
    end
end)

Options.AutoWinToggle:SetValue(false)

local JumpPowerSlider = Tabs.Main:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Value
        end
    end
})

JumpPowerSlider:SetValue(50)

local GravitySlider = Tabs.Main:AddSlider("Gravity", {
    Title = "Gravity",
    Default = 196.2,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        game.Workspace.Gravity = Value
    end
})

GravitySlider:SetValue(196.2)

local infJumpEnabled = false

local InfJumpToggle = Tabs.Main:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Default = false
})

InfJumpToggle:OnChanged(function(state)
    infJumpEnabled = state
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local noclipEnabled = false
local noclipLoop

local NoClipToggle = Tabs.Main:AddToggle("NoClipToggle", {
    Title = "NoClip",
    Default = false
})

NoClipToggle:OnChanged(function(state)
    noclipEnabled = state
    if noclipEnabled then
        noclipLoop = task.spawn(function()
            while noclipEnabled do
                local player = game.Players.LocalPlayer
                local character = player.Character

                if character then
                    for _, v in pairs(character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
                task.wait()
            end
        end)
    else
        if noclipLoop then task.cancel(noclipLoop) end
    end
end)

local flyEnabled = false
local flySpeed = 50
local flying = false
local velocity, flightLoop

local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false
})

FlyToggle:OnChanged(function(state)
    flyEnabled = state
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if flyEnabled and humanoidRootPart then
        Fluent:Notify({ Title = "Fly", Content = "Fly Enabled!", Duration = 3 })

        flying = true
        velocity = Instance.new("BodyVelocity", humanoidRootPart)
        velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        velocity.Velocity = Vector3.zero

        flightLoop = RunService.RenderStepped:Connect(function()
            if not flying then return end
            local direction = Vector3.zero
            local camera = workspace.CurrentCamera
            local root = humanoidRootPart

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                direction = direction.Unit * flySpeed
            end

            velocity.Velocity = direction
        end)
    else
        Fluent:Notify({ Title = "Fly", Content = "Fly Disabled!", Duration = 3 })
        flying = false
        if velocity then velocity:Destroy() end
        if flightLoop then flightLoop:Disconnect() end
    end
end)

local FlySpeedSlider = Tabs.Main:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        flySpeed = Value
    end
})

FlySpeedSlider:SetValue(50)

InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/onlyuptop")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({ Title = "SwirlHub", Content = "The script has been loaded.", Duration = 8 })
SaveManager:LoadAutoloadConfig()
