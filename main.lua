print([[

               _      _ _           _     
              (_)    | | |         | |    
  _____      ___ _ __| | |__  _   _| |__  
 / __\ \ /\ / / | '__| | '_ \| | | | '_ \ 
 \__ \\ V  V /| | |  | | | | | |_| | |_) |
 |___/ \_/\_/ |_|_|  |_|_| |_|\__,_|_.__/ 

   🌊 SwirlHub - The Best ScriptHub 🚀
--------------------------------------------------
   🔑 Scripts are open source
   🌍 Join our Discord & unlock premium scripts.
   ⚡ Works for any running executor
--------------------------------------------------
   💡 Created by Flames 🔥

]])


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "🌌 SwirlHub - Key System",
    SubTitle = "by Flames",
    TabWidth = 170,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Key System", Icon = "key" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "👋 Welcome!",
    Content = "Complete the process to access the script!",
    Duration = 5,
    Type = "info"
})

-- 🌟 Key System UI
local KeySection = Tabs.Main:AddSection("🔐 Key Authentication")

KeySection:AddParagraph({
    Title = "📜 How to Access the Script",
    Content = "Click the button below to copy the verification link. Open it in your browser, complete the steps, and you'll be invited to our Discord where the script is located."
})

KeySection:AddButton({
    Title = "📋 Copy Link",
    Description = "Click to copy the verification link to your clipboard.",
    Callback = function()
        setclipboard("https://workink.net/1RvP/jv4dmmw0")
        Fluent:Notify({
            Title = "✅ Link Copied!",
            Content = "Paste it in your browser and follow the steps.",
            Duration = 4,
            Type = "success"
        })
    end
})

KeySection:AddParagraph({
    Title = "📢 Instructions",
    Content = "Once you've completed the process, you'll be redirected to our Discord where you can access the script. Make sure to follow all the instructions carefully!"
})


Fluent:Notify({
    Title = "✅ SwirlHub",
    Content = "Key system successfully loaded!",
    Duration = 5,
    Type = "success"
})
