if not CLIENT then return end

function Lotto:Msg(...)
    chat.AddText(Color(255, 255, 0), "[Lotto] ", color_white, ...)
end

function Lotto:GetLang(lang, ...)
    local lang = Lotto.Lang[lang] or "<INVALID LANG>"
    return string.format(lang, ...)
end

local function createFont(name, size, weight)
    surface.CreateFont("Lotto_" .. name, {
        font = "Roboto",
        size = size,
        weight = weight,
    })
end
createFont("Title", 24, 400)
createFont("PanelTitle", 32, 400)
createFont("PanelDesc", 20, 400)
createFont("GuessTheNumberEntry", 36, 400)
createFont("GuessTheNumberButton", 30, 400)
createFont("CurrentPot", 32, 400)
createFont("LotteryButton", 30, 400)

function Lotto:OpenMenu()
    if Lotto.Menu then Lotto.Menu:Remove() end
    Lotto.Menu = vgui.Create("DFrame")
    Lotto.Menu:SetTitle("")
    Lotto.Menu:SetSize(600, 400)
    Lotto.Menu:Center()
    Lotto.Menu:MakePopup()

    Lotto.Menu.Paint = function(self, w, h)
        surface.SetDrawColor(Lotto.Theme["Background"])
        surface.DrawRect(0, 0, w, h)

        surface.SetFont("Lotto_Title")
        surface.SetTextPos(10, 10)
        surface.SetTextColor(Lotto.Theme["TitleText"])
        local textx, texty = surface.GetTextSize("Lotto")
        surface.DrawText("Lotto")

        surface.SetDrawColor(Lotto.Theme["Line"])
        surface.DrawRect(0, 10 + texty + 10, w, 1)
    end

    Lotto.GuessNumber = vgui.Create("DPanel", Lotto.Menu)
    Lotto.GuessNumber:SetSize(285, 0)
    Lotto.GuessNumber:Dock(LEFT)
    Lotto.GuessNumber:DockMargin(5, 25, 0, 5)
    Lotto.GuessNumber.Paint = function(self, w, h)
        surface.SetDrawColor(Lotto.Theme["Panel"])
        surface.DrawRect(0, 0, w, h)

        local text = "Guess the numbers"
        surface.SetTextColor(Lotto.Theme["PanelText"])
        surface.SetFont("Lotto_PanelTitle")
        local textx, texty = surface.GetTextSize(text)
        surface.SetTextPos(w / 2 - textx / 2, 10)
        surface.DrawText(text)

        surface.SetTextColor(Lotto.Theme["PanelText"])
        surface.SetFont("Lotto_PanelDesc")
        local y = texty + 10
        for _, line in pairs(string.Explode("\n", Lotto.GuessDesc)) do
            surface.SetTextPos(10, y)
            surface.DrawText(line)
            local textx, texty = surface.GetTextSize(line)
            y = y + texty
        end
    end

    Lotto.NumberPanel = vgui.Create("DPanel", Lotto.GuessNumber)
    Lotto.NumberPanel:SetPos(10, 120)
    Lotto.NumberPanel:SetSize(265, 50)

    Lotto.Number1 = vgui.Create("DTextEntry", Lotto.NumberPanel)
    Lotto.Number1:Dock(LEFT)
    Lotto.Number1:DockMargin(0, 0, 0, 0)
    Lotto.Number1:SetNumeric(true)
    Lotto.Number1:SetFont("Lotto_GuessTheNumberEntry")

    Lotto.Number2 = vgui.Create("DTextEntry", Lotto.NumberPanel)
    Lotto.Number2:Dock(LEFT)
    Lotto.Number2:DockMargin(35, 0, 0, 0)
    Lotto.Number2:SetNumeric(true)
    Lotto.Number2:SetFont("Lotto_GuessTheNumberEntry")

    Lotto.Number3 = vgui.Create("DTextEntry", Lotto.NumberPanel)
    Lotto.Number3:Dock(RIGHT)
    Lotto.Number3:DockMargin(0, 0, 0, 0)
    Lotto.Number3:SetNumeric(true)
    Lotto.Number3:SetFont("Lotto_GuessTheNumberEntry")

    Lotto.NumberPlay = vgui.Create("DButton", Lotto.GuessNumber)
    Lotto.NumberPlay:Dock(BOTTOM)
    Lotto.NumberPlay:DockMargin(10, 0, 10, 10)
    Lotto.NumberPlay:SetText("Play for " .. Lotto.GuessEnterPrice .. " Points")
    Lotto.NumberPlay:SetFont("Lotto_GuessTheNumberButton")
    Lotto.NumberPlay:SetSize(200, 75)
    Lotto.NumberPlay.DoClick = function()
        local number1 = tonumber(Lotto.Number1:GetValue())
        local number2 = tonumber(Lotto.Number2:GetValue())
        local number3 = tonumber(Lotto.Number3:GetValue())

        local errorMsg

        if number1 > 20 or number1 < 1 then errorMsg = "One of the numbers was too high (needs to be between 1-20)" end
        if number2 > 20 or number2 < 1 then errorMsg = "One of the numbers was too high (needs to be between 1-20)" end
        if number3 > 20 or number3 < 1 then errorMsg = "One of the numbers was too high (needs to be between 1-20)" end

        Lotto.Menu:Remove()
        if errorMsg then
            Lotto:Msg(errorMsg)
            return
        end

        net.Start("Lotto_GuessNumber")
            net.WriteUInt(number1, 16)
            net.WriteUInt(number2, 16)
            net.WriteUInt(number3, 16)
        net.SendToServer()
    end

    Lotto.Lottery = vgui.Create("DPanel", Lotto.Menu)
    Lotto.Lottery:SetSize(285, 0)
    Lotto.Lottery:Dock(RIGHT)
    Lotto.Lottery:DockMargin(0, 25, 5, 5)
    Lotto.Lottery.Paint = function(self, w, h)
        surface.SetDrawColor(Lotto.Theme["Panel"])
        surface.DrawRect(0, 0, w, h)

        local text = "Lottery"
        surface.SetTextColor(Lotto.Theme["PanelText"])
        surface.SetFont("Lotto_PanelTitle")
        local textx, texty = surface.GetTextSize(text)
        surface.SetTextPos(w / 2 - textx / 2, 10)
        surface.DrawText(text)

        surface.SetTextColor(Lotto.Theme["PanelText"])
        surface.SetFont("Lotto_PanelDesc")
        local y = texty + 10
        for _, line in pairs(string.Explode("\n", Lotto.LottoDesc)) do
            surface.SetTextPos(10, y)
            surface.DrawText(line)
            local textx, texty = surface.GetTextSize(line)
            y = y + texty
        end

        local text = Lotto:GetLang("CurrentPot", GetGlobalInt("CurrentPot", 0) .. " Points")
        surface.SetFont("Lotto_CurrentPot")
        local textx, texty = surface.GetTextSize(text)
        surface.SetTextPos(w / 2 - textx / 2, y + 20)
        surface.DrawText(text)
    end

    Lotto.LotteryPlay = vgui.Create("DButton", Lotto.Lottery)
    Lotto.LotteryPlay:Dock(BOTTOM)
    Lotto.LotteryPlay:DockMargin(10, 0, 10, 10)
    Lotto.LotteryPlay:SetText("Enter for " .. Lotto.LottoEnterPrice .. " Points")
    Lotto.LotteryPlay:SetFont("Lotto_LotteryButton")
    Lotto.LotteryPlay:SetSize(200, 75)
    Lotto.LotteryPlay.DoClick = function()
        Lotto.Menu:Remove()
        net.Start("Lotto_Lottery")
        net.SendToServer()
    end
end

net.Receive("Lotto_OpenMenu", function()
    Lotto:OpenMenu()
end)

concommand.Add(Lotto.ChatLottoCmd, Lotto.OpenMenu)
