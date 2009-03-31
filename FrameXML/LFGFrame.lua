ROLE_DISABLED = false;
ROLE_ENABLED = true;

LFMCOLUMN1TYPE_INDIVIDUAL = false;
LFMCOLUMN1TYPE_GROUP = true;

NUM_ROLES = 3;
local classRoles = {
--	CLASS = { DPS, TANK, HEALER },
	DRUID = {		ROLE_ENABLED,	ROLE_ENABLED,	ROLE_ENABLED,	},
	PALADIN = {		ROLE_ENABLED,	ROLE_ENABLED,	ROLE_ENABLED,	},
	ROGUE = {		ROLE_ENABLED,	ROLE_DISABLED,	ROLE_DISABLED,	},
	PRIEST = {		ROLE_ENABLED,	ROLE_DISABLED,	ROLE_ENABLED,	},
	WARRIOR = {		ROLE_ENABLED,	ROLE_ENABLED,	ROLE_DISABLED,	},
	HUNTER = {		ROLE_ENABLED,	ROLE_DISABLED,	ROLE_DISABLED,	},
	MAGE = {		ROLE_ENABLED,	ROLE_DISABLED,	ROLE_DISABLED,	},
	WARLOCK = {		ROLE_ENABLED,	ROLE_DISABLED,	ROLE_DISABLED,	},
	SHAMAN = {		ROLE_ENABLED,	ROLE_DISABLED,	ROLE_ENABLED,	},
	DEATHKNIGHT = {	ROLE_ENABLED,	ROLE_ENABLED,	ROLE_DISABLED,	},
}

LFGS_TO_DISPLAY = 15;
LFM_BUTTONHEIGHT = 16
NUM_LFG_CRITERIA = 3;
LFG_SET_COMMENT_THROTTLE = 0.5;
LFM_REFRESH_UPDATE_THROTTLE = 0.5;
LFM_LIST_REFRESH_UPDATE_TIME = 10;
LFG_REFRESH_UPDATE_THROTTLE = 0.5;
LFG_DISABLED_DROPDOWN_NAMES = {};
LFG_DISABLED_DROPDOWN_NAMES[1] = {};
LFG_DISABLED_DROPDOWN_NAMES[2] = {};
LFG_DISABLED_DROPDOWN_NAMES[3] = {};
LFG_TYPE_NONE_ID = 1;

