local MOUNT_BUTTON_HEIGHT = 46;
local PLAYER_MOUNT_LEVEL = 20;
local SUMMON_RANDOM_FAVORITE_MOUNT_SPELL = 150544;
local LOCKED_EQUIPMENT_LABEL_COLOR = CreateColor(0.450, 0.392, 0.341);
local DESATURATED_EQUIPMENT_LABEL_COLOR = CreateColor(0.502, 0.502, 0.502);

local MOUNT_FACTION_TEXTURES = {
	[0] = "MountJournalIcons-Horde",
	[1] = "MountJournalIcons-Alliance"
};

local mountTypeStrings = {
	[Enum.MountType.Ground] = MOUNT_JOURNAL_FILTER_GROUND,
	[Enum.MountType.Flying] = MOUNT_JOURNAL_FILTER_FLYING,
	[Enum.MountType.Aquatic] = MOUNT_JOURNAL_FILTER_AQUATIC,
};

function MountJournal_OnLoad(self)
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED");
	self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("CURSOR_CHANGED");
	self:RegisterUnitEvent("UNIT_FORM_CHANGED", "player");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("MountListButtonTemplate", function(button, elementData)
		MountJournal_InitMountButton(button, elementData);
	end);
	view:SetPadding(0,0,44,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate, MountJournal_EvaluateListHelpTip, self);

	MountJournal_InitFilterButton(self);

	self.FilterDropdown:SetWidth(85);

end

function MountJournal_InitFilterButton(self)
	self.FilterDropdown:SetIsDefaultCallback(function()
		return C_MountJournal.IsUsingDefaultFilters();
	end);
	
	self.FilterDropdown:SetDefaultCallback(function()
		C_MountJournal.SetDefaultFilters();
	end);

	local mountSourceOrderPriorities = {
		[Enum.BattlePetSources.Drop] = 5,
		[Enum.BattlePetSources.Quest] = 5,
		[Enum.BattlePetSources.Vendor] = 5,
		[Enum.BattlePetSources.Profession] = 5,
		[Enum.BattlePetSources.Achievement] = 5,
		[Enum.BattlePetSources.WorldEvent] = 5,
		[Enum.BattlePetSources.Discovery] = 5,
		[Enum.BattlePetSources.TradingPost] = 4,
		[Enum.BattlePetSources.Promotion] = 3,
		[Enum.BattlePetSources.PetStore] = 2,
		[Enum.BattlePetSources.Tcg] = 1,
	};
	
	local function IsSourceChecked(filterIndex) 
		return C_MountJournal.IsSourceChecked(filterIndex)
	end

	local function SetSourceChecked(filterIndex) 
		C_MountJournal.SetSourceFilter(filterIndex, not IsSourceChecked(filterIndex));
	end
	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_MOUNT_COLLECTION_FILTER");

		rootDescription:CreateCheckbox(COLLECTED, MountJournal_GetCollectedFilter, function()
			MountJournal_SetCollectedFilter(not MountJournal_GetCollectedFilter());
		end);

		rootDescription:CreateCheckbox(NOT_COLLECTED, MountJournal_GetNotCollectedFilter, function()
			MountJournal_SetNotCollectedFilter(not MountJournal_GetNotCollectedFilter());
		end);
	end);
end

