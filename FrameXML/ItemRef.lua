
function SetItemRef(link, text, button, chatFrame)
	if ( strsub(link, 1, 6) == "player" ) then
		local namelink, isGMLink;
		if ( strsub(link, 7, 8) == "GM" ) then
			namelink = strsub(link, 10);
			isGMLink = true;
		else
			namelink = strsub(link, 8);
		end
		
		local name, lineid, chatType, chatTarget = strsplit(":", namelink);
		if ( name and (strlen(name) > 0) ) then
			if ( IsModifiedClick("CHATLINK") ) then
				local staticPopup;
				staticPopup = StaticPopup_Visible("ADD_IGNORE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_MUTE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_FRIEND");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_GUILDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_TEAMMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_RAIDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("CHANNEL_INVITE");
				if ( staticPopup ) then
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				if ( ChatEdit_GetActiveWindow() ) then
					ChatEdit_InsertLink(name);
				elseif ( HelpFrameOpenTicketEditBox:IsVisible() ) then
					HelpFrameOpenTicketEditBox:Insert(name);
				else
					SendWho(WHO_TAG_NAME..name);					
				end
				
			elseif ( button == "RightButton" and (not isGMLink) ) then
				FriendsFrame_ShowDropdown(name, 1, lineid, chatType, chatFrame);
			else
				ChatFrame_SendTell(name);
			end
		end
		return;
	elseif ( strsub(link, 1, 8) == "BNplayer" ) then
		local namelink = strsub(link, 10);
		
		local name, lineid, chatType, chatTarget = strsplit(":", namelink);
		if ( name and (strlen(name) > 0) ) then
			if ( IsModifiedClick("CHATLINK") ) then
				local staticPopup;
				staticPopup = StaticPopup_Visible("ADD_IGNORE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_MUTE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_FRIEND");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_GUILDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_TEAMMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_RAIDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("CHANNEL_INVITE");
				if ( staticPopup ) then
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				if ( ChatEdit_GetActiveWindow() ) then
					ChatEdit_InsertLink(name);
				elseif ( HelpFrameOpenTicketEditBox:IsVisible() ) then
					HelpFrameOpenTicketEditBox:Insert(name);				
				end
				
			elseif ( button == "RightButton" ) then
				FriendsFrame_ShowBNDropdown(name, 1, nil, chatType, chatFrame, nil, BNet_GetPresenceID(name));
			else
				ChatFrame_SendTell(name);
			end
		end
		return;
	elseif ( strsub(link, 1, 7) == "channel" ) then
		if ( IsModifiedClick("CHATLINK") ) then
			ToggleFriendsFrame(4);
		elseif ( button == "LeftButton" ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);
			
			if ( strupper(chatType) == "CHANNEL" ) then
				if ( GetChannelName(tonumber(chatTarget))~=0 ) then
					ChatFrame_OpenChat("/"..chatTarget, DEFAULT_CHAT_FRAME);
				end
			elseif ( strupper(chatType) == "BN_CONVERSATION" ) then
				if ( BNGetConversationInfo(chatTarget) ) then
					ChatFrame_OpenChat("/"..(chatTarget + MAX_WOW_CHAT_CHANNELS), DEFAULT_CHAT_FRAME);
				end
			else
				ChatFrame_OpenChat("/"..chatType, DEFAULT_CHAT_FRAME);
			end
		elseif ( button == "RightButton" ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);
			if not ( (strupper(chatType) == "CHANNEL" and GetChannelName(tonumber(chatTarget)) == 0) or	--Don't show the dropdown if this is a channel we are no longer in.
				(strupper(chatType) == "BN_CONVERSATION" and not BNGetConversationInfo(chatTarget)) ) then	--Or a conversation we are no longer in.
				ChatChannelDropDown_Show(chatFrame, strupper(chatType), chatTarget, Chat_GetColoredChatName(strupper(chatType), chatTarget));
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
