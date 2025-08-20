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
	local chatLinkLevelToastsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ChatLinkLevelToastsDisabled);
	if not chatLinkLevelToastsDisabled then
		local level, levelUpType, arg1 = string.split(":", linkData.options);
		EventToastManagerSideDisplay:DisplayToastsByLevel(tonumber(level));
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.BattlegroundUI, function(link, text, linkData, contextData)
	PVEFrame_ShowFrame("PVPUIFrame", HonorFrame);
	HonorFrame_SetType("specific");
	local bgID = string.split(":", linkData.options);
	HonorFrameSpecificList_FindAndSelectBattleground(tonumber(bgID));
end);

LinkUtil.RegisterLinkHandler(LinkTypes.SpecializationsUI, function(link, text, linkData, contextData)
	PlayerSpellsUtil.OpenToClassSpecializationsTab();
end);

LinkUtil.RegisterLinkHandler(LinkTypes.TalentsUI, function(link, text, linkData, contextData)
	PlayerSpellsUtil.OpenToClassTalentsTab();
end);

LinkUtil.RegisterLinkHandler(LinkTypes.DelveCompanionConfig, function(link, text, linkData, contextData)
	ShowUIPanel(DelvesCompanionConfigurationFrame);
	ShowUIPanel(DelvesCompanionAbilityListFrame);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.MountEquipment, function(link, text, linkData, contextData)
	ToggleCollectionsJournal(COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.PvPTalentsUI, function(link, text, linkData, contextData)
	PlayerSpellsUtil.OpenToClassTalentsTab();
end);

LinkUtil.RegisterLinkHandler(LinkTypes.AdventureGuide, function(link, text, linkData, contextData)
	if ( not HandleModifiedItemClick(GetFixedLink(text)) ) then
		AdventureGuideUtil.OpenHyperLink(string.split(":", link));
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.URLIndex, function(link, text, linkData, contextData)
	local index = string.split(":", linkData.options);
	LoadURLIndex(tonumber(index));
end);

LinkUtil.RegisterLinkHandler(LinkTypes.LootHistory, function(link, text, linkData, contextData)
	local encounterID = string.split(":", linkData.options);
	SetLootHistoryFrameToEncounter(tonumber(encounterID));
end);

LinkUtil.RegisterLinkHandler(LinkTypes.BattlePet, function(link, text, linkData, contextData)
	local speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = string.split(":", linkData.options);
	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text, tonumber(breedQuality));
		HandleModifiedItemClick(fixedLink);
	else
		FloatingBattlePet_Toggle(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), string.gsub(string.gsub(text, "^(.*)%[", ""), "%](.*)$", ""), battlePetID);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.TransmogAppearance, function(link, text, linkData, contextData)
	local sourceID = string.split(":", linkData.options);
	if ( IsModifiedClick("CHATLINK") ) then
		local itemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
		HandleModifiedItemClick(itemLink);
	elseif ( IsModifiedClick("DRESSUP") ) then
		local itemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
		DressUpItemLink(itemLink);
	else
		TransmogUtil.OpenCollectionToItem(sourceID);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.TransmogSet, function(link, text, linkData, contextData)
	local setID = string.split(":", linkData.options);
	TransmogUtil.OpenCollectionToSet(setID);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.TransmogOutfit, function(link, text, linkData, contextData)
	local fixedLink = GetFixedLink(text);
	if not HandleModifiedItemClick(fixedLink) then
		local itemTransmogInfoList = C_TransmogCollection.GetItemTransmogInfoListFromOutfitHyperlink(text);
		if itemTransmogInfoList then
			local showOutfitDetails = true;
			DressUpItemTransmogInfoList(itemTransmogInfoList, showOutfitDetails);
		end
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.StoreCategory, function(link, text, linkData, contextData)
	local category = string.split(":", linkData.options);
	if category == "token" then
		-- TODO: Replace with MirrorVar
		local useNewCashShop = GetCVarBool("useNewCashShop");
		if useNewCashShop then
			CatalogShopInboundInterface.SetTokenCategory();
		else
			StoreFrame_SetTokenCategory();
		end
		ToggleStoreUI();
	elseif category == "games" then
		-- TODO: Replace with MirrorVar
		local useNewCashShop = GetCVarBool("useNewCashShop");
		if useNewCashShop then
			CatalogShopInboundInterface.OpenGamesCategory();
		else
			StoreFrame_OpenGamesCategory();
		end
	elseif category == "services" then
		-- TODO: Replace with MirrorVar
		local useNewCashShop = GetCVarBool("useNewCashShop");
		if useNewCashShop then
			CatalogShopInboundInterface.SetServicesCategory();
		else
			StoreFrame_SetServicesCategory();
		end
		ToggleStoreUI();
	elseif category == "gametime" then
		StoreInterfaceUtil.OpenToSubscriptionProduct();
	end

	return LinkProcessorResponse.Unhandled;
