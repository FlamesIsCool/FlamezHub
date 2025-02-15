--// Load Fluent and Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--// Create Main Window
local Window = Fluent:CreateWindow({
    Title = "🌌 SwirlHub - Rivals " .. Fluent.Version,
    SubTitle = "by Flames",
    TabWidth = 170,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })

local function DebugLog(msg)
    print("🔧 [SwirlHub Debug]: " .. msg)
end

--// Welcome Notification
Fluent:Notify({
    Title = "🎉 Welcome",
    Content = "SwirlHub Rivals has been successfully loaded!",
    Duration = 5,
    Type = "success"
})

DebugLog("Script initialization complete.")

--// INFORMATION SECTION
MainTab:AddParagraph({
    Title = "ℹ️ INFORMATION",
    Content = "🔹 Script may take a while to load.\n🔹 Questions? Join Discord: discord.gg/5c9D3VD7se\n🔹 ⚠️ Aimbot can sometimes glitch while aiming!"
})

local Players = game:FindService("Players") or game:GetService("Players")
if not Players then
    warn("⚠️ Players service is not available. Aimbot may fail.")
end

local LocalPlayer = Players.LocalPlayer
local Options = Fluent.Options

--// AIMBOT SETUP
local AimbotEnabled = false
local aimbotKey = Enum.KeyCode.E
local lockedTarget = nil
local isLocked = false
local aimPart = "Head"
local fovSize = 100
local fovColor = Color3.fromRGB(255, 0, 0)

--// FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 100
FOVCircle.Visible = false

local function UpdateFOV()
    FOVCircle.Radius = fovSize
    FOVCircle.Color = fovColor
    FOVCircle.Visible = AimbotEnabled
end

local function GetClosestTargetInFOV()
    if not Players then return nil end
    local closest, minDist = nil, math.huge
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer 
           and player.Character 
           and player.Character:FindFirstChild(aimPart) then

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

game:GetService("RunService").RenderStepped:Connect(function()
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    FOVCircle.Position = mousePos
    if isLocked and lockedTarget then
        MoveMouseToTarget(lockedTarget)
    end
end)

--// AIMBOT SECTION
local AimbotSection = MainTab:AddSection("🎯 Aimbot")

AimbotSection:AddToggle("AimbotToggle", {
    Title = "✅ Enable Aimbot",
    Default = false
}):OnChanged(function(Value)
    AimbotEnabled = Value
    UpdateFOV()
    Fluent:Notify({
        Title = "🎯 Aimbot",
        Content = Value and "Aimbot Enabled" or "Aimbot Disabled",
        Duration = 4
    })
    DebugLog("Aimbot toggled: " .. tostring(Value))
end)

AimbotSection:AddSlider("FOVSize", {
    Title = "🔘 FOV Circle Size",
    Min = 50,
    Max = 500,
    Default = 100,
    Rounding = 0,
    Callback = function(Value)
        fovSize = Value
        UpdateFOV()
        DebugLog("FOV size set to: " .. Value)
    end
})

AimbotSection:AddColorpicker("FOVColor", {
    Title = "🎨 FOV Circle Color",
    Default = Color3.fromRGB(255, 0, 0)
}):OnChanged(function()
    fovColor = Options.FOVColor.Value
    UpdateFOV()
    Fluent:Notify({
        Title = "🎯 Aimbot",
        Content = "FOV Color updated!",
        Duration = 4
    })
    DebugLog("FOV color changed.")
end)

AimbotSection:AddDropdown("AimPartDropdown", {
    Title = "🎯 Aim Part",
    Values = {"Head", "HumanoidRootPart"},
    Default = "Head"
}):OnChanged(function(Value)
    aimPart = Value
    Fluent:Notify({
        Title = "🎯 Aimbot",
        Content = "Aim Part set to " .. Value,
        Duration = 4
    })
    DebugLog("Aim part changed to: " .. Value)
end)

AimbotSection:AddKeybind("AimbotKeybind", {
    Title = "🎮 Aimbot Key",
    Default = "E",
    Mode = "Toggle",
    Callback = function()
        if AimbotEnabled then
            if isLocked then
                isLocked = false
                lockedTarget = nil
                Fluent:Notify({
                    Title = "🎯 Aimbot",
                    Content = "Target Unlocked",
                    Duration = 4
                })
                DebugLog("Target unlocked.")
            else
                lockedTarget = GetClosestTargetInFOV()
                if lockedTarget then
                    isLocked = true
                    Fluent:Notify({
                        Title = "🎯 Aimbot",
                        Content = "Target Locked",
                        Duration = 4
                    })
                    DebugLog("Target locked onto: "..lockedTarget.Name)
                else
                    Fluent:Notify({
                        Title = "🎯 Aimbot",
                        Content = "No target in FOV!",
                        Duration = 4
                    })
                    DebugLog("No valid target found in FOV.")
                end
            end
        end
    end,
    ChangedCallback = function(NewKey)
        aimbotKey = NewKey
        Fluent:Notify({
            Title = "🎯 Aimbot Key",
            Content = "Keybind changed to " .. tostring(NewKey),
            Duration = 4
        })
        DebugLog("Aimbot keybind changed to: " .. tostring(NewKey))
    end
})

