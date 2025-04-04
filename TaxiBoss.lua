-- Prevent Roblox Idle Kick
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Staff Auto-Kick System
task.spawn(function()
    local Players = game:GetService("Players")
    while true do
        for _, v in pairs(Players:GetPlayers()) do
            if v:GetRankInGroup(11987919) > 149 then
                game.Players.LocalPlayer:Kick("Auto Kicked: Staff Member " .. v.Name .. " joined.")
            end
        end
        task.wait(5)
    end
end)

game:GetService("LogService").MessageOut:Connect(function(msg, msgType)
    if msgType == Enum.MessageType.MessageError then
        print("[⚠️ FlameHub Detected Error]:", msg)
    end
end)

local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldKick = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if tostring(self) == "Kick" or method == "Kick" then
        warn("[FlameHub] Kick attempt intercepted!")
        return -- block the kick
    end
    return oldKick(self, ...)
end)


-- FlameHub - Taxi Boss | Fluent UI Edition
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FlameHub - Taxi Boss",
    SubTitle = "Made by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(680, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "grid" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Tabs.Main:AddToggle("AutoMoney", {
    Title = "Auto Money",
    Default = false,
    Description = "Farms contractBuildMaterial missions automatically."
}):OnChanged(function(state)
    getfenv().AutoMoney = state

    pcall(function()
        local quest = game:GetService("Players").LocalPlayer.ActiveQuests:FindFirstChildOfClass("StringValue")
        if quest then
            game:GetService("ReplicatedStorage").Quests.Contracts.CancelContract:InvokeServer(quest.Name)
            game:GetService("ReplicatedStorage").Quests.Contracts.CancelContract:InvokeServer(quest.Name)
        end
    end)

    task.spawn(function()
        while getfenv().AutoMoney do
            task.wait()

            local player = game:GetService("Players").LocalPlayer
            local activeQuests = player.ActiveQuests

            if not activeQuests:FindFirstChild("contractBuildMaterial") then
                game:GetService("ReplicatedStorage").Quests.Contracts.StartContract:InvokeServer("contractBuildMaterial")
                repeat task.wait() until activeQuests:FindFirstChild("contractBuildMaterial") or not getfenv().AutoMoney
            end

            repeat
                task.wait()
                task.spawn(function()
                    local r = game:GetService("ReplicatedStorage").Quests.DeliveryComplete
                    r:InvokeServer("contractMaterial")
                    r:InvokeServer("contractMaterial")
                    r:InvokeServer("contractMaterial")
                end)
            until activeQuests.contractBuildMaterial and activeQuests.contractBuildMaterial.Value == "!pw5pi3ps2" or not getfenv().AutoMoney

            if getfenv().AutoMoney then
                game:GetService("ReplicatedStorage").Quests.Contracts.CompleteContract:InvokeServer()
            end
        end
    end)
end)

Tabs.Main:AddToggle("AutoCustomers", {
    Title = "Auto Customers [Float Delivery]",
    Default = false,
    Description = "Stays flying during sky tween. Clean no-drop delivery."
}):OnChanged(function(state)
    getfenv().AutoCustomers = state

    local delivered = false

    task.spawn(function()
        while getfenv().AutoCustomers do
            task.wait(0.5)
            pcall(function()
                local player = game.Players.LocalPlayer
                local char = player.Character
                if not char then return end

                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local seat = humanoid and humanoid.SeatPart

                if not seat then
                    game.ReplicatedStorage.Vehicles.GetNearestSpot:InvokeServer(player.variables.carId.Value)
                    task.wait(0.5)
                    game.ReplicatedStorage.Vehicles.EnterVehicleEvent:InvokeServer()
                    return
                end

                local car = seat:FindFirstAncestorOfClass("Model")
                if not car then return end
                if not car.PrimaryPart then car.PrimaryPart = seat end

                -- Reset if not in mission
                if not player.variables.inMission.Value then
                    delivered = false

                    -- 🚕 Customer pickup
                    local best, dist = nil, math.huge
                    for _, v in pairs(workspace.NewCustomers:GetDescendants()) do
                        if v:IsA("Part") and v:GetAttribute("GroupSize")
                            and v:FindFirstChildOfClass("CFrameValue")
                            and player.variables.seatAmount.Value > v:GetAttribute("GroupSize")
                            and v:GetAttribute("Rating") < player.variables.vehicleRating.Value then

                            local d = (v.Position - char.HumanoidRootPart.Position).Magnitude
                            if d < dist then
                                best = v
                                dist = d
                            end
                        end
                    end

                    if best then
                        print("[FlameHub] Teleporting to customer.")
                        car:PivotTo(best.CFrame + Vector3.new(0, 3, 0))
                        task.wait(1)
                        local prompt = best:FindFirstChild("Client") and best.Client:FindFirstChild("PromptPart")
                        if prompt and prompt:FindFirstChild("CustomerPrompt") then
                            fireproximityprompt(prompt.CustomerPrompt)
                        end
                    end

                -- 🚀 Delivery with full air-lock (no falling)
                elseif player.variables.inMission.Value and not delivered then
                    delivered = true

                    local destination = workspace:FindFirstChild("ParkingMarkers") and workspace.ParkingMarkers:FindFirstChild("destinationPart")
                    if not destination then
                        char:PivotTo(CFrame.new(0, 500, 0))
                        for _ = 1, 30 do
                            destination = workspace:FindFirstChild("ParkingMarkers") and workspace.ParkingMarkers:FindFirstChild("destinationPart")
                            if destination then break end
                            task.wait(0.3)
                        end
                        if not destination then
                            print("[FlameHub] destinationPart never appeared")
                            return
                        end
                    end

                    local TweenService = game:GetService("TweenService")

                    -- Positions
                    local upHeight = 300
                    local current = car.PrimaryPart.Position
                    local dest = destination.Position + Vector3.new(0, 3, 0)

                    local skyUp = current + Vector3.new(0, upHeight, 0)
                    local skyAcross = Vector3.new(dest.X, skyUp.Y, dest.Z)
                    local landing = dest

                    -- 🛑 Lock the car in air
                    car.PrimaryPart.Anchored = true

                    -- Tween helper
                    local function tweenCar(pos, time)
                        local dummy = Instance.new("Part")
                        dummy.Anchored = true
                        dummy.Transparency = 1
                        dummy.CanCollide = false
                        dummy.CFrame = car:GetPrimaryPartCFrame()
                        dummy.Parent = workspace

                        local tween = TweenService:Create(dummy, TweenInfo.new(time or 1.2, Enum.EasingStyle.Quad), {
                            CFrame = CFrame.new(pos)
                        })

                        tween:Play()
                        tween.Completed:Wait()
                        car:PivotTo(dummy.CFrame)
                        dummy:Destroy()
                        task.wait(0.2)
                    end

                    -- Tween steps
                    tweenCar(skyUp, 1)
                    tweenCar(skyAcross, 1.6)
                    tweenCar(landing, 1)

                    -- 🔓 Unlock the car
                    car.PrimaryPart.Anchored = false

                    -- Simulate drop-off
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, 304, false, game)
                    task.wait(0.3)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, 304, false, game)

                    Fluent:Notify({
                        Title = "FlameHub",
                        Content = "Delivered smooth. No drop. ✅",
                        Duration = 2
                    })

                    print("[FlameHub] ✅ Clean delivery complete.")
                end
            end)
        end
    end)