----------------------------- LFG Parent Functions -----------------------------
function LFGParentFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 2);
	LFGParentFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("UPDATE_LFG_LIST");
	self:RegisterEvent("MEETINGSTONE_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function LFGParentFrame_OnEvent(self, event, ...)
	if ( self:IsShown() ) then
		if ( event == "UPDATE_LFG_LIST" or event == "MEETINGSTONE_CHANGED" ) then
			local becauseJoinedGroup = ...;
			if ( not becauseJoinedGroup or IsRealPartyLeader() or GetRealNumPartyMembers() > 0 ) then	--We are being kicked out of LFG due to joining a party. Don't update stuff if we haven't gotten the party update yet.
				LFGParentFrame_UpdateTabs();
			end
		else
			LFGParentFrame_UpdateTabs();
		end
	end
	if ( event == "PARTY_MEMBERS_CHANGED" and (not UnitInBattleground("player")) ) then
		SendLFGQuery();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		LFGFrame_UpdateRoles();
	end
end

function LFGParentFrameTab1_OnClick()
	PanelTemplates_SetTab(LFGParentFrame, 1);
	LFGFrame:Show();
	LFMFrame:Hide();
	PlaySound("igCharacterInfoTab");
end

function LFGParentFrameTab2_OnClick()
	PanelTemplates_SetTab(LFGParentFrame, 2);
	LFGFrame:Hide();
	LFMFrame:Show();
	PlaySound("igCharacterInfoTab");
end

-- Disable the LFG tab if the player is in a party
function LFGParentFrame_UpdateTabs()
	local _, _, _, _, _, _, _, _, _, _, lfgStatus, lfmStatus = GetLookingForGroup();
	if ( IsRealPartyLeader() or IsRealRaidLeader() or (GetRealNumPartyMembers() > 0) or (GetRealNumRaidMembers() > 0) or lfmStatus ) then
		LFGParentFrameTab2_OnClick();
		PanelTemplates_DisableTab(LFGParentFrame, 1);
		LFGParentTooltipTab1:Show();
		PanelTemplates_EnableTab(LFGParentFrame, 2);
		LFGParentTooltipTab2:Hide();
		if ( lfmStatus ) then
			return "lfm";
		else
			return "inparty";
		end
	elseif ( not lfgStatus ) then
		LFGParentFrameTab1_OnClick();
		PanelTemplates_EnableTab(LFGParentFrame, 1);
		LFGParentTooltipTab1:Hide()
		PanelTemplates_DisableTab(LFGParentFrame, 2);
		LFGParentTooltipTab2:Show();
		return "nolfg";
	else
		PanelTemplates_EnableTab(LFGParentFrame, 1);
		LFGParentTooltipTab1:Hide();
		PanelTemplates_EnableTab(LFGParentFrame, 2);
		LFGParentTooltipTab2:Hide();
		return nil;
	end
end

----------------------------- LFM Functions -----------------------------
function LFMFrame_OnShow()
	LFGParentFrameBackground:SetTexture("Interface\\LFGFrame\\LFMFrame");
	LFMFrame_UpdateDropDowns();
	LFMFrame_CacheAndUpdate();
	LFGParentFrameTab1:Show();
	LFGParentFrameTab2:Show();
	LFGParentFrameTitle:SetText(LFM_TITLE);
	LFMFrame.listRefreshTimer = 0;
end

function LFMFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_LFG_TYPES");
	-- Event for entire list
	self:RegisterEvent("UPDATE_LFG_LIST");
	self:RegisterEvent("MEETINGSTONE_CHANGED");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PLAYER_LEVEL_UP");
end

function LFMFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_LFG_TYPES" ) then
		LFMFrame_UpdateDropDowns();
		LFMFrame_Update();
	elseif ( event == "MEETINGSTONE_CHANGED" ) then
		LFMFrame_Update();
	elseif ( event == "UPDATE_LFG_LIST" ) then
		LFMFrame_CacheAndUpdate();
	elseif ( event == "PARTY_LEADER_CHANGED" and (not UnitInBattleground("player"))) then
		if ( IsRealPartyLeader() ) then
			LFGFrame.loaded = nil;
			LFMFrame_CacheAndUpdate();
			SendLFGQuery();
		end
	elseif ( event == "PLAYER_LEVEL_UP"  ) then
		ClearLookingForMore();
		SetLFMType(1);	
		LFMFrame.doUpdate = 1;
	end
end

local LFMReturnValues = {};
local LFMNumReturnResults = 0;
local LFMCacheZoneName = "";

function LFMFrame_CacheAndUpdate()
	local name, level, zone, class, criteria1, criteria2, criteria3, comment, numPartyMembers, isLFM;
	local classFileName, willBeLeader, willBeTank, willBeHealer, willBeDPS;
	local selectedLFMType = UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown);
	local selectedLFMName = UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown);
	local numResults, totalCount = GetNumLFGResults(selectedLFMType, selectedLFMName);
	
	local currIndex = 0;
	for resultIndex=1, numResults do
		if ( LFMFrameFilter_DataMatches(GetLFGResults(selectedLFMType, selectedLFMName, resultIndex)) ) then
			name, level, zone, class, criteria1, criteria2, criteria3, comment, numPartyMembers, isLFM, classFileName, willBeLeader, willBeTank, willBeHealer, willBeDPS = GetLFGResults(selectedLFMType, selectedLFMName, resultIndex);
			currIndex = currIndex + 1;
			if ( not LFMReturnValues[currIndex] ) then
				LFMReturnValues[currIndex] = {};
			end
			
			local tempTab = LFMReturnValues[currIndex];
			tempTab[1] = name;
			tempTab[2] = level;
			tempTab[3] = zone;
			tempTab[4] = class;
			tempTab[5] = criteria1;
			tempTab[6] = criteria2;
			tempTab[7] = criteria3;
			tempTab[8] = comment;
			tempTab[9] = numPartyMembers;
			tempTab[10] = isLFM;
			tempTab[11] = classFileName;
			tempTab[12] = willBeLeader;
			tempTab[13] = willBeTank;
			tempTab[14] = willBeHealer;
			tempTab[15] = willBeDPS;
			
			if ( not tempTab.partyMemberInfo ) then
				tempTab.partyMemberInfo = {};
			end
			
			for i=1, numPartyMembers do
				name, level, class = GetLFGPartyResults(selectedLFMType, selectedLFMName, resultIndex, i);
				if ( not tempTab.partyMemberInfo[i] ) then
					tempTab.partyMemberInfo[i] = {};
				end
				tempTab.partyMemberInfo[i][1] = name;
				tempTab.partyMemberInfo[i][2] = level;
				tempTab.partyMemberInfo[i][3] = class;
			end
		end
	end
	LFMNumReturnResults = currIndex;
	if ( selectedLFMName and selectedLFMType ) then
		LFMCacheZoneName = select(selectedLFMName*2-1, GetLFGTypeEntries(selectedLFMType));
	else
		LFMCacheZoneName = "";
	end
	
	LFMFrame_Update();	--We include this in here to enforce good practice; You should never update the cached data without updating the screen. That can lead to some wacky stuff.
end

function GetLFGCacheSourceInfo()
	return LFMCacheZoneName;	--More to come?
end

function GetLFGResultsProxy(resultIndex)
	if ( resultIndex <= LFMNumReturnResults ) then
		return unpack(LFMReturnValues[resultIndex]);
	end
end

function GetLFGPartyResultsProxy(lfgIndex, playerIndex)
	if ( lfgIndex <= LFMNumReturnResults ) then
		local infoTable = LFMReturnValues[lfgIndex];
		if ( playerIndex <= infoTable[9] and infoTable.partyMemberInfo and infoTable.partyMemberInfo[playerIndex] ) then
			return unpack(infoTable.partyMemberInfo[playerIndex]);
		end
	end
end

function GetNumLFGResultsProxy()
	return LFMNumReturnResults;
end

