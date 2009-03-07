
function SetItemRef(link, text, button)
	if ( strsub(link, 1, 6) == "player" ) then
		local namelink, isGMLink;
		if ( strsub(link, 7, 8) == "GM" ) then
			namelink = strsub(link, 10);
			isGMLink = true;
		else
			namelink = strsub(link, 8);
		end
		
		local name, lineid = strsplit(":", namelink);
		if ( name and (strlen(name) > 0) ) then
			if ( IsModifiedClick("CHATLINK") ) then
				local staticPopup;
				staticPopup = StaticPopup_Visible("ADD_IGNORE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_MUTE");
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
				staticPopup = StaticPopup_Visible("ADD_TEAMMEMBER");
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
				staticPopup = StaticPopup_Visible("CHANNEL_INVITE");
				if ( staticPopup ) then
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				if ( ChatFrameEditBox:IsVisible() ) then
					ChatFrameEditBox:Insert(name);
				elseif ( HelpFrameOpenTicketText:IsVisible() ) then
					HelpFrameOpenTicketText:Insert(name);
				else
					SendWho(WHO_TAG_NAME..name);					
				end
				
			elseif ( button == "RightButton" and (not isGMLink) ) then
				FriendsFrame_ShowDropdown(name, 1, lineid);
			else
				ChatFrame_SendTell(name);
			end
		end
		return;
	elseif ( strsub(link, 1, 7) == "channel" ) then
		if ( IsModifiedClick("CHATLINK") ) then
			ToggleFriendsFrame(4);
		elseif ( button == "LeftButton" ) then
			local chan = strsub(link, 9);
			local channum = tonumber(chan)
			if ( (not channum) or GetChannelName(channum)~=0 ) then
				--Open chat for channel
				ChatFrame_OpenChat("/"..chan, DEFAULT_CHAT_FRAME);
			end
		end
		return;
	elseif ( strsub(link, 1, 6) == "GMChat" ) then
		GMChatStatusFrame_OnClick();
		return;
    end
    
	if ( IsModifiedClick() ) then
		HandleModifiedItemClick(text);
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsShown() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
		ItemRefTooltip:SetHyperlink(link);
	end
end