local ESPEnabled = false
local ESPFillColor = Color3.fromRGB(255, 0, 0) 
local ESPOutlineColor = Color3.fromRGB(255, 255, 255)
local ESPFillTransparency = 0.5
local ESPOutlineTransparency = 0
local ESPAlwaysOnTop = true
local ESPMaxDistance = 1000
local ESPObjects = {}

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

local function CreateESP(player)
    if not player or player == LocalPlayer or ESPObjects[player] then return end

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

    if not success or not highlight then
        warn("❌ Error creating ESP for player: " .. (player.Name or "Unknown"))
        return
    end

    ESPObjects[player] = highlight

    local function UpdateCharacter()
        task.wait(0.5)
        if player and player.Character then
            pcall(function() highlight.Adornee = player.Character end)
        end
    end

    local charAddedConn = player.CharacterAdded:Connect(function()
        pcall(UpdateCharacter)
    end)

    highlight:GetPropertyChangedSignal("Parent"):Connect(function()
        if not highlight.Parent then
            pcall(function() charAddedConn:Disconnect() end)
        end
    end)

    pcall(UpdateCharacter)
    DebugLog("ESP created for: " .. player.Name)
end

local function RemoveESP(player)
    if ESPObjects[player] then
        pcall(function() ESPObjects[player]:Destroy() end)
        ESPObjects[player] = nil
        DebugLog("ESP removed for: " .. player.Name)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    CreateESP(p)
end

Players.PlayerAdded:Connect(function(p)
    CreateESP(p)
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if not ESPEnabled then
        for _, highlight in pairs(ESPObjects) do
            if highlight then
                pcall(function() highlight.Enabled = false end)
            end
        end
        return
    end

    for _, ply in ipairs(Players:GetPlayers()) do
        local character = ply.Character
        if character and character:FindFirstChild("HumanoidRootPart") and ESPObjects[ply] then
            local success, distance = pcall(function()
                return (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)
            if success then
                pcall(function()
                    ESPObjects[ply].Enabled = (distance <= ESPMaxDistance)
                end)
            end
        end
    end
end)

--// ESP SECTION
local ESPSection = MainTab:AddSection("👀 ESP")

ESPSection:AddToggle("ESPEnabled", {
    Title = "✅ Enable ESP",
    Default = false
}):OnChanged(function(Value)
    ESPEnabled = Value
    if not Value then
        for _, highlight in pairs(ESPObjects) do
            pcall(function() highlight.Enabled = false end)
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            CreateESP(p)
        end
        for _, highlight in pairs(ESPObjects) do
            pcall(function() highlight.Enabled = true end)
        end
    end
    
    Fluent:Notify({
        Title = "👀 ESP",
        Content = Value and "ESP Enabled" or "ESP Disabled",
        Duration = 4
    })
    DebugLog("ESP toggled: " .. tostring(Value))
end)

ESPSection:AddColorpicker("ESPFColor", {
    Title = "🎨 ESP Fill Color",
    Default = ESPFillColor
}):OnChanged(function()
    ESPFillColor = Options.ESPFColor.Value
    UpdateESPProperties()
    Fluent:Notify({
        Title = "👀 ESP",
        Content = "ESP Fill Color updated!",
        Duration = 4
    })
    DebugLog("ESP fill color changed.")
end)

ESPSection:AddColorpicker("ESPOutlineColor", {
    Title = "🎨 ESP Outline Color",
    Default = ESPOutlineColor
}):OnChanged(function()
    ESPOutlineColor = Options.ESPOutlineColor.Value
    UpdateESPProperties()
    Fluent:Notify({
        Title = "👀 ESP",
        Content = "ESP Outline Color updated!",
        Duration = 4
    })
    DebugLog("ESP outline color changed.")
end)

ESPSection:AddSlider("ESPFTransparency", {
    Title = "🔘 ESP Fill Transparency",
    Min = 0,
    Max = 1,
    Default = ESPFillTransparency,
    Rounding = 2,
    Callback = function(Value)
        ESPFillTransparency = Value
        UpdateESPProperties()
        DebugLog("ESP fill transparency: "..Value)
    end
})

ESPSection:AddSlider("ESPOutlineTransparency", {
    Title = "🔘 ESP Outline Transparency",
    Min = 0,
    Max = 1,
    Default = ESPOutlineTransparency,
    Rounding = 2,
    Callback = function(Value)
        ESPOutlineTransparency = Value
        UpdateESPProperties()
        DebugLog("ESP outline transparency: "..Value)
    end
})

ESPSection:AddToggle("ESPDepthMode", {
    Title = "🔳 ESP Always On Top",
    Default = true
}):OnChanged(function(Value)
    ESPAlwaysOnTop = Value
    UpdateESPProperties()
    Fluent:Notify({
        Title = "👀 ESP",
        Content = "ESP Depth Mode: " .. (Value and "Always On Top" or "Occluded"),
        Duration = 4
    })
    DebugLog("ESP depth mode: " .. tostring(Value))
end)

ESPSection:AddSlider("ESPMaxDistance", {
    Title = "📏 ESP Max Distance",
    Min = 100,
    Max = 3000,
    Default = ESPMaxDistance,
    Rounding = 0,
    Callback = function(Value)
        ESPMaxDistance = Value
        DebugLog("ESP max distance set to: "..Value)
    end
})

--// LOCALPLAYER FEATURES
local noclipEnabled = false
local infJumpEnabled = false
local flyEnabled = false
local flySpeed = 50

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

local LocalPlayerSection = MainTab:AddSection("🧍 LocalPlayer Features")

LocalPlayerSection:AddToggle("Noclip", {
    Title = "🚫 Noclip",
    Default = false
}):OnChanged(function(Value)
    noclipEnabled = Value
    Fluent:Notify({
        Title = "🧍 Noclip",
        Content = Value and "Noclip Enabled" or "Noclip Disabled",
        Duration = 4
    })
    DebugLog("Noclip toggled: " .. tostring(Value))
end)

LocalPlayerSection:AddToggle("InfJump", {
    Title = "🔝 Infinite Jump",
    Default = false
}):OnChanged(function(Value)
    infJumpEnabled = Value
    Fluent:Notify({
        Title = "🧍 Infinite Jump",
        Content = Value and "Infinite Jump Enabled" or "Infinite Jump Disabled",
        Duration = 4
    })
    DebugLog("Infinite jump toggled: " .. tostring(Value))
end)

LocalPlayerSection:AddToggle("Fly", {
    Title = "🦋 Fly",
    Default = false
}):OnChanged(function(Value)
    flyEnabled = Value
    Fluent:Notify({
        Title = "🧍 Fly",
        Content = Value and "Fly Mode Enabled" or "Fly Mode Disabled",
        Duration = 4
    })
    DebugLog("Fly toggled: " .. tostring(Value))

    if Value then
        -- Start Fly
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
    Title = "💨 Fly Speed",
    Min = 10,
    Max = 200,
    Default = flySpeed,
    Rounding = 0,
    Callback = function(Value)
        flySpeed = Value
        DebugLog("Fly speed set to: " .. Value)
    end
})

