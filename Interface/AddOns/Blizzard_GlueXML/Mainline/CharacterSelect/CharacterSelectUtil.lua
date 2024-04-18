
local s_vasQueueTimes = {};
local s_autoSwitchRealm = false;


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
		CharacterSelect_SelectCharacter(CharacterSelect.createIndex);
	end
end

function CharacterSelectUtil.ChangeRealm()
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER);
	CharacterSelectListUtil.CheckSaveCharacterOrder();
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
	-- There's more, just starting with this for now.
	local name, raceName, raceFilename, className, classFilename, classID, experienceLevel, areaName, genderEnum, isGhost,
		hasCustomize, hasRaceChange, hasFactionChange, deprecated1, guid, profession0, profession1, genderID, boostInProgress,
	 	hasNameChange, isLocked, isTrialBoost, isTrialBoostCompleted, isRevokedCharacterUpgrade, vasServiceInProgress, lastLoginBuild,
	 	specID, isExpansionTrialCharacter, faction, lockedByExpansion, mailSenders, customizeDisabled, deprecated2,
		characterServiceRequiresLogin, raceID = GetCharacterInfo(characterIndex);

	if not name then
		return nil;
	end

	return {
		name = name,
		raceName = raceName,
		raceFilename = raceFilename,
		className = className,
		classFilename = classFilename,
		classID = classID,
		experienceLevel = experienceLevel,
		areaName = areaName,
		genderEnum = genderEnum,
		isGhost = isGhost,
		hasCustomize = hasCustomize,
		hasRaceChange = hasRaceChange,
		hasFactionChange = hasFactionChange,
		guid = guid,
		profession0 = profession0,
		profession1 = profession1,
		genderID = genderID,
		boostInProgress = boostInProgress,
		hasNameChange = hasNameChange,
		isLocked = isLocked,
		isTrialBoost = isTrialBoost,
		isTrialBoostCompleted = isTrialBoostCompleted,
		isRevokedCharacterUpgrade = isRevokedCharacterUpgrade,
		vasServiceInProgress = vasServiceInProgress,
		lastLoginBuild = lastLoginBuild,
		specID = specID,
		isExpansionTrialCharacter = isExpansionTrialCharacter,
		faction = faction,
		lockedByExpansion = lockedByExpansion,
		mailSenders = mailSenders,
		customizeDisabled = customizeDisabled,
		characterServiceRequiresLogin = characterServiceRequiresLogin,
		raceID = raceID
	};
end

function CharacterSelectUtil.FormatCharacterName(name, timerunningSeasonID)
	if timerunningSeasonID then
		return CreateAtlasMarkup("timerunning-glues-icon", 12, 12)..name;
	else
		return name;
	end
end

function CharacterSelectUtil.SetTooltipForCharacterInfo(characterInfo)
	if not characterInfo then
		return;
	end

	-- Block 1
	local name = characterInfo.name;
	-- Realm;

	-- Block 2
	local specID = characterInfo.specID;
	local _, specName = GetSpecializationInfoForSpecID(specID);
	local className = characterInfo.className;
	-- Item Level
	local areaName = characterInfo.areaName;

	-- Block 3
	local raceID = characterInfo.raceID;
	local profession0 = characterInfo.profession0;
	local profession1 = characterInfo.profession1;
	local professionName0 = profession0 ~= 0 and GetSkillLineDisplayNameForRace(profession0, raceID) or nil;
	local professionName1 = profession1 ~= 0 and GetSkillLineDisplayNameForRace(profession1, raceID) or nil;
	-- Mythic+ Rating
	-- PvP Rating

	-- Block 4
	-- Gold

	GameTooltip_AddColoredLine(GlueTooltip, name, WHITE_FONT_COLOR);
	-- Realm

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
end