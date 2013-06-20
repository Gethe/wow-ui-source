function FlexRaidFrame_Update(dungeonID)
	local frame = FlexRaidFrame.ScrollFrame.Child
	local dungeonName, typeID, subtypeID, _,_,_,_,_,_,_, textureFilename,
		  difficulty, _, dungeonDescription, isHoliday, bonusRepAmount = GetLFGDungeonInfo(dungeonID);
	local backgroundTexture;
	
	if ( textureFilename ~= "" ) then
		if ( subtypeID == LFG_SUBTYPEID_RAID or subtypeID == LFG_SUBTYPEID_FLEXRAID ) then
			backgroundTexture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-"..textureFilename.."Q";
		else
			backgroundTexture = "Interface\\LFGFrame\\UI-LFG-HOLIDAY-BACKGROUND-"..textureFilename;
		end
	else
		backgroundTexture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER";
	end
	
	FlexRaidFrame.ScrollFrame.Background:SetTexture(backgroundTexture)
	frame.RaidTitle:SetText(dungeonName)
	frame.RaidDescription:SetText(dungeonDescription);
end

function FlexRaidFrameSelectionDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, FlexRaidFrameSelectionDropDown_Initialize);
	if ( FlexRaidFrame.raid ) then
		UIDropDownMenu_SetSelectedValue(FlexRaidFrameSelectionDropDown, FlexRaidFrame.raid);
	else
		UIDropDownMenu_SetText(self, "")
	end
end

function FlexRaidFrameSelectionDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	
	-- If we ever change this logic, we also need to change the logic in RaidFinderFrame_UpdateAvailability
	--for i=1, GetNumFlexRaidDungeons() do
	for i=1, GetNumRFDungeons() do
		--local id, name = GetFlexRaidDungeonInfo(i);
		local id, name = GetRFDungeonInfo(i);
		local isAvailable, isAvailableToPlayer = IsLFGDungeonJoinable(id);
		if ( isAvailable or isAvailableToPlayer or isRaidFinderDungeonDisplayable(id) ) then
			if ( isAvailable ) then
				info.text = name; --Note that the dropdown text may be manually changed in RaidFinderQueueFrame_SetRaid
				info.value = id;
				info.isTitle = nil;
				info.func = FlexRaidFrameSelectionDropDown_OnClick;
				info.disabled = nil;
				info.checked = (FlexRaidFrame.raid == info.value);
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

function FlexRaidFrameSelectionDropDown_OnClick(self)
	FlexRaidFrame_SetRaid(self.value);
end

function FlexRaidFrame_SetRaid(value)
	FlexRaidFrame.raid = value;
	UIDropDownMenu_SetSelectedValue(FlexRaidFrameSelectionDropDown, value);
	if ( value ) then
		local name = GetLFGDungeonInfo(value);
		UIDropDownMenu_SetText(FlexRaidFrameSelectionDropDown, name);
		FlexRaidFrame_Update(value)
	else
		UIDropDownMenu_SetText(FlexRaidFrameSelectionDropDown, "");
	end
end