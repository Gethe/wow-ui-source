GARRISON_FOLLOWER_BUSY_COLOR = { 0, 0.06, 0.22, 0.44 };
GARRISON_FOLLOWER_INACTIVE_COLOR = { 0.22, 0.06, 0, 0.44 };

local minFollowersForThreatCountersFrame = 10;

---------------------------------------------------------------------------------
--- Follower List                                                             ---
---------------------------------------------------------------------------------
function GarrisonFollowerList_ScrollListUpdate(self)
	GarrisonFollowerList_Update(self.followerFrame);
end

function GarrisonFollowerList_OnLoad(self)
	self.FollowerList.followers = { };
	self.FollowerList.followersList = { };
	GarrisonFollowerList_DirtyList(self.FollowerList);

	self.FollowerList.listScroll.update = GarrisonFollowerList_ScrollListUpdate;
	self.FollowerList.listScroll.dynamic = function(offset) return GarrisonFollowerList_GetTopButton(self, offset); end;
	HybridScrollFrame_CreateButtons(self.FollowerList.listScroll, "GarrisonMissionFollowerButtonTemplate", 7, -7, nil, nil, nil, -6);
	self.FollowerList.listScroll.followerFrame = self;

	GarrisonFollowerList_Update(self);

	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_REMOVED");
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self:RegisterEvent("GARRISON_FOLLOWER_UPGRADED");
end

function GarrisonFollowerList_OnShow(self)
	GarrisonFollowerList_DirtyList(self);
	GarrisonFollowerList_UpdateFollowers(self);
	-- if there's no follower displayed in the tab, select the first one
	local followerTab = self:GetParent().FollowerTab;
	if (followerTab and not followerTab.followerID) then
		local index = self.followersList[1];
		if (index) then
			GarrisonFollowerPage_ShowFollower(followerTab, self.followers[index].followerID);
		else
			-- empty page
			GarrisonFollowerPage_ShowFollower(followerTab,0);
		end
	end
	if (C_Garrison.GetNumFollowers() >= minFollowersForThreatCountersFrame) then
		GarrisonThreatCountersFrame:Show();
	end
end

function GarrisonFollowerList_OnHide(self)
	self.followers = nil;
end

function GarrisonFollowerList_OnEvent(self, event, ...)
	if (event == "GARRISON_FOLLOWER_LIST_UPDATE" or event == "GARRISON_FOLLOWER_XP_CHANGED") then
		if (self.FollowerTab and self.FollowerTab.followerID) then
			GarrisonFollowerPage_ShowFollower(self.FollowerTab, self.FollowerTab.followerID);
		end
		
		GarrisonFollowerList_DirtyList(self.FollowerList);
		GarrisonFollowerList_UpdateFollowers(self.FollowerList);

		if (C_Garrison.GetNumFollowers() >= minFollowersForThreatCountersFrame) then
			GarrisonThreatCountersFrame:Show();
		end

		GarrisonThreatCountersFrame:Show();
		return true;
	elseif (event == "GARRISON_FOLLOWER_REMOVED") then
		if (self.FollowerTab and self.FollowerTab.followerID and not C_Garrison.GetFollowerInfo(self.FollowerTab.followerID) and self.FollowerList.followers) then
			-- viewed follower got removed, pick someone else
			local index = self.FollowerList.followersList[1];
			if (index and self.FollowerList.followers[index].followerID ~= self.FollowerTab.followerID) then
				GarrisonFollowerPage_ShowFollower(self.FollowerTab, self.FollowerList.followers[index].followerID);
			else
				-- try the 2nd follower
				index = self.FollowerList.followersList[2];
				if (index) then
					GarrisonFollowerPage_ShowFollower(self.FollowerTab, self.FollowerList.followers[index].followerID);
				else
					-- empty page
					GarrisonFollowerPage_ShowFollower(self.FollowerTab, 0);
				end
			end
		end
		GarrisonFollowerList_DirtyList(self.FollowerList);
		return true;
	elseif (event == "GARRISON_FOLLOWER_UPGRADED") then
		if ( self.FollowerTab and self.FollowerTab.Model and self.FollowerTab:IsVisible() ) then
			local followerID = ...;
			if ( followerID == self.FollowerTab.Model.followerID ) then
				self.FollowerTab.Model:SetSpellVisualKit(6375);	-- level up visual
				PlaySound("UI_Garrison_CommandTable_Follower_LevelUp");
			end
		end
	end

	return false;
end

function GarrisonFollowListEditBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	GarrisonFollowerList_UpdateFollowers(self:GetParent());
end

function GarrisonFollowerList_UpdateFollowers(self)
	local followerList = self;
	if ( followerList.dirtyList ) then
		followerList.followers = C_Garrison.GetFollowers();
		followerList.dirtyList = nil;
	end
	followerList.followersList = { };

	local searchString = followerList.SearchBox:GetText();
	
	for i = 1, #followerList.followers do
		if ( (self.followers[i].isCollected or self.showUncollected) and (searchString == "" or C_Garrison.SearchForFollower(self.followers[i].followerID, searchString)) ) then
			tinsert(self.followersList, i);
		end
	end

	local followerTab = self:GetParent().FollowerTab;
	if ( followerTab ) then
		local maxFollowers = C_Garrison.GetFollowerSoftCap();
		local numActiveFollowers = C_Garrison.GetNumActiveFollowers();
		if ( self.isLandingPage ) then
			local countColor = HIGHLIGHT_FONT_COLOR_CODE;
			if ( numActiveFollowers > maxFollowers ) then
				countColor = RED_FONT_COLOR_CODE;
			end
			self:GetParent().FollowerTab.NumFollowers:SetText(countColor..numActiveFollowers.."/"..maxFollowers..FONT_COLOR_CODE_CLOSE);
		else
			local countColor = NORMAL_FONT_COLOR_CODE;
			if ( numActiveFollowers > maxFollowers ) then
				countColor = RED_FONT_COLOR_CODE;
			end
			self:GetParent().FollowerTab.NumFollowers:SetText(format(GARRISON_FOLLOWER_COUNT, countColor, numActiveFollowers, maxFollowers, FONT_COLOR_CODE_CLOSE));
		end
	end

	GarrisonFollowerList_SortFollowers(self);
	GarrisonFollowerList_Update(self:GetParent());
