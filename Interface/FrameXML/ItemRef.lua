local DUNGEON_SCORE_LINK_INDEX_START = 9; 
local DUNGEON_SCORE_LINK_ITERATE = 3; 
local PVP_LINK_ITERATE = 3; 
local PVP_LINK_ITERATE_BRACKET = 4; 
local PVP_LINK_INDEX_START = 7;

local function FormatLink(linkType, linkDisplayText, ...)
	local linkFormatTable = { ("|H%s"):format(linkType), ... };
	local returnLink = table.concat(linkFormatTable, ":");
	if linkDisplayText then
		return returnLink .. ("|h%s|h"):format(linkDisplayText);
	else
		return returnLink .. "|h";
	end
end

function SetItemRef(link, text, button, chatFrame)

	-- Going forward, use linkType and linkData instead of strsub and strsplit everywhere
	local linkType, linkData = ExtractLinkData(link);

	if ( strsub(link, 1, 6) == "player" ) then
		local namelink, isGMLink, isCommunityLink;
		if ( strsub(link, 7, 8) == "GM" ) then
			namelink = strsub(link, 10);
			isGMLink = true;
		elseif ( strsub(link, 7, 15) == "Community") then
			namelink = strsub(link, 17);
			isCommunityLink = true;
		else
			namelink = strsub(link, 8);
		end

		local name, lineID, chatType, chatTarget, communityClubID, communityStreamID, communityEpoch, communityPosition;

		if ( isCommunityLink ) then
			name, communityClubID, communityStreamID, communityEpoch, communityPosition = strsplit(":", namelink);
		else
			name, lineID, chatType, chatTarget = strsplit(":", namelink);
		end
		if ( name and (strlen(name) > 0) ) then
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
					C_FriendList.SendWho(WHO_TAG_EXACT..name);
				end

			elseif ( button == "RightButton" and (not isGMLink) ) then
				FriendsFrame_ShowDropdown(name, 1, lineID, chatType, chatFrame, nil, nil, communityClubID, communityStreamID, communityEpoch, communityPosition);
			else
				ChatFrame_SendTell(name, chatFrame);
			end
		end
		return;
	elseif ( strsub(link, 1, 8) == "BNplayer" ) then
		local namelink, isCommunityLink;
		if ( strsub(link, 9, 17) == "Community" ) then
			namelink = strsub(link, 19);
			isCommunityLink = true;
		else
			namelink = strsub(link, 10);
		end

		local name, bnetIDAccount, lineID, chatType, chatTarget, communityClubID, communityStreamID, communityEpoch, communityPosition;
		if ( isCommunityLink ) then
			name, bnetIDAccount, communityClubID, communityStreamID, communityEpoch, communityPosition = strsplit(":", namelink);
		else
			name, bnetIDAccount, lineID, chatType, chatTarget = strsplit(":", namelink);
		end
		if ( name and (strlen(name) > 0) ) then
			if ( IsModifiedClick("CHATLINK") ) then
				-- Disable SHIFT-CLICK for battlenet friends, so we don't put an encoded bnetIDAccount in chat
			elseif ( button == "RightButton" ) then
				if ( isCommunityLink or not BNIsSelf(bnetIDAccount) ) then
					FriendsFrame_ShowBNDropdown(name, 1, nil, chatType, chatFrame, nil, bnetIDAccount, communityClubID, communityStreamID, communityEpoch, communityPosition);
				end
			else
				if ( BNIsFriend(bnetIDAccount)) then
					ChatFrame_SendBNetTell(name);
				else
					local displayName = BNGetDisplayName(bnetIDAccount);
					ChatFrame_SendBNetTell(displayName)
				end
			end
		end
		return;
	elseif ( strsub(link, 1, 7) == "channel" ) then
		if ( IsModifiedClick("CHATLINK") ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);
			ChannelFrame:Toggle();
		elseif ( button == "LeftButton" ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);

			if ( strupper(chatType) == "CHANNEL" ) then
				if ( GetChannelName(tonumber(chatTarget))~=0 ) then
					ChatFrame_OpenChat("/"..chatTarget, chatFrame);
				end
			elseif ( strupper(chatType) == "PET_BATTLE_COMBAT_LOG" or strupper(chatType) == "PET_BATTLE_INFO" ) then
				--Don't do anything
			else
				ChatFrame_OpenChat("/"..chatType, chatFrame);
			end
		elseif ( button == "RightButton" ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);
			if not ( (strupper(chatType) == "CHANNEL" and GetChannelName(tonumber(chatTarget)) == 0) ) then	--Don't show the dropdown if this is a channel we are no longer in.
				ChatChannelDropDown_Show(chatFrame, strupper(chatType), chatTarget, Chat_GetColoredChatName(strupper(chatType), chatTarget));
			end
		end
		return;
	elseif ( strsub(link, 1, 6) == "GMChat" ) then
		GMChatStatusFrame_OnClick();
		return;
	elseif ( strsub(link, 1, 7) == "levelup" ) then
		local _, level, levelUpType, arg1 = strsplit(":", link);
		EventToastManagerSideDisplay:DisplayToastsByLevel(level);
		return;
	elseif ( strsub(link, 1, 6) == "pvpbgs" ) then
		TogglePVPUI();
		return;
	elseif ( strsub(link, 1, 12) == "battleground" ) then
		PVEFrame_ShowFrame("PVPUIFrame", HonorFrame);
		HonorFrame_SetType("specific");
		local _, bgID = strsplit(":", link);
		HonorFrameSpecificList_FindAndSelectBattleground(tonumber(bgID));
		return;
	elseif ( strsub(link, 1, 3) == "lfd" ) then
		ToggleLFDParentFrame();
		return;
	elseif ( strsub(link, 1, 8) == "specpane" ) then
		ToggleTalentFrame(SPECIALIZATION_TAB);
		return;
	elseif ( strsub(link, 1, 10) == "talentpane" ) then
		ToggleTalentFrame(TALENTS_TAB);
		return;
	elseif ( strsub(link, 1, 14) == "mountequipment" ) then
		ToggleCollectionsJournal(COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
		return;
	elseif ( strsub(link, 1, 11) == "honortalent" ) then
		ToggleTalentFrame(PVP_TALENTS_TAB);
		return;
	elseif ( strsub(link, 1, 10) == "worldquest" ) then
		OpenWorldMap();
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
			local fixedLink = GetFixedLink(text, tonumber(breedQuality));
			HandleModifiedItemClick(fixedLink);
		else
			FloatingBattlePet_Toggle(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), string.gsub(string.gsub(text, "^(.*)%[", ""), "%](.*)$", ""), battlePetID);
		end
		return;
	elseif ( strsub(link, 1, 19) == "garrfollowerability" ) then
		local _, garrFollowerAbilityID = strsplit(":", link);
		if ( IsModifiedClick() ) then
			local fixedLink = GetFixedLink(text);
			HandleModifiedItemClick(fixedLink);
		else
			FloatingGarrisonFollowerAbility_Toggle(tonumber(garrFollowerAbilityID));
		end
		return;
	elseif ( strsub(link, 1, 12) == "garrfollower" ) then
		local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = strsplit(":", link);
		if ( IsModifiedClick() ) then
			local fixedLink = GetFixedLink(text, tonumber(quality));
			HandleModifiedItemClick(fixedLink);
		else
			FloatingGarrisonFollower_Toggle(tonumber(garrisonFollowerID), tonumber(quality), tonumber(level), tonumber(itemLevel), tonumber(spec1), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4));
		end
		return;
	elseif ( strsub(link, 1, 11) == "garrmission" ) then
		local _, garrMissionID = strsplit(":", link);
		local garrMissionID, garrMissionDBID = link:match("garrmission:(%d+):([0-9a-fA-F]+)")
		if (garrMissionID and garrMissionDBID and strlen(garrMissionDBID) == 16) then
			if ( IsModifiedClick() ) then
				local fixedLink = GetFixedLink(text);
				HandleModifiedItemClick(fixedLink);
			else
				FloatingGarrisonMission_Toggle(tonumber(garrMissionID), "0x"..(garrMissionDBID:upper()));
			end
		end
		return;
	elseif ( strsub(link, 1, 5) == "death" ) then
		local _, id = strsplit(":", link);
		OpenDeathRecapUI(id);
		return;
	elseif ( strsub(link, 1, 7) == "sharess" ) then
		local _, index = strsplit(":", link);
		SocialFrame_LoadUI();
		Social_ShowScreenshot(tonumber(index));
		return;
	elseif ( strsub(link, 1, 12) == "shareachieve" ) then
		local _, achievementID, earned = strsplit(":", link);
		SocialFrame_LoadUI();
		Social_ShowAchievement(tonumber(achievementID), StringToBoolean(earned));
		return;
	elseif ( strsub(link, 1, 9) == "shareitem" ) then
		local strippedItemLink, earned = link:match("^shareitem:(.-):(%d+)$");
		local itemLink = FormatLink("item", nil, strippedItemLink);
		SocialFrame_LoadUI();
		Social_ShowItem(itemLink, earned);
		return;
	elseif ( strsub(link, 1, 16) == "transmogillusion" ) then
		local fixedLink = GetFixedLink(text);
		if ( not HandleModifiedItemClick(fixedLink) ) then
			DressUpTransmogLink(link);
		end
		return;
	elseif ( strsub(link, 1, 18) == "transmogappearance" ) then
		local _, sourceID = strsplit(":", link);
		if ( IsModifiedClick("CHATLINK") ) then
			local itemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
			HandleModifiedItemClick(itemLink);
		else
			TransmogUtil.OpenCollectionToItem(sourceID);
		end
		return;
	elseif ( strsub(link, 1, 11) == "transmogset" ) then
		local _, setID = strsplit(":", link);
		TransmogUtil.OpenCollectionToSet(setID);
		return;
	elseif ( strsub(link, 1, 3) == "api" ) then
		APIDocumentation_LoadUI();

		local command = APIDocumentation.Commands.Default;
		if button == "RightButton" then
			command = APIDocumentation.Commands.CopyAPI;
		elseif IsModifiedClick("CHATLINK") then
			command = APIDocumentation.Commands.OpenDump;
		end

		APIDocumentation:HandleAPILink(link, command);
		return;
	elseif ( strsub(link, 1, 13) == "storecategory" ) then
		local _, category = strsplit(":", link);
		if category == "token" then
			StoreFrame_SetTokenCategory();
			ToggleStoreUI();
		elseif category == "games" then
			StoreFrame_OpenGamesCategory();
		elseif category == "services" then
			StoreFrame_SetServicesCategory();
			ToggleStoreUI();
		elseif category == "gametime" then
			StoreInterfaceUtil.OpenToSubscriptionProduct();
		end
	elseif ( strsub(link, 1, 4) == "item" ) then
		if ( IsModifiedClick("CHATLINK") and button == "LeftButton" ) then
			local name, link = GetItemInfo(text);
			if ChatEdit_InsertLink(link) then
				return;
			end
		end
	elseif ( strsub(link, 1, 10) == "clubTicket" ) then
		if ( IsModifiedClick("CHATLINK") and button == "LeftButton" ) then
			if ChatEdit_InsertLink(text) then
				return;
			end
		end
		local _, ticketId = strsplit(":", link);
		if ( CommunitiesFrame_IsEnabled() ) then
			Communities_LoadUI();
			CommunitiesHyperlink.OnClickLink(ticketId);
		end
		return;
	elseif ( strsub(link, 1, 13) == "calendarEvent" ) then
		local _, monthOffset, monthDay, index = strsplit(":", link);
		local dayEvent = C_Calendar.GetDayEvent(monthOffset, monthDay, index);
		if dayEvent then
			Calendar_LoadUI();

			if not CalendarFrame:IsShown() then
				Calendar_Toggle();
			end

			C_Calendar.OpenEvent(monthOffset, monthDay, index);
		end
		return;
	elseif ( strsub(link, 1, 9) == "community" ) then
		if ( CommunitiesFrame_IsEnabled() ) then
			local _, clubId = strsplit(":", link);
			clubId = tonumber(clubId);
			Communities_LoadUI();
			CommunitiesHyperlink.OnClickReference(clubId);
		end
		return;
	elseif ( strsub(link, 1, 9) == "azessence" ) then
		if ChatEdit_InsertLink(link) then
			return;
		end
	elseif ( strsub(link, 1, 10) == "clubFinder" ) then
		if ( IsModifiedClick("CHATLINK") and button == "LeftButton" ) then
			if ChatEdit_InsertLink(text) then
				return;
			end
		end
		Communities_LoadUI();
		local _, clubFinderId = strsplit(":", link);
		CommunitiesFrame:ClubFinderHyperLinkClicked(clubFinderId);
		return;
	elseif ( strsub(link, 1, 8) == "worldmap" ) then
		local waypoint = C_Map.GetUserWaypointFromHyperlink(link);
		if waypoint then
			C_Map.SetUserWaypoint(waypoint);
			OpenWorldMap(waypoint.uiMapID);
		end
		return;
	elseif ( strsub(link, 1, 12) ==  "dungeonScore" ) then 
		DisplayDungeonScoreLink(link);
		return; 
	elseif ( strsub(link, 1, 9) == "pvpRating" ) then
		DisplayPvpRatingLink(link);
		return;
	end
	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text);
		HandleModifiedItemClick(fixedLink);
	else
		local itemName, itemLink = ItemRefTooltip:GetItem();
		if itemLink == GetFixedLink(text) then
			HideUIPanel(ItemRefTooltip);
		else
			ShowUIPanel(ItemRefTooltip);
			if ( not ItemRefTooltip:IsShown() ) then
				ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
			end
			ItemRefTooltip:ItemRefSetHyperlink(link);
		end
	end
