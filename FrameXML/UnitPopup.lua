
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
UnitPopupButtons["TARGET"] = { text = TEXT(TARGET), dist = 0 };
UnitPopupButtons["DUEL"] = { text = TEXT(DUEL), dist = 3, space = 1 };
UnitPopupButtons["WHISPER"]	= { text = TEXT(WHISPER), dist = 0 };
UnitPopupButtons["INVITE"]	= { text = TEXT(PARTY_INVITE), dist = 0 };
UnitPopupButtons["UNINVITE"] = { text = TEXT(PARTY_UNINVITE), dist = 0 };
UnitPopupButtons["PROMOTE"] = { text = TEXT(PARTY_PROMOTE), dist = 0 };
UnitPopupButtons["GUILD_PROMOTE"] = { text = TEXT(GUILD_PROMOTE), dist = 0 };
UnitPopupButtons["GUILD_LEAVE"] = { text = TEXT(GUILD_LEAVE), dist = 0 };
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
UnitPopupButtons["RESET_INSTANCES"] = { text = TEXT(RESET_INSTANCES), dist = 0 };

UnitPopupButtons["LOOT_THRESHOLD"] = { text = TEXT(LOOT_THRESHOLD), dist = 0, nested = 1 };
UnitPopupButtons["LOOT_PROMOTE"] = { text = TEXT(LOOT_PROMOTE), dist = 0 };
UnitPopupButtons["ITEM_QUALITY2_DESC"] = { text = TEXT(ITEM_QUALITY2_DESC), dist = 0, color = ITEM_QUALITY_COLORS[2] };
UnitPopupButtons["ITEM_QUALITY3_DESC"] = { text = TEXT(ITEM_QUALITY3_DESC), dist = 0, color = ITEM_QUALITY_COLORS[3] };
UnitPopupButtons["ITEM_QUALITY4_DESC"] = { text = TEXT(ITEM_QUALITY4_DESC), dist = 0, color = ITEM_QUALITY_COLORS[4] };

UnitPopupButtons["RAID_LEADER"] = { text = TEXT(NEW_LEADER), dist = 0 };
UnitPopupButtons["RAID_PROMOTE"] = { text = TEXT(PROMOTE), dist = 0 };
UnitPopupButtons["RAID_DEMOTE"] = { text = TEXT(DEMOTE), dist = 0 };
UnitPopupButtons["RAID_REMOVE"] = { text = TEXT(REMOVE), dist = 0 };

