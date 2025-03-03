
if (game.SinglePlayer()) then
	ErrorNoHalt("Singleplayer is enabled! Expect errors!\n")
end
if !IsMounted("tf") and !steamworks.IsSubscribed("3324553730") then
	ErrorNoHalt("Team Fortress 2 is not mounted! Expect errors!\n")
	if CLIENT then
		local conflict_help_frame = vgui.Create( "DFrame" )
		conflict_help_frame:SetSize(200, 200)
		conflict_help_frame:Center()
		conflict_help_frame:SetTitle("!!TF2 IS NOT MOUNTED!!")
		conflict_help_frame:ShowCloseButton(true)
		conflict_help_frame:SetBackgroundBlur(true)
		conflict_help_frame:MakePopup()

		local conflicttext = vgui.Create("RichText", conflict_help_frame)
		conflicttext:Dock(FILL)
		conflicttext:InsertColorChange(255, 255, 255, 255)
		conflicttext:CenterHorizontal(0.5)
		conflicttext:SetVerticalScrollbarEnabled(false)
		conflicttext:AppendText("Hey!~ TF2 is currently not mounted! Without the assets, you will see everything as ERRORs! Luckily, I do have a solution for ya. It will take a while, though.")
			local conflictbut2 = vgui.Create("DButton", conflict_help_frame)
			conflictbut2:SetSize(100, 30)
			conflictbut2:SetPos(0, 125)
			conflictbut2:CenterHorizontal(0.5)
			conflictbut2:SetText("I understand.") 

			function conflictbut2.DoClick()
				conflict_help_frame:Close()
				gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3323795558")
			end
	end
end 