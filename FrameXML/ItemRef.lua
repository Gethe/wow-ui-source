
function SetItemRef(link)
	if ( strsub(link, 1, 6) == "Player" ) then
		local name = strsub(link, 8);
		if ( name and (strlen(name) > 0) ) then
			if ( IsShiftKeyDown() ) then
				SendWho("n-"..name);
			else
				DEFAULT_CHAT_FRAME.editBox.chatType = "WHISPER";
				DEFAULT_CHAT_FRAME.editBox.tellTarget = name;
				ChatEdit_UpdateHeader(DEFAULT_CHAT_FRAME.editBox);
				if ( not DEFAULT_CHAT_FRAME.editBox:IsVisible() ) then
					ChatFrame_OpenChat("", DEFAULT_CHAT_FRAME);
				end
			end
		end
		return;
	end

	ShowUIPanel(ItemRefTooltip);
	if ( not ItemRefTooltip:IsVisible() ) then
		ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
	end
	ItemRefTooltip:SetHyperlink(link);
end