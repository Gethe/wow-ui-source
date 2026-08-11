function LFD_IsEmpowered()
	-- Solo players are always empowered.
	if ( not IsInGroup() ) then
		return true;
	end

	-- The leader may always queue or dequeue.
	if ( UnitIsGroupLeader("player") ) then
		return true;
	end

	-- In DF groups, anyone may queue or dequeue. In RF groups, the leader or assistants may queue or dequeue.
	if ( HasLFGRestrictions() and (not IsInRaid() or UnitIsGroupAssistant("player")) ) then
		return true;
	end

	return false;
end

function IsInLFDBattlefield()
	return IsLFGModeActive(LE_LFG_CATEGORY_BATTLEFIELD);
end

function LeaveInstanceParty()
	if ( IsInLFDBattlefield() ) then
		local currentMapID, _, lfgID = select(8, GetInstanceInfo());
		local _, typeID, subtypeID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, lfgMapID = GetLFGDungeonInfo(lfgID);
		local subtypeUsesLFGTeleport = (subtypeID == LFG_SUBTYPEID_BATTLEFIELD) or (subtypeID == LFG_SUBTYPEID_TRAINING_GROUNDS);
		if currentMapID == lfgMapID and subtypeUsesLFGTeleport then
			LFGTeleport(true);
			return;
		end
	end
	C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE);
end

-- WALK_IN party members automatically leave the party upon zoning out
-- Porting out of a delve is only allowed when the delve is complete (unless a hearthstone or other tool is used)
function LeaveWalkInParty()
	C_PartyInfo.DelveTeleportOut();
end

function ConfirmOrLeaveBattlefield()
	if ( GetBattlefieldWinner() ) then
		LeaveBattlefield();
	else
		StaticPopupDialogs["CONFIRM_LEAVE_BATTLEFIELD"].acceptDelay = C_PvP.IsInRatedMatchWithDeserterPenalty() and 5 or nil;
		StaticPopup_Show("CONFIRM_LEAVE_BATTLEFIELD");
	end
end

function ConfirmSurrenderArena()
	StaticPopup_Show("CONFIRM_SURRENDER_ARENA");
end

function WillAcceptInviteRemoveQueues()
	--Dungeon/Raid Finder
	for i = 1, NUM_LE_LFG_CATEGORYS do
		local mode = GetLFGMode(i);
		if ( mode and mode ~= "lfgparty" ) then
			return true;
		end
	end

	--Don't need to look at LFGList listings because we can't accept invites while in one

	--LFGList applications
	local apps = C_LFGList.GetApplications();
	for i = 1, #apps do
		local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
		if ( appStatus == "applied" or appStatus == "invited" ) then
			return true;
		end
	end

	--PvP
	for i = 1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend, _, _, _, _, _, _, isSoloQueue = GetBattlefieldStatus(i);
		if ( (status == "queued" or status == "confirmed" ) and not isSoloQueue ) then
			return true;
		end
	end

	return false;
end

--Only really works on friends and guild-mates
function GetDisplayedInviteType(guid)
	if ( IsInGroup() ) then
		if ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
			return "INVITE";
		else
			return "SUGGEST_INVITE";
		end
	else
		if ( not guid ) then
			return "INVITE";
		end

		local party, isSoloQueueParty = C_SocialQueue.GetGroupForPlayer(guid);
		if ( party and not isSoloQueueParty ) then --In a real party, not a secret hidden party for solo queuing
			return "REQUEST_INVITE";
		elseif ( WillAcceptInviteRemoveQueues() ) then
			return "INVITE";
		elseif ( party ) then --They are queued solo for something
			return "REQUEST_INVITE";
		else
			return "INVITE";
		end
	end
end

function OnInviteToPartyConfirmation(name, willConvertToRaid, questSessionActive)
	if questSessionActive then
		HandleQuestSessionInviteToPartyConfirmation(name, willConvertToRaid);
	elseif willConvertToRaid then
		StaticPopup_Show("CONVERT_TO_RAID", nil, nil, name);
	else
		C_PartyInfo.ConfirmInviteUnit(name);
	end
end

local function AllowAutoAcceptInviteConfirmation(isQuickJoin, isSelfRelationship)
	return isQuickJoin and isSelfRelationship and GetCVarBool("autoAcceptQuickJoinRequests") and not C_QuestSession.Exists();
end

local function ShouldAutoAcceptInviteConfirmation(invite)
	local confirmationType, name, guid, rolesInvalid, willConvertToRaid = GetInviteConfirmationInfo(invite);
	local _, _, _, isQuickJoin, clubID = C_PartyInfo.GetInviteReferralInfo(invite);
	local _, _, selfRelationship = SocialQueueUtil_GetRelationshipInfo(guid, name, clubID);
	return AllowAutoAcceptInviteConfirmation(isQuickJoin, selfRelationship);