local function CreateContextMenu(owner, rootDescription, index)
	rootDescription:SetTag("MENU_MOUNT_COLLECTION_MOUNT");

	local isUsable, _, _, _, _, _, _, menuMountID = select(5, C_MountJournal.GetDisplayedMountInfo(index));

	local text;
	local checkEnabled = false;
	local needsFanfare = C_MountJournal.NeedsFanfare(menuMountID);
	if needsFanfare then
		text = UNWRAP;
	else
		local active = select(4, C_MountJournal.GetMountInfoByID(menuMountID));
		if active then
			text = BINDING_NAME_DISMOUNT;
		else
			text = MOUNT;
			checkEnabled = true;
		end
	end

	local button = rootDescription:CreateButton(text, function()
		if needsFanfare then
			MountJournal_Select(index);
		end
		MountJournalMountButton_UseMount(menuMountID);
	end);
	
	if checkEnabled then
		button:SetEnabled(isUsable);
	end

	if not needsFanfare then
		local favoriteButton;
		local isFavorite, canFavorite = C_MountJournal.GetIsFavorite(index);
		if isFavorite then
			favoriteButton = rootDescription:CreateButton(BATTLE_PET_UNFAVORITE, function()
				C_MountJournal.SetIsFavorite(index, false);
			end);
		else
			favoriteButton = rootDescription:CreateButton(BATTLE_PET_FAVORITE, function()
				C_MountJournal.SetIsFavorite(index, true);
			end);
		end
		favoriteButton:SetEnabled(canFavorite);
	end
end

function MountJournal_ResetMountButton(button)
	button.name:SetText("");
	button.icon:SetTexture("Interface\\PetBattles\\MountJournalEmptyIcon");
	button.index = nil;
	button.spellID = 0;
	button.selected = false;
	CollectionItemListButton_SetRedOverlayShown(button, false);
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

function MountJournal_InitMountButton(button, elementData)
	local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(elementData.index);
	local needsFanfare = C_MountJournal.NeedsFanfare(mountID);

	button.name:SetText(creatureName);
	button.icon:SetTexture(needsFanfare and COLLECTIONS_FANFARE_ICON or icon);
	button.new:SetShown(needsFanfare);
	button.newGlow:SetShown(needsFanfare);

	local yOffset = 1;
	if isForDragonriding then
		if button.name:GetNumLines() == 1 then
			yOffset = 6;
		else
			yOffset = 5;
		end
	end
	button.name:SetPoint("LEFT", button.icon, "RIGHT", 10, yOffset);
	button.index = elementData.index;
	button.spellID = spellID;
	button.mountID = mountID;

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
	CollectionItemListButton_SetRedOverlayShown(button, false);
	button.iconBorder:Hide();
	button.background:SetVertexColor(1, 1, 1, 1);
	if (isUsable or needsFanfare) then
		button.DragButton:SetEnabled(true);
		button.additionalText = nil;
		button.icon:SetDesaturated(false);
		button.icon:SetAlpha(1.0);
		button.name:SetFontObject("GameFontNormal");
	else
		if (isCollected) then
			CollectionItemListButton_SetRedOverlayShown(button, true);
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
end

