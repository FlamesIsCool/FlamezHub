--// UI Library Module
local UILibrary = {}

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--// Create the main UI frame
function UILibrary:CreateWindow(Title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.Text = Title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.Font = Enum.Font.SourceSansBold
    TitleBar.TextSize = 18
    TitleBar.Parent = MainFrame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -30)
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Container
    UIListLayout.Padding = UDim.new(0, 5)

    --// Drag Function
    local function MakeDraggable(frame, object)
        local dragging, dragInput, dragStart, startPos
        object.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        object.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    MakeDraggable(MainFrame, TitleBar)

    return setmetatable({Container = Container}, {__index = UILibrary})
end

--// Button Creation
function UILibrary:CreateButton(Text, Callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Parent = self.Container

    Button.MouseButton1Click:Connect(function()
        pcall(Callback)
    end)
end

--// Toggle Button
function UILibrary:CreateToggle(Text, Callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, -10, 0, 40)
    Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Toggle.Text = Text .. " [ OFF ]"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.Font = Enum.Font.SourceSans
    Toggle.TextSize = 16
    Toggle.Parent = self.Container

    local State = false

    Toggle.MouseButton1Click:Connect(function()
        State = not State
        Toggle.Text = Text .. (State and " [ ON ]" or " [ OFF ]")
        pcall(Callback, State)
    end)
end

--// Slider
function UILibrary:CreateSlider(Text, Min, Max, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 40)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderFrame.Parent = self.Container

    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(1, 0, 0.5, 0)
    SliderText.Text = Text .. ": 0"
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.BackgroundTransparency = 1
    SliderText.Font = Enum.Font.SourceSans
    SliderText.TextSize = 16
    SliderText.Parent = SliderFrame

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 0.5, 0)
    SliderButton.Position = UDim2.new(0, 0, 0.5, 0)
    SliderButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SliderButton.Text = ""
    SliderButton.Parent = SliderFrame

    local function UpdateSlider(input)
        local Percent = math.clamp((input.Position.X - SliderButton.AbsolutePosition.X) / SliderButton.AbsoluteSize.X, 0, 1)
        local Value = math.floor(Min + (Max - Min) * Percent)
        SliderText.Text = Text .. ": " .. Value
        pcall(Callback, Value)
    end

    SliderButton.MouseButton1Down:Connect(function()
        UpdateSlider(game.Players.LocalPlayer:GetMouse())
        local MoveConnection
        MoveConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                MoveConnection:Disconnect()
            end
        end)
    end)
end

--// Dropdown
function UILibrary:CreateDropdown(Text, Options, Callback)
    local Dropdown = Instance.new("TextButton")
    Dropdown.Size = UDim2.new(1, -10, 0, 40)
    Dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Dropdown.Text = Text .. " [Select]"
    Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    Dropdown.Font = Enum.Font.SourceSans
    Dropdown.TextSize = 16
    Dropdown.Parent = self.Container

    local Selected = nil

    Dropdown.MouseButton1Click:Connect(function()
        local Choice = Options[math.random(1, #Options)]
        Dropdown.Text = Text .. " [" .. Choice .. "]"
        Selected = Choice
        pcall(Callback, Choice)
    end)
end

return UILibrary
