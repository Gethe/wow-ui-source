local DUNGEON_SCORE_LINK_INDEX_START = 11; 
local DUNGEON_SCORE_LINK_ITERATE = 3; 
local PVP_LINK_ITERATE_BRACKET = 4; 
local PVP_LINK_INDEX_START = 7;

function SetItemRef(link, text, button, frame)
	local contextData = { button = button, frame = frame };
	local response = LinkUtil.ProcessLink(link, text, contextData);

	if response == LinkProcessorResponse.Handled then
		return;
	end

	-- Links that are unhandled or request a fallthrough to default logic
	-- should be routed through the ItemRef tooltip.

	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text);
		HandleModifiedItemClick(fixedLink);
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsShown() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
		ItemRefTooltip:ItemRefSetHyperlink(link);
	end
end

function GetFixedLink(text, quality)
	local startLink = strfind(text, "|H");
	if ( not strfind(text, "|c") ) then
		local colorData = nil;
		if ( quality ) then
			colorData = ColorManager.GetColorDataForItemQuality(quality);
		end

		if ( colorData ) then
			return (gsub(text, "(|H.+|h.+|h)", colorData.hex.."%1|r", 1));
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
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd200%1|r", 1)); -- UIColor::GetColorString("NORMAL_FONT_COLOR") (yellow)
		elseif ( strsub(text, startLink + 2, startLink + 12) == "garrmission" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 17) == "transmogillusion" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 19) == "transmogappearance" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 12) == "transmogset" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 7) == "outfit" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 9) == "worldmap" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 7) == "layout" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 12) == "talentbuild" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
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
	return ("|cff4e96f7%s|r"):format(LinkUtil.FormatLink(LinkTypes.BattlePetAbility, linkDisplayText, abilityID, maxHealth or 100, power or 0, speed or 0));
end

function GetGMLink(gmName, linkDisplayText, lineID)
	if lineID then
		return LinkUtil.FormatLink(LinkTypes.PlayerGM, linkDisplayText, gmName, lineID or 0);
	else
		return LinkUtil.FormatLink(LinkTypes.PlayerGM, linkDisplayText, gmName);
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
	return LinkUtil.FormatLink(LinkTypes.BNPlayerCommunity, linkDisplayText, playerName, bnetIDAccount, clubId, streamId, epoch, position);
end

function GetPlayerCommunityLink(playerName, linkDisplayText, clubId, streamId, epoch, position)
	clubId, streamId, epoch, position = SanitizeCommunityData(clubId, streamId, epoch, position);
	return LinkUtil.FormatLink(LinkTypes.PlayerCommunity, linkDisplayText, playerName, clubId, streamId, epoch, position);
end