end

function UpdateInviteConfirmationDialogs()
	local invite = GetNextPendingInviteConfirmation();
	if invite then
		HandlePendingInviteConfirmation(invite);
	end
end

function HandlePendingInviteConfirmation(invite)
	if C_QuestSession.HasJoined() then
		HandlePendingInviteConfirmation_QuestSession(invite);
	else
		HandlePendingInviteConfirmation_StaticPopup(invite);
	end
end

function HandlePendingInviteConfirmation_StaticPopup(invite)
	if not StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION") then
		if ShouldAutoAcceptInviteConfirmation(invite) then
			RespondToInviteConfirmation(invite, true);
		else
			local text = CreatePendingInviteConfirmationText(invite);
			StaticPopup_Show("GROUP_INVITE_CONFIRMATION", text, nil, invite);
		end
	end
end

function HandlePendingInviteConfirmation_QuestSession(invite)
	-- Chances are that we never want to auto-accept in a quest session,
	-- so always show the dialog.
	local text = CreatePendingInviteConfirmationText(invite);
	ShowQuestSessionGroupInviteConfirmation(invite, text);
end

function CreatePendingInviteConfirmationText(invite)
	local confirmationType, name, guid, rolesInvalid, willConvertToRaid, _, _, _, isCrossFaction, playerFactionGroup, localizedFaction = GetInviteConfirmationInfo(invite);

	if confirmationType == LE_INVITE_CONFIRMATION_REQUEST then
		return CreatePendingInviteConfirmationText_Request(invite, name, guid, rolesInvalid, willConvertToRaid, isCrossFaction, playerFactionGroup, localizedFaction);
	elseif confirmationType == LE_INVITE_CONFIRMATION_SUGGEST then
		return CreatePendingInviteConfirmationText_Suggest(invite, name, guid, rolesInvalid, willConvertToRaid, isCrossFaction, playerFactionGroup, localizedFaction);
	else
		return CreatePendingInviteConfirmationText_AppendWarnings("", invite, name, guid, rolesInvalid, willConvertToRaid);
	end
end

function CreatePendingInviteConfirmationText_Request(invite, name, guid, rolesInvalid, willConvertToRaid, isCrossFaction, playerFactionGroup, localizedFaction)
	local coloredName, coloredSuggesterName = CreatePendingInviteConfirmationNames(invite, name, guid, rolesInvalid, willConvertToRaid);

	if isCrossFaction then
		coloredName = CROSS_FACTION_PLAYER_NAME:format(coloredName, localizedFaction);
	end

	local suggesterGuid, _, relationship, isQuickJoin, clubId = C_PartyInfo.GetInviteReferralInfo(invite);

	--If we ourselves have a relationship with this player, we'll just act as if they asked through us.
	local _, _, selfRelationship = SocialQueueUtil_GetRelationshipInfo(guid, name, clubId);

	local text;

	if selfRelationship then
		local clubLink = clubId and GetCommunityLink(clubId) or nil;
		if ( clubLink and selfRelationship == "club" ) then
			if isQuickJoin then
				text = INVITE_CONFIRMATION_REQUEST_FROM_COMMUNITY_QUICKJOIN:format(coloredName, clubLink);
			else
				text = INVITE_CONFIRMATION_REQUEST_FROM_COMMUNITY:format(coloredName, clubLink);
			end
		elseif isQuickJoin then
			text = INVITE_CONFIRMATION_REQUEST_QUICKJOIN:format(coloredName);
		else
			text = INVITE_CONFIRMATION_REQUEST:format(coloredName);
		end
	elseif suggesterGuid then
		if relationship == Enum.PartyRequestJoinRelation.Friend then
			text = (isQuickJoin and INVITE_CONFIRMATION_REQUEST_FRIEND_QUICKJOIN or INVITE_CONFIRMATION_REQUEST_FRIEND):format(coloredSuggesterName, coloredName);
		elseif relationship == Enum.PartyRequestJoinRelation.Guild then
			text = (isQuickJoin and INVITE_CONFIRMATION_REQUEST_GUILD_QUICKJOIN or INVITE_CONFIRMATION_REQUEST_GUILD):format(coloredSuggesterName, coloredName);
		elseif relationship == Enum.PartyRequestJoinRelation.Club then
			text = (isQuickJoin and INVITE_CONFIRMATION_REQUEST_COMMUNITY_QUICKJOIN or INVITE_CONFIRMATION_REQUEST_COMMUNITY):format(coloredSuggesterName, coloredName);
		else
			text = INVITE_CONFIRMATION_REQUEST:format(coloredName);
		end
	else
		text = (isQuickJoin and INVITE_CONFIRMATION_REQUEST_QUICKJOIN or INVITE_CONFIRMATION_REQUEST):format(coloredName);
	end

	return CreatePendingInviteConfirmationText_AppendWarnings(text, invite, name, guid, rolesInvalid, willConvertToRaid);
