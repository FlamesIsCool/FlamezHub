local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Home Run Simulator - Flare" .. Fluent.Version,
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local scriptRunning = false

local function startFirstScript()
    scriptRunning = true
    task.spawn(function()
        while scriptRunning do
            local function getNil(name, class)
                for _, v in next, getnilinstances() do
                    if v.ClassName == class and v.Name == name then
                        return v
                    end
                end
            end

            local args = {
                [1] = getNil("Animation", "AnimationTrack")
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Throw"):FireServer(unpack(args))

            wait(0.1)
        end
    end)
end

local function startSecondScript()
    scriptRunning = true
    task.spawn(function()
        while scriptRunning do
            game:GetService("ReplicatedStorage"):WaitForChild("GemClaim"):FireServer()
            wait(0.1)
        end
    end)
end

local function startThirdScript()
    scriptRunning = true
    task.spawn(function()
        while scriptRunning do
            for i = 1, 20 do
                local args = {
                    [1] = i
                }

                game:GetService("ReplicatedStorage"):WaitForChild("BuyBat"):FireServer(unpack(args))
                wait(0.1)
            end
        end
    end)
end

local function startFourthScript()
    scriptRunning = true
    task.spawn(function()
        while scriptRunning do
            local args = {
                [1] = 2
            }

            game:GetService("ReplicatedStorage"):WaitForChild("BuyBall"):FireServer(unpack(args))
            wait(0.1)
        end
    end)
end

local function stopScripts()
    scriptRunning = false
end

Tabs.Main:AddParagraph({
    Title = "Thanks for using This Script!",
    Content = "You can join my discord and i'll be making more OP scripts like this ;) scripts to inf coins and shit lol but for now engoy peace"
})

local Toggle1 = Tabs.Main:AddToggle("FirstScriptToggle", {
    Title = "Generate Coins 🤑",
    Default = false
})

Toggle1:OnChanged(function()
    if Options.FirstScriptToggle.Value then
        startFirstScript()
    else
        stopScripts()
    end
end)

local Toggle2 = Tabs.Main:AddToggle("SecondScriptToggle", {
    Title = "Generate Gems 💎🤑",
    Default = false
})

Toggle2:OnChanged(function()
    if Options.SecondScriptToggle.Value then
        startSecondScript()
    else
        stopScripts()
    end
end)

local Toggle3 = Tabs.Main:AddToggle("ThirdScriptToggle", {
    Title = "Auto Buy Bats 🥍",
    Default = false
})

Toggle3:OnChanged(function()
    if Options.ThirdScriptToggle.Value then
        startThirdScript()
    else
        stopScripts()
    end
end)

local Toggle4 = Tabs.Main:AddToggle("FourthScriptToggle", {
    Title = "Auto Buy Balls ⚾️",
    Default = false
})

Toggle4:OnChanged(function()
    if Options.FourthScriptToggle.Value then
        startFourthScript()
    else
        stopScripts()
    end
end)

Tabs.Main:AddButton({
    Title = "Join Our Discord!",
    Description = "Click here to join our community Discord server.",
    Callback = function()
        local DiscordInvite = "https://discord.com/invite/qunH6yNeAF"
        setclipboard(DiscordInvite)
        Fluent:Notify({
            Title = "Discord Invite",
            Content = "The invite link has been copied to your clipboard. Paste it into your browser to join!",
            Duration = 10
        })
    end
})


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FlareScriptHub")
SaveManager:SetFolder("FlareScriptHub/HomeRunSimulator")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Flare",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