function GetClubTicketLink(ticketId, clubName, clubType)
	local link = LinkUtil.FormatLink(LinkTypes.ClubTicket, CLUB_INVITE_HYPERLINK_TEXT:format(clubName), ticketId);
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
	return fontColor:WrapTextInColorCode(LinkUtil.FormatLink(LinkTypes.ClubFinder, linkGlobalString:format(clubName), clubFinderId));
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
	for i = 1, #CONQUEST_BRACKET_INDEXES do 
		local bracketIndex = CONQUEST_BRACKET_INDEXES[i];
		local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(bracketIndex);
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
	local bestSeasonScore = tonumber(splits[9]);
	local bestSeasonNumber = tonumber(splits[10]);

	--Bad Link..
	if(not playerName or not playerClass or not playerItemLevel or not playerLevel) then 
		return; 
	end 

	--Bad Link..
	if(not className or not classFileName or not classColor) then 
		return;
	end 

	GameTooltip_SetTitle(ItemRefTooltip, classColor:WrapTextInColorCode(playerName));
	GameTooltip_AddColoredLine(ItemRefTooltip, DUNGEON_SCORE_LINK_LEVEL_CLASS_FORMAT_STRING:format(playerLevel, className), HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddNormalLine(ItemRefTooltip, DUNGEON_SCORE_LINK_ITEM_LEVEL:format(playerItemLevel));

	local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore) or HIGHLIGHT_FONT_COLOR;
	GameTooltip_AddNormalLine(ItemRefTooltip, DUNGEON_SCORE_LINK_RATING:format(color:WrapTextInColorCode(dungeonScore)));
	GameTooltip_AddNormalLine(ItemRefTooltip, DUNGEON_SCORE_LINK_RUNS_SEASON:format(runsThisSeason));

	if(bestSeasonScore ~= 0) then 
		local bestSeasonColor = C_ChallengeMode.GetDungeonScoreRarityColor(bestSeasonScore) or HIGHLIGHT_FONT_COLOR; 
		GameTooltip_AddNormalLine(ItemRefTooltip, DUNGEON_SCORE_LINK_PREVIOUS_HIGH:format(bestSeasonColor:WrapTextInColorCode(bestSeasonScore), bestSeasonNumber)); 
	end		
	GameTooltip_AddBlankLineToTooltip(ItemRefTooltip);

	local sortTable = { };
	for i = DUNGEON_SCORE_LINK_INDEX_START, (#splits), DUNGEON_SCORE_LINK_ITERATE do
		local mapChallengeModeID = tonumber(splits[i]);
		local completedInTime = splits[i + 1] == "1";
		local level = tonumber(splits[i + 2]);

		local mapName = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID);

		--If any of the maps don't exist.. this is a bad link
		if(not mapName) then 
			return; 
		end 

		table.insert(sortTable, { mapName = mapName, completedInTime = completedInTime, level = level });
	end

	-- Sort Alphabetically. 
	table.sort(sortTable, function(a, b) return strcmputf8i(a.mapName, b.mapName) < 0; end);

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
	local runHistory = C_MythicPlus.GetRunHistory(true, true);
	local bestSeasonScore, bestSeasonNumber = C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion(); 
	local dungeonScoreTable = { C_ChallengeMode.GetOverallDungeonScore(), UnitGUID("player"), playerName, class, math.ceil(avgItemLevel), UnitLevel("player"), runHistory and #runHistory or 0, bestSeasonScore, bestSeasonNumber, unpack(DungeonScoreLinkAddDungeonsToTable())};
	return NORMAL_FONT_COLOR:WrapTextInColorCode(LinkUtil.FormatLink(LinkTypes.DungeonScore, DUNGEON_SCORE_LINK, unpack(dungeonScoreTable)));
end		

function GetPvpRatingLink(playerName)
	local fontColor = NORMAL_FONT_COLOR;
	local _, _, class = UnitClass("player");
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
	local pvpRatingTable = { UnitGUID("player"), playerName, class, math.ceil(avgItemLevelPvP), UnitLevel("player"), unpack(AddPvpRatingsToTable())};
	return fontColor:WrapTextInColorCode(LinkUtil.FormatLink(LinkTypes.PvPRating, PVP_PERSONAL_RATING_LINK, unpack(pvpRatingTable)));
end

function GetCalendarEventLink(monthOffset, monthDay, index)
	local dayEvent = C_Calendar.GetDayEvent(monthOffset, monthDay, index);
	if dayEvent then
		return LinkUtil.FormatLink(LinkTypes.CalendarEvent, dayEvent.title, monthOffset, monthDay, index);
	end

	return nil;
end

function GetCommunityLink(clubId)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		local link = LinkUtil.FormatLink(LinkTypes.Community, COMMUNITY_REFERENCE_FORMAT:format(clubInfo.name), clubId);
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			return BATTLENET_FONT_COLOR:WrapTextInColorCode(link);
		else
			return NORMAL_FONT_COLOR:WrapTextInColorCode(link);
		end
	end

	return nil;
end

ItemRefTooltipMixin = {};

function ItemRefTooltipMixin:OnLoad()
	GameTooltip_OnLoad(self);
	self:RegisterForDrag("LeftButton");
	self.shoppingTooltips = { ItemRefShoppingTooltip1, ItemRefShoppingTooltip2 };
end

function ItemRefTooltipMixin:OnUpdate(elapsed)
	if self.shouldRefreshData then
		self:RefreshData();
	end
	if self.updateTooltipTimer then
		if ( IsModifiedClick("COMPAREITEMS") ) then
			self.updateTooltipTimer = self.updateTooltipTimer - elapsed;
			if ( self.updateTooltipTimer > 0 ) then
				return;
			end
			self.updateTooltipTimer = TOOLTIP_UPDATE_TIME;
			GameTooltip_ShowCompareItem(self);
		else
			TooltipComparisonManager:Clear(self);
		end
	end
end

function ItemRefTooltipMixin:OnDragStart()
	self:StartMoving();
end

function ItemRefTooltipMixin:OnDragStop()
	self:StopMovingOrSizing();
	ValidateFramePosition(self);
end

function ItemRefTooltipMixin:OnEnter()
	self.updateTooltipTimer = 0;
end

function ItemRefTooltipMixin:OnLeave()
	for _, frame in pairs(self.shoppingTooltips) do
		frame:Hide();
	end
	self.updateTooltipTimer = nil;
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

function ItemRefTooltipMixin:SetHyperlink(...)
	-- it's the same hyperlink as current data, close instead
	local info = self:GetPrimaryTooltipInfo();
	if info and info.getterName == "GetHyperlink" then
		local getterArgs = {...};
		if tCompare(info.getterArgs, getterArgs) then
			self:Hide();
			return false;
		end
	end

	local tooltipInfo = CreateBaseTooltipInfo("GetHyperlink", ...);
	return self:ProcessInfo(tooltipInfo);
end