
MOVING_RAID_MEMBER = nil;
TARGET_RAID_SLOT = nil;
RAID_SUBGROUP_LISTS = {};
NUM_RAID_PULLOUT_FRAMES = 0;
RAID_PULLOUT_BUTTON_HEIGHT = 33;
MOVING_RAID_PULLOUT = nil;

function RaidGroupFrame_OnLoad()
	RaidFrame:RegisterEvent("UNIT_LEVEL");
	RaidFrame:RegisterEvent("UNIT_HEALTH");
	RaidFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	RaidFrame:SetScript("OnHide", RaidGroupFrame_OnHide);
	RaidFrame:SetScript("OnEvent", RaidGroupFrame_OnEvent);
	RaidFrame:SetScript("OnUpdate", RaidGroupFrame_OnUpdate);
end

function RaidGroupFrame_OnHide()
	-- If there's a selected button then call the onmouseup function on it when the frame is hidden
	if ( MOVING_RAID_MEMBER ) then
		RaidGroupButton_OnDragStop(MOVING_RAID_MEMBER);
	end
end

function RaidGroupFrame_OnEvent()
	RaidFrame_OnEvent();
	if ( event == "UNIT_LEVEL" ) then
		local id, found = gsub(arg1, "raid([0-9]+)", "%1");
		if ( found == 1 ) then
			RaidGroupFrame_UpdateLevel(id);
		end
	end
	if ( event == "UNIT_HEALTH" ) then
		local id, found = gsub(arg1, "raid([0-9]+)", "%1");
		if ( found == 1 ) then
			RaidGroupFrame_UpdateHealth(id);
		end
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		RaidFrameReadyCheckButton_Update();
		RaidFrameAddMemberButton_Update();
	end
end

