local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Flare - Money Race",
    SubTitle = "Smarter. Better",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
local module_upvr = require(Modules:WaitForChild("Microtransactions"))
local LocalPlayer = game.Players.LocalPlayer
local VIPBarrier = workspace:WaitForChild("Lobby"):WaitForChild("VIPBarrier")
local Enabled_upvr_2 = LocalPlayer:WaitForChild("AutoRunData"):WaitForChild("Enabled")
local AutoRebirth = LocalPlayer:WaitForChild("Settings"):WaitForChild("AutoRebirth")

local function grantVIP()
    local success, err = pcall(function()
        LocalPlayer:SetAttribute("VIP", true)
    end)
    if success then
        print("VIP status granted!")
        VIPBarrier.Transparency = 1
        VIPBarrier.CanCollide = false
        VIPBarrier.CanTouch = false
        VIPBarrier.ZoneBarrier.Enabled = false
        VIPBarrier.Decal.Transparency = 1
    else
        warn("Failed to grant VIP status:", err)
    end
end

local function toggleAutoRun(value)
    Enabled_upvr_2.Value = value
    print("Auto Run toggled to", value)
end

local function toggleAutoRebirth(value)
    AutoRebirth.Value = value and "On" or "Off"
    print("Auto Rebirth toggled to", AutoRebirth.Value)
end

local function equipVehicle(vehicleName)
    local equipped = LocalPlayer.VehiclesData.Equipped
    if equipped and equipped:IsA("StringValue") then
        equipped.Value = vehicleName
        print("Equipped vehicle set to:", vehicleName)
    else
        warn("Equipped vehicle StringValue not found.")
    end
end

local function equipTrail(trailName)
    local equipped = LocalPlayer.TrailsData.Equipped
    if equipped and equipped:IsA("StringValue") then
        equipped.Value = trailName
        print("Equipped trail set to:", trailName)
    else
        warn("Equipped trail StringValue not found.")
    end
end

module_upvr.CheckIfOwnsGamepass = function(player, gamepass)
    if player == LocalPlayer and gamepass == "VIP" then
        return true
    end
    return false
end

Tabs.Main:AddButton({
    Title = "Grant VIP",
    Description = "Click to get VIP gamepass for free.",
    Callback = function()
        grantVIP()
    end
})

Tabs.Main:AddToggle("AutoRunToggle", {
    Title = "Auto Run",
    Default = false,
    Callback = function(value)
        toggleAutoRun(value)
    end
})

Tabs.Main:AddToggle("AutoRebirthToggle", {
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(value)
        toggleAutoRebirth(value)
    end
})

Tabs.Main:AddDropdown("VehicleDropdown", {
    Title = "Select Vehicle",
    Values = {
        "Army Truck",
        "Car",
        "Cloud",
        "Fighter Jet",
        "Forklift",
        "Golden Car",
        "Golf Cart",
        "Ice Cream Truck",
        "Motorcycle",
        "Pastry Kitty",
        "Police Car",
        "Rocket"
    },
    Default = "Car",
    Callback = function(value)
        equipVehicle(value)
    end
})

Tabs.Main:AddDropdown("TrailDropdown", {
    Title = "Select Trail",
    Values = {
        "Blue",
        "Blue & Pink",
        "Green",
        "Orange",
        "Orange & Pink",
        "Pink",
        "Purple",
        "Rainbow",
        "Red",
        "Red & Blue",
        "White",
        "Yellow"
    },
    Default = "Blue",
    Callback = function(value)
        equipTrail(value)
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FlareScriptHub")
SaveManager:SetFolder("FlareScriptHub/moneyrace")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Flare",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