end

function GetFixedLink(text, quality)
	local startLink = strfind(text, "|H");
	if ( not strfind(text, "|c") ) then
		if ( quality ) then
			return (gsub(text, "(|H.+|h.+|h)", ITEM_QUALITY_COLORS[quality].hex.."%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 6) == "quest" ) then
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
		elseif ( strsub(text, startLink + 2, startLink + 12) == "garrmission" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 17) == "transmogillusion" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 19) == "transmogappearance" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 12) == "transmogset" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 9) == "worldmap" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		end
	end
	--Nothing to change.
	return text;
end

function GetBattlePetAbilityHyperlink(abilityID, maxHealth, power, speed)
	local id, name = C_PetBattles.GetAbilityInfoByID(abilityID);
	if not name then
		GMError("Attempt to link ability when we don't have record.");
		return "";
	end

	local linkDisplayText = ("[%s]"):format(name);
	return ("|cff4e96f7%s|r"):format(FormatLink("battlePetAbil", linkDisplayText, abilityID, maxHealth or 100, power or 0, speed or 0));
end

function GetPlayerLink(characterName, linkDisplayText, lineID, chatType, chatTarget)
	-- Use simplified link if possible
	if lineID or chatType or chatTarget then
		return FormatLink("player", linkDisplayText, characterName, lineID or 0, chatType or 0, chatTarget or "");
	else
		return FormatLink("player", linkDisplayText, characterName);
	end
