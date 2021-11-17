function _DILLY:TopLvlsFrame()
	_DILLY.topLvlsFrame = vgui.Create("DFrame")
	local this = _DILLY.topLvlsFrame
	this:SetSize(300, 350)
	this:Center()
	this:MakePopup()
	this:SetDraggable(false)
	this:SetTitle("Highest Player Levels Online")

	local scrollPnl = vgui.Create("DScrollPanel", this)
	scrollPnl:SetSize(250, 265)
	scrollPnl:SetPos(25, 35)

	PrintTable(_DILLY.topLevels)

	for k,v in pairs(_DILLY.topLevels) do
		local name, lvl = _DILLY.topLevels[k].name, _DILLY.topLevels[k].level
		local item = scrollPnl:Add("DLabel")
		item:SetText('')
		item:Dock(TOP)

		item.Paint = function(self, w, h)
			surface.SetDrawColor(255, 255, 255, 100)
			surface.DrawRect(0, 0, w,  h)

			draw.SimpleText(name, "DermaDefault", 5, h/2, Color(0, 0, 0), 0, 1)
			draw.SimpleText(lvl, "DermaDefault", w - 5, h/2, Color(0, 0, 0), 2, 1)
		end
	end
end