local meta = debug.getregistry().Player;
timer.Simple(2, function()
	// Prop hunt override.
	meta.oldBlind = meta.oldBlind || meta.Blind;

	function meta:Blind(b)
		self:oldBlind(b);
		hook.Call("OnBlind", nil, self, b);
	end
end)

function meta:getCurGameID()
	 return self:GetNWInt("BGames_curGame", 0);
end

function meta:getCurGame()
	return ((BLINDGAMES && BLINDGAMES.games && BLINDGAMES.games[self:getCurGameID()]) || nil);
end

function meta:setCurGame(val)
	self:SetNWInt("BGames_curGame", val);
end

function meta:setPlayingGame(val)
	 self:SetNWBool("BGames_playing", val);
end

function meta:setGameScore(val)
	 self:SetNWInt("BGames_curScore", val);
end

function meta:getGameScore()
	 return self:GetNWInt("BGames_curScore", 0);
end

function meta:isPlayingGame()
	 return self:GetNWBool("BGames_playing", false);
end