end

function GetBNPlayerLink(name, linkDisplayText, bnetIDAccount, lineID, chatType, chatTarget)
	return FormatLink("BNplayer", linkDisplayText, name, bnetIDAccount, lineID or 0, chatType, chatTarget);
end

function GetGMLink(gmName, linkDisplayText, lineID)
	if lineID then
		return FormatLink("playerGM", linkDisplayText, gmName, lineID or 0);
	else
		return FormatLink("playerGM", linkDisplayText, gmName);
	end
end

local function SanitizeCommunityData(clubId, streamId, epoch, position)
	if type(clubId) == "number" then
		clubId = ("%.f"):format(clubId);
	end
	if type(streamId) == "number" then
		streamId = ("%.f"):format(streamId);
	end
	epoch = ("%.f"):format(epoch);
	position = ("%.f"):format(position);

	return clubId, streamId, epoch, position;
end

function GetBNPlayerCommunityLink(playerName, linkDisplayText, bnetIDAccount, clubId, streamId, epoch, position)
	clubId, streamId, epoch, position = SanitizeCommunityData(clubId, streamId, epoch, position);
	return FormatLink("BNplayerCommunity", linkDisplayText, playerName, bnetIDAccount, clubId, streamId, epoch, position);
end

function GetPlayerCommunityLink(playerName, linkDisplayText, clubId, streamId, epoch, position)
	clubId, streamId, epoch, position = SanitizeCommunityData(clubId, streamId, epoch, position);
	return FormatLink("playerCommunity", linkDisplayText, playerName, clubId, streamId, epoch, position);