end);

LinkUtil.RegisterLinkHandler(LinkTypes.CalendarEvent, function(link, text, linkData, contextData)
	local monthOffset, monthDay, index = string.split(":", linkData.options);
	local dayEvent = C_Calendar.GetDayEvent(monthOffset, monthDay, index);
	if dayEvent then
		Calendar_LoadUI();

		if not CalendarFrame:IsShown() then
			Calendar_Toggle();
		end

		C_Calendar.OpenEvent(monthOffset, monthDay, index);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.Community, function(link, text, linkData, contextData)
	if ( CommunitiesFrame_IsEnabled() ) then
		local clubId = string.split(":", linkData.options);
		clubId = tonumber(clubId);
		CommunitiesHyperlink.OnClickReference(clubId);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.AzeriteEssence, function(link, text, linkData, contextData)
	if ChatEdit_InsertLink(link) then
		return;
	end

	return LinkProcessorResponse.Unhandled;
end);

LinkUtil.RegisterLinkHandler(LinkTypes.ClubFinder, function(link, text, linkData, contextData)
	if ( IsModifiedClick("CHATLINK") and contextData.button == "LeftButton" ) then
		if ChatEdit_InsertLink(text) then
			return;
		end
	end
	local clubFinderId = string.split(":", linkData.options);
	CommunitiesFrame:ClubFinderHyperLinkClicked(clubFinderId);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.WorldMapWaypoint, function(link, text, linkData, contextData)
	local waypoint = C_Map.GetUserWaypointFromHyperlink(link);
	if waypoint then
		C_Map.SetUserWaypoint(waypoint);
		OpenWorldMap(waypoint.uiMapID);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.ReportCensoredMessage, function(link, text, linkData, contextData)
	local hyperlinkLineID = tonumber(strsplit(":", linkData.options));
	local playerLocation = PlayerLocation:CreateFromChatLineID(hyperlinkLineID);
	local reportTarget = C_ChatInfo.GetChatLineSenderGUID(hyperlinkLineID);
	local playerName = C_ChatInfo.GetChatLineSenderName(hyperlinkLineID);

	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.Chat);
	reportInfo:SetReportTarget(reportTarget);
	reportInfo:SetReportedChatInline();
	ReportFrame:InitiateReport(reportInfo, playerName, playerLocation);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.DungeonScore, function(link, text, linkData, contextData)
	DisplayDungeonScoreLink(link);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.PvPRating, function(link, text, linkData, contextData)
	DisplayPvpRatingLink(link);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.AADCOpenConfig, function(link, text, linkData, contextData)
	Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.EditModeLayout, function(link, text, linkData, contextData)
	local fixedLink = GetFixedLink(text);
	if not HandleModifiedItemClick(fixedLink) then
		EditModeManagerFrame:OpenAndShowImportLayoutLinkDialog(fixedLink);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.TalentBuild, function(link, text, linkData, contextData)
	local fixedLink = GetFixedLink(text);
	if not HandleModifiedItemClick(fixedLink) then
		PlayerSpellsUtil.InspectLoadout(linkData.options);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.PerksActivity, function(link, text, linkData, contextData)
	local perksActivityID = string.split(":", linkData.options);
	if ( not EncounterJournal ) then
		EncounterJournal_LoadUI();
	end
	MonthlyActivitiesFrame_OpenFrameToActivity(tonumber(perksActivityID));
end);

LinkUtil.RegisterLinkHandler(LinkTypes.WarbandScene, function(link, text, linkData, contextData)
	local warbandSceneID = string.split(":", linkData.options);
	local warbandSceneInfo = C_WarbandScene.GetWarbandSceneEntry(tonumber(warbandSceneID));
	if warbandSceneInfo then
		ItemRefTooltip:ClearHandlerInfo();
		ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");

		local isOwned = C_WarbandScene.HasWarbandScene(warbandSceneInfo.warbandSceneID);
		SharedCollectionUtil.ShowWarbandSceneEntryTooltip(ItemRefTooltip, warbandSceneInfo, isOwned);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.EventPOI, function(link, text, linkData, contextData)
	local areaPoiID = tonumber(linkData.options);
	OpenMapToEventPoi(areaPoiID);

	return LinkProcessorResponse.Unhandled;
end);
