local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Key System",
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Key System", Icon = "key" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Welcome!",
    Content = "Please complete the linkvertise process to join our Discord!",
    Duration = 5
})

local KeySection = Tabs.Main:AddSection("Key System")

KeySection:AddParagraph({
    Title = "🔑 How to Get the Script",
    Content = "Click the button below to copy the linkvertise link to your clipboard. Paste it in your browser, complete the process, and you will be invited to our Discord where the script is located."
})

KeySection:AddButton({
    Title = "📋 Copy Linkvertise Link",
    Description = "Click to copy the linkvertise link to your clipboard.",
    Callback = function()
        setclipboard("https://linkunlocker.com/unlock-exclusive-access-join-our-community-now-NKcfZ")
        Fluent:Notify({
            Title = "Copied!",
            Content = "The linkvertise link has been copied to your clipboard.",
            Duration = 3
        })
    end
})

KeySection:AddParagraph({
    Title = "📜 Instructions",
    Content = "After completing the linkvertise process, you will be redirected to our Discord server where you can get the script."
})

local InterfaceSection = Tabs.Settings:AddSection("Interface")

InterfaceSection:AddToggle("DarkModeToggle", {
    Title = "🌙 Dark Mode",
    Default = true,
    Callback = function(State)
        Fluent:SetTheme(State and "Darker" or "Light")
        Fluent:Notify({
            Title = "Theme Updated",
            Content = State and "Dark mode enabled." or "Light mode enabled.",
            Duration = 3
        })
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("SwirlHub/KeySystem")
InterfaceManager:SetFolder("SwirlHub/KeySystem")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "SwirlHub",
    Content = "Key system loaded successfully!",
    Duration = 5
})
