local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Flamez - Rivals",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Flamez - Rivals",
   LoadingSubtitle = "by Flames",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Flamez Hub"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "5c9D3VD7se", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Flamez - Key System",
      Subtitle = "Key System",
      Note = "The key is provided in the discord", -- Use this to tell the user how to get a key
      FileName = "flamezkey", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local AimingTab = Window:CreateTab("Aiming", "crosshair")
local VisualsTab = Window:CreateTab("visuals", "eye")

-- Divider for UI organization
local Divider = AimingTab:CreateDivider()

-- Dropdown for selecting aiming part
local Dropdown = AimingTab:CreateDropdown({
    Name = "Select Aiming Part",
    Options = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "AimingPartDropdown",
    Callback = function(Options)
        selected_part = Options[1]
    end,
})

local selected_part = "Head" -- Default aiming part

-- Services and variables
local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local camera = workspace.CurrentCamera

-- Safely load the Utility module
local utility
local success, err = pcall(function()
    utility = require(replicated_storage:WaitForChild("Modules"):WaitForChild("Utility"))
end)

if not success then
    warn("Failed to load Utility module:", err)
    return
end

if not utility.Raycast then
    warn("Raycast method not found in Utility module")
    return
end

-- Function to get all potential targets
local function get_players()
    local entities = {}
    for _, child in workspace:GetChildren() do
        if child:FindFirstChildOfClass("Humanoid") then
            table.insert(entities, child)
        elseif child.Name == "HurtEffect" then
            for _, hurt_player in child:GetChildren() do
                if hurt_player.ClassName ~= "Highlight" then
                    table.insert(entities, hurt_player)
                end
            end
        end
    end
    return entities
end

-- Function to find the closest player to the crosshair
local function get_closest_player()
    local closest, closest_distance = nil, math.huge
    local character = players.LocalPlayer.Character

    if not character then
        return
    end

    for _, player in get_players() do
        if player == players.LocalPlayer then
            continue
        end

        local aiming_part = player:FindFirstChild(selected_part)

        if not aiming_part then
            continue
        end

        local position, on_screen = camera:WorldToViewportPoint(aiming_part.Position)

        if not on_screen then
            continue
        end

        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local distance = (center - Vector2.new(position.X, position.Y)).Magnitude

        if distance > closest_distance then
            continue
        end

        closest = player
        closest_distance = distance
    end
    return closest
end

