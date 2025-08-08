local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Your Actual Keyboard",
    SubTitle = "by Flames/Aura",
    TabWidth = 160,
    Size = UDim2.fromOffset(420, 320),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "keyboard" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local loopKeys = false
local loopMachine = false

Tabs.Main:AddToggle("LoopKeys", {
    Title = "Press all keys",
    Description = "Clicks all the keys on the keyboard",
    Default = false
}):OnChanged(function(Value)
    loopKeys = Value
end)

Tabs.Main:AddToggle("LoopClickingMachine", {
    Title = "Spam ClickingMachine",
    Description = "Spams the ClickingMachine",
    Default = false
}):OnChanged(function(Value)
    loopMachine = Value
end)

task.spawn(function()
    while true do
        -- Keys loop
        if loopKeys then
            local keysFolder = workspace:FindFirstChild("Computer") and workspace.Computer:FindFirstChild("Default") and workspace.Computer.Default:FindFirstChild("Keys")
            if keysFolder then
                for _, obj in ipairs(keysFolder:GetDescendants()) do
                    if obj:IsA("ClickDetector") and obj.Parent and obj.Parent:IsA("BasePart") then
                        pcall(fireclickdetector, obj)
                    end
                end
            end
        end

        if loopMachine then
            local clickDetector = workspace:FindFirstChild("ClickingMachine") 
                and workspace.ClickingMachine:FindFirstChild("Button") 
                and workspace.ClickingMachine.Button:FindFirstChild("ClickingMachine") 
                and workspace.ClickingMachine.Button.ClickingMachine:FindFirstChild("ClickDetector")

            if clickDetector and clickDetector:IsA("ClickDetector") then
                pcall(fireclickdetector, clickDetector)
            end
        end

        task.wait(0.1)
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/YourActualKeyboard")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Your Actual Keyboard",
    Content = "Script loaded successfully!",
    Duration = 6
})

SaveManager:LoadAutoloadConfig()