end

function GarrisonFollowerList_GetTopButton(self, offset)
	local followerFrame = self.FollowerList;
	local buttonHeight = followerFrame.listScroll.buttonHeight;
	local expandedFollower = followerFrame.expandedFollower;
	local followers = followerFrame.followers;
	local sortedList = followerFrame.followersList;
	local totalHeight = 0;
	for i = 1, #sortedList do
		local height;
		if ( followers[sortedList[i]].followerID == expandedFollower ) then
			height = followerFrame.expandedFollowerHeight;
		else
			height = buttonHeight;
		end
		totalHeight = totalHeight + height;
		if ( totalHeight > offset ) then
			return i - 1, height + offset - totalHeight;
		end
	end

	--We're scrolled completely off the bottom
	return #followers, 0;
end

function GarrisonFollowerList_Update(self)
	local followerFrame = self;
	local followers = followerFrame.FollowerList.followers;
	local followersList = followerFrame.FollowerList.followersList;
	local numFollowers = #followersList;
	local scrollFrame = followerFrame.FollowerList.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local showCounters = followerFrame.FollowerList.showCounters;
	local canExpand = followerFrame.FollowerList.canExpand;
	local mentorLevel = GarrisonMissionFrame and GarrisonMissionFrame.MissionTab.MissionPage.mentorLevel or 0;
	local mentorItemLevel = GarrisonMissionFrame and GarrisonMissionFrame.MissionTab.MissionPage.mentorItemLevel or 0;
					
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numFollowers ) then
			local follower = followers[followersList[index]];
			button.id = follower.followerID;
			button.info = follower;
			button.Name:SetText(follower.name);
			button.Class:SetAtlas(follower.classAtlas);
			button.Status:SetText(follower.status);
			if ( follower.status == GARRISON_FOLLOWER_INACTIVE ) then
				button.Status:SetTextColor(1, 0.1, 0.1);
			else
				button.Status:SetTextColor(0.698, 0.941, 1);
			end
			local color = ITEM_QUALITY_COLORS[follower.quality];
			button.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
			button.PortraitFrame.Level:SetText(follower.level);
			GarrisonFollowerPortrait_Set(button.PortraitFrame.Portrait, follower.portraitIconID);
			if ( follower.isCollected ) then
				-- have this follower
				button.isCollected = true;
				button.Name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				button.Class:SetDesaturated(false);
				button.Class:SetAlpha(0.2);
				button.PortraitFrame.PortraitRingQuality:Show();
				button.PortraitFrame.PortraitRingQuality:SetVertexColor(color.r, color.g, color.b);
				button.PortraitFrame.Portrait:SetDesaturated(false);
				if ( follower.status == GARRISON_FOLLOWER_INACTIVE ) then
					button.PortraitFrame.PortraitRingCover:Show();
					button.PortraitFrame.PortraitRingCover:SetAlpha(0.5);
					button.BusyFrame:Show();
					button.BusyFrame.Texture:SetTexture(unpack(GARRISON_FOLLOWER_INACTIVE_COLOR));
				elseif ( follower.status ) then
					button.PortraitFrame.PortraitRingCover:Show();
					button.PortraitFrame.PortraitRingCover:SetAlpha(0.5);
					button.BusyFrame:Show();
					button.BusyFrame.Texture:SetTexture(unpack(GARRISON_FOLLOWER_BUSY_COLOR));
					-- get time remaining for follower
					if ( follower.status == GARRISON_FOLLOWER_ON_MISSION ) then
						if (follower.level == GARRISON_FOLLOWER_MAX_LEVEL) then
							button.Status:SetText(C_Garrison.GetFollowerMissionTimeLeft(follower.followerID));
						else
							button.Status:SetFormattedText(GARRISON_FOLLOWER_ON_MISSION_WITH_DURATION, C_Garrison.GetFollowerMissionTimeLeft(follower.followerID));
						end
					end
				else
					button.PortraitFrame.PortraitRingCover:Hide();
					button.BusyFrame:Hide();
				end
				if ( canExpand ) then
					button.DownArrow:SetAlpha(1);
				else
					button.DownArrow:SetAlpha(0);
				end
				-- adjust text position if we have additional text to show below name
				if (follower.level == GARRISON_FOLLOWER_MAX_LEVEL or follower.status) then
					button.Name:SetPoint("LEFT", button.PortraitFrame, "LEFT", 66, 8);
				else
					button.Name:SetPoint("LEFT", button.PortraitFrame, "LEFT", 66, 0);
				end
				-- show iLevel for max level followers	
				if (follower.level == GARRISON_FOLLOWER_MAX_LEVEL) then
					button.ILevel:SetText(ITEM_LEVEL_ABBR.." "..follower.iLevel);
					button.Status:SetPoint("TOPLEFT", button.ILevel, "TOPRIGHT", 4, 0);
				else
					button.ILevel:SetText(nil);
					button.Status:SetPoint("TOPLEFT", button.ILevel, "TOPRIGHT", 0, 0);
				end
				if (follower.xp == 0 or follower.levelXP == 0) then 
					button.XPBar:Hide();
				else
					button.XPBar:Show();
					button.XPBar:SetWidth((follower.xp/follower.levelXP) * GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH);
				end
			else
				-- don't have this follower
				button.isCollected = nil;
				button.Name:SetTextColor(0.25, 0.25, 0.25);
				button.ILevel:SetText(nil);
				button.Status:SetPoint("TOPLEFT", button.ILevel, "TOPRIGHT", 0, 0);
				button.Class:SetDesaturated(true);
				button.Class:SetAlpha(0.1);
				button.PortraitFrame.PortraitRingQuality:Hide();
				button.PortraitFrame.Portrait:SetDesaturated(true);
				button.PortraitFrame.PortraitRingCover:Show();
				button.PortraitFrame.PortraitRingCover:SetAlpha(0.6);
				button.XPBar:Hide();
				button.DownArrow:SetAlpha(0);
				button.BusyFrame:Hide();
			end

			GarrisonFollowerButton_UpdateCounters(button, follower, showCounters);

			if (canExpand and button.id == followerFrame.FollowerList.expandedFollower and button.id == followerFrame.selectedFollower) then
				GarrisonFollowerButton_Expand(button, followerFrame.FollowerList);
			else
				GarrisonFollowerButton_Collapse(button);
			end
			if ( button.id == followerFrame.selectedFollower ) then
				button.Selection:Show();
			else
				button.Selection:Hide();
			end
			button:Show();
		else
			button:Hide();
		end
	end

	local extraHeight = 0;
	if ( followerFrame.FollowerList.expandedFollower ) then
		extraHeight = followerFrame.FollowerList.expandedFollowerHeight - scrollFrame.buttonHeight;
	else
		extraHeight = 0;
	end
	local totalHeight = numFollowers * scrollFrame.buttonHeight + extraHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GarrisonFollowerButton_UpdateCounters(button, follower, showCounters)
	local numShown = 0;
	if ( showCounters and button.isCollected and follower.status ~= GARRISON_FOLLOWER_INACTIVE ) then
		--if a mission is being viewed, show mechanics this follower can counter
		--for followers you have, show counters if they are or could be on the mission
		local counters = GarrisonMissionFrame.followerCounters and GarrisonMissionFrame.followerCounters[follower.followerID];
		if ( counters ) then
			for i = 1, #counters do
				-- max of 4 icons
				if ( numShown == 4 ) then
					break;
				end			
				numShown = numShown + 1;
				GarrisonFollowerButton_SetCounterButton(button, numShown, counters[i]);
			end
		end
		local traits = GarrisonMissionFrame.followerTraits and GarrisonMissionFrame.followerTraits[follower.followerID];
		if ( traits ) then
			for i = 1, #traits do
				-- max of 4 icons
				if ( numShown == 4 ) then
					break;
				end
				numShown = numShown + 1;
				GarrisonFollowerButton_SetCounterButton(button, numShown, traits[i]);
			end
		end
	end
	if ( numShown == 1 or numShown == 2 ) then
		button.Counters[1]:SetPoint("TOPRIGHT", -8, -16);
	else
		button.Counters[1]:SetPoint("TOPRIGHT", -8, -4);
	end
	for i = numShown + 1, #button.Counters do
		button.Counters[i].info = nil;
		button.Counters[i]:Hide();
	end
