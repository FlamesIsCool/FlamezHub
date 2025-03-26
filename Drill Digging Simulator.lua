local discordInvite = "https://discord.com/invite/5j7Rv6VXdn"

local http_request = (syn and syn.request) or (http and http.request) or request
if http_request then
    http_request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = game:GetService("HttpService"):JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {code = string.match(discordInvite, "discord%.com/invite/(%w+)")},
            nonce = game:GetService("HttpService"):GenerateGUID(false)
        })
    })
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Executor Not Supported",
        Text = "Join manually: "..discordInvite,
        Duration = 5
    })
end


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Flame - Drill Digging Simulator",
   Icon = 0,
   LoadingTitle = "Flame - Drill Digging Simulator",
   LoadingSubtitle = "by Flames",
   Theme = "Default",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Flame Hub"
   },

   Discord = {
      Enabled = true,
      Invite = "5j7Rv6VXdn",
      RememberJoins = false
   },

   KeySystem = false,
   KeySettings = {
      Title = "Flame - Key System",
      Subtitle = "Key System",
      Note = "The key is provided in the discord",
      FileName = "FlameKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

local Tab = Window:CreateTab("Main", "home")

local Divider = Tab:CreateDivider()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local giveCashRemote = ReplicatedStorage:WaitForChild("GiveCash")

local firing = false

task.spawn(function()
    while true do
        if firing then
            local backpack = LocalPlayer:WaitForChild("Backpack")
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = Character
            end

            local equippedTool = Character:FindFirstChildOfClass("Tool")
            if equippedTool then
                giveCashRemote:FireServer(equippedTool)
            end
        end
        task.wait()
    end
end)

local Toggle = Tab:CreateToggle({
    Name = "Auto Cash",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        firing = Value
    end,
})
