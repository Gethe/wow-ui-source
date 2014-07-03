GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;
GARRISON_FOLLOWER_MAX_LEVEL = 100;
GARRISON_MISSION_MANY_THRESHOLD = 4;

function GarrisonMissionFrame_ToggleFrame()
	if (not GarrisonMissionFrame:IsShown()) then
		ShowUIPanel(GarrisonMissionFrame);
	else
		HideUIPanel(GarrisonMissionFrame);
	end
end

function GarrisonMissionFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 2);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	
	self.FollowerList.followers = { };
	self.FollowerList.followersList = { };
	GarrisonFollowerList_DirtyList();

	GarrisonMissionFrame_UpdateCurrency();
	
	self.FollowerList.listScroll.update = GarrisonFollowerList_Update;
	HybridScrollFrame_CreateButtons(self.FollowerList.listScroll, "GarrisonMissionFollowerButtonTemplate", 7, -7, nil, nil, nil, -6);
	GarrisonFollowerList_Update();
	
	self.MissionTab.MissionList.listScroll.update = GarrisonMissionList_Update;
	HybridScrollFrame_CreateButtons(self.MissionTab.MissionList.listScroll, "GarrisonMissionListButtonTemplate", 13, -8, nil, nil, nil, -4);
	GarrisonMissionList_Update();
	
	self.MissionTab.MissionList.Tab1:Click();
	
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Horde" ) then
		GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.Chest:SetAtlas("GarrMission-HordeChest");
	end

	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_REMOVED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function GarrisonMissionFrame_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_LIST_UPDATE") then
		showToast = ...;
		GarrisonMissionList_UpdateMissions();
	elseif (event == "GARRISON_FOLLOWER_LIST_UPDATE") then
		GarrisonFollowerList_DirtyList();
		GarrisonFollowerList_UpdateFollowers();
	elseif (event == "GARRISON_FOLLOWER_REMOVED") then
		if (GarrisonMissionFrame.FollowerTab.followerID and not C_Garrison.GetFollowerInfo(GarrisonMissionFrame.FollowerTab.followerID)) then
			-- viewed follower got removed, pick someone else
			local index = GarrisonMissionFrame.FollowerList.followersList[1];
			if (index and GarrisonMissionFrame.FollowerList.followers[index].followerID ~= GarrisonMissionFrame.FollowerTab.followerID) then
				GarrisonFollowerPage_ShowFollower(GarrisonMissionFrame.FollowerList.followers[index].followerID);
			else
				-- try the 2nd follower
				index = GarrisonMissionFrame.FollowerList.followersList[2];
				if (index) then
					GarrisonFollowerPage_ShowFollower(GarrisonMissionFrame.FollowerList.followers[index].followerID);
				else
					-- empty page
					GarrisonFollowerPage_ShowFollower(0);
				end
			end
		end
		GarrisonFollowerList_DirtyList();
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then
		GarrisonMissionFrame_UpdateCurrency();
	end
end

function GarrisonMissionFrame_OnShow(self)
	self.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions();
	if (#self.MissionComplete.completeMissions > 0) then
		GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog:Show();
	end
end

function GarrisonMissionFrameTab_OnClick(self)
	PlaySound("igCharacterInfoTab");
	PanelTemplates_Tab_OnClick(self, GarrisonMissionFrame);
	
	if (self:GetID() == 1) then
		if ( GarrisonMissionFrame.MissionComplete.currentIndex ) then
			GarrisonMissionFrame.MissionComplete:Show();
			GarrisonMissionFrame.FollowerList:Hide();		
		else
			GarrisonMissionFrame.MissionTab:Show();
		end
		GarrisonMissionFrame.FollowerTab:Hide();
	else
		GarrisonMissionFrame.MissionComplete:Hide();
		GarrisonMissionFrame.MissionTab:Hide();
		GarrisonMissionFrame.FollowerTab:Show();
		GarrisonMissionFrame.FollowerList:Show();
		-- if there's no follower displayed on the right, select the first one
		if (not GarrisonMissionFrame.FollowerTab.followerID) then
			local index = GarrisonMissionFrame.FollowerList.followersList[1];
			if (index) then
				GarrisonFollowerPage_ShowFollower(GarrisonMissionFrame.FollowerList.followers[index].followerID);
			else
				-- empty page
				GarrisonFollowerPage_ShowFollower(0);
			end
		end
	end
end

function GarrisonMissionFrame_UpdateCurrency()
	local currencyName, amount, currencyTexture = GetCurrencyInfo(GARRISON_CURRENCY);
	GarrisonMissionFrame.materialAmount = amount;
	amount = BreakUpLargeNumbers(amount)
	GarrisonMissionFrame.MissionTab.MissionList.MaterialFrame.Materials:SetText(amount.." |T"..currencyTexture..":0:0:0:-1|t ");
	GarrisonMissionFrame.FollowerList.MaterialFrame.Materials:SetText(amount.." |T"..currencyTexture..":0:0:0:-1|t ");
end

---------------------------------------------------------------------------------
--- Follower List                                                             ---
---------------------------------------------------------------------------------

function GarrisonFollowerList_OnShow(self)
	GarrisonFollowerList_DirtyList();
	GarrisonFollowerList_UpdateFollowers()
end

function GarrisonFollowerList_OnHide(self)
	self.followers = nil;
end

function GarrisonFollowerList_UpdateFollowers()
	local self = GarrisonMissionFrame.FollowerList;
	if ( self.dirtyList ) then
		self.followers = C_Garrison.GetFollowers();
		self.dirtyList = nil;
	end
	self.followersList = { };

	local hideCollected = GetCVarBitfield("garrisonFollowerFilters", LE_FOLLOWER_FILTER_COLLECTED);
	local hideNotCollected = GetCVarBitfield("garrisonFollowerFilters", LE_FOLLOWER_FILTER_NOT_COLLECTED);
	local searchString = self.SearchBox:GetText();
	if ( searchString == SEARCH ) then
		searchString = nil;
	end

	local isFiltered = function(follower)
		if ( hideCollected and follower.isCollected ) then
			return true;
		end
		if ( hideNotCollected and not follower.isCollected ) then
			return true;
		end
		if ( searchString and searchString ~= "" ) then
			return not C_Garrison.SearchForFollower(follower.followerID, searchString );
		end
		return false;
	end

	for i = 1, #self.followers do
		if ( not isFiltered(self.followers[i]) ) then
			tinsert(self.followersList, i);
		end
	end
	
	GarrisonFollowerList_SortFollowers();
	GarrisonFollowerList_Update();
end

function GarrisonFollowerList_Update()
	local followers = GarrisonMissionFrame.FollowerList.followers;
	local followersList = GarrisonMissionFrame.FollowerList.followersList;
	local numFollowers = #followersList;
	local scrollFrame = GarrisonMissionFrame.FollowerList.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local expandedHeight = 0;
	
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
			local color = ITEM_QUALITY_COLORS[follower.quality];
			button.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
			button.PortraitFrame.Level:SetText(follower.level);
			SetPortraitTexture(button.PortraitFrame.Portrait, follower.displayID);
			button.PortraitFrame.Favorite:SetShown(follower.isFavorite);
			if ( follower.isCollected ) then
				-- have this follower
				button.isCollected = true;
				button.Name:SetFontObject("GameFontNormal");
				button.Class:SetDesaturated(false);
				button.PortraitFrame.Portrait:SetDesaturated(false);
				button.DownArrow:SetAlpha(1);
				--show iLevel for max level followers				
				if (follower.level < 100) then
					button.Name:SetHeight(0);
					button.Name:SetPoint("LEFT", button, "TOPLEFT", 66, -28);
					button.ILevel:SetText(nil);
					button.Status:ClearAllPoints();
					button.Status:SetPoint("TOPLEFT", button.Name, "BOTTOMLEFT", 0, -2)
				else
					button.Name:SetHeight(10);
					button.Name:SetPoint("TOPLEFT", button, "TOPLEFT", 66, -13);
					button.ILevel:SetText(ITEM_LEVEL_ABBR.." "..follower.iLevel);
					button.Status:ClearAllPoints();
					button.Status:SetPoint("TOPLEFT", button.ILevel, "BOTTOMLEFT", 0, -3)
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
				button.Name:SetFontObject("GameFontDisable");
				button.Class:SetDesaturated(true);
				button.PortraitFrame.Portrait:SetDesaturated(true);
				button.XPBar:Hide();
				button.DownArrow:SetAlpha(0);
			end
			for i = 1, #button.Counters do
				button.Counters[i].info = nil;
				button.Counters[i]:Hide();
			end
			if (GarrisonMissionFrame.followerCounters) then
			--if a mission is being viewed, show mechanics this follower can counter
				counters = GarrisonMissionFrame.followerCounters[follower.followerID];
				if (counters) then
					for j = 1, #counters do
						if (not button.Counters[j]) then
							button.Counters[j] = CreateFrame("Frame", nil, button, "GarrisonMissionAbilityCounterTemplate");
							if (j % 2 == 0) then
								button.Counters[j]:SetPoint("RIGHT", button.Counters[j-1], "LEFT", 5, 0);
							else
								button.Counters[j]:SetPoint("TOP", button.Counters[j-2], "BOTTOM", 0, 5);
							end
						end
						local Counter = button.Counters[j];
						Counter.info = counters[j];
						Counter.info.showCounters = true;
						Counter.Icon:SetTexture(counters[j].icon);
						Counter.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
						Counter.tooltip = counters[j].name;
						Counter:Show();
					end
				end
			end

			if (button.id == GarrisonMissionFrame.openFollower) then
				GarrisonFollowerButton_Select(button);
				expandedHeight = button:GetHeight() - scrollFrame.buttonHeight + 6;
			else
				GarrisonFollowerButton_UnSelect(button);
			end
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numFollowers * scrollFrame.buttonHeight + expandedHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GarrisonFollowerButton_Select(self)
	if ( not self.isCollected ) then
		return;
	end

	self.UpArrow:Show();
	self.DownArrow:Hide();
	local abHeight = 0;
	if (not self.info.abilities) then
		self.info.abilities = C_Garrison.GetFollowerAbilities(self.info.followerID);
	end
	for i=1, #self.info.abilities do
		if (not self.Abilities[i]) then
			self.Abilities[i] = CreateFrame("Frame", nil, self, "GarrisonFollowerListButtonAbilityTemplate");
			self.Abilities[i]:SetPoint("TOPLEFT", self.Abilities[i-1], "BOTTOMLEFT", 0, -2);
		end
		local Ability = self.Abilities[i];
		local ability = self.info.abilities[i];
		Ability.abilityID = ability.id;
		Ability.Name:SetText(ability.name);
		Ability.Icon:SetTexture(ability.icon);
		Ability.tooltip = ability.description;
		Ability:Show();
		abHeight = abHeight + Ability:GetHeight() + 3;
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
end

function GarrisonFollowerButton_UnSelect(self)
	self.UpArrow:Hide();
	self.DownArrow:Show();
	self.AbilitiesBG:Hide();
	for i=1, #self.Abilities do
		self.Abilities[i]:Hide();
	end
	self:SetHeight(56);
end

function GarrisonFollowerListButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		if ( self.isCollected ) then
			if (not C_Garrison.CastSpellOnFollower(self.id)) then
				if (GarrisonMissionFrame.openFollower == self.id) then
					GarrisonMissionFrame.openFollower = nil;
				else
					GarrisonMissionFrame.openFollower = self.id;
				end
			end
		else
			GarrisonMissionFrame.openFollower = nil;
		end
		GarrisonFollowerList_Update();
		GarrisonFollowerPage_ShowFollower(self.id);
	elseif ( button == "RightButton" ) then
		if ( self.isCollected ) then
			if ( GarrisonFollowerOptionDropDown.followerID ~= self.id ) then
				CloseDropDownMenus();
			end
			GarrisonFollowerOptionDropDown.followerID = self.id;
			ToggleDropDownMenu(1, nil, GarrisonFollowerOptionDropDown, "cursor", 3, -3);
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

function GarrisonFollowerListButton_OnDragStart(self, button)
	GarrisonFollowerPlacer:SetDisplayInfo(self.info.displayID)
	GarrisonFollowerPlacer:SetAnimation(474);
	GarrisonFollowerPlacer.info = self.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 40);
	GarrisonFollowerPlacer:Show();
	GarrisonFollowerPlacer:SetScript("OnUpdate", GarrisonFollowerPlacer_OnUpdate);