end

function GarrisonFollowerButton_SetCounterButton(button, index, info)
	local counter = button.Counters[index];
	if ( not counter ) then
		button.Counters[index] = CreateFrame("Frame", nil, button, "GarrisonMissionAbilityCounterTemplate");
		if (index % 2 == 0) then
			button.Counters[index]:SetPoint("RIGHT", button.Counters[index-1], "LEFT", -6, 0);
		else
			button.Counters[index]:SetPoint("TOP", button.Counters[index-2], "BOTTOM", 0, -6);
		end
		counter = button.Counters[index];
	end
	counter.info = info;
	counter.Icon:SetTexture(info.icon);
	if ( info.traitID ) then
		counter.tooltip = nil;
		counter.info.showCounters = false;
		counter.Border:Hide();
	else
		counter.tooltip = info.name;
		counter.info.showCounters = true;
		counter.Border:Show();
	end
	counter:Show();
end

function GarrisonFollowerButton_Expand(self, followerListFrame)
	if ( not self.isCollected ) then
		return;
	end

	self.UpArrow:Show();
	self.DownArrow:Hide();
	local abHeight = 0;
	if (not self.info.abilities) then
		self.info.abilities = C_Garrison.GetFollowerAbilities(self.info.followerID);
	end

	local buttonCount = 0;
	-- abilities
	for i=1, #self.info.abilities do
		if ( not self.info.abilities[i].isTrait ) then
			buttonCount = buttonCount + 1;
			abHeight = abHeight + GarrisonFollowerButton_AddAbility(self, buttonCount, self.info.abilities[i]);			
		end
	end
	-- traits
	for i=1, #self.info.abilities do
		if ( self.info.abilities[i].isTrait ) then
			buttonCount = buttonCount + 1;
			abHeight = abHeight + GarrisonFollowerButton_AddAbility(self, buttonCount, self.info.abilities[i]);			
		end
	end

	for i=(#self.info.abilities + 1), #self.Abilities do
		self.Abilities[i]:Hide();
	end
	if (abHeight > 0) then
		abHeight = abHeight + 8;
		self.AbilitiesBG:Show();
		self.AbilitiesBG:SetHeight(abHeight);
	else
		self.AbilitiesBG:Hide();
	end
	self:SetHeight(51 + abHeight);
	followerListFrame.expandedFollowerHeight = 51 + abHeight + 6;
end

function GarrisonFollowerButton_AddAbility(self, index, ability)
	if (not self.Abilities[index]) then
		self.Abilities[index] = CreateFrame("Frame", nil, self, "GarrisonFollowerListButtonAbilityTemplate");
		self.Abilities[index]:SetPoint("TOPLEFT", self.Abilities[index-1], "BOTTOMLEFT", 0, -2);
	end
	local Ability = self.Abilities[index];
	Ability.abilityID = ability.id;
	Ability.Name:SetText(ability.name);
	Ability.Icon:SetTexture(ability.icon);
	Ability.tooltip = ability.description;
	Ability:Show();
	return Ability:GetHeight() + 3;
end

function GarrisonFollowerButton_Collapse(self)
	self.UpArrow:Hide();
	self.DownArrow:Show();
	self.AbilitiesBG:Hide();
	for i=1, #self.Abilities do
		self.Abilities[i]:Hide();
	end
	self:SetHeight(56);
end

function GarrisonFollowerListButton_OnClick(self, button)
	local followerFrame = self:GetParent():GetParent().followerFrame;
	if ( button == "LeftButton" ) then
		PlaySound("UI_Garrison_CommandTable_SelectFollower");
		followerFrame.selectedFollower = self.id;

		if ( self.isCollected and followerFrame.FollowerList.canCastSpellsOnFollowers and SpellCanTargetGarrisonFollower() ) then
			GarrisonFollower_DisplayUpgradeConfirmation(self.id);
		end
		
		if ( followerFrame.FollowerList.canExpand ) then
			if ( self.isCollected ) then
				if (followerFrame.FollowerList.expandedFollower == self.id) then
					followerFrame.FollowerList.expandedFollower = nil;
					PlaySound("UI_Garrison_CommandTable_FollowerAbilityClose");
				else
					followerFrame.FollowerList.expandedFollower = self.id;
					-- expand button now to get height
					GarrisonFollowerButton_Expand(self, followerFrame.FollowerList);
					PlaySound("UI_Garrison_CommandTable_FollowerAbilityOpen");
				end
			else
				followerFrame.FollowerList.expandedFollower = nil;
				PlaySound("UI_Garrison_CommandTable_FollowerAbilityClose");
			end
		else
			if ( not followerFrame.FollowerList.canExpand and followerFrame.FollowerList.expandedFollower ~= self.id ) then
				followerFrame.FollowerList.expandedFollower = nil;
			end
		end
		GarrisonFollowerList_Update(followerFrame);
		if ( followerFrame.FollowerTab ) then
			GarrisonFollowerPage_ShowFollower(followerFrame.FollowerTab, self.id);
		end
		CloseDropDownMenus();
	-- Don't show right click follower menu in landing page
	elseif ( button == "RightButton" and not self:GetParent():GetParent():GetParent().isLandingPage) then
		if ( self.isCollected ) then
			if ( GarrisonFollowerOptionDropDown.followerID ~= self.id ) then
				CloseDropDownMenus();
			end
			GarrisonFollowerOptionDropDown.followerID = self.id;
			ToggleDropDownMenu(1, nil, GarrisonFollowerOptionDropDown, "cursor", 0, 0);
		else
			GarrisonFollowerOptionDropDown.followerID = nil;
			CloseDropDownMenus();
		end
	end
end

function GarrisonFollowerListButton_OnModifiedClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local followerLink;
		if (self.info.isCollected) then
			followerLink = C_Garrison.GetFollowerLink(self.info.followerID);
		else
			followerLink = C_Garrison.GetFollowerLinkByID(self.info.followerID);
		end
		
		if ( followerLink ) then
			ChatEdit_InsertLink(followerLink);
		end
	end
end

---------------------------------------------------------------------------------
--- Follower filtering and searching                                          ---
---------------------------------------------------------------------------------
function GarrisonFollowerList_DirtyList(self)
	self.dirtyList = true;
end

local statusPriority = {
	[GARRISON_FOLLOWER_IN_PARTY] = 1,
	[GARRISON_FOLLOWER_WORKING] = 2,
	[GARRISON_FOLLOWER_ON_MISSION] = 3,
	[GARRISON_FOLLOWER_EXHAUSTED] = 4,
	[GARRISON_FOLLOWER_INACTIVE] = 5,
}

function GarrisonFollowerList_SortFollowers(self)
	local followers = self.followers;
	local followerCounters = GarrisonMissionFrame.followerCounters;
	local followerTraits = GarrisonMissionFrame.followerTraits;
	local checkAbilities = followerCounters and followerTraits and GarrisonMissionFrame.MissionTab:IsVisible();
	local mentorLevel, mentorItemLevel = 0, 0;
	if ( checkAbilities ) then
		mentorLevel = GarrisonMissionFrame.MissionTab.MissionPage.mentorLevel or 0;
		mentorItemLevel = GarrisonMissionFrame.MissionTab.MissionPage.mentorItemLevel or 0;
	end
	local comparison = function(index1, index2)
		local follower1 = followers[index1];
		local follower2 = followers[index2];

		if ( follower1.isCollected ~= follower2.isCollected ) then
			return follower1.isCollected;
		end
		
		-- treat IN_PARTY status as no status
		local status1 = follower1.status;
		if ( status1 == GARRISON_FOLLOWER_IN_PARTY ) then
			status1 = nil;
		end
		local status2 = follower2.status;
		if ( status2 == GARRISON_FOLLOWER_IN_PARTY ) then
			status2 = nil;
		end		
		if ( status1 and not status2 ) then
			return false;
		elseif ( not status1 and status2 ) then
			return true;
		end

		if ( status1 ~= status2 ) then
			return statusPriority[status1] < statusPriority[status2];
		end

		-- sorting: level > item level > (num counters for mission) > (num traits for mission) > quality > name
		local follower1Level = max(follower1.level, mentorLevel);
		local follower2Level = max(follower2.level, mentorLevel);
		if ( follower1Level ~= follower2Level ) then
			return follower1Level > follower2Level;
		end
		local follower1ItemLevel = max(follower1.iLevel, mentorItemLevel);
		local follower2ItemLevel = max(follower2.iLevel, mentorItemLevel);
		if ( follower1Level == GARRISON_FOLLOWER_MAX_LEVEL and follower1ItemLevel ~= follower2ItemLevel ) then		-- only checking follower 1 because follower 2 has same level at this point
			return follower1ItemLevel > follower2ItemLevel;
		end
		if ( checkAbilities and not status1 and follower1.isCollected ) then		-- only checking follower 1 because follower 2 has same status and collected-ness at this point
			local numCounters1 = followerCounters[follower1.followerID] and #followerCounters[follower1.followerID] or 0;
			local numCounters2 = followerCounters[follower2.followerID] and #followerCounters[follower2.followerID] or 0;
			if ( numCounters1 ~= numCounters2 ) then
				return numCounters1 > numCounters2;
			end
			local numTraits1 = followerTraits[follower1.followerID] and #followerTraits[follower1.followerID] or 0;
			local numTraits2 = followerTraits[follower2.followerID] and #followerTraits[follower2.followerID] or 0;
			if ( numTraits1 ~= numTraits2 ) then
				return numTraits1 > numTraits2;
			end
		end
		if ( follower1.quality ~= follower2.quality ) then
			return follower1.quality > follower2.quality;
		end
		return strcmputf8i(follower1.name, follower2.name) < 0;
	end

	table.sort(self.followersList, comparison);
end

---------------------------------------------------------------------------------
--- Models                                                                    ---
---------------------------------------------------------------------------------
function GarrisonMission_SetFollowerModel(modelFrame, followerID, displayID)
	if ( not displayID or displayID == 0 ) then
		modelFrame:ClearModel();
		modelFrame:Hide();
		modelFrame.followerID = nil;
	else
		modelFrame:Show();
		modelFrame:SetDisplayInfo(displayID);
		modelFrame.followerID = followerID;
		GarrisonMission_SetFollowerModelItems(modelFrame);
	end
end

function GarrisonMission_SetFollowerModelItems(modelFrame)
	if ( modelFrame.followerID ) then
		modelFrame:UnequipItems();
		local follower =  C_Garrison.GetFollowerInfo(modelFrame.followerID);
		if ( follower and follower.isCollected ) then
			local modelItems = C_Garrison.GetFollowerModelItems(modelFrame.followerID);
			for i = 1, #modelItems do
				modelFrame:EquipItem(modelItems[i]);
			end
		end
	end
end

function GarrisonCinematicModelBase_OnLoad(self)
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function GarrisonCinematicModelBase_OnEvent(self)
	self:RefreshCamera();
end

---------------------------------------------------------------------------------
--- Follower Page                                                             ---
---------------------------------------------------------------------------------
GARRISON_FOLLOWER_PAGE_HEIGHT_MULTIPLIER = .65;
GARRISON_FOLLOWER_PAGE_SCALE_MULTIPLIER = 1.3

function GarrisonFollowerPageItemButton_OnEvent(self, event)
	if ( not self:IsShown() and self.itemID ) then
		GarrisonFollowerPage_SetItem(self, self.itemID, self.itemLevel);
	end
end

function GarrisonFollowerPage_SetItem(itemFrame, itemID, itemLevel)
	if ( itemID and itemID > 0 ) then
		itemFrame.itemID = itemID;
		itemFrame.itemLevel = itemLevel;
		local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID);
		if ( itemName ) then
			itemFrame.Icon:SetTexture(itemTexture);
			itemFrame.Name:SetTextColor(GetItemQualityColor(itemQuality));
			itemFrame.ItemLevel:SetFormattedText(GARRISON_FOLLOWER_ITEM_LEVEL, itemLevel);
			itemFrame:Show();			
			return;
		end
	else
		itemFrame.itemID = nil;
		itemFrame.itemLevel = nil;
	end
	itemFrame:Hide();
