local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager =
    loadstring(
        game:HttpGet(repo .. 'addons/ThemeManager.lua')
    )()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = Library.Options
local Toggles = Library.Toggles
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer

Library:Notify('Script Loaded', 2)

local Window = Library:CreateWindow({
    Title = 'Bridge Builders!',
    Footer = 'Made by Flames/Aura',
    Icon = 95816097006870,
    NotifySide = 'Right',
})

local Tabs = {
    Main = Window:AddTab('Main', 'user'),
    ['UI Settings'] = Window:AddTab('UI Settings', 'settings'),
}

local MainGroup = Tabs.Main:AddLeftGroupbox('Autofarm')

MainGroup:AddToggle('AutoFarm', {
    Text = 'Blatent AutoFarm',
    Default = false,
    Tooltip = 'Farms area, teleports to bridge, touches trophy at the end all at once.',
})

-- Autofarm logic function
local function AutoFarm()
    local function getModelNumber(name)
        local num = string.match(name, '^P(%d+)$')
        return num and tonumber(num)
    end

    local function getHighestPModel(zoneName)
        local zone = workspace:FindFirstChild(zoneName)
        local build = zone and zone:FindFirstChild('Build')
        if not build then
            return nil
        end

        local highestModel, highestNum = nil, -math.huge
        for _, model in ipairs(build:GetChildren()) do
            if model:IsA('Model') and model.Name:match('^P%d+$') then
                local num = getModelNumber(model.Name)
                if num and num > highestNum then
                    highestNum = num
                    highestModel = model
                end
            end
        end
        return highestModel, highestNum
    end

    local function getTouchPartAndZone()
        local team = player.Team
        if not team then
            return nil, nil
        end
        local zoneName = team.Name .. 'Zone'
        local zone = workspace:FindFirstChild(zoneName)
        local area = zone and zone:FindFirstChild('Area' .. team.Name)
        return area, zoneName
    end

    local function fireTrophyTouch()
        local trophy = workspace:FindFirstChild('Trophy')
        local abajo = trophy and trophy:FindFirstChild('Abajo')
        local touch = abajo and abajo:FindFirstChild('TouchInterest')
        if
            abajo
            and touch
            and player.Character
            and player.Character:FindFirstChild('HumanoidRootPart')
        then
            firetouchinterest(player.Character.HumanoidRootPart, abajo, 0)
            firetouchinterest(player.Character.HumanoidRootPart, abajo, 1)
        end
    end

    RunService.RenderStepped:Connect(function()
        if not Toggles.AutoFarm.Value then
            return
        end

        local character = player.Character
        if
            not character or not character:FindFirstChild('HumanoidRootPart')
        then
            return
        end

        local areaPart, zoneName = getTouchPartAndZone()
        if areaPart then
            firetouchinterest(character.HumanoidRootPart, areaPart, 0)
            firetouchinterest(character.HumanoidRootPart, areaPart, 1)
        end

        if zoneName then
            local model, num = getHighestPModel(zoneName)
            if num and num >= 49 then
                fireTrophyTouch()
            end

            if model then
                if not model.PrimaryPart then
                    local part = model:FindFirstChildWhichIsA('BasePart')
                    if part then
                        model.PrimaryPart = part
                    else
                        return
                    end
                end
                character:SetPrimaryPartCFrame(
                    model.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                )
            end
        end
    end)
end

Toggles.AutoFarm:OnChanged(function()
    if Toggles.AutoFarm.Value then
        Library:Notify('AutoFarm Enabled', 2)
        AutoFarm()
    else
        Library:Notify('AutoFarm Paused', 2)
    end
end)

-- UI Settings tab
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddToggle('KeybindMenuOpen', {
    Text = 'Open Keybind Menu',
    Default = Library.KeybindFrame.Visible,
    Callback = function(v)
        Library.KeybindFrame.Visible = v
    end,
})

MenuGroup:AddButton('Unload UI', function()
    Library:Unload()
end)

MenuGroup:AddLabel('Menu keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'UI Toggle Keybind',
})

Library.ToggleKeybind = Options.MenuKeybind

-- === LEGIT AUTO FARM (PATHFINDING VERSION) === --

MainGroup:AddToggle('LegitAutoFarm', {
    Text = 'Legit AutoFarm',
    Default = false,
    Tooltip = 'Walks to Areas like a real player and touches',
})

local PathfindingService = game:GetService('PathfindingService')
local player = game:GetService('Players').LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Reuse walkTo() with Pathfinding
local function walkTo(position)
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local hrp = character:FindFirstChild('HumanoidRootPart')
    if not humanoid or not hrp then
        return
    end

    local path = PathfindingService:CreatePath()
    path:ComputeAsync(hrp.Position, position)

    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
            if not Toggles.LegitAutoFarm.Value then
                return
            end
        end
    else
        warn('[LegitAutoFarm] Failed to find path')
    end
end

-- Reuse number functions
local function getModelNumber(name)
    return tonumber(name:match('^P(%d+)$'))
end

local function getHighestPModel(zoneName)
    local build = workspace:FindFirstChild(zoneName):FindFirstChild('Build')
    local highest, num = nil, -math.huge

    for _, model in ipairs(build:GetChildren()) do
        if model:IsA('Model') and model.Name:match('^P%d+$') then
            local n = getModelNumber(model.Name)
            if n and n > num then
                highest = model
                num = n
            end
        end
    end
    return highest, num
end

local function fireTouch(part)
    local hrp = character:FindFirstChild('HumanoidRootPart')
    if part and hrp then
        firetouchinterest(hrp, part, 0)
        firetouchinterest(hrp, part, 1)
    end
end

