local Fluent = loadstring(
	game:HttpGet(
		'https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'
	)
)()
local SaveManager = loadstring(
	game:HttpGet(
		'https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua'
	)
)()
local InterfaceManager = loadstring(
	game:HttpGet(
		'https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua'
	)
)()

local Window = Fluent:CreateWindow({
	Title = 'Build a Car',
	SubTitle = 'by Flames/Aura',
	TabWidth = 160,
	Size = UDim2.fromOffset(450, 320),
	Acrylic = false,
	Theme = 'Dark',
	MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
	Main = Window:AddTab({ Title = 'Main', Icon = 'shopping-cart' }),
	Settings = Window:AddTab({ Title = 'Settings', Icon = 'settings' }),
}

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local Framework = ReplicatedStorage:WaitForChild('Framework')
local Network = require(Framework.Network)
local MerchantUtil = require(Framework.Universal.MerchantUtil)
local Saving = require(Framework.Client.Saving)
local CurrencyUtil = require(Framework.Universal.CurrencyUtil)

Tabs.Main:AddButton({
	Title = 'Auto Buy All',
	Description = 'Buys all merchant items until sold out',
	Callback = function()
		local save = Saving.Get()
		if not save then
			return warn('No save data')
		end
		local serverTime = workspace:GetServerTimeNow()
			+ (save.MerchantTimeAdvance or 0)

		local offersData = MerchantUtil.GetOffers(LocalPlayer, serverTime)
		if not offersData or not offersData.Offers then
			return warn('No merchant offers')
		end

		for _, offer in ipairs(offersData.Offers) do
			local comp = offer.Component
			local price = offer.Price
			if comp and comp._id then
				local stock = MerchantUtil.GetRemainingStock(
					LocalPlayer,
					comp,
					serverTime
				)
				while
					stock > 0
					and CurrencyUtil.CanAfford(LocalPlayer, 'Cash', price)
				do
					local success = pcall(function()
						return Network.Invoke('Merchant_Purchase', comp._id)
					end)
					if not success then
						break
					end
					stock = MerchantUtil.GetRemainingStock(
						LocalPlayer,
						comp,
						workspace:GetServerTimeNow()
							+ (save.MerchantTimeAdvance or 0)
					)
					task.wait(0.15)
				end
			end
		end
		Fluent:Notify({
			Title = 'Auto Buy',
			Content = 'Finished purchasing available merchant items.',
			Duration = 5,
		})
	end,
})

Tabs.Main:AddButton({
	Title = 'Infinite Cash',
	Description = 'Gives you infinite money (requires exploit method)',
	Callback = function()
		local Players = game:GetService('Players')
		local LocalPlayer = Players.LocalPlayer
		local Character = LocalPlayer.Character
			or LocalPlayer.CharacterAdded:Wait()
		local Root = Character:WaitForChild('HumanoidRootPart')
		local Remotes = workspace
			:WaitForChild('__THINGS')
			:WaitForChild('__REMOTES')

		for _, part in ipairs(Character:GetDescendants()) do
			if part:IsA('BasePart') then
				part.Anchored = false
				part.CanCollide = true
			end
		end

		local spin = Instance.new('BodyAngularVelocity')
		spin.AngularVelocity = Vector3.new(999999, 999999, 999999)
		spin.MaxTorque = Vector3.new(1, 1, 1) * math.huge
		spin.P = math.huge
		spin.Parent = Root

		local bv = Instance.new('BodyVelocity')
		bv.Velocity = Root.CFrame.LookVector * 1500
		bv.MaxForce = Vector3.new(1, 1, 1) * 1e9
		bv.P = 1e6
		bv.Parent = Root

		print('💥 You were flung like a goddamn cannonball')

		task.delay(3, function()
			spin:Destroy()
			bv:Destroy()
		end)

		task.delay(1, function()
			local spawnRemote = Remotes:WaitForChild('vehicle_spawn')
			local success = pcall(function()
				spawnRemote:InvokeServer()
			end)
			print(
				success and '🚗 Vehicle spawn fired'
					or '❌ Failed to fire vehicle_spawn'
			)
		end)

		task.delay(11, function()
			local stopRemote = Remotes:WaitForChild('vehicle_stop')
			local success = pcall(function()
				stopRemote:InvokeServer()
			end)
			print(
				success and '🛑 Vehicle stop fired'
					or '❌ Failed to fire vehicle_stop'
			)
		end)
	end,
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder('FluentScriptHub')
SaveManager:SetFolder('FluentScriptHub/BuildACar')
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
	Title = 'Build a Car',
	Content = 'Script loaded and ready.',
	Duration = 8,
})

SaveManager:LoadAutoloadConfig()