end

function GarrisonFollowerPage_ShowFollower(self, followerID)
	local followerInfo = C_Garrison.GetFollowerInfo(followerID);

	if (followerInfo) then
		self.followerID = followerID;
		self.NoFollowersLabel:Hide();
		self.PortraitFrame:Show();
		self.Model:SetAlpha(0);
		GarrisonMission_SetFollowerModel(self.Model, followerInfo.followerID, followerInfo.displayID);
		if (followerInfo.displayHeight) then
			self.Model:SetHeightFactor(followerInfo.displayHeight);
		end
		if (followerInfo.displayScale) then
			self.Model:InitializeCamera(followerInfo.displayScale);
		end		
	else
		self.followerID = nil;
		self.NoFollowersLabel:Show();
		followerInfo = { };
		followerInfo.quality = 1;
		followerInfo.abilities = { };
		self.PortraitFrame:Hide();
		self.Model:ClearModel();
	end

	GarrisonFollowerPageModelUpgrade_Update(self.Model.UpgradeFrame);
	GarrisonMissionFrame_SetFollowerPortrait(self.PortraitFrame, followerInfo);
	self.Name:SetText(followerInfo.name);
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];	
	self.Name:SetVertexColor(color.r, color.g, color.b);
	self.ClassSpec:SetText(followerInfo.className);
	self.Class:SetAtlas(followerInfo.classAtlas);
	if ( followerInfo.isCollected ) then
		-- Follower cannot be upgraded anymore
		if (followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL and followerInfo.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY) then
			self.XPLabel:Hide();
			self.XPBar:Hide();
			self.XPText:Hide();
			self.XPText:SetText("");
		else
			if (followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL) then
				self.XPLabel:SetText(GARRISON_FOLLOWER_XP_UPGRADE_STRING);
			else
				self.XPLabel:SetText(GARRISON_FOLLOWER_XP_STRING);
			end
			self.XPLabel:SetWidth(0);
			self.XPLabel:SetFontObject("GameFontHighlight");
			self.XPLabel:SetPoint("TOPRIGHT", self.XPText, "BOTTOMRIGHT", 0, -4);
			self.XPLabel:Show();
			-- If the XPLabel text does not fit within 100 pixels, shrink the font. If it wraps to 2 lines, move the text up.
			if (self.XPLabel:GetWidth() > 100) then
				self.XPLabel:SetWidth(100);
				self.XPLabel:SetFontObject("GameFontWhiteSmall");
				if (self.XPLabel:GetNumLines() > 1) then
					self.XPLabel:SetPoint("TOPRIGHT", self.XPText, "BOTTOMRIGHT", -1, 0);
				end
			end
			self.XPBar:Show();
			self.XPBar:SetMinMaxValues(0, followerInfo.levelXP);
			self.XPBar.Label:SetFormattedText(GARRISON_FOLLOWER_XP_BAR_LABEL, BreakUpLargeNumbers(followerInfo.xp), BreakUpLargeNumbers(followerInfo.levelXP));
			self.XPBar:SetValue(followerInfo.xp);
			local xpLeft = followerInfo.levelXP - followerInfo.xp;
			self.XPText:SetText(format(GARRISON_FOLLOWER_XP_LEFT, xpLeft));
			self.XPText:Show();
		end
	else
		self.XPText:Hide();
		self.XPLabel:Hide();
		self.XPBar:Hide();
	end
	GarrisonTruncationFrame_Check(self.Name);

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		self.QualityFrame:Show();
		self.QualityFrame.Text:SetText(_G["ITEM_QUALITY"..followerInfo.quality.."_DESC"]);
	else
		self.QualityFrame:Hide();
	end

	self.AbilitiesFrame.TraitsText:ClearAllPoints();
	if (not followerInfo.abilities) then
		followerInfo.abilities = C_Garrison.GetFollowerAbilities(followerID);
	end
	local lastAbilityAnchor, lastTraitAnchor;
	local numCounters = 0;

	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i];

		local abilityFrame = self.AbilitiesFrame.Abilities[i];
		if ( not abilityFrame ) then
			abilityFrame = CreateFrame("Frame", nil, self.AbilitiesFrame, "GarrisonFollowerPageAbilityTemplate");
			self.AbilitiesFrame.Abilities[i] = abilityFrame;
		end

		if ( self.isLandingPage ) then
			abilityFrame.Description:SetText("");
			abilityFrame.Name:SetFontObject("GameFontHighlightMed2");
			abilityFrame.Name:ClearAllPoints();
			abilityFrame.Name:SetPoint("LEFT", abilityFrame.IconButton, "RIGHT", 8, 0);
			abilityFrame.Name:SetWidth(150);
		else
			abilityFrame.Description:SetText(ability.description);
			abilityFrame.Name:SetFontObject("GameFontNormalLarge2");
			abilityFrame.Name:ClearAllPoints();
			abilityFrame.Name:SetPoint("TOPLEFT", abilityFrame.IconButton, "TOPRIGHT", 8, 0);
			abilityFrame.Name:SetWidth(0);
		end
		abilityFrame.Name:SetText(ability.name);
		abilityFrame.IconButton.Icon:SetTexture(ability.icon);
		abilityFrame.IconButton.abilityID = ability.id;

		local hasCounters = false;
		if ( ability.counters and not ability.isTrait and not self.isLandingPage ) then
			for id, counter in pairs(ability.counters) do
				numCounters = numCounters + 1;
				local counterFrame = self.AbilitiesFrame.Counters[numCounters];
				if ( not counterFrame ) then
					counterFrame = CreateFrame("Frame", nil, self.AbilitiesFrame, "GarrisonMissionMechanicTemplate");
					self.AbilitiesFrame.Counters[numCounters] = counterFrame;
				end
				counterFrame.Icon:SetTexture(counter.icon);
				counterFrame.tooltip = counter.name;
				counterFrame:ClearAllPoints();
				if ( hasCounters ) then			
					counterFrame:SetPoint("LEFT", self.AbilitiesFrame.Counters[numCounters - 1], "RIGHT", 10, 0);
				else
					counterFrame:SetPoint("LEFT", abilityFrame.CounterString, "RIGHT", 2, -2);
				end
				counterFrame:Show();
				counterFrame.info = counter;
				hasCounters = true;
			end
		end
		if ( hasCounters ) then
			abilityFrame.CounterString:Show();
		else
			abilityFrame.CounterString:Hide();
		end
		-- anchor ability
		if ( ability.isTrait ) then
			lastTraitAnchor = GarrisonFollowerPage_AnchorAbility(abilityFrame, lastTraitAnchor, self.AbilitiesFrame.TraitsText, hasCounters);
		else
			lastAbilityAnchor = GarrisonFollowerPage_AnchorAbility(abilityFrame, lastAbilityAnchor, self.AbilitiesFrame.AbilitiesText, hasCounters);
		end
		abilityFrame:Show();
	end

	if ( lastAbilityAnchor ) then
		self.AbilitiesFrame.AbilitiesText:Show();
	else
		self.AbilitiesFrame.AbilitiesText:Hide();
	end
	if ( lastTraitAnchor ) then
		self.AbilitiesFrame.TraitsText:Show();
		if ( lastAbilityAnchor ) then
			self.AbilitiesFrame.TraitsText:SetPoint("LEFT", self.AbilitiesFrame.AbilitiesText, "LEFT");
			if ( self.isLandingPage ) then
				self.AbilitiesFrame.TraitsText:SetPoint("TOP", lastAbilityAnchor, "BOTTOM", 0, -24);
			else
				self.AbilitiesFrame.TraitsText:SetPoint("TOP", lastAbilityAnchor, "BOTTOM", 0, -16);
			end
		else
			self.AbilitiesFrame.TraitsText:SetPoint("TOPLEFT", self.AbilitiesFrame.AbilitiesText, "TOPLEFT");
		end
	else
		self.AbilitiesFrame.TraitsText:Hide();
	end
	
	for i = #followerInfo.abilities + 1, #self.AbilitiesFrame.Abilities do
		self.AbilitiesFrame.Abilities[i]:Hide();
	end
	for i = numCounters + 1, #self.AbilitiesFrame.Counters do
		self.AbilitiesFrame.Counters[i]:Hide();
	end
	
	-- gear	/ source
	if ( followerInfo.isCollected and not self.isLandingPage ) then
		local weaponItemID, weaponItemLevel, armorItemID, armorItemLevel = C_Garrison.GetFollowerItems(followerInfo.followerID);
		GarrisonFollowerPage_SetItem(self.ItemWeapon, weaponItemID, weaponItemLevel);
		GarrisonFollowerPage_SetItem(self.ItemArmor, armorItemID, armorItemLevel);
		if ( followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL ) then
			self.ItemAverageLevel.Level:SetText(ITEM_LEVEL_ABBR .. " " .. followerInfo.iLevel);
			self.ItemAverageLevel.Level:Show();
		else
			self.ItemWeapon:Hide();
			self.ItemArmor:Hide();
			self.ItemAverageLevel.Level:Hide();
		end
		self.Source.SourceText:Hide();
	else
		self.ItemWeapon:Hide();
		self.ItemArmor:Hide();
		self.ItemAverageLevel.Level:Hide();		

		self.Source.SourceText:SetText(C_Garrison.GetFollowerSourceTextByID(followerID));		
		self.Source.SourceText:Show();
	end	
