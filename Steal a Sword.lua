local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager =
    loadstring(
        game:HttpGet(repo .. 'addons/ThemeManager.lua')
    )()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = Library.Options

local Window = Library:CreateWindow({
    Title = 'Steal a Sword',
    Footer = 'FlameHub v1.0',
    Icon = 95816097006870,
    NotifySide = 'Right',
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab('Main', 'sword'),
    ['UI Settings'] = Window:AddTab('UI Settings', 'settings'),
}

local DropdownGroupBox = Tabs.Main:AddRightGroupbox('Weapon Selector')

local allWeapons = {
    -- Common
    'Wooden Sword',
    'Plunger',
    'Rake',
    'Bat',
    'Bamboo Staff',
    -- Uncommon
    'Shovel',
    'Boxing Glove',
    'Bone Club',
    'Axe',
    'Stop Sign',
    -- Rare
    'Katana',
    'Pitchfork',
    'Morning Star',
    'Icicle',
    'Hammer',
    -- Legendary
    'Inferno Blade',
    'Ice Blade',
    'Dragon Spear',
    'Shadow Scythe',
    'Thunder Hammer',
    -- Mythical
    'Bloodvine Axe',
    'Mystic Reaper',
    'Heavens Halberd',
}

DropdownGroupBox:AddDropdown('WeaponDropdown', {
    Values = allWeapons,
    Default = 1,
    Multi = false,
    Searchable = true,
    Text = 'Select Weapon',
    Tooltip = 'Pick a weapon to add to your base',

    Callback = function(selectedWeapon)
        local args = { selectedWeapon }
        game
            :GetService('ReplicatedStorage')
            :WaitForChild('Events')
            :WaitForChild('AddWeaponToBase')
            :FireServer(unpack(args))
        Library:Notify('Added: ' .. selectedWeapon, 3)
    end,
})

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddToggle('ShowCustomCursor', {
    Text = 'Custom Cursor',
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown('NotificationSide', {
    Values = { 'Left', 'Right' },
    Default = 'Right',
    Text = 'Notification Side',
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown('DPIDropdown', {
    Values = { '50%', '75%', '100%', '125%', '150%', '175%', '200%' },
    Default = '100%',
    Text = 'DPI Scale',
    Callback = function(Value)
        Value = Value:gsub('%%', '')
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})

MenuGroup:AddLabel('Menu keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind',
})

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('FlameHub')
SaveManager:SetFolder('FlameHub/Game')
SaveManager:SetSubFolder('BaseWeapons')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
