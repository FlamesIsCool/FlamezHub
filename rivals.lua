local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Rivals " .. Fluent.Version,
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

Tabs.Main:AddParagraph({
    Title = "INFORMATION",
    Content = "Script may take a while to load the other features.\nIf you have any questions, join our Discord at discord.gg/5c9D3VD7se!\nNOTE: USING THE AIMBOT AND AIMING IN CAN GLITCH OUT."
})

local Options = Fluent.Options

local Players = game:FindService("Players") or game:GetService("Players")
if not Players then
    warn("Players service is not available. Aimbot may not work properly.")
end

local LocalPlayer = Players.LocalPlayer

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 100
FOVCircle.Visible = false

local aimbotEnabled = false
local fovSize = 100
local fovColor = Color3.fromRGB(255, 0, 0)
local aimbotKey = Enum.KeyCode.E
local lockedTarget = nil
local isLocked = false
local aimPart = "Head" 

local function GetClosestTargetInFOV()
    if not Players then return nil end
    local closest, minDist = nil, math.huge
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
            local targetPart = player.Character[aimPart]
            local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude

            if onScreen and distance < fovSize and distance < minDist then
                closest = player
                minDist = distance
            end
        end
    end
    return closest
end

local function UpdateFOV()
    FOVCircle.Radius = fovSize
    FOVCircle.Color = fovColor
    FOVCircle.Visible = aimbotEnabled
end

local function MoveMouseToTarget(target)
    if target and target.Character and target.Character:FindFirstChild(aimPart) then
        local targetPart = target.Character[aimPart]
        local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            mousemoverel(
                screenPoint.X - game:GetService("UserInputService"):GetMouseLocation().X, 
                screenPoint.Y - game:GetService("UserInputService"):GetMouseLocation().Y
            )
        end
    end
end

Tabs.Main:AddToggle("AimbotToggle", { Title = "Enable Aimbot", Default = false }):OnChanged(function(Value)
    aimbotEnabled = Value
    UpdateFOV()
    Fluent:Notify({
        Title = "Aimbot",
        Content = Value and "Aimbot Enabled" or "Aimbot Disabled",
        Duration = 4
    })
end)

Tabs.Main:AddSlider("FOVSize", {
    Title = "FOV Circle Size",
    Min = 50,
    Max = 500,
    Default = 100,
    Rounding = 0,
    Callback = function(Value)
        fovSize = Value
        UpdateFOV()
    end
})

Tabs.Main:AddColorpicker("FOVColor", {
    Title = "FOV Circle Color",
    Default = Color3.fromRGB(255, 0, 0)
}):OnChanged(function()
    fovColor = Options.FOVColor.Value
    UpdateFOV()
    Fluent:Notify({
        Title = "FOV Color",
        Content = "FOV Color updated!",
        Duration = 4
    })
end)

Tabs.Main:AddDropdown("AimPartDropdown", {
    Title = "Aim Part",
    Values = {"Head", "HumanoidRootPart"},
    Default = "Head",
}):OnChanged(function(Value)
    aimPart = Value
    Fluent:Notify({
        Title = "Aim Part",
        Content = "Aim Part set to " .. Value,
        Duration = 4
    })
end)

