local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FeatherHub - Bowling Simulator " .. Fluent.Version,
    SubTitle = "by Aura/Flames",
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

Tabs.Main:AddParagraph({
    Title = "Welcome to FeatherHub",
    Content = "This script is designed for Bowling Simulator. Automate actions like farming infinite wins :D, auto rebirthing wow :3, inf leg strenght :>, auto click for lazy people, and even selecting any trails for free :O."
})

Tabs.Main:AddParagraph({
    Title = "Discord Server Coming Soon",
    Content = ""
})

local Options = Fluent.Options
local toggleActive = false

local Toggle = Tabs.Main:AddToggle("AutoFarmToggle", { Title = "Auto Farm Wins", Default = false })

Toggle:OnChanged(function()
    toggleActive = Options.AutoFarmToggle.Value
    if toggleActive then
        print("Auto Farm activated")
        task.spawn(function()
            while toggleActive do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("GameService"):WaitForChild("RE"):WaitForChild("GetPKMoney"):FireServer()
                wait(0.1)
            end
        end)
    else
        print("Auto Farm deactivated")
    end
end)

local rebirthToggleActive = false
local RebirthToggle = Tabs.Main:AddToggle("AutoRebirthToggle", { Title = "Auto Rebirth", Default = false })

RebirthToggle:OnChanged(function()
    rebirthToggleActive = Options.AutoRebirthToggle.Value
    if rebirthToggleActive then
        print("Auto Rebirth activated")
        task.spawn(function()
            while rebirthToggleActive do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("PlayerRebirth"):InvokeServer()
                wait(0.1)
            end
        end)
    else
        print("Auto Rebirth deactivated")
    end
end)

local legStrengthToggleActive = false
local LegStrengthToggle = Tabs.Main:AddToggle("AutoLegStrengthToggle", { Title = "Auto Leg Strength", Default = false })

LegStrengthToggle:OnChanged(function()
    legStrengthToggleActive = Options.AutoLegStrengthToggle.Value
    if legStrengthToggleActive then
        print("Auto Leg Strength activated")
        task.spawn(function()
            while legStrengthToggleActive do
                local args = {
                    [1] = 100
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("TrainService"):WaitForChild("RF"):WaitForChild("PlayerExercise"):InvokeServer(unpack(args))
                wait(0.1)
            end
        end)
    else
        print("Auto Leg Strength deactivated")
    end
end)

local autoClickToggleActive = false
local AutoClickToggle = Tabs.Main:AddToggle("AutoClickToggle", { Title = "Auto Click", Default = false })

AutoClickToggle:OnChanged(function()
    autoClickToggleActive = Options.AutoClickToggle.Value
    if autoClickToggleActive then
        print("Auto Click activated")
        task.spawn(function()
            while autoClickToggleActive do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ClickService"):WaitForChild("RF"):WaitForChild("Click"):InvokeServer()
                wait(0.1)
            end
        end)
    else
        print("Auto Click deactivated")
    end
end)

local TrailsDropdown = Tabs.Main:AddDropdown("TrailSelector", {
    Title = "Select Trail",
    Values = {
        "base", "green", "star", "blue", "yellow", "catpaw",
        "pink", "blue-purple", "rainbow-star", "pink-blue", "rainbow",
        "diamond", "energy"
    },
    Multi = false,
    Default = "base"
})

TrailsDropdown:OnChanged(function(value)
    print("Selected Trail:", value)
    local trailMap = {
        base = 1, green = 2, star = 3, blue = 4,
        yellow = 5, catpaw = 6, pink = 7, blue_purple = 8,
        rainbow_star = 9, pink_blue = 10, rainbow = 11,
        diamond = 12, energy = 13
    }
    local trailID = trailMap[value]
    if trailID then
        local args = {
            [1] = tostring(trailID)
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("TrailService"):WaitForChild("RF"):WaitForChild("EquipTrail"):InvokeServer(unpack(args))
        print("Trail equipped:", value)
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FeatherHub")
SaveManager:SetFolder("FeatherHub/BowlingSimulator")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "FeatherHub",
    Content = "Script loaded successfully!",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
