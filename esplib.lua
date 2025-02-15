-- Ultimate ESP Library (Improved Version)
local ESP = {}
ESP.__index = ESP

--[[ 
    Configuration Settings:
      - Enabled: Master toggle.
      - TeamCheck: If true, ESP color will be green for your team.
      - MaxDistance: Maximum distance to display ESP.
      - Boxes, Names, Tracers, Health, HeadDot, Arrows: Toggle individual features.
      - BoxSizeFactor, BoxBaseSize, HealthBarWidth, HealthBarOffset, NameOffset, ArrowDistance, ArrowPoints, TextSize:
          Additional style and positioning options.
]]
ESP.Config = {
    Enabled = true,
    TeamCheck = false,
    MaxDistance = 1000,
    
    Boxes = true,
    Names = true,
    Tracers = true,
    Health = true,
    HeadDot = true,
    Arrows = true,
    
    BoxSizeFactor = 10,
    BoxBaseSize = Vector2.new(50, 80),
    HealthBarWidth = 4,
    HealthBarOffset = Vector2.new(-6, 0),
    NameOffset = Vector2.new(0, -15),
    ArrowDistance = 150,
    ArrowPoints = { Vector2.new(-10, 10), Vector2.new(10, 10), Vector2.new(0, -10) },
    TextSize = 18
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Storage for ESP drawings per player
local ESPObjects = {}

-- Utility: Convert a world position to a 2D screen position.
local function worldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Utility: Create a drawing object and assign its properties.
local function createDrawing(drawType, properties)
    local obj = Drawing.new(drawType)
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    return obj
end

-- Utility: Get color based on team (if TeamCheck is enabled).
local function getColor(player)
    if ESP.Config.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return Color3.fromRGB(0, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

-- Creates ESP drawings for a given player.
function ESP.Add(player)
    if player == LocalPlayer then return end -- Skip self

    ESPObjects[player] = {}
    local color = getColor(player)

    ESPObjects[player].Box = createDrawing("Square", {
        Thickness = 1,
        Filled = false,
        Color = color
    })
    ESPObjects[player].Tracer = createDrawing("Line", {
        Thickness = 1,
        Color = color
    })
    ESPObjects[player].Name = createDrawing("Text", {
        Size = ESP.Config.TextSize,
        Outline = true,
        Color = Color3.new(1, 1, 1)
    })
    ESPObjects[player].HealthBar = createDrawing("Square", {
        Filled = true,
        Color = Color3.new(0, 1, 0)
    })
    ESPObjects[player].HeadDot = createDrawing("Circle", {
        Filled = true,
        Radius = 4,
        Color = color
    })
    ESPObjects[player].Arrow = createDrawing("Triangle", {
        Filled = true,
        Color = color
    })
end

-- Removes ESP drawings for a given player.
function ESP.Remove(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end

-- Main update function run each frame.
local function updateESP()
    if not ESP.Config.Enabled then
        for _, drawings in pairs(ESPObjects) do
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
        return
    end

    for player, drawings in pairs(ESPObjects) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Head") then
            local hrp = character.HumanoidRootPart
            local head = character.Head
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end

            local screenPos, onScreen = worldToScreen(hrp.Position)
            local headPos, _ = worldToScreen(head.Position)
            local distance = (hrp.Position - Camera.CFrame.Position).Magnitude

            if distance > ESP.Config.MaxDistance then
                -- Hide all drawings if player is too far.
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
                continue
            end

            if onScreen then
                -- Calculate box dimensions relative to distance.
                local boxSize = (ESP.Config.BoxBaseSize / distance) * ESP.Config.BoxSizeFactor
                local boxPos = screenPos - boxSize / 2

                -- Update Box
                drawings.Box.Size = boxSize
                drawings.Box.Position = boxPos
                drawings.Box.Visible = ESP.Config.Boxes

                -- Update Name
                drawings.Name.Text = player.Name
                drawings.Name.Position = boxPos + ESP.Config.NameOffset
                drawings.Name.Visible = ESP.Config.Names

                -- Update Tracer
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                drawings.Tracer.To = screenPos
                drawings.Tracer.Visible = ESP.Config.Tracers

                -- Update Health Bar
                local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                drawings.HealthBar.Size = Vector2.new(ESP.Config.HealthBarWidth, boxSize.Y * healthRatio)
                drawings.HealthBar.Position = boxPos + ESP.Config.HealthBarOffset
                drawings.HealthBar.Visible = ESP.Config.Health

                -- Update Head Dot
                drawings.HeadDot.Position = headPos
                drawings.HeadDot.Visible = ESP.Config.HeadDot

                -- Hide Arrow if on screen.
                drawings.Arrow.Visible = false
            else
                -- Off-screen: Show arrow if enabled.
                if ESP.Config.Arrows then
                    -- Hide other drawings.
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                    drawings.Tracer.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.HeadDot.Visible = false

                    -- Calculate arrow position.
                    local direction = (hrp.Position - Camera.CFrame.Position).Unit
                    local arrowPos = (Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y) / 2) +
                                     Vector2.new(direction.X, direction.Y) * ESP.Config.ArrowDistance

                    drawings.Arrow.PointA = arrowPos + ESP.Config.ArrowPoints[1]
                    drawings.Arrow.PointB = arrowPos + ESP.Config.ArrowPoints[2]
                    drawings.Arrow.PointC = arrowPos + ESP.Config.ArrowPoints[3]
                    drawings.Arrow.Visible = true
                else
                    drawings.Arrow.Visible = false
                end
            end
        else
            ESP.Remove(player)  -- Clean up if the player's character is not valid.
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- Apply ESP to all current players.
function ESP.ApplyToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        ESP.Add(player)
    end
end

-- Connect events for players joining and leaving.
Players.PlayerAdded:Connect(ESP.Add)
Players.PlayerRemoving:Connect(ESP.Remove)
ESP.ApplyToAll()

return ESP
