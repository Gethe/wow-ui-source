
UNITPOPUP_TITLE_HEIGHT = 26;
UNITPOPUP_BUTTON_HEIGHT = 15;
UNITPOPUP_BORDER_HEIGHT = 8;
UNITPOPUP_BORDER_WIDTH = 19;

UNITPOPUP_NUMBUTTONS = 9;
UNITPOPUP_TIMEOUT = 5;

UNITPOPUP_SPACER_SPACING = 6;

UnitPopupButtons = { };
UnitPopupButtons["CANCEL"] = { text = TEXT(CANCEL), dist = 0, space = 1 };
UnitPopupButtons["TRADE"] = { text = TEXT(TRADE), dist = 2 };
UnitPopupButtons["INSPECT"] = { text = TEXT(INSPECT), dist = 1 };
UnitPopupButtons["DUEL"] = { text = TEXT(DUEL), dist = 3, space = 1 };
UnitPopupButtons["INVITE"]	= { text = TEXT(PARTY_INVITE), dist = 0 };
UnitPopupButtons["UNINVITE"] = { text = TEXT(PARTY_UNINVITE), dist = 0 };
UnitPopupButtons["PROMOTE"] = { text = TEXT(PARTY_PROMOTE), dist = 0 };
UnitPopupButtons["LEAVE"] = { text = TEXT(PARTY_LEAVE), dist = 0 };
UnitPopupButtons["FOLLOW"] = { text = TEXT(FOLLOW), dist = 4 };
UnitPopupButtons["PET_PASSIVE"] = { text = TEXT(PET_PASSIVE), dist = 0 };
UnitPopupButtons["PET_DEFENSIVE"] = { text = TEXT(PET_DEFENSIVE), dist = 0 };
UnitPopupButtons["PET_AGGRESSIVE"] = { text = TEXT(PET_AGGRESSIVE), dist = 0 };
UnitPopupButtons["PET_WAIT"] = { text = TEXT(PET_WAIT), dist = 0 };
UnitPopupButtons["PET_FOLLOW"] = { text = TEXT(PET_FOLLOW), dist = 0 };
UnitPopupButtons["PET_ATTACK"] = { text = TEXT(PET_ATTACK), dist = 0 };
UnitPopupButtons["PET_DISMISS"] = { text = TEXT(PET_DISMISS), dist = 0 };
UnitPopupButtons["PET_ABANDON"] = { text = TEXT(PET_ABANDON), dist = 0 };
UnitPopupButtons["PET_PAPERDOLL"] = { text = TEXT(PET_PAPERDOLL), dist = 0 };
UnitPopupButtons["PET_RENAME"] = { text = TEXT(PET_RENAME), dist = 0 };
UnitPopupButtons["FREE_FOR_ALL"] = { text = TEXT(LOOT_FREE_FOR_ALL), dist = 0 };
UnitPopupButtons["ROUND_ROBIN"] = { text = TEXT(LOOT_ROUND_ROBIN), dist = 0 };
UnitPopupButtons["MASTER_LOOTER"] = { text = TEXT(LOOT_MASTER_LOOTER), dist = 0 };
UnitPopupButtons["GROUP_LOOT"] = { text = TEXT(LOOT_GROUP_LOOT), dist = 0 };
UnitPopupButtons["NEED_BEFORE_GREED"] = { text = TEXT(LOOT_NEED_BEFORE_GREED), dist = 0 };
UnitPopupButtons["LOOT_THRESHOLD"] = { text = TEXT(LOOT_THRESHOLD), dist = 0 };
UnitPopupButtons["LOOT_PROMOTE"] = { text = TEXT(LOOT_PROMOTE), dist = 0 };

UnitPopupButtons["RAID_LEADER"] = { text = TEXT(NEW_LEADER), dist = 0 };
UnitPopupButtons["RAID_PROMOTE"] = { text = TEXT(PROMOTE), dist = 0 };
UnitPopupButtons["RAID_DEMOTE"] = { text = TEXT(DEMOTE), dist = 0 };
UnitPopupButtons["RAID_REMOVE"] = { text = TEXT(REMOVE), dist = 0 };