end

function GarrisonFollowerPage_AnchorAbility(abilityFrame, lastAnchor, headerString, hasCounters)
	abilityFrame:ClearAllPoints();
	if ( lastAnchor ) then
		abilityFrame:SetPoint("LEFT", lastAnchor:GetParent());
		abilityFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -16);			
	else
		abilityFrame:SetPoint("TOPLEFT", headerString, "BOTTOMLEFT", 2, -12);
	end
	if ( hasCounters ) then
		return abilityFrame.CounterString;
	else
		return abilityFrame.Description;
	end
end

function GarrisonFollowerPageModel_OnMouseDown(self, button)
	local followerList = self:GetParent():GetParent().FollowerList;
	if ( button == "LeftButton" and followerList.canCastSpellsOnFollowers and SpellCanTargetGarrisonFollower() ) then
		-- no rotation if you can upgrade this follower
		local followerID = self.followerID;
		local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
		if ( followerInfo and followerInfo.isCollected and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION ) then
			return;
		end
	end
	Model_OnMouseDown(self, button);
end

function GarrisonFollowerPageModel_OnMouseUp(self, button)
	local followerList = self:GetParent():GetParent().FollowerList;
	if ( button == "LeftButton" and followerList.canCastSpellsOnFollowers and SpellCanTargetGarrisonFollower() ) then
		-- no rotation if you can upgrade this follower, bring up confirmation dialog
		local followerID = self.followerID;
		local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
		if ( followerInfo and followerInfo.isCollected and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION ) then
			local name = ITEM_QUALITY_COLORS[followerInfo.quality].hex..followerInfo.name..FONT_COLOR_CODE_CLOSE;
			StaticPopup_Show("CONFIRM_FOLLOWER_UPGRADE", name, nil, self.followerID);
			return;
		end
	end
	Model_OnMouseUp(self, button);