function LFMFrame_Update()
	LFMFrameColumnHeaderRole_Update();
	local selectedLFMType = UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown);
	local selectedLFMName = UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown);
	local numResults = GetNumLFGResultsProxy();
	local name, level, zone, class, criteria1, criteria2, criteria3, comment, numPartyMembers, isLFM;
	local classFileName, willBeLeader, willBeTank, willBeHealer, willBeDPS;
	local button, buttonText, classTextColor;
	local scrollOffset = FauxScrollFrame_GetOffset(LFMListScrollFrame);
	local resultIndex = scrollOffset;
	local showScrollBar = nil;
	local classText;
	if ( numResults > LFGS_TO_DISPLAY ) then
		showScrollBar = 1;
	end
	if ( LFMFrameColumn1Type == LFMCOLUMN1TYPE_GROUP ) then
		LFMFrameColumnHeader4Group:Show();
		LFMFrameColumnHeader4:Hide();
		LFMFrameColumnHeader5:Hide();
		LFMFrameColumnHeader6:Hide();
		LFMFrameColumnHeader7:Hide();
	else
		LFMFrameColumnHeader4Group:Hide();
		LFMFrameColumnHeader4:Show();
		LFMFrameColumnHeader5:Show();
		LFMFrameColumnHeader6:Show();
		LFMFrameColumnHeader7:Show();
	end
	LFMFrameTotals:SetText(format(WHO_FRAME_TOTAL_TEMPLATE, numResults));
	for i=1, LFGS_TO_DISPLAY, 1 do
		resultIndex = scrollOffset + i;
		button = getglobal("LFMFrameButton"..i);
		button.lfgIndex = resultIndex;
		if ( resultIndex <= numResults ) then
			name, level, zone, class, criteria1, criteria2, criteria3, comment, numPartyMembers, isLFM, classFileName, willBeLeader, willBeTank, willBeHealer, willBeDPS = GetLFGResultsProxy(resultIndex);
			if ( name ) then
				if ( classFileName ) then
					classTextColor = RAID_CLASS_COLORS[classFileName];
				else
					classTextColor = NORMAL_FONT_COLOR;
				end
				buttonText = getglobal("LFMFrameButton"..i.."Name");
				buttonText:SetText(name);
				buttonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				buttonText = getglobal("LFMFrameButton"..i.."Level");
				buttonText:SetText(level);
				classText = getglobal("LFMFrameButton"..i.."Class");
				classText:SetText(class);
				classText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
					
				-- Show the party leader icon if necessary
				if ( numPartyMembers > 0 ) then
					getglobal("LFMFrameButton"..i.."PartyIcon"):Show();
				else	
					getglobal("LFMFrameButton"..i.."PartyIcon"):Hide();
				end
				
				if ( numPartyMembers > 0 ) then
					button.MembersFontString:SetText(numPartyMembers+1);	--+1 because the actual number given does not include the leader.
					button.MembersFontString:Show();
					button.LeaderIcon:Hide();
					button.TankIcon:Hide();
					button.HealerIcon:Hide();
					button.DamageIcon:Hide()
				else
					button.MembersFontString:Hide();
					--Show roles as necessary
					if ( willBeLeader ) then
						button.LeaderIcon:Show();
						if ( LFMFrame_RoleFilter_Individual["leader"] ) then
							button.LeaderIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
						else
							button.LeaderIcon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
						end
					else
						button.LeaderIcon:Hide();
					end
					if ( willBeTank ) then
						button.TankIcon:Show();
						if ( LFMFrame_RoleFilter_Individual["tank"] ) then
							button.TankIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
						else
							button.TankIcon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
						end
					else
						button.TankIcon:Hide();
					end
					if ( willBeHealer ) then
						button.HealerIcon:Show();
						if ( LFMFrame_RoleFilter_Individual["healer"] ) then
							button.HealerIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
						else
							button.HealerIcon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
						end
					else
						button.HealerIcon:Hide();
					end
					if ( willBeDPS ) then
						button.DamageIcon:Show();
						if ( LFMFrame_RoleFilter_Individual["damage"] ) then
							button.DamageIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
						else
							button.DamageIcon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
						end
					else
						button.DamageIcon:Hide();
					end
				end
				
				-- Set info for the tooltip
				button.isLFM = isLFM;
				button.nameLine = format(LFM_NAME_TEMPLATE, name, level, class);
				button.criteria = BuildNewLineListString(criteria1, criteria2, criteria3);
				if ( not button.criteria ) then
					button.criteria = GetLFGCacheSourceInfo();
				end
				button.comment = comment;
				button.partyMembers = numPartyMembers;
				button.willBeLeader = willBeLeader;
				button.willBeTank = willBeTank;
				button.willBeHealer = willBeHealer;
				button.willBeDPS = willBeDPS;
				
				if ( showScrollBar ) then
					classText:SetWidth(70);
				else
					classText:SetWidth(92);
				end

				-- Highlight the correct lfm
				if ( LFMFrame.selectedName == name ) then
					LFMFrame.selectedLFM = resultIndex;
					button:LockHighlight();
				else
					button:UnlockHighlight();
				end
				button:Show();
			end
		else
			button:Hide();
		end
	end

	-- Update send message and group invite buttons
	if ( LFMFrame.selectedName and (LFMFrame.selectedName ~= UnitName("player")) ) then
		LFMFrameSendMessageButton:Enable();
		if ( CanGroupInvite() and LFMFrameColumn1Type ~= LFMCOLUMN1TYPE_GROUP) then
			LFMFrameGroupInviteButton:Enable();
		else
			LFMFrameGroupInviteButton:Disable();
		end
	else
		LFMFrameSendMessageButton:Disable();
		LFMFrameGroupInviteButton:Disable();
	end

	-- If need scrollbar resize columns
	if ( showScrollBar ) then
		WhoFrameColumn_SetWidth(LFMFrameColumnHeader3, 88);
	else
		WhoFrameColumn_SetWidth(LFMFrameColumnHeader3, 110);
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(LFMListScrollFrame, numResults, LFGS_TO_DISPLAY, 16);
end

function LFMFrame_UpdateDropDowns()
	-- Update the search dropdowns
	local _, _, _, _, _, _, lfmType, lfmName, _, queued, lfgStatus, lfmStatus = GetLookingForGroup();
	-- Set LFM settings
	-- Set the LFM Type DropDown
	UIDropDownMenu_Initialize(LFMFrameTypeDropDown, LFMFrameTypeDropDown_Initialize);
	if ( (IsRealPartyLeader() and AutoAddMembersCheckButton:GetChecked() and AutoAddMembersCheckButton:IsEnabled()) or not LFGFrame.loaded ) then
		SetLFMTypeCriteria(lfmType);
	end
	if ( lfmStatus and IsRealPartyLeader()) then
		-- Set the LFM Name DropDown
		UIDropDownMenu_Initialize(LFMFrameNameDropDown, LFMFrameNameDropDown_Initialize);
		if ( lfmType ~= 1 ) then
			UIDropDownMenu_SetSelectedID(LFMFrameNameDropDown, lfmName);
		else
			UIDropDownMenu_ClearAll(LFMFrameNameDropDown);
		end
		if ( queued ) then
			LFMEye:Show();
		else
			LFMEye:Hide();
		end
		
	elseif ( (GetRealNumPartyMembers() == 0) or IsRealPartyLeader() or not LFGFrame.loaded) then
		if ( queued and lfmStatus ) then
			LFMEye:Show();
		else
			LFMEye:Hide();
		end
		UIDropDownMenu_Initialize(LFMFrameNameDropDown, LFMFrameNameDropDown_Initialize);
		if ( lfmName ~= 0 ) then
			if ( not lfgStatus ) then
				UIDropDownMenu_SetSelectedID(LFMFrameNameDropDown, lfmName);
			end
		else
			if ( not lfgStatus ) then
				UIDropDownMenu_ClearAll(LFMFrameNameDropDown);
			end
		end
	else
		LFMEye:Hide();
		if ( UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown) == 1 ) then
			UIDropDownMenu_ClearAll(LFMFrameNameDropDown);
		end
	end
	LFGFrame.loaded = 1;