function MountJournal_OnEvent(self, event, ...)
	if ( event == "MOUNT_JOURNAL_USABILITY_CHANGED" or event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" or event == "COMPANION_UPDATE" ) then
		local companionType = ...;
		if ( not companionType or companionType == "MOUNT" ) then
			MountJournal_FullUpdate(self);
		end
	elseif ( event == "MOUNT_JOURNAL_SEARCH_UPDATED" ) then
		MountJournal_FullUpdate(self);
	elseif ( event == "UI_MODEL_SCENE_INFO_UPDATED" ) then
		if (self:IsVisible()) then
			MountJournal_UpdateMountDisplay(true);
		end
	elseif ( event == "CURSOR_CHANGED" ) then
		--MountJournal_ValidateCursorDragSourceCompatible(self);
	elseif ( event == "UNIT_FORM_CHANGED" ) then
		local showPlayer = GetCVarBool("mountJournalShowPlayer");
		if(self:IsVisible() and showPlayer) then
			MountJournal_UpdateMountDisplay(true);
		end
	end
end

function MountJournal_FullUpdate(self)
	if (self:IsVisible()) then
		MountJournal_UpdateMountList();

		if (not MountJournal.selectedSpellID) then
			MountJournal_Select(self.dragonridingHelpTipMountIndex or 1);
		end

		MountJournal_UpdateMountDisplay();
	end
end

function MountJournal_OnShow(self)

	MountJournal_FullUpdate(self);
	SetPortraitToTexture(self:GetParent().portrait, "Interface\\ICONS\\Ability_Mount_RidingHorse");

	--flip the texture so it matches the microbutton
	self:GetParent().portrait:SetTexCoord(1, 0, 0, 1);

	EventRegistry:TriggerEvent("MountJournal.OnShow");
end

function MountJournal_OnHide(self)
	C_MountJournal.ClearRecentFanfares();
	EventRegistry:TriggerEvent("MountJournal.OnHide");
end

function MountJournal_UpdateMountList()
	local dragonridingHelpTipMountIndex = nil;

	local newDataProvider = CreateDataProvider();
	for index = 1, C_MountJournal.GetNumDisplayedMounts() do
		local mountID = C_MountJournal.GetDisplayedMountID(index);
		newDataProvider:Insert({index = index, mountID = mountID});
	end
	MountJournal.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition);

	MountJournal.dragonridingHelpTipMountIndex = dragonridingHelpTipMountIndex;

	local numMounts = C_MountJournal.GetNumMounts();
	MountJournal.numOwned = 0;
	local showMounts = true;
	if  ( numMounts < 1 ) then
		-- display the no mounts message on the right hand side
		MountJournal.MountDisplay.NoMounts:Show();
		showMounts = false;
	else
		local mountIDs = C_MountJournal.GetMountIDs();
		for i, mountID in ipairs(mountIDs) do
			local _, _, _, _, _, _, _, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID);
			if (isCollected and hideOnChar ~= true) then
				MountJournal.numOwned = MountJournal.numOwned + 1;
			end
		end
		MountJournal.MountDisplay.NoMounts:Hide();
	end

	MountJournal.MountCount.Count:SetText(MountJournal.numOwned);
	if ( not showMounts ) then
		MountJournal.selectedSpellID = nil;
		MountJournal.selectedMountID = nil;
		MountJournal_UpdateMountDisplay();
		MountJournal.MountCount.Count:SetText(0);
	end

	MountJournal_EvaluateListHelpTip(MountJournal);
end

function MountJournal_EvaluateListHelpTip(self)
	if self.dragonridingHelpTipMountIndex then
		local frame = self.ScrollBox:FindFrameByPredicate(function(entry, elementData)
			return entry.index == self.dragonridingHelpTipMountIndex;
		end);

		if not frame or not frame:IsShown() then
			return;
		end

		local frameTop = frame:GetTop();
		local frameBottom = frame:GetBottom();
		if not frameTop or not frameBottom then
			return;
		end

		local scrollTop = self.ScrollBox:GetTop();
		local scrollBottom = self.ScrollBox:GetBottom();
		if not scrollTop or not scrollBottom then
			return;
		end

		if (frameTop <= scrollTop + 4) and (frameBottom >= scrollBottom - 4) then
			local helpTipInfo = {
				text = MOUNT_JOURNAL_DRAGONRIDING_HELPTIP,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_MOUNT_COLLECTION_DRAGONRIDING,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = -4,
				onAcknowledgeCallback = function() self.dragonridingHelpTipMountIndex = nil; end;
			};
			HelpTip:Show(self, helpTipInfo, frame);
			return;
		end
	end
end

function MountJournalMountButton_UpdateTooltip(self)
	GameTooltip:SetMountBySpellID(self.spellID);
end

