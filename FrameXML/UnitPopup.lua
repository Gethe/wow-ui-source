
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

UnitPopupButtons["LOOT_METHOD"] = { text = TEXT(LOOT_METHOD), dist = 0, nested = 1 };
UnitPopupButtons["FREE_FOR_ALL"] = { text = TEXT(LOOT_FREE_FOR_ALL), dist = 0 };
UnitPopupButtons["ROUND_ROBIN"] = { text = TEXT(LOOT_ROUND_ROBIN), dist = 0 };
UnitPopupButtons["MASTER_LOOTER"] = { text = TEXT(LOOT_MASTER_LOOTER), dist = 0 };
UnitPopupButtons["GROUP_LOOT"] = { text = TEXT(LOOT_GROUP_LOOT), dist = 0 };
UnitPopupButtons["NEED_BEFORE_GREED"] = { text = TEXT(LOOT_NEED_BEFORE_GREED), dist = 0 };

UnitPopupButtons["LOOT_THRESHOLD"] = { text = TEXT(LOOT_THRESHOLD), dist = 0, nested = 1 };
UnitPopupButtons["LOOT_PROMOTE"] = { text = TEXT(LOOT_PROMOTE), dist = 0 };
UnitPopupButtons["ITEM_QUALITY2_DESC"] = { text = TEXT(ITEM_QUALITY2_DESC), dist = 0 };
UnitPopupButtons["ITEM_QUALITY3_DESC"] = { text = TEXT(ITEM_QUALITY3_DESC), dist = 0 };
UnitPopupButtons["ITEM_QUALITY4_DESC"] = { text = TEXT(ITEM_QUALITY4_DESC), dist = 0 };

UnitPopupButtons["RAID_LEADER"] = { text = TEXT(NEW_LEADER), dist = 0 };
UnitPopupButtons["RAID_PROMOTE"] = { text = TEXT(PROMOTE), dist = 0 };
UnitPopupButtons["RAID_DEMOTE"] = { text = TEXT(DEMOTE), dist = 0 };
UnitPopupButtons["RAID_REMOVE"] = { text = TEXT(REMOVE), dist = 0 };

