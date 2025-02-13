local scripts = {
    ["Murder Mystery 2"] = "https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/mm2script.lua",
    ["Home Run Simulator"] = "https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/Home%20Run%20Simulator.lua",
    ["Tower Of Hell"] = "https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/TOH.lua",
    ["Money Race"] = "https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/Money%20Race.lua",
    ["Stud Long Jumps Obby"] = "https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/StudLongJumps.lua",
    ["RIVALS"] = "https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/rivals.lua",
    ["Get Big Simulator"] = "https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/getbigsim.lua"
}

local gameLinks = {
    ["Murder Mystery 2"] = 142823291,
    ["Home Run Simulator"] = 11562435896,
    ["Tower Of Hell"] = 1962086868,
    ["Money Race"] = 13529953420,
    ["Stud Long Jumps Obby"] = 12062249395,
    ["RIVALS"] = 17625359962,
    ["Get Big Simulator"] = 13675842775
}

local found = false

for gameName, gameId in pairs(gameLinks) do
    if game.GameId == gameId then
        found = true
        print("Executing script for: " .. gameName)
        loadstring(game:HttpGet(scripts[gameName], true))()
        break
    end
end

if not found then
    game.StarterGui:SetCore("SendNotification", {
        Title = "SwirlHub",
        Text = "Game not supported!",
        Duration = 5
    })
end
