
local VALID_KEY_B64 = "YnJpZGdlYnVpbGRlcnNfMTIzY3hnMjMxMzNkZg=="
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/bridge_builders.lua"
local KEY_LINK = "https://workink.net/1RvP/udgb880w"

local function decodeBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = data:gsub('[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Window = Library:CreateWindow({
    Title = "🔐 Key System",
    Footer = "Enter Key to Continue",
    Icon = 95816097006870,
    NotifySide = "Right",
})

local Tabs = {
    Key = Window:AddTab("Key", "lock"),
}

local KeyGroup = Tabs.Key:AddLeftGroupbox("Enter Key")

KeyGroup:AddLabel("Enter your key below to unlock the script:")

KeyGroup:AddInput("UserKeyInput", {
    Placeholder = "Paste key here...",
    Text = "Access Key",
    ClearTextOnFocus = true,
})

KeyGroup:AddButton("Submit Key", function()
    local userKey = Options.UserKeyInput.Value
    local realKey = decodeBase64(VALID_KEY_B64)

    if userKey == realKey then
        Library:Notify("✅ Correct key! Loading script...", 3)
        task.wait(1)
        Library:Unload()

        local success, result = pcall(function()
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        end)

        if not success then
            warn("❌ Failed to load script:", result)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Load Failed",
                Text = "Could not load main script.",
                Duration = 5,
            })
        end
    else
        Library:Notify("❌ Invalid key. Try again.", 3)
    end
end)

KeyGroup:AddButton("Copy Key Link", function()
    setclipboard(KEY_LINK)
    Library:Notify("✅ Key link copied to clipboard.", 3)
end)