local ExtraSection = MainTab:AddSection("✨ Extra")

local success, run_service = pcall(function() return game:GetService("RunService") end)
if not success or not run_service then
    warn("Failed to get RunService!")
    return
end

local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local playerscripts = localplayer:FindFirstChild("PlayerScripts")
local spinning = false
local spin_speed = 100
local spin_connection

local camera_controller
local camera_controller_success, camera_controller_result = pcall(function()
    return require(playerscripts.Controllers.CameraController)
end)

if camera_controller_success then
    camera_controller = camera_controller_result
else
    camera_controller = nil
end

local function sendFluentNotification(title, content, subcontent, duration)
    Fluent:Notify({
        Title = title,
        Content = content,
        SubContent = subcontent or "",
        Duration = duration or 5
    })
end

local function toggleThirdPerson(enabled)
    if camera_controller then
        camera_controller:SetPOV(not enabled, 0, false) -- third person
    else
        sendFluentNotification("Executor Error", "Your executor does not support require()!", "Third-person may not work!", 5)
    end
end

local function toggleSpin(enabled)
    if not run_service then
        warn("RunService is nil, cannot enable spin.")
        return
    end

    if enabled then
        spinning = true
        if spin_connection then spin_connection:Disconnect() end
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

ExtraSection:AddToggle("ThirdPersonToggle", {
    Title = "👁️ Third Person",
    Default = false
}):OnChanged(function(Value)
    toggleThirdPerson(Value)
    DebugLog("Third-person toggled: "..tostring(Value))
end)

ExtraSection:AddToggle("SpinToggle", {
    Title = "🔄 Spin Character",
    Default = false
}):OnChanged(function(Value)
    toggleSpin(Value)
    DebugLog("Spin toggled: "..tostring(Value))
end)

local ClientSection = MainTab:AddSection("💡 Client")

local Lighting = game:GetService("Lighting")
local isDarkMode = false

local function toggleDarkMode()
    if isDarkMode then
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        isDarkMode = false
        Fluent:Notify({
            Title = "💡 Mode Switched",
            Content = "Switched to Light Mode",
            Duration = 3
        })
        DebugLog("Light mode activated.")
    else
        Lighting.Brightness = 0.5
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 30)
        Lighting.Ambient = Color3.fromRGB(20, 20, 20)
        isDarkMode = true
        Fluent:Notify({
            Title = "💡 Mode Switched",
            Content = "Switched to Dark Mode",
            Duration = 3
        })
        DebugLog("Dark mode activated.")
    end
end

ClientSection:AddButton({
    Title = "🌓 Toggle Dark/Light Mode",
    Description = "Switch between dark mode and light mode",
    Callback = function()
        toggleDarkMode()
    end
})

--// Save/Load System
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/rivals")


Window:SelectTab(1)

Fluent:Notify({
    Title = "SwirlHub",
    Content = "The script has been loaded successfully!",
    Duration = 4
})

SaveManager:LoadAutoloadConfig()

DebugLog("Script fully loaded! Enjoy 🚀")
