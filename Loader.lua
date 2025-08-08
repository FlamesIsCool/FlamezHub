-- Table linking place IDs to their loader URLs
local scriptMappings = {
    -- LuckyBlock
    [662417684] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/luckyblockbattleground.lua",
    
    -- Murder Mystery 2
    [142823291] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/mm2script.lua",
    
    -- Tower of Hell
    [1962086868] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/TOH.lua",
    
    -- Home Run Simulator
    [11562435896] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/Home%20Run%20Simulator.lua",
    
    -- Money Race
    [13529953420] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/Money%20Race.lua",
    
    -- RIVALS
    [5678901234] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/rivals.lua",
    
    -- Bridge Builders
    [101419624822516] = "https://api.luarmor.net/files/v3/loaders/e0f091812777232dbd17eb33578f97d0.lua",
    
    -- HideOrDie
    [18799085098] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/HideOrDie.lua",
    
    -- Build a Car
    [88728793053496] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/build%20a%20car.lua",
    
    -- Shrink Hide and Seek
    [137541498231955] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/shrink%20hide%20and%20seek.lua",
    
    -- Build a Plane (BLOOD MOON AUTOFARM)
    [137925884276740] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/build%20a%20plane%20blood.lua",

    -- your actual keyboard
    [92777117358647] = "https://raw.githubusercontent.com/FlamesIsCool/FlamezHub/refs/heads/main/your%20actual%20keyboard.lua",
}

-- Check the current PlaceId and fetch the matching script
local currentId = game.PlaceId
if scriptMappings[currentId] then
    local url = scriptMappings[currentId]
    local scriptContent = game:HttpGet(url)
    loadstring(scriptContent)()
else
    warn("No script found for this PlaceId:", currentId)
end