end

function CreatePendingInviteConfirmationNames(invite, name, guid, rolesInvalid, willConvertToRaid)
	local suggesterGuid, suggesterName, relationship, isQuickJoin, clubId = C_PartyInfo.GetInviteReferralInfo(invite);

	--If we ourselves have a relationship with this player, we'll just act as if they asked through us.
	local _, color, selfRelationship, playerLink = SocialQueueUtil_GetRelationshipInfo(guid, name, clubId);

	name = (playerLink and isQuickJoin) and ("[" .. playerLink .. "]") or name;

	if selfRelationship or isQuickJoin then
		name = color .. name .. FONT_COLOR_CODE_CLOSE;
	end

	if selfRelationship then
		return name;
	elseif suggesterGuid then
		local _, suggesterColor, suggesterRelationship = SocialQueueUtil_GetRelationshipInfo(suggesterGuid);
		if ( suggesterRelationship ) then
			suggesterName = suggesterColor .. suggesterName .. FONT_COLOR_CODE_CLOSE;
		end

		if relationship == Enum.PartyRequestJoinRelation.Friend or relationship == Enum.PartyRequestJoinRelation.Guild or relationship == Enum.PartyRequestJoinRelation.Club then
			return name, suggesterName;
		else
			return name;
		end
	else
		return name;
	end
end

function CreatePendingInviteConfirmationText_Suggest(invite, name, guid, rolesInvalid, willConvertToRaid, isCrossFaction, playerFactionGroup, localizedFaction)
	local suggesterGuid, suggesterName, relationship, isQuickJoin = C_PartyInfo.GetInviteReferralInfo(invite);
	local _, suggesterColor, suggesterRelationship = SocialQueueUtil_GetRelationshipInfo(suggesterGuid);
	if ( suggesterRelationship ) then
		suggesterName = suggesterColor .. suggesterName .. FONT_COLOR_CODE_CLOSE;
	end

	local _, nameColor, nameRelationship = SocialQueueUtil_GetRelationshipInfo(guid);
	if ( nameRelationship ) then
		name = nameColor .. name .. FONT_COLOR_CODE_CLOSE;
	end

	if isCrossFaction then
		name = CROSS_FACTION_PLAYER_NAME:format(name, localizedFaction);
	end

	-- Only using a single string here, if somebody is suggesting a person to join the group, QuickJoin text doesn't apply.
	local text = INVITE_CONFIRMATION_SUGGEST:format(suggesterName, name);

	return CreatePendingInviteConfirmationText_AppendWarnings(text, invite, name, guid, rolesInvalid, willConvertToRaid)
end

function CreatePendingInviteConfirmationText_AppendWarnings(text, invite, name, guid, rolesInvalid, willConvertToRaid)
	local warnings = CreatePendingInviteConfirmationText_GetWarnings(invite, name, guid, rolesInvalid, willConvertToRaid);
	if warnings ~= "" then
		if text ~= "" then
			return text .. "\n\n" .. warnings;
		else
			return warnings;
		end
	end

	return text;
end

function CreatePendingInviteConfirmationText_GetWarnings(invite, name, guid, rolesInvalid, willConvertToRaid)
	local warnings = {};
	local invalidQueues = C_PartyInfo.GetInviteConfirmationInvalidQueues(invite);
	if invalidQueues and #invalidQueues > 0 then
		if rolesInvalid then
			table.insert(warnings, INSTANCE_UNAVAILABLE_OTHER_NO_VALID_ROLES:format(name));
		end

		table.insert(warnings, INVITE_CONFIRMATION_QUEUE_WARNING:format(name));

		for i = 1, #invalidQueues do
			local queueName = SocialQueueUtil_GetQueueName(invalidQueues[i]);
			table.insert(warnings, NORMAL_FONT_COLOR:WrapTextInColorCode(queueName));
		end
	end

	if willConvertToRaid then
		table.insert(warnings, RED_FONT_COLOR:WrapTextInColorCode(LFG_LIST_CONVERT_TO_RAID_WARNING));
	end

	return table.concat(warnings, "\n");
end
