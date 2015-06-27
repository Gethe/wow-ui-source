local MOUNT_BUTTON_HEIGHT = 46;
local PLAYER_MOUNT_LEVEL = 20;
local SUMMON_RANDOM_FAVORITE_MOUNT_SPELL = 150544;

local MOUNT_FACTION_TEXTURES = {
	[0] = "MountJournalIcons-Horde",
	[1] = "MountJournalIcons-Alliance"
};

function MountJournal_GetNumMounts()
	return C_MountJournal.GetNumMounts();
end

function MountJournal_GetMountInfo(index)
	return C_MountJournal.GetMountInfo(index);
end

function MountJournal_GetMountInfoExtra(index)
	return C_MountJournal.GetMountInfoExtra(index);
end

function MountJournal_Pickup(index)
	return C_MountJournal.Pickup(index);
end

function MountJournal_Dismiss()
	return C_MountJournal.Dismiss();
end

function MountJournal_Summon(index)
	return C_MountJournal.Summon(index);
end

function MountJournal_SetIsFavorite(index,value)
	C_MountJournal.SetIsFavorite(index, value);
	MountJournal_DirtyList(MountJournal);
	MountJournal_UpdateMountList();
end

function MountJournal_GetIsFavorite(index)
	return C_MountJournal.GetIsFavorite(index);
end

function MountJournal_GetCollectedFilterSetting(flag)
	return C_MountJournal.GetCollectedFilterSetting(flag);
end

function MountJournal_SetCollectedFilterSetting(flag,value)
	C_MountJournal.SetCollectedFilterSetting(flag,value);
	MountJournal_DirtyList(MountJournal);
end

function MountJournal_OnLoad(self)
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED");
	self.ListScrollFrame.update = MountJournal_UpdateMountList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "MountListButtonTemplate", 44, 0);
	UIDropDownMenu_Initialize(self.mountOptionsMenu, MountOptionsMenu_Init, "MENU");

	MountJournal_InitializeFilter();
end

