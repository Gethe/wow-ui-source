local _, addonTbl = ...;
local SecureCmdList = addonTbl.SecureCmdList;

SecureCmdList["PET_DEFENSIVEASSIST"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetDefensiveAssistMode();
	end
end

SecureCmdList["PET_ASSIST"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		C_PetInfo.PetAssistMode();
	end
end

SecureCmdList["PET_AUTOCASTON"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		C_Spell.SetSpellAutoCastEnabled(spell, true);
	end
end

SecureCmdList["PET_AUTOCASTOFF"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		C_Spell.SetSpellAutoCastEnabled(spell, false);
	end
end

SecureCmdList["PET_AUTOCASTTOGGLE"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		C_Spell.ToggleSpellAutoCast(spell);
	end
end

SecureCmdList["SUMMON_BATTLE_PET"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	local pet = SecureCmdOptionParse(msg);
	if ( type(pet) == "string" ) then
		local _, petID = C_PetJournal.FindPetIDByName(string.trim(pet));
		if ( petID ) then
			C_PetJournal.SummonPetByGUID(petID);
		else
			C_PetJournal.SummonPetByGUID(pet);
		end
	end
end

SecureCmdList["RANDOMPET"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	if ( SecureCmdOptionParse(msg) ) then
		C_PetJournal.SummonRandomPet(false);
	end
end

SecureCmdList["RANDOMFAVORITEPET"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	if ( SecureCmdOptionParse(msg) ) then
		C_PetJournal.SummonRandomPet(true);
	end
end

SecureCmdList["DISMISSBATTLEPET"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	if ( SecureCmdOptionParse(msg) ) then
		local petID = C_PetJournal.GetSummonedPetGUID();
		if ( petID ) then
			C_PetJournal.SummonPetByGUID(petID);
		end
	end
end

SecureCmdList["USE_TOY"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	local toyName = SecureCmdOptionParse(msg);
	if ( toyName and toyName ~= "" ) then
		UseToyByName(toyName)
	end
end

if not C_Glue.IsOnGlueScreen() then
	local function CleanupPingTypeString(pingTypeString)
		local cleanString = pingTypeString:gsub("%s+", "");
		cleanString = strupper(cleanString);
		return cleanString;
	end
	local pingNameToTypeTable = {
		["1"] = Enum.PingSubjectType.Attack,
		[CleanupPingTypeString(PING_TYPE_ATTACK)] = Enum.PingSubjectType.Attack,
		["2"] = Enum.PingSubjectType.Warning,
		[CleanupPingTypeString(PING_TYPE_WARNING)] = Enum.PingSubjectType.Warning,
		["3"] = Enum.PingSubjectType.OnMyWay,
		[CleanupPingTypeString(PING_TYPE_ON_MY_WAY)] = Enum.PingSubjectType.OnMyWay,
		["4"] = Enum.PingSubjectType.Assist,
		[CleanupPingTypeString(PING_TYPE_ASSIST)] = Enum.PingSubjectType.Assist,
		["5"] = Enum.PingSubjectType.AlertNotThreat,
		[CleanupPingTypeString(PING_TYPE_NOT_THREAT)] = Enum.PingSubjectType.AlertNotThreat,
		["6"] = Enum.PingSubjectType.AlertThreat,
		[CleanupPingTypeString(PING_TYPE_THREAT)] = Enum.PingSubjectType.AlertThreat,
	};
	SecureCmdList["PING"] = function(msg)
		local action, target = SecureCmdOptionParse(msg);
		local pingType;
		if action then
			pingType = pingNameToTypeTable[CleanupPingTypeString(action)];
		end

		-- If you don't have a target but were trying to use one then just return
		-- We were trying to ping a target which we couldn't get due to some conditional
		-- Don't wanna try and send a ping since that will do it's best to come up with a target to use which isn't our intention in this case
		if not target and msg:find("%[.+%]") then
			return;
		end

		C_Ping.SendMacroPing(pingType, target);
	end
end

SecureCmdList["ABANDON"] = function(msg)
	if C_PartyInfo.ChallengeModeRestrictionsActive() then
		C_PartyInfo.StartInstanceAbandonVote();
	end
end

SlashCmdList["INVITE"] = function(msg)
	if(msg == "") then
		msg = GetUnitName("target", true)
	end
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if(msg == nil) then
		ChatFrame_DisplayUsageError(ERR_NO_TARGET_OR_NAME);
		return;
	end
	C_PartyInfo.InviteUnit(msg);
end

SlashCmdList["REQUEST_INVITE"] = function(msg)
	if(msg == "") then
		msg = GetUnitName("target", true)
	end
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if(msg == nil) then
		ChatFrame_DisplayUsageError(ERR_NO_TARGET_OR_NAME);
		return;
	end
	C_PartyInfo.RequestInviteFromUnit(msg);
end

SlashCmdList["CHAT_AFK"] = function(msg)
	if C_PvP.IsInRatedMatchWithDeserterPenalty() then
		ConfirmOrLeaveBattlefield();
		return;
	end

	C_ChatInfo.SendChatMessage(msg, "AFK");
end

SlashCmdList["RAID_INFO"] = function(msg)
	RaidFrame.slashCommand = 1;
	if ( ( GetNumSavedInstances() + GetNumSavedWorldBosses() > 0 ) and not RaidInfoFrame:IsVisible() ) then
		ToggleRaidFrame();
		RaidInfoFrame:Show();
	elseif ( not RaidFrame:IsVisible() ) then
		ToggleRaidFrame();
	end
end

SlashCmdList["DUNGEONS"] = function(msg)
	ToggleLFDParentFrame();
end

SlashCmdList["LEAVEVEHICLE"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		VehicleExit();
	end
end

SlashCmdList["CALENDAR"] = function(msg)
	local inGameCalendarDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.IngameCalendarDisabled);
	if inGameCalendarDisabled then
		return;
	end

	if ( not C_AddOns.IsAddOnLoaded("Blizzard_Calendar") ) then
		UIParentLoadAddOn("Blizzard_Calendar");
	end
	if ( Calendar_Toggle ) then
		Calendar_Toggle();
	end
end

SlashCmdList["SET_TITLE"] = function(msg)
	local name = SecureCmdOptionParse(msg);
	if ( name and name ~= "") then
		if(not SetTitleByName(name)) then
			UIErrorsFrame:AddMessage(TITLE_DOESNT_EXIST, 1.0, 0.1, 0.1, 1.0);
		end
	else
		SetCurrentTitle(-1)
	end
end

SlashCmdList["FRAMESTACK"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools");

	local showHiddenArg, showRegionsArg, showAnchorsArg;
	local pattern = "^%s*(%S+)(.*)$";
	showHiddenArg, msg = string.match(msg or "", pattern);
	showRegionsArg, msg = string.match(msg or "", pattern);
	showAnchorsArg, msg = string.match(msg or "", pattern);

	-- If no parameters are passed the defaults specified by these cvars are used instead.
	local showHiddenDefault = FrameStackTooltip_IsShowHiddenEnabled();
	local showRegionsDefault = FrameStackTooltip_IsShowRegionsEnabled();
	local showAnchorsDefault = FrameStackTooltip_IsShowAnchorsEnabled();

	local showHidden = StringToBoolean(showHiddenArg or "", showHiddenDefault);
	local showRegions = StringToBoolean(showRegionsArg or "", showRegionsDefault);
	local showAnchors = StringToBoolean(showAnchorsArg or "", showAnchorsDefault);

	FrameStackTooltip_Toggle(showHidden, showRegions, showAnchors);
end

SlashCmdList["SOLOSHUFFLE_WARGAME"] = function(msg)
	StartSoloShuffleWarGameByName(msg);
end

SlashCmdList["SOLORBG_WARGAME"] = function(msg)
	C_PvP.StartSoloRBGWarGameByName(msg);
end

SlashCmdList["SPECTATOR_WARGAME"] = function(msg)
	local target1, target2, size, area, isTournamentMode = strmatch(msg, "^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s*([^%s]*)%s*([^%s]*)")
	if (not target1 or not target2 or not size) then
		return;
	end

	local bnetIDGameAccount1, bnetIDGameAccount2 = ChatFrame_WargameTargetsVerifyBNetAccounts(target1, target2);
	if (area == "" or area == "nil" or area == "0") then area = nil end

	StartSpectatorWarGame(bnetIDGameAccount1 or target1, bnetIDGameAccount2 or target2, size, area, ValueToBoolean(isTournamentMode));
end

SlashCmdList["SPECTATOR_SOLOSHUFFLE_WARGAME"] = function(msg)
	local target1, target2, area, isTournamentMode = strmatch(msg, "^([^%s]+)%s+([^%s]+)%s*([^%s]*)%s*([^%s]*)");
	if (not target1 or not target2) then
		return;
	end

	local bnetIDGameAccount1, bnetIDGameAccount2 = ChatFrame_WargameTargetsVerifyBNetAccounts(target1, target2);
	if (area == "" or area == "nil" or area == "0") then area = nil end

	StartSpectatorSoloShuffleWarGame(bnetIDGameAccount1 or target1, bnetIDGameAccount2 or target2, area, ValueToBoolean(isTournamentMode));
end

SlashCmdList["SPECTATOR_SOLORBG_WARGAME"] = function(msg)
	local target1, target2, area, isTournamentMode = strmatch(msg, "^([^%s]+)%s+([^%s]+)%s*([^%s]*)%s*([^%s]*)");
	if (not target1 or not target2) then
		return;
	end

	local bnetIDGameAccount1, bnetIDGameAccount2 = ChatFrame_WargameTargetsVerifyBNetAccounts(target1, target2);
	if (area == "" or area == "nil" or area == "0") then area = nil end

	C_PvP.StartSpectatorSoloRBGWarGame(bnetIDGameAccount1 or target1, bnetIDGameAccount2 or target2, area, ValueToBoolean(isTournamentMode));
end

function ChatFrame_WargameTargetsVerifyBNetAccounts(target1, target2)
	local bnetIDGameAccount1 = BNet_GetBNetIDAccountFromCharacterName(target1) or BNet_GetBNetIDAccount(target1);
	if not bnetIDGameAccount1 then
		C_Log.LogErrorMessage("Failed to find StartSpectatorSoloShuffleWarGame target1:", target1);
	end
	local bnetIDGameAccount2 = BNet_GetBNetIDAccountFromCharacterName(target2) or BNet_GetBNetIDAccount(target2);
	if not bnetIDGameAccount2 then
		C_Log.LogErrorMessage("Failed to find StartSpectatorSoloShuffleWarGame target2:", target2);
	end
	return bnetIDGameAccount1, bnetIDGameAccount2;
end

SlashCmdList["GUILDFINDER"] = function(msg)
	if ( GameLimitedMode_IsActive() ) then
		UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, 1.0, 0.1, 0.1, 1.0);
	else
		ToggleGuildFinder();
	end
end

SlashCmdList["TRANSMOG_OUTFIT"] = function(msg)
	local itemTransmogInfoList = TransmogUtil.ParseOutfitSlashCommand(msg);
	if itemTransmogInfoList then
		local showOutfitDetails = true;
		DressUpItemTransmogInfoList(itemTransmogInfoList, showOutfitDetails);
	end
end

SlashCmdList["COMMUNITY"] = function(msg)
	if msg == "" then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(COMMUNITY_COMMAND_SYNTAX, info.r, info.g, info.b, info.id);
		return;
	end

	local command, clubType = string.split(" ", string.lower(msg));
	local loadCommunity = function()
		if not CommunitiesFrame or not CommunitiesFrame:IsShown() then
			ToggleCommunitiesFrame();
		end
	end
	if command == string.lower(COMMUNITY_COMMAND_JOIN) then
		loadCommunity();
		AddCommunitiesFlow_Toggle()
	elseif command == string.lower(COMMUNITY_COMMAND_CREATE) then
		if clubType == string.lower(COMMUNITY_COMMAND_CHARACTER) then
			loadCommunity();
			CommunitiesCreateCommunityDialog();
		elseif clubType == string.lower(COMMUNITY_COMMAND_BATTLENET) then
			loadCommunity();
			CommunitiesCreateBattleNetDialog();
		end
	end
end

SlashCmdList["RAF"] = function(msg)
	if(C_RecruitAFriend.IsEnabled()) then
		ToggleRafPanel();
	end
end

SlashCmdList["EDITMODE"] = function(msg)
	if EditModeManagerFrame:CanEnterEditMode() then
		ShowUIPanel(EditModeManagerFrame);
	else
		ChatFrame_DisplaySystemMessageInPrimary(ERROR_SLASH_EDITMODE_CANNOT_ENTER);
	end
end
