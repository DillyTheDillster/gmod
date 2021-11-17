if not SERVER then return end

util.AddNetworkString("Lotto_Lang")
util.AddNetworkString("Lotto_OpenMenu")
util.AddNetworkString("Lotto_GuessNumber")
util.AddNetworkString("Lotto_Lottery")

function Lotto:GetLang(lang, ...)
    local lang = Lotto.Lang[lang] or "<INVALID LANG>"
    return string.format(lang, ...)
end

function Lotto:SetPot(potamount)
    if not tonumber(potamount) then return end
    if not Lotto.Started then Lotto.EndLotto = CurTime() + Lotto.LottoDuration end
    SetGlobalInt("CurrentPot", potamount)
    for _, ply in pairs(player.GetAll()) do
        ply:SendLua([[Lotto:Msg(Lotto:GetLang("PotSet", "]] .. potamount .. [["))]])
        ply:SendLua([[Lotto:Msg(Lotto:GetLang("ToJoin", "]] .. Lotto.ChatPrefix .. Lotto.ChatLottoCmd .. [["))]])
    end

    file.CreateDir("lotto")
    local joined = file.Read("lotto/joined.txt", "DATA") or "{}"
    joined = util.JSONToTable(joined)
    joined["CurrentPot"] = GetGlobalInt("CurrentPot", potamount)
    joined = util.TableToJSON(joined)
    file.Write("lotto/joined.txt", joined)
end

function Lotto:Join(sid)
    file.CreateDir("lotto")
    local joined = file.Read("lotto/joined.txt", "DATA") or "{}"
    joined = util.JSONToTable(joined)
    joined[sid] = true
    joined["CurrentPot"] = GetGlobalInt("CurrentPot", potamount)
    joined = util.TableToJSON(joined)
    file.Write("lotto/joined.txt", joined)
end

Lotto.GetOnline = Lotto.GetOnline or {}
hook.Add("PlayerInitialSpawn", "LottoReward", function(ply)
    if Lotto.GetOnline[ply:SteamID()] then ply:PS2_AddStandardPoints(Lotto.GetOnline[ply:SteamID()], "Lottery win", false) Lotto.GetOnline[ply:SteamID()] = nil end
end)

local runned = false
hook.Add("Think", "LottoCheck", function()
    hook.Remove("Think", "LottoCheck")
    timer.Create("LottoCheck",30, 1, function()
        if file.Exists("lotto/joined.txt", "DATA") then
            local joined = file.Read("lotto/joined.txt", "DATA") or "{}"
            joined = util.JSONToTable(joined)
            if table.Count(joined) == 0 then return end
            local pot = joined["CurrentPot"]
            joined["CurrentPot"] = nil
            local val, randomSid = table.Random(joined)
            if not player.GetBySteamID(randomSid) then
                Lotto.GetOnline[randomSid] = pot
            else
                player.GetBySteamID(randomSid):PS2_AddStandardPoints(pot, "Lottery win", false)
            end
            file.Write("lotto/joined.txt", "{}")
        end
    end)
end)

hook.Add("Think", "LottoEnd", function()
    if Lotto.EndLotto and Lotto.EndLotto < CurTime() then
        Lotto.EndLotto = nil
        SetGlobalInt("CurrentPot", 0)
        if file.Exists("lotto/joined.txt", "DATA") then
            local joined = file.Read("lotto/joined.txt", "DATA") or "{}"
            joined = util.JSONToTable(joined)
            if table.Count(joined) == 0 then
                for _, ply in pairs(player.GetAll()) do
                    ply:SendLua([[Lotto:Msg(Lotto:GetLang("NoWinner"))]])
                end
                file.Write("lotto/joined.txt", "{}")
                return
            end
            local pot = joined["CurrentPot"]
            joined["CurrentPot"] = nil
            local val, randomSid = table.Random(joined)
            if not player.GetBySteamID(randomSid) then
                Lotto.GetOnline[randomSid] = pot
                for _, ply in pairs(player.GetAll()) do
                    ply:SendLua([[Lotto:Msg(Lotto:GetLang("LottoEnd", "<NOT ONLINE>", ]] .. pot .. [[))]])
                end
            else
                player.GetBySteamID(randomSid):PS2_AddStandardPoints(pot, "Lottery win", false)
                for _, ply in pairs(player.GetAll()) do
                    ply:SendLua([[Lotto:Msg(Lotto:GetLang("LottoEnd", "]] .. player.GetBySteamID(randomSid):Name() .. [[", "]] .. pot .. [["))]])
                end
            end
            file.Write("lotto/joined.txt", "{}")
        end
    end
end)

