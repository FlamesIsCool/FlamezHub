local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Build a Plane - FlameHub " .. Fluent.Version,
    SubTitle = "by Flames/Aura",
    TabWidth = 160,
    Size = UDim2.fromOffset(400, 360),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Main = Window:AddTab({ Title = "Blood Moon", Icon = "atom" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local autofarmEnabled = false

local currentIndex = 1
local cachedCoins = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function getCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    repeat task.wait() until char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart")
    return char
end

local function waitForRespawn()
    while true do
        local char = getCharacter()
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then break end
        task.wait()
    end
end

local function getVehicle()
    local seat = getCharacter():FindFirstChildOfClass("Humanoid") and getCharacter():FindFirstChildOfClass("Humanoid").SeatPart
    if not seat then return end
    local model = seat:FindFirstAncestorOfClass("Model")
    if not model then return end

    if not model.PrimaryPart then
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                model.PrimaryPart = part
                break
            end
        end
    end
    return model
end

local function fireLaunchAndPortal()
    ReplicatedStorage.Remotes.LaunchEvents.Launch:FireServer()
    task.wait(0.3)
    ReplicatedStorage.Remotes.SpectialEvents.PortalTouched:FireServer()
end

local function collectCoin(coin)
    ReplicatedStorage.Remotes.SpectialEvents.CollectCoin:FireServer(coin.Name)
end

local function tpVehicleTo(vehicle, position)
    if not vehicle or not vehicle.PrimaryPart then return end
    vehicle:SetPrimaryPartCFrame(CFrame.new(position + Vector3.new(0, 7, 0)))
end

local function getCoinsSorted()
    if #cachedCoins > 0 then return cachedCoins end

    local char = getCharacter()
    local pos = char:WaitForChild("HumanoidRootPart").Position
    local allCoins = {}

    for _, section in ipairs(workspace:WaitForChild("SpawnedSections"):GetChildren()) do
        local coins = section:FindFirstChild("Coins")
        if coins then
            for _, coin in ipairs(coins:GetChildren()) do
                if coin:IsA("BasePart") then
                    table.insert(allCoins, coin)
                end
            end
        end
    end

    table.sort(allCoins, function(a, b)
        return (a.Position - pos).Magnitude < (b.Position - pos).Magnitude
    end)

    cachedCoins = allCoins
    return cachedCoins
end

spawn(function()
    while true do
        task.wait(0.1)
        if autofarmEnabled then
            waitForRespawn()
            fireLaunchAndPortal()
            task.wait(0.2)

            local vehicle = getVehicle()
            if not vehicle then warn("No vehicle") task.wait(1) continue end

            local coins = getCoinsSorted()
            if currentIndex > #coins then
                currentIndex = 1 -- restart when finished
            end

            local coin = coins[currentIndex]
            if coin and coin:IsA("BasePart") then
                tpVehicleTo(vehicle, coin.Position)
                collectCoin(coin)
                currentIndex += 1
                task.wait(0.05)
            end
        end
    end
end)

Tabs.Main:AddToggle("AutofarmToggle", {
    Title = "Autofarm Blood Tokens",
    Default = false,
    Callback = function(state)
        autofarmEnabled = state
        print("Autofarm toggled:", state)
    end
})
