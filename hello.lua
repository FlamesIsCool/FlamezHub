local SCRIPT_ID = "e0f091812777232dbd17eb33578f97d0"
local LOADER_URL = "https://api.luarmor.net/files/v3/loaders/" .. SCRIPT_ID .. ".lua"
local KEY_LINK = "https://ads.luarmor.net/v/cb/aryRIsTZeyhR/oHpqgwldFDpwBXeB"

local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
api.script_id = SCRIPT_ID

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options

local Window = Library:CreateWindow({
    Title = "🔐 Luarmor Key System",
    Footer = "Complete the ad checkpoint and paste your key",
    Center = true,
    AutoShow = true,
})

local tab = Window:AddTab("Key", "lock")
local grp = tab:AddLeftGroupbox("Get Your Script Key")

grp:AddLabel("1️⃣ Click to copy the key link:")
grp:AddButton("🌐 Copy Key Link", function()
    setclipboard(KEY_LINK)
    Library:Notify("Link copied! Complete it in browser…", 4)
end)

grp:AddLabel("2️⃣ Enter your Luarmor key below:")
grp:AddInput("UserKeyInput", {
    Placeholder = "Your Luarmor key here...",
    ClearTextOnFocus = true,
})

grp:AddButton("✅ Submit Key", function()
    local key = Options.UserKeyInput.Value
    if not key or #key < 10 then
        return Library:Notify("❌ Paste a valid key!", 3)
    end

    Library:Notify("🔍 Verifying key…", 3)
    local status = api.check_key(key)
    if status.code == "KEY_VALID" then
        Library:Notify("✅ Valid key! Loading script…", 3)
        task.wait(1)
        getgenv().script_key = key
        Library:Unload()
        loadstring(game:HttpGet(LOADER_URL))()
    else
        Library:Notify("❌ Key error: " .. status.message, 5)
    end
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyTheme("Dracula")
SaveManager:BuildConfigSection(tab)
