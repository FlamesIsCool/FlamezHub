local EspLib = {}

local Players = game:GetService("Players")

local highlights = {}
local espEnabled = false

local config = {
    TeamCheck = false,
    RefreshRate = 0.2,
    TargetPlayers = true,
    TargetOthers = {}, -- NPCs or models
    FillColor = Color3.fromRGB(255, 0, 0),
    FillTransparency = 0.5,
    OutlineColor = Color3.fromRGB(255, 255, 255),
    OutlineTransparency = 0,
    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
}

function EspLib:Config(opts)
    for k, v in pairs(opts) do
        config[k] = v
    end
end

function EspLib:Clear()
    for _, v in pairs(highlights) do
        if v and v.Destroy then
            v:Destroy()
        end
    end
    table.clear(highlights)
end

function EspLib:Refresh()
    self:Clear()

    if config.TargetPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if config.TeamCheck and plr.Team == Players.LocalPlayer.Team then
                    continue
                end

                local hl = Instance.new("Highlight")
                hl.Name = "ESP_Highlight"
                hl.Adornee = plr.Character
                hl.FillColor = config.FillColor
                hl.FillTransparency = config.FillTransparency
                hl.OutlineColor = config.OutlineColor
                hl.OutlineTransparency = config.OutlineTransparency
                hl.DepthMode = config.DepthMode
                hl.Parent = plr.Character

                highlights[plr] = hl
            end
        end
    end

    for _, inst in ipairs(config.TargetOthers) do
        if inst and (inst:IsA("Model") or inst:IsA("Part")) then
            local target = inst:IsA("Model") and inst or inst.Parent
            if target and target:IsA("Model") then
                local hl = Instance.new("Highlight")
                hl.Name = "ESP_Highlight"
                hl.Adornee = target
                hl.FillColor = config.FillColor
                hl.FillTransparency = config.FillTransparency
                hl.OutlineColor = config.OutlineColor
                hl.OutlineTransparency = config.OutlineTransparency
                hl.DepthMode = config.DepthMode
                hl.Parent = target

                highlights[target] = hl
            end
        end
    end
end

function EspLib:Enable()
    if espEnabled then return end
    espEnabled = true

    task.spawn(function()
        while espEnabled do
            self:Refresh()
            task.wait(config.RefreshRate)
        end
    end)
end

function EspLib:Disable()
    espEnabled = false
    self:Clear()
end

function EspLib:Toggle()
    if espEnabled then
        self:Disable()
    else
        self:Enable()
    end
end

return EspLib
