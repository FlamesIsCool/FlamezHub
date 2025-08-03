local Fluent = loadstring(
    game:HttpGet(
        'https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'
    )
)()
local SaveManager = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua'
    )
)()
local InterfaceManager = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua'
    )
)()

local Window = Fluent:CreateWindow({
    Title = 'Fluent ' .. Fluent.Version,
    SubTitle = 'by dawid',
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = 'Dark',
    MinimizeKey = Enum.KeyCode.LeftControl, -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = 'Main', Icon = 'home' }),
    ESP = Window:AddTab({ Title = 'ESP', Icon = 'eye' }),
    Settings = Window:AddTab({ Title = 'Settings', Icon = 'settings' }),
}

-- WALKSPEED
local WalkSlider = Tabs.Main:AddSlider('WalkSpeed', {
    Title = 'WalkSpeed',
    Description = 'Adjust your movement speed',
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 0,
    Callback = function(val)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        end)
    end,
})

-- JUMPPOWER
local JumpSlider = Tabs.Main:AddSlider('JumpPower', {
    Title = 'JumpPower',
    Description = 'Adjust how high you jump',
    Min = 50,
    Max = 300,
    Default = 50,
    Rounding = 0,
    Callback = function(val)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
        end)
    end,
})

-- GRAVITY
local GravitySlider = Tabs.Main:AddSlider('Gravity', {
    Title = 'Gravity',
    Description = 'Control game gravity',
    Min = 0,
    Max = 196.2,
    Default = workspace.Gravity,
    Rounding = 1,
    Callback = function(val)
        workspace.Gravity = val
    end,
})

-- FOV
local FOVSlider = Tabs.Main:AddSlider('FOV', {
    Title = 'Field of View',
    Description = 'Change your camera FOV',
    Min = 30,
    Max = 120,
    Default = 70,
    Rounding = 0,
    Callback = function(val)
        game:GetService('Workspace').CurrentCamera.FieldOfView = val
    end,
})

-- NOCLIP
local noclip = false
local NoclipToggle = Tabs.Main:AddToggle(
    'NoclipToggle',
    { Title = 'Noclip', Default = false }
)

NoclipToggle:OnChanged(function(val)
    noclip = val
end)

