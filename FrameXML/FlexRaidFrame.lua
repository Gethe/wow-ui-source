
function FlexRaidFrame_OnLoad(self)
	self:RegisterEvent("LFG_LOCK_INFO_RECEIVED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
end

function FlexRaidFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LOCK_INFO_RECEIVED" ) then
		FlexRaidFrame_ShowBest() 
		FlexRaidFrame_UpdateAvailability();
	elseif ( event == 	"GROUP_ROSTER_UPDATE" ) then
		FlexRaidFrame_UpdateButton()
	end
end

function FlexRaidFrame_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	FlexRaidFrame_UpdateAvailability();
	FlexRaidFrame_ShowBest();
	FlexRaidFrame_UpdateButton();
end

function FlexRaidFrame_ShowBest()
	if ( not FlexRaidFrame.raid or not IsLFGDungeonJoinable(FlexRaidFrame.raid) ) then
		FlexRaidFrame_SetRaid(GetBestFlexRaidChoice());
	end
end

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
	
	frame.Lockouts.dungeonID = dungeonID;
	local numEncounters, numCompleted = GetLFGDungeonNumEncounters(dungeonID);
	if ( numCompleted > 0 ) then
		frame.Lockouts:Show();
	else
		frame.Lockouts:Hide();
	end
end

function FlexRaidFrame_UpdateAvailability()
	--Update the cover panel for when flex raids are available to you, but you're between raid levels
	local available = false;
	local nextLevel = nil;
	local level = UnitLevel("player");
	for i=1, GetNumFlexRaidDungeons() do
		local id, name, typeID, subtype, minLevel, maxLevel = GetFlexRaidDungeonInfo(i);
		if ( level >= minLevel and level <= maxLevel ) then
			available = true;
			nextLevel = nil;
			break;
		elseif ( level < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
			nextLevel = minLevel;
		end
	end
	if ( available ) then
		FlexRaidFrame.NoRaidsCover:Hide();
	else
		FlexRaidFrame.NoRaidsCover:Show();
		if ( nextLevel ) then
			FlexRaidFrame.NoRaidsCover.Label:SetFormattedText(NO_RF_AVAILABLE_WITH_NEXT_LEVEL, nextLevel);
		else
			FlexRaidFrame.NoRaidsCover.Label:SetText(NO_RF_AVAILABLE);
		end
	end
end

function FlexRaidFrame_UpdateButton()
	local button = FlexRaidFrame.StartButton;
	button:Disable();
	button.tooltip = nil;
	
	if (not LFD_IsEmpowered()) then
		return;
	end
	
	local minPlayers, maxPlayers;
	if(FlexRaidFrame.raid) then
		local _
		_, _, _, _, _, _, _, _, _, _, _, _, maxPlayers, _, _, _, _, minPlayers = GetLFGDungeonInfo(FlexRaidFrame.raid);
	end
	
	local groupSize = GetNumGroupMembers();
	maxPlayers = maxPlayers or 0;
	minPlayers = minPlayers or 0;
	if (groupSize == 0 or not FlexRaidFrame.raid) then
		button.tooltip = PVP_NO_QUEUE_GROUP;
	elseif (groupSize >= minPlayers and groupSize <= maxPlayers) then
		button:Enable();
	else
		if (groupSize < minPlayers) then
			button.tooltip = format(FLEX_RAID_NEED_MORE, minPlayers - groupSize);
		else
			button.tooltip = format(FLEX_RAID_NEED_LESS, groupSize - maxPlayers);
		end
	end
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
	
	for i=1, GetNumFlexRaidDungeons() do
		local id, name = GetFlexRaidDungeonInfo(i);
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
	FlexRaidFrame_UpdateButton();
end

function FlexRaidFrame_Join()
	if ( FlexRaidFrame.raid ) then
		ClearAllLFGDungeons(LE_LFG_CATEGORY_FLEXRAID);
		SetLFGDungeon(LE_LFG_CATEGORY_FLEXRAID, FlexRaidFrame.raid);
		JoinLFG(LE_LFG_CATEGORY_FLEXRAID);
	end
end