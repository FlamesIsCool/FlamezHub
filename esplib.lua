-- Ultimate ESP Library (Enhanced Version)
local ESP = {}
ESP.__index = ESP

--[[ 
    Configuration Settings
    ----------------------
    Toggle Features:
      Enabled      : Master toggle for the ESP system.
      TeamCheck    : Colors ESP green for your team and red for enemies.
      MaxDistance  : Maximum distance (studs) at which ESP is active.
      Boxes        : 2D box around the character.
      Names        : Player name label.
      Tracers      : Line from the bottom of the screen to the player.
      Health       : Health bar.
      HeadDot      : Small dot over the head.
      Arrows       : Off-screen indicator arrow.
      Skeleton     : Skeleton lines connecting key body parts.
      DistanceText : Appends the distance (in meters) to the name label.
      FOVCircle    : A circle drawn at the center of the screen representing your FOV.
    
    Visual Settings:
      BoxSizeFactor      : Scaling factor for the 2D box.
      BoxBaseSize        : Base size (width x height) for the box.
      HealthBarWidth     : Width of the health bar.
      HealthBarOffset    : Positional offset for the health bar.
      NameOffset         : Positional offset for the name text.
      ArrowDistance      : Distance from the center for the off-screen arrow.
      ArrowPoints        : Offset points to form a triangle (arrow shape).
      TextSize           : Font size for the name text.
      SkeletonThickness  : Line thickness for skeleton ESP.
      SkeletonColor      : Color for skeleton lines.
      FOVCircleRadius    : Radius of the FOV circle.
      FOVCircleThickness : Line thickness of the FOV circle.
      FOVCircleColor     : Color of the FOV circle.
]]
ESP.Config = {
    Enabled = true,
    TeamCheck = false,
    MaxDistance = 1000,
    
    -- Feature Toggles
    Boxes = true,
    Names = true,
    Tracers = true,
    Health = true,
    HeadDot = true,
    Arrows = true,
    Skeleton = true,
    DistanceText = true,
    FOVCircle = true,
    
    -- Visual Settings
    BoxSizeFactor = 10,
    BoxBaseSize = Vector2.new(50, 80),
    HealthBarWidth = 4,
    HealthBarOffset = Vector2.new(-6, 0),
    NameOffset = Vector2.new(0, -15),
    ArrowDistance = 150,
    ArrowPoints = { Vector2.new(-10, 10), Vector2.new(10, 10), Vector2.new(0, -10) },
    TextSize = 18,
    
    SkeletonThickness = 1,
    SkeletonColor = Color3.new(1, 1, 1),
    
    FOVCircleRadius = 150,
    FOVCircleThickness = 1,
    FOVCircleColor = Color3.fromRGB(255, 255, 255)
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Storage for ESP drawings per player
local ESPObjects = {}

-- Global FOV circle drawing (if enabled)
local FOVCircle = nil

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

-- Convert a world position to screen coordinates.
local function worldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Create a drawing object with preset properties.
local function createDrawing(drawType, properties)
    local obj = Drawing.new(drawType)
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    return obj
end

-- Get a player's ESP color based on team (if TeamCheck is enabled).
local function getColor(player)
    if ESP.Config.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return Color3.fromRGB(0, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

-- Retrieve a character part; tries common names for both R6 and R15.
local function getCharacterPart(character, name)
    local part = character:FindFirstChild(name)
    if not part then
        if name == "Torso" then
            part = character:FindFirstChild("UpperTorso")
        elseif name == "Left Arm" then
            part = character:FindFirstChild("LeftUpperArm")
        elseif name == "Right Arm" then
            part = character:FindFirstChild("RightUpperArm")
        elseif name == "Left Leg" then
            part = character:FindFirstChild("LeftUpperLeg")
        elseif name == "Right Leg" then
            part = character:FindFirstChild("RightUpperLeg")
        end
    end
    return part
end

--------------------------------------------------------------------------------
-- Skeleton Setup
--------------------------------------------------------------------------------
-- Define skeleton segments as pairs of part names.
local skeletonSegments = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"}
}

--------------------------------------------------------------------------------
-- ESP Object Creation and Removal
--------------------------------------------------------------------------------

-- Create ESP drawings for a given player.
function ESP.Add(player)
    if player == LocalPlayer then return end

    ESPObjects[player] = {}

    local color = getColor(player)
    -- Create core drawing objects
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
    
    -- Create skeleton lines if enabled.
    if ESP.Config.Skeleton then
        ESPObjects[player].Skeleton = {}
        for i = 1, #skeletonSegments do
            local line = createDrawing("Line", {
                Thickness = ESP.Config.SkeletonThickness,
                Color = ESP.Config.SkeletonColor
            })
            ESPObjects[player].Skeleton[i] = line
        end
    end
end

-- Remove ESP drawings for a given player.
function ESP.Remove(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            if type(drawing) == "table" then
                for _, subDrawing in pairs(drawing) do
                    subDrawing:Remove()
                end
            else
                drawing:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end

--------------------------------------------------------------------------------
-- Main Update Loop
--------------------------------------------------------------------------------

local function updateESP()
    -- Update FOV Circle if enabled.
    if ESP.Config.FOVCircle then
        if not FOVCircle then
            FOVCircle = createDrawing("Circle", {
                Thickness = ESP.Config.FOVCircleThickness,
                Color = ESP.Config.FOVCircleColor,
                NumSides = 64,
                Filled = false
            })
        end
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = ESP.Config.FOVCircleRadius
        FOVCircle.Visible = true
    elseif FOVCircle then
        FOVCircle.Visible = false
    end

    -- If ESP is globally disabled, hide all drawings.
    if not ESP.Config.Enabled then
        for _, drawings in pairs(ESPObjects) do
            for _, drawing in pairs(drawings) do
                if type(drawing) == "table" then
                    for _, subDrawing in pairs(drawing) do
                        subDrawing.Visible = false
                    end
                else
                    drawing.Visible = false
                end
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
            local color = getColor(player)
            
            -- Update dynamic colors.
            drawings.Box.Color = color
            drawings.Tracer.Color = color
            drawings.HeadDot.Color = color
            drawings.Arrow.Color = color
            
            if distance > ESP.Config.MaxDistance then
                -- Hide all drawings if the player is too far.
                for _, drawing in pairs(drawings) do
                    if type(drawing) == "table" then
                        for _, subDrawing in pairs(drawing) do
                            subDrawing.Visible = false
                        end
                    else
                        drawing.Visible = false
                    end
                end
                continue
            end

            if onScreen then
                -- Calculate box dimensions relative to distance.
                local boxSize = (ESP.Config.BoxBaseSize / distance) * ESP.Config.BoxSizeFactor
                local boxPos = screenPos - boxSize / 2

                -- Box ESP.
                drawings.Box.Size = boxSize
                drawings.Box.Position = boxPos
                drawings.Box.Visible = ESP.Config.Boxes

                -- Name ESP (with optional distance text).
                local nameText = player.Name
                if ESP.Config.DistanceText then
                    nameText = nameText .. " [" .. math.floor(distance) .. "m]"
                end
                drawings.Name.Text = nameText
                drawings.Name.Position = boxPos + ESP.Config.NameOffset
                drawings.Name.Visible = ESP.Config.Names

                -- Tracer ESP.
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                drawings.Tracer.To = screenPos
                drawings.Tracer.Visible = ESP.Config.Tracers

                -- Health Bar ESP.
                local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                drawings.HealthBar.Size = Vector2.new(ESP.Config.HealthBarWidth, boxSize.Y * healthRatio)
                drawings.HealthBar.Position = boxPos + ESP.Config.HealthBarOffset
                drawings.HealthBar.Visible = ESP.Config.Health

                -- Head Dot ESP.
                drawings.HeadDot.Position = headPos
                drawings.HeadDot.Visible = ESP.Config.HeadDot

                -- Skeleton ESP.
                if ESP.Config.Skeleton and drawings.Skeleton then
                    local parts = {
                        Head = head,
                        Torso = getCharacterPart(character, "Torso"),
                        ["Left Arm"] = getCharacterPart(character, "Left Arm"),
                        ["Right Arm"] = getCharacterPart(character, "Right Arm"),
                        ["Left Leg"] = getCharacterPart(character, "Left Leg"),
                        ["Right Leg"] = getCharacterPart(character, "Right Leg")
                    }
                    
                    for i, segment in ipairs(skeletonSegments) do
                        local partA = parts[segment[1]]
                        local partB = parts[segment[2]]
                        local line = drawings.Skeleton[i]
                        if partA and partB then
                            local posA, onScreenA = worldToScreen(partA.Position)
                            local posB, onScreenB = worldToScreen(partB.Position)
                            line.From = posA
                            line.To = posB
                            line.Visible = onScreenA and onScreenB
                        else
                            line.Visible = false
                        end
                    end
                end

                -- Hide the off-screen arrow if the player is visible.
                drawings.Arrow.Visible = false
            else
                -- Off-screen: Show arrow indicator if enabled.
                if ESP.Config.Arrows then
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                    drawings.Tracer.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.HeadDot.Visible = false
                    if drawings.Skeleton then
                        for _, line in pairs(drawings.Skeleton) do
                            line.Visible = false
                        end
                    end
                    
                    local direction = (hrp.Position - Camera.CFrame.Position).Unit
                    local arrowPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) +
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
            ESP.Remove(player)  -- Clean up if character is not valid.
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

--------------------------------------------------------------------------------
-- Player Management
--------------------------------------------------------------------------------

-- Apply ESP to all current players.
function ESP.ApplyToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        ESP.Add(player)
    end
end

-- Connect player added and removed events.
Players.PlayerAdded:Connect(ESP.Add)
Players.PlayerRemoving:Connect(ESP.Remove)
ESP.ApplyToAll()

--------------------------------------------------------------------------------
-- Return the Library
--------------------------------------------------------------------------------
return ESP