end

function LFMFrame_OnUpdate(self, elapsed)
	local updated = false;
	--Enable or disable the refresh button based on CanSendLFGQuery
	if ( (LFMFrame.refreshTimer or 0) >= LFM_REFRESH_UPDATE_THROTTLE ) then
		LFMFrame.refreshTimer = 0;

		--If your party is full you can't autoadd
		local _, _, _, _, _, _, _, _, _, queued, lfgStatus, lfmStatus = GetLookingForGroup();
		if ( (queued and lfgStatus) or RealPartyIsFull() or (not IsRealPartyLeader()) or (not IsRealRaidLeader()) or not LFMFrame_CanAutoAdd() ) then
			LFMFrame_DisableAutoAdd();
		else
			LFMFrame_EnableAutoAdd();
		end
	else
		LFMFrame.refreshTimer = (LFMFrame.refreshTimer or 0) + elapsed;
	end
	
	if ( (LFMFrame.listRefreshTimer or 0) >= LFM_LIST_REFRESH_UPDATE_TIME ) then
		LFMFrame.listRefreshTimer = 0;
		
		LFMFrame_CacheAndUpdate();
		updated = true;
	else
		LFMFrame.listRefreshTimer = (LFMFrame.listRefreshTimer or 0) + elapsed;
	end
	
	if ( LFMFrame.doUpdate ) then
		if ( not updated ) then
			LFMFrame_CacheAndUpdate();
		end
		LFMFrame.doUpdate = nil;
	end
end

function LFMFrame_UpdateAutoAdd(autoaddStatus, setCheckbox)
	if ( autoaddStatus and AutoAddMembersCheckButton:IsEnabled() ) then
		SetLFMAutofill();
	else
		ClearLFMAutofill();
	end
	if ( setCheckbox ) then
		AutoAddMembersCheckButton:SetChecked(autoaddStatus);
	end
end

function LFMButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		LFMFrame.selectedLFM = getglobal("LFMFrameButton"..self:GetID()).lfgIndex;
		LFMFrame.selectedName = getglobal("LFMFrameButton"..self:GetID().."Name"):GetText();
		LFMFrame_UpdateDropDowns();
		LFMFrame_CacheAndUpdate();
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

function LFMButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 27, -37);
	if ( self.isLFM ) then
		GameTooltip:SetText(LFM_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		GameTooltip:SetText(LFG_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	
	GameTooltip:AddLine(self.nameLine);
	local numPartyMembers = self.partyMembers;
	if ( numPartyMembers > 0 ) then
		GameTooltip:AddTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
		-- Only show party members if there are 10 or less
		if ( numPartyMembers > 9 ) then
			GameTooltip:AddLine(format(LFM_NUM_RAID_MEMBER_TEMPLATE, numPartyMembers));
			-- Bogus texture to make the spacing correct
			GameTooltip:AddTexture("");
		else
			local lfmType = UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown);
			local lfmName = UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown);
			local name, level, class;
			for i=1, numPartyMembers do
				name, level, class = GetLFGPartyResultsProxy(self.lfgIndex, i);
				if ( name ) then
					if ( level == "" ) then
						level = "??";
					end
					GameTooltip:AddLine(format(LFM_NAME_TEMPLATE, name, level, class));
					-- Bogus texture to make the spacing correct
					GameTooltip:AddTexture("");
				end
			end
		end
	end
	GameTooltip:AddLine("\n"..self.criteria, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	if ( self.comment and self.comment ~= "" ) then
		GameTooltip:AddLine("\n"..self.comment, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	end
	
	if ( numPartyMembers <= 0 ) then
		GameTooltip:AddLine("\n"..format("%s:", ROLES))
		if ( self.willBeDPS ) then
			GameTooltip:AddLine(DAMAGER);
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.25, 0.5, 0, 1);
		end
		if ( self.willBeTank ) then
			GameTooltip:AddLine(TANK);
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.5, 0.75, 0, 1);
		end
		if ( self.willBeHealer ) then
			GameTooltip:AddLine(HEALER);
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.75, 1, 0, 1);
		end
		if ( self.willBeLeader ) then
			GameTooltip:AddLine(LEADER);
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0, 0.25, 0, 1);
		end
	end
	
	GameTooltip:Show();
end

-- Type Dropdown stuff
function LFMFrameTypeDropDown_Initialize()
	Dropdown_GetLFMTypes(GetLFGTypes());
end

function Dropdown_GetLFMTypes(...)
	local info = UIDropDownMenu_CreateInfo();
	for i=1, select("#", ...), 1 do
		info.text = select(i, ...);
		info.func = LFMTypeButton_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function LFMTypeButton_OnClick(self)
	SetLFMTypeCriteria(self:GetID());
	LFGParentFrame_UpdateTabs();
end