-- First level menus
UnitPopupMenus = { };
UnitPopupMenus["SELF"] = { "LOOT_METHOD", "LOOT_THRESHOLD", "LOOT_PROMOTE", "LEAVE", "CANCEL" };
UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
UnitPopupMenus["PARTY"] = { "PROMOTE", "LOOT_PROMOTE", "UNINVITE", "INSPECT", "TRADE", "FOLLOW", "DUEL", "CANCEL" };
UnitPopupMenus["PLAYER"] = { "INSPECT", "INVITE", "TRADE", "FOLLOW", "DUEL", "CANCEL" };
UnitPopupMenus["RAID"] = { "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "CANCEL" };

-- Second level menus
UnitPopupMenus[1] = { "FREE_FOR_ALL", "ROUND_ROBIN", "MASTER_LOOTER", "GROUP_LOOT", "NEED_BEFORE_GREED", "CANCEL" };
UnitPopupMenus[2] = { "ITEM_QUALITY2_DESC", "ITEM_QUALITY3_DESC", "ITEM_QUALITY4_DESC", "CANCEL" };

UnitPopupShown = { 1, 1, 1, 1, 1, 1, 1, 1 };

UnitLootMethod = {};
UnitLootMethod["freeforall"] = LOOT_FREE_FOR_ALL;
UnitLootMethod["roundrobin"] = LOOT_ROUND_ROBIN;
UnitLootMethod["master"] = LOOT_MASTER_LOOTER;
UnitLootMethod["group"] = LOOT_GROUP_LOOT;
UnitLootMethod["needbeforegreed"] = LOOT_NEED_BEFORE_GREED;


UnitPopupFrames = {
	"PlayerFrameDropDown",
	"TargetFrameDropDown",
	"PartyMemberFrame1DropDown",
	"PartyMemberFrame2DropDown",
	"PartyMemberFrame3DropDown",
	"PartyMemberFrame4DropDown"
};

function UnitPopup_ShowMenu(dropdownMenu, which, unit, userData, raidName)
	-- Init variables
	dropdownMenu.which = which;
	dropdownMenu.unit = unit;
	dropdownMenu.userData = userData;

	-- Determine which buttons should be shown or hidden
	UnitPopup_HideButtons();
	
	-- If only one menu item (the cancel button) then don't show the menu
	local count = 0;
	for index, value in UnitPopupMenus[which] do
		if( UnitPopupShown[index] == 1 and value ~= "CANCEL" ) then
			count = count + 1;
		end
	end
	if ( count < 1 ) then
		return;
	end
	
	-- Determine which loot method and which loot threshold are selected and set the corresponding buttons to the same text
	dropdownMenu.selectedLootMethod = UnitLootMethod[GetLootMethod()];
	UnitPopupButtons["LOOT_METHOD"].text = dropdownMenu.selectedLootMethod;
	dropdownMenu.selectedLootThreshold = getglobal("ITEM_QUALITY"..GetLootThreshold().."_DESC");
	UnitPopupButtons["LOOT_THRESHOLD"].text = dropdownMenu.selectedLootThreshold;

	-- If level2 dropdown
	local info;
	local color;
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		dropdownMenu.which = UIDROPDOWNMENU_MENU_VALUE;
		for index, value in UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE] do
			info = {};
			info.text = UnitPopupButtons[value].text;
			info.owner = UIDROPDOWNMENU_MENU_VALUE;
			-- Set the text color
			if ( value ~= "CANCEL" and UIDROPDOWNMENU_MENU_VALUE == 2 ) then
				color = ITEM_QUALITY_COLORS[index+1];
				info.textR = color.r;
				info.textG = color.g;
				info.textB = color.b;
			end
			if ( info.text == dropdownMenu.selectedLootMethod  ) then
				info.checked = 1;
			elseif ( info.text == dropdownMenu.selectedLootThreshold ) then
				info.checked = 1;
			end
			
			info.value = index;
			info.func = UnitPopup_OnClick;
			-- Setup newbie tooltips
			info.tooltipTitle = UnitPopupButtons[value].text;
			info.tooltipText = getglobal("NEWBIE_TOOLTIP_UNIT_"..value);
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		return;			
	end

	-- Add dropdown title
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
		info = {};
		info.text = name;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end
	
	-- Show the buttons which are used by this menu
	for index, value in UnitPopupMenus[which] do
		if( UnitPopupShown[index] == 1 ) then
			info = {};
			info.text = UnitPopupButtons[value].text;
			info.value = index;
			info.owner = which;
			info.func = UnitPopup_OnClick;
			info.notCheckable = 1;
			if ( UnitPopupButtons[value].nested ) then
				info.hasArrow = 1;
			end
			if ( value == "LOOT_THRESHOLD" ) then
				-- Set the text color
				color = ITEM_QUALITY_COLORS[GetLootThreshold()];
				info.textR = color.r;
				info.textG = color.g;
				info.textB = color.b;
			end
			-- Setup newbie tooltips
			info.tooltipTitle = UnitPopupButtons[value].text;
			info.tooltipText = getglobal("NEWBIE_TOOLTIP_UNIT_"..value);
			UIDropDownMenu_AddButton(info);
		end
	end
	PlaySound("igMainMenuOpen");
end