UnitPopupButtons["RAID_TARGET_ICON"] = { text = TEXT(RAID_TARGET_ICON), dist = 0, nested = 1 };
UnitPopupButtons["RAID_TARGET_1"] = { text = TEXT(RAID_TARGET_1), dist = 0, checkable = 1, color = {r = 1.0, g = 0.92, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0, tCoordRight = 0.25, tCoordTop = 0, tCoordBottom = 0.25 };
UnitPopupButtons["RAID_TARGET_2"] = { text = TEXT(RAID_TARGET_2), dist = 0, checkable = 1, color = {r = 0.98, g = 0.57, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.25, tCoordRight = 0.5, tCoordTop = 0, tCoordBottom = 0.25 };
UnitPopupButtons["RAID_TARGET_3"] = { text = TEXT(RAID_TARGET_3), dist = 0, checkable = 1, color = {r = 0.83, g = 0.22, b = 0.9}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.5, tCoordRight = 0.75, tCoordTop = 0, tCoordBottom = 0.25 };
UnitPopupButtons["RAID_TARGET_4"] = { text = TEXT(RAID_TARGET_4), dist = 0, checkable = 1, color = {r = 0.04, g = 0.95, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.75, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 0.25 };
UnitPopupButtons["RAID_TARGET_5"] = { text = TEXT(RAID_TARGET_5), dist = 0, checkable = 1, color = {r = 0.7, g = 0.82, b = 0.875}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0, tCoordRight = 0.25, tCoordTop = 0.25, tCoordBottom = 0.5 };
UnitPopupButtons["RAID_TARGET_6"] = { text = TEXT(RAID_TARGET_6), dist = 0, checkable = 1, color = {r = 0, g = 0.71, b = 1}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.25, tCoordRight = 0.5, tCoordTop = 0.25, tCoordBottom = 0.5 };
UnitPopupButtons["RAID_TARGET_7"] = { text = TEXT(RAID_TARGET_7), dist = 0, checkable = 1, color = {r = 1.0, g = 0.24, b = 0.168}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.5, tCoordRight = 0.75, tCoordTop = 0.25, tCoordBottom = 0.5 };
UnitPopupButtons["RAID_TARGET_8"] = { text = TEXT(RAID_TARGET_8), dist = 0, checkable = 1, color = {r = 0.98, g = 0.98, b = 0.98}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.75, tCoordRight = 1, tCoordTop = 0.25, tCoordBottom = 0.5 };
UnitPopupButtons["RAID_TARGET_NONE"] = { text = TEXT(NONE), dist = 0, checkable = 1, };

-- First level menus
UnitPopupMenus = { };
UnitPopupMenus["SELF"] = { "LOOT_METHOD", "LOOT_THRESHOLD", "LOOT_PROMOTE", "LEAVE", "RESET_INSTANCES", "RAID_TARGET_ICON", "CANCEL" };
UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
UnitPopupMenus["PARTY"] = { "WHISPER", "PROMOTE", "LOOT_PROMOTE", "UNINVITE", "INSPECT", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "CANCEL" };
UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "CANCEL" };
UnitPopupMenus["RAID"] = { "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "CANCEL" };
UnitPopupMenus["FRIEND"] = { "WHISPER", "INVITE", "TARGET", "GUILD_PROMOTE", "GUILD_LEAVE", "CANCEL" };
UnitPopupMenus["RAID_TARGET_ICON"] = { "RAID_TARGET_1", "RAID_TARGET_2", "RAID_TARGET_3", "RAID_TARGET_4", "RAID_TARGET_5", "RAID_TARGET_6", "RAID_TARGET_7", "RAID_TARGET_8", "RAID_TARGET_NONE" };

-- Second level menus
UnitPopupMenus["LOOT_METHOD"] = { "FREE_FOR_ALL", "ROUND_ROBIN", "MASTER_LOOTER", "GROUP_LOOT", "NEED_BEFORE_GREED", "CANCEL" };
UnitPopupMenus["LOOT_THRESHOLD"] = { "ITEM_QUALITY2_DESC", "ITEM_QUALITY3_DESC", "ITEM_QUALITY4_DESC", "CANCEL" };

UnitPopupShown = { 1, 1, 1, 1, 1, 1, 1, 1, 1 };

UnitLootMethod = {};
UnitLootMethod["freeforall"] = { text = LOOT_FREE_FOR_ALL, tooltipText = NEWBIE_TOOLTIP_UNIT_FREE_FOR_ALL };
UnitLootMethod["roundrobin"] = { text = LOOT_ROUND_ROBIN, tooltipText = NEWBIE_TOOLTIP_UNIT_ROUND_ROBIN };
UnitLootMethod["master"] = { text = LOOT_MASTER_LOOTER, tooltipText = NEWBIE_TOOLTIP_UNIT_MASTER_LOOTER };
UnitLootMethod["group"] = { text = LOOT_GROUP_LOOT, tooltipText = NEWBIE_TOOLTIP_UNIT_GROUP_LOOT };
UnitLootMethod["needbeforegreed"] = { text = LOOT_NEED_BEFORE_GREED, tooltipText = NEWBIE_TOOLTIP_UNIT_NEED_BEFORE_GREED };


UnitPopupFrames = {
	"PlayerFrameDropDown",
	"TargetFrameDropDown",
	"PartyMemberFrame1DropDown",
	"PartyMemberFrame2DropDown",
	"PartyMemberFrame3DropDown",
	"PartyMemberFrame4DropDown",
	"FriendsDropDown"
};

function UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData)
	-- Init variables
	dropdownMenu.which = which;
	dropdownMenu.unit = unit;
	if ( unit and not name ) then
		name, server = UnitName(unit, true);
	end
	dropdownMenu.name = name;
	dropdownMenu.userData = userData;
	dropdownMenu.server = server;

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
	dropdownMenu.selectedLootMethod = UnitLootMethod[GetLootMethod()].text;
	UnitPopupButtons["LOOT_METHOD"].text = dropdownMenu.selectedLootMethod;
	UnitPopupButtons["LOOT_METHOD"].tooltipText = UnitLootMethod[GetLootMethod()].tooltipText;
	dropdownMenu.selectedLootThreshold = getglobal("ITEM_QUALITY"..GetLootThreshold().."_DESC");
	UnitPopupButtons["LOOT_THRESHOLD"].text = dropdownMenu.selectedLootThreshold;
	-- This allows player to view loot settings if he's not the leader
	if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
		-- If this is true then player is the party leader
		UnitPopupButtons["LOOT_METHOD"].nested = 1;
		UnitPopupButtons["LOOT_THRESHOLD"].nested = 1;
	else
		UnitPopupButtons["LOOT_METHOD"].nested = nil;
		UnitPopupButtons["LOOT_THRESHOLD"].nested = nil;
	end

	-- If level 2 dropdown
	local info;
	local color;
	local icon;
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		dropdownMenu.which = UIDROPDOWNMENU_MENU_VALUE;
		-- Set which menu is being opened
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
		for index, value in UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE] do
			info = {};
			info.text = UnitPopupButtons[value].text;
			info.owner = UIDROPDOWNMENU_MENU_VALUE;
			-- Set the text color
			color = UnitPopupButtons[value].color;
			if ( color ) then
				info.textR = color.r;
				info.textG = color.g;
				info.textB = color.b;
			end
			-- Icons
			info.icon = UnitPopupButtons[value].icon;
			info.tCoordLeft = UnitPopupButtons[value].tCoordLeft;
			info.tCoordRight = UnitPopupButtons[value].tCoordRight;
			info.tCoordTop = UnitPopupButtons[value].tCoordTop;
			info.tCoordBottom = UnitPopupButtons[value].tCoordBottom;
			-- Checked conditions
			if ( info.text == dropdownMenu.selectedLootMethod  ) then
				info.checked = 1;
			elseif ( info.text == dropdownMenu.selectedLootThreshold ) then
				info.checked = 1;
			elseif ( strsub(value, 1, 12) == "RAID_TARGET_" ) then
				local raidTargetIndex = GetRaidTargetIndex(unit);
				if ( raidTargetIndex == index ) then
					info.checked = 1;
				end
			end
			
			info.value = value;
			info.func = UnitPopup_OnClick;
			-- Setup newbie tooltips
			info.tooltipTitle = UnitPopupButtons[value].text;
			info.tooltipText = getglobal("NEWBIE_TOOLTIP_UNIT_"..value);
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		return;			
	end

	-- Add dropdown title
	if ( unit or name ) then
		info = {};
		if ( name ) then
			info.text = name;
		else
			info.text = TEXT(UNKNOWN);
		end
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end
	
	-- Set which menu is being opened
	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
	-- Show the buttons which are used by this menu
	local tooltipText;
	for index, value in UnitPopupMenus[which] do
		if( UnitPopupShown[index] == 1 ) then
			info = {};
			info.text = UnitPopupButtons[value].text;
			info.value = value;
			info.owner = which;
			info.func = UnitPopup_OnClick;
			if ( not UnitPopupButtons[value].checkable ) then
				info.notCheckable = 1;
			end
			-- Text color
			if ( value == "LOOT_THRESHOLD" ) then
				-- Set the text color
				color = ITEM_QUALITY_COLORS[GetLootThreshold()];
				info.textR = color.r;
				info.textG = color.g;
				info.textB = color.b;
			else
				color = UnitPopupButtons[value].color;
				if ( color ) then
					info.textR = color.r;
					info.textG = color.g;
					info.textB = color.b;
				end
			end
			-- Icons
			info.icon = UnitPopupButtons[value].icon;
			info.tCoordLeft = UnitPopupButtons[value].tCoordLeft;
			info.tCoordRight = UnitPopupButtons[value].tCoordRight;
			info.tCoordTop = UnitPopupButtons[value].tCoordTop;
			info.tCoordBottom = UnitPopupButtons[value].tCoordBottom;
			-- Checked conditions
			if ( strsub(value, 1, 12) == "RAID_TARGET_" ) then
				local raidTargetIndex = GetRaidTargetIndex("target");
				if ( raidTargetIndex == index ) then
					info.checked = 1;
				end
			end
			if ( UnitPopupButtons[value].nested ) then
				info.hasArrow = 1;
			end
			
			-- Setup newbie tooltips
			info.tooltipTitle = UnitPopupButtons[value].text;
			tooltipText = getglobal("NEWBIE_TOOLTIP_UNIT_"..value);
			if ( not tooltipText ) then
				tooltipText = UnitPopupButtons[value].tooltipText;
			end
			info.tooltipText = tooltipText;
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
	if ( dropdownMenu.unit and UnitCanCooperate("player", dropdownMenu.unit) ) then
		canCoop = 1;
	end
	for index, value in UnitPopupMenus[dropdownMenu.which] do
		UnitPopupShown[index] = 1;

		if ( value == "TRADE" ) then
			if ( canCoop == 0 ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "INVITE" ) then
			if ( dropdownMenu.unit ) then
				if ( canCoop == 0 ) then
					UnitPopupShown[index] = 0;
				end
			else
				if ( dropdownMenu.name == UnitName("party1") or
					 dropdownMenu.name == UnitName("party2") or
					 dropdownMenu.name == UnitName("party3") or
					 dropdownMenu.name == UnitName("party4") or
					 dropdownMenu.name == UnitName("player")) then
					UnitPopupShown[index] = 0;
				end
			end
		elseif ( value == "FOLLOW" ) then
			if ( canCoop == 0 ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "WHISPER" ) then
			if ( dropdownMenu.unit and canCoop == 0 ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "DUEL" ) then
			if ( canCoop == 0 ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "INSPECT" ) then
			if ( canCoop == 0 ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "PROMOTE" ) then
			if ( (inParty == 0) or (isLeader == 0) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "GUILD_PROMOTE" ) then
			if ( not IsGuildLeader() or dropdownMenu.name == UnitName("player") or not GuildFrame:IsVisible() ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "GUILD_LEAVE" ) then
			if ( dropdownMenu.name ~= UnitName("player") or not GuildFrame:IsVisible() ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "UNINVITE" ) then
			if ( (inParty == 0) or (isLeader == 0) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "WHISPER" ) then
			if ( dropdownMenu.name == UnitName("player") ) then
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
			if ( inParty == 0 ) then
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
			if ( inParty == 0 ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RESET_INSTANCES" ) then
			if ( not CanShowResetInstances() or ((inParty == 1) and (isLeader == 0)) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_LEADER" ) then
			local name, rank = GetRaidRosterInfo(dropdownMenu.userData);
			if ( (isLeader == 0) or (rank == 2) or not dropdownMenu.name ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_PROMOTE" ) then
			local name, rank = GetRaidRosterInfo(dropdownMenu.userData);
			if ( (isLeader == 0) or (rank ~= 0) or not dropdownMenu.name ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "RAID_DEMOTE" ) then
			local name, rank = GetRaidRosterInfo(dropdownMenu.userData);
			if ( (isLeader == 0) or (rank ~= 1) or not dropdownMenu.name ) then
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
		elseif ( strsub(value, 1, 12)  == "RAID_TARGET_" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (isAssistant == 0)) ) then
				UnitPopupShown[index] = 0;
			end
			if ( not (dropdownMenu.which == "SELF") ) then
				if ( UnitExists("target") and not UnitPlayerOrPetInParty("target") and not UnitPlayerOrPetInRaid("target") ) then
					if ( UnitIsPlayer("target") and (not UnitCanCooperate("player", "target") and not UnitIsUnit("target", "player")) ) then
						UnitPopupShown[index] = 0;
					end
				end
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
	local isAssistant = 0;
	if ( IsRaidOfficer() ) then
		isAssistant = 1;
	end
	-- Loop through all menus and enable/disable their buttons appropriately
	local count;
	for level, dropdownFrame in OPEN_DROPDOWNMENUS do
		if ( dropdownFrame ) then
			count = 0;
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
						if ( inParty == 1 and (isLeader == 0 and isAssistant == 0)) then
							enable = 0;
						end
					elseif ( value == "UNINVITE" or value == "PROMOTE" ) then
						if ( inParty == 0 or isLeader == 0 ) then
							enable = 0;
						end
					elseif ( value == "WHISPER" ) then
						if ( dropdownFrame.unit and not UnitIsConnected(dropdownFrame.unit) ) then
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
							if ( dropdownFrame.unit and UnitIsUnit(dropdownFrame.unit, masterName) ) then
								enable = 0;
							end
						end
					end

					if ( enable == 1 ) then
						UIDropDownMenu_EnableButton(level, count+1);
					else
						UIDropDownMenu_DisableButton(level, count+1);
					end
				end
			end
		end
	end
end

function UnitPopup_OnClick()
	local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local button = this.value;
	local unit = dropdownFrame.unit;
	local name = dropdownFrame.name;
	local server = dropdownFrame.server;

	if ( button == "TRADE" ) then
		InitiateTrade(unit);
	elseif ( button == "WHISPER" ) then
		if(server) then
			ChatFrame_SendTell(name.."-"..server);
		else
			ChatFrame_SendTell(name)
		end
	elseif ( button == "INSPECT" ) then
		InspectUnit(unit);
	elseif ( button == "TARGET" ) then
		if ( server ) then
			TargetByName(name.."-"..server, 1);
		else
			TargetByName(name, 1);
		end
	elseif ( button == "DUEL" ) then
		StartDuelUnit(unit);
	elseif ( button == "INVITE" ) then
		if ( unit ) then
			InviteToParty(unit);
		else
			InviteByName(name);
		end
	elseif ( button == "UNINVITE" ) then
		UninviteFromParty(unit);
	elseif ( button == "PROMOTE" ) then
		PromoteToPartyLeader(unit);
	elseif ( button == "GUILD_PROMOTE" ) then
		local dialog = StaticPopup_Show("CONFIRM_GUILD_PROMOTE", name);
		dialog.data = name;
	elseif ( button == "GUILD_LEAVE" ) then
		StaticPopup_Show("CONFIRM_GUILD_LEAVE", GetGuildInfo("player"));
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
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "ROUND_ROBIN" ) then
		SetLootMethod("roundrobin");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "MASTER_LOOTER" ) then
		SetLootMethod("master", name);
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "GROUP_LOOT" ) then
		SetLootMethod("group");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "NEED_BEFORE_GREED" ) then
		SetLootMethod("needbeforegreed");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "LOOT_PROMOTE" ) then
		SetLootMethod("master", name);
	elseif ( button == "RESET_INSTANCES" ) then
		StaticPopup_Show("CONFIRM_RESET_INSTANCES");
	elseif ( button == "FOLLOW" ) then
		FollowByName(name, 1);
	elseif ( button == "RAID_LEADER" ) then
		PromoteByName(name);
	elseif ( button == "RAID_PROMOTE" ) then
		PromoteToAssistant(name);
	elseif ( button == "RAID_DEMOTE" ) then
		DemoteAssistant(name);
	elseif ( button == "RAID_REMOVE" ) then
		UninviteFromRaid(dropdownFrame.userData);
	elseif ( button == "ITEM_QUALITY2_DESC" or button == "ITEM_QUALITY3_DESC" or button == "ITEM_QUALITY4_DESC" ) then
		SetLootThreshold(this:GetID()+1);
		color = ITEM_QUALITY_COLORS[this:GetID()+1];
		UIDropDownMenu_SetButtonText(1, 3, UnitPopupButtons[button].text, color.r, color.g, color.b);
	elseif ( strsub(button, 1, 12) == "RAID_TARGET_" and button ~= "RAID_TARGET_ICON" ) then
		local raidTargetIndex = strsub(button, 13);
		if ( raidTargetIndex == "NONE" ) then
			raidTargetIndex = 0;
		end
		SetRaidTargetIcon(unit, tonumber(raidTargetIndex));
	end
	PlaySound("UChatScrollButton");
end
