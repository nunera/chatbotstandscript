--all lowercase and include the executor account too
local allwhitelisted = false

local whitelist = {
    "jeronimoxfelinor",
    "blatantdefiance"
}
local baseplate = true
local bringphrase = "Penguin, analysis."
local dismissphrase = "Affirmative."

local plrs = game:GetService("Players")
local allplrs = plrs:GetChildren()
local whitelistsingame = {}

print("Chat bot stand activated!")
local HttpService = game:GetService("HttpService")
local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humpart = char:WaitForChild("HumanoidRootPart")
local tweenservice = game:GetService("TweenService")
local tweeninfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local istweeninfo = TweenInfo.new(.01, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

--EVENTUALLY WANT TO WELD INSTEAD OF CFRAME LOOP
_G.is = false
local partpos = Vector3.new(5.741, 150.286, 21.387)
local personCFrame = CFrame.new(5.74100018, 160.2860031, 21.3869991, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local plrs = game:GetService("Players")
function getChat(message, plrname)
    local apiKey = "YOUR_OPENAI_API_KEY" 
    local endpoint = "https://api.openai.com/v1/completions"
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. apiKey
    }
    local chatHistory = {}  -- Store the conversation history 

    local data = {
        model = "gpt-3.5-turbo-0125",
        messages = chatHistory, -- Include previous messages
        max_tokens = 100 
    }
    local jsonData = HttpService:JSONEncode(data)
    local response = HttpService:RequestAsync({
        Url = endpoint,
        Method = "POST",
        Headers = headers,
        Body = jsonData
    })
    if response.Success then
        local decoded = HttpService:JSONDecode(response.Body)
        if decoded.choices then
            local chatResponse = decoded.choices[1].message.content
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(chatResponse, "All")
            table.insert(chatHistory, {role = "user", content = message}) -- Add user message
            table.insert(chatHistory, {role = "assistant", content = chatResponse}) -- Add bot response
        end
    else
        print("OpenAI API request failed: ", response.StatusCode, response.Body)
    end
end
function clearChatHistory()
    chatHistory = {}
end
local function tween(plr)
    if _G.is then
        while _G.is do
            local whitelistcframe = plr.Character.HumanoidRootPart.CFrame
            local offset = CFrame.new(3, 0, 3)
            local newcframe = whitelistcframe:ToWorldSpace(offset)
            local tween = tweenservice:Create(humpart, istweeninfo, {CFrame = newcframe})
            tween:Play()
            wait(.01)
        end
    else
        local tween = tweenservice:Create(humpart, tweeninfo, {CFrame = personCFrame})
        tween:Play()
    end
end
if baseplate then
    local part = Instance.new("Part")
    part.Parent = workspace
    part.Anchored = true
    part.Position = partpos
    part.Size = Vector3.new(5, 1, 5)
    wait(2)
    tween()
end
player.Chatted:Connect(
    function(text)
        local split = string.split(text, " ")
        if split[1] == "!analysis" then
            local plr = split[2]
            for i, v in pairs(game.Players:GetChildren()) do
                local newplr = v.Name
                local low = string.lower(newplr)
                if plr == low then
                    _G.is = true
                    tween(v)
                end
            end
        end
        if split[1] == "!affirmative" then
            _G.is = false
            clearChatHistory()
            if baseplate then
                tween()
            end
        end
    end
)
local function log()
    for i, plr in pairs(allplrs) do
        local newplayer = string.lower(plr.Name)
        if table.find(whitelist, newplayer) or allwhitelisted then
            table.insert(whitelistsingame, newplayer)
            print(newplayer, "is whitelisted!")
            local list = string.lower(plr.Name)
            plr.Chatted:Connect(
                function(mes)
                    if table.find(whitelistsingame, newplayer) or allwhitelisted then
                        local sep = string.split(mes, " ")
                        if mes == bringphrase and not _G.is then
                            _G.is = true
                            coroutine.resume(coroutine.create(tween(plr)))
                        end
                        if _G.is then
                            if mes == dismissphrase then
                                _G.is = false
                                clearChatHistory()
                                if baseplate then
                                    tween()
                                end
                            else
                                getChat(mes, plr.Name)
                            end
                        end
                    end
                end
            )
        end
    end
end
log()
game.Players.PlayerAdded:Connect(log())
