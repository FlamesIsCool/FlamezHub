-- Ultimate ESP Library (Handles Everything)
local ESP = {}

-- SETTINGS
ESP.Enabled = true
ESP.TeamCheck = false
ESP.MaxDistance = 1000

-- Feature Toggles
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

-- ESP Object Storage
local ESPObjects = {}

-- Function to convert world coordinates to screen coordinates
local function WorldToScreen(Position)
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)
    return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen
end

-- Function to create a drawing object
local function CreateDrawing(Type, Properties)
    local DrawingObject = Drawing.new(Type)
    for Property, Value in pairs(Properties) do
        DrawingObject[Property] = Value
    end
    return DrawingObject
end

-- Function to get the correct color (based on team settings)
local function GetColor(Player)
    return (ESP.TeamCheck and Player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

-- Function to create ESP for a player
function ESP.Add(Player)
    if Player == LocalPlayer then return end -- Don't ESP yourself
    ESPObjects[Player] = {}

    ESPObjects[Player].Box = CreateDrawing("Square", {Thickness = 1, Filled = false, Color = GetColor(Player)})
    ESPObjects[Player].Tracer = CreateDrawing("Line", {Thickness = 1, Color = GetColor(Player)})
    ESPObjects[Player].Name = CreateDrawing("Text", {Size = 18, Outline = true, Color = Color3.new(1, 1, 1)})
    ESPObjects[Player].HealthBar = CreateDrawing("Square", {Filled = true, Color = Color3.new(0, 1, 0)})
    ESPObjects[Player].HeadDot = CreateDrawing("Circle", {Filled = true, Radius = 4, Color = GetColor(Player)})
    ESPObjects[Player].Arrow = CreateDrawing("Triangle", {Filled = true, Color = GetColor(Player)})
end

-- Function to remove ESP for a player
function ESP.Remove(Player)
    if ESPObjects[Player] then
        for _, Object in pairs(ESPObjects[Player]) do
            Object:Remove()
        end
        ESPObjects[Player] = nil
    end
end

-- Function to update ESP for all players
local function UpdateESP()
    if not ESP.Enabled then
        for _, Objects in pairs(ESPObjects) do
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
        end
        return
    end

    for Player, ESPData in pairs(ESPObjects) do
        local Character = Player.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Head") then
            local HRP = Character.HumanoidRootPart
            local Head = Character.Head
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")

            local ScreenPos, OnScreen = WorldToScreen(HRP.Position)
            local HeadPos, _ = WorldToScreen(Head.Position)

            if OnScreen then
                local Distance = (HRP.Position - Camera.CFrame.Position).Magnitude
                if Distance <= ESP.MaxDistance then
                    local BoxSize = Vector2.new(50, 80) / Distance * 10
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
                    for _, Object in pairs(ESPData) do
                        Object.Visible = false
                    end
                end
            else
                -- Off-Screen Arrow
                local Direction = (HRP.Position - Camera.CFrame.Position).Unit
                local ArrowPos = Camera.ViewportSize / 2 + Vector2.new(Direction.X, Direction.Y) * 150
                ESPData.Arrow.PointA = ArrowPos + Vector2.new(-10, 10)
                ESPData.Arrow.PointB = ArrowPos + Vector2.new(10, 10)
                ESPData.Arrow.PointC = ArrowPos + Vector2.new(0, -10)
                ESPData.Arrow.Visible = ESP.Arrows
            end
        else
            ESP.Remove(Player) -- Remove ESP if player leaves
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- Function to apply ESP to all players
function ESP.ApplyToAll()
    for _, Player in pairs(Players:GetPlayers()) do
        ESP.Add(Player)
    end
end

-- Connect Player Events
Players.PlayerAdded:Connect(ESP.Add)
Players.PlayerRemoving:Connect(ESP.Remove)
ESP.ApplyToAll()

return ESP
