local discordLink = "https://discord.gg/5c9D3VD7se" 

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIGradient = Instance.new("UIGradient")
local UIStroke = Instance.new("UIStroke")
local UICorner = Instance.new("UICorner")
local ShadowFrame = Instance.new("Frame")
local CopyButton = Instance.new("TextButton")
local InfoLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local TweenService = game:GetService("TweenService")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "DiscordGUI"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

UIStroke.Parent = MainFrame
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 10)

ShadowFrame.Name = "ShadowFrame"
ShadowFrame.Parent = MainFrame
ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShadowFrame.BackgroundTransparency = 0.5
ShadowFrame.Size = UDim2.new(1, 20, 1, 20)
ShadowFrame.Position = UDim2.new(0, -10, 0, -10)
ShadowFrame.ZIndex = 0

InfoLabel.Name = "InfoLabel"
InfoLabel.Parent = MainFrame
InfoLabel.Text = "Join our Discord for the script!"
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.TextScaled = true
InfoLabel.Size = UDim2.new(0.8, 0, 0.3, 0)
InfoLabel.Position = UDim2.new(0.1, 0, 0.15, 0)
InfoLabel.BackgroundTransparency = 1

CopyButton.Name = "CopyButton"
CopyButton.Parent = MainFrame
CopyButton.Text = "Copy Discord Link"
CopyButton.Font = Enum.Font.GothamBold
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextScaled = true
CopyButton.Size = UDim2.new(0.6, 0, 0.2, 0)
CopyButton.Position = UDim2.new(0.2, 0, 0.55, 0)
CopyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local ButtonUICorner = Instance.new("UICorner")
ButtonUICorner.CornerRadius = UDim.new(0, 10)
ButtonUICorner.Parent = CopyButton

local ButtonUIStroke = Instance.new("UIStroke")
ButtonUIStroke.Thickness = 2
ButtonUIStroke.Color = Color3.fromRGB(255, 255, 255)
ButtonUIStroke.Parent = CopyButton

CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Size = UDim2.new(0.1, 0, 0.1, 0)
CloseButton.Position = UDim2.new(0.9, -5, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

local CloseButtonUICorner = Instance.new("UICorner")
CloseButtonUICorner.CornerRadius = UDim.new(0, 5)
CloseButtonUICorner.Parent = CloseButton

CopyButton.MouseEnter:Connect(function()
    local hoverTween = TweenService:Create(CopyButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
    hoverTween:Play()
end)

CopyButton.MouseLeave:Connect(function()
    local leaveTween = TweenService:Create(CopyButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
    leaveTween:Play()
end)

CopyButton.MouseButton1Click:Connect(function()
    setclipboard(discordLink)
    CopyButton.Text = "Link Copied!"
    wait(1.5)
    CopyButton.Text = "Copy Discord Link"
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

MainFrame:TweenSize(UDim2.new(0, 400, 0, 200), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
