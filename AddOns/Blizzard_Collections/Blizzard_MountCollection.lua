local MOUNT_BUTTON_HEIGHT = 46;
local PLAYER_MOUNT_LEVEL = 20;
local SUMMON_RANDOM_FAVORITE_MOUNT_SPELL = 150544;

local MOUNT_FACTION_TEXTURES = {
	[0] = "MountJournalIcons-Horde",
	[1] = "MountJournalIcons-Alliance"
};

function MountJournal_OnLoad(self)
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED");
	self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED");
	self.ListScrollFrame.update = MountJournal_UpdateMountList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "MountListButtonTemplate", 44, 0);
	UIDropDownMenu_Initialize(self.mountOptionsMenu, MountOptionsMenu_Init, "MENU");
end

function MountJournal_OnEvent(self, event, ...)
	if ( event == "MOUNT_JOURNAL_USABILITY_CHANGED" or event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" or event == "COMPANION_UPDATE" ) then
		local companionType = ...;
		if ( not companionType or companionType == "MOUNT" ) then
			if (self:IsVisible()) then
				MountJournal_UpdateMountList();
				MountJournal_UpdateMountDisplay();
			end
		end
	elseif ( event == "MOUNT_JOURNAL_SEARCH_UPDATED" ) then
		if (self:IsVisible()) then
			MountJournal_UpdateMountList();
			MountJournal_UpdateMountDisplay();
		end
	end
end

function MountJournal_OnShow(self)
	MountJournal_UpdateMountList();
	if (not MountJournal.selectedSpellID) then
		MountJournal_Select(1);
	end
	MountJournal_UpdateMountDisplay();
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");
end

function MountJournal_OnHide(self)
	C_MountJournal.ClearRecentFanfares();
end

function MountJournal_UpdateMountList()
	local scrollFrame = MountJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numMounts = C_MountJournal.GetNumMounts();
	local showMounts = true;
	local playerLevel = UnitLevel("player");
	if  ( numMounts < 1 ) then
		-- display the no mounts message on the right hand side
		MountJournal.MountDisplay.NoMounts:Show();
		showMounts = false;
	else
		MountJournal.MountDisplay.NoMounts:Hide();
	end

	local numDisplayedMounts = C_MountJournal.GetNumDisplayedMounts();
	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= numDisplayedMounts and showMounts ) then
			local index = displayIndex;
			local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(index);
			local needsFanFare = C_MountJournal.NeedsFanfare(mountID);

			button.name:SetText(creatureName);
			button.icon:SetTexture(needsFanFare and COLLECTIONS_FANFARE_ICON or icon);
			button.new:SetShown(needsFanFare);
			button.newGlow:SetShown(needsFanFare);

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
			if (isUsable or needsFanFare) then
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

	local totalHeight = numDisplayedMounts * MOUNT_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
	MountJournal.MountCount.Count:SetText(MountJournal.numOwned);
	if ( not showMounts ) then
		MountJournal.selectedSpellID = nil;
		MountJournal.selectedMountID = nil;
		MountJournal_UpdateMountDisplay();
		MountJournal.MountCount.Count:SetText(0);
	end
end

function MountJournalMountButton_UpdateTooltip(self)
	GameTooltip:SetMountBySpellID(self.spellID);
end