end

function GarrisonFollowerListButton_OnDragStop(self)
	if (GarrisonFollowerPlacer:IsShown()) then
		GarrisonFollowerPlacerFrame:Show();
	end
end

--[[
-- current design desire is to not show any tooltip on mouseover
function GarrisonFollowerListButton_OnTooltip(self)	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if (self.isCollected) then
		GarrisonFollowerTooltip_Show(self.info.garrFollowerID, 
			self.info.isCollected,
			C_Garrison.GetFollowerQuality(self.info.followerID),
			C_Garrison.GetFollowerLevel(self.info.followerID), 
			C_Garrison.GetFollowerXP(self.info.followerID),
			C_Garrison.GetFollowerLevelXP(self.info.followerID),
			C_Garrison.GetFollowerItemLevelAverage(self.info.followerID), 
			C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 1),
			C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 2),
			C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 3),
			C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 4),
			C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 1),
			C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 2),
			C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 3),
			C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 4)
			);
	else
		GarrisonFollowerTooltip_Show(
			self.info.followerID, 
			self.info.isCollected,
			self.info.quality,
			self.info.level,
			0,			
			0,
			0,
			C_Garrison.GetFollowerAbilityAtIndexByID(self.info.followerID, 1),
			C_Garrison.GetFollowerAbilityAtIndexByID(self.info.followerID, 2),
			C_Garrison.GetFollowerAbilityAtIndexByID(self.info.followerID, 3),
			C_Garrison.GetFollowerAbilityAtIndexByID(self.info.followerID, 4),
			C_Garrison.GetFollowerTraitAtIndexByID(self.info.followerID, 1),
			C_Garrison.GetFollowerTraitAtIndexByID(self.info.followerID, 2),
			C_Garrison.GetFollowerTraitAtIndexByID(self.info.followerID, 3),
			C_Garrison.GetFollowerTraitAtIndexByID(self.info.followerID, 4)
			);
	end
end
]]--

function GarrisonFollowerPlacer_OnUpdate(self)
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 40);
end

function GarrisonFollowerPlacerFrame_OnClick(self, button)
	if( not GarrisonMissionFrame:IsShown() )then
		-- TODO: fix this
		GarrisonFollowerPlacer:Hide();
		self:Hide();
		return;
	end
	local page = GarrisonMissionFrame.MissionTab.MissionPage;
	if (page.SmallParty:IsShown() and page.SmallParty:IsMouseOver()) then
		GarrisonSingleParty_ReceiveDrag(page.SmallParty);
	elseif (page.MediumParty:IsShown() and page.MediumParty:IsMouseOver()) then
		GarrisonManyParty_ReceiveDrag(page.MediumParty);
	elseif (page.LargeParty:IsShown() and page.LargeParty:IsMouseOver()) then
		GarrisonManyParty_ReceiveDrag(page.LargeParty);
	end
	GarrisonFollowerPlacer:Hide();
	self:Hide();
end

function GarrisonFollowerOptionDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	local follower = self.followerID and C_Garrison.GetFollowerInfo(self.followerID);
	if ( follower ) then
		if ( follower.isFavorite ) then
			info.text = BATTLE_PET_UNFAVORITE;
			info.func = function() 
				C_Garrison.SetFollowerFavorite(self.followerID, false); 
			end
		else
			info.text = BATTLE_PET_FAVORITE;
			info.func = function() 
				C_Garrison.SetFollowerFavorite(self.followerID, true); 
			end
		end
		UIDropDownMenu_AddButton(info, level);
	end

	info.text = CANCEL;
	info.func = nil;
	UIDropDownMenu_AddButton(info, level);	
end

---------------------------------------------------------------------------------
--- Follower filtering and searching                                          ---
---------------------------------------------------------------------------------

function GarrisonFollowerFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;	

	if level == 1 then
	
		info.text = COLLECTED
		info.func = 	function(_, _, _, value)
							SetCVarBitfield("garrisonFollowerFilters", LE_FOLLOWER_FILTER_COLLECTED, not value);
							GarrisonFollowerList_UpdateFollowers();
						end 
		info.checked = not GetCVarBitfield("garrisonFollowerFilters", LE_FOLLOWER_FILTER_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.text = NOT_COLLECTED
		info.func = 	function(_, _, _, value)
							SetCVarBitfield("garrisonFollowerFilters", LE_FOLLOWER_FILTER_NOT_COLLECTED, not value);
							GarrisonFollowerList_UpdateFollowers();		
						end 
		info.checked = not GetCVarBitfield("garrisonFollowerFilters", LE_FOLLOWER_FILTER_NOT_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
	
		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;
		
		info.text = RAID_FRAME_SORT_LABEL
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)
	
	else --if level == 2 then	
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.hasArrow = false;
			info.isNotRadio = nil;
			info.notCheckable = nil;
			info.keepShownOnClick = nil;	
			
			local sortCVar = GetCVar("garrisonFollowerSort");
			local sortType;
			if ( sortCVar == "level" or sortCVar == "rarity" ) then
				sortType = sortCVar;
			else
				-- this is the default
				sortType = "name";
			end
			
			info.text = NAME
			info.func = function()
							GarrisonFollowerList_SetSortType("name");
						end
			info.checked = (sortType == "name");
			UIDropDownMenu_AddButton(info, level);
			
			info.text = LEVEL
			info.func = function()
							GarrisonFollowerList_SetSortType("level");
						end
			info.checked = (sortType == "level");
			UIDropDownMenu_AddButton(info, level);
			
			info.text = RARITY
			info.func = function()
							GarrisonFollowerList_SetSortType("rarity");
						end
			info.checked = (sortType == "rarity");
			UIDropDownMenu_AddButton(info, level);			
		end
	end
end

function GarrisonFollowerList_DirtyList()
	GarrisonMissionFrame.FollowerList.dirtyList = true;
end

function GarrisonFollowerList_SetSortType(sortType)
	SetCVar("garrisonFollowerSort", sortType);
	GarrisonFollowerList_SortFollowers();
	GarrisonFollowerList_Update();
end

function GarrisonFollowerList_SortFollowers()
	local sortCVar = GetCVar("garrisonFollowerSort");
	local followers = GarrisonMissionFrame.FollowerList.followers;

	local comparison = function(index1, index2)
		local follower1 = followers[index1];
		local follower2 = followers[index2];

		if ( follower1.isFavorite ~= follower2.isFavorite ) then
			return follower1.isFavorite;
		end
		if ( follower1.isCollected ~= follower2.isCollected ) then
			return follower1.isCollected;
		end
		if ( follower1.status and not follower2.status ) then
			return false;
		elseif ( not follower1.status and follower2.status ) then
			return true;
		end

		if ( sortCVar == "rarity" ) then
			if ( follower1.quality == follower2.quality ) then
				if ( follower1.level ~= follower2.level ) then
					return follower1.level > follower2.level;
				end
			else
				return follower1.quality > follower2.quality;
			end
		elseif ( sortCVar == "level" ) then
			if ( follower1.level == follower2.level ) then
				if ( follower1.quality ~= follower2.quality ) then
					return follower1.quality > follower2.quality;
				end		
			else
				return follower1.level > follower2.level;
			end
		end
		-- default is name sort
		return follower1.name < follower2.name;
	end

	table.sort(GarrisonMissionFrame.FollowerList.followersList, comparison);
end

---------------------------------------------------------------------------------
--- Models                                                                    ---
---------------------------------------------------------------------------------

function GarrisonMission_SetFollowerModel(modelFrame, followerID, displayID)
	if ( not displayID or displayID == 0 ) then
		modelFrame:ClearModel();
		modelFrame.followerID = nil;
	else
		modelFrame:SetDisplayInfo(displayID);
		modelFrame.followerID = followerID;
		GarrisonMission_SetFollowerModelItems(modelFrame);
	end
end

function GarrisonMission_SetFollowerModelItems(modelFrame)
	if ( modelFrame.followerID ) then
		local follower =  C_Garrison.GetFollowerInfo(modelFrame.followerID);
		if ( follower.isCollected ) then
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
			itemFrame.Name:SetText(itemName);
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

function GarrisonFollowerPage_ShowFollower(followerID)
	local followerInfo = C_Garrison.GetFollowerInfo(followerID);
	local self = GarrisonMissionFrame.FollowerTab;

	if (followerInfo) then
		self.followerID = followerID;
		self.NoFollowersLabel:Hide();
		self.PortraitFrame:Show();
		SetPortraitTexture(self.PortraitFrame.Portrait, followerInfo.displayID);
		GarrisonMission_SetFollowerModel(self.Model, followerInfo.followerID, followerInfo.displayID);
		self.Model:SetHeightFactor(followerInfo.height * GARRISON_FOLLOWER_PAGE_HEIGHT_MULTIPLIER)
		self.Model:InitializeCamera(followerInfo.scale * GARRISON_FOLLOWER_PAGE_SCALE_MULTIPLIER)		
	else
		self.followerID = nil;
		self.NoFollowersLabel:Show();
		followerInfo = { };
		followerInfo.quality = 1;
		followerInfo.abilities = { };
		self.PortraitFrame:Hide();
		self.Model:ClearModel();
	end

	self.Name:SetText(followerInfo.name);
	self.PortraitFrame.Level:SetText(followerInfo.level);
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];
	self.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
	self.Name:SetVertexColor(color.r, color.g, color.b);
	self.ClassSpec:SetText(followerInfo.className);
	self.Class:SetAtlas(followerInfo.classAtlas);
	if ( followerInfo.isCollected ) then
		if (followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL) then
			self.XPText:Hide();
			self.XPLabel:Hide();
			self.XPBar:Hide();
			self.ItemLevel:SetText(ITEM_LEVEL_ABBR.." "..followerInfo.iLevel)
			self.ItemLevel:Show();
		else
			local xpLeft = followerInfo.levelXP - followerInfo.xp;
			self.XPText:SetText(xpLeft..XP);
			self.XPText:Show();
			self.XPLabel:Show();
			self.XPBar:Show();
			self.XPBar:SetMinMaxValues(0, followerInfo.levelXP);
			self.XPBar:SetValue(followerInfo.xp);
			self.ItemLevel:Hide();
		end
	else
		self.XPText:Hide();
		self.XPLabel:Hide();
		self.XPBar:Hide();
	end
	
	for i=1, #self.Abilities do
		self.Abilities[i]:Hide();
	end
	for i=1, #self.Traits do
		self.Traits[i]:Hide();
	end
	
	local numAbilities = 0;
	local numTraits = 0;
	if (not followerInfo.abilities) then
		followerInfo.abilities = C_Garrison.GetFollowerAbilities(followerID);
	end
	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i];
		local Frame;
		if (ability.isTrait) then
			numTraits = numTraits + 1;
			if (not self.Traits[numTraits]) then
				self.Traits[numTraits] = CreateFrame("Frame", nil, self, "GarrisonFollowerPageAbilityTemplate");
				self.Traits[numTraits]:SetPoint("TOPLEFT", self.Traits[numTraits-1], "BOTTOMLEFT", 0, -2);
			end
			Frame = self.Traits[numTraits];
		else
			numAbilities = numAbilities + 1;
			if (not self.Abilities[numAbilities]) then
				self.Abilities[numAbilities] = CreateFrame("Frame", nil, self, "GarrisonFollowerPageAbilityTemplate");
				self.Abilities[numAbilities]:SetPoint("TOPLEFT", self.Abilities[numAbilities-1], "BOTTOMLEFT", 0, -2);
			end
			Frame = self.Abilities[numAbilities];
		end
		
		Frame.Name:SetText(ability.name);
		Frame.IconButton.Icon:SetTexture(ability.icon);
		Frame.Description:SetText(ability.description);
		
		Frame.IconButton.abilityID = ability.id;
		
		local numCounters = 0;
		if (ability.counters) then
			for id, counter in pairs(ability.counters) do
				numCounters = numCounters + 1;
				if (not Frame.Counters[numCounters]) then
					Frame.Counters[numCounters] = CreateFrame("Frame", nil, Frame, "GarrisonMissionAbilityCounterTemplate");
					Frame.Counters[numCounters]:SetPoint("LEFT", Frame.Counters[numCounters-1], "RIGHT", 2, 0)
				end
				local Counter = Frame.Counters[numCounters];
				Counter.Icon:SetTexture(counter.icon);
				Counter.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				Counter.tooltip = counter.name;
				Counter:Show();
			end
			Frame.CounterString:Show();
		else
			Frame.CounterString:Hide();
		end
		local startIndex = numCounters + 1;
		for j = startIndex, #Frame.Counters do
			Frame.Counters[j]:Hide();
		end
		
		Frame:Show();
	end

	if (numAbilities == 0) then
		self.AbilitiesText:Hide();
		self.TraitsText:ClearAllPoints();
		self.TraitsText:SetPoint("TOPLEFT", self.AbilitiesText, "TOPLEFT");
	else
		self.AbilitiesText:Show();
		self.TraitsText:ClearAllPoints();
		local offset = numAbilities * (self.Abilities[1]:GetHeight() + 2) + 10;
		self.TraitsText:SetPoint("TOPLEFT", self.AbilitiesText, "BOTTOMLEFT", 0, -offset);
	end
	
	if (numTraits == 0) then
		self.TraitsText:Hide();
	else
		self.TraitsText:Show();
	end

	-- gear	
	if ( followerInfo.isCollected ) then
		local weaponItemID, weaponItemLevel, armorItemID, armorItemLevel = C_Garrison.GetFollowerItems(followerInfo.followerID);
		GarrisonFollowerPage_SetItem(self.ItemWeapon, weaponItemID, weaponItemLevel);
		GarrisonFollowerPage_SetItem(self.ItemArmor, armorItemID, armorItemLevel);
	else
		self.ItemWeapon:Hide();
		self.ItemArmor:Hide();
	end	
