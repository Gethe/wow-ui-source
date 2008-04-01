MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;
MOVING_RAID_MEMBER = nil;
TARGET_RAID_SLOT = nil;

function RaidFrame_OnLoad()
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	RaidGroup_SetSlotStatus(nil);
end

function RaidFrame_OnShow()
	RaidFrame_Update();
end

function RaidFrame_OnHide()
	-- If there's a selected button then call the onmouseup function on it when the frame is hidden
	if ( MOVING_RAID_MEMBER ) then
		RaidGroupButton_OnMouseUp("LeftButton", MOVING_RAID_MEMBER);
	end
end

function RaidFrame_OnEvent()
	if ( event == "RAID_ROSTER_UPDATE" ) then
		RaidFrame_Update();
	end
end

function RaidFrame_Update()
	-- Handle management buttons
	RaidFrameConvertToRaidButton:Disable();
	RaidFrameAddMemberButton:Disable();
	if ( IsRaidLeader() or IsRaidOfficer() ) then
		if ( IsRaidLeader() and (GetNumRaidMembers() == 0) ) then
			RaidFrameConvertToRaidButton:Enable();
		end
		RaidFrameAddMemberButton:Enable();
	end

	-- If not in a raid hide all the UI and just display raid explanation text
	if ( GetNumRaidMembers() == 0 ) then
		for i=1, NUM_RAID_GROUPS do
			getglobal("RaidGroup"..i):Hide();
		end
		RaidFrameRaidDescription:Show();
	else
		for i=1, NUM_RAID_GROUPS do
			getglobal("RaidGroup"..i):Show();
		end
		RaidFrameRaidDescription:Hide();
	end
	
	-- Reset group index counters;
	for i=1, NUM_RAID_GROUPS do
		getglobal("RaidGroup"..i).nextIndex = 1;
	end
	-- Clear out all the slots buttons
	RaidGroup_ResetSlotButtons();

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
				buttonLevel = getglobal("RaidGroupButton"..i.."Level");
				buttonClass = getglobal("RaidGroupButton"..i.."Class");
				buttonRank = getglobal("RaidGroupButton"..i.."Rank");
				button.id = i;
				
				button.name = name;
				button.unit = "raid"..i;
				
				if ( level == 0 ) then
					level = "";
				end
				
				if ( not name ) then
					name = UNKNOWN;
				end
				
				buttonName:SetText(name);
				buttonLevel:SetText(level);
				buttonClass:SetText(class);
				
				if ( isDead ) then
					buttonName:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					buttonClass:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					buttonLevel:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				elseif ( online ) then
					color = RAID_CLASS_COLORS[fileName];
					if ( color ) then
						buttonName:SetVertexColor(color.r, color.g, color.b);
						buttonLevel:SetVertexColor(color.r, color.g, color.b);
						buttonClass:SetVertexColor(color.r, color.g, color.b);
					end
				else
					buttonName:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					buttonClass:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					buttonLevel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
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

function RaidGroupButton_OnMouseUp(button, raidButton)
	if ( not raidButton ) then
		raidButton = this;
	end
	if ( button ~= "RightButton" ) then
		raidButton:StopMovingOrSizing();
		MOVING_RAID_MEMBER = nil;
		if ( TARGET_RAID_SLOT and TARGET_RAID_SLOT:GetParent():GetID() ~= raidButton.subgroup ) then
			if (TARGET_RAID_SLOT.button) then
				local button = getglobal(TARGET_RAID_SLOT.button);
				--button:SetPoint("TOPLEFT", this:GetName(), "TOPLEFT", 0, 0);
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
end

function RaidGroupButton_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		if ( not IsRaidLeader() ) then
			return;
		end
		this:StartMoving();
		MOVING_RAID_MEMBER = this;
		SetRaidRosterSelection(this.id);
	else
		HideDropDownMenu(1);
		if ( this.id and this.name ) then
			FriendsDropDown.initialize = RaidFrameDropDown_Initialize;
			FriendsDropDown.displayMode = "MENU";
			ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
		end
	end
end

function RaidFrameDropDown_Initialize()
	UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "RAID", this.unit, this.name, this.id);
end

function RaidGroup_SetSlotStatus(enable)
	for i=1, NUM_RAID_GROUPS do
		for j=1, MEMBERS_PER_RAID_GROUP do
			if ( enable ) then
				getglobal("RaidGroup"..i.."Slot"..j):Enable();
			else
				getglobal("RaidGroup"..i.."Slot"..j):Disable();
			end
		end
	end
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

function RaidGroupFrame_OnLoad()
	RaidGroup_SetSlotStatus(nil);
end

function Toggle_RaidGroups()
	if ( GetCenterFrame() ) then
		HideUIPanel(GetCenterFrame());
	end
	if ( RaidGroupFrame:IsVisible() ) then
		RaidGroupFrame:Hide();
	else
		RaidGroupFrame:Show();
	end
end
