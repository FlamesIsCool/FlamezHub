-- ESP Library for Roblox Executors
local ESP = {}

-- Settings
ESP.Enabled = true
ESP.TeamCheck = false
ESP.MaxDistance = 500

-- Features Toggles
ESP.Boxes = true
ESP.Names = true
ESP.Tracers = true
ESP.Health = true
ESP.HeadDot = true
ESP.Arrows = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Function to convert World to Screen
local function WorldToScreen(Position)
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)
    return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen
end

-- Function to create drawing objects
local function CreateDrawing(Type, Properties)
    local DrawingObject = Drawing.new(Type)
    for Property, Value in pairs(Properties) do
        DrawingObject[Property] = Value
    end
    return DrawingObject
end

-- Store ESP objects
local ESPObjects = {}

-- Function to get color based on team
local function GetColor(Player)
    return (ESP.TeamCheck and Player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

-- Function to create ESP for all players
function ESP.Add(Player)
    if Player == LocalPlayer then return end
    local Character = Player.Character
    if not Character then return end

    ESPObjects[Player] = {
        Box = CreateDrawing("Square", {Thickness = 1, Filled = false, Color = GetColor(Player)}),
        Tracer = CreateDrawing("Line", {Thickness = 1, Color = GetColor(Player)}),
        Name = CreateDrawing("Text", {Size = 18, Outline = true, Color = Color3.new(1, 1, 1)}),
        HealthBar = CreateDrawing("Square", {Filled = true, Color = Color3.new(0, 1, 0)}),
        HeadDot = CreateDrawing("Circle", {Filled = true, Radius = 4, Color = GetColor(Player)}),
        Arrow = CreateDrawing("Triangle", {Filled = true, Color = GetColor(Player)})
    }
end

-- Function to remove ESP
function ESP.Remove(Player)
    if ESPObjects[Player] then
        for _, Object in pairs(ESPObjects[Player]) do
            Object:Remove()
        end
        ESPObjects[Player] = nil
    end
end

-- Function to apply ESP to all players
function ESP.ApplyToAll()
    for _, Player in pairs(Players:GetPlayers()) do
        ESP.Add(Player)
    end
end

-- Update ESP each frame
local function UpdateESP()
    for Player, ESPData in pairs(ESPObjects) do
        if not ESP.Enabled or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            for _, Object in pairs(ESPData) do
                Object.Visible = false
            end
            return
        end

        local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
        local Head = Player.Character:FindFirstChild("Head")
        local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

        if HRP and Head and Humanoid then
            local ScreenPos, OnScreen = WorldToScreen(HRP.Position)
            local HeadPos, _ = WorldToScreen(Head.Position)

            if OnScreen then
                local BoxSize = Vector2.new(50, 80) / (HRP.Position - Camera.CFrame.Position).Magnitude * 10
                local BoxPosition = ScreenPos - BoxSize / 2
                
                -- Box ESP
                ESPData.Box.Size = BoxSize
                ESPData.Box.Position = BoxPosition
                ESPData.Box.Visible = ESP.Boxes
                
                -- Name
                ESPData.Name.Text = Player.Name
                ESPData.Name.Position = BoxPosition - Vector2.new(0, 15)
                ESPData.Name.Visible = ESP.Names
                
                -- Tracer
                ESPData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                ESPData.Tracer.To = ScreenPos
                ESPData.Tracer.Visible = ESP.Tracers
                
                -- Health Bar
                ESPData.HealthBar.Size = Vector2.new(4, BoxSize.Y * (Humanoid.Health / Humanoid.MaxHealth))
                ESPData.HealthBar.Position = BoxPosition - Vector2.new(6, 0)
                ESPData.HealthBar.Visible = ESP.Health
                
                -- Head Dot
                ESPData.HeadDot.Position = HeadPos
                ESPData.HeadDot.Visible = ESP.HeadDot
            else
                -- Off-Screen Arrow
                local Direction = (HRP.Position - Camera.CFrame.Position).Unit
                local ArrowPos = Camera.ViewportSize / 2 + Vector2.new(Direction.X, Direction.Y) * 150
                ESPData.Arrow.PointA = ArrowPos + Vector2.new(-10, 10)
                ESPData.Arrow.PointB = ArrowPos + Vector2.new(10, 10)
                ESPData.Arrow.PointC = ArrowPos + Vector2.new(0, -10)
                ESPData.Arrow.Visible = ESP.Arrows
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- Connect Player Events
ESP.ApplyToAll()
Players.PlayerAdded:Connect(ESP.Add)
Players.PlayerRemoving:Connect(ESP.Remove)

return ESP