function SetLFMTypeCriteria(id)
	if ((id ~= UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown)) and UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown)) then
		UIDropDownMenu_ClearAll(LFMFrameNameDropDown);
	end
	SetLFMType(id);
	UIDropDownMenu_SetSelectedID(LFMFrameTypeDropDown, id);
	if ( id == 1 ) then
		ClearLookingForMore();		
		LFMFrame.doUpdate = 1;
	end
end

-- Entryname Dropdown stuff
function LFMFrameNameDropDown_Initialize()
	if ( UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown) ) then
		Dropdown_GetLFMTypeNames(GetLFGTypeEntries(UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown)));
	else
		UIDropDownMenu_ClearAll(LFMFrameNameDropDown);
	end
end

function Dropdown_GetLFMTypeNames(...)
	local info = UIDropDownMenu_CreateInfo();
	for i=1, select("#", ...), 2 do
		info.text = select(i, ...);
		info.func = LFMNameButton_OnClick;
		info.owner = UIDROPDOWNMENU_OPEN_MENU;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function LFMNameButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(LFMFrameNameDropDown, self:GetID());
	if ( not RealPartyIsFull() ) then
		SetLookingForMore(UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown), UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown));
	end
	SendLFGQuery();
	LFMFrame_UpdateDropDowns();
	LFMFrame_CacheAndUpdate();
end

function LFMFrame_CanAutoAdd()
	local selectedText = "";
	if ( UIDropDownMenu_GetText(LFMFrameNameDropDown) ) then
		selectedText = UIDropDownMenu_GetText(LFMFrameTypeDropDown);
	end
	if ( (strfind(selectedText, LFG_TYPE_DUNGEON) or strfind(selectedText, LFG_TYPE_HEROIC_DUNGEON)) ) then
		return 1;
	else
		return nil;
	end
end

--Wrapper function for the LFGQuery function to determine whether can query for new information or if throttled
--If throttled just get the old information so that the ui seems responsive
function SendLFGQuery()
	if ( CanSendLFGQuery(UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown), UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown)) ) then
		LFGQuery(UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown), UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown));
	else
		LFMFrame_UpdateDropDowns();
		LFMFrame_CacheAndUpdate();	
	end	
end

function LFMFrame_DisableAutoAdd()
	AutoAddMembersCheckButton:Disable();
	AutoAddMembersCheckButtonText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	AutoAddMembersCheckButtonTooltipFrame:Show();
end

function LFMFrame_EnableAutoAdd()
	AutoAddMembersCheckButton:Enable();
	AutoAddMembersCheckButtonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	AutoAddMembersCheckButtonTooltipFrame:Hide();
end

----------------------------- LFG Functions -----------------------------
function LFGFrame_OnLoad(self)
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("MEETINGSTONE_CHANGED");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("VARIABLES_LOADED");
	self.refreshTimer = 0;
end

function LFGFrame_OnEvent(self, event, ...)
	if ( event == "LFG_UPDATE" or event == "MEETINGSTONE_CHANGED" ) then
		LFGFrame_Update();
		LFGFrame_UpdateDropDowns();
	elseif ( event == "PLAYER_LEVEL_UP" ) then
		LFGFrameClearAllButton_OnClick();
	elseif ( event == "VARIABLES_LOADED" ) then
		LFGFrame_UpdateRoleBoxes();
		LFGFrame_UpdateRolesChosen();
	end
end

function LFGFrame_OnShow()
	LFGParentFrameBackground:SetTexture("Interface\\LFGFrame\\UI-Frame-ThreeButton-Blank");
	LFGParentFrameTab1:Show();
	LFGParentFrameTab2:Show();
	LFGParentFrameTitle:SetText(LFG_TITLE);
	LFGFrame_Update();
	LFGFrame_UpdateDropDowns();
end

function LFGFrame_OnUpdate(self, elapsed)
	--Upate the state of autojoin
	--If your party is full you can't autojoin
	if ( LFGFrame.refreshTimer >= LFG_REFRESH_UPDATE_THROTTLE ) then
		local _, _, _, _, _, _, _, _, _, queued, lfgStatus, lfmStatus = GetLookingForGroup();
		local canAutoJoin = (LFGFrameTypeDropDown1.canAutoJoin or LFGFrameTypeDropDown2.canAutoJoin or LFGFrameTypeDropDown3.canAutoJoin);
		if ( ((queued and lfmStatus) or RealPartyIsFull()) or not canAutoJoin ) then
			LFGFrame_DisableAutoJoin();
		else
			LFGFrame_EnableAutoJoin();
		end
		LFGFrame.refreshTimer = 0;
	else
		LFGFrame.refreshTimer = LFGFrame.refreshTimer + elapsed;
	end
end