function RaidGroupFrame_Update()

	-- Update raid group labels
	if ( GetNumRaidMembers() == 0 ) then
		for i=1, NUM_RAID_GROUPS do
			getglobal("RaidGroup"..i):Hide();
		end
		RaidFrameReadyCheckButton:Hide();
	else
		for i=1, NUM_RAID_GROUPS do
			getglobal("RaidGroup"..i):Show();
		end
	end

	RaidFrameReadyCheckButton_Update();
	RaidFrameAddMemberButton_Update();
	if ( RaidFrameReadyCheckButton:IsShown() ) then
		RaidFrameRaidInfoButton:SetPoint("LEFT", "RaidFrameReadyCheckButton", "RIGHT", 2, 0);
	end


	-- Reset group index counters;
	for i=1, NUM_RAID_GROUPS do
		getglobal("RaidGroup"..i).nextIndex = 1;
	end
	-- Clear out all the slots buttons
	RaidGroup_ResetSlotButtons();

	-- Clear out subgroup list
	RAID_SUBGROUP_LISTS = {};
	for i=1, NUM_RAID_GROUPS do
		RAID_SUBGROUP_LISTS[i] = {};
	end

	-- Use the class color list to clear out the class list
	for index, value in RAID_CLASS_COLORS do
		RAID_SUBGROUP_LISTS[index] = {};
	end

	-- Fill out buttons
	local numRaidMembers = GetNumRaidMembers();
	local raidGroup, color;
	local buttonName, buttonLevel, buttonClass, buttonRank;
	local name, rank, subgroup, level, class, fileName, zone, online, isDead;
	for i=1, MAX_RAID_MEMBERS do
		button = getglobal("RaidGroupButton"..i);
		if ( i <= numRaidMembers ) then
			name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i);
			raidGroup = getglobal("RaidGroup"..subgroup);
			-- To prevent errors when the server hiccups
			if ( raidGroup.nextIndex <= MEMBERS_PER_RAID_GROUP ) then
				buttonName = getglobal("RaidGroupButton"..i.."Name");
				buttonClass = getglobal("RaidGroupButton"..i.."Class");
				buttonLevel = getglobal("RaidGroupButton"..i.."Level");
				buttonRank = getglobal("RaidGroupButton"..i.."Rank");
				button.id = i;
				
				button.name = name;
				button.unit = "raid"..i;
				button.class = fileName;
				
				if ( level == 0 ) then
					level = "";
				end
				
				if ( not name ) then
					name = UNKNOWN;
				end
				
				-- Fill in subgroup list
				tinsert(RAID_SUBGROUP_LISTS[subgroup], i);

				-- Fill in class list
				if ( fileName ) then
					tinsert(RAID_SUBGROUP_LISTS[fileName], i);
				end
				
				buttonName:SetText(name);
				if ( class ) then
					buttonClass:SetText(class);
				else
					buttonClass:SetText("");
				end
				
				if ( level ) then
					buttonLevel:SetText(level);
				else
					buttonLevel:SetText("");
				end
				
				if ( online ) then
					if ( isDead ) then
						buttonName:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
						buttonClass:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
						buttonLevel:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					else
						color = RAID_CLASS_COLORS[fileName];
						if ( color ) then
							buttonName:SetTextColor(color.r, color.g, color.b);
							buttonClass:SetTextColor(color.r, color.g, color.b);
							buttonLevel:SetTextColor(color.r, color.g, color.b);
						end
					end
				else
					buttonName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					buttonClass:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					buttonLevel:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				end

				if ( rank == 2 ) then
					buttonRank:SetText(RAID_LEADER_TOKEN);
				elseif ( rank == 1 ) then
					buttonRank:SetText(RAID_ASSISTANT_TOKEN);
				else 
					buttonRank:SetText("");
				end
			
				-- Anchor button to slot
				if ( MOVING_RAID_MEMBER ~= button  ) then
					button:SetPoint("TOPLEFT", "RaidGroup"..subgroup.."Slot"..raidGroup.nextIndex, "TOPLEFT", 0, 0);
				end
				
				-- Save slot for future use
				button.slot = "RaidGroup"..subgroup.."Slot"..raidGroup.nextIndex;
				-- Save the button's subgroup too
				button.subgroup = subgroup;
				-- Tell the slot what button is in it
				getglobal("RaidGroup"..subgroup.."Slot"..raidGroup.nextIndex).button = button:GetName();
				raidGroup.nextIndex = raidGroup.nextIndex + 1;
				button:SetID(i);
				button:Show();
			end
		else
			button:Hide();
		end
	end
end

function RaidGroupFrame_UpdateLevel(id)
	local unit = "raid"..id;
	local buttonLevel = getglobal("RaidGroupButton"..id.."Level");

	buttonLevel:SetText(UnitLevel(unit));
end

function RaidGroupFrame_UpdateHealth(id)
	local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(id);

	local buttonName = getglobal("RaidGroupButton"..id.."Name");
	local buttonClass = getglobal("RaidGroupButton"..id.."Class");
	local buttonLevel = getglobal("RaidGroupButton"..id.."Level");

	if ( online ) then
		if ( isDead ) then
			buttonName:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			buttonClass:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			buttonLevel:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			color = RAID_CLASS_COLORS[fileName];
			if ( color ) then
				buttonName:SetTextColor(color.r, color.g, color.b);
				buttonClass:SetTextColor(color.r, color.g, color.b);
				buttonLevel:SetTextColor(color.r, color.g, color.b);
			end
		end
	else
		buttonName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		buttonClass:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		buttonLevel:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function RaidGroupFrame_OnUpdate(elapsed)
	if ( MOVING_RAID_MEMBER ) then
		local button, slot;
		TARGET_RAID_SLOT = nil;
		for i=1, NUM_RAID_GROUPS do
			for j=1, MEMBERS_PER_RAID_GROUP do
				slot = getglobal("RaidGroup"..i.."Slot"..j);
				if ( MouseIsOver(slot) ) then
					slot:LockHighlight();
					TARGET_RAID_SLOT = slot;
				else
					slot:UnlockHighlight();
				end
			end
		end
	end
end