net.Receive("Lotto_Lottery", function(len, ply)
    local errorMsg
    if ply.PS2Wallet and ply.PS2Wallet.points < Lotto.LottoEnterPrice then errorMsg = "You dont have enough money!" return end
    file.CreateDir("lotto")
    local joined = file.Read("lotto/joined.txt", "DATA") or "{}"
    joined = util.JSONToTable(joined)
    if joined[ply:SteamID()] then errorMsg = "You have already joined!" end

    if errorMsg then
        ply:SendLua([[Lotto:Msg("]] .. errorMsg .. [[")]])
        return
    end

    ply:PS2_AddStandardPoints(-Lotto.LottoEnterPrice, "Lottery price", false)
    Lotto:SetPot(GetGlobalInt("CurrentPot", 0) + Lotto.LottoEnterPrice)
    Lotto:Join(ply:SteamID())
end)

net.Receive("Lotto_GuessNumber", function(len, ply)
     local number1 = net.ReadUInt(16)
     local number2 = net.ReadUInt(16)
     local number3 = net.ReadUInt(16)

     local errorMsg
     if number1 > 20 or number1 < 1 then errorMsg = "One of the numbers was too high (needs to be between 1-20)" end
     if number2 > 20 or number2 < 1 then errorMsg = "One of the numbers was too high (needs to be between 1-20)" end
     if number3 > 20 or number3 < 1 then errorMsg = "One of the numbers was too high (needs to be between 1-20)" end
     if ply.PS2Wallet and ply.PS2Wallet.points < Lotto.GuessEnterPrice then errorMsg = "You dont have enough money!" return end

     if errorMsg then
         ply:SendLua([[Lotto:Msg("]] .. errorMsg .. [[")]])
         return
     end

     ply:PS2_AddStandardPoints(-Lotto.GuessEnterPrice, "Guess the number price", false)
     local new1, new2, new3 = math.random(1, 20), math.random(1, 20), math.random(1, 20)
     local numbersRight = 0

     if new1 == number1 then numbersRight = numbersRight + 1 end
     if new2 == number2 then numbersRight = numbersRight + 1 end
     if new3 == number3 then numbersRight = numbersRight + 1 end

     local value
     if numbersRight == 1 then
         value = Lotto.Guess1RightMultiplier
     elseif numbersRight == 2 then
         value = Lotto.Guess2RightMultiplier
     elseif numbersRight == 3 then
         value = Lotto.Guess3RightMultiplier
     end

     if value then
         local win = Lotto.GuessEnterPrice * value
         ply:PS2_AddStandardPoints(win, "Guess the number win", false)
         ply:SendLua([[Lotto:Msg(Lotto:GetLang("Guess_Won", "]] .. win .. [["))]])
     else
         ply:SendLua([[Lotto:Msg(Lotto:GetLang("Guess_Lost"))]])
     end
end)

hook.Add("PlayerSay", "Lotto_ChatCmds", function(ply, text, teamChat)
    if not string.StartWith(text, Lotto.ChatPrefix) then return end
    local cmd = string.Explode(" ", text)
    cmd = string.sub(cmd[1], 2, string.len(cmd[1]))

    if cmd == Lotto.ChatLottoCmd then
        net.Start("Lotto_OpenMenu")
        net.Send(ply)
        if Lotto.HideChatCmds then
            return ""
        end
    elseif cmd == Lotto.ChatPotCmd then
        local args = string.Explode(" ", text)
        if not args or #args < 2 then ply:SendLua([[Lotto:Msg("You didn't enter pot amount!")]]) return end
        local potamount = args[2]
        if not tonumber(potamount) then ply:SendLua([[Lotto:Msg("The pot amount is not a number!")]]) return end
        potamount = tonumber(potamount)
        Lotto:SetPot(potamount)
        if Lotto.HideChatCmds then
            return ""
        end
    end
end)