-- legit logic
local function LegitFarm()
    task.spawn(function()
        while Toggles.LegitAutoFarm.Value do
            character = player.Character or player.CharacterAdded:Wait()
            local team = player.Team and player.Team.Name
            if not team then
                return
            end

            local zoneName = team .. 'Zone'
            local zone = workspace:FindFirstChild(zoneName)
            local area = zone and zone:FindFirstChild('Area' .. team)

            if area then
                walkTo(area.Position + Vector3.new(0, 3, 0))
                fireTouch(area)
            end

            local model, num = getHighestPModel(zoneName)
            if model then
                local part = model.PrimaryPart
                    or model:FindFirstChildWhichIsA('BasePart')
                if part then
                    walkTo(part.Position + Vector3.new(0, 3, 0))
                end
            end

            if num and num >= 49 then
                local trophy = workspace:FindFirstChild('Trophy')
                local abajo = trophy and trophy:FindFirstChild('Abajo')
                if abajo then
                    walkTo(abajo.Position + Vector3.new(0, 3, 0))
                    fireTouch(abajo)
                end
            end

            task.wait(1)
        end
    end)
end

Toggles.LegitAutoFarm:OnChanged(function()
    if Toggles.LegitAutoFarm.Value then
        Library:Notify('LegitAutoFarm ON', 3)
        LegitFarm()
    else
        Library:Notify('LegitAutoFarm OFF', 3)
    end
end)

local LocalGroup = Tabs.Main:AddRightGroupbox('LocalPlayer')

-- WALKSPEED
LocalGroup:AddSlider('WalkSpeedSlider', {
    Text = 'WalkSpeed',
    Min = 16,
    Max = 250,
    Default = 16,
    Rounding = 0,
    Compact = false,
    Callback = function(val)
        local char = player.Character
        if char and char:FindFirstChildOfClass('Humanoid') then
            char:FindFirstChildOfClass('Humanoid').WalkSpeed = val
        end
    end,
})

-- INFINITE JUMP
LocalGroup:AddToggle('InfJump', {
    Text = 'Infinite Jump',
    Default = false,
})

-- Noclip
LocalGroup:AddToggle('NoclipToggle', {
    Text = 'Noclip',
    Default = false,
})

-- WASD FLY SYSTEM
LocalGroup:AddToggle('FlyToggle', {
    Text = 'Fly',
    Default = false,
})

-- === SCRIPTS === --

-- Infinite Jump
game:GetService('UserInputService').JumpRequest:Connect(function()
    if Toggles.InfJump and Toggles.InfJump.Value then
        local char = player.Character
        if char and char:FindFirstChildOfClass('Humanoid') then
            char
                :FindFirstChildOfClass('Humanoid')
                :ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip Logic
RunService.Stepped:Connect(function()
    if Toggles.NoclipToggle and Toggles.NoclipToggle.Value then
        local char = player.Character
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- WASD FLY SETUP
local flying = false
local UIS = game:GetService('UserInputService')
local velocity, gyro
local direction = Vector3.zero
local cam = workspace.CurrentCamera

Toggles.FlyToggle:OnChanged(function()
    flying = Toggles.FlyToggle.Value

    if flying then
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild('HumanoidRootPart')

        velocity = Instance.new('BodyVelocity')
        velocity.Velocity = Vector3.zero
        velocity.MaxForce = Vector3.new(1, 1, 1) * 1e5
        velocity.P = 1e4
        velocity.Parent = hrp

        gyro = Instance.new('BodyGyro')
        gyro.MaxTorque = Vector3.new(1, 1, 1) * 1e5
        gyro.P = 1e4
        gyro.CFrame = hrp.CFrame
        gyro.Parent = hrp

        Library:Notify('Fly Enabled (WASD to move)', 3)
    else
        if velocity then
            velocity:Destroy()
        end
        if gyro then
            gyro:Destroy()
        end
        velocity, gyro = nil, nil
        Library:Notify('Fly Disabled', 3)
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then
        return
    end
    if not flying then
        return
    end

    if input.KeyCode == Enum.KeyCode.W then
        direction = direction + Vector3.new(0, 0, -1)
    end
    if input.KeyCode == Enum.KeyCode.S then
        direction = direction + Vector3.new(0, 0, 1)
    end
    if input.KeyCode == Enum.KeyCode.A then
        direction = direction + Vector3.new(-1, 0, 0)
    end
    if input.KeyCode == Enum.KeyCode.D then
        direction = direction + Vector3.new(1, 0, 0)
    end
    if input.KeyCode == Enum.KeyCode.Space then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        direction = direction + Vector3.new(0, -1, 0)
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then
        return
    end
    if not flying then
        return
    end

    if input.KeyCode == Enum.KeyCode.W then
        direction = direction - Vector3.new(0, 0, -1)
    end
    if input.KeyCode == Enum.KeyCode.S then
        direction = direction - Vector3.new(0, 0, 1)
    end
    if input.KeyCode == Enum.KeyCode.A then
        direction = direction - Vector3.new(-1, 0, 0)
    end
    if input.KeyCode == Enum.KeyCode.D then
        direction = direction - Vector3.new(1, 0, 0)
    end
    if input.KeyCode == Enum.KeyCode.Space then
        direction = direction - Vector3.new(0, 1, 0)
    end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        direction = direction - Vector3.new(0, -1, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if flying and velocity and gyro then
        local hrp = player.Character
            and player.Character:FindFirstChild('HumanoidRootPart')
        if not hrp then
            return
        end
        local moveDir = cam.CFrame:VectorToWorldSpace(direction)
        velocity.Velocity = moveDir * 60
        gyro.CFrame = cam.CFrame
    end
end)

-- Theme + config system
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder('FlameHub')
SaveManager:SetFolder('FlamesHub/BridgeBuilders')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