-- Silent Aim Toggle
local old = utility.Raycast -- Safely store original Raycast function
local SilentAimToggle = AimingTab:CreateToggle({
    Name = "Enable Silent Aim",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        if Value then
            utility.Raycast = function(...)
                local arguments = {...}

                if (#arguments > 0 and arguments[4] == 999) then
                    local closest = get_closest_player()

                    if closest and closest:FindFirstChild(selected_part) then
                        arguments[3] = closest[selected_part].Position
                    end
                end
                return old(table.unpack(arguments))
            end
        else
            utility.Raycast = old -- Restore original Raycast
        end
    end,
})

-- Divider for separation
local Divider = AimingTab:CreateDivider()

-- Regular Aimbot Variables
local target_locked = false -- Tracks if a target is locked
local locked_target = nil -- The current locked-on target

-- Function to lock on or unlock a target
local function toggle_lock()
    if target_locked then
        target_locked = false
        locked_target = nil
    else
        locked_target = get_closest_player()
        if locked_target then
            target_locked = true
        end
    end
end

-- Keybind for locking onto a target
local AimbotKeybind = AimingTab:CreateKeybind({
    Name = "Aimbot Lock Keybind",
    CurrentKeybind = "Q",
    HoldToInteract = false,
    Flag = "AimbotLockKeybind",
    Callback = function()
        toggle_lock()
    end,
})

-- Regular Aimbot Toggle
local RegularAimbotToggle = AimingTab:CreateToggle({
    Name = "Enable Aimbot(BROKEN RIGHT NOW)",
    CurrentValue = false,
    Flag = "RegularAimbotToggle",
    Callback = function(Value)
        if Value then
            game:GetService("RunService").RenderStepped:Connect(function()
                if target_locked and locked_target and locked_target:FindFirstChild(selected_part) then
                    local target_part = locked_target[selected_part]
                    if target_part then
                        camera.CFrame = CFrame.new(camera.CFrame.Position, target_part.Position)
                    end
                end
            end)
        else
            target_locked = false
            locked_target = nil
        end
    end,
})

-- 1. Load the Sense ESP Library
local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()

-- Divider for ESP Settings
local Divider = VisualsTab:CreateDivider()

-- Initialize Default Configuration
Sense.teamSettings.enemy.enabled = true -- Allow enemy ESP

-- Helper function to create toggles for boolean settings
local function createBooleanToggle(tab, name, settingPath, default)
    tab:CreateToggle({
        Name = name,
        CurrentValue = default or false,
        Flag = name .. "Toggle", -- Unique flag for each toggle
        Callback = function(Value)
            -- Access the correct settings table
            local settings = Sense.teamSettings.enemy

            -- Traverse to the desired setting
            for i = 1, #settingPath - 1 do
                settings = settings[settingPath[i]]
            end

            -- Set the value of the last setting
            settings[settingPath[#settingPath]] = Value
        end,
    })
end

-- Helper function to create color pickers
local function createColorPicker(tab, name, settingPath, defaultColor)
    tab:CreateColorPicker({
        Name = name,
        Color = defaultColor,
        Flag = name .. "ColorPicker", -- Unique flag for each color picker
        Callback = function(Value)
            -- Access the correct settings table
            local settings = Sense.teamSettings.enemy

            -- Traverse to the desired setting
            for i = 1, #settingPath - 1 do
                settings = settings[settingPath[i]]
            end

            -- Set the color
            settings[settingPath[#settingPath]][1] = Value
        end,
    })
end

-- Enemy ESP Toggles with Color Pickers
createBooleanToggle(VisualsTab, "Enable Box ESP", {"box"}, false)
createColorPicker(VisualsTab, "Box ESP Color", {"boxColor"}, Color3.new(0, 0.25, 0.75))

createBooleanToggle(VisualsTab, "Enable 3D Box ESP", {"box3d"}, false)
createColorPicker(VisualsTab, "3D Box ESP Color", {"box3dColor"}, Color3.new(1, 0, 0))

createBooleanToggle(VisualsTab, "Enable Tracers", {"tracer"}, false)
createColorPicker(VisualsTab, "Tracers Color", {"tracerColor"}, Color3.new(1, 0, 0))

createBooleanToggle(VisualsTab, "Show Player Names", {"name"}, false)
createColorPicker(VisualsTab, "Player Name Color", {"nameColor"}, Color3.new(1, 1, 1))

createBooleanToggle(VisualsTab, "Show Health Bar", {"healthBar"}, false)
createColorPicker(VisualsTab, "Health Bar Color (Healthy)", {"healthyColor"}, Color3.new(0, 1, 0))
createColorPicker(VisualsTab, "Health Bar Color (Dying)", {"dyingColor"}, Color3.new(1, 0, 0))

createBooleanToggle(VisualsTab, "Show Weapon ESP", {"weapon"}, false)
createColorPicker(VisualsTab, "Weapon ESP Color", {"weaponColor"}, Color3.new(1, 1, 1))

createBooleanToggle(VisualsTab, "Enable Off-Screen Arrows", {"offScreenArrow"}, false)
createColorPicker(VisualsTab, "Off-Screen Arrow Color", {"offScreenArrowColor"}, Color3.new(1, 1, 1))

-- Load ESP
Sense.Load()

-- Unload ESP Button
VisualsTab:CreateButton({
    Name = "Unload ESP",
    Callback = function()
        Sense.Unload()
    end,
})