function LFGFrame_Update()
	local type1, name1, type2, name2, type3, name3, lfmType, lfmName, comment, queued, lfgStatus, lfmStatus = GetLookingForGroup();
	-- Set LFG settings
	if ( type1 ) then
		if ( type1 ~= LFG_TYPE_NONE_ID or (UIDropDownMenu_GetSelectedName(LFGFrameNameDropDown1)) or (not LFGFrameTypeDropDown1Text:GetText()) ) then
			UIDropDownMenu_Initialize(LFGFrameTypeDropDown1, LFGFrameTypeDropDown_Initialize);
			SetLFGTypeCriteria(LFGFrameTypeDropDown1, type1, true);
		end
		UIDropDownMenu_Initialize(LFGFrameNameDropDown1, LFGFrameNameDropDown1_Initialize);
		SetLFGNameCriteria(LFGFrameNameDropDown1, name1, UIDropDownMenu_GetValue(name1), 1);
	end
	if ( type2 ) then
		if ( type2 ~= LFG_TYPE_NONE_ID or (UIDropDownMenu_GetSelectedName(LFGFrameNameDropDown2)) or (not LFGFrameTypeDropDown2Text:GetText()) ) then
			UIDropDownMenu_Initialize(LFGFrameTypeDropDown2, LFGFrameTypeDropDown_Initialize);
			SetLFGTypeCriteria(LFGFrameTypeDropDown2, type2, true);
		end
		UIDropDownMenu_Initialize(LFGFrameNameDropDown2, LFGFrameNameDropDown2_Initialize);
		SetLFGNameCriteria(LFGFrameNameDropDown2, name2, UIDropDownMenu_GetValue(name2), 1);
	end
	if ( type3 ) then
		if ( type3 ~= LFG_TYPE_NONE_ID or (UIDropDownMenu_GetSelectedName(LFGFrameNameDropDown3)) or (not LFGFrameTypeDropDown3Text:GetText()) ) then
			UIDropDownMenu_Initialize(LFGFrameTypeDropDown3, LFGFrameTypeDropDown_Initialize);
			SetLFGTypeCriteria(LFGFrameTypeDropDown3, type3, true);
		end
		UIDropDownMenu_Initialize(LFGFrameNameDropDown3, LFGFrameNameDropDown3_Initialize);
		SetLFGNameCriteria(LFGFrameNameDropDown3, name3, UIDropDownMenu_GetValue(name3), 1);
	end

	-- Show/Hide Eye
	if ( queued and lfgStatus ) then
		LFGEye:Show();
	else
		LFGEye:Hide();
	end
	LFMFrame_UpdateAutoAdd(queued, true);
	LFGFrame_UpdateAutoJoinButton(queued);
end

function LFGFrame_UpdateDropDowns()	
	local _, _, type2, _, type3 = GetLookingForGroup();
	
	-- If a type is selected then enable the name dropdown
	if ( UIDropDownMenu_GetSelectedID(LFGFrameTypeDropDown1) ~= 0 ) then
		UIDropDownMenu_EnableDropDown(LFGFrameNameDropDown1);
	end	

	-- If a name is selected in the first dropdown then enable the second set of dropdowns
	if ( (UIDropDownMenu_GetSelectedID(LFGFrameNameDropDown1) and UIDropDownMenu_GetSelectedID(LFGFrameNameDropDown1) ~= 0) or type2 ~= 0 ) then
		LFGLabel2:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		UIDropDownMenu_EnableDropDown(LFGFrameTypeDropDown2);
	end

	-- If a type is selected then enable the name dropdown
	if ( UIDropDownMenu_GetSelectedID(LFGFrameTypeDropDown2) ~= 0 and UIDropDownMenu_IsEnabled(LFGFrameTypeDropDown2) ) then
		UIDropDownMenu_EnableDropDown(LFGFrameNameDropDown2);
	end	
	
	-- If a name is selected in the second dropdown then enable the second set of dropdowns
	if ( (UIDropDownMenu_GetSelectedID(LFGFrameNameDropDown2) and UIDropDownMenu_GetSelectedID(LFGFrameNameDropDown2) ~= 0) or type3 ~= 0 ) then
		LFGLabel3:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		UIDropDownMenu_EnableDropDown(LFGFrameTypeDropDown3);
	end	

	-- If a type is selected then enable the name dropdown
	if ( UIDropDownMenu_GetSelectedID(LFGFrameTypeDropDown3) ~= 0 and UIDropDownMenu_IsEnabled(LFGFrameTypeDropDown3)) then
		UIDropDownMenu_EnableDropDown(LFGFrameNameDropDown3);
	end
end

function LFGFrame_UpdateAutoJoin()
	if ( AutoJoinCheckButton:GetChecked() and AutoJoinCheckButton:IsEnabled() ) then
		SetLFGAutojoin();
	else
		ClearLFGAutojoin();
	end
end

function LFGFrame_UpdateAutoJoinButton(autojoinStatus)
	AutoJoinCheckButton:SetChecked(autojoinStatus);
end

function LFGFrame_DisableAutoJoin()
	AutoJoinCheckButton:Disable();
	AutoJoinCheckButtonText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	AutoJoinCheckButtonTooltipFrame:Show();
end

function LFGFrame_EnableAutoJoin()
	AutoJoinCheckButton:Enable();
	AutoJoinCheckButtonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	AutoJoinCheckButtonTooltipFrame:Hide();
end

-- Type Dropdown stuff
function LFGFrameTypeDropDown_Initialize()
	Dropdown_GetLFGTypes(GetLFGTypes());
end

function Dropdown_GetLFGTypes(...)
	local info = UIDropDownMenu_CreateInfo();
	local text;
	local autoJoinSet;
	if ( AutoJoinCheckButton:GetChecked() and AutoJoinCheckButton:IsEnabled() ) then
		autoJoinSet = 1;
	end
	for i=1, select("#", ...), 1 do
		text = select(i, ...);
		-- Add autojoin to the end if auto join is set;
		if ( ((text == LFG_TYPE_DUNGEON) or (text == LFG_TYPE_HEROIC_DUNGEON)) and autoJoinSet ) then
			text = text.."  "..GRAY_FONT_COLOR_CODE.."("..AUTO_JOIN..")"..FONT_COLOR_CODE_CLOSE;
		end
		info.text = text;
		info.func = LFGTypeButton_OnClick;
		info.owner = UIDROPDOWNMENU_OPEN_MENU;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function LFGTypeButton_OnClick(self)
	SetLFGTypeCriteria(self.owner, self:GetID(), false);
	LFGFrame_UpdateDropDowns();
end

