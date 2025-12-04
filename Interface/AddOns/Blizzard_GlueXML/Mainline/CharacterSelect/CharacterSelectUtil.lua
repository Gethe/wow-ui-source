
local s_vasQueueTimes = {};
local s_autoSwitchRealm = false;
local showDebugTooltipInfo = GetCVarBool("debugTargetInfo");

CharacterSelectUtil.ConfigParam = {
	DisableCampsites = 1,					-- Disable the camps button in the nav bar.
	DisableRealmSelection = 2,				-- Disable the Realms button in the nav bar.
	VASTokens = 3,							-- Show/Hide VAS tokens.
	CharacterListSearch = 4,				-- Show/Hide the character list search bar.
	CharacterListAddGroup = 5,				-- Show/Hide the character list add group button.
	CharacterListGroupCollapse = 6,			-- Prevent collapsing character groups. Useful when there's only 1.
	CharacterListFaction = 7,				-- Show/Hide the display of character faction.
	CharacterListUngroupedSection = 8,		-- Only show character list groups.
	CharacterListDetails = 9,				-- Show/Hide the display of character info (level, class, zone, etc).
	CharacterContext = 10,					-- Show/Hide the display of character info in the scene.
	CharacterTooltips = 11,					-- Allow/disallow tooltips in the character select list and in the camp scene.
};

function CharacterSelectUtil.GetConfig()
	return CharacterSelectUI:GetConfig();
end

function CharacterSelectUtil.ShouldExpandCharacterList()
	return GetCVarBool("expandWarbandCharacterList");
end

function CharacterSelectUtil.IsUndeleting()
	return CharacterSelect.undeleting;
end

function CharacterSelectUtil.SelectAtIndex(characterIndex)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharacterSelect_SelectCharacter(characterIndex);
end

function CharacterSelectUtil.IsAccountLocked()
	return C_AccountServices.IsAccountLockedPostSave();
end

function CharacterSelectUtil.IsStoreAvailable()
	if not C_StorePublic.IsEnabled() then
		return false;
	end

	return (GetNumCharacters() > 0) and not CharacterSelectUtil.IsAccountLocked();
end

function CharacterSelectUtil.ShouldStoreBeEnabled()
	return CharacterSelectUI:ShouldStoreBeEnabled();
end

function CharacterSelectUtil.CreateNewCharacter(characterType, timerunningSeasonID)
	if CharacterSelectUtil.IsAccountLocked() then
		return;
	end

	C_CharacterCreation.SetCharacterCreateType(characterType);
	C_CharacterCreation.SetTimerunningSeasonID(timerunningSeasonID);

	if GlueParent_GetCurrentScreen() == "charcreate" then
		CharacterCreateFrame:UpdateTimerunningChoice();
	else
		CharacterSelectListUtil.SaveCharacterOrder();
		CharacterSelect_SelectCharacter(CharacterSelect.createIndex);
	end
end

function CharacterSelectUtil.ChangeRealm()
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER);
	CharacterSelectListUtil.SaveCharacterOrder();
	CharacterSelectCharacterFrame:ClearSearch();
	CharacterSelectUtil.SetAutoSwitchRealm(false);
	C_RealmList.RequestChangeRealmList();
end

function CharacterSelectUtil.SetAutoSwitchRealm(autoSwitchRealm)
	s_autoSwitchRealm = autoSwitchRealm;
end

function CharacterSelectUtil.GetAutoSwitchRealm()
	return s_autoSwitchRealm;
end

-- Required for backwards compatibility with store.
CharacterSelect_SetAutoSwitchRealm = CharacterSelectUtil.SetAutoSwitchRealm;

function CharacterSelectUtil.UpdateVASQueueTime(guid, minutes)
	s_vasQueueTimes[guid] = minutes;
end

function CharacterSelectUtil.GetVASQueueTime(guid)
	return s_vasQueueTimes[guid];
end

function CharacterSelectUtil.FormatCharacterName(name, timerunningSeasonID, offsetX, offsetY)
	if timerunningSeasonID then
		return CreateAtlasMarkup("timerunning-glues-icon", 11, 11, offsetX, offsetY)..name;
	else
		return name;
	end
end

function CharacterSelectUtil.UpdateShowDebugTooltipInfo(state)
	showDebugTooltipInfo = state;
end