function UnitPopup_HideButtons()
	local dropdownMenu = getglobal(UIDROPDOWNMENU_INIT_MENU);
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
	if ( UnitCanCooperate("player", dropdownMenu.unit) ) then
		canCoop = 1;
	end
	for index, value in UnitPopupMenus[dropdownMenu.which] do
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
			if ( (inParty == 0) or (isLeader == 0) or (lootMethod ~= "master") or (lootMaster and (dropdownMenu.unit == "party"..lootMaster)) or ((dropdownMenu.unit == "player") and lootMaster and (lootMaster == 0)) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "LOOT_METHOD" ) then
			if ( (inParty == 0) or (isLeader == 0) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_LEADER" ) then
			local name, rank = GetRaidRosterInfo(dropdownMenu.userData);
			if ( (isLeader == 0) or (rank == 2) or not RaidFrame.selectedName ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_PROMOTE" ) then
			local name, rank = GetRaidRosterInfo(dropdownMenu.userData);
			if ( (isLeader == 0) or (rank ~= 0) or not RaidFrame.selectedName ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_DEMOTE" ) then
			local name, rank = GetRaidRosterInfo(dropdownMenu.userData);
			if ( (isLeader == 0) or (rank ~= 1) or not RaidFrame.selectedName ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_REMOVE" ) then
			local name, rank = GetRaidRosterInfo(dropdownMenu.userData);
			if ( ((isLeader == 0) and (isAssistant == 0)) or (rank == 2) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "PET_PAPERDOLL" ) then
			if( not PetCanBeAbandoned() ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "PET_RENAME" ) then
			if( not PetCanBeAbandoned() or not PetCanBeRenamed() ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "PET_ABANDON" ) then
			if( not PetCanBeAbandoned() ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "PET_DISMISS" ) then
			if( PetCanBeAbandoned() ) then
				UnitPopupShown[index] = 0;
			end
		end

	end
end

function UnitPopup_OnUpdate(elapsed)
	if ( not DropDownList1:IsVisible() ) then
		return;
	else
		-- If none of the untipopup frames are visible then return
		for index, value in UnitPopupFrames do
			if ( UIDROPDOWNMENU_OPEN_MENU == value ) then
				break;
			elseif ( index == getn(UnitPopupFrames) ) then
				return;
			end
		end
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
	local dropdownFrame = getglobal(UIDROPDOWNMENU_OPEN_MENU);
	for index, value in UnitPopupMenus[dropdownFrame.which] do
		if ( UnitPopupShown[index] == 1 ) then
			count = count + 1;
			local enable = 1;

			if ( UnitPopupButtons[value].dist > 0 ) then
				if ( not CheckInteractDistance(dropdownFrame.unit, UnitPopupButtons[value].dist) ) then
					enable = 0;
				end
			end

			if ( value == "TRADE" ) then
				if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(dropdownFrame.unit) ) then
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
				if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(dropdownFrame.unit) ) then
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
					if ( UnitIsUnit(dropdownFrame.unit, masterName) ) then
						enable = 0;
					end
				end
			end

			if ( enable == 1 ) then
				UIDropDownMenu_EnableButton(1, count+1);
			else
				UIDropDownMenu_DisableButton(1, count+1);
			end
		end
	end
end

function UnitPopup_OnClick()
	local index = this.value;
	local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local button = UnitPopupMenus[this.owner][index];
	local unit = dropdownFrame.unit;

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
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
	elseif ( button == "ROUND_ROBIN" ) then
		SetLootMethod("roundrobin");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
	elseif ( button == "MASTER_LOOTER" ) then
		SetLootMethod("master", UnitName("player"));
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
	elseif ( button == "GROUP_LOOT" ) then
		SetLootMethod("group");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
	elseif ( button == "NEED_BEFORE_GREED" ) then
		SetLootMethod("needbeforegreed");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
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
		UninviteFromRaid(dropdownFrame.userData);
	elseif ( button == "ITEM_QUALITY2_DESC" or button == "ITEM_QUALITY3_DESC" or button == "ITEM_QUALITY4_DESC" ) then
		SetLootThreshold(this:GetID()+1);
		color = ITEM_QUALITY_COLORS[this:GetID()+1];
		UIDropDownMenu_SetButtonText(1, 3, UnitPopupButtons[button].text, color.r, color.g, color.b);
	end
	PlaySound("UChatScrollButton");
end
