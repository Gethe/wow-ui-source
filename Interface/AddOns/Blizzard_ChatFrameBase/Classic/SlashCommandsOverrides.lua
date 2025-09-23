local _, addonTbl = ...;
local SecureCmdList = addonTbl.SecureCmdList;

SecureCmdList["DUEL_TO_THE_DEATH"] = function(msg)
	if(not msg or msg == "") then
		msg = GetUnitName("target", true);
	end
	if (msg == "" or not msg or not C_GameRules.IsHardcoreActive()) then
		return;
	end

	local text2 = nil;
	local data = {unit = "target"};
	StaticPopup_Show("DUEL_TO_THE_DEATH_CHALLENGE_CONFIRM", msg, text2, data);
end

SecureCmdList["PET_ASSIST"] = function(msg)
	if ( IsPetAssistAvailable() and SecureCmdOptionParse(msg) ) then
		C_PetInfo.PetAssistMode();
	end
end

SecureCmdList["PET_AUTOCASTON"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		EnableSpellAutocast(spell);
	end
end

SecureCmdList["PET_AUTOCASTOFF"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		DisableSpellAutocast(spell);
	end
end

SecureCmdList["PET_AUTOCASTTOGGLE"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		ToggleSpellAutocast(spell);
	end
end

SecureCmdList["TEAM_INVITE"] = function(msg)
	if ( msg ~= "" and GetCurrentArenaSeasonUsesTeams() ) then
		local team, name = strmatch(msg, "^(%d+)[%w+%d+]*%s+(.*)");
		if ( team and name ) then
			if ( strlen(name) > MAX_CHARACTER_NAME_BYTES ) then
				ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
				return;
			end
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					ArenaTeamInviteByName(teamsizeID, name);
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_INVITE);
end

SecureCmdList["TEAM_QUIT"] = function(msg)
	if ( msg ~= "" ) then
		local team = strmatch(msg, "^(%d+)[%w+%d+]*");
		if ( team ) then
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					ArenaTeamLeave(teamsizeID);
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_QUIT);
end

SecureCmdList["TEAM_UNINVITE"] = function(msg)
	if ( msg ~= "" ) then
		local team, name = strmatch(msg, "^(%d+)[%w+%d+]*%s+(.*)");
		if ( team and name ) then
			if ( strlen(name) > MAX_CHARACTER_NAME_BYTES ) then
				ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
				return;
			end
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					ArenaTeamUninviteByName(teamsizeID, name);
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_UNINVITE);
end

SecureCmdList["TEAM_CAPTAIN"] = function(msg)
	if ( msg ~= "" ) then
		local team, name = strmatch(msg, "^(%d+)[%w+%d+]*%s+(.*)");
		if ( team and name ) then
			if ( strlen(name) > MAX_CHARACTER_NAME_BYTES ) then
				ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
				return;
			end
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					ArenaTeamSetLeaderByName(teamsizeID, name);
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_CAPTAIN);
end

SecureCmdList["TEAM_DISBAND"] = function(msg)
	if ( msg ~= "" ) then
		local team = strmatch(msg, "^(%d+)[%w+%d+]*");
		if ( team ) then
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					local teamName, teamSize = GetArenaTeam(teamsizeID);
					for i = 1, teamSize * 2 do
						local name, rank = GetArenaTeamRosterInfo(teamsizeID, i);
						if ( rank == 0 ) then
							if ( name == UnitName("player") ) then
								StaticPopup_Show("CONFIRM_TEAM_DISBAND", teamName, nil, teamsizeID);
							end
							break;
						end
					end
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_DISBAND);
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
	InviteToGroup(msg);
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
	RequestInviteFromUnit(msg);
end

SlashCmdList["GUILD_ROSTER"] = function(msg)
	if ( IsInGuild() ) then
		ToggleFriendsFrame(FRIEND_TAB_GUILD);
	end
end

SlashCmdList["CHAT_AFK"] = function(msg)
	C_ChatInfo.SendChatMessage(msg, "AFK");
end

SlashCmdList["LOOT_FFA"] = function(msg)
	C_PartyInfo.SetLootMethod(Enum.LootMethod.Freeforall);
end

SlashCmdList["LOOT_ROUNDROBIN"] = function(msg)
	C_PartyInfo.SetLootMethod(Enum.LootMethod.Roundrobin);
end

SlashCmdList["LOOT_MASTER"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		C_PartyInfo.SetLootMethod(Enum.LootMethod.Masterlooter, GetSlashCmdTarget(msg));
	end
end

SlashCmdList["FRAMESTACK"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools");

	local showHiddenArg, showRegionsArg, showAnchorsArg;

	showHiddenArg, msg = string.match(msg or "", "^%s*(%S+)(.*)$");
	showRegionsArg, msg = string.match(msg or "", "^%s*(%S+)(.*)$");
	showAnchorsArg, msg =  string.match(msg or "", "^%s*(%S+)(.*)$");

	local showHidden = StringToBoolean(showHiddenArg or "", false);
	local showRegions = StringToBoolean(showRegionsArg or "", true);
	local showAnchors = StringToBoolean(showAnchorsArg or "", true);

	FrameStackTooltip_Toggle(showHidden, showRegions, showAnchors);
end

SLASH_PERFREPORT1 = "/perfreport";
SlashCmdList["PERFREPORT"] = function(msg)
	C_ChatInfo.ReportServerLag();
end

SlashCmdList["SPECTATOR_WARGAME"] = function(msg)
	local target1, target2, size, area, isTournamentMode = strmatch(msg, "^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s*([^%s]*)%s*([^%s]*)")
	if (not target1 or not target2 or not size) then
		return;
	end

	local bnetIDGameAccount1 = BNet_GetBNetIDAccountFromCharacterName(target1) or BNet_GetBNetIDAccount(target1);
	if not bnetIDGameAccount1 then
		C_Log.LogErrorMessage("Failed to find StartSpectatorWarGame target1:", target1);
	end
	local bnetIDGameAccount2 = BNet_GetBNetIDAccountFromCharacterName(target2) or BNet_GetBNetIDAccount(target2);
	if not bnetIDGameAccount2 then
		C_Log.LogErrorMessage("Failed to find StartSpectatorWarGame target2:", target2);
	end
	if (area == "" or area == "nil" or area == "0") then area = nil end
	StartSpectatorWarGame(bnetIDGameAccount1 or target1, bnetIDGameAccount2 or target2, size, area, ValueToBoolean(isTournamentMode));
end
