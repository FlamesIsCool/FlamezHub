local FlyLib = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local char, hrp, hum
local bv, bg
local flying = false
local controls = {w=false, a=false, s=false, d=false, space=false, shift=false}

-- Defaults
local config = {
    Speed = 5,
    ToggleKey = Enum.KeyCode.E,
    UseKeybind = true
}

local function setupChar()
    char = lp.Character or lp.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end

local function createFlyBodies()
    bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.P = 1250
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.CFrame = hrp.CFrame
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 3000
    bg.Parent = hrp
end

local function destroyFlyBodies()
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

function FlyLib:Fly(state)
    if state == flying then return end
    flying = state

    if flying then
        setupChar()
        hum.PlatformStand = true
        createFlyBodies()
    else
        hum.PlatformStand = false
        destroyFlyBodies()
        if hrp then hrp.Velocity = Vector3.zero end
    end
end

function FlyLib:Toggle()
    self:Fly(not flying)
end

function FlyLib:Config(opts)
    for k,v in pairs(opts) do
        config[k] = v
    end
end

-- Movement Keys
UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    local k = i.KeyCode
    if config.UseKeybind and k == config.ToggleKey then
        FlyLib:Toggle()
    end
    if k == Enum.KeyCode.W then controls.w = true end
    if k == Enum.KeyCode.A then controls.a = true end
    if k == Enum.KeyCode.S then controls.s = true end
    if k == Enum.KeyCode.D then controls.d = true end
    if k == Enum.KeyCode.Space then controls.space = true end
    if k == Enum.KeyCode.LeftShift then controls.shift = true end
end)

UIS.InputEnded:Connect(function(i)
    local k = i.KeyCode
    if k == Enum.KeyCode.W then controls.w = false end
    if k == Enum.KeyCode.A then controls.a = false end
    if k == Enum.KeyCode.S then controls.s = false end
    if k == Enum.KeyCode.D then controls.d = false end
    if k == Enum.KeyCode.Space then controls.space = false end
    if k == Enum.KeyCode.LeftShift then controls.shift = false end
end)

-- Main Fly Loop
RunService.RenderStepped:Connect(function()
    if flying and bv and bg then
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if controls.w then dir += cam.CFrame.LookVector end
        if controls.s then dir -= cam.CFrame.LookVector end
        if controls.a then dir -= cam.CFrame.RightVector end
        if controls.d then dir += cam.CFrame.RightVector end
        if controls.space then dir += cam.CFrame.UpVector end
        if controls.shift then dir -= cam.CFrame.UpVector end

        if dir.Magnitude > 0 then
            bv.Velocity = dir.Unit * config.Speed * 10
        else
            bv.Velocity = Vector3.zero
        end

        bg.CFrame = cam.CFrame
    end
end)

return FlyLib