function MountJournal_UpdateMountDisplay()
	if ( MountJournal.selectedMountID ) then
		local creatureName, spellID, icon, active, isUsable, sourceType = C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID);
		if ( MountJournal.MountDisplay.lastDisplayed ~= spellID ) then
			local creatureDisplayID, descriptionText, sourceText, isSelfMount = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID);
			local needsFanFare = C_MountJournal.NeedsFanfare(MountJournal.selectedMountID);

			MountJournal.MountDisplay.InfoButton.Name:SetText(creatureName);

			if needsFanFare then
				MountJournal.MountDisplay.InfoButton.New:Show();
				MountJournal.MountDisplay.InfoButton.NewGlow:Show();

				local offsetX = math.min(MountJournal.MountDisplay.InfoButton.Name:GetStringWidth(), MountJournal.MountDisplay.InfoButton.Name:GetWidth());
				MountJournal.MountDisplay.InfoButton.New:SetPoint("LEFT", MountJournal.MountDisplay.InfoButton.Name, "LEFT", offsetX + 8, 0);

				MountJournal.MountDisplay.InfoButton.Icon:SetTexture(COLLECTIONS_FANFARE_ICON);
			else
				MountJournal.MountDisplay.InfoButton.New:Hide();
				MountJournal.MountDisplay.InfoButton.NewGlow:Hide();

				MountJournal.MountDisplay.InfoButton.Icon:SetTexture(icon);
			end

			MountJournal.MountDisplay.InfoButton.Source:SetText(sourceText);
			MountJournal.MountDisplay.InfoButton.Lore:SetText(descriptionText)

			MountJournal.MountDisplay.lastDisplayed = spellID;

			if creatureDisplayID == 0 then
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

			if needsFanFare then
				MountJournal.MountDisplay.WrappedModelFrame:Show();
				if not MountJournal.MountDisplay.UnwrapAnim:IsPlaying() then
					MountJournal.MountDisplay.ModelFrame:SetAlpha(0);
					MountJournal.MountDisplay.WrappedModelFrame:SetAnimation(0);
					MountJournal.MountDisplay.WrappedModelFrame:SetAlpha(1);
				end
			else
				MountJournal.MountDisplay.WrappedModelFrame:Hide();
				if not MountJournal.MountDisplay.UnwrapAnim:IsPlaying() then
					MountJournal.MountDisplay.ModelFrame:SetAlpha(1);
				end
			end
		end

		MountJournal.MountDisplay.ModelFrame:Show();
		MountJournal.MountDisplay.YesMountsTex:Show();
		MountJournal.MountDisplay.InfoButton:Show();
		MountJournal.MountDisplay.NoMountsTex:Hide();
		MountJournal.MountDisplay.NoMounts:Hide();

		if (C_MountJournal.NeedsFanfare(MountJournal.selectedMountID) ) then
			MountJournal.MountButton:SetText(UNWRAP)
			MountJournal.MountButton:Enable();
		elseif ( active ) then
			MountJournal.MountButton:SetText(BINDING_NAME_DISMOUNT);
			MountJournal.MountButton:SetEnabled(isUsable);
		else
			MountJournal.MountButton:SetText(MOUNT);
			MountJournal.MountButton:SetEnabled(isUsable);
		end
	else
		MountJournal.MountDisplay.InfoButton:Hide();
		MountJournal.MountDisplay.ModelFrame:Hide();
		MountJournal.MountDisplay.YesMountsTex:Hide();
		MountJournal.MountDisplay.NoMountsTex:Show();
		MountJournal.MountDisplay.NoMounts:Show();
		MountJournal.MountButton:SetEnabled(false);
	end
end

function MountJournal_Select(index)
	local creatureName, spellID, icon, active, _, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(index);
	MountJournal.selectedSpellID = spellID;
	MountJournal.selectedMountID = mountID;
	MountJournal_HideMountDropdown();
	MountJournal_UpdateMountList();
	MountJournal_UpdateMountDisplay();
end

function MountJournal_CollectAvailableFilters()
	MountJournal.baseFilterTypes = {};
	local numSources = C_PetJournal.GetNumPetSources();

	for i = 1, numSources do
		MountJournal.baseFilterTypes[i] = false
	end
	for i = 1, C_MountJournal.GetNumDisplayedMounts() do
		local sourceType = select(6,C_MountJournal.GetDisplayedMountInfo(i))
		MountJournal.baseFilterTypes[sourceType] = true;
	end
end

function MountJournalMountButton_UseMount(mountID)
	local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(mountID);
	if ( active ) then
		C_MountJournal.Dismiss();
	elseif ( C_MountJournal.NeedsFanfare(mountID) ) then
		if MountJournal.MountDisplay.UnwrapAnim:IsPlaying() then
			return;
		end

		MountJournal.MountDisplay.WrappedModelFrame:SetAnimation(148);
		MountJournal.MountDisplay.UnwrapAnim:Play();
		PlaySound("UI_Store_Unwrap");
		C_Timer.After(.8, function()
			MountJournal.MountDisplay.ModelFrame:ApplySpellVisualKit(73393, true);
		end)
		C_Timer.After(1.6, function()
			C_MountJournal.ClearFanfare(mountID);
			MountJournal_HideMountDropdown();
			MountJournal_UpdateMountList();
			MountJournal_UpdateMountDisplay();
		end)
	else
		C_MountJournal.SummonByID(mountID);
	end