function MountJournalMountButton_ChooseFallbackMountToDisplay(mountID, random)
	local allCreatureDisplays = C_MountJournal.GetMountAllCreatureDisplayInfoByID(mountID);
	if allCreatureDisplays and #allCreatureDisplays > 0 then
		if random then
			return allCreatureDisplays[math.random(1, #allCreatureDisplays)].creatureDisplayID;
		else
			return allCreatureDisplays[1].creatureDisplayID;
		end
	end
	return 0;
end

function MountJournal_UpdateMountDisplay(forceSceneChange)
	if ( MountJournal.selectedMountID ) then
		local creatureName, spellID, icon, active, isUsable, sourceType = C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID);
		local needsFanfare = C_MountJournal.NeedsFanfare(MountJournal.selectedMountID);
		if ( MountJournal.MountDisplay.lastDisplayed ~= spellID or forceSceneChange ) then
			local creatureDisplayID, descriptionText, sourceText, isSelfMount, _, modelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID);

			if not creatureDisplayID then
				local randomSelection = false;
				creatureDisplayID = MountJournalMountButton_ChooseFallbackMountToDisplay(MountJournal.selectedMountID, randomSelection);
			end

			MountJournal.MountDisplay.InfoButton.Name:SetText(creatureName);

			if needsFanfare then
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

			MountJournal.MountDisplay.ModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);

			MountJournal.MountDisplay.ModelScene:PrepareForFanfare(needsFanfare);

			local mountActor = MountJournal.MountDisplay.ModelScene:GetActorByTag("unwrapped");
			if mountActor then
				mountActor:SetModelByCreatureDisplayID(creatureDisplayID, true);

				-- mount self idle animation
				if (isSelfMount) then
					mountActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
					mountActor:SetAnimation(618); -- MountSelfIdle
				else
					mountActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.Anim);
					mountActor:SetAnimation(0);
				end
				local showPlayer = GetCVarBool("mountJournalShowPlayer");
				if not disablePlayerMountPreview and not showPlayer then
					disablePlayerMountPreview = true;
				end
				local _, raceFilename = UnitRace("player");
				local useNativeForm = raceFilename or WantsAlteredForm();
				
				MountJournal.MountDisplay.ModelScene:AttachPlayerToMount(mountActor, animID, isSelfMount, disablePlayerMountPreview, spellVisualKitID, useNativeForm);
			end
		end

		MountJournal.MountDisplay.ModelScene:Show();
		MountJournal.MountDisplay.YesMountsTex:Show();
		MountJournal.MountDisplay.InfoButton:Show();
		MountJournal.MountDisplay.NoMountsTex:Hide();
		MountJournal.MountDisplay.NoMounts:Hide();

		if ( needsFanfare ) then
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
		MountJournal.MountDisplay.ModelScene:Hide();
		MountJournal.MountDisplay.YesMountsTex:Hide();
		MountJournal.MountDisplay.NoMountsTex:Show();
		MountJournal.MountDisplay.NoMounts:Show();
		MountJournal.MountButton:SetEnabled(false);
	end
end

function MountJournal_Select(index)
	local creatureName, spellID, icon, active, _, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(index);
	MountJournal_SetSelected(mountID, spellID);
end

function MountJournal_SelectByMountID(mountID)
	local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(mountID);
	MountJournal_SetSelected(mountID, spellID);
end

function MountJournal_GetMountButtonHeight()
	return MOUNT_BUTTON_HEIGHT;
end

function MountJournal_GetMountButtonByMountID(mountID)
	return MountJournal.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return elementData.mountID == mountID;
	end);
end

function MountJournal_SetSelected(selectedMountID, selectedSpellID)
	local oldSelectedID = MountJournal.selectedMountID;
	MountJournal.selectedSpellID = selectedSpellID;
	MountJournal.selectedMountID = selectedMountID;
	MountJournal_UpdateMountDisplay();
	
	if oldSelectedID ~= selectedMountID then
		local foundFrame = MountJournal.ScrollBox:FindFrameByPredicate(function(frame, elementData)
			return elementData.mountID == oldSelectedID;
		end);
		if foundFrame then
			MountJournal_InitMountButton(foundFrame, foundFrame:GetElementData());
		end
	end

	-- Scroll to the selected mount only if it is not in view.
	local foundFrame = MountJournal.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return elementData.mountID == selectedMountID;
	end);
	if not foundFrame then
		MountJournal.ScrollBox:ScrollToElementDataByPredicate(function(elementData)
			return elementData.mountID == selectedMountID;
		end);
	else
		MountJournal_InitMountButton(foundFrame, foundFrame:GetElementData());
	end