end)





Tabs.Main:AddToggle("AutoUpgrade", {
    Title = "Auto Upgrade Office",
    Default = false,
    Description = "Automatically upgrades your company office."
}):OnChanged(function(state)
    getfenv().AutoUpgrade = state

    task.spawn(function()
        while getfenv().AutoUpgrade do
            task.wait(1)
            local player = game.Players.LocalPlayer

            if not player:FindFirstChild("Office") then
                game.ReplicatedStorage.Company.StartOffice:InvokeServer()
                task.wait(0.2)
            end

            local office = player:FindFirstChild("Office")
            if office and office:GetAttribute("level") < 16 then
                game.ReplicatedStorage.Company.SkipOfficeQuest:InvokeServer()
                game.ReplicatedStorage.Company.UpgradeOffice:InvokeServer()
                print("[FlameHub] Office upgraded.")
            end
        end
    end)
end)


local TeleportDropdown = Tabs.Teleports:AddDropdown("TeleportLocation", {
    Title = "Teleport Location",
    Values = {}, -- placeholder, filled below
    Multi = false,
    Default = nil,
})

-- Fill in locations
local locations = {
    "Beechwood", "Beechwood Beach", "Boss Airport", "Bridgeview", "Cedar Side",
    "Central Bank", "Central City", "City Park", "Coconut Park", "Country Club",
    "Da Hills", "Doge Harbor", "Gas Station", "Gas Station 2", "Harborview",
    "Hawthorn Park", "Hospital", "Industrial District", "Logistic District",
    "Master Hotel", "Military Base", "Noll Cliffs", "Nuclear Power Plant",
    "OFF ROAD Test Track", "Ocean Viewpoint", "Oil Refinery", "Old Town",
    "Popular Street", "Small Town", "St. Noll Viewpoint", "Sunny Elementary",
    "Sunset Grove", "Taxi Central", "high school", "mall", "the beach", "🏆 Race Club"
}

TeleportDropdown:SetValues(locations)

TeleportDropdown:OnChanged(function(selection)
    local chr = game.Players.LocalPlayer.Character
    local hum = chr and chr:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    local offset = Vector3.new(0, 40, 0)

    local cframe
    pcall(function()
        local target = game:GetService("ReplicatedStorage").Places[selection]
        if target then
            cframe = target.CFrame or CFrame.new(target.Position)
        elseif selection == "Boss Airport" then
            cframe = CFrame.new(-637.13, 38.99, 4325.22)
        elseif selection == "Bridgeview" then
            cframe = CFrame.new(1354.46, 10.3, 1278.8)
        elseif selection == "Da Hills" then
            cframe = CFrame.new(2348.34, 73.1, -1537.31)
        elseif selection == "Doge Harbor" then
            cframe = CFrame.new(3335.73, 24.95, 2773.03)
        elseif selection == "Gas Station" then
            cframe = CFrame.new(103.7, 0, -640.6)
        elseif selection == "Gas Station 2" then
            cframe = CFrame.new(930.7, 0, 643.4)
        elseif selection == "Logistic District" then
            cframe = CFrame.new(588.28, 53.57, 2529.95)
        elseif selection == "Master Hotel" then
            cframe = CFrame.new(2736.15, 15.86, -202.09)
        end
    end)

    if not cframe then return end

    if seat then
        seat.Parent.Parent:PivotTo(cframe + offset)
    else
        chr:PivotTo(cframe + offset)
    end
end)