function RaidGroupButton_OnDragStart()
	if ( not IsRaidLeader() ) then
		return;
	end
	local cursorX, cursorY = GetCursorPosition();
	this:ClearAllPoints();
	this:SetPoint("CENTER", nil, "BOTTOMLEFT", cursorX*GetScreenWidthScale(), cursorY*GetScreenHeightScale());
	this:StartMoving();
	MOVING_RAID_MEMBER = this;
	SetRaidRosterSelection(this.id);
end

function RaidGroupButton_OnDragStop(raidButton)
	if ( not IsRaidLeader() ) then
		return;
	end
	if ( not raidButton ) then
		raidButton = this;
	end
	
	raidButton:StopMovingOrSizing();
	MOVING_RAID_MEMBER = nil;
	if ( TARGET_RAID_SLOT and TARGET_RAID_SLOT:GetParent():GetID() ~= raidButton.subgroup ) then
		if (TARGET_RAID_SLOT.button) then
			local button = getglobal(TARGET_RAID_SLOT.button);
			--button:SetPoint("TOPLEFT", this, "TOPLEFT", 0, 0);
			SwapRaidSubgroup(raidButton:GetID(), button:GetID());
		else
			local slot = TARGET_RAID_SLOT:GetParent():GetName().."Slot"..TARGET_RAID_SLOT:GetParent().nextIndex;
			raidButton:SetPoint("TOPLEFT", slot, "TOPLEFT", 0, 0);
			TARGET_RAID_SLOT:UnlockHighlight();
			SetRaidSubgroup(raidButton:GetID(), TARGET_RAID_SLOT:GetParent():GetID());
		end
	else
		if ( TARGET_RAID_SLOT ) then
			TARGET_RAID_SLOT:UnlockHighlight();
		end
		raidButton:SetPoint("TOPLEFT", raidButton.slot, "TOPLEFT", 0, 0);
	end
end

function RaidGroupButton_OnClick(button)
	if ( button == "LeftButton" ) then
		local unit = "raid"..this.id;
		if ( SpellIsTargeting() ) then
			SpellTargetUnit(unit);
		elseif ( CursorHasItem() ) then
			DropItemOnUnit(unit);
		else
			TargetUnit(unit);
		end
	else
		HideDropDownMenu(1);
		if ( this.id and this.name ) then
			FriendsDropDown.initialize = RaidFrameDropDown_Initialize;
			FriendsDropDown.displayMode = "MENU";
			ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
		end
	end
end

function RaidGroupButton_OnEnter()
	if ( SpellIsTargeting() ) then
		if ( SpellCanTargetUnit(this.unit) ) then
			SetCursor("CAST_CURSOR");
		else
			SetCursor("CAST_ERROR_CURSOR");
		end
	end

	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	
	if ( GameTooltip:SetUnit(this.unit) ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end

	this.r, this.g, this.b = GameTooltip_UnitColor(this.unit);
	GameTooltipTextLeft1:SetTextColor(this.r, this.g, this.b);
end

function RaidFrameDropDown_Initialize()
	UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "RAID", this.unit, this.name, this.id);
end

function RaidGroup_ResetSlotButtons()
	for i=1, NUM_RAID_GROUPS do
		for j=1, MEMBERS_PER_RAID_GROUP do
			getglobal("RaidGroup"..i.."Slot"..j).button = nil;
		end
	end
end

function RaidButton_OnClick()
	SetRaidRosterSelection(this.index);
	RaidFrame_Update();
end

----------------- Pullout Button Functions --------------------
function RaidPullout_OnEvent()
	if ( event == "RAID_ROSTER_UPDATE" and this:IsVisible() ) then
		RaidPullout_Update();
	end
end