end

---------------------------------------------------------------------------------
--- Mission List                                                              ---
---------------------------------------------------------------------------------

function GarrisonMissionList_OnShow(self)
	GarrisonMissionList_UpdateMissions();
	GarrisonMissionFrame.FollowerList:Hide();
	-- check to show the help plate
	if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_MISSION_LIST) ) then
		local helpPlate = GarrisonMissionList_HelpPlate;
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
			HelpPlate_Show( helpPlate, GarrisonBuildingFrame, GarrisonBuildingFrame.MainHelpButton );
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_MISSION_LIST, true );
		end
	end
end

function GarrisonMissionList_OnHide(self)
	self.missions = nil;
end

function GarrisonMissionListTab_OnClick(self, button)
	PlaySound("igCharacterInfoTab");
	
	local list = GarrisonMissionFrame.MissionTab.MissionList;
	if (self:GetID() == 1) then
		list.showInProgress = false;
		GarrisonMissonListTab_SetSelected(list.Tab2, false);
	else
		list.showInProgress = true;
		GarrisonMissonListTab_SetSelected(list.Tab1, false);
	end
	GarrisonMissonListTab_SetSelected(self, true);
	GarrisonMissionList_UpdateMissions();
end

function GarrisonMissonListTab_SetSelected(tab, isSelected)
	tab.SelectedLeft:SetShown(isSelected);
	tab.SelectedRight:SetShown(isSelected);
	tab.SelectedMid:SetShown(isSelected);
end

function GarrisonMissionList_UpdateMissions()
	local self = GarrisonMissionFrame.MissionTab.MissionList;
	self.availableMissions = C_Garrison.GetAvailableMissions();
	self.inProgressMissions = C_Garrison.GetInProgressMissions();
	self.Tab1:SetText(AVAILABLE.." - "..#self.availableMissions)
	self.Tab2:SetText(WINTERGRASP_IN_PROGRESS.." - "..#self.inProgressMissions)
	GarrisonMissionList_Update();
end

function GarrisonMissionList_Update()
	local self = GarrisonMissionFrame.MissionTab.MissionList;
	local missions;
	if (self.showInProgress) then
		missions = self.inProgressMissions or {};
	else
		missions = self.availableMissions or {};
	end
	local numMissions = #missions;
	local scrollFrame = self.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	if (numMissions == 0) then
		self.EmptyListString:Show();
	else
		self.EmptyListString:Hide();
	end
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numMissions) then
			local mission = missions[index];
			button.id = index;
			button.info = mission;
			button.Title:SetText(mission.name);
			button.Level:SetText(mission.level);
			button.Summary:SetText(mission.duration);
			if (mission.isRare) then
				button.RareOverlay:Show();
				button.RareText:Show();
				button.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4)
			else
				button.RareOverlay:Hide();
				button.RareText:Hide();
				button.IconBG:SetVertexColor(0, 0, 0, 0.4)
			end
			if (mission.cost > 0) then
				button.CostFrame:Show();
				button.CostFrame.Cost:SetText(BreakUpLargeNumbers(mission.cost));
				if (mission.cost > GarrisonMissionFrame.materialAmount) then
					button.CostFrame.Cost:SetText(RED_FONT_COLOR_CODE..BreakUpLargeNumbers(mission.cost)..FONT_COLOR_CODE_CLOSE);
				else
					button.CostFrame.Cost:SetText(BreakUpLargeNumbers(mission.cost));
				end
			else
				button.CostFrame:Hide();
			end
			
			button:Enable();
			if (mission.inProgress) then
				button.Overlay:Show();
				button.Summary:SetText(button.Summary:GetText().." "..RED_FONT_COLOR_CODE.."(In Progress)"..FONT_COLOR_CODE_CLOSE);
				button.CostFrame:Hide();
			else
				button.Overlay:Hide();
			end
			button.MissionType:SetAtlas(mission.typeAtlas);
			GarrisonMissionButton_SetRewards(button, mission.rewards, mission.numRewards);
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numMissions * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GarrisonMissionButton_SetRewards(self, rewards, numRewards)
	if (numRewards > 0) then
		self.RewardsBG:SetWidth(74 * numRewards);
		self.RewardsBG:SetTexCoord(0, .333 * numRewards, 0, 1);
		local index = 1;
		for id, reward in pairs(rewards) do
			if (not self.Rewards[index]) then
				self.Rewards[index] = CreateFrame("Frame", nil, self, "GarrisonMissionListButtonRewardTemplate");
				self.Rewards[index]:SetPoint("RIGHT", self.Rewards[index-1], "LEFT", 0, 0);
			end
			local Reward = self.Rewards[index];
			Reward.Quantity:Hide();
			if (reward.itemID) then
				Reward.itemID = reward.itemID;
				local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
				Reward.Icon:SetTexture(itemTexture);
			else
				Reward.Icon:SetTexture(reward.icon);
				Reward.title = reward.title
				if (reward.currencyID and reward.quantity) then
					if (reward.currencyID == 0) then
						Reward.tooltip = GetMoneyString(reward.quantity);
					else
						local _, _, currencyTexture = GetCurrencyInfo(reward.currencyID);
						Reward.tooltip = BreakUpLargeNumbers(reward.quantity).." |T"..currencyTexture..":0:0:0:-1|t ";
						Reward.Quantity:SetText(reward.quantity);
						Reward.Quantity:Show();
					end
				else
					Reward.tooltip = reward.tooltip;
				end
			end
			Reward:Show();
			index = index + 1;
		end
	else
		self.RewardsBG:Hide();
	end
	
	for i = (numRewards + 1), #self.Rewards do
		self.Rewards[i]:Hide();
	end
end

function GarrisonMissionButton_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local missionLink = C_Garrison.GetMissionLink(self.info.missionID);
		if (missionLink) then
			ChatEdit_InsertLink(missionLink);
		end
		return;
	end

	-- don't do anything other than create links for in progress missions
	if (self.info.inProgress) then
		return;
	end

	GarrisonMissionList_Update();
	
	GarrisonMissionFrame.MissionTab.MissionList:Hide();
	GarrisonMissionFrame.MissionTab.MissionPage:Show();
	GarrisonMissionPage_ShowMission(self.info);
	GarrisonMissionFrame.followerCounters = C_Garrison.GetBuffedFollowersForMission(self.info.missionID)
	GarrisonFollowerList_Update();
	if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_MISSION_PAGE) ) then
		local helpPlate = GarrisonMissionPage_HelpPlate;
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
			HelpPlate_Show( helpPlate, GarrisonBuildingFrame, GarrisonBuildingFrame.MainHelpButton );
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_MISSION_PAGE, true );
		end
	end
end

function GarrisonMissionButton_OnEnter(self, button)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	
	--Mission Name
	GameTooltip:SetText(self.info.name);
	
	if(self.info.inProgress) then
		GameTooltip:AddLine(self.info.timeLeft.." "..RED_FONT_COLOR_CODE.."(In Progress)"..FONT_COLOR_CODE_CLOSE, 1, 1, 1);
		GameTooltip:AddLine(" ");
		if self.info.followers ~= nil then
			GameTooltip:AddLine(GARRISON_FOLLOWERS);
			for i=1, #(self.info.followers) do
				GameTooltip:AddLine(C_Garrison.GetFollowerName(self.info.followers[i]), 1, 1, 1);
			end
			--GameTooltip:AddLine(" ");
		end
		--[[
		-- current UI desire is not to show rewards as they're redundant w/ the reward buttons
		GameTooltip:AddLine("Rewards");
		for id, reward in pairs(self.info.rewards) do
			if (reward.quality) then
				GameTooltip:AddLine(ITEM_QUALITY_COLORS[reward.quality + 1].hex..reward.title..FONT_COLOR_CODE_CLOSE);
			elseif (reward.itemID) then
				local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
				GameTooltip:AddLine(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
			elseif (reward.followerXP) then
				GameTooltip:AddLine(BreakUpLargeNumbers(reward.followerXP), 1, 1, 1);
			else
				GameTooltip:AddLine(reward.title, 1, 1, 1);
			end
		end
		]]--
	else
		GameTooltip:AddLine(string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, self.info.numFollowers), 1, 1, 1);		

		if not C_Garrison.IsOnGarrisonMap() then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(GARRISON_MISSION_TOOLTIP_RETURN_TO_START);
		end
	end

	GameTooltip:Show();
end




---------------------------------------------------------------------------------
--- Mission Page                                                              ---
---------------------------------------------------------------------------------

function GarrisonMissionPage_ShowMission(missionInfo)
	local self = GarrisonMissionFrame.MissionTab.MissionPage;
	self.mission = missionInfo.missionID;
	
	local location, xp, environment, locPrefix, enemies = C_Garrison.GetMissionInfo(missionInfo.missionID);
	GarrisonMissionPage_ShowMissionTimes(missionInfo.missionID);
	self.Stage.Level:SetText(missionInfo.level);
	self.Stage.Title:SetText(missionInfo.name);
	self.Stage.MissionDescription:SetText(missionInfo.description);
	if ( environment ) then
		self.Stage.MissionArea:SetFormattedText(GARRISON_MISSION_AREA_ENV, location, environment);
	else
		self.Stage.MissionArea:SetText(location);
	end
	if ( locPrefix ) then
		self.Stage.LocBack:SetAtlas("_"..locPrefix.."-Back", true);
		self.Stage.LocMid:SetAtlas ("_"..locPrefix.."-Mid", true);
		self.Stage.LocFore:SetAtlas("_"..locPrefix.."-Fore", true);
	end
	self.Stage.MissionXP:SetText(xp);
	self.Stage.MissionType:SetAtlas(missionInfo.typeAtlas);
	
	if (missionInfo.cost > 0) then
		self.CostFrame:Show();
		self.CostFrame.Cost:SetText(missionInfo.cost);
		self.StartMissionButton:ClearAllPoints();
		self.StartMissionButton:SetPoint("RIGHT", self.ButtonFrame, "RIGHT", -50, 1);
	else
		self.CostFrame:Hide();
		self.StartMissionButton:ClearAllPoints();
		self.StartMissionButton:SetPoint("CENTER", self.ButtonFrame, "CENTER", 0, 1);
	end
		
	GarrisonMissionPage_SetPartySize(missionInfo.numFollowers);
	GarrisonMissionPage_SetEnemies(enemies);
	
	local numRewards = missionInfo.numRewards;
	self.RewardsFrame.numRewards = numRewards;
	local index = 1;
	for id, reward in pairs(missionInfo.rewards) do
		if (not self.RewardsFrame.Rewards[index]) then
			self.RewardsFrame.Rewards[index] = CreateFrame("Frame", nil, self.RewardsFrame, "GarrisonMissionListButtonRewardTemplate");
			self.RewardsFrame.Rewards[index]:SetPoint("RIGHT", self.RewardsFrame.Rewards[index-1], "LEFT", 1, 0);
		end
		self.RewardsFrame.Rewards[index].id = id;
		GarrisonMissionPage_SetReward(self.RewardsFrame.Rewards[index], reward);
		index = index + 1;
	end
	for i = (numRewards + 1), #self.RewardsFrame.Rewards do
		self.RewardsFrame.Rewards[i]:Hide();
		self.RewardsFrame.Rewards[i].id = nil;
	end
	self.RewardsFrame.Rewards[1]:ClearAllPoints();
	if (numRewards == 1) then
		self.RewardsFrame.Rewards[1]:SetPoint("RIGHT", self.RewardsFrame, "RIGHT", -115, -20);
	elseif (numRewards == 2) then
		self.RewardsFrame.Rewards[1]:SetPoint("RIGHT", self.RewardsFrame, "RIGHT", -77, -20);
	else
		self.RewardsFrame.Rewards[1]:SetPoint("RIGHT", self.RewardsFrame, "RIGHT", -44, -20);
	end