Tabs.Main:AddKeybind("AimbotKeybind", {
    Title = "Aimbot Key",
    Default = "E",
    Mode = "Toggle",
    Callback = function(Value)
        if aimbotEnabled then
            if isLocked then
                isLocked = false
                lockedTarget = nil
                Fluent:Notify({
                    Title = "Aimbot",
                    Content = "Target Unlocked",
                    Duration = 4
                })
            else
                lockedTarget = GetClosestTargetInFOV()
                if lockedTarget then
                    isLocked = true
                    Fluent:Notify({
                        Title = "Aimbot",
                        Content = "Target Locked",
                        Duration = 4
                    })
                else
                    Fluent:Notify({
                        Title = "Aimbot",
                        Content = "No target in FOV!",
                        Duration = 4
                    })
                end
            end
        end
    end,
    ChangedCallback = function(NewKey)
        aimbotKey = NewKey
        Fluent:Notify({
            Title = "Aimbot Key",
            Content = "Keybind changed to " .. tostring(NewKey),
            Duration = 4
        })
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    FOVCircle.Position = mousePos
    if isLocked and lockedTarget then
        MoveMouseToTarget(lockedTarget)
    end
end)

local ESPEnabled = false
local ESPFillColor = Color3.fromRGB(255, 0, 0)          
local ESPOutlineColor = Color3.fromRGB(255, 255, 255)     
local ESPFillTransparency = 0.5
local ESPOutlineTransparency = 0
local ESPAlwaysOnTop = true
local ESPMaxDistance = 1000                             

local ESPObjects = {}  

local function CreateESP(player)
    if not player or player == LocalPlayer or ESPObjects[player] then
        return
    end

    local success, highlight = pcall(function()
        local hl = Instance.new("Highlight")
        hl.FillColor = ESPFillColor
        hl.OutlineColor = ESPOutlineColor
        hl.FillTransparency = ESPFillTransparency
        hl.OutlineTransparency = ESPOutlineTransparency
        hl.DepthMode = ESPAlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        hl.Enabled = ESPEnabled
        hl.Parent = game:GetService("CoreGui")
        return hl
    end)

    if not success then
        warn("Error creating ESP for player: " .. tostring(player.Name))
        return
    end

    ESPObjects[player] = highlight

    local function UpdateCharacter()
        task.wait(0.5)
        if player and player.Character then
            pcall(function() highlight.Adornee = player.Character end)
        end
    end

    local charAddedConn = player.CharacterAdded:Connect(function(character)
        pcall(UpdateCharacter)
    end)

    highlight:GetPropertyChangedSignal("Parent"):Connect(function()
        if not highlight.Parent then
            pcall(function() charAddedConn:Disconnect() end)
        end
    end)

    pcall(UpdateCharacter)
end

local function RemoveESP(player)
    if ESPObjects[player] then
        pcall(function() ESPObjects[player]:Destroy() end)
        ESPObjects[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    pcall(function() CreateESP(player) end)
end

Players.PlayerAdded:Connect(function(player)
    pcall(function() CreateESP(player) end)
end)

Players.PlayerRemoving:Connect(function(player)
    pcall(function() RemoveESP(player) end)
end)

local function UpdateESPProperties()
    for player, highlight in pairs(ESPObjects) do
        if highlight and highlight.Parent then
            pcall(function()
                highlight.FillColor = ESPFillColor
                highlight.OutlineColor = ESPOutlineColor
                highlight.FillTransparency = ESPFillTransparency
                highlight.OutlineTransparency = ESPOutlineTransparency
                highlight.DepthMode = ESPAlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                highlight.Enabled = ESPEnabled
            end)
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not ESPEnabled then
        for _, highlight in pairs(ESPObjects) do
            if highlight then
                pcall(function() highlight.Enabled = false end)
            end
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and ESPObjects[player] then
            local success, distance = pcall(function()
                return (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)
            if success then
                pcall(function()
                    ESPObjects[player].Enabled = (distance <= ESPMaxDistance)
                end)
            end
        end
    end
end)

local ESPSection = Tabs.Main:AddSection("ESP")

ESPSection:AddToggle("ESPEnabled", { Title = "Enable ESP", Default = false }):OnChanged(function(Value)
    ESPEnabled = Value
    if not Value then
        for _, highlight in pairs(ESPObjects) do
            pcall(function() highlight.Enabled = false end)
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            CreateESP(player)
        end
        for _, highlight in pairs(ESPObjects) do
            pcall(function() highlight.Enabled = true end)
        end
    end
    Fluent:Notify({
        Title = "ESP",
        Content = Value and "ESP Enabled" or "ESP Disabled",
        Duration = 4
    })
end)

ESPSection:AddColorpicker("ESPFColor", {
    Title = "ESP Fill Color",
    Default = ESPFillColor
}):OnChanged(function()
    ESPFillColor = Options.ESPFColor.Value
    UpdateESPProperties()
    Fluent:Notify({
        Title = "ESP",
        Content = "ESP Fill Color updated!",
        Duration = 4
    })
end)

ESPSection:AddColorpicker("ESPOutlineColor", {
    Title = "ESP Outline Color",
    Default = ESPOutlineColor
}):OnChanged(function()
    ESPOutlineColor = Options.ESPOutlineColor.Value
    UpdateESPProperties()
    Fluent:Notify({
        Title = "ESP",
        Content = "ESP Outline Color updated!",
        Duration = 4
    })
end)

ESPSection:AddSlider("ESPFTransparency", {
    Title = "ESP Fill Transparency",
    Min = 0,
    Max = 1,
    Default = ESPFillTransparency,
    Rounding = 2,
    Callback = function(Value)
        ESPFillTransparency = Value
        UpdateESPProperties()
    end
})

ESPSection:AddSlider("ESPOutlineTransparency", {
    Title = "ESP Outline Transparency",
    Min = 0,
    Max = 1,
    Default = ESPOutlineTransparency,
    Rounding = 2,
    Callback = function(Value)
        ESPOutlineTransparency = Value
        UpdateESPProperties()
    end
})

ESPSection:AddToggle("ESPDepthMode", { Title = "ESP Always On Top", Default = true }):OnChanged(function(Value)
    ESPAlwaysOnTop = Value
    UpdateESPProperties()
    Fluent:Notify({
        Title = "ESP",
        Content = "ESP Depth Mode set to " .. (Value and "Always On Top" or "Occluded"),
        Duration = 4
    })
end)

ESPSection:AddSlider("ESPMaxDistance", {
    Title = "ESP Max Distance",
    Min = 100,
    Max = 3000,
    Default = ESPMaxDistance,
    Rounding = 0,
    Callback = function(Value)
        ESPMaxDistance = Value
    end
})

local noclipEnabled = false
local infJumpEnabled = false
local flyEnabled = false
local flySpeed = 50

local LocalPlayerSection = Tabs.Main:AddSection("LocalPlayer Features")

LocalPlayerSection:AddToggle("Noclip", { Title = "Noclip", Default = false }):OnChanged(function(Value)
    noclipEnabled = Value
end)

LocalPlayerSection:AddToggle("InfJump", { Title = "Infinite Jump", Default = false }):OnChanged(function(Value)
    infJumpEnabled = Value
end)

LocalPlayerSection:AddToggle("Fly", { Title = "Fly", Default = false }):OnChanged(function(Value)
    flyEnabled = Value
    if flyEnabled then
        spawn(function()
            local character = LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp then
                humanoid.PlatformStand = true
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVelocity.Parent = hrp
                local uis = game:GetService("UserInputService")
                while flyEnabled and character and character.Parent do
                    local moveDir = Vector3.new(0, 0, 0)
                    if uis:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector
                    end
                    if uis:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector
                    end
                    if uis:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector
                    end
                    if uis:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector
                    end
                    if uis:IsKeyDown(Enum.KeyCode.Space) then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    end
                    if uis:IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDir = moveDir - Vector3.new(0, 1, 0)
                    end
                    bodyVelocity.Velocity = moveDir * flySpeed
                    wait(0.01)
                end
                bodyVelocity:Destroy()
                humanoid.PlatformStand = false
            end
        end)
    end
end)

LocalPlayerSection:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = flySpeed,
    Rounding = 0,
    Callback = function(Value)
        flySpeed = Value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local ExtraSection = Tabs.Main:AddSection("Extra")

--// Ensure RunService is properly assigned
local success, run_service = pcall(function() return game:GetService("RunService") end)
if not success or not run_service then
    warn("Failed to get RunService!")
    return
end

--// services
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")

--// variables
local localplayer = players.LocalPlayer
local playerscripts = localplayer:FindFirstChild("PlayerScripts")


local spinning = false
local spin_speed = 100 -- Adjust for faster or slower spinning
local spin_connection

-- Attempt to require CameraController, but catch errors for unsupported executors
local camera_controller
local camera_controller_success, camera_controller_result = pcall(function()
    return require(playerscripts.Controllers.CameraController)
end)

if camera_controller_success then
    camera_controller = camera_controller_result
else
    camera_controller = nil
end

-- Function to send Fluent Notifications
local function sendFluentNotification(title, content, subcontent, duration)
    Fluent:Notify({
        Title = title,
        Content = content,
        SubContent = subcontent or "", -- Optional
        Duration = duration or 5 -- Default to 5 seconds if not specified
    })
end

--// Third-Person Toggle Function
local function toggleThirdPerson(enabled)
    if camera_controller then
        camera_controller:SetPOV(not enabled, 0, false) -- Enable third-person
    else
        sendFluentNotification("Executor Error", "Your executor does not support require(), third person may not work!", "Use a high-level executor.", 5)
    end
end

--// Function to toggle spinning effect
local function toggleSpin(enabled)
    if not run_service then
        warn("RunService is nil, cannot enable spin.")
        return
    end

    if enabled then
        spinning = true
        if spin_connection then spin_connection:Disconnect() end -- Prevent duplicate connections
        spin_connection = run_service.RenderStepped:Connect(function()
            if localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = localplayer.Character.HumanoidRootPart
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spin_speed), 0)
            end
        end)
    else
        spinning = false
        if spin_connection then
            spin_connection:Disconnect()
            spin_connection = nil
        end
    end
end

local ThirdPersonToggle = Tabs.Main:AddToggle("ThirdPersonToggle", {Title = "Third Person", Default = false })

ThirdPersonToggle:OnChanged(function()
    print("Third-person toggle changed:", Options.ThirdPersonToggle.Value)
    toggleThirdPerson(Options.ThirdPersonToggle.Value)
end)

Options.ThirdPersonToggle:SetValue(false) -- Default to first-person mode

--// Spin toggle
local SpinToggle = Tabs.Main:AddToggle("SpinToggle", {Title = "Spin Character", Default = false })

SpinToggle:OnChanged(function()
    print("Spin toggle changed:", Options.SpinToggle.Value)
    toggleSpin(Options.SpinToggle.Value)
end)

Options.SpinToggle:SetValue(false) -- Default to no spinning

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/rivals")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "SwirlHub",
    Content = "The script has been loaded successfully!",
    Duration = 4
})

SaveManager:LoadAutoloadConfig()
