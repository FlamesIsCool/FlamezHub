local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager =
	loadstring(
		game:HttpGet(repo .. 'addons/ThemeManager.lua')
	)()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
	Title = 'FlameHub - Cash Tycoon',
	Footer = 'Game: Cash Tycoon',
	Icon = 0,
	NotifySide = 'Right',
	ShowCustomCursor = true,
})

local Tabs = {
	Main = Window:AddTab('Main', 'terminal'),
	['UI Settings'] = Window:AddTab('UI Settings', 'settings'),
}

local MainGroup = Tabs.Main:AddLeftGroupbox('Auto Features')

-- Auto Claim Money Toggle
MainGroup:AddToggle('AutoClaimMoney', {
	Text = 'Auto Claim Money',
	Default = false,
	Tooltip = 'Automatically claims money using TimedRewardService',
	Callback = function(Value)
		if Value then
			getgenv().ClaimSpam = task.spawn(function()
				local Claim = game
					:GetService('ReplicatedStorage')
					:WaitForChild('Packages')
					:WaitForChild('_Index')
					:WaitForChild('dazzycoin_knit@0.1.6')
					:WaitForChild('knit')
					:WaitForChild('Services')
					:WaitForChild('TimedRewardService')
					:WaitForChild('RF')
					:WaitForChild('Claim')

				while Toggles.AutoClaimMoney.Value do
					pcall(function()
						Claim:InvokeServer(1)
					end)
					task.wait(0.1)
				end
			end)
		else
			if getgenv().ClaimSpam then
				task.cancel(getgenv().ClaimSpam)
			end
		end
	end,
})

-- Auto Buy Buttons Toggle
MainGroup:AddToggle('AutoBuyButtons', {
	Text = 'Auto Buy Buttons',
	Default = false,
	Tooltip = 'Automatically touches the cheapest button you can afford',
	Callback = function(Value)
		if Value then
			getgenv().AutoBuyLoop = task.spawn(function()
				local Knit = require(
					game
						:GetService('ReplicatedStorage')
						:WaitForChild('Packages')
						:WaitForChild('Knit')
				)
				local DataController = Knit.GetController('DataController')

				while Toggles.AutoBuyButtons.Value do
					local buttons = {}
					for _, plot in pairs(workspace:WaitForChild('Plots'):GetDescendants()) do
						if
							plot:GetAttribute('Owner') == Knit.Player.UserId
							and plot:IsA('Model')
							and plot:GetAttribute('Cost')
						then
							table.insert(buttons, plot)
						end
					end

					local cheapest = nil
					for _, btn in pairs(buttons) do
						local cost = btn:GetAttribute('Cost')
						if
							cost
							and DataController:GetValue({ 'Cash' }) >= cost
						then
							if
								not cheapest
								or cost < cheapest:GetAttribute('Cost')
							then
								cheapest = btn
							end
						end
					end

					if cheapest then
						local touch = cheapest:FindFirstChild('_TOUCH')
						if touch then
							firetouchinterest(
								game.Players.LocalPlayer.Character.HumanoidRootPart,
								touch,
								0
							)
							task.wait(0.1)
							firetouchinterest(
								game.Players.LocalPlayer.Character.HumanoidRootPart,
								touch,
								1
							)
						end
					end

					task.wait(0.5)
				end
			end)
		else
			if getgenv().AutoBuyLoop then
				task.cancel(getgenv().AutoBuyLoop)
			end
		end
	end,
})

-- Force a black and white theme
ThemeManager:SetLibrary(Library)
ThemeManager:ApplyTheme({
	Font = Enum.Font.SourceSans,
	TextColor = Color3.new(1, 1, 1),
	MainBackgroundColor = Color3.new(0.1, 0.1, 0.1),
	BackgroundColor = Color3.new(0.12, 0.12, 0.12),
	AccentColor = Color3.new(1, 1, 1),
	OutlineColor = Color3.new(0.2, 0.2, 0.2),
	BorderColor = Color3.new(0, 0, 0),
	TabBackgroundColor = Color3.new(0.08, 0.08, 0.08),
})

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('FlameHub')
SaveManager:SetFolder('FlameHub/CashTycoon')
SaveManager:SetSubFolder('Main')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

Library:Notify('FlameHub loaded for Cash Tycoon', 3)