end

function GarrisonMissionPage_ShowMissionTimes(missionID)
	local stage = GarrisonMissionFrame.MissionTab.MissionPage.Stage;
	local travelTimeString, travelTime, isTravelTimeImproved, missionTimeString, missionTime, isMissionTimeImproved, totalTimeString = C_Garrison.GetMissionTimes(missionID);
	if ( travelTimeString ) then
		if ( isTravelTimeImproved ) then
			travelTimeString = GREEN_FONT_COLOR_CODE..travelTimeString..FONT_COLOR_CODE_CLOSE;
		end
		stage.MissionTravel:SetFormattedText(GARRISON_MISSION_TRAVEL, travelTimeString);
	end
	if ( missionTimeString ) then
		if ( isMissionTimeImproved ) then
			missionTimeString = GREEN_FONT_COLOR_CODE..missionTimeString..FONT_COLOR_CODE_CLOSE;
		end
		stage.MissionTime:SetFormattedText(GARRISON_MISSION_TIME, missionTimeString);
	end
	stage.MissionSummary:SetFormattedText(GARRISON_MISSION_TIME_TOTAL, totalTimeString);
end

function GarrisonMissionPage_SetReward(frame, reward)
	frame.Quantity:Hide();
	if (reward.itemID) then
		frame.itemID = reward.itemID;
		local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
		frame.Icon:SetTexture(itemTexture);
		if (frame.Name) then
			frame.Name:SetText(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
		end
	else
		frame.Icon:SetTexture(reward.icon);
		frame.title = reward.title
		if (reward.currencyID and reward.quantity) then
			if (reward.currencyID == 0) then
				frame.tooltip = GetMoneyString(reward.quantity);
				if (frame.Name) then
					frame.Name:SetText(frame.tooltip);
				end
			else
				local currencyName, _, currencyTexture = GetCurrencyInfo(reward.currencyID);
				frame.tooltip = BreakUpLargeNumbers(reward.quantity).." |T"..currencyTexture..":0:0:0:-1|t ";
				if (frame.Name) then
					frame.Name:SetText(currencyName);
				end
				frame.Quantity:SetText(reward.quantity);
				frame.Quantity:Show();
			end
		else
			frame.tooltip = reward.tooltip;
			if (frame.Name) then
				if (reward.quality) then
					frame.Name:SetText(ITEM_QUALITY_COLORS[reward.quality + 1].hex..frame.title..FONT_COLOR_CODE_CLOSE);
				elseif (reward.followerXP) then
					frame.Name:SetText(BreakUpLargeNumbers(reward.followerXP));
				else
					frame.Name:SetText(frame.title);
				end
			end
		end
	end
	if (reward.chance) then
		-- TODO: fix with mission chance
		GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.Chance:SetFormattedText(PERCENTAGE_STRING, reward.chance);
		frame.isChest = true;
	else
		frame.isChest = nil;
	end
	frame:Show();
end

function GarrisonMissionPage_SetPartySize(size)
	local self = GarrisonMissionFrame.MissionTab.MissionPage;
	
	self.RewardsFrame:SetHeight(113);
	if (size == 1) then
		self.SmallParty:Show();
		self.MediumParty:Hide();
		self.LargeParty:Hide();
	elseif (size == 2 or size == 3) then
		self.SmallParty:Hide();
		self.MediumParty:Show();
		self.LargeParty:Hide();
		if (size == 2) then
			self.MediumParty.Follower3:Hide();
			self.MediumParty.Follower1:SetPoint("TOPLEFT", self.MediumParty, "TOPLEFT", 80, -20);
			self.MediumParty.Follower2:SetPoint("LEFT", self.MediumParty.Follower1, "RIGHT", 60, 0);
		else
			self.MediumParty.Follower3:Show();
			self.MediumParty.Follower1:SetPoint("TOPLEFT", self.MediumParty, "TOPLEFT", 20, -20);
			self.MediumParty.Follower2:SetPoint("LEFT", self.MediumParty.Follower1, "RIGHT", 0, 0);
		end
		self.MediumParty:SetID(size);
	else
		self.SmallParty:Hide();
		self.MediumParty:Hide();
		self.LargeParty:Show();
		if (size == 4) then
			self.LargeParty.Follower5:Hide();
			self.LargeParty.Follower1:SetPoint("TOPLEFT", self.LargeParty, "TOPLEFT", 35, -24);
			self.LargeParty.Follower2:SetPoint("LEFT", self.LargeParty.Follower1, "RIGHT", 30, 0);
			self.LargeParty.Follower3:SetPoint("LEFT", self.LargeParty.Follower2, "RIGHT", 30, 0);
			self.LargeParty.Follower4:SetPoint("LEFT", self.LargeParty.Follower3, "RIGHT", 30, 0);
		else
			self.LargeParty.Follower5:Show();
			self.LargeParty.Follower1:SetPoint("TOPLEFT", self.LargeParty, "TOPLEFT", 10, -24);
			self.LargeParty.Follower2:SetPoint("LEFT", self.LargeParty.Follower1, "RIGHT", 7, 0);
			self.LargeParty.Follower3:SetPoint("LEFT", self.LargeParty.Follower2, "RIGHT", 7, 0);
			self.LargeParty.Follower4:SetPoint("LEFT", self.LargeParty.Follower3, "RIGHT", 7, 0);
		end
		self.LargeParty:SetID(size);
	end
end

function GarrisonMissionPage_SetNumEnemies(size)
	local self = GarrisonMissionFrame.MissionTab.MissionPage;
	
	if (size < 4) then
		self.FewEnemies:Show();
		self.ManyEnemies:Hide();
		if (size == 1) then
			self.FewEnemies.Enemy2:Hide();
			self.FewEnemies.Enemy3:Hide();
			self.FewEnemies.Enemy1:SetPoint("TOPLEFT", self.FewEnemies, "TOPLEFT", 30, -13);
		elseif (size == 2) then
			self.FewEnemies.Enemy2:Show();
			self.FewEnemies.Enemy3:Hide();
			self.FewEnemies.Enemy1:SetPoint("TOPLEFT", self.FewEnemies, "TOPLEFT", 75, -13);
			self.FewEnemies.Enemy2:SetPoint("LEFT", self.FewEnemies.Enemy1, "RIGHT", 46, 0);
		else
			self.FewEnemies.Enemy2:Show();
			self.FewEnemies.Enemy3:Show();
			self.FewEnemies.Enemy1:SetPoint("TOPLEFT", self.FewEnemies, "TOPLEFT", 20, -13);
			self.FewEnemies.Enemy2:SetPoint("LEFT", self.FewEnemies.Enemy1, "RIGHT", -14, 0);
		end
	else
		self.FewEnemies:Hide();
		self.ManyEnemies:Show();
		if (size == 4) then
			self.ManyEnemies.Enemy5:Hide();
			self.ManyEnemies.Enemy1:SetPoint("TOPLEFT", self.ManyEnemies, "TOPLEFT", 35, -10);
			self.ManyEnemies.Enemy2:SetPoint("LEFT", self.ManyEnemies.Enemy1, "RIGHT", 30, 0);
			self.ManyEnemies.Enemy3:SetPoint("LEFT", self.ManyEnemies.Enemy2, "RIGHT", 30, 0);
			self.ManyEnemies.Enemy4:SetPoint("LEFT", self.ManyEnemies.Enemy3, "RIGHT", 30, 0);
		else
			self.ManyEnemies.Enemy5:Show();
			self.ManyEnemies.Enemy1:SetPoint("TOPLEFT", self.ManyEnemies, "TOPLEFT", 9, -10);
			self.ManyEnemies.Enemy2:SetPoint("LEFT", self.ManyEnemies.Enemy1, "RIGHT", 7, 0);
			self.ManyEnemies.Enemy3:SetPoint("LEFT", self.ManyEnemies.Enemy2, "RIGHT", 7, 0);
			self.ManyEnemies.Enemy4:SetPoint("LEFT", self.ManyEnemies.Enemy3, "RIGHT", 7, 0);
		end
	end
	
end

function GarrisonMissionPage_SetEnemies(enemies)
	GarrisonMissionPage_SetNumEnemies(#enemies)
	local enemyFrames;
	if (#enemies < 4) then
		enemyFrames = GarrisonMissionFrame.MissionTab.MissionPage.FewEnemies;
	else
		enemyFrames = GarrisonMissionFrame.MissionTab.MissionPage.ManyEnemies;
	end
	
	for i=1, #enemies do
		local Frame = enemyFrames["Enemy"..i]
		local enemy = enemies[i];
		Frame.Name:SetText(enemy.name);
		if (enemy.displayID) then
			SetPortraitTexture(Frame.PortraitFrame.Portrait, enemy.displayID);
		end
		local numMechs = 1;
		for id, mechanic in pairs(enemy.mechanics) do
			if (not Frame.Mechanics[numMechs]) then
				Frame.Mechanics[numMechs] = CreateFrame("Frame", nil, Frame, "GarrisonMissionEnemyMechanicTemplate");
				Frame.Mechanics[numMechs]:SetPoint("LEFT", Frame.Mechanics[numMechs-1], "RIGHT", 0, 0);
			end
			local Mechanic = Frame.Mechanics[numMechs];
			Mechanic.info = mechanic;
			Mechanic.Icon:SetTexture(mechanic.icon);
			Mechanic.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			Mechanic.mechanicID = id;
			Mechanic:Show();
			numMechs = numMechs + 1;
		end
		for j=(numMechs + 1), #Frame.Mechanics do
			Frame.Mechanics[j]:Hide();
			Frame.Mechanics[j].mechanicID = nil;
			Frame.Mechanics[j].info = nil;
		end
	end
end

function GarrisonMissionPageFollowerFrame_SetFollower(frame, info)
	if (frame.info) then
		GarrisonMissionFollowerFrame_ClearFollower(frame);
	end
	frame.info = info;
	frame.Name:Show();
	frame.Name:SetText(info.name);
	if (frame.Class) then
		frame.Class:Show();
		frame.Class:SetAtlas(info.classAtlas);
	end
	frame.PortraitFrame.Empty:Hide();
	SetPortraitTexture(frame.PortraitFrame.Portrait, info.displayID);
	local color = ITEM_QUALITY_COLORS[info.quality];
	frame.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
	frame.PortraitFrame.Level:SetText(info.level);
	counters = GarrisonMissionFrame.followerCounters and GarrisonMissionFrame.followerCounters[frame.info.followerID] or nil;
	if (counters) then
		for i = 1, #counters do
			if (not frame.Counters[i]) then
				frame.Counters[i] = CreateFrame("Frame", nil, frame, "GarrisonMissionAbilityCounterTemplate");
				frame.Counters[i]:SetPoint("LEFT", frame.Counters[i-1], "RIGHT", -5, 0);
			end
			local Counter = frame.Counters[i];
			Counter.info = counters[i];
			Counter.info.showCounters = true;
			Counter.Icon:SetTexture(counters[i].icon);
			Counter.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			Counter.tooltip = counters[i].name;
			Counter:Show();
		end
		for i = (#counters + 1), #frame.Counters do
			frame.Counters[i]:Hide();
		end
	end
	
	local missionPage = GarrisonMissionFrame.MissionTab.MissionPage;
	C_Garrison.AddFollowerToMission(missionPage.mission, info.followerID);
	--update bonus loot chances
	for i=1, missionPage.RewardsFrame.numRewards do
		local rewardFrame = missionPage.RewardsFrame.Rewards[i];
		if (rewardFrame.isChest) then
			-- TODO: fix with mission chance
			local chance = C_Garrison.GetBonusRewardChance(missionPage.mission, rewardFrame.id);
			GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.Chance:SetFormattedText(PERCENTAGE_STRING, chance);
		end
	end
	
	GarrisonMissionPage_SetCounters();
end

function GarrisonMissionFollowerFrame_ClearFollower(frame)
	local followerID = frame.info and frame.info.followerID or nil;
	frame.info = nil;
	frame.Name:Hide();
	if (frame.Class) then
		frame.Class:Hide();
	end
	frame.PortraitFrame.Empty:Show();
	for i = 1, #frame.Counters do
		frame.Counters[i]:Hide();
	end
	
	local missionPage = GarrisonMissionFrame.MissionTab.MissionPage;
	if (followerID) then
		C_Garrison.RemoveFollowerFromMission(missionPage.mission, followerID);
		--update bonus loot chances
		for i=1, missionPage.RewardsFrame.numRewards do
			local rewardFrame = missionPage.RewardsFrame.Rewards[i];
			if (rewardFrame.isChest) then
				-- TODO: fix with mission chance
				local chance = C_Garrison.GetBonusRewardChance(missionPage.mission, rewardFrame.id);
				GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.Chance:SetFormattedText(PERCENTAGE_STRING, chance);
			end
		end
	end
	
	GarrisonMissionPage_SetCounters();
end

function GarrisonMissionPageParty_IsEmpty(partyFrame)
	for i=1, partyFrame.partySize do
		local Follower = partyFrame["Follower"..i];
		if (Follower.info) then
			return false;
		end
	end
	return true;
end

function GarrisonMissionPageParty_Reset(partyFrame)
	for i=1, partyFrame.partySize do
		local Follower = partyFrame["Follower"..i];
		GarrisonMissionFollowerFrame_ClearFollower(Follower);
	end
	
	partyFrame.Buffs:Hide();
	
	if (partyFrame.partySize == 1) then
		partyFrame.Follower1.EmptyString:Show();
		partyFrame.Model:Hide();
		partyFrame.EmptyShadow:Show();
	else
		partyFrame.EmptyString:Show();
	end
end

function GarrisonMissionPage_ClearCounters(enemiesFrame)
	for i=1, enemiesFrame.numEnemies do
		local frame = enemiesFrame["Enemy"..i];
		for j=1, #frame.Mechanics do
			frame.Mechanics[j].Check:Hide();
		end
	end
end

--this function puts check marks on the encounter mechanics countered by the slotted followers abilities
function GarrisonMissionPage_SetCounters()
	local missionPage = GarrisonMissionFrame.MissionTab.MissionPage;
	local enemiesFrame, partyFrame;
	if (missionPage.FewEnemies:IsShown()) then
		enemiesFrame = missionPage.FewEnemies;
	else
		enemiesFrame = missionPage.ManyEnemies;
	end
	if (missionPage.SmallParty:IsShown()) then
		partyFrame = missionPage.SmallParty;
	elseif (missionPage.MediumParty:IsShown()) then
		partyFrame = missionPage.MediumParty;
	else
		partyFrame = missionPage.LargeParty;
	end
	
	GarrisonMissionPage_ClearCounters(enemiesFrame);
	for f=1, partyFrame.partySize do
		local follower = partyFrame["Follower"..f];
		if (follower.info) then
			if (not follower.info.abilities) then
				follower.info.abilities = C_Garrison.GetFollowerAbilities(follower.info.followerID)
			end
			for a=1, #follower.info.abilities do
				local ability = follower.info.abilities[a];
				for counterID, counterInfo in pairs(ability.counters) do
					for e=1, enemiesFrame.numEnemies do
						local enemy = enemiesFrame["Enemy"..e];
						for m=1, #enemy.Mechanics do
							if (counterID == enemy.Mechanics[m].mechanicID) then
								enemy.Mechanics[m].Check:Show();
								
							end
						end
					end
				end
			end
		end
	end
end

function GarrisonMissionPageCloseButton_OnClick(self)
	GarrisonMissionFrame.MissionTab.MissionPage:Hide();
	GarrisonMissionFrame.MissionTab.MissionList:Show();
	GarrisonMissionPageParty_Reset(GarrisonMissionFrame.MissionTab.MissionPage.SmallParty);
	GarrisonMissionPageParty_Reset(GarrisonMissionFrame.MissionTab.MissionPage.MediumParty);
	GarrisonMissionPageParty_Reset(GarrisonMissionFrame.MissionTab.MissionPage.LargeParty);
	GarrisonMissionFrame.followerCounters = nil;
	GarrisonFollowerList_Update();
	GarrisonMissionList_Update();
end

---------------------------------------------------------------------------------
--- Mission Page: Placing Followers/Starting Mission                          ---
---------------------------------------------------------------------------------

function GarrisonSingleParty_ReceiveDrag(self)
	if (not GarrisonFollowerPlacer:IsShown()) then
		return;
	end
	
	local follower = GarrisonFollowerPlacer.info;
	
	self.EmptyShadow:Hide();
	self.Follower1.EmptyString:Hide();
	
	GarrisonMissionPageFollowerFrame_SetFollower(self.Follower1, follower)
	self.Model:Show();
	self.Model:SetTargetDistance(0);
	GarrisonMission_SetFollowerModel(self.Model, follower.followerID, follower.displayID);
	self.Model:SetHeightFactor(follower.height);
	self.Model:InitializeCamera(follower.scale);
	self.Model:SetFacing(-.2);
	--self.Buffs:Show();
	
	GarrisonFollowerPlacer:Hide();
	GarrisonFollowerPlacerFrame:Hide();
end

function GarrisonManyParty_ReceiveDrag(self)
	if (not GarrisonFollowerPlacer:IsShown()) then
		return;
	end
	
	local follower = GarrisonFollowerPlacer.info;
	
	self.EmptyString:Hide();
	GarrisonFollowerPlacer:Hide();
	GarrisonFollowerPlacerFrame:Hide();
	
	local followerFrame;
	for i=1, self.partySize do
		if (not self["Follower"..i].info) then
			followerFrame = self["Follower"..i];
			break;
		elseif (self["Follower"..i].info.followerID == follower.followerID) then
			return;
		end
	end
	if (not followerFrame) then
		return;
	end
	
	GarrisonMissionPageFollowerFrame_SetFollower(followerFrame, follower)
	--self.Buffs:Show();
end

function GarrisonMissionPageFollowerFrame_OnDragStart(self)
	GarrisonFollowerPlacer:SetDisplayInfo(self.info.displayID)
	GarrisonFollowerPlacer:SetAnimation(474);
	GarrisonFollowerPlacer.info = self.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 40);
	GarrisonFollowerPlacer:Show();
	GarrisonFollowerPlacer:SetScript("OnUpdate", GarrisonFollowerPlacer_OnUpdate);
end

function GarrisonMissionPageFollowerFrame_OnDragStop(self)
	GarrisonFollowerPlacer:Hide();
	GarrisonFollowerPlacerFrame:Hide();
	
	if (self:IsMouseOver()) then
		return;
	end
	
	GarrisonMissionFollowerFrame_ClearFollower(self);
	
	local partyFrame = self:GetParent()
	if (GarrisonMissionPageParty_IsEmpty(partyFrame)) then
		GarrisonMissionPageParty_Reset(partyFrame);
	end
end

function GarrisonMissionPageFollowerFrame_OnEnter(self)
	if not self.info then 
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	

	GarrisonFollowerTooltip_Show(self.info.garrFollowerID, 
		self.info.isCollected,
		C_Garrison.GetFollowerQuality(self.info.followerID),
		C_Garrison.GetFollowerLevel(self.info.followerID), 
		C_Garrison.GetFollowerXP(self.info.followerID),
		C_Garrison.GetFollowerLevelXP(self.info.followerID),
		C_Garrison.GetFollowerItemLevelAverage(self.info.followerID), 
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 4),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 4)
		);
	GarrisonFollowerTooltip:Show();
end

function GarrisonMissionPageFollowerFrame_OnLeave(self)
	GarrisonFollowerTooltip:Hide();
end

function GarrisonMissionPageStartMissionButton_OnClick(self)
	local missionPage = GarrisonMissionFrame.MissionTab.MissionPage;
	if (not missionPage.mission) then
		return;
	end
	C_Garrison.StartMission(missionPage.mission);
	GarrisonMissionList_UpdateMissions();
	GarrisonFollowerList_UpdateFollowers();
	missionPage.CloseButton:Click();
	if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_LANDING)) then
		GarrisonLandingPageTutorialBox:Show();
	end