end

function GetClubTicketLink(ticketId, clubName, clubType)
	local link = FormatLink("clubTicket", CLUB_INVITE_HYPERLINK_TEXT:format(clubName), ticketId);
	if clubType == Enum.ClubType.BattleNet then
		return BATTLENET_FONT_COLOR:WrapTextInColorCode(link);
	else
		return NORMAL_FONT_COLOR:WrapTextInColorCode(link);
	end
end

function GetClubFinderLink(clubFinderId, clubName)
	local clubType = C_ClubFinder.GetClubTypeFromFinderGUID(clubFinderId);
	local fontColor = NORMAL_FONT_COLOR;
	local linkGlobalString;
	if(clubType == Enum.ClubFinderRequestType.Guild) then
		linkGlobalString = CLUB_FINDER_LINK_GUILD;
	elseif(clubType == Enum.ClubFinderRequestType.Community) then
		linkGlobalString = CLUB_FINDER_LINK_COMMUNITY;
		fontColor = BATTLENET_FONT_COLOR;
	else
		linkGlobalString = ""
	end
	return fontColor:WrapTextInColorCode(FormatLink("clubFinder", linkGlobalString:format(clubName), clubFinderId));
end

function DungeonScoreLinkAddDungeonsToTable()
	local dungeonScoreDungeonTable = { };
	local maps = C_ChallengeMode.GetMapScoreInfo(); 
	for _, scoreInfo in ipairs(maps) do 
		table.insert(dungeonScoreDungeonTable, scoreInfo.mapChallengeModeID);
		table.insert(dungeonScoreDungeonTable, scoreInfo.completedInTime);
		table.insert(dungeonScoreDungeonTable, scoreInfo.level);
	end		
	return dungeonScoreDungeonTable; 
