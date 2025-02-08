local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Stud Long Jumps Obby " .. Fluent.Version,
    SubTitle = "by Flames",
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

local Options = Fluent.Options

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local autoActive = false

local autoLoopThread = nil

local function completeCheckpoints()
    local checkpointsFolder = workspace:WaitForChild("Checkpoints")
    local checkpoints = {}

    for _, child in ipairs(checkpointsFolder:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(checkpoints, child)
        end
    end

    table.sort(checkpoints, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    for _, checkpoint in ipairs(checkpoints) do
        if not autoActive then
            break  
        end
        hrp.CFrame = checkpoint.CFrame
        wait(0)  
    end
end

local function autoRebirth()
    local rebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
    print("Auto rebirth: Firing RebirthEvent")
    rebirthEvent:FireServer()
end

local AutoToggle = Tabs.Main:AddToggle("AutoCPR", { Title = "Auto Checkpoints & Rebirth", Default = false })

AutoToggle:OnChanged(function()
    autoActive = Options.AutoCPR.Value
    if autoActive then
        print("Auto Checkpoints & Rebirth enabled")

        if not autoLoopThread then
            autoLoopThread = spawn(function()
                while autoActive do
                    completeCheckpoints()
                    if not autoActive then break end  
                    autoRebirth()
                    wait(0)  
                end
                autoLoopThread = nil
                print("Auto Checkpoints & Rebirth loop stopped")
            end)
        end
    else
        print("Auto Checkpoints & Rebirth disabled")
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local WalkspeedSlider = Tabs.Main:AddSlider("Walkspeed", {
    Title = "Walkspeed",
    Description = "Adjust your player's walkspeed.",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end
})

local JumpPowerSlider = Tabs.Main:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjust your player's jump power.",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end
    end
})

local GravitySlider = Tabs.Main:AddSlider("Gravity", {
    Title = "Gravity",
    Description = "Adjust the game gravity.",
    Default = workspace.Gravity,
    Min = 0,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

local FOVSlider = Tabs.Main:AddSlider("FOV", {
    Title = "Field of View",
    Description = "Adjust the camera's field of view.",
    Default = Camera.FieldOfView,
    Min = 20,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        Camera.FieldOfView = Value
    end
})

local InfJumpToggle = Tabs.Main:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false,
    Description = "Enable infinite jump."
})

local InfJumpEnabled = false
local InfJumpConnection

InfJumpToggle:OnChanged(function()
    InfJumpEnabled = InfJumpToggle.Value
    if InfJumpEnabled then
        InfJumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if InfJumpConnection then
            InfJumpConnection:Disconnect()
        end
    end
end)

local NoclipToggle = Tabs.Main:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Description = "Enable noclip (walk through walls)."
})

local NoclipEnabled = false
NoclipToggle:OnChanged(function()
    NoclipEnabled = NoclipToggle.Value
end)

RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local FlyToggle = Tabs.Main:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Description = "Enable flying mode."
})

local FlySpeedSlider = Tabs.Main:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust your fly speed.",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)

    end
})

local FlyEnabled = false
local FlyBodyVelocity, FlyBodyGyro
local FlyConnection

FlyToggle:OnChanged(function()
    FlyEnabled = FlyToggle.Value
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if FlyEnabled then

        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.Parent = hrp

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp

        FlyConnection = RunService.RenderStepped:Connect(function()
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            FlyBodyVelocity.Velocity = direction * FlySpeedSlider.Value
            if direction.Magnitude > 0 then
                FlyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
            else
                FlyBodyGyro.CFrame = hrp.CFrame
            end
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
        end
        if FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
        end
        if FlyBodyGyro then
            FlyBodyGyro:Destroy()
        end
    end
end)

local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local TeleportDropdown = Tabs.Main:AddDropdown("TeleportToPlayer", {
    Title = "Teleport to Player",
    Description = "Select a player to teleport to their position.",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
           and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame =
                target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Refresh Player List",
    Description = "Update the teleport dropdown with current players.",
    Callback = function()
        TeleportDropdown:SetValues(getPlayerNames())
    end
})

Tabs.Main:AddButton({
    Title = "Reset Player",
    Description = "Reset WalkSpeed and JumpPower to default values.",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
            WalkspeedSlider:SetValue(16)
            JumpPowerSlider:SetValue(50)
        end
    end
})

Fluent:Notify({
    Title = "Fluent",
    Content = "Auto Checkpoints & Rebirth script has been loaded.",
    Duration = 8
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/StudLongJumpsObby")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
