--[[ 
   Player Utilities GUI using Fluent
   Features:
     • Walkspeed slider
     • Jump Power slider
     • Gravity slider
     • FOV slider
     • Infinite Jump toggle
     • Noclip toggle
     • Fly toggle with FlySpeed slider
     • Teleport to Player dropdown (with refresh button)
     • Reset Player button (resets WalkSpeed and JumpPower)
--]]

-- Load the Fluent libraries
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the main window
local Window = Fluent:CreateWindow({
    Title = "SwirlHub - MM2 " .. Fluent.Version,
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,        -- Set to false if you want to disable blur
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Create Tabs (Here we make the player functions the main tab)
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Services and local references
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

----------------------------------------------------------------
-- Walkspeed Slider
----------------------------------------------------------------
local WalkspeedSlider = Tabs.Main:AddSlider("Walkspeed", {
    Title = "Walkspeed",
    Description = "Adjust your player's walkspeed.",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end
})

----------------------------------------------------------------
-- Jump Power Slider
----------------------------------------------------------------
local JumpPowerSlider = Tabs.Main:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjust your player's jump power.",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end
    end
})

----------------------------------------------------------------
-- Gravity Slider
----------------------------------------------------------------
local GravitySlider = Tabs.Main:AddSlider("Gravity", {
    Title = "Gravity",
    Description = "Adjust the game gravity.",
    Default = workspace.Gravity,
    Min = 0,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

----------------------------------------------------------------
-- FOV Slider
----------------------------------------------------------------
local FOVSlider = Tabs.Main:AddSlider("FOV", {
    Title = "Field of View",
    Description = "Adjust the camera's field of view.",
    Default = Camera.FieldOfView,
    Min = 20,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        Camera.FieldOfView = Value
    end
})

----------------------------------------------------------------
-- Infinite Jump Toggle
----------------------------------------------------------------
local InfJumpToggle = Tabs.Main:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false,
    Description = "Enable infinite jump."
})

local InfJumpEnabled = false
local InfJumpConnection

InfJumpToggle:OnChanged(function()
    InfJumpEnabled = InfJumpToggle.Value
    if InfJumpEnabled then
        InfJumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if InfJumpConnection then
            InfJumpConnection:Disconnect()
        end
    end
end)

----------------------------------------------------------------
-- Noclip Toggle
----------------------------------------------------------------
local NoclipToggle = Tabs.Main:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Description = "Enable noclip (walk through walls)."
})

local NoclipEnabled = false
NoclipToggle:OnChanged(function()
    NoclipEnabled = NoclipToggle.Value
end)

-- Run every frame to disable collisions if noclip is enabled
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

----------------------------------------------------------------
-- Fly Toggle and FlySpeed Slider
----------------------------------------------------------------
local FlyToggle = Tabs.Main:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Description = "Enable flying mode."
})

local FlySpeedSlider = Tabs.Main:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust your fly speed.",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        -- The fly speed will update automatically during RenderStepped.
    end
})

local FlyEnabled = false
local FlyBodyVelocity, FlyBodyGyro
local FlyConnection

