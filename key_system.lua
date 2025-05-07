local expectedKey = "HIDEKEY3152" -- CHANGE THIS TO YOUR KEY
local keySystemLink = "https://link-center.net/1284584/roblox-hide-or-die-script" -- CHANGE THIS TO YOUR KEY SITE
local scriptURL = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/HideOrDie.lua"

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystem"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.BorderSizePixel = 0
title.Text = "Key System"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Key TextBox
local textBox = Instance.new("TextBox")
textBox.PlaceholderText = "Enter your key here..."
textBox.Size = UDim2.new(0.9, 0, 0, 30)
textBox.Position = UDim2.new(0.05, 0, 0, 50)
textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 14
textBox.Parent = frame

-- Copy Link Button
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.9, 0, 0, 30)
copyButton.Position = UDim2.new(0.05, 0, 0, 90)
copyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
copyButton.Text = "Copy Key Link"
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Font = Enum.Font.GothamBold
copyButton.TextSize = 14
copyButton.Parent = frame

-- Submit Button
local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0.9, 0, 0, 30)
submitButton.Position = UDim2.new(0.05, 0, 0, 130)
submitButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
submitButton.Text = "Submit Key"
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 14
submitButton.Parent = frame

-- Copy Link Function
copyButton.MouseButton1Click:Connect(function()
    setclipboard(keySystemLink)
    copyButton.Text = "Link Copied!"
    task.wait(1.5)
    copyButton.Text = "Copy Key Link"
end)

-- Submit Key Function
submitButton.MouseButton1Click:Connect(function()
    local userKey = textBox.Text
    if userKey == expectedKey then
        submitButton.Text = "Key Correct!"
        task.spawn(function()
            loadstring(game:HttpGet(scriptURL))()
        end)
        task.wait(1)
        screenGui:Destroy()
    else
        submitButton.Text = "Invalid Key!"
        task.wait(1.5)
        submitButton.Text = "Submit Key"
    end
end)
