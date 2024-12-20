-- Load the UI library
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/PPHUD/main/Library.lua'))()
local Flags = Library.Flags

-- Create main window
local Window = Library:Window({
   Text = "Main"
})

-- Create tabs
local TabMain = Window:Tab({
   Text = "Main"
})

-- LocalPlayer Section (Left)
local SectionLocalPlayer = TabMain:Section({
   Text = "LocalPlayer",
   Side = "Left"
})

SectionLocalPlayer:Slider({
   Text = "WalkSpeed",
   Minimum = 16,
   Default = 16,
   Maximum = 500,
   Callback = function(value)
       game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
   end
})

SectionLocalPlayer:Slider({
   Text = "JumpPower",
   Minimum = 50,
   Default = 50,
   Maximum = 500,
   Callback = function(value)
       game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
   end
})

SectionLocalPlayer:Slider({
   Text = "Gravity",
   Minimum = 0,
   Default = 196.2,
   Maximum = 500,
   Callback = function(value)
       workspace.Gravity = value
   end
})

local noclipConnection
SectionLocalPlayer:Check({
   Text = "Noclip",
   Callback = function(enabled)
       if enabled then
           noclipConnection = game:GetService("RunService").Stepped:Connect(function()
               local character = game.Players.LocalPlayer.Character
               if character then
                   for _, part in pairs(character:GetDescendants()) do
                       if part:IsA("BasePart") then
                           part.CanCollide = false
                       end
                   end
               end
           end)
       else
           if noclipConnection then
               noclipConnection:Disconnect()
               noclipConnection = nil
           end
       end
   end
})

local jumpConnection
SectionLocalPlayer:Check({
   Text = "Infinite Jump",
   Callback = function(enabled)
       if enabled then
           jumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
               local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
               if humanoid then
                   humanoid:ChangeState("Jumping")
               end
           end)
       else
           if jumpConnection then
               jumpConnection:Disconnect()
               jumpConnection = nil
           end
       end
   end
})

SectionLocalPlayer:Button({
   Text = "Fly",
   Callback = function()
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
       local flying = true
       
       local bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart)
       bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
       bodyVelocity.Velocity = Vector3.zero

       local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
       bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
       bodyGyro.CFrame = humanoidRootPart.CFrame

       local flyConnection
       flyConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
           if gameProcessed then return end
           if input.KeyCode == Enum.KeyCode.E then -- Toggle fly
               flying = not flying
               if not flying then
                   bodyVelocity:Destroy()
                   bodyGyro:Destroy()
                   flyConnection:Disconnect()
               end
           end
       end)

       game:GetService("RunService").Stepped:Connect(function()
           if flying then
               local camera = workspace.CurrentCamera
               bodyVelocity.Velocity = camera.CFrame.LookVector * 50 -- Adjust speed
               bodyGyro.CFrame = camera.CFrame
           end
       end)
   end
})

-- ESP Section (Right)
local SectionESP = TabMain:Section({
   Text = "ESP",
   Side = "Right"
})

SectionESP:Check({
   Text = "Enable ESP",
   Flag = "EnableESP",
   Callback = function(enabled)
       if enabled then
           warn("ESP Enabled")
           local function createESP(player)
               if player == game.Players.LocalPlayer then return end -- Skip local player
               local character = player.Character or player.CharacterAdded:Wait()
               local highlight = Instance.new("Highlight")
               highlight.Adornee = character
               highlight.Parent = character
               highlight.FillTransparency = 0.7 -- Adjust for visibility
               highlight.OutlineTransparency = 0
               highlight.FillColor = Color3.new(1, 0, 0) -- Red fill
               highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline
           end

           local function setupESP()
               for _, player in pairs(game.Players:GetPlayers()) do
                   createESP(player)
               end

               game.Players.PlayerAdded:Connect(function(player)
                   player.CharacterAdded:Connect(function()
                       createESP(player)
                   end)
               end)
           end

           setupESP()
       else
           warn("ESP Disabled")
           for _, player in pairs(game.Players:GetPlayers()) do
               local character = player.Character
               if character then
                   for _, child in pairs(character:GetChildren()) do
                       if child:IsA("Highlight") then
                           child:Destroy()
                       end
                   end
               end
           end
       end
   end
})

-- Auto Win Section (Right)
local SectionAutoWin = TabMain:Section({
   Text = "Auto Win",
   Side = "Right"
})

local originalPosition
SectionAutoWin:Check({
   Text = "Auto Find All",
   Callback = function(enabled)
       if enabled then
           for _, player in pairs(game.Players:GetPlayers()) do
               if player ~= game.Players.LocalPlayer then
                   local character = player.Character
                   if character and character:FindFirstChild("HumanoidRootPart") then
                       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame
                       wait(0.5) -- Adjust delay as needed
                   end
               end
           end
       end
   end
})

SectionAutoWin:Check({
   Text = "Auto Hide",
   Callback = function(enabled)
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
       if enabled then
           originalPosition = humanoidRootPart.CFrame
           humanoidRootPart.CFrame = CFrame.new(0, 1000, 0) -- Adjust to a secret platform location
       else
           if originalPosition then
               humanoidRootPart.CFrame = originalPosition
           end
       end
   end
})

local autoCollectConnection
SectionAutoWin:Check({
   Text = "Auto Collect Coins",
   Callback = function(enabled)
       if enabled then
           autoCollectConnection = game:GetService("RunService").Stepped:Connect(function()
               for _, object in pairs(workspace.GameObjects:GetChildren()) do
                   if object:IsA("BasePart") then
                       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = object.CFrame
                       wait(0.1) -- Adjust delay as needed
                   end
               end
           end)
       else
           if autoCollectConnection then
               autoCollectConnection:Disconnect()
               autoCollectConnection = nil
           end
       end
   end
})

-- Player Teleportation Section (Left)
local SectionPlayerTeleport = TabMain:Section({
   Text = "Player Teleportation",
   Side = "Left"
})

local playerList = {}
for _, player in pairs(game.Players:GetPlayers()) do
   if player ~= game.Players.LocalPlayer then
       table.insert(playerList, player.Name)
   end
end

game.Players.PlayerAdded:Connect(function(player)
   if player ~= game.Players.LocalPlayer then
       table.insert(playerList, player.Name)
   end
end)

game.Players.PlayerRemoving:Connect(function(player)
   for i, playerName in pairs(playerList) do
       if playerName == player.Name then
           table.remove(playerList, i)
           break
       end
   end
end)

SectionPlayerTeleport:Dropdown({
   Text = "Select Player",
   List = playerList,
   Callback = function(selectedPlayerName)
       local selectedPlayer = game.Players:FindFirstChild(selectedPlayerName)
       if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
           game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
       end
   end
})