FlyToggle:OnChanged(function()
    FlyEnabled = FlyToggle.Value
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if FlyEnabled then
        -- Create BodyMover objects to control flying
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.Parent = hrp
        
        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp
        
        -- Update the fly movement every frame
        FlyConnection = RunService.RenderStepped:Connect(function()
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            FlyBodyVelocity.Velocity = direction * FlySpeedSlider.Value
            if direction.Magnitude > 0 then
                FlyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
            else
                FlyBodyGyro.CFrame = hrp.CFrame
            end
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
        end
        if FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
        end
        if FlyBodyGyro then
            FlyBodyGyro:Destroy()
        end
    end
end)

----------------------------------------------------------------
-- Teleport to Player Dropdown
----------------------------------------------------------------
-- Function to get a list of other players' names
local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local TeleportDropdown = Tabs.Main:AddDropdown("TeleportToPlayer", {
    Title = "Teleport to Player",
    Description = "Select a player to teleport to their position.",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
           and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame =
                target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

-- A button to refresh the player list in the dropdown
Tabs.Main:AddButton({
    Title = "Refresh Player List",
    Description = "Update the teleport dropdown with current players.",
    Callback = function()
        TeleportDropdown:SetValues(getPlayerNames())
    end
})

----------------------------------------------------------------
-- Reset Player Button (Optional)
----------------------------------------------------------------
Tabs.Main:AddButton({
    Title = "Reset Player",
    Description = "Reset WalkSpeed and JumpPower to default values.",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
            WalkspeedSlider:SetValue(16)
            JumpPowerSlider:SetValue(50)
        end
    end
})

--------------------------------------------------
-- ESP Section (for Murderer, Sheriff, Innocent, Coin)
--------------------------------------------------
-- Create a new section in the Main tab for ESP features
local ESPSection = Tabs.Main:AddSection("ESP")

-- Create toggles for each ESP category
local murdererESPToggle = ESPSection:AddToggle("MurdererESP", {
    Title = "Murderer ESP",
    Description = "Highlight the murderer in red.",
    Default = true
})

local sheriffESPToggle = ESPSection:AddToggle("SheriffESP", {
    Title = "Sheriff ESP",
    Description = "Highlight the shriff in blue.",
    Default = true
})

local innocentESPToggle = ESPSection:AddToggle("InnocentESP", {
    Title = "Innocent ESP",
    Description = "Highlight players who are innocent in green.",
    Default = true
})

local coinESPToggle = ESPSection:AddToggle("CoinESP", {
    Title = "Coin ESP",
    Description = "Highlight all coins in yellow.",
    Default = true
})

-- Services and local references
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Tables to store highlight objects for players and coins
local playerHighlights = {}  -- [player] = Highlight instance
local coinHighlights = {}    -- [coin instance] = Highlight instance

--[[
    updateESPForPlayer(player)
    
    Checks the player's Backpack and Character for Tools:
      - If the player has a "Knife", they’re considered a murderer.
      - Otherwise if they have a "Gun", they’re considered sheriff.
      - Otherwise they’re innocent.
      
    Depending on which toggles are enabled, a Highlight instance is created (or updated)
    for the player's character with the corresponding color:
      • Red for murderer
      • Blue for sheriff
      • Green for innocent
--]]
local function updateESPForPlayer(player)
    if not player.Character then
        -- If no character, remove any highlight we might have
        if playerHighlights[player] then
            playerHighlights[player]:Destroy()
            playerHighlights[player] = nil
        end
        return
    end

    local character = player.Character

    -- Helper function to check for a tool with a specific name in Backpack and Character.
    local function hasTool(toolName)
        local found = false
        if player:FindFirstChild("Backpack") then
            for _, tool in ipairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == toolName then
                    found = true
                    break
                end
            end
        end
        if not found then
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Tool") and item.Name == toolName then
                    found = true
                    break
                end
            end
        end
        return found
    end

    local isMurderer = hasTool("Knife")
    local isSheriff  = (not isMurderer) and hasTool("Gun")
    local isInnocent  = (not isMurderer and not isSheriff)

    -- Decide what color should be used based on toggles and the above checks.
    local desiredColor
    if isMurderer and murdererESPToggle.Value then
        desiredColor = Color3.new(1, 0, 0)   -- Red
    elseif isSheriff and sheriffESPToggle.Value then
        desiredColor = Color3.new(0, 0, 1)   -- Blue
    elseif isInnocent and innocentESPToggle.Value then
        desiredColor = Color3.new(0, 1, 0)   -- Green
    end

    -- If we have a desired color, create (or update) a Highlight instance.
    if desiredColor then
        if not playerHighlights[player] then
            local h = Instance.new("Highlight")
            h.Name = "ESPHighlight"
            h.FillTransparency = 0.5
            h.OutlineTransparency = 1
            h.Adornee = character
            h.FillColor = desiredColor
            -- Parent the highlight to the character so it gets cleaned up on death.
            h.Parent = character
            playerHighlights[player] = h
        else
            playerHighlights[player].FillColor = desiredColor
            if playerHighlights[player].Adornee ~= character then
                playerHighlights[player].Adornee = character
            end
        end
    else
        -- If no ESP should be shown, remove any existing highlight.
        if playerHighlights[player] then
            playerHighlights[player]:Destroy()
            playerHighlights[player] = nil
        end
    end
end

-- Update ESP for all players every second.
spawn(function()
    while wait(1) do
        for _, player in ipairs(Players:GetPlayers()) do
            -- Optionally, you can skip the LocalPlayer if you don't want to highlight yourself.
            if player ~= LocalPlayer then
                updateESPForPlayer(player)
            end
        end
    end
end)

-- Update when toggles change (refresh all players’ ESP)
local function refreshAllPlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateESPForPlayer(player)
        end
    end
end

murdererESPToggle:OnChanged(refreshAllPlayerESP)
sheriffESPToggle:OnChanged(refreshAllPlayerESP)
innocentESPToggle:OnChanged(refreshAllPlayerESP)

-- Also update when a new character loads
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(0.5)  -- slight delay to let the character load fully
        updateESPForPlayer(player)
    end)
end)


-- Table to store created coin highlight instances
local coinHighlights = coinHighlights or {}

-- This loop updates the coin ESP every second.
spawn(function()
    while wait(0.1) do
        if coinESPToggle.Value then
            -- Search through all descendants in the workspace for any Model named "CoinContainer"
            for _, container in ipairs(workspace:GetDescendants()) do
                if container:IsA("Model") and container.Name == "CoinContainer" then
                    -- Loop through all children of the CoinContainer
                    for _, coinServer in ipairs(container:GetChildren()) do
                        if coinServer.Name == "Coin_Server" then
                            local coinVisual = coinServer:FindFirstChild("CoinVisual")
                            if coinVisual then
                                local mainCoin = coinVisual:FindFirstChild("MainCoin")
                                if mainCoin and mainCoin:IsA("MeshPart") then
                                    -- Create a Highlight instance if one doesn't already exist for this MainCoin
                                    if not coinHighlights[mainCoin] then
                                        local h = Instance.new("Highlight")
                                        h.Name = "CoinESPHighlight"
                                        h.FillColor = Color3.fromRGB(0, 255, 255)  -- Cyan
                                        h.FillTransparency = 0.5
                                        h.OutlineTransparency = 1
                                        h.Adornee = mainCoin
                                        h.Parent = mainCoin  -- Parent to the part so it cleans up naturally
                                        coinHighlights[mainCoin] = h
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            -- If the coin ESP toggle is off, remove any existing highlights
            for coinObj, h in pairs(coinHighlights) do
                if h then
                    h:Destroy()
                end
            end
            coinHighlights = {}
        end
    end
end)


-- Create a new section in the Settings tab for executor/utilities
local utilitiesSection = Tabs.Settings:AddSection("Utilities")

--------------------------------------------------
-- Rejoin Button
--------------------------------------------------
utilitiesSection:AddButton({
    Title = "Rejoin",
    Description = "Rejoin the current server.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

--------------------------------------------------
-- Serverhop Button
--------------------------------------------------
utilitiesSection:AddButton({
    Title = "Serverhop",
    Description = "Hop to a different server instance.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local PlaceId = game.PlaceId

        -- This example uses a simple HTTP request to get a list of servers.
        -- Adjust the HTTP request function as needed depending on your executor.
        local req = syn and syn.request or http_request or request
        if not req then
            warn("HTTP request function not available.")
            return
        end

        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = req({
            Url = url,
            Method = "GET"
        })
        if response and response.Body then
            local data = HttpService:JSONDecode(response.Body)
            local servers = {}
            for i, v in ipairs(data.data) do
                if v.playing < v.maxPlayers then
                    table.insert(servers, v.id)
                end
            end
            if #servers > 0 then
                local randomServer = servers[math.random(1, #servers)]
                TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, LocalPlayer)
            else
                warn("No available servers found!")
            end
        end
    end
})

--------------------------------------------------
-- Identify Executor Paragraph
--------------------------------------------------
local executorName, executorVersion = "Unknown", "Unknown"
if identifyexecutor and type(identifyexecutor) == "function" then
    local result1, result2 = identifyexecutor()
    if type(result1) == "string" and type(result2) == "string" then
        executorName = result1
        executorVersion = result2
    end
end

-- Display the result in a paragraph.
utilitiesSection:AddParagraph({
    Title = "Executor Type",
    Content = "Executor: " .. executorName .. " (v" .. executorVersion .. ")"
})

--------------------------------------------------
-- Set FPS Cap Button
--------------------------------------------------
utilitiesSection:AddButton({
    Title = "Set FPS Cap",
    Description = "Set your FPS cap to Infinite.",
    Callback = function()
        if setfpscap then
            setfpscap(999)  -- Adjust the value as needed.
        else
            warn("setfpscap function not available on your executor.")
        end
    end
})




----------------------------------------------------------------
-- Save and Interface Manager Setup (Optional)
----------------------------------------------------------------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/MM2")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select the first (Player) tab on load
Window:SelectTab(1)

-- A startup notification
Fluent:Notify({
    Title = "SwirlHub",
    Content = "Player script has been loaded.",
    Duration = 8
})

-- Optionally load an autoload config
SaveManager:LoadAutoloadConfig()
