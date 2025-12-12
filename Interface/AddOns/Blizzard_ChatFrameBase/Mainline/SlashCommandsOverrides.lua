SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_ASSIST, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		C_PetInfo.PetAssistMode();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_AUTOCASTON, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		C_Spell.SetSpellAutoCastEnabled(spell, true);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_AUTOCASTOFF, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		C_Spell.SetSpellAutoCastEnabled(spell, false);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_AUTOCASTTOGGLE, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		C_Spell.ToggleSpellAutoCast(spell);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.USE_TOY, SLASH_COMMAND_CATEGORY.TOY, function(msg)
	local toyName = SecureCmdOptionParse(msg);
	if ( toyName and toyName ~= "" ) then
		UseToyByName(toyName)
	end
end);

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
	SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PING, SLASH_COMMAND_CATEGORY.PING, function(msg)
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
	end);
end

local abandonCooldownFormatter = CreateFromMixins(SecondsFormatterMixin);
abandonCooldownFormatter:Init(0, SecondsFormatter.Abbreviation.None, false, true);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.ABANDON, SLASH_COMMAND_CATEGORY.GROUP_COMMAND, function(msg)
	local _duration, cooldownTimeLeft = C_PartyInfo.GetInstanceAbandonVoteCooldownTime();
	if cooldownTimeLeft then
		local cooldownTimeLeftFormatted = abandonCooldownFormatter:Format(cooldownTimeLeft);
		local cooldownTimeLeftText = VOTE_TO_ABANDON_ON_COOLDOWN:format(cooldownTimeLeftFormatted);

		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(cooldownTimeLeftText, info.r, info.g, info.b, info.id);
	elseif C_PartyInfo.ChallengeModeRestrictionsActive() then
		C_PartyInfo.StartInstanceAbandonVote();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.INVITE, SLASH_COMMAND_CATEGORY.GROUP_COMMAND, function(msg)
	if(msg == "") then
		if not UnitIsHumanPlayer("target") then
			return;
		end

		msg = GetUnitName("target", true)
	end
	if( msg and (strlen(msg) > Constants.ChatFrameConstants.MaxCharacterNameBytes) ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if(msg == nil) then
		ChatFrameUtil.DisplayUsageError(ERR_NO_TARGET_OR_NAME);
		return;
	end
	C_PartyInfo.InviteUnit(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.REQUEST_INVITE, SLASH_COMMAND_CATEGORY.GROUP_COMMAND, function(msg)
	if(msg == "") then
		msg = GetUnitName("target", true)
	end
	if( msg and (strlen(msg) > Constants.ChatFrameConstants.MaxCharacterNameBytes) ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if(msg == nil) then
		ChatFrameUtil.DisplayUsageError(ERR_NO_TARGET_OR_NAME);
		return;
	end
	C_PartyInfo.RequestInviteFromUnit(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_AFK, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	if C_PvP.IsInRatedMatchWithDeserterPenalty() then
		ConfirmOrLeaveBattlefield();
		return;
	end

	C_ChatInfo.SendChatMessage(msg, "AFK");
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.DUNGEONS, SLASH_COMMAND_CATEGORY.DUNGEON, function(msg)
	ToggleLFDParentFrame();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.LEAVEVEHICLE, SLASH_COMMAND_CATEGORY.VEHICLE, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		VehicleExit();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CALENDAR, SLASH_COMMAND_CATEGORY.CALENDAR, function(msg)
	if Kiosk.IsEnabled() then
		return;
	end

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
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.SET_TITLE, SLASH_COMMAND_CATEGORY.TITLE, function(msg)
	local name = SecureCmdOptionParse(msg);
	if ( name and name ~= "") then
		if(not SetTitleByName(name)) then
			UIErrorsFrame:AddMessage(TITLE_DOESNT_EXIST, 1.0, 0.1, 0.1, 1.0);
		end
	else
		SetCurrentTitle(-1)
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.FRAMESTACK, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
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
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.SOLOSHUFFLE_WARGAME, SLASH_COMMAND_CATEGORY.PVP, function(msg)
	StartSoloShuffleWarGameByName(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.SOLORBG_WARGAME, SLASH_COMMAND_CATEGORY.PVP, function(msg)
	C_PvP.StartSoloRBGWarGameByName(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.SPECTATOR_WARGAME, SLASH_COMMAND_CATEGORY.COMMENTATOR, function(msg)
	local target1, target2, size, area, isTournamentMode = strmatch(msg, "^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s*([^%s]*)%s*([^%s]*)")
	if (not target1 or not target2 or not size) then
		return;
	end

	local bnetIDGameAccount1, bnetIDGameAccount2 = ChatFrame_WargameTargetsVerifyBNetAccounts(target1, target2);
	if (area == "" or area == "nil" or area == "0") then area = nil end

	StartSpectatorWarGame(bnetIDGameAccount1 or target1, bnetIDGameAccount2 or target2, size, area, ValueToBoolean(isTournamentMode));
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.SPECTATOR_SOLOSHUFFLE_WARGAME, SLASH_COMMAND_CATEGORY.COMMENTATOR, function(msg)
	local target1, target2, area, isTournamentMode = strmatch(msg, "^([^%s]+)%s+([^%s]+)%s*([^%s]*)%s*([^%s]*)");
	if (not target1 or not target2) then
		return;
	end

	local bnetIDGameAccount1, bnetIDGameAccount2 = ChatFrame_WargameTargetsVerifyBNetAccounts(target1, target2);
	if (area == "" or area == "nil" or area == "0") then area = nil end

	StartSpectatorSoloShuffleWarGame(bnetIDGameAccount1 or target1, bnetIDGameAccount2 or target2, area, ValueToBoolean(isTournamentMode));
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.SPECTATOR_SOLORBG_WARGAME, SLASH_COMMAND_CATEGORY.COMMENTATOR, function(msg)
	local target1, target2, area, isTournamentMode = strmatch(msg, "^([^%s]+)%s+([^%s]+)%s*([^%s]*)%s*([^%s]*)");
	if (not target1 or not target2) then
		return;
	end

	local bnetIDGameAccount1, bnetIDGameAccount2 = ChatFrame_WargameTargetsVerifyBNetAccounts(target1, target2);
	if (area == "" or area == "nil" or area == "0") then area = nil end

	C_PvP.StartSpectatorSoloRBGWarGame(bnetIDGameAccount1 or target1, bnetIDGameAccount2 or target2, area, ValueToBoolean(isTournamentMode));
end);

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

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.GUILDFINDER, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	if ( GameLimitedMode_IsActive() ) then
		UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, 1.0, 0.1, 0.1, 1.0);
	else
		ToggleGuildFinder();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.TRANSMOG_CUSTOM_SET, SLASH_COMMAND_CATEGORY.TRANSMOG, function(msg)
	local itemTransmogInfoList = TransmogUtil.ParseCustomSetSlashCommand(msg);
	if itemTransmogInfoList then
		local showCustomSetDetails = true;
		DressUpItemTransmogInfoList(itemTransmogInfoList, showCustomSetDetails);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.COMMUNITY, SLASH_COMMAND_CATEGORY.COMMUNITY, function(msg)
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
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RAF, SLASH_COMMAND_CATEGORY.SOCIAL, function(msg)
	if(C_RecruitAFriend.IsEnabled()) then
		ToggleRafPanel();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.EDITMODE, SLASH_COMMAND_CATEGORY.EDIT_MODE, function(msg)
	if EditModeManagerFrame:CanEnterEditMode() then
		ShowUIPanel(EditModeManagerFrame);
	else
		ChatFrameUtil.DisplaySystemMessageInPrimary(ERROR_SLASH_EDITMODE_CANNOT_ENTER);
	end
end);
