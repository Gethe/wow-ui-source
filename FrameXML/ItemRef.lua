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
				ChatFrame_SendTell(name, chatFrame);
			end
		end
		return;
	elseif ( strsub(link, 1, 8) == "BNplayer" ) then
		local namelink = strsub(link, 10);
		
		local name, presenceID, lineid, chatType, chatTarget = strsplit(":", namelink);
		if ( name and (strlen(name) > 0) ) then
			if ( IsModifiedClick("CHATLINK") ) then
				--[[
				disable SHIFT-CLICK for battlenet friends, so we don't put an encoded presence id in chat

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
				]]
			elseif ( button == "RightButton" ) then
				if ( not BNIsSelf(presenceID) ) then
					FriendsFrame_ShowBNDropdown(name, 1, nil, chatType, chatFrame, nil, BNet_GetPresenceID(name));
				end
			else
				if ( not BNIsSelf(presenceID) ) then
					ChatFrame_SendSmartTell(name, chatFrame);
				end
			end
		end
		return;
	elseif ( strsub(link, 1, 7) == "channel" ) then
		if ( IsModifiedClick("CHATLINK") ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);
			if ( strupper(chatType) == "BN_CONVERSATION" ) then
				BNListConversation(chatTarget);
			else
				ToggleFriendsFrame(3);
			end
		elseif ( button == "LeftButton" ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);
			
			if ( strupper(chatType) == "CHANNEL" ) then
				if ( GetChannelName(tonumber(chatTarget))~=0 ) then
					ChatFrame_OpenChat("/"..chatTarget, chatFrame);
				end
			elseif ( strupper(chatType) == "BN_CONVERSATION" ) then
				if ( BNGetConversationInfo(chatTarget) ) then
					ChatFrame_OpenChat("/"..(chatTarget + MAX_WOW_CHAT_CHANNELS), chatFrame);
				end
			elseif ( strupper(chatType) == "PET_BATTLE_COMBAT_LOG" or strupper(chatType) == "PET_BATTLE_INFO" ) then
				--Don't do anything
			else
				ChatFrame_OpenChat("/"..chatType, chatFrame);
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
	elseif ( strsub(link, 1, 7) == "levelup" ) then
		local _, level, levelUpType, arg1 = strsplit(":", link);
		LevelUpDisplay_ShowSideDisplay(tonumber(level), _G[levelUpType], arg1);
		return;
	elseif ( strsub(link, 1, 6) == "pvpbgs" ) then
		TogglePVPUI();
		return;
	elseif ( strsub(link, 1, 3) == "lfd" ) then
		ToggleLFDParentFrame();
		return;
	elseif ( strsub(link, 1, 9) == "glyphpane" ) then
		ToggleGlyphFrame();
		return;
	elseif ( strsub(link, 1, 10) == "talentpane" ) then
		ToggleTalentFrame();
		return;
	elseif ( strsub(link, 1, 7) == "journal" ) then
		if ( not HandleModifiedItemClick(GetFixedLink(text)) ) then
			if ( not EncounterJournal ) then
				EncounterJournal_LoadUI();
			end
			EncounterJournal_OpenJournalLink(strsplit(":", link));
		end
		return;
	elseif ( strsub(link, 1, 8) == "urlIndex" ) then
		local _, index = strsplit(":", link);
		LoadURLIndex(tonumber(index));
		return;
	elseif ( strsub(link, 1, 11) == "lootHistory" ) then
		local _, rollID = strsplit(":", link);
		LootHistoryFrame_ToggleWithRoll(LootHistoryFrame, tonumber(rollID), chatFrame);
		return;
	elseif ( strsub(link, 1, 13) == "battlePetAbil" ) then
		local _, abilityID, maxHealth, power, speed = strsplit(":", link);
		if ( IsModifiedClick() ) then
			local fixedLink = GetFixedLink(text);
			HandleModifiedItemClick(fixedLink);
		else
			FloatingPetBattleAbility_Show(tonumber(abilityID), tonumber(maxHealth), tonumber(power), tonumber(speed));
		end
		return;
	elseif ( strsub(link, 1, 9) == "battlepet" ) then
		local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit(":", link);
		if ( IsModifiedClick() ) then
			local fixedLink = GetFixedLink(text);
			HandleModifiedItemClick(fixedLink);
		else
			FloatingBattlePet_Toggle(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), string.gsub(string.gsub(text, "^(.*)%[", ""), "%](.*)$", ""), battlePetID);
		end
		return;
	end
    
	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text);
		HandleModifiedItemClick(fixedLink);
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsShown() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
		ItemRefTooltip:SetHyperlink(link);
	end
end

function GetFixedLink(text)
	local startLink = strfind(text, "|H");
	if ( not strfind(text, "|c") ) then
		if ( strsub(text, startLink + 2, startLink + 6) == "quest" ) then
			--We'll always color it yellow. We really need to fix this for Cata. (It will appear the correct color in the chat log)
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 12) == "achievement" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 7) == "talent" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cff4e96f7%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 6) == "trade" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd000%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 8) == "enchant" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd000%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 13) == "instancelock" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff8000%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 8) == "journal" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cff66bbff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 14) == "battlePetAbil" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cff4e96f7%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 10) == "battlepet" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd200%1|r", 1)); -- s_defaultColorString (yellow)
		end
	end
	--Nothing to change.
	return text;
end

function GetBattlePetAbilityHyperlink(abilityID, maxHealth, power, speed)
	local id, name = C_PetBattles.GetAbilityInfoByID(abilityID);
	if ( name ) then
		return format("|cff4e96f7|HbattlePetAbil:%d:%d:%d:%d|h[%s]|h|r", abilityID, maxHealth or 100, power or 0, speed or 0, name);
	else
		GMError("Attempt to link ability when we don't have record.");
		return "";
	end
end