end

---------------------------------------------------------------------------------
--- Tooltips                                                                  ---
---------------------------------------------------------------------------------

function GarrisonMissionMechanic_OnEnter(self)
	if (not self.info) then
		return;
	end
	local tooltip = GarrisonMissionMechanicTooltip;
	tooltip.Icon:SetTexture(self.info.icon);
	tooltip.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
	tooltip.Name:SetText(self.info.name);
	local height = tooltip.Icon:GetHeight() + 28; --height of icon plus padding around it and at the bottom
	tooltip.Description:SetText(self.info.description);
	height = height + tooltip.Description:GetHeight();
	
	if (self.info.showCounters) then
		tooltip.CounterFrom:Show();
		tooltip.CounterIcon:Show();
		tooltip.CounterName:Show();
		tooltip.CounterIcon:SetTexture(self.info.counterIcon);
		tooltip.CounterName:SetText(self.info.counterName);
		height = height + 25 + tooltip.CounterFrom:GetHeight() + tooltip.CounterIcon:GetHeight();
	else
		tooltip.CounterFrom:Hide();
		tooltip.CounterIcon:Hide();
		tooltip.CounterName:Hide();
	end
	
	tooltip:SetHeight(height);
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 5, 0);
	tooltip:Show();
end

---------------------------------------------------------------------------------
--- Mission Complete                                                          ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete_OnLoad(self)
	self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE");
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self.xpTable = C_Garrison.GetFollowerXPTable();
	self.pendingXPAwards = { };
end

function GarrisonMissionComplete_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_BONUS_ROLL_COMPLETE") then
		missionID, chestIndex, result = ...;
		GarrisonMissionCompleteReward_OnResult(missionID, result);
	elseif (event == "GARRISON_FOLLOWER_XP_CHANGED") then
		GarrisonMissionComplete_AnimXP(...);
	end
end

function GarrisonMissionFrame_ShowCompleteMissions()
	GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog:Hide();
	local self = GarrisonMissionFrame.MissionComplete;
	
	GarrisonMissionFrame.MissionTab:Hide();
	GarrisonMissionFrame.FollowerTab:Hide();
	GarrisonMissionFrame.FollowerList:Hide();
	HelpPlate_Hide();
	GarrisonMissionFrame.MainHelpButton:Hide();

	GarrisonMissionFrame.MissionComplete:Show();
	
	self.currentIndex = 1;
	GarrisonMissionComplete_Initialize(self.completeMissions, self.currentIndex);
end

function GarrisonMissionFrame_HideCompleteMissions()
	local self = GarrisonMissionFrame;
	
	self.MissionTab:Show();
	self.MainHelpButton:Show();

	self.MissionComplete:Hide();
	GarrisonMissionFrame.MissionComplete.currentIndex = nil;
end

GARRISON_MISSION_CHEST_MODELS = {
	{[PLAYER_FACTION_GROUP[0]] = 54910, [PLAYER_FACTION_GROUP[1]] = 54910},
	{[PLAYER_FACTION_GROUP[0]] = 54911, [PLAYER_FACTION_GROUP[1]] = 54911},
	{[PLAYER_FACTION_GROUP[0]] = 54913, [PLAYER_FACTION_GROUP[1]] = 54912},
}

