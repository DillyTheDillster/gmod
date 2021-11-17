Lotto = Lotto or {}

Lotto.Lang = {
    ["LottoStart"] = "Lotto has been started! Type !lotto to join",
    ["LottoEnd"] = "Lotto has ended! The winner is %s, He won %s!",
    ["NoWinner"] = "Lotto has ended and there is no winners!",
    ["Guess_Won"] = "You have won %s from Guess the number! Congratulations!",
    ["Guess_Lost"] = "You lost, better luck next time!",
    ["CurrentPot"] = "Current pot: %s",
    ["PotSet"] = "The pot has been set to %s!",
    ["ToJoin"] = "Join to the pot by typing %s!",
}

Lotto.Admins = {
    ["superadmin"] = true,
    ["Owner"] = true,
	["Dev/Co-Owner"] = true,
}

Lotto.Theme = {
    ["Background"] = Color(30, 30, 30),
    ["TitleText"] = Color(255, 255, 255),
    ["Line"] = Color(255, 255, 255),
    ["Panel"] = Color(230, 230, 230),
    ["PanelText"] = Color(30, 30, 30),
}

Lotto.LottoDesc = [[Enter for a chance to win the
jackpot! What are you waiting for?]]
Lotto.LottoEnterPrice = 2500 -- How much does it cost to join lottery
Lotto.LottoDuration = 420 -- How many seconds until the winner is announced

Lotto.GuessDesc = [[Guess 3 numbers, and if you guess
any of the numbers right, you win!
More right guesses = more $$$!]]
Lotto.GuessEnterPrice = 1500 -- How much does it cost to
Lotto.Guess1RightMultiplier = 0.5 -- How much do you get if you get 1 number right (GuessEnterPrice * ThisValue)
Lotto.Guess2RightMultiplier = 1 -- How much do you get if you get 2 number right (GuessEnterPrice * ThisValue)
Lotto.Guess3RightMultiplier = 1.5 -- How much do you get if you get 3 number right (GuessEnterPrice * ThisValue)

Lotto.ChatPrefix = "!"
Lotto.ChatLottoCmd = "lotto" -- Command to open lotto menu (dont add chat prefix), will also work as console cmd
Lotto.ChatPotCmd = "potamount"
Lotto.HideChatCmds = false -- Hide chat commands?