UnitPopupMenus = { };
UnitPopupMenus["SELF"] = { "FREE_FOR_ALL", "ROUND_ROBIN", "MASTER_LOOTER", "GROUP_LOOT", "NEED_BEFORE_GREED", "LOOT_THRESHOLD", "LOOT_PROMOTE", "LEAVE", "CANCEL" };
UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_ABANDON", "CANCEL" };
UnitPopupMenus["PET_RENAME"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "CANCEL" };
UnitPopupMenus["PET_NOABANDON"] = { "PET_DISMISS", "CANCEL" };
UnitPopupMenus["PARTY"] = { "PROMOTE", "LOOT_PROMOTE", "UNINVITE", "INSPECT", "TRADE", "FOLLOW", "DUEL", "CANCEL" };
UnitPopupMenus["PLAYER"] = { "INSPECT", "INVITE", "TRADE", "FOLLOW", "DUEL", "CANCEL" };
UnitPopupMenus["RAID"] = { "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "CANCEL" };

UnitPopupShown = { 1, 1, 1, 1, 1, 1, 1, 1 };

function UnitPopup_ShowMenu(parent, which, unit, userData, raidName)
	local last_button = 1;
	UnitPopup.parent = parent
	UnitPopup.which = which;
	UnitPopup.unit = unit;
	UnitPopup.userData = userData;
	UnitPopup.timeleft = UNITPOPUP_TIMEOUT;
	if ( unit ) then
		local name;
		-- Ugly hack for the raid menu
		if ( raidName ) then
			name = raidName
		else
			name = UnitName(unit);
			if ( not name or (strlen(name) == 0) ) then
				name = TEXT(UNKNOWN);
			end
		end
		UnitPopupTitle:SetText(name);
	end

	UnitPopup_HideButtons();

	local maxWidth = UnitPopupTitle:GetWidth();

	-- Show the buttons which are used by this menu
	local count = 0;
	local spaces = 0;
	for index, value in UnitPopupMenus[which] do
		if( UnitPopupShown[index] == 1 ) then
			count = count + 1;
			local button = getglobal("UnitPopupButton"..count);
			button:SetText(UnitPopupButtons[value].text);
			if (count > 1) then
				if ( UnitPopupButtons[value].space ) then
					spaces = spaces + 1;
					button:SetPoint("TOP", "UnitPopupButton"..count-1, "BOTTOM", 0, -UNITPOPUP_SPACER_SPACING);
				else
					button:SetPoint("TOP", "UnitPopupButton"..count-1, "BOTTOM", 0, 0);
				end
			end
			button:SetID(index);
			button:Show();
			last_button = count+1;
			local width = button:GetTextWidth();
			if ( width > maxWidth) then
				maxWidth = width;
			end

			-- Setup newbie tooltips
			button.tooltipTitle = UnitPopupButtons[value].text;
			button.tooltipText = getglobal("NEWBIE_TOOLTIP_UNIT_"..value);
		end
	end

	if ( count <= 1 ) then
		UnitPopup:Hide();
		return;
	end
	
	PlaySound("igMainMenuOpen");

	-- Hide all the rest of the buttons
	for index = last_button, UNITPOPUP_NUMBUTTONS, 1 do
		local button = getglobal("UnitPopupButton"..index);
		button:Hide();
	end
	
	for index, value in UnitPopupMenus[which] do
		local button = getglobal("UnitPopupButton"..index);
		button:SetWidth(maxWidth);
	end

	local height = UNITPOPUP_TITLE_HEIGHT + ((last_button - 1) * UNITPOPUP_BUTTON_HEIGHT) + (3 * UNITPOPUP_BORDER_HEIGHT);
	height = height + (spaces * UNITPOPUP_SPACER_SPACING);
	local width = maxWidth + (2 * UNITPOPUP_BORDER_WIDTH);
	UnitPopup:SetHeight(height);
	UnitPopup:SetWidth(width);
	UnitPopup:Show();
end

function UnitPopup_HideButtons()
	local inParty = 0;
	if ( (GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0) ) then
		inParty = 1;
	end

	local isLeader = 0;
	if ( inParty and IsPartyLeader() ) then
		isLeader = 1;
	end

	local isAssistant = 0;
	if ( IsRaidOfficer() ) then
		isAssistant = 1;
	end

	local canCoop = 0;
	if ( UnitCanCooperate("player", UnitPopup.unit) ) then
		canCoop = 1;
	end

	for index, value in UnitPopupMenus[UnitPopup.which] do
		UnitPopupShown[index] = 1;

		if ( value == "TRADE" ) then
			if ( canCoop == 0 ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "INVITE" ) then
			if ( canCoop == 0 ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "PROMOTE" ) then
			if ( (inParty == 0) or (isLeader == 0) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "UNINVITE" ) then
			if ( (inParty == 0) or (isLeader == 0) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "LEAVE" ) then
			if ( (inParty == 0) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "FREE_FOR_ALL" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "freeforall")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "ROUND_ROBIN" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "roundrobin")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "MASTER_LOOTER" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "master")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "GROUP_LOOT" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "group")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "NEED_BEFORE_GREED" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "needbeforegreed")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "LOOT_THRESHOLD" ) then
			if ( (inParty == 0) or (isLeader == 0) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "LOOT_PROMOTE" ) then
			local lootMethod;
			local lootMaster;
			lootMethod, lootMaster = GetLootMethod();
			if ( (inParty == 0) or (isLeader == 0) or (lootMethod ~= "master") or (lootMaster and (UnitPopup.unit == "party"..lootMaster)) or ((UnitPopup.unit == "player") and lootMaster and (lootMaster == 0)) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "PET_RENAME" ) then
			if ( not PetCanBeRenamed() ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_LEADER" ) then
			local name, rank = GetRaidRosterInfo(UnitPopup.userData);
			if ( (isLeader == 0) or (rank == 2) or not RaidFrame.selectedName ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_PROMOTE" ) then
			local name, rank = GetRaidRosterInfo(UnitPopup.userData);
			if ( (isLeader == 0) or (rank ~= 0) or not RaidFrame.selectedName ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_DEMOTE" ) then
			local name, rank = GetRaidRosterInfo(UnitPopup.userData);
			if ( (isLeader == 0) or (rank ~= 1) or not RaidFrame.selectedName ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_REMOVE" ) then
			local name, rank = GetRaidRosterInfo(UnitPopup.userData);
			if ( ((isLeader == 0) and (isAssistant == 0)) or (rank == 2) ) then
				UnitPopupShown[index] = 0;
			end
		end

	end
end

function UnitPopup_OnUpdate(elapsed)
	local timeleft = UnitPopup.timeleft - elapsed;
	if ( timeleft <= 0 ) then
		UnitPopup:Hide();
		return;
	end
	UnitPopup.timeleft = timeleft;

	if ( not UnitPopup.parent:IsVisible() ) then
		UnitPopup:Hide();
		return;	
	end

	local inParty = 0;
	if ( (GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0) ) then
		inParty = 1;
	end

	local isLeader = 0;
	if ( inParty and IsPartyLeader() ) then
		isLeader = 1;
	end
	local count = 0;
	for index, value in UnitPopupMenus[UnitPopup.which] do
		if ( UnitPopupShown[index] == 1 ) then
			count = count + 1;
			local button = getglobal("UnitPopupButton"..count);
			local enable = 1;

			if ( UnitPopupButtons[value].dist > 0 ) then
				if ( not CheckInteractDistance(this.unit, UnitPopupButtons[value].dist) ) then
					enable = 0;
				end
			end

			if ( value == "TRADE" ) then
				if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(this.unit) ) then
					enable = 0;
				end
			elseif ( value == "LEAVE" ) then
				if ( inParty == 0 ) then
					enable = 0;
				end
			elseif ( value == "INVITE" ) then
				if ( inParty == 1 and isLeader == 0 ) then
					enable = 0;
				end
			elseif ( value == "UNINVITE" or value == "PROMOTE" ) then
				if ( inParty == 0 or isLeader == 0 ) then
					enable = 0;
				end
			elseif ( value == "INSPECT" ) then
				if ( UnitIsDeadOrGhost("player") ) then
					enable = 0;
				end
			elseif ( value == "FOLLOW" ) then
				if ( UnitIsDead("player") ) then
					enable = 0;
				end
			elseif ( value == "DUEL" ) then
				if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(this.unit) ) then
					enable = 0;
				end
			elseif ( value == "FREE_FOR_ALL" ) then
				if ( inParty == 0 or isLeader == 0 or GetLootMethod() == "freeforall" ) then
					enable = 0;
				end
			elseif ( value == "ROUND_ROBIN" ) then
				if ( inParty == 0 or isLeader == 0 or GetLootMethod() == "roundrobin" ) then
					enable = 0;
				end
			elseif ( value == "MASTER_LOOTER" ) then
				if ( inParty == 0 or isLeader == 0 or GetLootMethod() == "master" ) then
					enable = 0;
				end
			elseif ( value == "GROUP_LOOT" ) then
				if ( inParty == 0 or isLeader == 0 or GetLootMethod() == "group" ) then
					enable = 0;
				end
			elseif ( value == "NEED_BEFORE_GREED" ) then
				if ( inParty == 0 or isLeader == 0 or GetLootMethod() == "needbeforegreed" ) then
					enable = 0;
				end
			elseif ( value == "LOOT_PROMOTE" ) then
				local lootMethod;
				local lootMaster;
				lootMethod, lootMaster = GetLootMethod();
				if ( (inParty == 0) or (isLeader == 0) or (lootMethod ~= "master") ) then
					enable = 0;
				else
					local masterName = 0;
					if ( not lootMaster or (lootMaster == 0) ) then
						masterName = "player";
					else
						masterName = "party"..lootMaster;
					end
					if ( UnitIsUnit(UnitPopup.unit, masterName) ) then
						enable = 0;
					end
				end
			end

			if ( enable == 1 ) then
				button:Enable();
			else
				button:Disable();
			end
		end
	end
end

function UnitPopup_OnClick(index)
	local button = UnitPopupMenus[UnitPopup.which][index];
	local unit = UnitPopup.unit;

	if ( button == "TRADE" ) then
		InitiateTrade(unit);
	elseif ( button == "INSPECT" ) then
		InspectUnit(unit);
	elseif ( button == "DUEL" ) then
		StartDuelUnit(unit);
	elseif ( button == "INVITE" ) then
		InviteToParty(unit);
	elseif ( button == "UNINVITE" ) then
		UninviteFromParty(unit);
	elseif ( button == "PROMOTE" ) then
		PromoteToPartyLeader(unit);
	elseif ( button == "LEAVE" ) then
		LeaveParty();
	elseif ( button == "PET_PASSIVE" ) then
		PetPassiveMode();
	elseif ( button == "PET_DEFENSIVE" ) then
		PetDefensiveMode();
	elseif ( button == "PET_AGGRESSIVE" ) then
		PetAggressiveMode();
	elseif ( button == "PET_WAIT" ) then
		PetWait();
	elseif ( button == "PET_FOLLOW" ) then
		PetFollow();
	elseif ( button == "PET_ATTACK" ) then
		PetAttack();
	elseif ( button == "PET_DISMISS" ) then
		PetDismiss();
	elseif ( button == "PET_ABANDON" ) then
		StaticPopup_Show("ABANDON_PET");
	elseif ( button == "PET_PAPERDOLL" ) then
		ToggleCharacter("PetPaperDollFrame");
	elseif ( button == "PET_RENAME" ) then
		StaticPopup_Show("RENAME_PET");
	elseif ( button == "FREE_FOR_ALL" ) then
		SetLootMethod("freeforall");
	elseif ( button == "ROUND_ROBIN" ) then
		SetLootMethod("roundrobin");
	elseif ( button == "MASTER_LOOTER" ) then
		SetLootMethod("master", UnitName("player"));
	elseif ( button == "GROUP_LOOT" ) then
		SetLootMethod("group");
	elseif ( button == "NEED_BEFORE_GREED" ) then
		SetLootMethod("needbeforegreed");
	elseif ( button == "LOOT_THRESHOLD" ) then
		PlayerFrameLootThresholdPopup:SetPoint("TOPLEFT", this:GetName(), "BOTTOMRIGHT", 0, 0);
		PlayerFrameLootThresholdPopup:Show();
	elseif ( button == "LOOT_PROMOTE" ) then
		SetLootMethod("master", UnitName(unit));
	elseif ( button == "FOLLOW" ) then
		FollowUnit(unit);
	elseif ( button == "RAID_LEADER" ) then
		PromoteByName(RaidFrame.selectedName);
	elseif ( button == "RAID_PROMOTE" ) then
		PromoteToAssistant(RaidFrame.selectedName);
	elseif ( button == "RAID_DEMOTE" ) then
		DemoteAssistant(RaidFrame.selectedName);
	elseif ( button == "RAID_REMOVE" ) then
		UninviteFromRaid(UnitPopup.userData);
	end
	PlaySound("UChatScrollButton");
	UnitPopup:Hide();
end