function GarrisonMissionComplete_Initialize(missionList, index)
	local self = GarrisonMissionFrame.MissionComplete;
	if (not missionList or #missionList == 0 or index == 0) then
		GarrisonMissionFrame_HideCompleteMissions();
		return;
	end
	if (index > #missionList) then
		self.currentIndex = nil;
		self.completeMissions = nil;
		GarrisonMissionFrame_HideCompleteMissions();
		return;
	end
	local mission = missionList[index];
	
	local stage = self.Stage;
	stage.FewFollowers:Hide();
	stage.ManyFollowers:Hide();
	stage.Encounters:Show();
	
	stage.MissionInfo.Title:SetText(mission.name);
	stage.MissionInfo.Level:SetText(mission.level);
	stage.MissionInfo.Location:SetText(mission.location);

	local location, xp, environment, locPrefix, enemies = C_Garrison.GetMissionInfo(mission.missionID);
	if ( locPrefix ) then
		stage.LocBack:SetAtlas("_"..locPrefix.."-Back", true);
		stage.LocMid:SetAtlas ("_"..locPrefix.."-Mid", true);
		stage.LocFore:SetAtlas("_"..locPrefix.."-Fore", true);
	end
	stage.MissionInfo.MissionXP:SetText(xp);
	stage.MissionInfo.MissionType:SetAtlas(mission.typeAtlas);
	
	local encounters = C_Garrison.GetMissionCompleteEncounters(mission.missionID);
	GarrisonMissionComplete_SetNumEncounters(#encounters);
	for i=1, #encounters do
		local encounter = stage.Encounters["Encounter"..i]
		if (encounters[i].displayID) then
			SetPortraitTexture(encounter.Portrait, encounters[i].displayID);
		end
	end
	
	if (#mission.followers >= GARRISON_MISSION_MANY_THRESHOLD) then
		stage.followersFrame = stage.ManyFollowers;
	else
		stage.followersFrame = stage.FewFollowers;
	end
	self.animInfo = {};
	stage.followers = {};
	for i=1, #mission.followers do
		local follower = stage.followersFrame["Follower"..i];
		local name, displayID, level, quality, currXP, maxXP, height, scale, movementType, impactDelay, castID, impactID, classAtlas = 
					C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[i]);
		follower.followerID = mission.followers[i];
		SetPortraitTexture(follower.PortraitFrame.Portrait, displayID);
		local color = ITEM_QUALITY_COLORS[quality];
		follower.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
		follower.Name:SetText(name);
		if ( follower.Class ) then
			follower.Class:SetAtlas(classAtlas);
		end
		GarrisonMissionComplete_InitFollowerLevel(follower, level, currXP, maxXP);
		local color = ITEM_QUALITY_COLORS[quality];
	    follower.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
		stage.followers[i] = { displayID = displayID, height = height, scale = scale, followerID = mission.followers[i] };
		if (encounters[i]) then --cannot have more animations than encounters
			self.animInfo[i] = { 	displayID = displayID,
									height = height, 
									scale = scale, 
									movementType = movementType,
									impactDelay = impactDelay,
									castID = castID,
									impactID = impactID,
									enemyDisplayID = encounters[i].displayID,
									enemyScale = encounters[i].scale,
									enemyHeight = encounters[i].height,
									followerID = mission.followers[i],
								}
		end
	end
	
	self.BonusRewards.Saturated:Hide();
	
	local numRewards = mission.numRewards;
	local index = 1;
	self.BonusRewards.firstChest = nil;
	for id, reward in pairs(mission.rewards) do
		if (not self.BonusRewards.Rewards[index]) then
			self.BonusRewards.Rewards[index] = CreateFrame("Frame", nil, self.BonusRewards, "GarrisonMissionCompleteRewardTemplate");
			self.BonusRewards.Rewards[index]:SetPoint("RIGHT", self.BonusRewards.Rewards[index-1], "LEFT", -9, 0);
		end
		local Reward = self.BonusRewards.Rewards[index];
		Reward.id = id;
		if (reward.chance) then
			Reward.Icon:Hide();
			Reward.BG:Hide();
			Reward.Name:Hide();
			Reward.Quantity:Hide();
			Reward.Chance:Hide();
			Reward.Chest:Show();
			Reward.Chest.Model:SetDisplayInfo(GARRISON_MISSION_CHEST_MODELS[reward.quality][UnitFactionGroup("player")]);
			Reward.Chest.Chance:SetFormattedText(PERCENTAGE_STRING, reward.chance);
			Reward.Chest.Model:SetAnimation(148);
			Reward.Chest.Lock:SetAlpha(1);
			Reward.Chest:Disable();
			if (not self.BonusRewards.firstChest) then
				self.BonusRewards.firstChest = Reward.Chest;
			end
		else
			Reward.Icon:Show();
			Reward.BG:Show();
			Reward.Name:Show();
			Reward.Chest:Hide();
			GarrisonMissionPage_SetReward(self.BonusRewards.Rewards[index], reward);
		end
		index = index + 1;
	end
	for i = (numRewards + 1), #self.BonusRewards.Rewards do
		self.BonusRewards.Rewards[i]:Hide();
	end
	self.BonusRewards.Rewards[1]:ClearAllPoints();
	if (numRewards == 1) then
		self.BonusRewards.Rewards[1]:SetPoint("CENTER", self.BonusRewards, "CENTER", 0, 0);
	elseif (numRewards == 2) then
		self.BonusRewards.Rewards[1]:SetPoint("LEFT", self.BonusRewards, "CENTER", 5, 0);
	else
		self.BonusRewards.Rewards[1]:SetPoint("RIGHT", self.BonusRewards, "RIGHT", -18, 0);
	end

	GarrisonMissionFrame.MissionComplete.NextMissionButton:Disable();
	if (mission.state >= 0) then
		stage.Encounters:Hide();
		local animIndex = GarrisonMissionComplete_FindAnimIndexFor(GarrisonMissionComplete_AnimFollowersIn);
		if ( animIndex > 0 ) then
			-- want to start animation right before this
			animIndex = animIndex - 1;
		end
		GarrisonMissionComplete_BeginAnims(self, animIndex);
	else
		stage.ModelFarLeft:Hide();
		stage.ModelFarRight:Hide();
		stage.ModelMiddle:Hide();
		GarrisonMissionComplete_BeginAnims(self);
	end
end

function GarrisonMissionComplete_InitFollowerLevel(followerFrame, level, currXP, maxXP)
	followerFrame.XP:SetMinMaxValues(0, maxXP);
	followerFrame.XP:SetValue(currXP);
	followerFrame.XP.level = level;
	followerFrame.PortraitFrame.Level:SetText(level);
end

function GarrisonMissionComplete_SetNumEncounters(numEncounters)
	local self = GarrisonMissionFrame.MissionComplete.Stage.Encounters;
	
	local _, _, _, width = self.Encounter5:GetPoint(1);
	
	for i = 1, 5 do
		local encounter = self["Encounter"..i];
		if ( i <= numEncounters ) then
			encounter:Show();
			encounter.CrossLeft:SetAlpha(0);
			encounter.CrossRight:SetAlpha(0);
		else
			encounter:Hide();
		end
	end
	local step = width / numEncounters;
	local currentAnchor = step;
	for i=1, numEncounters do
		local encounter = self["Encounter"..i];
		encounter:SetPoint("CENTER", self.BarNub, "CENTER", currentAnchor, 3);
		currentAnchor = currentAnchor + step;
	end
	
end

function GarrisonMissionCompleteReward_OnClick(self)
	self:SetScript("OnEvent", GarrisonMissionCompleteReward_OnEvent);
	self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT");
	local missionList = GarrisonMissionFrame.MissionComplete.completeMissions;
	local missionIndex = GarrisonMissionFrame.MissionComplete.currentIndex;
	C_Garrison.MissionBonusRoll(missionList[missionIndex].missionID);
end

function GarrisonMissionCompleteReward_OnResult(missionID, result)
	local missionList = GarrisonMissionFrame.MissionComplete.completeMissions;
	local missionIndex = GarrisonMissionFrame.MissionComplete.currentIndex;
	if (missionList[missionIndex].missionID ~= missionID) then
		return
	end
	
	local currentChest = nil;
	local rewardFrame = GarrisonMissionFrame.MissionComplete.BonusRewards;
	for i=#rewardFrame.Rewards, 1, -1 do
		local reward = rewardFrame.Rewards[i];
		if (reward.Chest:IsShown() and reward.Chest.Lock:GetAlpha() == 0) then
			currentChest = reward.Chest;
			break;
		end
	end
	
	if (not currentChest) then
		return;
	end
	if (result) then --got loot
		currentChest.Model:SetAnimation(154);
		PlaySoundKitID(41361);
	else --no got loot
		currentChest.Model:SetAnimation(153);
		PlaySoundKitID(41362);
		currentChest:SetScript("OnEvent", nil);
		currentChest:UnregisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT");
	end
	
	local nextIndex = chestIndex + 1;
	local nextChest = nil;
	for i=#rewardFrame.Rewards, 1, -1 do
		local reward = rewardFrame.Rewards[i];
		if (reward.Chest:IsShown() and reward.Chest.Lock:GetAlpha() == 1) then
			nextChest = reward.Chest;
			break;
		end
	end
	if (not nextChest or not nextChest:IsShown()) then
		GarrisonMissionFrame.MissionComplete.NextMissionButton:Enable();
		return;
	end
	nextChest.BonusLockBurstAnim:Play();
end

function GarrisonMissionCompleteReward_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_BONUS_ROLL_LOOT") then
		local itemID = ...;
		local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID);
		local reward = self:GetParent();
		reward.Chest:Hide();
		reward.itemID = itemID;
		reward.Icon:SetTexture(itemTexture);
		reward.Name:SetText(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
		reward.Icon:Show();
		reward.Name:Show();
		reward.BG:Show();
		self:SetScript("OnEvent", nil);
		self:UnregisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT");
	end
end

function GarrisonMissionCompleteNextButton_OnClick(self)
	local frame = GarrisonMissionFrame.MissionComplete;
	
	frame.currentIndex = frame.currentIndex + 1;
	GarrisonMissionComplete_Initialize(frame.completeMissions, frame.currentIndex);
end

---------------------------------------------------------------------------------
--- Mission Complete: Animation stuff                                         ---
---------------------------------------------------------------------------------

GARRISON_ANIMATION_LENGTH = 1;

function GarrisonMissionComplete_AnimLine(self, entry)
	GarrisonMissionComplete_PreloadEncounterModels(self);

	local iconWidth = 64;			-- size of portrait icon
	local iconEdgeSpace = 6;		-- empty space on either side of the portrait
	local lineAnimDuration = 1.25;	-- total time for line to animate from one end to another
	local modelWaitTime = 1;		-- extra time to wait for models to load
	
	local encounters = self.Stage.Encounters;
	local lineStart = encounters.EncounterBarFill:GetLeft();
	local lineEnd = encounters["Encounter"..self.encounterIndex]:GetLeft() + iconEdgeSpace;
	local duration = lineAnimDuration / #self.animInfo;
	-- set duration for this segment
	entry.duration = duration;
	-- fill
	local barFill = encounters.EncounterBarFill;
	if ( self.encounterIndex == 1 ) then
		barFill:SetWidth(1);
	else
		barFill:SetWidth(barFill:GetWidth() + iconWidth - iconEdgeSpace * 2);
	end
	barFill.finalWidth = lineEnd - lineStart;
	barFill.Anim.Scale:SetDuration(duration);
	barFill.Anim.Scale:SetToScale(barFill.finalWidth / barFill:GetWidth(), 1);
	barFill.Anim:Play();	-- has OnFinished to set its width to finalWidth
	-- spark
	local barSpark = encounters.EncounterBarSpark;
	barSpark.Anim.Translation:SetDuration(duration);
	barSpark.Anim.Translation:SetOffset(barFill.finalWidth - barFill:GetWidth(), 0);
	barSpark:Show();
	barSpark.Anim:Play();	-- has OnFinished to hide
end

function GarrisonMissionComplete_AnimCheckModels(self, entry)
	self.animNumModelHolds = 0;
	local modelLeft = self.Stage.ModelLeft;
	if ( modelLeft.state == "loading" ) then
		self.animNumModelHolds = self.animNumModelHolds + 1;
	end
	local modelRight = self.Stage.ModelRight;
	if ( modelRight.state == "loading" ) then
		self.animNumModelHolds = self.animNumModelHolds + 1;
	end

	if ( self.animNumModelHolds == 0 ) then
		entry.duration = 0;
	else
		-- wait another second for models to finish loading	
		entry.duration = 1;
	end
end

function GarrisonMissionComplete_AnimModels(self, entry)
	self.animNumModelHolds = nil;
	local modelLeft = self.Stage.ModelLeft;
	local modelRight = self.Stage.ModelRight;
	-- if enemy model is still loading, ignore it
	if ( modelRight.state == "loading" ) then
		modelRight.state = "empty";
	end
	-- but we must have follower model
	if ( modelLeft.state == "loaded" ) then
		-- play models
		local currentAnim = self.animInfo[self.encounterIndex];
		modelLeft:InitializePanCamera(currentAnim.scale or 1)
		modelLeft:SetHeightFactor(currentAnim.height or 0.5);
		modelLeft:StartPan(currentAnim.movementType or LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true, currentAnim.castID);
		-- enemy model is optional
		if ( modelRight.state == "loaded" ) then
			modelRight:InitializePanCamera(currentAnim.enemyScale or 1);
			modelRight:SetHeightFactor(currentAnim.enemyHeight or 0.5);
			modelRight:SetAnimOffset(currentAnim.impactDelay  or 0);
			modelRight:StartPan(LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true, currentAnim.impactID);
		end
		entry.duration = GARRISON_ANIMATION_LENGTH - 0.4;
	else
		-- no models, skip
		entry.duration = 0;
	end
end

function GarrisonMissionComplete_AnimPortrait(self, entry)
	self.Stage.Encounters["Encounter"..self.encounterIndex].Anim:Play();
end

function GarrisonMissionComplete_AnimCheckEncounters(self, entry)
	self.encounterIndex = self.encounterIndex + 1;
	if ( self.animInfo[self.encounterIndex] ) then
		-- restart for new encounter
		self.animIndex = 0;
		entry.duration = 0;
	else
		self.Stage.Encounters.FadeOut:Play();	-- has OnFinished to hide
		entry.duration = 0.5;
	end
end

function GarrisonMissionComplete_AnimFollowersIn(self, entry)
	local missionList = self.completeMissions;
	local missionIndex = self.currentIndex;
	local mission = missionList[missionIndex];
	if ( not (mission.state >= 0) ) then
		C_Garrison.MarkMissionComplete(mission.missionID);
	end
	
	local numFollowers = #mission.followers;
	GarrisonMissionComplete_SetNumFollowers(numFollowers);
	_G["Ending"..numFollowers]();
	local stage = self.Stage;
	if (stage.ModelLeft:IsShown()) then
		stage.ModelLeft.FadeIn:Play();		-- no OnFinished
	end
	if (stage.ModelRight:IsShown()) then
		stage.ModelRight.FadeIn:Play();		-- no OnFinished
	end
	if (stage.ModelFarLeft:IsShown()) then
		stage.ModelFarLeft.FadeIn:Play();	-- no OnFinished
	end
	if (stage.ModelFarRight:IsShown()) then
		stage.ModelFarRight.FadeIn:Play();	-- no OnFinished
	end
	if (stage.ModelMiddle:IsShown()) then
		stage.ModelMiddle.FadeIn:Play();	-- no OnFinished
	end
	for i = 1, numFollowers do
		local followerFrame = stage.followersFrame["Follower"..i];
		followerFrame.XPGain:SetAlpha(0);
		followerFrame.LevelUpFrame:Hide();
	end
	stage.followersFrame.FadeIn:Play();
end

function GarrisonMissionComplete_AnimRewards(self, entry)
	if ( self.BonusRewards.firstChest) then
		self.BonusRewards.firstChest.BonusLockBurstAnim:Play();
	else
		self.NextMissionButton:Enable();
	end
	self.BonusRewards.Saturated:Show();
	self.BonusRewards.Saturated.FadeIn:Play();
end

-- if duration is nil it will be set in the onStart function
-- duration is irrelevant for the last entry
local ANIMATION_CONTROL = {
	[1] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimLine },					-- line between encounters
	[2] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimCheckModels },			-- check that models are loaded
	[3] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimModels },					-- model fight
	[4] = { duration = 0.45,	onStartFunc = GarrisonMissionComplete_AnimPortrait },				-- X over portrait
	[5] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimCheckEncounters },		-- evaluate whether to do next encounter or move on
	[6] = { duration = 0.5,		onStartFunc = GarrisonMissionComplete_AnimFollowersIn },			-- show all the mission followers - MARK MISSION COMPLETE here
	[7] = { duration = 0,		onStartFunc = GarrisonMissionComplete_AnimRewards },				-- reward panel
};