end

function GarrisonFollowerPageModelUpgrade_OnLoad(self)
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function GarrisonFollowerPageModelUpgrade_OnEvent(self, event)
	GarrisonFollowerPageModelUpgrade_Update(self);
end

function GarrisonFollowerPageModelUpgrade_Update(self)
	if ( SpellCanTargetGarrisonFollower() ) then
		local followerID = self:GetParent().followerID;
		local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
		if ( followerInfo and followerInfo.isCollected and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION ) then
			local isValidTarget = (followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL or not C_Garrison.TargetSpellHasFollowerItemLevelUpgrade());
			self.Text:SetShown(isValidTarget);
			self.Icon:SetShown(isValidTarget);
			self.TextInvalid:SetShown(not isValidTarget);
			self:Show();
			return;
		end
	end
	self:Hide();
end

function GarrisionFollowerPageUpgradeTarget_OnLoad(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 5);
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function GarrisionFollowerPageUpgradeTarget_OnEvent(self, event)
	if (event == "CURRENT_SPELL_CAST_CHANGED") then
		self:SetShown( SpellCanTargetGarrisonFollower() );
	end
end

function GarrisonFollower_DisplayUpgradeConfirmation(followerID)
	local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
	if ( followerInfo and followerInfo.isCollected and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION and (followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL or not C_Garrison.TargetSpellHasFollowerItemLevelUpgrade()) ) then
		local name = ITEM_QUALITY_COLORS[followerInfo.quality].hex..followerInfo.name..FONT_COLOR_CODE_CLOSE;
		StaticPopup_Show("CONFIRM_FOLLOWER_UPGRADE", name, nil, followerID);
	end