game:GetService('RunService').Stepped:Connect(function()
    if noclip then
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA('BasePart') and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- INFINITE JUMP
local infJump = false
local InfJumpToggle = Tabs.Main:AddToggle(
    'InfJumpToggle',
    { Title = 'Infinite Jump', Default = false }
)

InfJumpToggle:OnChanged(function(val)
    infJump = val
end)

game:GetService('UserInputService').JumpRequest:Connect(function()
    if infJump then
        local humanoid = game.Players.LocalPlayer.Character
            and game.Players.LocalPlayer.Character:FindFirstChildOfClass(
                'Humanoid'
            )
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local AutoTauntEnabled = false
local TauntBridge = require(
    game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('BridgeNet')
).CreateBridge('Taunt')

local TauntToggle = Tabs.Main:AddToggle(
    'AutoTaunt',
    { Title = 'Auto Taunt', Default = false }
)

TauntToggle:OnChanged(function(val)
    AutoTauntEnabled = val
end)

-- Main loop
task.spawn(function()
    local cooldown = false
    while true do
        if AutoTauntEnabled and not cooldown then
            local tauntGui = game.Players.LocalPlayer:FindFirstChild(
                'PlayerGui'
            ) and game.Players.LocalPlayer.PlayerGui:FindFirstChild(
                'InGame'
            ) and game.Players.LocalPlayer.PlayerGui.InGame:FindFirstChild(
                'Main'
            ) and game.Players.LocalPlayer.PlayerGui.InGame.Main:FindFirstChild(
                'Hiders'
            ) and game.Players.LocalPlayer.PlayerGui.InGame.Main.Hiders:FindFirstChild(
                'Taunt'
            ) and game.Players.LocalPlayer.PlayerGui.InGame.Main.Hiders.Taunt:FindFirstChild(
                'Main'
            )

            if tauntGui then
                local taunts = {}
                for _, btn in ipairs(tauntGui:GetChildren()) do
                    if btn:IsA('TextButton') then
                        table.insert(taunts, btn.Name)
                    end
                end

                if #taunts > 0 then
                    local choice = taunts[math.random(1, #taunts)]
                    cooldown = true
                    TauntBridge:Fire(choice)
                    task.delay(2, function()
                        cooldown = false
                    end)
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Platform settings
local platformSize = Vector3.new(100, 2, 100)
local platformCFrame = CFrame.new(9999, 250, -9999) -- position in void
local platformColor = Color3.fromRGB(0, 255, 127)

-- Create platform
local platform = Instance.new('Part')
platform.Size = platformSize
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 0.2 -- Set to 1 for invisible
platform.Color = platformColor
platform.Name = 'SecretPlatform'
platform.CFrame = platformCFrame
platform.Parent = workspace

-- Teleport toggle logic
local lastPosition = nil

local TP_Toggle = Tabs.Main:AddToggle('SecretPlatform', {
    Title = 'Teleport to Secret Platform',
    Default = false,
})

TP_Toggle:OnChanged(function(state)
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild('HumanoidRootPart')

    if not hrp then
        return
    end

    if state then
        -- Save position and teleport
        lastPosition = hrp.CFrame
        task.wait(0.1)
        hrp.CFrame = platformCFrame + Vector3.new(0, 5, 0)
    else
        -- Return to saved position
        if lastPosition then
            hrp.CFrame = lastPosition
        end
    end
end)

Tabs.Main:AddButton({
    Title = 'Grow',
    Description = 'Grow your character',
    Callback = function()
        local args = {
            {
                {
                    'Grow',
                },
                '\002',
            },
        }
        game
            :GetService('ReplicatedStorage')
            :WaitForChild('dataRemoteEvent')
            :FireServer(unpack(args))
    end,
})

Tabs.Main:AddButton({
    Title = 'Shrink',
    Description = 'Shrink your character',
    Callback = function()
        local args = {
            {
                {
                    'Shrink',
                },
                '\002',
            },
        }
        game
            :GetService('ReplicatedStorage')
            :WaitForChild('dataRemoteEvent')
            :FireServer(unpack(args))
    end,
})

-- ESP Toggles
local ToggleBox = Tabs.ESP:AddToggle(
    'BoxESP',
    { Title = 'Box ESP', Default = true }
)
local ToggleName = Tabs.ESP:AddToggle(
    'NameESP',
    { Title = 'Name ESP', Default = true }
)
local ToggleDistance = Tabs.ESP:AddToggle(
    'DistanceESP',
    { Title = 'Distance ESP', Default = true }
)
local ToggleTracer = Tabs.ESP:AddToggle(
    'TracerESP',
    { Title = 'Tracer ESP', Default = true }
)

-- ESP Setup
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPTable = {}

local function createESP(player)
    if player == LocalPlayer then
        return
    end

    local box = Drawing.new('Square')
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    box.Visible = false

    local nameText = Drawing.new('Text')
    nameText.Size = 13
    nameText.Center = true
    nameText.Outline = true
    nameText.Visible = false

    local distanceText = Drawing.new('Text')
    distanceText.Size = 12
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.Visible = false

    local tracer = Drawing.new('Line')
    tracer.Thickness = 1.5
    tracer.Transparency = 1
    tracer.Visible = false

    ESPTable[player] = {
        Box = box,
        Name = nameText,
        Distance = distanceText,
        Tracer = tracer,
    }
end

local function removeESP(player)
    if ESPTable[player] then
        for _, obj in pairs(ESPTable[player]) do
            obj:Remove()
        end
        ESPTable[player] = nil
    end
end

-- Init for existing players
for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- Main ESP loop
RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESPTable) do
        local character = player.Character
        local hrp = character and character:FindFirstChild('HumanoidRootPart')
        local humanoid = character
            and character:FindFirstChildOfClass('Humanoid')

        if hrp and humanoid and humanoid.Health > 0 then
            local cf, size = character:GetBoundingBox()

            local top = Camera:WorldToViewportPoint(
                cf.Position + Vector3.new(0, size.Y / 2, 0)
            )
            local bottom = Camera:WorldToViewportPoint(
                cf.Position - Vector3.new(0, size.Y / 2, 0)
            )
            local rootPos = Camera:WorldToViewportPoint(hrp.Position)

            local visible = top.Z > 0 and bottom.Z > 0

            if visible then
                local color = player.Team and player.Team.TeamColor.Color
                    or Color3.new(1, 1, 1)
                local dist = math.floor(
                    (Camera.CFrame.Position - hrp.Position).Magnitude
                )

                local height = math.abs(top.Y - bottom.Y)
                local width = height / 2

                -- Box
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(rootPos.X - width / 2, top.Y)
                esp.Box.Color = color
                esp.Box.Visible = ToggleBox.Value

                -- Name
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(rootPos.X, top.Y - 15)
                esp.Name.Color = color
                esp.Name.Visible = ToggleName.Value

                -- Distance
                esp.Distance.Text = '[' .. dist .. 'm]'
                esp.Distance.Position = Vector2.new(rootPos.X, top.Y - 2)
                esp.Distance.Color = color
                esp.Distance.Visible = ToggleDistance.Value

                -- Tracer
                esp.Tracer.From = Vector2.new(
                    Camera.ViewportSize.X / 2,
                    Camera.ViewportSize.Y
                )
                esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.Tracer.Color = color
                esp.Tracer.Visible = ToggleTracer.Value
            else
                for _, obj in pairs(esp) do
                    obj.Visible = false
                end
            end
        else
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
    end
end)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder('FluentScriptHub')
SaveManager:SetFolder('FluentScriptHub/specific-game')

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = 'Fluent',
    Content = 'The script has been loaded.',
    Duration = 8,
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