function GarrisonMissionComplete_FindAnimIndexFor(func)
	for i = 1, #ANIMATION_CONTROL do
		if ( ANIMATION_CONTROL[i].onStartFunc == func ) then
			return i;
		end
	end
	return 0;
end

function GarrisonMissionComplete_BeginAnims(self, animIndex)
	self.encounterIndex = 1;
	self.animIndex = animIndex or 0;
	self.animTimeLeft = 0;
	self:SetScript("OnUpdate", GarrisonMissionComplete_OnUpdate);
end

function GarrisonMissionComplete_OnUpdate(self, elapsed)
	self.animTimeLeft = self.animTimeLeft - elapsed;
	if ( self.animTimeLeft <= 0 ) then
		self.animIndex = self.animIndex + 1;
		local entry = ANIMATION_CONTROL[self.animIndex];
		if ( entry ) then
			entry.onStartFunc(self, entry);
			self.animTimeLeft = entry.duration;
		else
			-- done
			self:SetScript("OnUpdate", nil);
		end
	end
end

function GarrisonMissionComplete_OnModelLoaded(self)
	-- making sure we didn't give up on loading this model
	if ( self.state == "loading" ) then
		self.state = "loaded";
		-- is the anim paused for models?
		local frame = GarrisonMissionFrame.MissionComplete;
		if ( frame.animNumModelHolds ) then
			frame.animNumModelHolds = frame.animNumModelHolds - 1;
			-- no models left to load, full speed ahead
			if ( frame.animNumModelHolds == 0 ) then
				frame.animTimeLeft = 0;
			end
		end
	end
end

function GarrisonMissionComplete_PreloadEncounterModels(self)
	local modelLeft = self.Stage.ModelLeft;
	modelLeft:SetAlpha(0);	
	modelLeft:Show();
	modelLeft:ClearModel();

	local modelRight = self.Stage.ModelRight;	
	modelRight:SetAlpha(0);	
	modelRight:Show();
	modelRight:ClearModel();

	if ( self.animInfo and self.encounterIndex and self.animInfo[self.encounterIndex] ) then
		local currentAnim = self.animInfo[self.encounterIndex];
		modelLeft.state = "loading";
		GarrisonMission_SetFollowerModel(modelLeft, currentAnim.followerID, currentAnim.displayID);		
		if ( currentAnim.enemyDisplayID ) then
			modelRight.state = "loading";
			modelRight:SetDisplayInfo(currentAnim.enemyDisplayID);
		else
			modelRight.state = "empty";
		end
	else
		modelLeft.state = "empty";
		modelRight.state = "empty";
	end
end

---------------------------------------------------------------------------------
--- Mission Complete: XP stuff				                                  ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete_AwardFollowerXP(followerFrame, xpAward)
	local xpBar = followerFrame.XP;
	local xpFrame = followerFrame.XPGain;
	-- xp text
	xpFrame:Show();
	xpFrame.FadeIn:Play();
	xpFrame.Text:SetText("+"..xpAward);
	-- bar
	local _, maxXP = xpBar:GetMinMaxValues();
	if ( xpBar:GetValue() + xpAward >  maxXP ) then
		xpBar.toGoXP = maxXP - xpBar:GetValue();
		xpBar.remainingXP = xpAward - xpBar.toGoXP;
	else
		xpBar.toGoXP = xpAward;
		xpBar.remainingXP = 0;
	end
	followerFrame.activeAnims = 2;	-- text & bar
	GarrisonMissionComplete_AnimXPBar(xpBar);
end

function GarrisonMissionComplete_AnimXP(followerID, xpAward, oldXP, oldLevel)
	local self = GarrisonMissionFrame.MissionComplete;
	local missionList = self.completeMissions;
	local missionIndex = self.currentIndex;
	local mission = missionList[missionIndex];

	for i = 1, #mission.followers do
		local followerFrame = self.Stage.followersFrame["Follower"..i];
		if ( followerFrame.followerID == followerID ) then
			if ( not followerFrame.activeAnims or followerFrame.activeAnims == 0 ) then
				if ( xpAward > 0 ) then
					GarrisonMissionComplete_InitFollowerLevel(followerFrame, oldLevel, oldXP, self.xpTable[oldLevel]);
					GarrisonMissionComplete_AwardFollowerXP(followerFrame, xpAward);
				else
					-- lost xp, no anim
					local _, _, level, _, currXP, maxXP = C_Garrison.GetFollowerMissionCompleteInfo(followerID);
					GarrisonMissionComplete_InitFollowerLevel(followerFrame, level, currXP, maxXP);
				end
			else
				-- save for later
				local t = {};
				t.followerID = followerID;
				t.xpAward = xpAward;
				t.oldXP = oldXP;
				t.oldLevel = oldLevel;
				tinsert(self.pendingXPAwards, t);
			end
			break;
		end
	end
end

function GarrisonMissionComplete_AnimXPBar(xpBar)
	xpBar.timeIn = 0;
	xpBar.startXP = xpBar:GetValue();
	local _, maxXP = xpBar:GetMinMaxValues();
	xpBar.duration = xpBar.toGoXP / maxXP * xpBar.length / 25;
	xpBar:SetScript("OnUpdate", GarrisonMissionComplete_AnimXPBar_OnUpdate);
end

function GarrisonMissionComplete_AnimXPBar_OnUpdate(self, elapsed)
	self.timeIn = self.timeIn + elapsed;
	if ( self.timeIn >= self.duration ) then
		self.timeIn = nil;
		self:SetScript("OnUpdate", nil);
		self:SetValue(self.startXP + self.toGoXP);
		GarrisonMissionComplete_AnimXPBarOnFinish(self);
	else
		self:SetValue(self.startXP + (self.timeIn / self.duration) * self.toGoXP);
	end
	
end

function GarrisonMissionComplete_AnimXPBarOnFinish(xpBar)
	local _, maxXP = xpBar:GetMinMaxValues();
	if ( xpBar:GetValue() == maxXP ) then
		-- leveled up!
		local followerFrame = xpBar:GetParent();
		local levelUpFrame = followerFrame.LevelUpFrame;
		if ( not levelUpFrame:IsShown() ) then
			levelUpFrame:Show();
			levelUpFrame:SetAlpha(1);
			levelUpFrame.Anim:Play();
		end
		local nextLevel = xpBar.level + 1;
		local nextLevelXP = GarrisonMissionFrame.MissionComplete.xpTable[nextLevel];
		if ( nextLevelXP ) then
			GarrisonMissionComplete_InitFollowerLevel(followerFrame, nextLevel, 0, nextLevelXP);
			maxXP = nextLevelXP;
		end
	end
	if ( xpBar.remainingXP > 0 ) then
		-- we still have XP to go
		local availableXP = maxXP - xpBar:GetValue();
		if ( xpBar.remainingXP > availableXP ) then
			xpBar.toGoXP = availableXP;
			xpBar.remainingXP = xpBar.remainingXP - availableXP;
		else
			xpBar.toGoXP = xpBar.remainingXP;
			xpBar.remainingXP = 0;
		end
		GarrisonMissionComplete_AnimXPBar(xpBar);
	else
		GarrisonMissionComplete_OnFollowerXPFinished(xpBar:GetParent());
	end
end

function GarrisonMissionComplete_AnimXPGainOnFinish(self)
	GarrisonMissionComplete_OnFollowerXPFinished(self:GetParent():GetParent());
end

function GarrisonMissionComplete_OnFollowerXPFinished(followerFrame)
	followerFrame.activeAnims = followerFrame.activeAnims - 1;
	if ( followerFrame.activeAnims == 0 ) then
		-- check queued rewards
		local pendingXPAwards = GarrisonMissionFrame.MissionComplete.pendingXPAwards;
		for k, v in pairs(pendingXPAwards) do
			if ( v.followerID == followerFrame.followerID ) then
				GarrisonMissionComplete_AnimXP(v.followerID, v.xpAward, v.oldXP, v.oldLevel);
				tremove(pendingXPAwards, k);
				return;
			end
		end
	end
end

---------------------------------------------------------------------------------
--- Mission Complete: Follower pose stuff                                     ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete_ShowEnding()
	local self = GarrisonMissionFrame.MissionComplete;
	
	self.Stage.Encounters.FadeOut:Play();
end	

