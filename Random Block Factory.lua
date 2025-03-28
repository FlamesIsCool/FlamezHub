local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Random Block Factory " .. Fluent.Version,
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(680, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


Tabs.Main:AddButton({
    Title = "Give Infinite Diamonds",
    Description = "Adds an unlimited amount of diamonds instantly",
    Callback = function()
        local args = {
            [1] = math.huge
        }

        game:GetService("ReplicatedStorage")
            :WaitForChild("rbxts_include")
            :WaitForChild("node_modules")
            :WaitForChild("@rbxts")
            :WaitForChild("remo")
            :WaitForChild("src")
            :WaitForChild("container")
            :WaitForChild("collect.diamonds")
            :FireServer(unpack(args))

        Fluent:Notify({
            Title = "Diamonds",
            Content = "Attempted to give infinite diamonds!",
            Duration = 5
        })
    end
})

local selectedEgg = "Nature"
local autoOpenEgg = false

local EggDropdown = Tabs.Main:AddDropdown("EggDropdown", {
    Title = "Select Egg",
    Values = { "Nature", "Sea", "Pumpkin", "Yeti" },
    Multi = false,
    Default = "Nature"
})

EggDropdown:OnChanged(function(Value)
    selectedEgg = Value
    Fluent:Notify({
        Title = "Egg Selected",
        Content = "Selected: " .. selectedEgg,
        Duration = 3
    })
end)

local EggToggle = Tabs.Main:AddToggle("AutoEggToggle", {
    Title = "Auto Open Egg",
    Description = "Automatically hatches the selected egg",
    Default = false
})

EggToggle:OnChanged(function(Value)
    autoOpenEgg = Value

    if autoOpenEgg then
        Fluent:Notify({
            Title = "Auto Opening",
            Content = "Auto egg opening started!",
            Duration = 3
        })

        task.spawn(function()
            while autoOpenEgg and not Fluent.Unloaded do
                local args = {
                    [1] = selectedEgg,
                    [2] = 1
                }

                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("rbxts_include")
                        :WaitForChild("node_modules")
                        :WaitForChild("@rbxts")
                        :WaitForChild("remo")
                        :WaitForChild("src")
                        :WaitForChild("container")
                        :WaitForChild("eggs.purchase")
                        :InvokeServer(unpack(args))
                end)

                task.wait(0.1)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Opening",
            Content = "Auto egg opening stopped.",
            Duration = 3
        })
    end
end)

local autoUpgrade = false

local UpgradeToggle = Tabs.Main:AddToggle("AutoUpgradeToggle", {
    Title = "Auto Upgrade",
    Description = "Upgrades your processor continuously",
    Default = false
})

UpgradeToggle:OnChanged(function(Value)
    autoUpgrade = Value

    if autoUpgrade then
        Fluent:Notify({
            Title = "Auto Upgrade",
            Content = "Auto upgrade started!",
            Duration = 3
        })

        task.spawn(function()
            while autoUpgrade and not Fluent.Unloaded do
                local args = {
                    [1] = 0
                }

                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("rbxts_include")
                        :WaitForChild("node_modules")
                        :WaitForChild("@rbxts")
                        :WaitForChild("remo")
                        :WaitForChild("src")
                        :WaitForChild("container")
                        :WaitForChild("processor.upgrade")
                        :InvokeServer(unpack(args))
                end)

                task.wait(1)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Upgrade",
            Content = "Auto upgrade stopped.",
            Duration = 3
        })
    end
end)

local autoSell = false

local SellToggle = Tabs.Main:AddToggle("AutoSellToggle", {
    Title = "Auto Sell",
    Description = "Sells blocks automatically",
    Default = false
})

SellToggle:OnChanged(function(Value)
    autoSell = Value

    if autoSell then
        Fluent:Notify({
            Title = "Auto Sell",
            Content = "Auto selling started!",
            Duration = 3
        })

        task.spawn(function()
            while autoSell and not Fluent.Unloaded do
                local args = {
                    [1] = 0
                }

                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("rbxts_include")
                        :WaitForChild("node_modules")
                        :WaitForChild("@rbxts")
                        :WaitForChild("remo")
                        :WaitForChild("src")
                        :WaitForChild("container")
                        :WaitForChild("processor.process")
                        :InvokeServer(unpack(args))
                end)

                task.wait(1)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Sell",
            Content = "Auto selling stopped.",
            Duration = 3
        })
    end
end)

local autoCollect = false

local CollectToggle = Tabs.Main:AddToggle("AutoCollectToggle", {
    Title = "Auto Collect Blocks",
    Description = "Teleports you to each block in the map",
    Default = false
})

CollectToggle:OnChanged(function(Value)
    autoCollect = Value

    if autoCollect then
        Fluent:Notify({
            Title = "Auto Collect",
            Content = "Block collecting started!",
            Duration = 3
        })

        task.spawn(function()
            while autoCollect and not Fluent.Unloaded do
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()

                for _, drop in ipairs(workspace:GetChildren()) do
                    if drop:IsA("Model") and drop.Name == "Drop" then
                        local primary = drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            character:PivotTo(CFrame.new(primary.Position + Vector3.new(0, 3, 0)))
                            task.wait(0.3)
                        end
                    end
                end

                task.wait(0.5)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Collect",
            Content = "Block collecting stopped.",
            Duration = 3
        })
    end