function RaidPullout_GenerateGroupFrame(groupID)
	-- construct the button listing
	if ( not groupID ) then
		groupID = this:GetParent():GetID();
	end
	
	-- Get a handle on a pullout frame
	local pullOutFrame = RaidPullout_GetFrame(groupID);
	if ( pullOutFrame ) then
		pullOutFrame.filterID = groupID;
		pullOutFrame.showBuffs = nil;
		-- Set pullout name
		getglobal(pullOutFrame:GetName().."Name"):SetText(GROUP.." "..groupID);
		if ( RaidPullout_Update(pullOutFrame) ) then
			return pullOutFrame;		
		end
	end
end

function RaidPullout_GenerateClassFrame(class, fileName)
	-- construct the button listing
	if ( not class ) then
		class = this:GetParent().class;
	end
	
	-- Get a handle on a pullout frame
	local pullOutFrame = RaidPullout_GetFrame(fileName);
	if ( pullOutFrame ) then
		pullOutFrame.filterID = fileName;
		pullOutFrame.showBuffs = nil;
		-- Set pullout name
		getglobal(pullOutFrame:GetName().."Name"):SetText(class);
		if ( RaidPullout_Update(pullOutFrame) ) then
			return pullOutFrame;		
		end
	end
end

function RaidPullout_Update(pullOutFrame)
	if ( not pullOutFrame ) then
		pullOutFrame = this;
	end

	local filterID = pullOutFrame.filterID;
	local numPulloutEntries = 0;
	if ( RAID_SUBGROUP_LISTS[filterID] ) then
		numPulloutEntries = getn(RAID_SUBGROUP_LISTS[filterID]);
	end
	local pulloutList = RAID_SUBGROUP_LISTS[filterID];

	-- Hide the pullout if no entries
	if ( numPulloutEntries == 0 ) then
		pullOutFrame:Hide();
		return nil;
	end

	-- Fill out the buttons
	local pulloutButton, pulloutButtonName, color, unit, pulloutHealthBar, pulloutManaBar, unitHPMin, unitHPMax;
	local name, rank, subgroup, level, class, fileName, zone, online, isDead;
	local debuff;

	if ( numPulloutEntries > pullOutFrame.numPulloutButtons ) then
		local index = pullOutFrame.numPulloutButtons + 1;
		local relative;
		for i=index, numPulloutEntries do
			pulloutButton = CreateFrame("Frame", pullOutFrame:GetName().."Button"..i, pullOutFrame, "RaidPulloutButtonTemplate");
			if ( i == 1 ) then
				pulloutButton:SetPoint("TOP", pullOutFrame, "TOP", 1, -10);
			else
				relative = getglobal(pullOutFrame:GetName().."Button"..(i-1));
				pulloutButton:SetPoint("TOP", relative, "BOTTOM", 0, -8);
			end
		end
		pullOutFrame.numPulloutButtons = numPulloutEntries;
	end
	for i=1, pullOutFrame.numPulloutButtons do
		pulloutButton = getglobal(pullOutFrame:GetName().."Button"..i);
		if ( i <= numPulloutEntries ) then
			pulloutButtonName = getglobal(pulloutButton:GetName().."Name");
			pulloutHealthBar = getglobal(pulloutButton:GetName().."HealthBar");
			pulloutManaBar = getglobal(pulloutButton:GetName().."ManaBar");
			name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(pulloutList[i]);
			-- follow same coloration rules as the raid interface
			pulloutButtonName:SetText(name);
			unit = "raid"..pulloutList[i];
			pulloutButton.unit = unit;
			
			-- Set for tooltip support
			getglobal(pulloutButton:GetName().."ClearButton").unit = unit;
			
			pulloutButton.raidIndex = pulloutList[i];
			pulloutButton.manabar = pulloutManaBar;
			pulloutManaBar.unit = unit;
			if ( online ) then
				RaidPulloutButton_UpdateDead(pulloutButton, isDead, fileName);
				-- Setup Health and mana bars
				UnitFrameHealthBar_Initialize(unit, pulloutHealthBar);
				UnitFrameHealthBar_Update(pulloutHealthBar, unit);
				UnitFrameManaBar_Initialize(unit, pulloutManaBar);
				UnitFrameManaBar_Update(pulloutManaBar, unit);
			else
				-- Offline so gray out and maxout healthbar
				unitHPMin, unitHPMax = pulloutHealthBar:GetMinMaxValues();
				pulloutHealthBar:SetValue(unitHPMax);
				pulloutHealthBar:SetStatusBarColor(0.5, 0.5, 0.5);
				pulloutButtonName:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				UnitFrameManaBar_Update(pulloutManaBar, unit);
			end
			
			-- Handle buffs/debuffs
			RefreshBuffs(pulloutButton, pullOutFrame.showBuffs, unit);

			pulloutButton:RegisterEvent("UNIT_HEALTH");
			pulloutButton:RegisterEvent("UNIT_AURA");
			pulloutButton:Show();
		else
			pulloutButton:UnregisterEvent("UNIT_HEALTH");
			pulloutButton:UnregisterEvent("UNIT_AURA");
			pulloutButton:Hide();
		end
	end
	pullOutFrame:SetHeight(numPulloutEntries * RAID_PULLOUT_BUTTON_HEIGHT + 14);
	pullOutFrame:Show();
	return 1;
