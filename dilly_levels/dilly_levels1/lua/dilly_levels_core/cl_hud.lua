local scrW, scrH = ScrW(), ScrH()

local outline = _DILLY.CONFIG.xpBarOutline	
local background = _DILLY.CONFIG.xpBarBackground
local filled = _DILLY.CONFIG.xpBarUnfilled
local unfilled = _DILLY.CONFIG.xpBarFilled

local xpBar = xpBar || {}
xpBar.w = 500
xpBar.h	= 30
xpBar.x	= scrW/2 - xpBar.w/2

if (_DILLY.CONFIG.topOrBottom == 0) then
	xpBar.y = _DILLY.CONFIG.padding
else
	xpBar.y = scrH - xpBar.h - _DILLY.CONFIG.padding
end

hook.Add("HUDPaint", "_dilly level bar draw", function()
	local ply = LocalPlayer()
	local lvl = tonumber(ply:GetNWString("_dillyPlyLevel"))
	local exp = tonumber(ply:GetNWString("_dillyPlyExperience"))
	local expBracket = tonumber(ply:GetNWString("_dillyPlyExpBracket"))

	local percent = 494 * exp / expBracket

	surface.SetDrawColor(background)
	surface.DrawRect(xpBar.x, xpBar.y, xpBar.w, xpBar.h)

	surface.SetDrawColor(unfilled)
	surface.DrawRect(xpBar.x + 3, xpBar.y + 3, xpBar.w - 6, xpBar.h - 6)

	surface.SetDrawColor(filled)
	surface.DrawRect(xpBar.x + 3, xpBar.y + 3, percent, xpBar.h - 6)

	surface.SetDrawColor(outline)
	surface.DrawOutlinedRect(xpBar.x, xpBar.y, xpBar.w, xpBar.h)

	draw.SimpleText("Level " .. lvl, "DermaDefault", scrW/2 - 218, xpBar.y + xpBar.h/2, Color(255, 255, 255), 1, 1)
	draw.SimpleText(exp .. "/" .. expBracket, "DermaDefault", scrW/2, xpBar.y + xpBar.h/2, Color(255, 255, 255), 1, 1)
end)