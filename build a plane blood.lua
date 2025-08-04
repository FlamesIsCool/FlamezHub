local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Build a Plane - FlameHub " .. Fluent.Version,
    SubTitle = "by Flames/Aura",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Moon = Window:AddTab({ Title = "Blood Moon", Icon = "moon" }),
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
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

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Folder") and obj.Name == "Coins" then
            for _, coin in ipairs(obj:GetChildren()) do
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
            task.wait(0.1)

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
                task.wait(0.1)
            end
        end
    end
end)

Tabs.Moon:AddToggle("AutofarmToggle", {
    Title = "Autofarm Blood Tokens",
    Default = false,
    Callback = function(state)
        autofarmEnabled = state
        print("Autofarm toggled:", state)
    end
})

local autobuyEnabled = false

local function autoBuyAll()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local BuyBlock = ReplicatedStorage.Remotes.ShopEvents:WaitForChild("BuyBlock")

    local itemsToBuy = {
        "block_1",
        "wing_1", "wing_2",
        "fuel_1", "fuel_2", "fuel_3",
        "propeller_1", "propeller_2",
        "seat_1",
        "balloon",
        "missile",
        "rocket",
        "energy"
    }

    while autobuyEnabled do
        for _, item in ipairs(itemsToBuy) do
            pcall(function()
                BuyBlock:FireServer(item)
            end)
            task.wait(0.1)
        end
        task.wait(1)
    end
end

Tabs.Main:AddToggle("AutobuyToggle", {
    Title = "Auto Buy All Items",
    Default = false,
    Callback = function(state)
        autobuyEnabled = state
        if state then
            task.spawn(autoBuyAll)
        end
        print("Autobuy toggled:", state)
    end
})

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Variables
local stepDistance = 10
local stepInterval = 0.3
local flyHeight = 300
local straightFarmEnabled = false
local selectedFarmMode = "Teleport"

-- Character + Seat
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getVehicleSeat()
    local char = getCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
    return nil
end

-- Autofarm logic
local function straightAutoFarm()
    while straightFarmEnabled do
        local seat = getVehicleSeat()
        if not seat then
            warn("Not seated in a VehicleSeat.")
            task.wait(1)
            continue
        end

        local forward = seat.CFrame.LookVector * stepDistance
        local targetPos = Vector3.new(
            seat.Position.X + forward.X,
            flyHeight,
            seat.Position.Z + forward.Z
        )

        if selectedFarmMode == "Teleport" then
            seat.CFrame = CFrame.new(targetPos, targetPos + seat.CFrame.LookVector)
            task.wait(stepInterval)

        elseif selectedFarmMode == "Tween" then
            local tween = TweenService:Create(seat, TweenInfo.new(stepInterval, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(targetPos, targetPos + seat.CFrame.LookVector)
            })
            tween:Play()
            tween.Completed:Wait()
        end
    end
end

Tabs.Main:AddToggle("StraightFarmToggle", {
    Title = "Straight AutoFarm (Fly Forward)",
    Default = false,
    Callback = function(state)
        straightFarmEnabled = state
        print("Straight Autofarm toggled:", state)
        if state then
            task.spawn(straightAutoFarm)
        end
    end
})

local farmModeDropdown = Tabs.Main:AddDropdown("FarmMethod", {
    Title = "AutoFarm Method",
    Description = "Choose how the vehicle moves",
    Values = {"Teleport", "Tween"},
    Multi = false,
    Default = 1,
})

farmModeDropdown:OnChanged(function(Value)
    selectedFarmMode = Value
    print("Farm method set to:", Value)
end)

Tabs.Main:AddSlider("StepDistance", {
    Title = "Step Distance",
    Description = "Distance moved forward per step",
    Default = stepDistance,
    Min = 5,
    Max = 100,
    Rounding = 1,
    Callback = function(val)
        stepDistance = val
    end
})

Tabs.Main:AddSlider("StepInterval", {
    Title = "Step Interval",
    Description = "Time between each movement",
    Default = stepInterval,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(val)
        stepInterval = val
    end
})

Tabs.Main:AddSlider("FlyHeight", {
    Title = "Fly Height",
    Description = "Fixed Y position while flying",
    Default = flyHeight,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(val)
        flyHeight = val
    end
})