end

function RaidPulloutButton_OnEvent()
	if ( event == "UNIT_HEALTH" ) then
		if ( arg1 == this.unit ) then
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(this.raidIndex);
			if ( online ) then
				RaidPulloutButton_UpdateDead(this, isDead, fileName);
			end
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == this.unit ) then
			RefreshBuffs(this, this:GetParent().showBuffs, this.unit);
		end
	end
end

function RaidPulloutButton_UpdateDead(button, isDead, class)
	local pulloutButtonName = getglobal(button:GetName().."Name");
	if ( isDead ) then
		pulloutButtonName:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	else
		local color = RAID_CLASS_COLORS[class];
		if ( color ) then
			pulloutButtonName:SetVertexColor(color.r, color.g, color.b);
		end
	end
end

function RaidPulloutButton_OnClick()
	if ( arg1 == "LeftButton" ) then
		-- Select target or cast spell on
		local unit = this.unit;
		-- If no unit assume that this is a manabar or healthbar and look at the parent's unit info
		if ( not unit ) then
			unit = this:GetParent().unit;
		end
		if ( SpellIsTargeting() ) then
			SpellTargetUnit(unit);
		elseif ( CursorHasItem() ) then
			DropItemOnUnit(unit);
		else
			TargetUnit(unit);
		end
	elseif ( arg1 == "RightButton" ) then
		ToggleDropDownMenu(1, nil, getglobal(this:GetParent():GetParent():GetName().."DropDown"));
	end
end

function RaidPulloutButton_OnDragStart(frame)
	if ( not frame ) then
		MOVING_RAID_PULLOUT = nil;
		return;
	end
	local cursorX, cursorY = GetCursorPosition();
	frame:SetFrameStrata("DIALOG");
	frame:ClearAllPoints();
	frame:SetPoint("TOP", nil, "BOTTOMLEFT", cursorX*GetScreenWidthScale(), cursorY*GetScreenHeightScale());
	frame:StartMoving();
	MOVING_RAID_PULLOUT = frame;
end

function RaidPulloutStopMoving()
	if ( MOVING_RAID_PULLOUT ) then
		MOVING_RAID_PULLOUT:StopMovingOrSizing();
		MOVING_RAID_PULLOUT:SetFrameStrata("BACKGROUND");
		ValidateFramePosition(MOVING_RAID_PULLOUT, 25);
	end
end

function RaidPullout_GetFrame(filterID)
	-- Grab an available pullout frame
	local frame;
	for i=1, NUM_RAID_PULLOUT_FRAMES do
		frame = getglobal("RaidPullout"..i);
		-- if frame is visible see if its group id is already taken
		if ( frame:IsVisible() and filterID == frame.filterID ) then
			return nil;
		end
	end
	for i=1, NUM_RAID_PULLOUT_FRAMES do
		frame = getglobal("RaidPullout"..i);
		if ( not frame:IsVisible() ) then
			return frame;
		end
	end
	NUM_RAID_PULLOUT_FRAMES = NUM_RAID_PULLOUT_FRAMES + 1;
	frame = CreateFrame("Button", "RaidPullout"..NUM_RAID_PULLOUT_FRAMES, UIParent, "RaidPulloutFrameTemplate");
	frame.numPulloutButtons = 0;
	return frame;