end

function GarrisionFollowerPageUpgradeTarget_OnClick(self, button)
	GarrisonFollower_DisplayUpgradeConfirmation(self:GetParent().followerID);
end
---------------------------------------------------------------------------------
--- Mission Sorting                                                           ---
---------------------------------------------------------------------------------

function Garrison_SortMissions(missionsList)
	local comparison = function(mission1, mission2)
		if ( mission1.level ~= mission2.level ) then
			return mission1.level > mission2.level;
		end

		if ( mission1.level == GARRISON_FOLLOWER_MAX_LEVEL ) then	-- mission 2 level is same as 1's at this point
			if ( mission1.iLevel ~= mission2.iLevel ) then
				return mission1.iLevel > mission2.iLevel;
			end		
		end

		if ( mission1.durationSeconds ~= mission2.durationSeconds ) then
			return mission1.durationSeconds < mission2.durationSeconds;
		end
		
		if ( mission1.isRare ~= mission2.isRare ) then
			return mission1.isRare;
		end

		return strcmputf8i(mission1.name, mission2.name) < 0;
	end

	table.sort(missionsList, comparison);
end

---------------------------------------------------------------------------------
--- Truncation		                                                          ---
---------------------------------------------------------------------------------

function GarrisonTruncationFrame_Check(fontString)
	local self = GarrisonTruncationFrame;
	-- force a resize so IsTruncated will be correct, otherwise it might change a frame later depending on pending resizes
	fontString:GetRect();
	if ( fontString:IsTruncated() ) then
		self:SetParent(fontString:GetParent());
		self:SetPoint("TOPLEFT", fontString);
		self:SetPoint("BOTTOMRIGHT", fontString);
		self:Show();
		self.tooltip = fontString:GetText();
	else
		self:Hide();
		self.tooltip = nil;
	end