end)

local autoRebirth = false

local RebirthToggle = Tabs.Main:AddToggle("AutoRebirthToggle", {
    Title = "Auto Rebirth",
    Description = "Automatically rebirths when possible",
    Default = false
})

RebirthToggle:OnChanged(function(Value)
    autoRebirth = Value

    if autoRebirth then
        Fluent:Notify({
            Title = "Auto Rebirth",
            Content = "Rebirthing started!",
            Duration = 3
        })

        task.spawn(function()
            while autoRebirth and not Fluent.Unloaded do
                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("rbxts_include")
                        :WaitForChild("node_modules")
                        :WaitForChild("@rbxts")
                        :WaitForChild("remo")
                        :WaitForChild("src")
                        :WaitForChild("container")
                        :WaitForChild("rebirth")
                        :InvokeServer()
                end)

                task.wait(2)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Rebirth",
            Content = "Rebirthing stopped.",
            Duration = 3
        })
    end
end)

local autoClaimGifts = false

local ClaimGiftsToggle = Tabs.Main:AddToggle("AutoClaimGiftsToggle", {
    Title = "Auto Claim Gifts",
    Description = "Automatically claims all available playtime gifts",
    Default = false
})

ClaimGiftsToggle:OnChanged(function(Value)
    autoClaimGifts = Value

    if autoClaimGifts then
        Fluent:Notify({
            Title = "Auto Claim Gifts",
            Content = "Gift claiming started!",
            Duration = 3
        })

        task.spawn(function()
            while autoClaimGifts and not Fluent.Unloaded do
                for giftId = 1, 12 do
                    local args = {
                        [1] = tostring(giftId)
                    }

                    pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("rbxts_include")
                            :WaitForChild("node_modules")
                            :WaitForChild("@rbxts")
                            :WaitForChild("remo")
                            :WaitForChild("src")
                            :WaitForChild("container")
                            :WaitForChild("playtime.claim")
                            :InvokeServer(unpack(args))
                    end)

                    task.wait(0.25)
                end

                task.wait(10)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Claim Gifts",
            Content = "Gift claiming stopped.",
            Duration = 3
        })
    end
end)

local autoSpin = false

local SpinToggle = Tabs.Main:AddToggle("AutoSpinToggle", {
    Title = "Auto Spin Wheel",
    Description = "Spins the daily wheel automatically",
    Default = false
})

SpinToggle:OnChanged(function(Value)
    autoSpin = Value

    if autoSpin then
        Fluent:Notify({
            Title = "Auto Spin",
            Content = "Spinning started!",
            Duration = 3
        })

        task.spawn(function()
            while autoSpin and not Fluent.Unloaded do
                local args = {
                    [1] = 1
                }

                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("rbxts_include")
                        :WaitForChild("node_modules")
                        :WaitForChild("@rbxts")
                        :WaitForChild("remo")
                        :WaitForChild("src")
                        :WaitForChild("container")
                        :WaitForChild("wheel.spin")
                        :InvokeServer(unpack(args))
                end)

                task.wait(1)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Spin",
            Content = "Spinning stopped.",
            Duration = 3
        })
    end
end)

local autoUpgradeGenerator = false

local GeneratorToggle = Tabs.Main:AddToggle("AutoUpgradeGeneratorToggle", {
    Title = "Auto Upgrade Generator",
    Description = "Automatically purchases all available generator upgrades",
    Default = false
})

GeneratorToggle:OnChanged(function(Value)
    autoUpgradeGenerator = Value

    if autoUpgradeGenerator then
        Fluent:Notify({
            Title = "Auto Generator",
            Content = "Generator upgrades started!",
            Duration = 3
        })

        task.spawn(function()
            while autoUpgradeGenerator and not Fluent.Unloaded do
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")

                local tycoonName = "Tycoon-" .. player.UserId
                local myTycoon = workspace:FindFirstChild(tycoonName)

                if myTycoon then
                    local upgrades = myTycoon:FindFirstChild("Zones")
                        and myTycoon.Zones:FindFirstChild("0")
                        and myTycoon.Zones["0"]:FindFirstChild("Upgrades")

                    if upgrades then
                        for _, obj in ipairs(upgrades:GetDescendants()) do
                            if obj:IsA("Model") and obj.Name == "button" then
                                local part = obj:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    for _, child in ipairs(part:GetChildren()) do
                                        if child:IsA("TouchTransmitter") then
                                            firetouchinterest(root, part, 0)
                                            firetouchinterest(root, part, 1)
                                            task.wait(0.05)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                task.wait(2)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Generator",
            Content = "Generator upgrades stopped.",
            Duration = 3
        })
    end
end)



-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("Flame")
SaveManager:SetFolder("Flame/RandomBlockFactory")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Flame",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