function CharacterSelectUtil.SetTooltipForCharacterInfo(characterInfo, characterID)
	if not characterInfo then
		return false;
	end

	local config = CharacterSelectUtil.GetConfig();
	if not config[CharacterSelectUtil.ConfigParam.CharacterTooltips] then
		return false;
	end

	-- Block 1
	local name = characterInfo.name;
	local realmName = characterInfo.realmName;

	-- Block 2
	local level = characterInfo.experienceLevel;
	local specID = characterInfo.specID;
	local _, specName = GetSpecializationInfoForSpecID(specID);
	local className = characterInfo.className;
	local areaName = characterInfo.areaName;

	-- Block 3
	local raceID = characterInfo.raceID;
	local profession0 = characterInfo.profession0;
	local profession1 = characterInfo.profession1;
	local professionName0 = profession0 ~= 0 and GetSkillLineDisplayNameForRace(profession0, raceID) or nil;
	local professionName1 = profession1 ~= 0 and GetSkillLineDisplayNameForRace(profession1, raceID) or nil;

	-- Block 4
	local realmAddress = characterInfo.realmAddress;
	local money = CharacterSelectUtil.IsSameRealmAsCurrent(realmAddress) and characterInfo.money or 0;

	-- Block 5
	local catchupAvailable = characterID and IsRPEBoostEligible(characterID);

	GameTooltip_AddColoredLine(GlueTooltip, name, WHITE_FONT_COLOR);
	GameTooltip_AddColoredLine(GlueTooltip, CHARACTER_SELECT_REALM_TOOLTIP:format(realmName), GRAY_FONT_COLOR);
	if showDebugTooltipInfo then
		GameTooltip_AddColoredLine(GlueTooltip, characterInfo.guid, GRAY_FONT_COLOR);
	end


	GameTooltip_AddBlankLineToTooltip(GlueTooltip);
	if className then
		local color = CreateColor(GetClassColor(characterInfo.classFilename));
		if specName and specName ~= "" and className then
			local formattedSpecAndClass = TALENT_SPEC_AND_CLASS:format(specName, className);
			GameTooltip_AddColoredLine(GlueTooltip, color:WrapTextInColorCode(formattedSpecAndClass), BLUE_FONT_COLOR);
		elseif className then
			GameTooltip_AddColoredLine(GlueTooltip, color:WrapTextInColorCode(className), BLUE_FONT_COLOR);
		end
	end

	GameTooltip_AddColoredLine(GlueTooltip, CHARACTER_SELECT_LEVEL_TOOLTIP:format(level), WHITE_FONT_COLOR);

	if areaName then
		GameTooltip_AddColoredLine(GlueTooltip, areaName, GRAY_FONT_COLOR);
	end

	-- Add a blank line only if we have populated fields for the next section.
	if professionName0 or professionName1 then
		GameTooltip_AddBlankLineToTooltip(GlueTooltip);

		if professionName0 and professionName1 then
			GameTooltip_AddColoredLine(GlueTooltip, CHARACTER_SELECT_PROFESSIONS:format(professionName0, professionName1), WHITE_FONT_COLOR);
		elseif professionName0 then
			GameTooltip_AddColoredLine(GlueTooltip, professionName0, WHITE_FONT_COLOR);
		elseif professionName1 then
			GameTooltip_AddColoredLine(GlueTooltip, professionName1, WHITE_FONT_COLOR);
		end
	end

	-- Add a blank line only if we have populated fields for the next section.
	if money and money > 0 then
		GameTooltip_AddBlankLineToTooltip(GlueTooltip);

		SetTooltipMoney(GlueTooltip, money);
	end
	
	-- Add a blank line only if we have populated fields for the next section.
	if catchupAvailable then
		GameTooltip_AddBlankLineToTooltip(GlueTooltip);

		GameTooltip_AddNormalLine(GlueTooltip, RPE_CATCH_UP_AVAILABLE);
	end

	return true;
end

function CharacterSelectUtil.GetFormattedCurrentRealmName()
	local formattedRealmName = "";

	local serverName, _, isRP = GetServerName();
	local connected = IsConnectedToServer();
	if serverName then
		if not connected then
			serverName = serverName .. " (" .. SERVER_DOWN .. ")";
		end

		formattedRealmName = isRP and (serverName .. " " .. RP_PARENTHESES) or serverName;
	end

	return formattedRealmName;
end

function CharacterSelectUtil.IsSameRealmAsCurrent(realmAddress)
	local currentRealmAddress = select(5, GetServerName());
	return (currentRealmAddress and realmAddress) and realmAddress == currentRealmAddress;
end

function CharacterSelectUtil.IsFilteringCharacterList()
	return CharacterSelectCharacterFrame.SearchBox:IsShown() and CharacterSelectCharacterFrame.SearchBox:GetText() ~= "";
end
