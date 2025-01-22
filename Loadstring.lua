local placeId = game.PlaceId

local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))();
local Notify = AkaliNotif.Notify;

if placeId == 17625359962 then --rivals
loadstring(game:HttpGet('https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/rivals.lua'))()

elseif placeId == 662417684 then --luckyblockbattleground
    loadstring(game:HttpGet('https://raw.githubusercontent.com/FlamesGamesO/FlamezHub/refs/heads/main/luckyblockbattleground.lua'))()
  
else
    warn("No specific script found for this game!")
    Notify({
        Title = "Unsupported Game",
        Description = "This game isn't directly supported by the script. Ensure you're in the right game or await future updates.",
        Duration = 50
    });
end
