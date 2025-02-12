local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Skibidi",
    SubTitle = "Made with Flames",
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

Tabs.Main:AddButton({
    Title = "Teleport Parts 🏃‍♂️",
    Description = "Moves all orbs to you",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hrp then
            local folder = workspace:FindFirstChild("NyamNyamas")
            if folder then
                for _, part in ipairs(folder:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Position = hrp.Position + Vector3.new(math.random(-2, 2), 3, math.random(-2, 2))
                    end
                end
                Fluent:Notify({ Title = "✅ Success", Content = "Parts teleported!", Duration = 4 })
            else
                Fluent:Notify({ Title = "❌ Error", Content = "Folder 'NyamNyamas' not found!", Duration = 4 })
            end
        else
            Fluent:Notify({ Title = "❌ Error", Content = "Could not find your character!", Duration = 4 })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Get Infinite Coins 💰",
    Description = "Gives you an insane amount of coins",
    Callback = function()
        local args = {
            [1] = "coins",
            [2] = "999999999999999999999999999999"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteDataStore2Editor"):FireServer(unpack(args))
        Fluent:Notify({ Title = "✅ Success", Content = "Infinite coins added!", Duration = 4 })
    end
})

local AutoSize = Tabs.Main:AddToggle("AutoSize", { Title = "Auto Size 📏", Default = false })

AutoSize:OnChanged(function(value)
    if value then
        task.spawn(function()
            while AutoSize.Value do
                local args = {
                    [1] = "size",
                    [2] = 500
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteDataStore2Editor"):FireServer(unpack(args))
                wait(0.1)
            end
        end)
        Fluent:Notify({ Title = "✅ Enabled", Content = "Auto Size is active!", Duration = 4 })
    else
        Fluent:Notify({ Title = "❌ Disabled", Content = "Auto Size turned off!", Duration = 4 })
    end
end)

local Skins = {
    "SkibidiCamera", "SkibidiScout", "SkibidiWarrior", "AngelicSkibidi", "InvisibleSkibidi", "SkibidiScientist"
}
local SkinDropdown = Tabs.Main:AddDropdown("SkinSelect", {
    Title = "Select Skin 🎭",
    Values = Skins,
    Multi = false,
    Default = "SkibidiCamera"
})

SkinDropdown:OnChanged(function(value)
    local args = { [1] = value }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteSkinChanger"):FireServer(unpack(args))
    Fluent:Notify({ Title = "✅ Success", Content = "Skin changed to " .. value .. "!", Duration = 4 })
end)

local AutoBarrier = Tabs.Main:AddToggle("AutoBarrier", { Title = "Auto Barrier 🔥", Default = false })

AutoBarrier:OnChanged(function(value)
    local args = { [1] = value }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteBarrierEvent"):FireServer(unpack(args))
    if value then
        Fluent:Notify({ Title = "✅ Enabled", Content = "Barrier is now ON!", Duration = 4 })
    else
        Fluent:Notify({ Title = "❌ Disabled", Content = "Barrier is now OFF!", Duration = 4 })
    end
end)

local WalkSpeedSlider = Tabs.Main:AddSlider("WalkSpeed", {
    Title = "WalkSpeed 🚀",
    Description = "Adjust your movement speed",
    Default = 16, 
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
})

WalkSpeedSlider:OnChanged(function(Value)
    print("WalkSpeed set to:", Value)
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("SwirlHub/skibidi")
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