function GarrisonMissionComplete_SetNumFollowers(size)
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	
	if (size < GARRISON_MISSION_MANY_THRESHOLD) then
		self.FewFollowers:Show();
		self.ManyFollowers:Hide();
		if (size == 1) then
			Ending1();
			self.FewFollowers.Follower2:Hide();
			self.FewFollowers.Follower3:Hide();
			self.FewFollowers.Follower1:SetPoint("LEFT", self.FewFollowers, "BOTTOMLEFT", 200, -4);
		elseif (size == 2) then
			Ending2();
			self.FewFollowers.Follower2:Show();
			self.FewFollowers.Follower3:Hide();
			self.FewFollowers.Follower1:SetPoint("LEFT", self.FewFollowers, "BOTTOMLEFT", 75, -4);
			self.FewFollowers.Follower2:SetPoint("LEFT", self.FewFollowers.Follower1, "RIGHT", 75, 0);
		else
			Ending3();
			self.FewFollowers.Follower2:Show();
			self.FewFollowers.Follower3:Show();
			self.FewFollowers.Follower1:SetPoint("LEFT", self.FewFollowers, "BOTTOMLEFT", 25, -4);
			self.FewFollowers.Follower2:SetPoint("LEFT", self.FewFollowers.Follower1, "RIGHT", 0, 0);
		end
	else
		self.FewFollowers:Hide();
		self.ManyFollowers:Show();
		if (size == 4) then
			Ending4();
			self.ManyFollowers.Follower5:Hide();
			self.ManyFollowers.Follower1:SetPoint("LEFT", self.ManyFollowers, "BOTTOMLEFT", 50, -7);
			self.ManyFollowers.Follower2:SetPoint("LEFT", self.ManyFollowers.Follower1, "RIGHT", 40, 0);
			self.ManyFollowers.Follower3:SetPoint("LEFT", self.ManyFollowers.Follower2, "RIGHT", 40, 0);
			self.ManyFollowers.Follower4:SetPoint("LEFT", self.ManyFollowers.Follower3, "RIGHT", 40, 0);
		else
			Ending5();
			self.ManyFollowers.Follower5:Show();
			self.ManyFollowers.Follower1:SetPoint("LEFT", self.ManyFollowers, "BOTTOMLEFT", 27, -7);
			self.ManyFollowers.Follower2:SetPoint("LEFT", self.ManyFollowers.Follower1, "RIGHT", 20, 0);
			self.ManyFollowers.Follower3:SetPoint("LEFT", self.ManyFollowers.Follower2, "RIGHT", 20, 0);
			self.ManyFollowers.Follower4:SetPoint("LEFT", self.ManyFollowers.Follower3, "RIGHT", 20, 0);
		end
	end
end

function SetupEnding(M, L, R, FL, FR)
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	if (M) then
		GarrisonMission_SetFollowerModel(self.ModelMiddle, M.followerID, M.displayID);
		self.ModelMiddle:SetHeightFactor(M.height);
		self.ModelMiddle:InitializeCamera(M.scale);
	end
	if (L) then
		GarrisonMission_SetFollowerModel(self.ModelLeft, L.followerID, L.displayID);
		self.ModelLeft:SetHeightFactor(L.height);
		self.ModelLeft:InitializeCamera(L.scale);
	end
	if (R) then
		GarrisonMission_SetFollowerModel(self.ModelRight, R.followerID, R.displayID);
		self.ModelRight:SetHeightFactor(R.height);
		self.ModelRight:InitializeCamera(R.scale);
	end
	if (FL) then
		GarrisonMission_SetFollowerModel(self.ModelFarLeft, FL.followerID, FL.displayID);
		self.ModelFarLeft:SetHeightFactor(FL.height);
		self.ModelFarLeft:InitializeCamera(FL.scale);
	end
	if (FR) then
		GarrisonMission_SetFollowerModel(self.ModelFarRight, FR.followerID, FR.displayID);
		self.ModelFarRight:SetHeightFactor(FR.height);
		self.ModelFarRight:InitializeCamera(FR.scale);
	end
end

function Ending1()
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	SetupEnding(self.followers[1]);
	self.ModelLeft:Hide();
	self.ModelRight:Hide();
	self.ModelFarLeft:Hide();
	self.ModelFarRight:Hide();
	self.ModelMiddle:Show();
	self.ModelMiddle:SetAlpha(1);
	self.ModelMiddle:SetTargetDistance(0);
	self.ModelMiddle:SetFacing(.1);
end

function Ending2()
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	SetupEnding(nil, self.followers[1], self.followers[2]);
	self.ModelLeft:Show();
	self.ModelLeft:SetAlpha(1);
	self.ModelLeft:SetTargetDistance(.2);
	self.ModelLeft:SetFacing(-.2);
	self.ModelRight:Show();
	self.ModelRight:SetAlpha(1);
	self.ModelRight:SetTargetDistance(.2);
	self.ModelRight:SetFacing(.2);
	self.ModelFarLeft:Hide();
	self.ModelFarRight:Hide();
	self.ModelMiddle:Hide();
end

function Ending3()
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	SetupEnding(self.followers[2], self.followers[1], self.followers[3]);
	self.ModelLeft:Show();
	self.ModelLeft:SetAlpha(1);
	self.ModelLeft:SetTargetDistance(.2);
	self.ModelLeft:SetFacing(-.3);
	self.ModelRight:Show();
	self.ModelRight:SetAlpha(1);
	self.ModelRight:SetTargetDistance(.2);
	self.ModelRight:SetFacing(.3);
	self.ModelFarLeft:Hide();
	self.ModelFarRight:Hide();
	self.ModelMiddle:Show();
	self.ModelMiddle:SetAlpha(1);
	self.ModelMiddle:SetTargetDistance(0);
	self.ModelMiddle:SetFacing(.1);
end

function Ending4()
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	SetupEnding(nil, self.followers[2], self.followers[3], self.followers[1], self.followers[4]);
	self.ModelLeft:Show();
	self.ModelLeft:SetAlpha(1);
	self.ModelLeft:SetTargetDistance(.1);
	self.ModelLeft:SetFacing(-.2);
	self.ModelRight:Show();
	self.ModelRight:SetAlpha(1);
	self.ModelRight:SetTargetDistance(.1);
	self.ModelRight:SetFacing(.2);
	self.ModelFarLeft:Show();
	self.ModelFarLeft:SetAlpha(1);
	self.ModelFarLeft:SetTargetDistance(.28);
	self.ModelFarLeft:SetFacing(-.3);
	self.ModelFarRight:Show();
	self.ModelFarRight:SetAlpha(1);
	self.ModelFarRight:SetTargetDistance(.28);
	self.ModelFarRight:SetFacing(.3);
	self.ModelMiddle:Hide();
end

function Ending5()
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	SetupEnding(self.followers[3], self.followers[2], self.followers[4], self.followers[1], self.followers[5]);
	self.ModelLeft:Show();
	self.ModelLeft:SetAlpha(1);
	self.ModelLeft:SetTargetDistance(.15);
	self.ModelLeft:SetFacing(-.4);
	self.ModelRight:Show();
	self.ModelRight:SetAlpha(1);
	self.ModelRight:SetTargetDistance(.15);
	self.ModelRight:SetFacing(.4);
	self.ModelFarLeft:Show();
	self.ModelFarLeft:SetAlpha(1);
	self.ModelFarLeft:SetTargetDistance(.3);
	self.ModelFarLeft:SetFacing(-.45);
	self.ModelFarRight:Show();
	self.ModelFarRight:SetAlpha(1);
	self.ModelFarRight:SetTargetDistance(.3);
	self.ModelFarRight:SetFacing(.45);
	self.ModelMiddle:Show();
	self.ModelMiddle:SetAlpha(1);
	self.ModelMiddle:SetTargetDistance(0);
	self.ModelMiddle:SetFacing(.1);
end


---------------------------------------------------------------------------------
--- Mission Complete: Stage Stuff                                             ---
---------------------------------------------------------------------------------

function GarrisonMissionCompleteStage_OnLoad(self)
	self.LocBack:SetAtlas("_GarrMissionLocation-TannanJungle-Back", true);
	self.LocMid:SetAtlas ("_GarrMissionLocation-TannanJungle-Mid", true);
	self.LocFore:SetAtlas("_GarrMissionLocation-TannanJungle-Fore", true);
	local _, backWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Back");
	local _, midWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Mid");
	local _, foreWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Fore");
	local texWidth = self.LocBack:GetWidth();
	self.LocBack:SetTexCoord(0, texWidth/backWidth, 0, 1);
	self.LocMid:SetTexCoord (0, texWidth/midWidth, 0, 1);
	self.LocFore:SetTexCoord(0, texWidth/foreWidth, 0, 1);
end

--parallax rates in % texCoords per second
local rateBack = 0.1; 
local rateMid = 0.3;
local rateFore = 0.8;

function GarrisonMissionCompleteStage_OnUpdate(self, elapsed)
	local changeBack = rateBack/100 * elapsed;
	local changeMid = rateMid/100 * elapsed;
	local changeFore = rateFore/100 * elapsed;
	
	local backL, _, _, _, backR = self.LocBack:GetTexCoord();
	local midL, _, _, _, midR = self.LocMid:GetTexCoord();
	local foreL, _, _, _, foreR = self.LocFore:GetTexCoord();
	
	backL = backL + changeBack;
	backR = backR + changeBack;
	midL = midL + changeMid;
	midR = midR + changeMid;
	foreL = foreL + changeFore;
	foreR = foreR + changeFore;
	
	if (backL >= 1) then
		backL = backL - 1;
		backR = backR - 1;
	end
	if (midL >= 1) then
		midL = midL - 1;
		midR = midR - 1;
	end
	if (foreL >= 1) then
		foreL = foreL - 1;
		foreR = foreR - 1;
	end
	
	self.LocBack:SetTexCoord(backL, backR, 0, 1);
	self.LocMid:SetTexCoord (midL, midR, 0, 1);
	self.LocFore:SetTexCoord(foreL, foreR, 0, 1);
end

---------------------------------------
-------Help plate stuff-----------
---------------------------------------

GarrisonMissionList_HelpPlate = {
	FramePos = { x = 20,          y = -22 },
	FrameSize = { width = 960, height = 620 },
	[1] = { ButtonPos = { x = 135,	y = -85 },  HighLightBox = { x = 10, y = -15, width = 305, height = 590 },	 ToolTipDir = "DOWN",  ToolTipText = "Your followers are listed here. \n \nA green arrow indicates this follower is good for the mission you are highlighting." },
	[2] = { ButtonPos = { x = 640,  y = -95 },  HighLightBox = { x = 340, y = -15, width = 605, height = 590 },  ToolTipDir = "DOWN",  ToolTipText = "Click on a mission to view." },
}

GarrisonMissionPage_HelpPlate = {
	FramePos = { x = 20,          y = -22 },
	FrameSize = { width = 960, height = 620 },
	[1] = { ButtonPos = { x = 32,	y = -55 },  HighLightBox = { x = 20, y = -50, width = 180, height = 64 },	 ToolTipDir = "DOWN",  ToolTipText = "Drag your follower to the mission to add them to the party."	},
	[2] = { ButtonPos = { x = 205,  y = -55 }, HighLightBox = { x = 205, y = -50, width = 84, height = 64 },  ToolTipDir = "DOWN",   ToolTipText = "Icons will show up if a follower can counter a threat in the mission." },
	[3] = { ButtonPos = { x = 500,  y = -175 },  HighLightBox = { x = 350, y = -150, width = 555, height = 100 }, ToolTipDir = "RIGHT",   ToolTipText = "Enemies are displayed with their threat mechanic icon. \n \nTry to counter as many threats as possible for a better chance at loot." },
	[4] = { ButtonPos = { x = 390,  y = -285 },  HighLightBox = { x = 350, y = -260, width = 555, height = 100 },  ToolTipDir = "RIGHT",		ToolTipText = "Drag your follower here to add them to the party." },
	[5] = { ButtonPos = { x = 500,  y = -475 },  HighLightBox = { x = 350, y = -400, width = 555, height = 170 },  ToolTipDir = "LEFT",  ToolTipText = "The more threats you counter, the better chance you'll have at opening a Bonus Chest when the mission completes." },
}

function GarrisonMission_ToggleTutorial()
	local helpPlate;
	if (GarrisonMissionFrame.MissionTab.MissionList:IsShown()) then
		helpPlate = GarrisonMissionList_HelpPlate;
	else
		helpPlate = GarrisonMissionPage_HelpPlate;
	end
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, GarrisonBuildingFrame, GarrisonBuildingFrame.MainHelpButton, true );
		if (GarrisonMissionFrame.MissionTab.MissionList:IsShown()) then
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_MISSION_LIST, true );
		else
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_MISSION_PAGE, true );
		end
	else
		HelpPlate_Hide(true);
	end
end

