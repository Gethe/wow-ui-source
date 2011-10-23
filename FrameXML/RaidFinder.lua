function RaidFinderFrame_OnLoad(self)
	self:RegisterEvent("LFG_LOCK_INFO_RECEIVED");
end

function RaidFinderFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LOCK_INFO_RECEIVED" ) then
		if ( not RaidFinderQueueFrame.raid or not IsLFGDungeonJoinable(RaidFinderQueueFrame.raid) ) then
			RaidFinderQueueFrame_SetRaid(GetBestRFChoice());
			--RaidFinderQueueFrame.raid = GetBestRFChoice();
			--UIDropDownMenu_SetSelectedValue(RaidFinderQueueFrameSelectionDropDown, RaidFinderQueueFrame.raid);
		end
	end
end

function RaidFinderFrame_OnShow(self)
	RequestLFDPlayerLockInfo();
	RequestLFDPartyLockInfo();
	ButtonFrameTemplate_HideAttic(self:GetParent());
	self:GetParent().TitleText:SetText(RAID_FINDER);
	RaidFinderFrameFindRaidButton_Update();
	
	self:GetParent().Inset:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", 2, 284);
	self:GetParent().Inset:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -2, 26);
end

function RaidFinderQueueFrameSelectionDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, RaidFinderQueueFrameSelectionDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(RaidFinderQueueFrameSelectionDropDown, RaidFinderQueueFrame.raid);
end

function RaidFinderQueueFrameSelectionDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	
	for i=1, GetNumRFDungeons() do
		local id, name = GetRFDungeonInfo(i);
		local isAvailable = IsLFGDungeonJoinable(id);
		if ( isAvailable or isRaidFinderDungeonDisplayable(id) ) then
			if ( isAvailable ) then
				info.text = name; --Note that the dropdown text may be manually changed in RaidFinderQueueFrame_SetRaid
				info.value = id;
				info.isTitle = nil;
				info.func = RaidFinderQueueFrameSelectionDropDownButton_OnClick;
				info.disabled = nil;
				info.checked = (RaidFinderQueueFrame.raid == info.value);
				info.tooltipWhileDisabled = nil;
				info.tooltipOnButton = nil;
				info.tooltipTitle = nil;
				info.tooltipText = nil;
				UIDropDownMenu_AddButton(info);
			else
				info.text = name; --Note that the dropdown text may be manually changed in RaidFinderQueueFrame_SetRaid
				info.value = id;
				info.isTitle = nil;
				info.func = nil;
				info.disabled = 1;
				info.checked = nil;
				info.tooltipWhileDisabled = 1;
				info.tooltipOnButton = 1;
				info.tooltipTitle = YOU_MAY_NOT_QUEUE_FOR_THIS;
				info.tooltipText = LFGConstructDeclinedMessage(id);
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

function RaidFinderQueueFrameSelectionDropDownButton_OnClick(self)
	RaidFinderQueueFrame_SetRaid(self.value);
end

function RaidFinderQueueFrame_SetRaid(value)
	RaidFinderQueueFrame.raid = value;
	UIDropDownMenu_SetSelectedValue(RaidFinderQueueFrameSelectionDropDown, value);
	if ( value ) then
		local name = GetLFGDungeonInfo(value);
		UIDropDownMenu_SetText(RaidFinderQueueFrameSelectionDropDown, name);
	end
	RaidFinderQueueFrameRewards_UpdateFrame();
end

function RaidFinderQueueFrame_Join()
	if ( RaidFinderQueueFrame.raid ) then
		ClearAllLFGDungeons();
		SetLFGDungeon(RaidFinderQueueFrame.raid);
		JoinLFG();
	end
end

function isRaidFinderDungeonDisplayable(id)
	local name, typeID, subtypeID, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(id);
	local myLevel = UnitLevel("player");
	return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel;
end

function RaidFinderFrameRoleCheckButton_OnClick(self)
	RaidFinderQueueFrame_SetRoles();
end

function RaidFinderQueueFrame_SetRoles()
	SetLFGRoles(RaidFinderQueueFrameRoleButtonLeader.checkButton:GetChecked(), 
		RaidFinderQueueFrameRoleButtonTank.checkButton:GetChecked(),
		RaidFinderQueueFrameRoleButtonHealer.checkButton:GetChecked(),
		RaidFinderQueueFrameRoleButtonDPS.checkButton:GetChecked());
end

function RaidFinderQueueFrameRewards_UpdateFrame()
	LFGRewardsFrame_UpdateFrame(RaidFinderQueueFrameScrollFrameChildFrame, RaidFinderQueueFrame.raid, RaidFinderQueueFrameBackground);
end

function RaidFinderFrameFindRaidButton_Update()
	local mode, subMode = GetLFGMode();
	if ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
		RaidFinderFrameFindRaidButton:SetText(LEAVE_QUEUE);
	else
		if ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
			RaidFinderFrameFindRaidButton:SetText(JOIN_AS_PARTY);
		else
			RaidFinderFrameFindRaidButton:SetText(FIND_A_GROUP);
		end
	end
	
	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "listed"  ) then --During the proposal, they must use the proposal buttons to leave the queue.
		if ( mode == "queued" or mode =="proposal" or mode == "rolecheck" or mode == "suspended" or not LFDQueueFramePartyBackfill:IsVisible() ) then
			RaidFinderFrameFindRaidButton:Enable();
		else
			RaidFinderFrameFindRaidButton:Disable();
		end
	else
		RaidFinderFrameFindRaidButton:Disable();
	end
end

