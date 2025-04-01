--// April Fools Day Screen Overlay GUI

-- Clean up if it already exists
pcall(function()
    game.CoreGui:FindFirstChild("AprilFoolsOverlay"):Destroy()
end)

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AprilFoolsOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- Full black background
local BlackFrame = Instance.new("Frame")
BlackFrame.Size = UDim2.new(1, 0, 1, 0)
BlackFrame.Position = UDim2.new(0, 0, 0, 0)
BlackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
BlackFrame.BorderSizePixel = 0
BlackFrame.Parent = ScreenGui

-- Centered white text
local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.Position = UDim2.new(0, 0, 0, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Happy April Fools Day"
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextScaled = true
TextLabel.Font = Enum.Font.GothamBlack
TextLabel.Parent = ScreenGui