-- Function to set the type criteria for the lfg frame
function SetLFGTypeCriteria(dropdown, id, doNotSetLookingForGroup)
	-- If the selected type is "none" then clear out the looking for group
	if ( not doNotSetLookingForGroup ) then
		SetLookingForGroup(dropdown:GetID(), id, 0, LFGFrameLeaderCheckButton:GetChecked(), LFGFrameRoleButton2:GetChecked(), LFGFrameRoleButton3:GetChecked(), LFGFrameRoleButton1:GetChecked());
	end
	
	UIDropDownMenu_SetSelectedID(dropdown, id);
	local dropdownID = dropdown:GetID();
	local nameDropDown = getglobal("LFGFrameNameDropDown"..dropdownID);
	LFG_DISABLED_DROPDOWN_NAMES[dropdownID].type = id;
	nameDropDown.selectedType = id
	if ( UIDropDownMenu_GetSelectedID(nameDropDown)) then
		UIDropDownMenu_ClearAll(nameDropDown);
		getglobal("LFGSearchIcon"..dropdownID):SetTexture("");
	end
end

-- Entryname Dropdown stuff
function LFGFrameNameDropDown1_Initialize()
	local selectedType = UIDropDownMenu_GetSelectedID(LFGFrameTypeDropDown1);
	if ( selectedType ) then
		Dropdown_GetLFGTypeNames(LFGFrameTypeDropDown1, GetLFGTypeEntries(selectedType));
	end
end
function LFGFrameNameDropDown2_Initialize()
	local selectedType = UIDropDownMenu_GetSelectedID(LFGFrameTypeDropDown2);
	if ( selectedType ) then
		Dropdown_GetLFGTypeNames(LFGFrameTypeDropDown2, GetLFGTypeEntries(selectedType));
	end
end
function LFGFrameNameDropDown3_Initialize()
	local selectedType = UIDropDownMenu_GetSelectedID(LFGFrameTypeDropDown3);
	if ( selectedType ) then
		Dropdown_GetLFGTypeNames(LFGFrameTypeDropDown3, GetLFGTypeEntries(selectedType));
	end
end

function Dropdown_GetLFGTypeNames(...)
	local info = UIDropDownMenu_CreateInfo();
	local typeDropdown = ...;
	local dropdownID = typeDropdown:GetID();
	local selectedType = UIDropDownMenu_GetSelectedID(typeDropdown);
	local index;
	for i=2, select("#", ...), 2 do
		-- Limit number of displayable names to 20 (40/2)
		if ( i <= 40 ) then
			index = i/2;
			info.text = select(i, ...);
			info.value = select(i+1, ...);
			info.func = LFGNameButton_OnClick;
			info.owner = UIDROPDOWNMENU_OPEN_MENU;
			info.checked = nil;
			info.disabled = nil;
			for j=1, #LFG_DISABLED_DROPDOWN_NAMES do
				if ( j ~= dropdownID ) then
					if ( LFG_DISABLED_DROPDOWN_NAMES[j].type == selectedType and LFG_DISABLED_DROPDOWN_NAMES[j].name == index ) then
						info.disabled = 1;
					end
				end
			end
			UIDropDownMenu_AddButton(info);
		end
	end
end

function LFGNameButton_OnClick(self)
	SetLFGNameCriteria(self.owner, self:GetID(), self.value);
	LFGFrame_UpdateDropDowns();
end

-- Function to set the name criteria for the lfg frame
function SetLFGNameCriteria(dropdown, id, icon, doNotSetLookingForGroup)
	local dropdownID = dropdown:GetID();
	if ( not doNotSetLookingForGroup ) then
		SetLookingForGroup(dropdownID, dropdown.selectedType, id, LFGFrameLeaderCheckButton:GetChecked(), LFGFrameRoleButton2:GetChecked(), LFGFrameRoleButton3:GetChecked(), LFGFrameRoleButton1:GetChecked());
	end

	UIDropDownMenu_SetSelectedID(dropdown, id);
	LFG_DISABLED_DROPDOWN_NAMES[dropdownID].name = id;

	local iconTexture = getglobal("LFGSearchIcon"..dropdownID);
	local iconPath = "Interface\\LFGFrame\\LFGIcon-";
	local selectedText = "";
	local typeDropdown = getglobal("LFGFrameTypeDropDown"..dropdownID);
	if ( UIDropDownMenu_GetText(getglobal("LFGFrameNameDropDown"..dropdownID)) ) then
		selectedText = UIDropDownMenu_GetText(typeDropdown);
	end
	if ( icon and icon ~= "" ) then
		icon = iconPath..icon;
	elseif ( selectedText == LFG_TYPE_QUEST ) then
		icon = iconPath.."Quest";
	elseif ( selectedText == LFG_TYPE_RAID ) then
		icon = iconPath.."Raid";
	elseif ( selectedText == LFG_TYPE_ZONE ) then
		icon = iconPath.."Zone";
	elseif ( selectedText == LFG_TYPE_BATTLEGROUND ) then
		icon = iconPath.."BattleGround";
	elseif ( strfind(selectedText, LFG_TYPE_DUNGEON) ) then
		icon = iconPath.."Dungeon";
	end

	-- If finally have an icon then start the shine
	if ( not icon ) then
		icon = "";
	end
	iconTexture:SetTexture(icon);

	if ( (strfind(selectedText, LFG_TYPE_DUNGEON) or strfind(selectedText, LFG_TYPE_HEROIC_DUNGEON)) and id ~= 0 ) then
		typeDropdown.canAutoJoin = 1;
	else
		typeDropdown.canAutoJoin = nil;
	end
end

function LFGFrameClearAllButton_OnClick()
	ClearLookingForGroup();
	LFGFrame_Update();
	LFGParentFrame_UpdateTabs();
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function LFGFrame_UpdateRoles()
	local _, englishClass = UnitClass("player");
	local frame, label, roleStatus;
	for i=1,NUM_ROLES do
		frame = _G["LFGFrameRoleButton"..i];
		label = _G["LFGFrameRoleButton"..i.."Label"];
		roleStatus = classRoles[englishClass][i];
		if ( roleStatus == ROLE_DISABLED ) then
			frame:SetChecked(false);
			frame:Disable();
			label:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		elseif ( roleStatus == ROLE_ENABLED ) then
			frame:Enable();
			label:SetTextColor(label:GetFontObject():GetTextColor());
		end
	end