end

function MountJournalMountButton_OnClick(self)
	if MountJournal.selectedMountID then
		MountJournalMountButton_UseMount(MountJournal.selectedMountID);
	end
end

function MountListDragButton_OnClick(self, button)
	local parent = self:GetParent();
	if ( button ~= "LeftButton" ) then
		local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetDisplayedMountInfo(parent.index);
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
		C_MountJournal.Pickup(parent.index);
	end
end

function MountListItem_OnClick(self, button)
	if ( button ~= "LeftButton" ) then
		local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetDisplayedMountInfo(self.index);
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
	elseif ( self.spellID ~= MountJournal.selectedSpellID ) then
		MountJournal_Select(self.index);
	end
end

function MountJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_MountJournal.SetSearch(self:GetText());
end

function MountJournal_ClearSearch()
	MountJournal.searchBox:SetText("");
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
						C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED,value);
					end
		info.checked = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.text = NOT_COLLECTED
		info.func = function(_, _, _, value)
						C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED,value);
					end
		info.checked = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED);
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
						C_MountJournal.SetAllSourceFilters(true);
						UIDropDownMenu_Refresh(MountJournalFilterDropDown, 1, 2);
					end
		UIDropDownMenu_AddButton(info, level)

		info.text = UNCHECK_ALL
		info.func = function()
						C_MountJournal.SetAllSourceFilters(false);
						UIDropDownMenu_Refresh(MountJournalFilterDropDown, 1, 2);
					end
		UIDropDownMenu_AddButton(info, level)

		info.notCheckable = false;
		MountJournal_CollectAvailableFilters();
		local numSources = C_PetJournal.GetNumPetSources();
		for i=1,numSources do
			if ( MountJournal.baseFilterTypes[i] ) then
				info.text = _G["BATTLE_PET_SOURCE_"..i];
				info.func = function(_, _, _, value)
								C_MountJournal.SetSourceFilter(i,value);
							end
				info.checked = function() return C_MountJournal.IsSourceChecked(i) end;
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
	C_MountJournal.SummonByID(0);
end

function MountJournalSummonRandomFavoriteButton_OnDragStart(self)
	C_MountJournal.Pickup(0);
end

function MountJournalSummonRandomFavoriteButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetMountBySpellID(self.spellID);
end

function MountOptionsMenu_Init(self, level)
	if not MountJournal.menuMountIndex then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	local needsFanfare = C_MountJournal.NeedsFanfare(MountJournal.menuMountID);

	if (needsFanfare) then
		info.text = UNWRAP;
	elseif ( active ) then
		info.text = BINDING_NAME_DISMOUNT;
	else
		info.text = MOUNT;
		info.disabled = not MountJournal.menuIsUsable;
	end

	info.func = function()
		if needsFanfare then
			MountJournal_Select(MountJournal.menuMountIndex);
		end
		MountJournalMountButton_UseMount(MountJournal.menuMountID);
	end;

	UIDropDownMenu_AddButton(info, level);

	if not needsFanfare then
		info.disabled = nil;

		local canFavorite = false;
		local isFavorite = false;
		if (MountJournal.menuMountIndex) then
			 isFavorite, canFavorite = C_MountJournal.GetIsFavorite(MountJournal.menuMountIndex);
		end

		if (isFavorite) then
			info.text = BATTLE_PET_UNFAVORITE;
			info.func = function()
				C_MountJournal.SetIsFavorite(MountJournal.menuMountIndex, false);
			end
		else
			info.text = BATTLE_PET_FAVORITE;
			info.func = function()
				C_MountJournal.SetIsFavorite(MountJournal.menuMountIndex, true);
			end
		end

		if (canFavorite) then
			info.disabled = false;
		else
			info.disabled = true;
		end

		UIDropDownMenu_AddButton(info, level);
	end

	info.disabled = nil;
	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

function MountJournal_ShowMountDropdown(index, anchorTo, offsetX, offsetY)
	if (index) then
		MountJournal.menuMountIndex = index;
		MountJournal.menuMountID = select(12, C_MountJournal.GetDisplayedMountInfo(MountJournal.menuMountIndex));
		local active, isUsable = select(4, C_MountJournal.GetDisplayedMountInfo(index));
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