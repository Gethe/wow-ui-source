
local s_vasQueueTimes = {};
local s_autoSwitchRealm = false;
local showDebugTooltipInfo = GetCVarBool("debugTargetInfo");

CharacterSelectUtil = {};

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
	if not C_StorePublic.IsEnabled() or C_StorePublic.IsDisabledByParentalControls() then
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

function CharacterSelectUtil.GetCharacterInfoTable(characterIndex)
	local characterGuid = GetCharacterGUID(characterIndex);

	if not characterGuid then
		return nil;
	end

	local characterInfo = GetBasicCharacterInfo(characterGuid);
	if not characterInfo.name then
		return nil;
	end

	local serviceCharacterInfo = GetServiceCharacterInfo(characterGuid);
	MergeTable(characterInfo, serviceCharacterInfo);

	return characterInfo;
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
		return;
	end

	-- Block 1
	local name = characterInfo.name;
	local realmName = characterInfo.realmName;

	-- Block 2
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
	local hasGearUpdate = characterID and IsRPEBoostEligible(characterID);

	GameTooltip_AddColoredLine(GlueTooltip, name, WHITE_FONT_COLOR);
	GameTooltip_AddColoredLine(GlueTooltip, CHARACTER_SELECT_REALM_TOOLTIP:format(realmName), GRAY_FONT_COLOR);
	if showDebugTooltipInfo then
		GameTooltip_AddColoredLine(GlueTooltip, characterInfo.guid, GRAY_FONT_COLOR);
	end

	-- Add a blank line only if we have populated fields for the next section.
	if className or areaName then
		GameTooltip_AddBlankLineToTooltip(GlueTooltip);

		local color = CreateColor(GetClassColor(characterInfo.classFilename));
		if specName and className then
			local formattedSpecAndClass = TALENT_SPEC_AND_CLASS:format(specName, className);
			GameTooltip_AddColoredLine(GlueTooltip, color:WrapTextInColorCode(formattedSpecAndClass), BLUE_FONT_COLOR);
		elseif className then
			GameTooltip_AddColoredLine(GlueTooltip, color:WrapTextInColorCode(className), BLUE_FONT_COLOR);
		end

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
	if hasGearUpdate then
		GameTooltip_AddBlankLineToTooltip(GlueTooltip);

		GameTooltip_AddNormalLine(GlueTooltip, RPE_TOOLTIP_LINE1);
		GameTooltip_AddNormalLine(GlueTooltip, RPE_TOOLTIP_LINE2);

		if not CharacterSelectUtil.IsSameRealmAsCurrent(realmAddress) then
			GameTooltip_AddErrorLine(GlueTooltip, RPE_TOOLTIP_CHARACTER_ON_DIFFERENT_REALM);
		end
	end
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