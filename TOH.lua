local player = game.Players.LocalPlayer
local username = player.Name
local displayName = player.DisplayName
local userId = player.UserId
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local gameId = game.PlaceId
local jobId = game.JobId
local playerCount = #game.Players:GetPlayers()

loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/discordjoin.lua"))()
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title       = "SwirlHub - Tower Of Hell " .. Fluent.Version,
    SubTitle    = "🔥 by Flames",
    TabWidth    = 170,
    Size        = UDim2.fromOffset(620, 500),
    Acrylic     = true,
    Theme       = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local function enableGodmode()
    for _, v in pairs(player.Character:GetChildren()) do
        if v:IsA("Part") then
            local fb = v:FindFirstChild("TouchInterest")
            if fb then
                fb:Destroy()
            end
        end
    end
    warn("⚡ Godmode ready. Resets auto-reload it.")

    player.CharacterAdded:Connect(function(char)
        repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("Part") then
                local fb = part:FindFirstChild("TouchInterest")
                if fb then
                    fb:Destroy()
                end
            end
        end
        warn("⚡ Godmode auto-reloaded upon respawn.")
    end)
end

local function giveAllTools()
    local gearsFolder = game.ReplicatedStorage:FindFirstChild("Gear")
    if gearsFolder then
        for _, tool in pairs(gearsFolder:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Clone().Parent = player.Backpack
            end
        end
        warn("🎁 All tools added to your character.")
    else
        warn("⚠️ Gear folder not found in ReplicatedStorage.")
    end
end

local function setGlobalJumps(value)
    local globalJumps = game.ReplicatedStorage:FindFirstChild("globalJumps")
    if globalJumps and globalJumps:IsA("IntValue") then
        globalJumps.Value = value
        warn("🔼 globalJumps set to " .. value)
    else
        warn("⚠️ globalJumps IntValue not found in ReplicatedStorage.")
    end
end

local function setGlobalSpeed(value)
    local globalSpeed = game.ReplicatedStorage:FindFirstChild("globalSpeed")
    if globalSpeed and globalSpeed:IsA("NumberValue") then
        globalSpeed.Value = value
        warn("💨 globalSpeed set to " .. value)
    else
        warn("⚠️ globalSpeed NumberValue not found in ReplicatedStorage.")
    end
end

local function removeKillParts()
    local count = 0
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name:lower() == "kill" or part.Name:lower() == "killpart") then
            part:Destroy()
            count += 1
        end
    end
    warn("❌ Removed " .. count .. " parts named 'kill' or 'killPart'.")
end

local function teleportToFinish()
    local character = player.Character or player.CharacterAdded:Wait()
    local tower = workspace:FindFirstChild("tower")
    local finishGlow = tower 
        and tower.sections:FindFirstChild("finish") 
        and tower.sections.finish:FindFirstChild("FinishGlow")

    if finishGlow and character then
        local finishPosition = finishGlow.CFrame * CFrame.new(0, -5, 0)
        character.HumanoidRootPart.CFrame = finishPosition
        warn("✅ Teleported to finish!")
    else
        warn("⚠️ FinishGlow or character not found.")
    end
end

Tabs.Main:AddButton({
    Title       = "🛡️ Activate Godmode",
    Description = "Enable godmode for your character",
    Callback    = function()
        Window:Dialog({
            Title   = "🛡️ Activate Godmode",
            Content = "Are you sure you want to activate godmode?",
            Buttons = {
                {
                    Title    = "Confirm",
                    Callback = function()
                        enableGodmode()
                        print("Godmode activated.")
                    end
                },
                {
                    Title    = "Cancel",
                    Callback = function()
                        print("Godmode activation cancelled.")
                    end
                }
            }
        })
    end
})

Tabs.Main:AddButton({
    Title       = "❌ Remove All Kill Parts",
    Description = "Remove all parts named 'Kill' from the entire Workspace",
    Callback    = function()
        Window:Dialog({
            Title   = "❌ Remove Kill Parts",
            Content = "Are you sure you want to remove all 'Kill' parts?",
            Buttons = {
                {
                    Title    = "Confirm",
                    Callback = function()
                        removeKillParts()
                        print("All 'Kill' parts removed.")
                    end
                },
                {
                    Title    = "Cancel",
                    Callback = function()
                        print("Removal cancelled.")
                    end
                }
            }
        })
    end
})

Tabs.Main:AddButton({
    Title       = "🎁 Give All Tools",
    Description = "Give all tools from the Gear folder to your character",
    Callback    = function()
        Window:Dialog({
            Title   = "🎁 Give All Tools",
            Content = "Are you sure you want to give all tools?",
            Buttons = {
                {
                    Title    = "Confirm",
                    Callback = function()
                        giveAllTools()
                        print("All tools given to character.")
                    end
                },
                {
                    Title    = "Cancel",
                    Callback = function()
                        print("Tool giving cancelled.")
                    end
                }
            }
        })
    end
})

Tabs.Main:AddButton({
    Title       = "🏆 Teleport to Finish",
    Description = "Teleport directly to the finish line near the roof",
    Callback    = function()
        Window:Dialog({
            Title   = "🏆 Teleport to Finish",
            Content = "Are you sure you want to teleport to finish?",
            Buttons = {
                {
                    Title    = "Confirm",
                    Callback = function()
                        teleportToFinish()
                        print("Teleported to finish.")
                    end
                },
                {
                    Title    = "Cancel",
                    Callback = function()
                        print("Teleportation cancelled.")
                    end
                }
            }
        })
    end
})

local GlobalJumpsToggle = Tabs.Main:AddToggle("GlobalJumpsToggle", {
    Title   = "🔝 Infinite Jump",
    Default = false
})
GlobalJumpsToggle:OnChanged(function()
    if Options.GlobalJumpsToggle.Value then
        setGlobalJumps(999)
    else
        setGlobalJumps(0)
    end
    print("GlobalJumpsToggle changed:", Options.GlobalJumpsToggle.Value)
end)
Options.GlobalJumpsToggle:SetValue(false)

local SpeedSlider = Tabs.Main:AddSlider("SpeedSlider", {
    Title       = "💨 Walkspeed",
    Description = "Adjust your walkspeed",
    Default     = 16,
    Min         = 0,
    Max         = 100,
    Rounding    = 0,
    Callback    = function(Value)
        setGlobalSpeed(Value)
        print("Walkspeed set to:", Value)
    end
})
SpeedSlider:OnChanged(function(Value)
    setGlobalSpeed(Value)
    print("Walkspeed updated:", Value)
end)
SpeedSlider:SetValue(16)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()     
SaveManager:SetIgnoreIndexes({})      
InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/TowerOfHell")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title   = "SwirlHub",
    Content = "✅ Tower Of Hell script loaded!",
    Duration = 8,
    Type    = "success"
})

SaveManager:LoadAutoloadConfig()

print("🔧 [SwirlHub Debug]: Script fully loaded. Enjoy!")
