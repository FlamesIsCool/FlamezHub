local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Get Big Simulator",
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Fluent:Notify({
    Title = "🚀 Script Loaded",
    Content = "Enjoy exploiting!",
    Duration = 8
})

local WalkSpeedToggle = Tabs.Main:AddToggle("WalkSpeedToggle", { Title = "WalkSpeed ⚡", Default = false })

WalkSpeedToggle:OnChanged(function(value)
    if value then
        task.spawn(function()
            while WalkSpeedToggle.Value do
                local args = {
                    [1] = 29,
                    [2] = game:GetService("Players").LocalPlayer.Character.Humanoid,
                    [3] = 250
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateSpeed"):FireServer(unpack(args))
                wait(0)
            end
        end)
        Fluent:Notify({ Title = "✅ Enabled", Content = "WalkSpeed set to 250!", Duration = 4 })
    else
        Fluent:Notify({ Title = "❌ Disabled", Content = "WalkSpeed toggle turned off!", Duration = 4 })
    end
end)

Tabs.Main:AddButton({
    Title = "Max Strength 💪",
    Description = "Gives you unlimited strength instantly",
    Callback = function()
        local args = { [1] = 999999999999999999 }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateStrength"):FireServer(unpack(args))
        Fluent:Notify({ Title = "✅ Success", Content = "Max strength applied!", Duration = 4 })
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("SwirlHub/sgetbigsimulator")
InterfaceManager:SetFolder("SwirlHub")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

Fluent:Notify({
    Title = "SwirlHub",
    Content = "Script successfully loaded!",
    Duration = 8
})
