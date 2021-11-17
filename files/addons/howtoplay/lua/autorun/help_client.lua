if (CLIENT) then

	net.Receive("StartHelp",function()
		local HelpPanel = vgui.Create( "DFrame" )
		HelpPanel:SetPos( 50,50 )
		HelpPanel:SetSize( 650, 300 )
		HelpPanel:SetTitle( "How to play!" )
		HelpPanel:SetVisible( true )
		HelpPanel:SetDraggable( true )
		HelpPanel:ShowCloseButton( true )
		HelpPanel:Center()
		HelpPanel:MakePopup()
		 
		local HelpList = vgui.Create("DListView")
		HelpList:Center()
		HelpList:SetParent(HelpPanel)
		HelpList:SetPos(25, 50)
		HelpList:SetSize(600, 200)
		HelpList:SetMultiSelect(false)
		HelpList:AddColumn("How to") -- Add column
		HelpList:AddColumn("Do this")
		HelpList:AddLine("Play Hunter","Find and kill all Props")
		HelpList:AddLine("Play Props","Hide from the Hunters")
		HelpList:AddLine("Change into a prop","Press \"Right Mouse Button\" on the prop when it is green")
		HelpList:AddLine("Change view (both teams)","Hold \"C\" and click \"Third Person\"")
		HelpList:AddLine("Lock rotation","Hold \"C\" and click \"Angle Lock\"")
		HelpList:AddLine("Snap rotation","Hold \"C\" and click \"Angle Snapping\"")
		HelpList:AddLine("Taunt","Hold \"Q\" and select a taunt or press F3")
	end)
end