function MountJournal_OnEvent(self, event, ...)
	if ( event == "MOUNT_JOURNAL_USABILITY_CHANGED" or event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" or event == "COMPANION_UPDATE" ) then
		local companionType = ...;
		if ( not companionType or companionType == "MOUNT" ) then
			if ( event ~= "COMPANION_UPDATE" ) then
				--Companion updates don't change who's on our list.
				MountJournal_DirtyList(self);
			end

			if (self:IsVisible()) then
				MountJournal_UpdateMountList();
				MountJournal_UpdateMountDisplay();
			end
		end
	end
end

function MountJournal_OnShow(self)
	MountJournal_UpdateMountList();
	local index = MountJournal_FindSelectedIndex();
	if ( not index and MountJournal.cachedMounts and #MountJournal.cachedMounts > 0 ) then
		MountJournal_Select(MountJournal.cachedMounts[1]);
	elseif (not index) then
		MountJournal_Select(1);
	end
	MountJournal_UpdateMountDisplay();
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");
end

function MountJournal_DirtyList(self)
	self.dirtyList = true;
end

function MountJournal_UpdateCachedList(self)
	if ( self.cachedMounts and not self.dirtyList ) then
		return;
	end
	self.cachedMounts = {};
	self.sortVal = {};
	self.numOwned = 0;

	for i=1, MountJournal_GetNumMounts() do
		local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, _, _, hideOnChar, isCollected = MountJournal_GetMountInfo(i);

		if ( hideOnChar ~= true and MountJournal_MountMatchesFilter(self, creatureName, sourceType, isCollected ) ) then
			self.cachedMounts[#self.cachedMounts + 1] = i;
			self.sortVal[i] = MountJournal_GetMountSortVal(self, isUsable, sourceType, isFavorite, isCollected);
		end
		if (isCollected and hideOnChar ~= true) then
			self.numOwned = self.numOwned + 1;
		end
	end

	local comparison = function(index1, index2)
		return MountJournal_SortComparison(self, index1, index2);
	end

	table.sort(self.cachedMounts, comparison);
	self.sortVal = {};

	self.dirtyList = false;
end

function MountJournal_GetMountSortVal(self, isUsable, sourceType, isFavorite, isCollected)
	local sortOrder = 3;
	if (isFavorite) then
		sortOrder = 1
	elseif (isCollected) then
		sortOrder = 2
	end

	return sortOrder;
end

function MountJournal_SortComparison(self, index1, index2)
	local sortTest1 = self.sortVal[index1];
	local sortTest2 = self.sortVal[index2];

	local sortVal = sortTest1 - sortTest2;
	if (sortVal < 0) then
		return true;
	elseif (sortVal == 0) then
		return (index1 < index2);	-- from C side elements are alphabetically sorted
	else
		return false;
	end
end

function MountJournal_MountMatchesFilter(self, name, sourceType, collected)
	if ( self.searchString ) then
		if ( string.find(CaseAccentInsensitiveParse(name), self.searchString, 1, true) ) then
			return true;
		else
			return false;
		end
	end

	if ( not MountJournal_GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED) and collected ) then
		return false;
	end

	if ( not MountJournal_GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED) and not collected ) then
		return false;
	end

	return MountJournal_IsSourceNotFiltered(sourceType);
end

function MountJournal_UpdateMountList()
	MountJournal_UpdateCachedList(MountJournal);

	local scrollFrame = MountJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numMounts = MountJournal_GetNumMounts();

	local showMounts = true;
	local playerLevel = UnitLevel("player");
	if  ( numMounts < 1 ) then
		-- display the no mounts message on the right hand side
		MountJournal.MountDisplay.NoMounts:Show();
		showMounts = false;
	else
		MountJournal.MountDisplay.NoMounts:Hide();
	end

	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= #MountJournal.cachedMounts and showMounts ) then
			local index = MountJournal.cachedMounts[displayIndex];
			local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, _, isCollected = MountJournal_GetMountInfo(index);

			button.name:SetText(creatureName);
			button.icon:SetTexture(icon);
			button.index = index;
			button.spellID = spellID;

			button.active = active;
			if (active) then
				button.DragButton.ActiveTexture:Show();
			else
				button.DragButton.ActiveTexture:Hide();
			end
			button:Show();
			
			if ( MountJournal.selectedSpellID == spellID ) then
				button.selected = true;
				button.selectedTexture:Show();
			else
				button.selected = false;
				button.selectedTexture:Hide();
			end
			button:SetEnabled(true);
			button.unusable:Hide();
			button.iconBorder:Hide();
			button.background:SetVertexColor(1, 1, 1, 1);
			if (isUsable) then
				button.DragButton:SetEnabled(true);
				button.additionalText = nil;
				button.icon:SetDesaturated(false);
				button.icon:SetAlpha(1.0);
				button.name:SetFontObject("GameFontNormal");				
			else
				if (isCollected) then
					button.unusable:Show();
					button.DragButton:SetEnabled(true);
					button.name:SetFontObject("GameFontNormal");
					button.icon:SetAlpha(0.75);
					button.additionalText = nil;
					button.background:SetVertexColor(1, 0, 0, 1);
				else
					button.icon:SetDesaturated(true);
					button.DragButton:SetEnabled(false);
					button.icon:SetAlpha(0.25);
					button.additionalText = nil;
					button.name:SetFontObject("GameFontDisable");
				end			
			end

			if ( isFavorite ) then
				button.favorite:Show();
			else
				button.favorite:Hide();
			end

			if ( isFactionSpecific ) then
				button.factionIcon:SetAtlas(MOUNT_FACTION_TEXTURES[faction], true);
				button.factionIcon:Show();
			else
				button.factionIcon:Hide();
			end

			if ( button.showingTooltip ) then
				MountJournalMountButton_UpdateTooltip(button);
			end
		else
			button.name:SetText("");
			button.icon:SetTexture("Interface\\PetBattles\\MountJournalEmptyIcon");
			button.index = nil;
			button.spellID = 0;
			button.selected = false;
			button.unusable:Hide();
			button.DragButton.ActiveTexture:Hide();
			button.selectedTexture:Hide();
			button:SetEnabled(false);
			button.DragButton:SetEnabled(false);
			button.icon:SetDesaturated(true);
			button.icon:SetAlpha(0.5);
			button.favorite:Hide();
			button.factionIcon:Hide();
			button.background:SetVertexColor(1, 1, 1, 1);
			button.iconBorder:Hide();
		end
	end

	local totalHeight = #MountJournal.cachedMounts * MOUNT_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
	MountJournal.MountCount.Count:SetText(MountJournal.numOwned);
	if ( not showMounts ) then
		MountJournal.selectedSpellID = 0;
		MountJournal_UpdateMountDisplay();
		MountJournal.MountCount.Count:SetText(0);
	end
end

function MountJournalMountButton_UpdateTooltip(self)
	GameTooltip:SetMountBySpellID(self.spellID);
end

function MountJournal_UpdateMountDisplay()
	local index = MountJournal_FindSelectedIndex();

	if ( index ) then
		local creatureName, spellID, icon, active, isUsable, sourceType = MountJournal_GetMountInfo(index);
		if ( MountJournal.MountDisplay.lastDisplayed ~= spellID ) then
			local creatureDisplayID, descriptionText, sourceText, isSelfMount = MountJournal_GetMountInfoExtra(index);

			MountJournal.MountDisplay.InfoButton.Name:SetText(creatureName);
			MountJournal.MountDisplay.InfoButton.Icon:SetTexture(icon);
			
			MountJournal.MountDisplay.InfoButton.Source:SetText(sourceText);
			MountJournal.MountDisplay.InfoButton.Lore:SetText(descriptionText)

			MountJournal.MountDisplay.lastDisplayed = spellID;

			if (creatureDisplayID == 0) then
				local raceID = UnitRace("player");
				local gender = UnitSex("player");
				MountJournal.MountDisplay.ModelFrame:SetCustomRace(raceID, gender);
			else
				MountJournal.MountDisplay.ModelFrame:SetDisplayInfo(creatureDisplayID);
			end

			-- mount self idle animation
			if (isSelfMount) then
				MountJournal.MountDisplay.ModelFrame:SetDoBlend(false);
				MountJournal.MountDisplay.ModelFrame:SetAnimation(618, -1); -- MountSelfIdle
			end

		end

		MountJournal.MountDisplay.ModelFrame:Show();
		MountJournal.MountDisplay.YesMountsTex:Show();
		MountJournal.MountDisplay.InfoButton:Show();
		MountJournal.MountDisplay.NoMountsTex:Hide();
		MountJournal.MountDisplay.NoMounts:Hide();

		if ( active ) then
			MountJournal.MountButton:SetText(BINDING_NAME_DISMOUNT);
		else
			MountJournal.MountButton:SetText(MOUNT);
		end

		MountJournal.MountButton:SetEnabled(isUsable);
	else
		MountJournal.MountDisplay.InfoButton:Hide();
		MountJournal.MountDisplay.ModelFrame:Hide();
		MountJournal.MountDisplay.YesMountsTex:Hide();
		MountJournal.MountDisplay.NoMountsTex:Show();
		MountJournal.MountDisplay.NoMounts:Show();
		MountJournal.MountButton:SetEnabled(false);
	end
end

function MountJournal_FindSelectedIndex()
	local selectedSpellID = MountJournal.selectedSpellID;
	if ( selectedSpellID ) then
		for i=1, MountJournal_GetNumMounts() do
			local creatureName, spellID, icon, active = MountJournal_GetMountInfo(i);
			if ( spellID == selectedSpellID ) then
				return i;
			end
		end
	end

	return nil;
end

function MountJournal_Select(index)
	local creatureName, spellID, icon, active = MountJournal_GetMountInfo(index);
	MountJournal.selectedSpellID = spellID;
	MountJournal_HideMountDropdown();
	MountJournal_UpdateMountList();
	MountJournal_UpdateMountDisplay();
end

function MountJournal_GetSelectedSpellID()
	return MountJournal.selectedSpellID;
end

function MountJournal_CollectAvailableFilters()
	MountJournal.baseFilterTypes = {};
	local numSources = C_PetJournal.GetNumPetSources();

	for i = 1, numSources do
		MountJournal.baseFilterTypes[i] = false
	end
	for i = 1, MountJournal_GetNumMounts() do
		local sourceType = select(6,MountJournal_GetMountInfo(i))
		MountJournal.baseFilterTypes[sourceType] = true;
	end
end

function MountJournal_InitializeFilter()
	MountJournal.filterTypes = {};
	MountJournal_AddAllSources();
end

function MountJournal_AddAllSources()
	local numSources = C_PetJournal.GetNumPetSources();
	for i=1,numSources do
		MountJournal.filterTypes[i] = true
	end

	MountJournal_DirtyList(MountJournal);
end

function MountJournal_ClearAllSources()
	local numSources = C_PetJournal.GetNumPetSources();
	for i=1,numSources do
		MountJournal.filterTypes[i] = false
	end
	MountJournal_DirtyList(MountJournal);
end

function MountJournal_IsSourceNotFiltered(sourceType)
	if ( not MountJournal.filterTypes or (sourceType == 0) ) then
		return true;
	end
	return MountJournal.filterTypes[sourceType]
end

function MountJournal_SetSourceFilter(sourceType,value)
	MountJournal.filterTypes[sourceType] = value;
	MountJournal_DirtyList(MountJournal);
end

function MountJournalMountButton_OnClick(self)
	local index = MountJournal_FindSelectedIndex();
	if ( index ) then
		local creatureName, spellID, icon, active = MountJournal_GetMountInfo(index);
		if ( active ) then
			MountJournal_Dismiss();
		else
			MountJournal_Summon(index);
		end
	end
end

function MountListDragButton_OnClick(self, button)
	local parent = self:GetParent();
	if ( button ~= "LeftButton" ) then
		local _, _, _, _, _, _, _, _, _, _, isCollected = MountJournal_GetMountInfo(parent.index);
		if isCollected then
			MountJournal_ShowMountDropdown(parent.index, self, 0, 0);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = parent.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local spellLink = GetSpellLink(id)
			ChatEdit_InsertLink(spellLink);
		end
	else
		MountJournal_Pickup(parent.index);
	end
end

function MountListItem_OnClick(self, button)
	if ( button ~= "LeftButton" ) then
		local _, _, _, _, _, _, _, _, _, _, isCollected = MountJournal_GetMountInfo(self.index);
		if isCollected then
			MountJournal_ShowMountDropdown(self.index, self, 0, 0);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = self.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local spellLink = GetSpellLink(id)
			ChatEdit_InsertLink(spellLink);
		end
	elseif ( self.spellID ~= MountJournal_GetSelectedSpellID() ) then
		MountJournal_Select(self.index);
	end
end

function MountJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	local text = self:GetText();
	local oldText = MountJournal.searchString;
	if ( text == "" ) then
		MountJournal.searchString = nil;
	else
		MountJournal.searchString = CaseAccentInsensitiveParse(text);
	end

	if ( oldText ~= MountJournal.searchString ) then
		MountJournal_DirtyList(MountJournal);
		MountJournal_UpdateMountList(MountJournal);
	end
end

function MountJournalFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, MountJournalFilterDropDown_Initialize, "MENU");
end

function MountJournalFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;	

	if level == 1 then
		info.text = COLLECTED
		info.func = function(_, _, _, value)
						MountJournal_SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED,value);
						MountJournal_UpdateMountList();
					end 
		info.checked = MountJournal_GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.text = NOT_COLLECTED
		info.func = function(_, _, _, value)
						MountJournal_SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED,value);
						MountJournal_UpdateMountList();
					end 
		info.checked = MountJournal_GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
	
		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;
		
		info.text = SOURCES;
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)
	else --if level == 2 then
		info.hasArrow = false;
		info.isNotRadio = true;
		info.notCheckable = true;
			
		info.text = CHECK_ALL
		info.func = function()
						MountJournal_AddAllSources();
						UIDropDownMenu_Refresh(MountJournalFilterDropDown, 1, 2);
						MountJournal_UpdateMountList();
					end
		UIDropDownMenu_AddButton(info, level)
		
		info.text = UNCHECK_ALL
		info.func = function()
						MountJournal_ClearAllSources();
						UIDropDownMenu_Refresh(MountJournalFilterDropDown, 1, 2);
						MountJournal_UpdateMountList();
					end
		UIDropDownMenu_AddButton(info, level)

		info.notCheckable = false;
		MountJournal_CollectAvailableFilters();
		local numSources = C_PetJournal.GetNumPetSources();
		for i=1,numSources do
			if ( MountJournal.baseFilterTypes[i] ) then
				info.text = _G["BATTLE_PET_SOURCE_"..i];
				info.func = function(_, _, _, value)
								MountJournal_SetSourceFilter(i,value);
								MountJournal_UpdateMountList();
							end
				info.checked = function() return MountJournal_IsSourceNotFiltered(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end

function MountJournalSummonRandomFavoriteButton_OnLoad(self)
	self.spellID = SUMMON_RANDOM_FAVORITE_MOUNT_SPELL;
	local spellName, spellSubname, spellIcon = GetSpellInfo(self.spellID);
	self.texture:SetTexture(spellIcon);
	-- Use the global string instead of the spellName from the db here so that we can have custom newlines in the string
	self.spellname:SetText(MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT);
	self:RegisterForDrag("LeftButton");
end

function MountJournalSummonRandomFavoriteButton_OnClick(self)
	MountJournal_Summon(0);
end

function MountJournalSummonRandomFavoriteButton_OnDragStart(self)
	MountJournal_Pickup(0);
end

function MountJournalSummonRandomFavoriteButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetMountBySpellID(self.spellID);
end

function MountOptionsMenu_Init(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
		
	info.text = BATTLE_PET_SUMMON;
	info.func = function() MountJournal_Summon(MountJournal.menuMountID) end
	if (MountJournal.menuMountID and MountJournal.active) then
		info.text = PET_DISMISS;
		info.func = function() MountJournal_Dismiss() end
	end
	if ( MountJournal.menuMountID and MountJournal.menuIsUsable ) then
		info.disabled = false;
	else
		info.disabled = true;
	end
	UIDropDownMenu_AddButton(info, level);
	info.disabled = nil;

	local canFavorite = false;
	local isFavorite = false;
	if (MountJournal.menuMountID) then
		 isFavorite, canFavorite = MountJournal_GetIsFavorite(MountJournal.menuMountID);
	end

	if (isFavorite) then
		info.text = BATTLE_PET_UNFAVORITE;
		info.func = function() 
			MountJournal_SetIsFavorite(MountJournal.menuMountID, false);
		end
	else
		info.text = BATTLE_PET_FAVORITE;
		info.func = function() 
			MountJournal_SetIsFavorite(MountJournal.menuMountID, true); 
		end
	end

	if (canFavorite) then
		info.disabled = false;
	else
		info.disabled = true;
	end

	UIDropDownMenu_AddButton(info, level);
	info.disabled = nil;
	
	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

function MountJournal_ShowMountDropdown(index, anchorTo, offsetX, offsetY)
	if (index) then
		MountJournal.menuMountID = index;
		local active, isUsable = select(4, MountJournal_GetMountInfo(index));
		MountJournal.active = active;
		MountJournal.menuIsUsable = isUsable;
	else
		return;
	end
	ToggleDropDownMenu(1, nil, MountJournal.mountOptionsMenu, anchorTo, offsetX, offsetY);
end

function MountJournal_HideMountDropdown()
	if (UIDropDownMenu_GetCurrentDropDown() == MountJournal.mountOptionsMenu) then
		HideDropDownMenu(1);
	end
end