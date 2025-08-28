local function HandlePlayerLink(link, text, linkData, contextData)
	local name, lineID, chatType, chatTarget, communityClubID, communityStreamID, communityEpoch, communityPosition;

	if ( linkData.type == LinkTypes.PlayerCommunity ) then
		name, communityClubID, communityStreamID, communityEpoch, communityPosition = string.split(":", linkData.options);
	else
		name, lineID, chatType, chatTarget = string.split(":", linkData.options);
	end
	if ( name and (string.len(name) > 0) ) then
		if ( IsModifiedClick("CHATLINK") ) then
			local staticPopup;
			staticPopup = StaticPopup_Visible("ADD_IGNORE");
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
				_G(staticPopup.."EditBox"):SetText(name);
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
			else
				C_FriendList.SendWho(WHO_TAG_EXACT..name, Enum.SocialWhoOrigin.Item);
			end

		elseif ( contextData.button == "RightButton" and (linkData.type ~= LinkTypes.PlayerGM) and FriendsFrame_ShowDropdown) then
			FriendsFrame_ShowDropdown(name, 1, lineID, chatType, contextData.frame, nil, communityClubID, communityStreamID, communityEpoch, communityPosition);
		else
			ChatFrame_SendTell(name, contextData.frame);
		end
	end
end

LinkUtil.RegisterLinkHandler(LinkTypes.Player, HandlePlayerLink);
LinkUtil.RegisterLinkHandler(LinkTypes.PlayerCommunity, HandlePlayerLink);
LinkUtil.RegisterLinkHandler(LinkTypes.PlayerGM, HandlePlayerLink);

LinkUtil.RegisterLinkHandler(LinkTypes.LevelUpToast, function(link, text, linkData, contextData)
	local level, levelUpType, arg1 = string.split(":", linkData.options);
	LevelUpDisplay_ShowSideDisplay(tonumber(level), _G[levelUpType], arg1);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.ClassSpecializationUI, function(link, text, linkData, contextData)
	ToggleTalentFrame(SPECIALIZATION_TAB);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.ClassTalentsUI, function(link, text, linkData, contextData)
	ToggleTalentFrame(TALENTS_TAB);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.PvPTalentsUI, function(link, text, linkData, contextData)
	ToggleTalentFrame(PVP_TALENTS_TAB);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.AdventureGuide, function(link, text, linkData, contextData)
	if ( not HandleModifiedItemClick(GetFixedLink(text)) ) then
		if ( not EncounterJournal ) then
			EncounterJournal_LoadUI();
		end
		EncounterJournal_OpenJournalLink(string.split(":", link));
	end

	return LinkProcessorResponse.Unhandled;
end);

LinkUtil.RegisterLinkHandler(LinkTypes.LootHistory, function(link, text, linkData, contextData)
	local rollID = string.split(":", linkData.options);
	LootHistoryFrame_ToggleWithRoll(LootHistoryFrame, tonumber(rollID), contextData.frame);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.BattlePet, function(link, text, linkData, contextData)
	local speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = string.split(":", linkData.options);
	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text, tonumber(breedQuality));
		HandleModifiedItemClick(fixedLink);
	else
		if(GetClassicExpansionLevel() >= LE_EXPANSION_MISTS_OF_PANDARIA) then
			FloatingBattlePet_Toggle(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), string.gsub(string.gsub(text, "^(.*)%[", ""), "%](.*)$", ""), battlePetID);
		else
			-- No tooltip for pre-mop
		end
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.TransmogAppearance, function(link, text, linkData, contextData)
	if ( IsModifiedClick("CHATLINK") ) then
		local sourceID = string.split(":", linkData.options);
		local itemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
		HandleModifiedItemClick(itemLink);
	else
		if ( not CollectionsJournal ) then
			CollectionsJournal_LoadUI();
		end
		if ( CollectionsJournal ) then
			WardrobeCollectionFrame:OpenTransmogLink(link);
		end
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.TransmogSet, function(link, text, linkData, contextData)
	if ( not CollectionsJournal ) then
		CollectionsJournal_LoadUI();
	end
	if ( CollectionsJournal ) then
		WardrobeCollectionFrame:OpenTransmogLink(link);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.StoreCategory, function(link, text, linkData, contextData)
	local category = string.split(":", linkData.options);
	if category == "token" then
		StoreFrame_SetTokenCategory();
		ToggleStoreUI();
	elseif category == "games" then
		StoreFrame_OpenGamesCategory();
	elseif category == "services" then
		StoreFrame_SetServicesCategory();
		ToggleStoreUI();
	elseif category == "gametime" then
		StoreFrame_OpenGameTimeCategory();
	end

	return LinkProcessorResponse.Unhandled;
end);

LinkUtil.RegisterLinkHandler(LinkTypes.ReportCensoredMessage, function(link, text, linkData, contextData)
	local hyperlinkLineID = tonumber(string.split(":", linkData.options));
	local reportTarget = C_ChatInfo.GetChatLineSenderGUID(hyperlinkLineID);
	local playerName = C_ChatInfo.GetChatLineSenderName(hyperlinkLineID);

	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.Chat);
	reportInfo:SetReportTarget(reportTarget);
	ReportFrame:InitiateReport(reportInfo, playerName);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.AADCOpenConfig, function(link, text, linkData, contextData)
	-- When muted, the ToggleChatButton in the chat config frame is not shown, and the Disable Chat
	-- option in settings has a tooltip with an explanation of how to unmute.
	if C_SocialRestrictions.IsMuted() then
		Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID);
	else
		ShowUIPanel(ChatConfigFrame);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.LFGListing, function(link, text, linkData, contextData)
	PVEFrame_ShowFrame();
end);
