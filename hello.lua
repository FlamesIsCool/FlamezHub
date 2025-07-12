-- 🔑 CONFIG
local VALID_KEY = 'bridgebuilders_123cxg23133df'
local MAIN_SCRIPT_URL =
    'https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/bridge_builders.lua'
local KEY_LINK = 'https://workink.net/1RvP/udgb880w'

-- ⚙️ Linoria UI setup
local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = Library.Options
local Window = Library:CreateWindow({
    Title = '🔐 Key System',
    Footer = 'Enter Key to Continue',
    Icon = 95816097006870,
    NotifySide = 'Right',
})

local Tabs = {
    Key = Window:AddTab('Key', 'lock'),
}

local KeyGroup = Tabs.Key:AddLeftGroupbox('Enter Key')

KeyGroup:AddLabel('Enter your key below to unlock the script:')

KeyGroup:AddInput('UserKeyInput', {
    Placeholder = 'Paste key here...',
    Text = 'Access Key',
    ClearTextOnFocus = true,
})

KeyGroup:AddButton('Submit Key', function()
    local key = Options.UserKeyInput.Value
    if key == VALID_KEY then
        Library:Notify('✅ Correct key! Loading script...', 3)
        task.wait(1)
        Library:Unload()

        local success, result = pcall(function()
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        end)

        if not success then
            warn('❌ Failed to load script:', result)
            game:GetService('StarterGui'):SetCore('SendNotification', {
                Title = 'Load Failed',
                Text = 'Could not load main script.',
                Duration = 5,
            })
        end
    else
        Library:Notify('❌ Invalid key. Try again.', 3)
    end
end)

-- 📋 Copy Key Link Button
KeyGroup:AddButton('Copy Key Link', function()
    setclipboard(KEY_LINK)
    Library:Notify('✅ Key link copied to clipboard.', 3)
end)
