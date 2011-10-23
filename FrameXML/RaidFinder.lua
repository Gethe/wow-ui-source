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
	ButtonFrameTemplate_HideAttic(self:GetParent());
	self:GetParent().TitleText:SetText(RAID_FINDER);
	
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
		if ( isRaidFinderDungeonDisplayable(id) ) then
			local isAvailable = IsLFGDungeonJoinable(id);
			if ( isAvailable ) then
				info.text = name;
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
				info.text = name;
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
	RaidFinderQueueFrameRewards_UpdateFrame();
end

function isRaidFinderDungeonDisplayable(id)
	return true;
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
	if ( not RaidFinderQueueFrame.raid ) then
		return;
	end
	
	LFGRewardsFrame_UpdateFrame(RaidFinderQueueFrameScrollFrameChildFrame, RaidFinderQueueFrame.raid, RaidFinderQueueFrameBackground);
end