end

function LFGFrameRoleCheckButton_OnClick(self, button)
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		
		LFGFrame_UpdateRolesChosen();
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		
		local _, _, _, _, _, _, _, _, _, _, lfgStatus = GetLookingForGroup();
		if ( (not lfgStatus) or LFGFrame_AreRolesChosen() ) then
			LFGFrame_UpdateRolesChosen();
		else
			StaticPopup_Show("CONFIRM_LFG_REMOVE_LAST_ROLE");
		end
	end
end

function LFGFrame_AreRolesChosen()
	for i=1,NUM_ROLES do
		if ( _G["LFGFrameRoleButton"..i]:GetChecked() ) then
			return true;
		end
	end
	return false;
end

function LFGFrame_UpdateRolesChosen()
	local frame;
	SetLFGRoles(LFGFrameLeaderCheckButton:GetChecked(), LFGFrameRoleButton2:GetChecked(), LFGFrameRoleButton3:GetChecked(), LFGFrameRoleButton1:GetChecked());
	if ( LFGFrame_AreRolesChosen() ) then
		LFGFrameNoRoleBackground:Hide();
	else
		LFGFrameNoRoleBackground:Show();
	end
end

function LFGFrame_UpdateRoleBoxes()
	local leader, tank, healer, damage = GetLFGRoles();
	LFGFrameLeaderCheckButton:SetChecked(leader)
	LFGFrameRoleButton1:SetChecked(damage);
	LFGFrameRoleButton2:SetChecked(tank);
	LFGFrameRoleButton3:SetChecked(healer);
end

function LFMFrameDropDown1_OnLoad(self)
	UIDropDownMenu_Initialize(self, LFMFrameDropDown1_Initialize);
	UIDropDownMenu_SetWidth(self, 80);
	UIDropDownMenu_SetButtonWidth(self, 24);
	UIDropDownMenu_JustifyText(self, "LEFT")
	LFMFrameColumn1Type = LFMCOLUMN1TYPE_INDIVIDUAL;
	UIDropDownMenu_SetSelectedID(self, 1);
end

LFMFRAME_DROPDOWN_LIST1 = {
	{ name = INDIVIDUALS,
			func = function(self)
				UIDropDownMenu_SetSelectedID(LFMFrameDropDown1, self:GetID());
				LFMFrameColumn1Type = LFMCOLUMN1TYPE_INDIVIDUAL;
				LFMFrame.selectedName = nil;
				LFMFrame.selectedLFM = nil;
				LFMFrame_CacheAndUpdate();
			end,
	},
	{ name = GROUPS,
			func = function(self)
				UIDropDownMenu_SetSelectedID(LFMFrameDropDown1, self:GetID());
				LFMFrameColumn1Type = LFMCOLUMN1TYPE_GROUP;
				LFMFrame.selectedName = nil;
				LFMFrame.selectedLFM = nil;
				LFMFrame_CacheAndUpdate();
			end,
	},
}
function LFMFrameDropDown1_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	for i=1, #LFMFRAME_DROPDOWN_LIST1, 1 do
		info.text = LFMFRAME_DROPDOWN_LIST1[i].name;
		info.func = LFMFRAME_DROPDOWN_LIST1[i].func;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

LFMFrame_RoleFilter_Individual = {
	["leader"] = false, --People usually don't care if the person they're looking for is going to be a healer, so we won't filter on that by default.
	["tank"] = true,
	["healer"] = true,
	["damage"] = true,
};

function LFMFrameColumnHeaderRole_Update()
	local frame;
	if ( LFMFrameColumn1Type == LFMCOLUMN1TYPE_GROUP ) then
		return;
	end
	for i=4, 3+NUM_ROLES+1 do
		frame = _G["LFMFrameColumnHeader"..i];
		frame.checked = LFMFrame_RoleFilter_Individual[frame.filterType];
		if ( LFMFrame_RoleFilter_Individual[frame.filterType] ) then
			frame.Icon:SetTexture("Interface\\LFGFrame\\LFGRole")
		else
			frame.Icon:SetTexture("Interface\\LFGFrame\\LFGRole_BW")
		end
	end
end

function LFMFrameColumnHeaderRole_OnClick(self)
	if ( LFMFrameColumn1Type == LFMCOLUMN1TYPE_GROUP ) then
		return;
	end
	LFMFrame_RoleFilter_Individual[self.filterType] = self.checked;
	LFMFrame_CacheAndUpdate();
end

function LFMFrameFilter_DataMatches(...)
	local name, level, zone, class, criteria1, criteria2, criteria3, comment, numPartyMembers, isLFM, classFileName, willBeLeader, willBeTank, willBeHealer, willBeDPS = ...;
	
	if ( LFMFrameColumn1Type == LFMCOLUMN1TYPE_GROUP ) then
		if ( (not numPartyMembers) or (numPartyMembers <= 0) ) then
			return false;
		end
	elseif ( (LFMFrameColumn1Type == LFMCOLUMN1TYPE_INDIVIDUAL)  ) then
		if ( numPartyMembers and (numPartyMembers > 0) ) then
			return false;
		end
		local roleFilterTab = LFMFrame_RoleFilter_Individual;
		if ( not ( (roleFilterTab["leader"] and willBeLeader) or
					(roleFilterTab["tank"] and willBeTank) or
					(roleFilterTab["healer"] and willBeHealer) or
					(roleFilterTab["damage"] and willBeDPS) ) ) then
			return false;
		end
	end
	
	return true;
end

function LFGFrameCommentButton_OnClick(self)
	StaticPopup_Show("SET_LFGNOTE");
end