end		

function DisplayPvpRatingLink(link)
	
	if ( not ItemRefTooltip:IsShown() ) then
		ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
	end 
	
	local splits  = StringSplitIntoTable(":", link);
	if(not splits) then 
		return; 
	end 
	local playerName = splits[3]; 
	local playerClass = splits[4]; 
	local playerItemLevel = tonumber(splits[5]);
	local playerLevel = tonumber(splits[6]);
	local className, classFileName = GetClassInfo(playerClass);
	local classColor = C_ClassColor.GetClassColor(classFileName);
	if(not playerName or not playerClass or not playerItemLevel or not playerLevel) then 
		return; 
	end 

	if(not className or not classFileName or not classColor) then 
		return;
	end 

	GameTooltip_SetTitle(ItemRefTooltip, classColor:WrapTextInColorCode(playerName));
	GameTooltip_AddColoredLine(ItemRefTooltip, PVP_LINK_LEVEL_CLASS_FORMAT_STRING:format(playerLevel, className), HIGHLIGHT_FONT_COLOR)
	GameTooltip_AddNormalLine(ItemRefTooltip, PVP_RATING_LINK_ITEM_LEVEL:format(playerItemLevel));

	for i = PVP_LINK_INDEX_START, (#splits), PVP_LINK_ITERATE_BRACKET do
		
		GameTooltip_AddBlankLineToTooltip(ItemRefTooltip); 

		local bracket = tonumber(splits[i]);
		local rating = tonumber(splits[i + 1]);
		local tier = tonumber(splits[i + 2]);
		local seasonGamesPlayed = tonumber(splits[i + 3]);		

		GameTooltip_AddNormalLine(ItemRefTooltip, PVPUtil.GetBracketName(bracket)); 
		GameTooltip_AddColoredLine(ItemRefTooltip,  PVP_RATING_LINK_FORMAT_STRING:format(PVPUtil.GetTierName(tier), rating), HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddColoredLine(ItemRefTooltip, PVP_LINK_SEASON_GAMES:format(seasonGamesPlayed), HIGHLIGHT_FONT_COLOR);
	end 
	ShowUIPanel(ItemRefTooltip);

	ItemRefTooltip:SetPadding(30, 0); 
end

function AddPvpRatingsToTable()
	local pvpLinkInfoTable = { };
	for i = 1, PVP_LINK_ITERATE do 
		local bracketIndex = CONQUEST_BRACKET_INDEXES[i];
		local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking = GetPersonalRatedInfo(bracketIndex);
		local tierInfo = C_PvP.GetPvpTierInfo(pvpTier);
		if(not tierInfo or not tierInfo.pvpTierEnum) then 
			return; 
		end 
		table.insert(pvpLinkInfoTable, bracketIndex);
		table.insert(pvpLinkInfoTable, rating);
		table.insert(pvpLinkInfoTable, tierInfo.pvpTierEnum);
		table.insert(pvpLinkInfoTable, seasonPlayed);
	end
	return pvpLinkInfoTable;
end

function DisplayDungeonScoreLink(link)
	if ( not ItemRefTooltip:IsShown() ) then
		ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
	end 

	local splits  = StringSplitIntoTable(":", link);
	
	--Bad Link, Return. 
	if(not splits) then 
		return;
	end		
	local dungeonScore = tonumber(splits[2]);
	local playerName = splits[4]; 
	local playerClass = splits[5]; 
	local playerItemLevel = tonumber(splits[6]);
	local playerLevel = tonumber(splits[7]);
	local className, classFileName = GetClassInfo(playerClass);
	local classColor = C_ClassColor.GetClassColor(classFileName);
	local runsThisSeason = tonumber(splits[8]);

	--Bad Link..
	if(not playerName or not playerClass or not playerItemLevel or not playerLevel) then 
		return; 
	end 

	--Bad Link..
	if(not className or not classFileName or not classColor) then 
		return;
	end 

	GameTooltip_SetTitle(ItemRefTooltip, classColor:WrapTextInColorCode(playerName));
	GameTooltip_AddColoredLine(ItemRefTooltip, DUNGEON_SCORE_LINK_LEVEL_CLASS_FORMAT_STRING:format(playerLevel, className), HIGHLIGHT_FONT_COLOR)
	GameTooltip_AddNormalLine(ItemRefTooltip, DUNGEON_SCORE_LINK_ITEM_LEVEL:format(playerItemLevel));

	local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore);
	if (not color) then 
		color = HIGHLIGHT_FONT_COLOR; 
	end
	GameTooltip_AddNormalLine(ItemRefTooltip, DUNGEON_SCORE_LINK_RATING:format(color:WrapTextInColorCode(dungeonScore)));
	GameTooltip_AddNormalLine(ItemRefTooltip, DUNGEON_SCORE_LINK_RUNS_SEASON:format(runsThisSeason));
	GameTooltip_AddBlankLineToTooltip(ItemRefTooltip);

	local sortTable = { };
	for i = DUNGEON_SCORE_LINK_INDEX_START, (#splits), DUNGEON_SCORE_LINK_ITERATE do
		local mapChallengeModeID = tonumber(splits[i]);
		local completedInTime = tonumber(splits[i + 1]); 
		local level = tonumber(splits[i + 2]);

		local mapName = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID);

		--If any of the maps don't exist.. this is a bad link
		if(not mapName) then 
			return; 
		end 

		table.insert(sortTable, { mapName = mapName, completedInTime = completedInTime, level = level });
	end

	-- Sort Alphabetically. 
	table.sort(sortTable, function(a, b) strcmputf8i(a.mapName, b.mapName); end);

	for i = 1, #sortTable do 
		local textColor = sortTable[i].completedInTime and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR; 
		GameTooltip_AddColoredDoubleLine(ItemRefTooltip, DUNGEON_SCORE_LINK_TEXT1:format(sortTable[i].mapName), (sortTable[i].level > 0 and  DUNGEON_SCORE_LINK_TEXT2:format(sortTable[i].level) or DUNGEON_SCORE_LINK_NO_SCORE), NORMAL_FONT_COLOR, textColor); 
	end
	ItemRefTooltip:SetPadding(0, 0); 
	ShowUIPanel(ItemRefTooltip);
end		

function GetDungeonScoreLink(dungeonScore, playerName)
	local _, _, class = UnitClass("player");
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
	local runHistory = C_MythicPlus.GetRunHistory(true);
	local dungeonScoreTable = {C_ChallengeMode.GetOverallDungeonScore(), UnitGUID("player"), playerName, class, math.ceil(avgItemLevel), UnitLevel("player"), runHistory and #runHistory or 0, unpack(DungeonScoreLinkAddDungeonsToTable())};
	return NORMAL_FONT_COLOR:WrapTextInColorCode(FormatLink("dungeonScore", DUNGEON_SCORE_LINK, unpack(dungeonScoreTable)));
end		

function GetPvpRatingLink(playerName)
	local fontColor = NORMAL_FONT_COLOR;
	local _, _, class = UnitClass("player");
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
	local pvpRatingTable = { UnitGUID("player"), playerName, class, math.ceil(avgItemLevelPvP), UnitLevel("player"), unpack(AddPvpRatingsToTable())};
	return fontColor:WrapTextInColorCode(FormatLink("pvpRating", PVP_PERSONAL_RATING_LINK, unpack(pvpRatingTable)));
end

function GetCalendarEventLink(monthOffset, monthDay, index)
	local dayEvent = C_Calendar.GetDayEvent(monthOffset, monthDay, index);
	if dayEvent then
		return FormatLink("calendarEvent", dayEvent.title, monthOffset, monthDay, index);
	end

	return nil;
end

function GetCommunityLink(clubId)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		local link = FormatLink("community", COMMUNITY_REFERENCE_FORMAT:format(clubInfo.name), clubId);
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			return BATTLENET_FONT_COLOR:WrapTextInColorCode(link);
		else
			return NORMAL_FONT_COLOR:WrapTextInColorCode(link);
		end
	end

	return nil;
end


LinkUtil = {};

function LinkUtil.SplitLink(link) -- returns linkText and displayText
	return link:match("^|H(.+)|h(.*)|h$");
end

-- Extract the first link from the text given, ignoring leading and trailing characters.
-- returns linkType, linkOptions, displayText
function LinkUtil.ExtractLink(text)
	-- linkType: |H([^:]*): matches everything that's not a colon, up to the first colon.
	-- linkOptions: ([^|]*)|h matches everything that's not a |, up to the first |h.
	-- displayText: ([^|]*)|h matches everything that's not a |, up to the second |h.
	-- Ex: |cffffffff|Htype:a:b:c:d|htext|h|r becomes type, a:b:c:d, text
	return string.match(text, [[|H([^:]*):([^|]*)|h([^|]*)|h]]);
end

function LinkUtil.IsLinkType(link, matchLinkType)
	local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link);
	return linkType == matchLinkType;
end

ItemRefTooltipMixin = {};

function ItemRefTooltipMixin:OnLoad()
	GameTooltip_OnLoad(self);
	self:RegisterForDrag("LeftButton");
	self.shoppingTooltips = { ItemRefShoppingTooltip1, ItemRefShoppingTooltip2 };
	self.updateTooltipTimer = 0;
	self.UpdateTooltip = function(self, elapsed)
		if ( IsModifiedClick("COMPAREITEMS") ) then
			self.updateTooltipTimer = self.updateTooltipTimer - elapsed;
			if ( self.updateTooltipTimer > 0 ) then
				return;
			end
			self.updateTooltipTimer = TOOLTIP_UPDATE_TIME;
			GameTooltip_ShowCompareItem(self);
		else
			for _, frame in pairs(self.shoppingTooltips) do
				frame:Hide();
			end
						
			self.needsReset = true;
			self.comparing = false;
		end
	end
end

function ItemRefTooltipMixin:OnTooltipSetItem()
	self.updateTooltipTimer = 0;
	if ( IsModifiedClick("COMPAREITEMS") and self:IsMouseOver() ) then
		GameTooltip_ShowCompareItem(self);
	end
end

function ItemRefTooltipMixin:OnDragStart()
	self:StartMoving();
end

function ItemRefTooltipMixin:OnDragStop()
	self:StopMovingOrSizing();
	ValidateFramePosition(self);
	if ( IsModifiedClick("COMPAREITEMS") ) then --We do this to choose where the comparison is shown
		GameTooltip_ShowCompareItem(self);
	end
end

function ItemRefTooltipMixin:OnEnter()
	self.updateTooltipTimer = 0;
	self:SetScript("OnUpdate", self.UpdateTooltip);
end

function ItemRefTooltipMixin:OnLeave()
	for _, frame in pairs(self.shoppingTooltips) do
		frame:Hide();
	end
	self:SetScript("OnUpdate", nil);
end

function ItemRefTooltipMixin:OnHide()
	GameTooltip_OnHide(self);
	--While it is true that OnUpdate won't fire while the frame is hidden, we don't want to have to check-and-unregister when we show it
	self:SetScript("OnUpdate", nil);
end

function ItemRefTooltipMixin:ItemRefSetHyperlink(link)
	self:SetPadding(0, 0);
	self:SetHyperlink(link);
	local title = _G[self:GetName().."TextLeft1"];
	if ( title and title:GetRight() - self.CloseButton:GetLeft() > 0 ) then
		local xPadding = 16;
		self:SetPadding(xPadding, 0);
	end
end	