end

function MountJournalMountButton_UseMount(mountID)
	local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(mountID);
	if ( active ) then
		C_MountJournal.Dismiss();
	elseif ( C_MountJournal.NeedsFanfare(mountID) ) then
		local function OnFinishedCallback()
			C_MountJournal.ClearFanfare(mountID);
			MountJournal_UpdateMountList();
			MountJournal_UpdateMountDisplay();
		end

		MountJournal.MountDisplay.ModelScene:StartUnwrapAnimation(OnFinishedCallback);
	else
		C_MountJournal.SummonByID(mountID);
	end
end

function MountJournalMountButton_OnClick(self)
	if MountJournal.selectedMountID then
		MountJournalMountButton_UseMount(MountJournal.selectedMountID);
	end
end

function MountJournalMountButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self:GetText(), HIGHLIGHT_FONT_COLOR:GetRGB());

	local needsFanFare = MountJournal.selectedMountID and C_MountJournal.NeedsFanfare(MountJournal.selectedMountID);
	if needsFanFare then
		GameTooltip_AddNormalLine(GameTooltip, MOUNT_UNWRAP_TOOLTIP, true);
	else
		GameTooltip_AddNormalLine(GameTooltip, MOUNT_SUMMON_TOOLTIP, true);
	end

	if MountJournal.selectedMountID ~= nil then
		local checkIndoors = true;
		local isUsable, errorText = C_MountJournal.GetMountUsabilityByID(MountJournal.selectedMountID, checkIndoors);
		if errorText ~= nil then
			GameTooltip_AddErrorLine(GameTooltip, errorText, true);
		end
	end

	GameTooltip:Show();
end

function MountListDragButton_OnClick(self, button)
	local parent = self:GetParent();
	if ( button ~= "LeftButton" ) then
		local isCollected = select(11, C_MountJournal.GetDisplayedMountInfo(parent.index));
		if isCollected then
			MenuUtil.CreateContextMenu(self, CreateContextMenu, parent.index);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = parent.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local mountLink = C_MountJournal.GetMountLink(id);
			ChatEdit_InsertLink(mountLink);
		end
	else
		C_MountJournal.Pickup(parent.index);
	end
end

function MountListItem_OnClick(self, button)
	if ( button ~= "LeftButton" ) then
		local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetDisplayedMountInfo(self.index);
		if isCollected then
			MenuUtil.CreateContextMenu(self, CreateContextMenu, self.index);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = self.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local mountLink = C_MountJournal.GetMountLink(id);
			ChatEdit_InsertLink(mountLink);
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

function MountJournal_SetCollectedFilter(value)
	return C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, value);
end

function MountJournal_GetCollectedFilter()
	return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED);
end

function MountJournal_SetNotCollectedFilter(value)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, value);
end

function MountJournal_GetNotCollectedFilter()
	return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED);
end

function MountJournal_SetUnusableFilter(value)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE, value);
end

function MountJournal_GetUnusableFilter()
	return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE);
end

function MountJournal_SetAllSourceFilters(value)
	C_MountJournal.SetAllSourceFilters(value); 
end 

--[[
function MountJournalSummonRandomFavoriteButton_OnLoad(self)
	self.spellID = SUMMON_RANDOM_FAVORITE_MOUNT_SPELL;
	local spellName, _, spellIcon = GetSpellInfo(self.spellID);
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
]]--

PlayerPreviewToggle = {}
function PlayerPreviewToggle:OnShow()
	local showPlayer = GetCVarBool("mountJournalShowPlayer");	
	self:SetChecked(showPlayer);
end

function PlayerPreviewToggle:OnClick()
	if self:GetChecked() then
		SetCVar("mountJournalShowPlayer", 1);
	else
		SetCVar("mountJournalShowPlayer", 0);
	end
	MountJournal_UpdateMountDisplay(true);
end