end

function GarrisonTruncationFrame_OnEnter(self)
	if ( self.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:SetText(self.tooltip);
	end
end

function GarrisonTruncationFrame_OnLeave(self)
	GameTooltip:Hide();
end

---------------------------------------------------------------------------------
--- Threat Counters                                                           ---
---------------------------------------------------------------------------------

function GarrisonThreatCountersFrame_OnLoad(self)
	local mechanics = C_Garrison.GetAllEncounterThreats();
	-- sort reverse alphabetical because we'll be anchoring buttons right to left
	table.sort(mechanics, function(m1, m2) return strcmputf8i(m1.name, m2.name) > 0; end);
	for i = 1, #mechanics do
		local frame = GarrisonThreatCountersFrame.ThreatsList[i];
		if ( not frame ) then
			frame = CreateFrame("Button", nil, GarrisonThreatCountersFrame, "GarrisonThreatCounterTemplate");
			frame:SetPoint("RIGHT", GarrisonThreatCountersFrame.ThreatsList[i-1], "LEFT", -14, 0);
			GarrisonThreatCountersFrame.ThreatsList[i] = frame;
		end
		frame.Icon:SetTexture(mechanics[i].icon);
		frame.name = mechanics[i].name;
		frame.id = mechanics[i].id;
	end
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
end

function GarrisonThreatCountersFrame_OnEvent(self, event, ...)
	if ( self:IsVisible() ) then
		GarrisonThreatCountersFrame_Update(self);
	end
end

function GarrisonThreatCountersFrame_Update(self)
	for i = 1, #self.ThreatsList do
		self.ThreatsList[i].Count:SetText(C_Garrison.GetNumFollowersForMechanic(self.ThreatsList[i].id));
	end
end

function GarrisonThreatCounter_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local text = string.format(GARRISON_THREAT_COUNTER_TOOLTIP, C_Garrison.GetNumFollowersForMechanic(self.id), self.name);
	GameTooltip:SetText(text, nil, nil, nil, nil, true);
end