end

function RaidPulloutDropDown_OnLoad()
	this.raidPulloutDropDown = true;
	UIDropDownMenu_Initialize(this, RaidPulloutDropDown_Initialize, "MENU");
	UIDropDownMenu_SetAnchor(0, 0, this, "TOPLEFT", this:GetParent():GetName(), "TOPRIGHT")
end

function RaidPulloutDropDown_Initialize()
	if ( not UIDROPDOWNMENU_OPEN_MENU or not getglobal(UIDROPDOWNMENU_OPEN_MENU).raidPulloutDropDown ) then
		return;
	end
	local currentPullout = getglobal(UIDROPDOWNMENU_OPEN_MENU):GetParent();
	local info;
	
	-- Show buffs or debuffs they are exclusive for now
	info = {};
	info.text = SHOW_BUFFS;
	info.func = function()
		currentPullout.showBuffs = 1;
		RaidPullout_Update(currentPullout);
	end;
	if ( currentPullout.showBuffs ) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = SHOW_DEBUFFS;
	info.func = function()
		currentPullout.showBuffs = nil;
		RaidPullout_Update(currentPullout);
	end;
	if ( not currentPullout.showBuffs ) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info);
	
	-- Hide background option
	local backdrop = getglobal(currentPullout:GetName().."MenuBackdrop");
	info = {};
	info.text = HIDE_PULLOUT_BG;
	info.func = function ()
		if ( backdrop:IsVisible() ) then
			backdrop:Hide();
		else
			backdrop:Show();
		end
	end;
	if ( not backdrop:IsVisible() ) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info);

	-- Close option
	info = {};
	info.text = CLOSE;
	info.func = function()
		currentPullout:Hide();
	end;
	UIDropDownMenu_AddButton(info);
end

-- Ready Check Functions
function ShowReadyCheck()
	local name, rank, leader;
	for i=1, MAX_RAID_MEMBERS do
		name, rank = GetRaidRosterInfo(i);
		if ( name ) then
			-- find leader
			if ( rank == 2 ) then
				leader = "raid"..i;
				break;
			end
		end
	end
	SetPortraitTexture(ReadyCheckPortrait, leader);
	ReadyCheckFrameText:SetText(format(READY_CHECK_MESSAGE, name));
	ReadyCheckFrame:Show();
	ReadyCheckFrame.timer = 30;
	PlaySound("ReadyCheck");
end

function ReadyCheck_OnUpdate(elapsed)
	if ( not ReadyCheckFrame.timer ) then
		return;
	end
	ReadyCheckFrame.timer = ReadyCheckFrame.timer-elapsed;
	if ( ReadyCheckFrame.timer < 0 ) then
		-- Timed out
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(TEXT(READY_CHECK_YOU_WERE_AFK), info.r, info.g, info.b, info.id);
		ReadyCheckFrame.timer = nil;
		ReadyCheckFrame:Hide();
	end
	
end

function RaidFrameReadyCheckButton_Update()
	if ( GetNumRaidMembers() > 0 and IsRaidLeader() ) then
		RaidFrameReadyCheckButton:Show();
	else
		RaidFrameReadyCheckButton:Hide();
	end
end

function RaidFrameAddMemberButton_Update()
	if ( GetNumRaidMembers() > 0 ) then
		RaidFrameAddMemberButton:Show();
		if ( IsRaidLeader() or IsRaidOfficer() ) then
			RaidFrameAddMemberButton:Enable();
		else
			RaidFrameAddMemberButton:Disable();
		end
	else	
		RaidFrameAddMemberButton:Hide();
	end
end
