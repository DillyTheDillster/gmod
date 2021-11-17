LocalPlayer().hasOpenedGames = false;

function BLINDGAMES.makeMenu()
	local frame = vgui.Create("DFrame");
	frame:SetSize(225, 325);
	frame:Center();
	frame:SetTitle("");
	frame:SetVisible(true);
	frame:SetDraggable(true);
	frame:ShowCloseButton(false);
	frame:MakePopup();
	frame.Paint = function(p, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200));
		draw.SimpleText("Game options", "GAMEFONT_SMALL", w/2, 0, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP);
	end
	
	frame.checkBoxes = {};
	
	local closeBut = vgui.Create("DButton", frame);
	closeBut:SetText("");
	closeBut:SetSize(frame:GetWide() / 1.1, frame:GetTall() / 10);
	closeBut:SetPos(0, frame:GetTall() - (closeBut:GetTall()*1.1));
	closeBut:CenterHorizontal();
	closeBut.Paint = function(p, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(150, 50, 50, 200));
		draw.SimpleText("Close", "GAMEFONT_SMALL", w/2, 0, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP);
	end
	closeBut.DoClick = function()
		frame:Close();
	end
	
	local yOffset = 0;
	for i, v in pairs(BLINDGAMES.games || {})do
		local CheckBoxThing = vgui.Create("DCheckBoxLabel", frame);
		CheckBoxThing:SetPos(10,40 + yOffset);
		if v.name == "No Games" then
			CheckBoxThing:SetPos(10,40 + yOffset + 200);
		end
		CheckBoxThing:SetText(v.name);
		if(i == LocalPlayer():getCurGameID())then
			CheckBoxThing:SetValue(1);
		else
			CheckBoxThing:SetValue(0);
		end
		CheckBoxThing.OnChange = function(pSelf, fValue)
			if(fValue)then
				for _, v in pairs(frame.checkBoxes) do
					if v == pSelf then continue; end
					
					v:SetValue(0);
				end
				net.Start("bgames_onGameChanged");
					net.WriteFloat(i);
				net.SendToServer();
			end
		end
		
		table.insert(frame.checkBoxes, CheckBoxThing);
		
		yOffset = yOffset + CheckBoxThing:GetTall();
	end
	LocalPlayer().hasOpenedGames = true;
end