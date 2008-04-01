
function SetItemRef(link, button)
	if ( strsub(link, 1, 6) == "player" ) then
		local name = strsub(link, 8);
		if ( name and (strlen(name) > 0) ) then
			if ( IsShiftKeyDown() ) then
				SendWho("n-"..name);
			elseif ( button == "RightButton" ) then
				FriendsFrame_ShowDropdown(name, 1);
			else
				ChatFrame_SendTell(name);
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
