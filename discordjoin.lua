local discordInvite = "https://discord.com/invite/Ud55WWnahX"

local http_request = (syn and syn.request) or (http and http.request) or request
if http_request then
    http_request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = game:GetService("HttpService"):JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {code = string.match(discordInvite, "discord%.com/invite/(%w+)")},
            nonce = game:GetService("HttpService"):GenerateGUID(false)
        })
    })
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Executor Not Supported",
        Text = "Join manually: "..discordInvite,
        Duration = 5
    })
end
