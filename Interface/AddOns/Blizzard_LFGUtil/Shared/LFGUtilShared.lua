function ConfirmOrLeaveLFGParty()
	if ( not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
		return;
	end

	if ( IsPartyLFG() and not IsLFGComplete() ) then
		local partyLFGSlot = GetPartyLFGID();
		local partyLFGCategory = nil;
		if ( partyLFGSlot ) then
			partyLFGCategory = GetLFGCategoryForID(partyLFGSlot);
		end
		StaticPopup_Show("CONFIRM_LEAVE_INSTANCE_PARTY", partyLFGCategory == LE_LFG_CATEGORY_WORLDPVP and CONFIRM_LEAVE_BATTLEFIELD or CONFIRM_LEAVE_INSTANCE_PARTY);
	else
		LeaveInstanceParty();
	end
end

function ConfirmOrLeaveParty()
	if ( not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
		return;
	end

	if ( IsPartyLFG() ) then
		ConfirmOrLeaveLFGParty();
	-- If the party is walk-in (aka Delve) let the player leave
	elseif ( C_PartyInfo.IsPartyWalkIn() ) then
		LeaveWalkInParty();
	end
end

function GetLFGMode(category, lfgID)
	if ( category ~= LE_LFG_CATEGORY_RF ) then
		lfgID = nil; -- RF works differently from everything else. You can queue for multiple RF slots with different ride tickets.
	end

	local proposalExists, id, _typeID, _subtypeID, _name, _texture, _role, hasResponded, _totalEncounters, _completedEncounters, _numMembers, _isLeader, _isHoliday, proposalCategory = GetLFGProposal();
	local _inParty, joined, queued = GetLFGInfoServer(category, lfgID);
	local roleCheckInProgress, _slots, _members, roleUpdateCategory, roleUpdateID = GetLFGRoleUpdate();

	local partyCategory = nil;
	local partySlot = GetPartyLFGID();
	if ( partySlot ) then
		partyCategory = GetLFGCategoryForID(partySlot);
	end

	local empoweredFunc = LFD_IsEmpowered;
	if ( category == LE_LFG_CATEGORY_LFR ) then
		empoweredFunc = function()
			return (not IsInGroup()) or UnitIsGroupLeader("player");
		end;
	end

	if ( proposalExists and not hasResponded and proposalCategory == category and (not lfgID or lfgID == id) ) then
		return "proposal", "unaccepted";
	elseif ( proposalExists and proposalCategory == category and (not lfgID or lfgID == id) ) then
		return "proposal", "accepted";
	elseif ( queued ) then
		return "queued", (empoweredFunc() and "empowered" or "unempowered");
	elseif ( roleCheckInProgress and roleUpdateCategory == category and (not lfgID or lfgID == roleUpdateID) ) then
		return "rolecheck";
	elseif ( category == LE_LFG_CATEGORY_LFR and joined ) then
		return "listed", (empoweredFunc() and "empowered" or "unempowered");
	elseif ( joined ) then
		return "suspended", (empoweredFunc() and "empowered" or "unempowered");
	elseif ( IsInGroup() and IsPartyLFG() and partyCategory == category and (not lfgID or lfgID == partySlot) ) then
		if IsAllowedToUserTeleport() then
			return "lfgparty", "teleport";
		end
		if IsLFGComplete() then
			return "lfgparty", "complete";
		end
		if IsInLFGDungeon() then
			-- If we're inside, we should still always show the option to leave instance party, which will boot the player out
			return "abandonedInDungeon";
		end
		return "lfgparty", "noteleport";
	elseif ( IsPartyLFG() and IsInLFGDungeon() and partyCategory == category and (not lfgID or lfgID == partySlot) ) then
		return "abandonedInDungeon";
	end
end

function IsLFGModeActive(category)
	local partySlot = GetPartyLFGID();
	local partyCategory = nil;
	if ( partySlot ) then
		partyCategory = GetLFGCategoryForID(partySlot);
	end

	return partyCategory == category;
end
