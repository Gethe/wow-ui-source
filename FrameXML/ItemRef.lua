
function SetItemRef(link, text, button)
	if ( strsub(link, 1, 6) == "player" ) then
		local name = strsub(link, 8);
		if ( name and (strlen(name) > 0) ) then
			name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3");
			name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2");
			if ( IsShiftKeyDown() ) then
				local staticPopup;
				staticPopup = StaticPopup_Visible("ADD_IGNORE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_FRIEND");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_GUILDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_RAIDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				if ( ChatFrameEditBox:IsVisible() ) then
					ChatFrameEditBox:Insert(name);
				else
					SendWho("n-"..name);					
				end
				
			elseif ( button == "RightButton" ) then
				FriendsFrame_ShowDropdown(name, 1);
			else
				ChatFrame_SendTell(name);
			end
		end
		return;
	end

	if ( IsControlKeyDown() ) then
		DressUpItemLink(text);
	elseif ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(text);
		end
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsVisible() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
		ItemRefTooltip:SetHyperlink(link);
	end
end
