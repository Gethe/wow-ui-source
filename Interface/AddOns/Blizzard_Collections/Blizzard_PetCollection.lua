local COMPANION_BUTTON_HEIGHT = 46;
local MAX_ACTIVE_PETS = 3;
local NUM_PET_ABILITIES = 6;
PET_ACHIEVEMENT_CATEGORY = 15117;
local MAX_PET_LEVEL = 25;
local HEAL_PET_SPELL = 125439;
local SUMMON_RANDOM_FAVORITE_PET_SPELL = 243819;

local UNLOCK_REQUIREMENTS = {
	[1] = {requirement = "SPELL", id = "119467"},
	[2] = {requirement = "ACHIEVEMENT", id = "7433"},
	[3] = {requirement = "ACHIEVEMENT", id = "6566"}
};

StaticPopupDialogs["BATTLE_PET_RENAME"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button3 = PET_RENAME_DEFAULT_LABEL,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 16,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		C_PetJournal.SetCustomName(self.data, text);
		PetJournal_UpdateAll();
	end,
	OnAlt = function(self)
		C_PetJournal.SetCustomName(self.data, "");
		PetJournal_UpdateAll();
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local text = parent.editBox:GetText();
		C_PetJournal.SetCustomName(parent.data, text);
		PetJournal_UpdateAll();
		parent:Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BATTLE_PET_PUT_IN_CAGE"] = {
	text = PET_PUT_IN_CAGE_LABEL,
	button1 = OKAY,
	button2 = CANCEL,
	maxLetters = 30,
	OnAccept = function(self)
		PetJournal_SetPendingCage(self.data);
		C_PetJournal.CagePetByID(self.data);
		if (PetJournalPetCard.petID == self.data) then
			PetJournal_ShowPetCard(1);
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BATTLE_PET_RELEASE"] = {
	-- Adding extra line breaks as a hack to make this look more distinct from the "Put In Cage" dialog
	text = "\n\n" .. PET_RELEASE_LABEL .. "\n\n",
	button1 = OKAY,
	button2 = CANCEL,
	maxLetters = 30,
	OnAccept = function(self)
		C_PetJournal.ReleasePetByID(self.data);
		if (PetJournalPetCard.petID == self.data) then
			PetJournal_ShowPetCard(1);
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	showAlert = 1,
};

function PetJournalUtil_GetDisplayName(petID)
	local _, customName, _, _, _, _, _, petName = C_PetJournal.GetPetInfoByPetID(petID);
	if ( customName ) then
		return customName;
	else
		return petName;
	end
end

function PetJournal_OnLoad(self)
	self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
	self:RegisterEvent("PET_JOURNAL_PET_DELETED");
	self:RegisterEvent("PET_JOURNAL_PETS_HEALED");
	self:RegisterEvent("PET_JOURNAL_CAGE_FAILED");
	self:RegisterEvent("BATTLE_PET_CURSOR_CLEAR");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED");
	self:RegisterEvent("PET_BATTLE_QUEUE_STATUS");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CompanionListButtonTemplate", function(button, elementData)
		PetJournal_InitPetButton(button, elementData);
	end);
	view:SetPadding(0,0,44,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	PetJournal_InitFilterDropdown(self);

	PetJournal_ShowPetCard(1);
end

function PetJournal_InitFilterDropdown(self)
	self.FilterDropdown:SetWidth(90);

	self.FilterDropdown:SetIsDefaultCallback(function()
		return C_PetJournal.IsUsingDefaultFilters();
	end);
	
	self.FilterDropdown:SetDefaultCallback(function()
		C_PetJournal.SetDefaultFilters();
	end);

	local function IsFamilyChecked(filterIndex) 
		return C_PetJournal.IsPetTypeChecked(filterIndex)
	end

	local function SetFamilyChecked(filterIndex) 
		C_PetJournal.SetPetTypeFilter(filterIndex, not IsFamilyChecked(filterIndex));
	end
	
	local function IsSourceChecked(filterIndex) 
		return C_PetJournal.IsPetSourceChecked(filterIndex)
	end

	local function SetSourceChecked(filterIndex) 
		C_PetJournal.SetPetSourceChecked(filterIndex, not IsSourceChecked(filterIndex));
	end
	
	local function IsSortByChecked(parameter) 
		return C_PetJournal.GetPetSortParameter() == parameter;
	end

	local function SetSortByChecked(parameter) 
		C_PetJournal.SetPetSortParameter(parameter); 
		PetJournal_UpdatePetList(); 
	end
	
	local petSourceOrderPriorities = {
		[Enum.BattlePetSources.Drop] = 5,
		[Enum.BattlePetSources.Quest] = 5,
		[Enum.BattlePetSources.Vendor] = 5,
		[Enum.BattlePetSources.Profession] = 5,
		[Enum.BattlePetSources.WildPet] = 5,
		[Enum.BattlePetSources.Achievement] = 5,
		[Enum.BattlePetSources.WorldEvent] = 5,
		[Enum.BattlePetSources.Discovery] = 5,
		[Enum.BattlePetSources.TradingPost] = 4,
		[Enum.BattlePetSources.Promotion] = 3,
		[Enum.BattlePetSources.PetStore] = 2,
		[Enum.BattlePetSources.Tcg] = 1,
	};

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PET_COLLECTION_FILTER");

		rootDescription:CreateCheckbox(COLLECTED, PetJournalFilterDropdown_GetCollectedFilter, function()
			PetJournalFilterDropdown_SetCollectedFilter(not PetJournalFilterDropdown_GetCollectedFilter());
		end);

		rootDescription:CreateCheckbox(NOT_COLLECTED, PetJournalFilterDropdown_GetNotCollectedFilter, function()
			PetJournalFilterDropdown_SetNotCollectedFilter(not PetJournalFilterDropdown_GetNotCollectedFilter());
		end);
		
		local familiesSubmenu = rootDescription:CreateButton(PET_FAMILIES);
		familiesSubmenu:CreateButton(CHECK_ALL, PetJournalFilterDropdown_SetAllPetTypes, true);
		familiesSubmenu:CreateButton(UNCHECK_ALL, PetJournalFilterDropdown_SetAllPetTypes, false);

		for filterIndex = 1, C_PetJournal.GetNumPetTypes() do
			familiesSubmenu:CreateCheckbox(_G["BATTLE_PET_NAME_"..filterIndex], IsFamilyChecked, SetFamilyChecked, filterIndex);
		end
		
		local sourceSubmenu = rootDescription:CreateButton(SOURCES);
		sourceSubmenu:CreateButton(CHECK_ALL, PetJournalFilterDropdown_SetAllPetSources, true);
		sourceSubmenu:CreateButton(UNCHECK_ALL, PetJournalFilterDropdown_SetAllPetSources, false);

		local filterIndexList = CollectionsUtil.GetSortedFilterIndexList("BATTLEPETS", petSourceOrderPriorities);
		for index = 1, C_PetJournal.GetNumPetSources() do
			local filterIndex = filterIndexList[i] and filterIndexList[i].index or index;
			sourceSubmenu:CreateCheckbox(_G["BATTLE_PET_SOURCE_"..filterIndex], IsSourceChecked, SetSourceChecked, filterIndex);
		end
		
		local sortBySubmenu = rootDescription:CreateButton(RAID_FRAME_SORT_LABEL);
		sortBySubmenu:CreateRadio(NAME, IsSortByChecked, SetSortByChecked, LE_SORT_BY_NAME);
		sortBySubmenu:CreateRadio(LEVEL, IsSortByChecked, SetSortByChecked, LE_SORT_BY_LEVEL);
		sortBySubmenu:CreateRadio(RARITY, IsSortByChecked, SetSortByChecked, LE_SORT_BY_RARITY);
		sortBySubmenu:CreateRadio(TYPE, IsSortByChecked, SetSortByChecked, LE_SORT_BY_PETTYPE);
	end);
end

function PetJournal_OnShow(self)
	PetJournal_UpdatePetList();
	PetJournal_UpdatePetLoadOut();
	PetJournal_UpdatePetCard(PetJournalPetCard);

	self:RegisterEvent("ACHIEVEMENT_EARNED");
	PetJournal.AchievementStatus.SumText:SetText(GetCategoryAchievementPoints(PET_ACHIEVEMENT_CATEGORY, true));

	-- check to show the help plate
	if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL) ) then
		local helpPlate = PetJournal_HelpPlate;
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
			HelpPlate_ShowTutorialPrompt( helpPlate, PetJournal.MainHelpButton );
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true );
		end
	end

	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\PetJournalPortrait");
end

function PetJournal_OnHide(self)
	self:UnregisterEvent("ACHIEVEMENT_EARNED");
	PetJournal.SpellSelect:Hide();
	HelpPlate_Hide();
	C_PetJournal.ClearRecentFanfares();
end

function PetJournal_OnEvent(self, event, ...)
	if event == "PET_BATTLE_LEVEL_CHANGED" then
		PetJournal_UpdatePetLoadOut();
	elseif event == "PET_JOURNAL_PET_DELETED" then
		local petID = ...;
		if (PetJournal_IsPendingCage(petID)) then
			PetJournal_ClearPendingCage();
		end
		PetJournal_UpdatePetList();
		PetJournal_UpdatePetLoadOut();
		if(PetJournalPetCard.petID == petID) then
			PetJournal_ShowPetCard(1);
		end
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetCard(PetJournalPetCard);
	elseif event == "PET_JOURNAL_CAGE_FAILED" then
		PetJournal_ClearPendingCage();
	elseif event == "PET_JOURNAL_PETS_HEALED" then
		PetJournal_UpdatePetLoadOut();
	elseif event == "PET_JOURNAL_LIST_UPDATE" then
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetList();
		PetJournal_UpdatePetLoadOut();
		PetJournal_UpdatePetCard(PetJournalPetCard);
	elseif event == "BATTLE_PET_CURSOR_CLEAR" then
		PetJournal.Loadout.Pet1.setButton:Hide();
		PetJournal.Loadout.Pet2.setButton:Hide();
		PetJournal.Loadout.Pet3.setButton:Hide();
	elseif event == "COMPANION_UPDATE" then
		local companionType = ...;
		if companionType == "CRITTER" then
			PetJournal_UpdatePetList();
			PetJournal_UpdateSummonButtonState();
		end
	elseif event == "ACHIEVEMENT_EARNED" then
		PetJournal.AchievementStatus.SumText:SetText(GetCategoryAchievementPoints(PET_ACHIEVEMENT_CATEGORY, true));
	elseif event == "PET_BATTLE_QUEUE_STATUS" then
		PetJournal_UpdatePetLoadOut();
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		if (self:IsVisible()) then
			PetJournal_UpdatePetCard(PetJournalPetCard, true);
			PetJournal_UpdatePetLoadOut(true);
		end
	end
end

function PetJournal_SelectSpecies(self, targetSpeciesID)
	local function FindPet(frame, elementData)
		return frame.speciesID == targetSpeciesID;
	end;

	local foundFrame = self.ScrollBox:FindFrameByPredicate(FindPet);
	if not foundFrame then
		self.ScrollBox:ScrollToElementDataByPredicate(FindPet);
	end

	PetJournal_ShowPetCardBySpeciesID(targetSpeciesID);
end

function PetJournal_SelectPet(self, petID)
	local function FindPet(frame, elementData)
		return frame.petID == petID;
	end;

	local foundFrame = self.ScrollBox:FindFrameByPredicate(FindPet);
	if not foundFrame then
		self.ScrollBox:ScrollToElementDataByPredicate(FindPet);
	end

	PetJournal_ShowPetCardByID(petID);
end

function PetJournal_UpdateSummonButtonState()
	local petID = PetJournalPetCard.petID;
	local hasPetID = petID ~= nil;
	local needsFanfare = hasPetID and C_PetJournal.PetNeedsFanfare(petID);

	PetJournal.SummonButton:SetEnabled(hasPetID and (C_PetJournal.PetIsSummonable(petID) or needsFanfare));

	if hasPetID and petID == C_PetJournal.GetSummonedPetGUID() then
		PetJournal.SummonButton:SetText(PET_DISMISS);
	elseif needsFanfare then
		PetJournal.SummonButton:SetText(UNWRAP);
	else
		PetJournal.SummonButton:SetText(BATTLE_PET_SUMMON);
	end

	if (GameTooltip:GetOwner() == PetJournal.SummonButton) then
		PetJournalSummonButton_OnEnter(PetJournal.SummonButton);
	end
end

function PetJournalHealPetButton_OnLoad(self)
	self.spellID = HEAL_PET_SPELL;
	local spellInfo = C_Spell.GetSpellInfo(self.spellID);
	self.texture:SetTexture(spellInfo.iconID);
	self.spellname:SetText(spellInfo.name);
end

function PetJournalHealPetButton_OnShow(self)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("PET_BATTLE_OPENING_START");
	self:RegisterEvent("PET_BATTLE_CLOSE");
	PetJournalHealPetButton_UpdateCooldown(self);
	PetJournalHealPetButton_UpdateUsability(self);
end

function PetJournalHealPetButton_OnHide(self)
	self:UnregisterEvent("PET_BATTLE_OPENING_START");
	self:UnregisterEvent("PET_BATTLE_CLOSE");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	if (self:IsEventRegistered("SPELLS_CHANGED")) then
		self:UnregisterEvent("SPELLS_CHANGED");
	end
end

function PetJournalHealPetButton_OnDragStart(self)
	C_Spell.PickupSpell(self.spellID);
end

function PetJournalHealPetButton_UpdateUsability(self)
	if (IsSpellKnown(self.spellID) and C_PetJournal.IsJournalUnlocked()) then
		if (C_PetBattles.IsInBattle() or not C_Spell.IsSpellUsable(self.spellID) ) then
			self:SetButtonState("NORMAL", true);
			self.texture:SetDesaturated(true);
			self.LockIcon:Show();
			self.BlackCover:Show();
		else
			self:SetButtonState("NORMAL", false);
			self.texture:SetDesaturated(false);
			self.LockIcon:Hide();
			self.BlackCover:Hide();
			self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
			self:RegisterForDrag("LeftButton");
		end
		if (self:IsEventRegistered("SPELLS_CHANGED")) then
			self:UnregisterEvent("SPELLS_CHANGED");
		end
	else
		self.BlackCover:Show();
		self.texture:SetDesaturated(true);
	end
end

function PetJournalHealPetButton_OnEvent(self, event, ...)
	if ( event == "SPELL_UPDATE_COOLDOWN" ) then
		PetJournalHealPetButton_UpdateCooldown(self);
		-- Update tooltip
		if ( GameTooltip:GetOwner() == self ) then
			PetJournalHealPetButton_OnEnter(self);
		end
	elseif ( event == "SPELLS_CHANGED" or event == "PET_BATTLE_OPENING_START" or event == "PET_BATTLE_CLOSE" ) then
		PetJournalHealPetButton_UpdateUsability(self);
	end
end

function PetJournalHealPetButton_UpdateCooldown(self)
	local cooldown = self.cooldown;
	local cooldownInfo = C_Spell.GetSpellCooldown(self.spellID);
	if ( cooldownInfo ) then
		CooldownFrame_Set(cooldown, cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled);
	else
		CooldownFrame_Clear(cooldown);
	end
end

function PetJournalHealPetButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID);
	if (not IsSpellKnown(self.spellID)) then
		GameTooltip:AddLine(PET_BATTLE_HEAL_SPELL_UNKNOWN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		GameTooltip:Show();
	elseif (not C_PetJournal.IsJournalUnlocked()) then
		GameTooltip:AddLine(PET_JOURNAL_HEAL_SPELL_LOCKED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		GameTooltip:Show();
	elseif (C_PetBattles.IsInBattle()) then
		GameTooltip:AddLine(PET_JOURNAL_HEAL_SPELL_IN_BATTLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
	self.UpdateTooltip = PetJournalHealPetButton_OnEnter;
end

-- SUMMON RANDOM FAVORITE PET ---

function PetJournalSummonRandomFavoritePetButton_OnLoad(self)
	self.spellID = SUMMON_RANDOM_FAVORITE_PET_SPELL;
	self.petID = C_PetJournal.GetSummonRandomFavoritePetGUID();
	local spellIcon = C_Spell.GetSpellTexture(self.spellID);
	self.texture:SetTexture(spellIcon);
	self.spellname:SetText(PET_JOURNAL_SUMMON_RANDOM_FAVORITE_PET);
end

function PetJournalSummonRandomFavoritePetButton_OnShow(self)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("PET_BATTLE_OPENING_START");
	self:RegisterEvent("PET_BATTLE_CLOSE");
	PetJournalSummonRandomFavoritePetButton_UpdateCooldown(self);
	PetJournalSummonRandomFavoritePetButton_UpdateSpellUsability(self);
end

function PetJournalSummonRandomFavoritePetButton_OnHide(self)
	self:UnregisterEvent("PET_BATTLE_OPENING_START");
	self:UnregisterEvent("PET_BATTLE_CLOSE");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
end

function PetJournalSummonRandomFavoritePetButton_UpdateCooldown(self)
	local cooldown = self.cooldown;
	local start, duration, enable = C_PetJournal.GetSummonBattlePetCooldown();
	CooldownFrame_Set(cooldown, start, duration, enable);
end

function PetJournalSummonRandomFavoritePetButton_UpdateSpellUsability(self)
	local numPets, numOwned = C_PetJournal.GetNumPets();
	if ( numOwned > 0 ) then
		if (C_PetBattles.IsInBattle()) then
			self:SetButtonState("NORMAL", true);
			self.texture:SetDesaturated(true);
			self.LockIcon:Show();
			self.BlackCover:Show();
		else
			self:SetButtonState("NORMAL", false);
			self.texture:SetDesaturated(false);
			self.LockIcon:Hide();
			self.BlackCover:Hide();
			self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
			self:RegisterForDrag("LeftButton");
		end
	else
		self.BlackCover:Show();
		self.texture:SetDesaturated(true);
	end
end

function PetJournalSummonRandomFavoritePetButton_OnEvent(self, event, ...)
	if ( event == "SPELL_UPDATE_COOLDOWN" ) then
		PetJournalSummonRandomFavoritePetButton_UpdateCooldown(self);
		-- Update tooltip
		if ( GameTooltip:GetOwner() == self ) then
			PetJournalSummonRandomFavoritePetButton_OnEnter(self);
		end
	elseif ( event == "PET_BATTLE_OPENING_START" or event == "PET_BATTLE_CLOSE" ) then
		PetJournalSummonRandomFavoritePetButton_UpdateSpellUsability(self);
	end
end

function PetJournalSummonRandomFavoritePetButton_OnClick(self)
	local hasFavoritePets = C_PetJournal.HasFavoritePets();
	C_PetJournal.SummonRandomPet(hasFavoritePets);
end

function PetJournalSummonRandomFavoritePetButton_OnDragStart(self)
	C_PetJournal.PickupSummonRandomPet();
end

function PetJournalSummonRandomFavoritePetButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local numPets, numOwned = C_PetJournal.GetNumPets();
	if ( numOwned > 0 and not C_PetBattles.IsInBattle()  ) then
		GameTooltip:SetCompanionPet(self.petID);
	else
		GameTooltip:SetSpellByID(self.spellID);
	end
end

function PetJournalSummonRandomFavoritePetButton_OnLeave(self)
	GameTooltip:Hide();
end

function PetJournalLoadout_GetRequiredLevel(loadoutPlate, abilityID)
	for i=1, NUM_PET_ABILITIES do
		if ( loadoutPlate.abilities[i] == abilityID ) then
			return loadoutPlate.abilityLevels[i];
		end
	end
	return 0;
end

function PetJournal_UpdatePetAbility(abilityFrame, abilityID, petID)
	--Get the info for the pet that has this ability
	local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType = C_PetJournal.GetPetInfoByPetID(petID);

	local requiredLevel = PetJournalLoadout_GetRequiredLevel(abilityFrame:GetParent(), abilityID);

	local name, icon, typeEnum = C_PetJournal.GetPetAbilityInfo(abilityID);
	abilityFrame.icon:SetTexture(icon);
	abilityFrame.abilityID = abilityID;
	abilityFrame.petID = petID;
	abilityFrame.speciesID = speciesID;
	abilityFrame.selected:Hide();


	--Display info about the required level
	local levelTooLow = requiredLevel > level;
	abilityFrame.icon:SetDesaturated(levelTooLow);
	abilityFrame.BlackCover:SetShown(levelTooLow);
	abilityFrame.LevelRequirement:SetText(requiredLevel);
	abilityFrame.LevelRequirement:SetShown(levelTooLow);
	if ( levelTooLow ) then
		abilityFrame.additionalText = format(PET_ABILITY_REQUIRES_LEVEL, requiredLevel);
	else
		abilityFrame.additionalText = nil;
	end
end

function PetJournal_ShowPetSelect(self)
	local slotFrame = self:GetParent();
	local abilities = slotFrame.abilities;
	local slotIndex = slotFrame:GetID();

	local abilityIndex = self:GetID();
	local spellIndex1 = abilityIndex;
	local spellIndex2 = spellIndex1 + 3;

	--Get the info for the pet that has this ability
	local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType = C_PetJournal.GetPetInfoByPetID(slotFrame.petID);

	if PetJournal.SpellSelect:IsShown() then
		if PetJournal.SpellSelect.slotIndex == slotIndex and
			PetJournal.SpellSelect.abilityIndex == abilityIndex then
			PetJournal.SpellSelect:Hide();
			self.selected:Hide();
			return;
		else
			PetJournal.Loadout["Pet"..PetJournal.SpellSelect.slotIndex]["spell"..PetJournal.SpellSelect.abilityIndex].selected:Hide();
		end
	end
	self.selected:Show();
	PetJournal.SpellSelect.slotIndex = slotIndex;
	PetJournal.SpellSelect.abilityIndex = abilityIndex;
	PetJournal.SpellSelect:SetFrameLevel(CollectionsJournal.NineSlice:GetFrameLevel() + 1);
	PetJournal_HideAbilityTooltip();

	--Setup spell one
	local _name, icon, _petType, requiredLevel;
	if (abilities[spellIndex1]) then
		_name, icon, _petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex1]);
		requiredLevel = PetJournalLoadout_GetRequiredLevel(slotFrame, abilities[spellIndex1]);
		PetJournal.SpellSelect.Spell1:SetEnabled(requiredLevel <= level);
	else
		icon = "";
		requiredLevel = 0;
		PetJournal.SpellSelect.Spell1:SetEnabled(false);
	end

	if ( requiredLevel > level ) then
		PetJournal.SpellSelect.Spell1.additionalText = format(PET_ABILITY_REQUIRES_LEVEL, requiredLevel);
	else
		PetJournal.SpellSelect.Spell1.additionalText = nil;
	end
	PetJournal.SpellSelect.Spell1.icon:SetTexture(icon);
	PetJournal.SpellSelect.Spell1.icon:SetDesaturated(requiredLevel > level);
	PetJournal.SpellSelect.Spell1.BlackCover:SetShown(requiredLevel > level);
	PetJournal.SpellSelect.Spell1.LevelRequirement:SetShown(requiredLevel > level);
	PetJournal.SpellSelect.Spell1.LevelRequirement:SetText(requiredLevel);
	PetJournal.SpellSelect.Spell1.slotIndex = slotIndex;
	PetJournal.SpellSelect.Spell1.abilityIndex = abilityIndex;
	PetJournal.SpellSelect.Spell1.abilityID = abilities[spellIndex1];
	PetJournal.SpellSelect.Spell1.petID = slotFrame.petID;
	PetJournal.SpellSelect.Spell1.speciesID = slotFrame.speciesID;
	--Setup spell two
	if (abilities[spellIndex2]) then
		_name, icon, _petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex2]);
		requiredLevel = PetJournalLoadout_GetRequiredLevel(slotFrame, abilities[spellIndex2]);
		PetJournal.SpellSelect.Spell2:SetEnabled(requiredLevel <= level);
	else
		icon = "";
		requiredLevel = 0;
		PetJournal.SpellSelect.Spell2:SetEnabled(false);
	end

	if ( requiredLevel > level ) then
		PetJournal.SpellSelect.Spell2.additionalText = format(PET_ABILITY_REQUIRES_LEVEL, requiredLevel);
	else
		PetJournal.SpellSelect.Spell2.additionalText = nil;
	end
	PetJournal.SpellSelect.Spell2.icon:SetTexture(icon);
	PetJournal.SpellSelect.Spell2.BlackCover:SetShown(requiredLevel > level);
	PetJournal.SpellSelect.Spell2.icon:SetDesaturated(requiredLevel > level);
	PetJournal.SpellSelect.Spell2.LevelRequirement:SetShown(requiredLevel > level);
	PetJournal.SpellSelect.Spell2.LevelRequirement:SetText(requiredLevel);
	PetJournal.SpellSelect.Spell2.slotIndex = slotIndex;
	PetJournal.SpellSelect.Spell2.abilityIndex = abilityIndex;
	PetJournal.SpellSelect.Spell2.abilityID = abilities[spellIndex2];
	PetJournal.SpellSelect.Spell2.petID = slotFrame.petID;
	PetJournal.SpellSelect.Spell2.speciesID = slotFrame.speciesID;

	PetJournal.SpellSelect.Spell1:SetChecked(self.abilityID == abilities[spellIndex1]);
	PetJournal.SpellSelect.Spell2:SetChecked(self.abilityID == abilities[spellIndex2]);

	PetJournal.SpellSelect:SetPoint("TOP", self, "BOTTOM", 0, 0);
	PetJournal.SpellSelect:Show();
end


function PetJournal_UpdatePetLoadOut(forceSceneChange)
	PetJournal_UpdateFindBattleButton();
	PetJournal.SpellSelect:Hide();
	for i=1,MAX_ACTIVE_PETS do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i);

		local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType;
		if petID then
			speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType = C_PetJournal.GetPetInfoByPetID(petID);
		end

		if ( not C_PetJournal.IsJournalUnlocked() ) then
			loadoutPlate.ReadOnlyFrame:Show();
			loadoutPlate.ReadOnlyFrame.LockIcon.tooltip = PET_JOURNAL_READONLY_TEXT;
		elseif ( C_PetBattles.GetPVPMatchmakingInfo() ) then
			loadoutPlate.ReadOnlyFrame:Show();
			loadoutPlate.ReadOnlyFrame.LockIcon.tooltip = ERR_PETBATTLE_QUEUE_QUEUED;
		else
			loadoutPlate.ReadOnlyFrame:Hide();
		end

		if (locked) then
			loadoutPlate.name:Hide();
			loadoutPlate.subName:Hide();
			loadoutPlate.level:Hide();
			loadoutPlate.levelBG:Hide();
			loadoutPlate.icon:Hide();
			loadoutPlate.qualityBorder:Hide();
			loadoutPlate.favorite:Hide()
			loadoutPlate.modelScene:Hide();
			loadoutPlate.xpBar:Hide();
			loadoutPlate.healthFrame:Hide();
			loadoutPlate.spell1:Hide();
			loadoutPlate.spell2:Hide();
			loadoutPlate.spell3:Hide();
			loadoutPlate.iconBorder:Hide();
			loadoutPlate.emptyslot:Hide();
			loadoutPlate.isDead:Hide();
			loadoutPlate.dragButton:Hide();
			-- helpFrame & requirement are active when the slot is locked
			loadoutPlate.requirement:SetShown(UNLOCK_REQUIREMENTS[i].id);
			if (UNLOCK_REQUIREMENTS[i].requirement == "ACHIEVEMENT" and UNLOCK_REQUIREMENTS[i].id) then
				loadoutPlate.requirement.str:SetText(GetAchievementLink(UNLOCK_REQUIREMENTS[i].id));
				loadoutPlate.requirement.achievementID = UNLOCK_REQUIREMENTS[i].id;
			elseif (UNLOCK_REQUIREMENTS[i].requirement == "SPELL" and UNLOCK_REQUIREMENTS[i].id) then
				local spellLink = C_Spell.GetSpellLink(UNLOCK_REQUIREMENTS[i].id);
				loadoutPlate.requirement.str:SetText(spellLink);
				loadoutPlate.requirement.spellID = UNLOCK_REQUIREMENTS[i].id;
			end
			loadoutPlate.helpFrame.text:SetText(_G["BATTLE_PET_UNLOCK_HELP_"..i]);
			loadoutPlate.helpFrame:Show();
			loadoutPlate.petTypeIcon:Hide();
			loadoutPlate.petID = nil;
		elseif (petID == nil or speciesID == nil) then
			loadoutPlate.name:Hide();
			loadoutPlate.subName:Hide();
			loadoutPlate.level:Hide();
			loadoutPlate.levelBG:Hide();
			loadoutPlate.icon:Hide();
			loadoutPlate.qualityBorder:Hide();
			loadoutPlate.favorite:Hide()
			loadoutPlate.modelScene:Hide();
			loadoutPlate.xpBar:Hide();
			loadoutPlate.healthFrame:Hide();
			loadoutPlate.spell1:Hide();
			loadoutPlate.spell2:Hide();
			loadoutPlate.spell3:Hide();
			loadoutPlate.iconBorder:Hide();
			loadoutPlate.helpFrame:Hide();
			loadoutPlate.requirement:Hide();
			loadoutPlate.emptyslot:Show();
			loadoutPlate.emptyslot.slot:SetText(format(BATTLE_PET_SLOT, i));
			loadoutPlate.dragButton:Show();
			loadoutPlate.isDead:Hide();
			loadoutPlate.petTypeIcon:Hide();
			loadoutPlate.petID = nil;
		else -- not locked and petID is not nil
			C_PetJournal.GetPetAbilityList(speciesID, loadoutPlate.abilities, loadoutPlate.abilityLevels);	--Read ability/ability levels into the correct tables

			--Find out how many abilities are usable due to level
			local numUsableAbilities = 0;
			for j=1, #loadoutPlate.abilityLevels do
				if ( loadoutPlate.abilityLevels[j] and level >= loadoutPlate.abilityLevels[j] ) then
					numUsableAbilities = numUsableAbilities + 1;
				end
			end

			--If we don't have something in a flyout, automatically put there the lower level ability
			if ( ability1ID == 0 and loadoutPlate.abilities[1] ) then
				ability1ID = loadoutPlate.abilities[1];
				C_PetJournal.SetAbility(i, 1, ability1ID);
			end
			if ( ability2ID == 0 and loadoutPlate.abilities[2] ) then
				ability2ID = loadoutPlate.abilities[2];
				C_PetJournal.SetAbility(i, 2, ability2ID);
			end
			if ( ability3ID == 0 and loadoutPlate.abilities[3] ) then
				ability3ID = loadoutPlate.abilities[3];
				C_PetJournal.SetAbility(i, 3, ability3ID);
			end
			loadoutPlate.name:Show();
			loadoutPlate.subName:Show();
			loadoutPlate.level:Show();
			loadoutPlate.levelBG:Show();
			loadoutPlate.icon:Show();
			loadoutPlate.iconBorder:Show();
			loadoutPlate.spell1:Show();
			loadoutPlate.spell2:Show();
			loadoutPlate.spell3:Show();

			if (isFavorite) then
				loadoutPlate.favorite:Show()
			else
				loadoutPlate.favorite:Hide()
			end

			if customName then
				loadoutPlate.name:SetText(customName);
				loadoutPlate.name:SetHeight(12);
				loadoutPlate.subName:Show();
				loadoutPlate.subName:SetText(name);
			else
				loadoutPlate.name:SetText(name);
				loadoutPlate.name:SetHeight(28);
				loadoutPlate.subName:Hide();
			end
			loadoutPlate.level:SetText(level);
			loadoutPlate.icon:SetTexture(icon);

			loadoutPlate.petTypeIcon:Show();
			loadoutPlate.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
			loadoutPlate.petID = petID;
			loadoutPlate.speciesID = speciesID;
			if(level < MAX_PET_LEVEL) then
				loadoutPlate.xpBar:Show();
			else
				loadoutPlate.xpBar:Hide();
			end

			loadoutPlate.xpBar:SetMinMaxValues(0, maxXp);
			loadoutPlate.xpBar:SetValue(xp);
			local display = GetCVar("statusTextDisplay")
			if (display == "BOTH") then
				loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_BOTH, xp, maxXp, xp/maxXp*100);
			elseif (display == "PERCENTAGE") then
				loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_PERCENT, xp/maxXp*100);
			else
				loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
			end
			loadoutPlate.xpBar.tooltip = format(PET_BATTLE_CURRENT_XP_FORMAT_TOOLTIP, xp, maxXp, xp/maxXp*100);

			local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);
			loadoutPlate.healthFrame.healthValue:SetFormattedText(PET_BATTLE_CURRENT_HEALTH_FORMAT, health, maxHealth);
			loadoutPlate.healthFrame.healthBar:SetMinMaxValues(0, maxHealth);
			loadoutPlate.healthFrame.healthBar:SetValue(health);
			loadoutPlate.healthFrame:Show();

			loadoutPlate.qualityBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);

			loadoutPlate.isDead:SetShown(health <= 0);

			loadoutPlate.modelScene:Show();
			local modelChanged = false;
			if ( displayID ~= loadoutPlate.displayID or forceSceneChange ) then
				loadoutPlate.displayID = displayID;

				local cardModelSceneID, loadoutModelSceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(speciesID);

				loadoutPlate.modelScene:TransitionToModelSceneID(loadoutModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);

				local battlePetActor = loadoutPlate.modelScene:GetActorByTag("pet");
				if ( battlePetActor ) then
					battlePetActor:SetModelByCreatureDisplayID(displayID);
					battlePetActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
				end

				modelChanged = true;
			end
			local isDead = health <= 0;
			if ( modelChanged or isDead ~= loadoutPlate.modelScene.wasDead ) then
				local battlePetActor = loadoutPlate.modelScene:GetActorByTag("pet");
				if ( battlePetActor ) then
					if ( isDead ) then
						battlePetActor:SetAnimation(6, -1);
					else
						battlePetActor:SetAnimation(0, -1);
					end
				end
				loadoutPlate.modelScene.wasDead = isDead;
			end


			PetJournal_UpdatePetAbility(loadoutPlate.spell1, ability1ID, petID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell2, ability2ID, petID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell3, ability3ID, petID);

			loadoutPlate.spell1.enabled = true;
			loadoutPlate.spell2.enabled = true;
			loadoutPlate.spell3.enabled = true;
			loadoutPlate.spell1:GetHighlightTexture():SetAlpha(1);
			loadoutPlate.spell2:GetHighlightTexture():SetAlpha(1);
			loadoutPlate.spell3:GetHighlightTexture():SetAlpha(1);
			loadoutPlate.spell1:GetPushedTexture():SetAlpha(1);
			loadoutPlate.spell2:GetPushedTexture():SetAlpha(1);
			loadoutPlate.spell3:GetPushedTexture():SetAlpha(1);
			loadoutPlate.spell1.FlyoutArrow:Show();
			loadoutPlate.spell2.FlyoutArrow:Show();
			loadoutPlate.spell3.FlyoutArrow:Show();

			loadoutPlate.helpFrame:Hide();
			loadoutPlate.requirement:Hide();
			loadoutPlate.emptyslot:Hide();
			loadoutPlate.dragButton:Show();
		end
	end -- for i=1,MAX_ACTIVE_PETS do

	PetJournal.Loadout.Pet1.setButton:Hide();
	PetJournal.Loadout.Pet2.setButton:Hide();
	PetJournal.Loadout.Pet3.setButton:Hide();
end


function PetJournalRequirement_ShowRequirementToolTip(self)
	if (self.achievementID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -185, 0);
		GameTooltip:SetAchievementByID(self.achievementID);
	elseif (self.spellID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -185, 0);
		GameTooltip:SetSpellByID(self.spellID);
	end
end

function PetJournal_UpdateAll()
	PetJournal_UpdatePetList();
	PetJournal_UpdatePetLoadOut();
	PetJournal_UpdatePetCard(PetJournalPetCard);
end

function PetJournal_InitPetButton(pet, elementData)
	local index = elementData.index;

	local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByIndex(index);
	local needsFanfare = petID and C_PetJournal.PetNeedsFanfare(petID);

	if customName then
		pet.name:SetText(customName);
		pet.name:SetHeight(12);
		pet.subName:Show();
		pet.subName:SetText(name);
	else
		pet.name:SetText(name);
		pet.name:SetHeight(30);
		pet.subName:Hide();
	end

	pet.icon:SetTexture(needsFanfare and COLLECTIONS_FANFARE_ICON or icon);
	pet.new:SetShown(needsFanfare);
	pet.newGlow:SetShown(needsFanfare);
	pet.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
	pet.petTypeIcon:SetShown(canBattle);

	if (favorite) then
		pet.dragButton.favorite:Show();
	else
		pet.dragButton.favorite:Hide();
	end

	CollectionItemListButton_SetRedOverlayShown(pet, false);

	if isOwned then
		local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);

		pet.dragButton.levelBG:SetShown(canBattle);
		pet.dragButton.level:SetShown(canBattle);
		pet.dragButton.level:SetText(level);

		pet.icon:SetDesaturated(false);
		pet.name:SetFontObject("GameFontNormal");
		pet.petTypeIcon:SetDesaturated(false);
		pet.dragButton:Enable();
		pet.iconBorder:Show();
		pet.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);
		if (health and health <= 0) then
			pet.isDead:Show();
		else
			pet.isDead:Hide();
		end
		if(isRevoked) then
			pet.dragButton.levelBG:Hide();
			pet.dragButton.level:Hide();
			pet.iconBorder:Hide();
			pet.icon:SetDesaturated(true);
			pet.petTypeIcon:SetDesaturated(true);
			pet.dragButton:Disable();
		else
			-- Only display the unusable texture if you'll never be able to summon this pet.
			local isSummonable, error, errorText = C_PetJournal.GetPetSummonInfo(petID);
			local neverUsable = error == Enum.PetJournalError.InvalidFaction;
			pet.iconBorder:SetShown(not neverUsable);
			CollectionItemListButton_SetRedOverlayShown(pet, neverUsable);
		end
	else
		pet.dragButton.levelBG:Hide();
		pet.dragButton.level:Hide();
		pet.icon:SetDesaturated(true);
		pet.iconBorder:Hide();
		pet.name:SetFontObject("GameFontDisable");
		pet.petTypeIcon:SetDesaturated(true);
		pet.dragButton:Disable();
		pet.isDead:Hide();
	end

	local summonedPetID = C_PetJournal.GetSummonedPetGUID();
	if ( petID and petID == summonedPetID ) then
		pet.dragButton.ActiveTexture:Show();
	else
		pet.dragButton.ActiveTexture:Hide();
	end

	pet.petID = petID;
	pet.speciesID = speciesID;
	pet.index = index;
	pet.owned = isOwned;

	--Update Petcard Button
	if PetJournalPetCard.petIndex == index then
		pet.selected = true;
		pet.selectedTexture:Show();
	else
		pet.selected = false;
		pet.selectedTexture:Hide()
	end

	if ( petID ) then
		local start, duration, enable = C_PetJournal.GetPetCooldownByGUID(pet.petID);
		if (start) then
			CooldownFrame_Set(pet.dragButton.Cooldown, start, duration, enable);
		end
	end
end

function PetJournal_UpdatePetList()
	local newDataProvider = CreateDataProvider();
	for index = 1, C_PetJournal.GetNumPets() do
		local petID, speciesID = C_PetJournal.GetPetInfoByIndex(index);
		newDataProvider:Insert({index = index, petID = petID, speciesID = speciesID});
	end
	PetJournal.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition);

	local numPets, numOwned = C_PetJournal.GetNumPets();
	PetJournal.PetCount.Count:SetText(numOwned);
end


function PetJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_PetJournal.SetSearchFilter(self:GetText());
end

local function CreateContextMenu(owner, rootDescription, petID)
	rootDescription:SetTag("MENU_PET_COLLECTION_PET");

	local needsFanfare = petID and C_PetJournal.PetNeedsFanfare(petID);
	if needsFanfare then
		rootDescription:CreateButton(UNWRAP, function()
			PetJournal_UnwrapPet(petID);
		end);
		return;
	end

	local isRevoked = petID and C_PetJournal.PetIsRevoked(petID);
	local isLockedForConvert = petID and C_PetJournal.PetIsLockedForConvert(petID);
	if not isRevoked and not isLockedForConvert then
		local canDismiss = (petID and C_PetJournal.GetSummonedPetGUID() == petID);
		local text = canDismiss and PET_DISMISS or BATTLE_PET_SUMMON;
		local button = rootDescription:CreateButton(text, function()
			C_PetJournal.SummonPetByGUID(petID);
		end);

		if petID and not C_PetJournal.PetIsSummonable(petID) then
			button:SetEnabled(false);
		end
	end

	if not isRevoked and not isLockedForConvert then
		local button = rootDescription:CreateButton(BATTLE_PET_RENAME, function()
			StaticPopup_Show("BATTLE_PET_RENAME", nil, nil, petID);
		end);
		button:SetEnabled(C_PetJournal.IsJournalUnlocked());
	end
	

	local isFavorite = petID and C_PetJournal.PetIsFavorite(petID);
	if isFavorite or (not isRevoked and not isLockedForConvert) then
		local button = nil;
		if isFavorite then
			button = rootDescription:CreateButton(BATTLE_PET_UNFAVORITE, function()
				C_PetJournal.SetFavorite(petID, 0);
			end);
		else
			button = rootDescription:CreateButton(BATTLE_PET_FAVORITE, function()
				C_PetJournal.SetFavorite(petID, 1);
			end);
		end
		button:SetEnabled(C_PetJournal.IsJournalUnlocked());
	end

	if petID and C_PetJournal.PetCanBeReleased(petID) then
		local button = rootDescription:CreateButton(BATTLE_PET_RELEASE, function()
			StaticPopup_Show("BATTLE_PET_RELEASE", PetJournalUtil_GetDisplayName(petID), nil, petID);
		end);
		
		local enabled = not (C_PetJournal.PetIsSlotted(petID) or C_PetBattles.IsInBattle() or not C_PetJournal.IsJournalUnlocked());
		button:SetEnabled(enabled);
	end

	if petID and C_PetJournal.PetIsTradable(petID) then
		local text = BATTLE_PET_PUT_IN_CAGE;
		local disabled = false;
		if C_PetJournal.PetIsSlotted(petID) then
			text = BATTLE_PET_PUT_IN_CAGE_SLOTTED;
			disabled = true;
		elseif C_PetJournal.PetIsHurt(petID) then
			text = BATTLE_PET_PUT_IN_CAGE_HEALTH;
			disabled = true;
		end
		local button = rootDescription:CreateButton(text, function()
			StaticPopup_Show("BATTLE_PET_PUT_IN_CAGE", nil, nil, petID);
		end);
		button:SetEnabled(not disabled);
	end
end

PetJournalListItemMixin = {}

function PetJournalListItemMixin:OnClick(button)
	if ( IsModifiedClick("CHATLINK") ) then
		local id = self.petID;
		if ( id and MacroFrame and MacroFrame:IsShown() ) then
			-- Macros are not yet supported
		elseif (id) then
			local petLink = C_PetJournal.GetBattlePetLink(id);
			ChatEdit_InsertLink(petLink);
		end
	elseif button == "RightButton" then
		if self.owned then
			PetJournal_ShowPetDropdown(self, self.index);
		end
	elseif SpellIsTargeting() then
		C_PetJournal.SpellTargetBattlePet(self.petID);
	elseif GetCursorInfo() == "battlepet" then
		PetJournal_UpdatePetLoadOut();
		ClearCursor();
	else
		PetJournal_ShowPetCard(self.index);
	end
end

function PetJournalListItemMixin:OnEnter()
	if ( self.petID ) then
		C_PetJournal.SetHoveredBattlePet(self.petID);
	end
end

function PetJournalListItemMixin:OnLeave()
	C_PetJournal.ClearHoveredBattlePet();
end

function PetJournalListItemMixin:OnDragStart()
	PetJournalDragButtonMixin.OnDragStart(self.dragButton);
end

PetJournalDragButtonMixin = {}

function PetJournalDragButtonMixin:OnEnter()
	local petID = self:GetParent().petID;
	if (not petID) then
		return;
	end

	C_PetJournal.SetHoveredBattlePet(petID);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetCompanionPet(petID);
	GameTooltip:Show();
end

function PetJournalDragButtonMixin:OnLeave()
	C_PetJournal.ClearHoveredBattlePet();

	GameTooltip_Hide();
end

function PetJournalDragButtonMixin:OnClick(button)
	if ( IsModifiedClick("CHATLINK") ) then
		local id = self:GetParent().petID;
		if ( id and MacroFrame and MacroFrame:IsShown() ) then
			-- Macros are not yet supported
		elseif (id) then
			local petLink = C_PetJournal.GetBattlePetLink(id);
			ChatEdit_InsertLink(petLink);
		end
	elseif ( button == "RightButton" ) then
		local parent = self:GetParent();
		if ( parent.owned ) then
			PetJournal_ShowPetDropdown(self, parent.index);
		end
	elseif SpellIsTargeting() then
		C_PetJournal.SpellTargetBattlePet(self:GetParent().petID);
	elseif GetCursorInfo() == "battlepet" then
		PetJournal_UpdatePetLoadOut();
		ClearCursor();
	else
		self:OnDragStart();
	end
end

function PetJournalDragButtonMixin:OnDragStart()
	if (not self:GetParent().petID) then
		return;
	end

	C_PetJournal.PickupPet(self:GetParent().petID);

	for i=1,MAX_ACTIVE_PETS do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i - 1);
		if(locked) then
			PetJournal.Loadout["Pet"..i].setButton:Hide();
		else
			PetJournal.Loadout["Pet"..i].setButton:Show();
		end
	end
end

function PetJournalDragButtonMixin:OnEvent(event, ...)
	if ( event == "SPELL_UPDATE_COOLDOWN" and self:GetParent().petID) then
		local start, duration, enable = C_PetJournal.GetPetCooldownByGUID(self:GetParent().petID);
		if (start) then
			CooldownFrame_Set(self.Cooldown, start, duration, enable);
		end
	end
end

PetJournalLoadoutDragButtonMixin = CreateFromMixins(PetJournalDragButtonMixin);

function PetJournalLoadoutDragButtonMixin:OnClick(button)
	local loadout = self:GetParent();
	if (button == "RightButton" and loadout.petID) then
		PetJournal_ShowPetDropdown(self, nil, loadout.petID);
		return;
	end
	if ( IsModifiedClick("CHATLINK") ) then
		local id = self:GetParent().petID;
		if ( id and MacroFrame and MacroFrame:IsShown() ) then
			-- Macros are not yet supported
		elseif (id) then
			local petLink = C_PetJournal.GetBattlePetLink(id);
			ChatEdit_InsertLink(petLink);
		end
	else
		PetJournalDragButtonMixin.OnDragStart(self);
	end
end

function PetJournalLoadoutDragButtonMixin:OnEnter()
	local petID = self:GetParent().petID;
	if (not petID) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetCompanionPet(petID);
	GameTooltip:Show();
end

function PetJournalLoadoutDragButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function PetJournalLoadOut_MenuRegion_OnMouseUp(self, button, buttonName)
	local petID = self:GetParent().petID;
	if (not petID) then
		return;
	end

	PetJournal_ShowPetDropdown(self, nil, petID);

end

function PetJournal_ShowPetDropdown(button, index, petID)
	if index then
		local usePetID = C_PetJournal.GetPetInfoByIndex(index);
		MenuUtil.CreateContextMenu(button, CreateContextMenu, usePetID);
	elseif petID then
		MenuUtil.CreateContextMenu(button, CreateContextMenu, petID);
	end
end

function PetJournal_ShowPetCardByID(petID)
	if (petID == nil) then
		PetJournal_ShowPetCard(1);
		return;
	end

	PetJournalPetCard.petID = petID;
	PetJournalPetCard.speciesID = C_PetJournal.GetPetInfoByPetID(petID);

	PetJournal_FindPetCardIndex();
	PetJournal_UpdatePetCard(PetJournalPetCard);
	PetJournal_UpdatePetList();
	PetJournal_UpdateSummonButtonState();
end

function PetJournal_ShowPetCardBySpeciesID(speciesID)
	if (not speciesID) then
		PetJournal_ShowPetCard(1);
		return;
	end

	PetJournalPetCard.petID = nil;
	PetJournalPetCard.speciesID = speciesID;

	PetJournal_FindPetCardIndex();
	PetJournal_UpdatePetCard(PetJournalPetCard);
	PetJournal_UpdatePetList();
	PetJournal_UpdateSummonButtonState();
end

function PetJournal_ShowPetCard(index)
	PetJournalPetCard.petIndex = index;
	local owned;
	PetJournalPetCard.petID, PetJournalPetCard.speciesID, owned = C_PetJournal.GetPetInfoByIndex(index);
	if ( not owned ) then
		PetJournalPetCard.petID = nil;
	end
	PetJournal_UpdatePetCard(PetJournalPetCard);
	PetJournal_UpdatePetList();
	PetJournal_UpdateSummonButtonState();
end

function PetJournal_FindPetCardIndex()
	PetJournalPetCard.petIndex = nil;
	local numPets = C_PetJournal.GetNumPets();
	for i = 1,numPets do
		local petID, speciesID, owned = C_PetJournal.GetPetInfoByIndex(i);
		if (owned and petID == PetJournalPetCard.petID) or
			(not owned and speciesID == PetJournalPetCard.speciesID)  then
			PetJournalPetCard.petIndex = i;
			break;
		end
	end
end

function PetJournalPetCard_OnClick(self, button)
	local type, petID = GetCursorInfo();
	if type == "battlepet" then
		ClearCursor();
		return;
	end

	if ( IsModifiedClick("CHATLINK") ) then
		local id = PetJournalPetCard.petID;
		if ( id and MacroFrame and MacroFrame:IsShown() ) then
			-- Macros are not yet supported
		elseif (id) then
			local petLink = C_PetJournal.GetBattlePetLink(id);
			ChatEdit_InsertLink(petLink);
		end
	elseif button == "RightButton" then
		if ( PetJournalPetCard.petID ) then
			PetJournal_ShowPetDropdown(self, PetJournalPetCard.petIndex, PetJournalPetCard.petID);
		end
	else
		PetJournalDragButtonMixin.OnDragStart(self);
	end
end

function PetJournal_UpdatePetCard(self, forceSceneChange)
	PetJournal.SpellSelect:Hide();

	if (not PetJournalPetCard.petID and not PetJournalPetCard.speciesID) then
		--Select a pet from the list on the left
		self.PetInfo.name:SetText(PET_JOURNAL_CARD_NAME_DEFAULT);
		self.PetInfo.subName:SetText("");
		self.PetInfo.subName:Hide();
		self.PetInfo.level:Hide();
		self.PetInfo.levelBG:Hide();
		self.PetInfo.qualityBorder:Hide();
		self.PetInfo.favorite:Hide();
		self.PetInfo.icon:Hide();

		self.TypeInfo:Hide();

		self.modelScene:Hide();
		self.shadows:Hide();

		self.AbilitiesBG1:Hide();
		self.AbilitiesBG2:Hide();
		self.AbilitiesBG3:Hide();
		self.CannotBattleText:Hide();
		for i=1,NUM_PET_ABILITIES do
			self["spell"..i]:Hide();
		end

		self.HealthFrame:Hide();
		self.PowerFrame:Hide();
		self.SpeedFrame:Hide();
		self.QualityFrame:Hide();

		self.xpBar:Hide();
		return;
	end

	self.PetInfo.icon:Show();

	local isDead = false;
	local needsFanfare = false;
	local speciesID, customName, level, name, icon, petType, creatureID, xp, maxXp, displayID, isFavorite, sourceText, description, isWild, canBattle, tradable, unique;
	local _;
	if PetJournalPetCard.petID then
		speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(PetJournalPetCard.petID);
		if ( not speciesID ) then
			return;
		end

		self.PetInfo.level:SetShown(canBattle);
		self.PetInfo.levelBG:SetShown(canBattle);
		self.PetInfo.level:SetText(level);

		needsFanfare = C_PetJournal.PetNeedsFanfare(PetJournalPetCard.petID);

		self.xpBar:SetShown(level < MAX_PET_LEVEL and canBattle);
		if (level < MAX_PET_LEVEL) then
			self.xpBar:SetMinMaxValues(0, maxXp);
			self.xpBar:SetValue(xp);
			local display = GetCVar("statusTextDisplay")
			if (display == "BOTH") then
				self.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_BOTH, xp, maxXp, xp/maxXp*100);
			elseif(display == "PERCENT") then
				self.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_PERCENT, xp/maxXp*100);
			else
				self.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
			end
			self.xpBar.tooltip = format(PET_BATTLE_CURRENT_XP_FORMAT_TOOLTIP, xp, maxXp, xp/maxXp*100);
		end

		--Stats
		local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(PetJournalPetCard.petID);
		self.HealthFrame:SetShown(canBattle);
		self.PowerFrame:SetShown(canBattle);
		self.SpeedFrame:SetShown(canBattle);

		self.HealthFrame.healthBar:SetMinMaxValues(0, maxHealth);
		self.HealthFrame.healthBar:SetValue(health);
		self.HealthFrame.health:SetText(maxHealth);

		isDead = health <= 0;

		self.PowerFrame.power:SetText(power);
		self.SpeedFrame.speed:SetText(speed);
		if ( canBattle ) then
			self.QualityFrame.quality:SetText(_G["BATTLE_PET_BREED_QUALITY"..rarity]);
			local color = ITEM_QUALITY_COLORS[rarity-1];
			self.QualityFrame.quality:SetVertexColor(color.r, color.g, color.b);
			self.QualityFrame:Show();
			self.PetInfo.qualityBorder:Show();
			self.PetInfo.qualityBorder:SetVertexColor(color.r, color.g, color.b);
		else
			self.QualityFrame:Hide();
			self.PetInfo.qualityBorder:Hide();
		end
	else
		speciesID = PetJournalPetCard.speciesID;
		name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, _, displayID = C_PetJournal.GetPetInfoBySpeciesID(PetJournalPetCard.speciesID);
		level = 1;
		self.PetInfo.level:Hide();
		self.PetInfo.levelBG:Hide();

		self.xpBar:Hide();
		self.HealthFrame:Hide();
		self.PowerFrame:Hide();
		self.SpeedFrame:Hide();
		self.QualityFrame:Hide();
		self.PetInfo.qualityBorder:Hide();
	end
	self.PetInfo.isDead:SetShown(isDead);

	self.TypeInfo:SetShown(canBattle);

	self.TypeInfo.type:SetText(_G["BATTLE_PET_NAME_"..petType]);
	self.TypeInfo.typeIcon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType]);
	self.TypeInfo.abilityID = PET_BATTLE_PET_TYPE_PASSIVES[petType];
	self.TypeInfo.petID = PetJournalPetCard.petID;
	self.TypeInfo.speciesID = speciesID;

	if (isFavorite) then
		self.PetInfo.favorite:Show();
	else
		self.PetInfo.favorite:Hide();
	end

	if customName then
		self.PetInfo.name:SetText(customName);
		self.PetInfo.name:SetHeight(24);
		self.PetInfo.subName:Show();
		self.PetInfo.subName:SetText(name);
	else
		self.PetInfo.name:SetText(name);
		self.PetInfo.name:SetHeight(32);
		self.PetInfo.subName:Hide();
	end


	self.PetInfo.new:SetShown(needsFanfare);
	self.PetInfo.newGlow:SetShown(needsFanfare);

	if needsFanfare then
		self.PetInfo.icon:SetTexture(COLLECTIONS_FANFARE_ICON);
		local offsetX = math.min(self.PetInfo.name:GetStringWidth(), self.PetInfo.name:GetWidth());
		self.PetInfo.new:SetPoint("BOTTOMLEFT", self.PetInfo.name, "BOTTOMLEFT", offsetX + 8, 0);
	else
		self.PetInfo.icon:SetTexture(icon);
	end

	self.PetInfo.sourceText = sourceText;
	self.PetInfo.tradable = tradable;
	self.PetInfo.unique = unique;

	if ( description ~= "" ) then
		self.PetInfo.description = format([["%s"]], description);
	else
		self.PetInfo.description = nil;
	end
	self.PetInfo.speciesName = name;

	self.modelScene:Show();
	self.shadows:Show();
	local modelChanged = false;
	if ( displayID ~= self.displayID or forceSceneChange ) then
		self.displayID = displayID;

		local cardModelSceneID, loadoutModelSceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(speciesID);

		self.modelScene:TransitionToModelSceneID(cardModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);

		local battlePetActor = self.modelScene:GetActorByTag("unwrapped");
		if ( battlePetActor ) then
			battlePetActor:SetModelByCreatureDisplayID(displayID);
			battlePetActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
		end

		modelChanged = true;
	end

	if ( modelChanged or self.modelScene.wasDead ~= isDead ) then
		local battlePetActor = self.modelScene:GetActorByTag("unwrapped");
		if ( battlePetActor ) then
			if ( isDead ) then
				battlePetActor:SetAnimation(6, -1);
			else
				battlePetActor:SetAnimation(0, -1);
			end
		end

		self.modelScene.wasDead = isDead;
	end

	self.modelScene:PrepareForFanfare(needsFanfare);

	self.AbilitiesBG1:SetShown(canBattle);
	self.AbilitiesBG2:SetShown(canBattle);
	self.AbilitiesBG3:SetShown(canBattle);
	self.CannotBattleText:SetShown(not canBattle);

	--Update pet abilites
	local abilities, levels = C_PetJournal.GetPetAbilityList(speciesID);
	for i=1,NUM_PET_ABILITIES do
		local spellFrame = self["spell"..i];
		if abilities[i] and canBattle then
			local _name, abilIcon, _petType = C_PetJournal.GetPetAbilityInfo(abilities[i]);
			local isNotUsable = not level or level < levels[i];
			spellFrame.icon:SetTexture(abilIcon);
			spellFrame.icon:SetDesaturated(isNotUsable);
			spellFrame.LevelRequirement:SetText(levels[i]);
			spellFrame.LevelRequirement:SetShown(isNotUsable);
			spellFrame.BlackCover:SetShown(isNotUsable);
			if (not level or level < levels[i]) then
				spellFrame.additionalText = format(PET_ABILITY_REQUIRES_LEVEL, levels[i]);
			else
				spellFrame.additionalText = nil;
			end
			spellFrame.abilityID = abilities[i];
			spellFrame.petID = PetJournalPetCard.petID;
			spellFrame.speciesID = speciesID;
			spellFrame:Show();
		else
			spellFrame:Hide();
		end
	end
end

function PetJournal_UnwrapPet(petID)
	if PetJournalPetCard.modelScene:IsUnwrapAnimating() or not C_PetJournal.PetNeedsFanfare(petID) then
		return;
	end

	PetJournal_ShowPetCardByID(petID);

	local function OnFinishedCallback()
		C_PetJournal.ClearFanfare(petID);
		PetJournal_ShowPetCardByID(petID);
	end

	PetJournalPetCard.modelScene:StartUnwrapAnimation(OnFinishedCallback);
end

function PetJournal_SetPendingCage(petID)
	local self = PetJournal;
	self.pendingCage = petID;
end

function PetJournal_ClearPendingCage()
	local self = PetJournal;
	self.pendingCage = nil;
end

function PetJournal_IsPendingCage(petID)
	local self = PetJournal;
	return self.pendingCage and self.pendingCage == petID;
end

function GetPetTypeTexture(petType)
	if PET_TYPE_SUFFIX[petType] then
		return "Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType];
	else
		return "Interface\\PetBattles\\PetIcon-NO_TYPE";
	end
end

function PetJournalFilterDropdown_SetCollectedFilter(value)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, value);
end

function PetJournalFilterDropdown_GetCollectedFilter()
	return C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED);
end

function PetJournalFilterDropdown_SetNotCollectedFilter(value)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, value);
end

function PetJournalFilterDropdown_GetNotCollectedFilter()
	return C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED);
end

function PetJournalFilterDropdown_SetAllPetTypes(value)
	C_PetJournal.SetAllPetTypesChecked(value);
	return MenuResponse.Refresh;
end 

function PetJournalFilterDropdown_SetAllPetSources(value)
	C_PetJournal.SetAllPetSourcesChecked(value);
	return MenuResponse.Refresh;
end

---------------------------------------
-------Ability Tooltip stuff-----------
---------------------------------------

local PET_JOURNAL_ABILITY_INFO = SharedPetBattleAbilityTooltip_GetInfoTable();

function PET_JOURNAL_ABILITY_INFO:GetAbilityID()
	return self.abilityID;
end

function PET_JOURNAL_ABILITY_INFO:IsInBattle()
	return false;
end

function PET_JOURNAL_ABILITY_INFO:GetHealth(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(self.petID);
		return health;
	else
		--Do something with self.speciesID?
		return self:GetMaxHealth(target);
	end
end

function PET_JOURNAL_ABILITY_INFO:GetMaxHealth(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(self.petID);
		return maxHealth;
	else
		--Do something with self.speciesID?
		return 100;
	end
end

function PET_JOURNAL_ABILITY_INFO:GetAttackStat(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(self.petID);
		return power;
	else
		--Do something with self.speciesID?
		return 0;
	end
end

function PET_JOURNAL_ABILITY_INFO:GetSpeedStat(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(self.petID);
		return speed;
	else
		--Do something with self.speciesID?
		return 0;
	end
end

function PET_JOURNAL_ABILITY_INFO:GetPetOwner(target)
	self:EnsureTarget(target);
	return Enum.BattlePetOwner.Ally;
end

function PET_JOURNAL_ABILITY_INFO:GetPetType(target)
	self:EnsureTarget(target);
	if ( not self.speciesID ) then
		GMError("No species id found");
		return 1;
	end
	local _, _, petType = C_PetJournal.GetPetInfoBySpeciesID(self.speciesID);
	return petType;
end

function PET_JOURNAL_ABILITY_INFO:EnsureTarget(target)
	if ( target == "default" ) then
		target = "self";
	elseif ( target == "affected" ) then
		target = "enemy";
	end
	if ( target ~= "self" ) then
		GMError("Only \"self\" unit supported out of combat");
	end
end


local journalAbilityInfo = {};
setmetatable(journalAbilityInfo, {__index = PET_JOURNAL_ABILITY_INFO});
function PetJournal_ShowAbilityTooltip(self, abilityID, speciesID, petID, additionalText)
	if ( abilityID and abilityID > 0 ) then
		journalAbilityInfo.abilityID = abilityID;
		journalAbilityInfo.speciesID = speciesID;
		journalAbilityInfo.petID = petID;
		PetJournalPrimaryAbilityTooltip:ClearAllPoints();
		PetJournalPrimaryAbilityTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0);
		PetJournalPrimaryAbilityTooltip.anchoredTo = self;
		SharedPetBattleAbilityTooltip_SetAbility(PetJournalPrimaryAbilityTooltip, journalAbilityInfo, additionalText);
		PetJournalPrimaryAbilityTooltip:Show();
	end
end

function PetJournal_GetPetAbilityHyperlink(abilityID, petID)
	local maxHealth, power, speed, _;
	if ( petID ) then
		_, maxHealth, power, speed, _ = C_PetJournal.GetPetStats(petID);
	else
		maxHealth, power, speed = 100, 0, 0;
	end
	return GetBattlePetAbilityHyperlink(abilityID, maxHealth, power, speed);
end



local CompareInfo1 = {};
local CompareInfo2 = {};
setmetatable(CompareInfo1, {__index = PET_JOURNAL_ABILITY_INFO});
setmetatable(CompareInfo2, {__index = PET_JOURNAL_ABILITY_INFO});
function PetJournal_ShowAbilityCompareTooltip(abilityID1, abilityID2, speciesID, petID)
	if ( abilityID1 and abilityID2 ) then
		CompareInfo1.abilityID = abilityID1;
		CompareInfo1.speciesID = speciesID;
		CompareInfo1.petID = petID;

		CompareInfo2.abilityID = abilityID2;
		CompareInfo2.speciesID = speciesID;
		CompareInfo2.petID = petID;



		PetJournalSecondaryAbilityTooltip:ClearAllPoints();
		PetJournalSecondaryAbilityTooltip:SetPoint("TOPLEFT", PetJournal.SpellSelect, "RIGHT", -15, 0);
		PetJournalPrimaryAbilityTooltip:ClearAllPoints();
		PetJournalPrimaryAbilityTooltip:SetPoint("BOTTOM", PetJournalSecondaryAbilityTooltip, "TOP", 0, 5);

		PetJournalPrimaryAbilityTooltip.anchoredTo = PetJournal.SpellSelect;
		SharedPetBattleAbilityTooltip_SetAbility(PetJournalPrimaryAbilityTooltip, CompareInfo1);
		SharedPetBattleAbilityTooltip_SetAbility(PetJournalSecondaryAbilityTooltip, CompareInfo2);
		PetJournalPrimaryAbilityTooltip:Show();
		PetJournalSecondaryAbilityTooltip:Show();
	end
end

function PetJournal_HideAbilityTooltip(self)
	if ( PetJournalPrimaryAbilityTooltip.anchoredTo == self or not self ) then
		PetJournalPrimaryAbilityTooltip:Hide();
	end
end

function PetJournalPetCount_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(BATTLE_PETS_TOTAL_PETS, 1, 1, 1);
	GameTooltip:AddLine(BATTLE_PETS_TOTAL_PETS_TOOLTIP, nil, nil, nil, true);
	GameTooltip:Show();
end

function PetJournalFindBattle_Update(self)
	local queueState = C_PetBattles.GetPVPMatchmakingInfo();
	if ( queueState == "queued" or queueState == "proposal" or queueState == "suspended" ) then
		self:SetText(LEAVE_QUEUE);
	else
		self:SetText(FIND_BATTLE);
	end
end

function PetJournal_UpdateFindBattleButton()
	PetJournal.FindBattleButton:SetEnabled(C_PetJournal.IsFindBattleEnabled() and C_PetJournal.IsJournalUnlocked());
end

function PetJournalFindBattle_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(FIND_BATTLE, 1, 1, 1);
	GameTooltip:AddLine(BATTLE_PETS_FIND_BATTLE_TOOLTIP, nil, nil, nil, true);

	if (not C_PetJournal.IsFindBattleEnabled()) then
		GameTooltip:AddLine(BATTLE_PET_FIND_BATTLE_DISABLED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	elseif (not C_PetJournal.IsJournalUnlocked()) then
		GameTooltip:AddLine(BATTLE_PET_FIND_BATTLE_READONLY, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	end

	GameTooltip:Show();
end

function PetJournalAchievementStatus_OnClick()
	ToggleAchievementFrame();
	AchievementFrame_UpdateAndSelectCategory(PET_ACHIEVEMENT_CATEGORY);
end

function PetJournalAchievementStatus_OnEnter(self)
	PetJournal.AchievementStatus.highlight:Show();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(BATTLE_PETS_ACHIEVEMENT, HIGHLIGHT_FONT_COLOR:GetRGB());
	GameTooltip:AddLine(BATTLE_PETS_ACHIEVEMENT_TOOLTIP, nil, nil, nil, true);
	GameTooltip:Show();
end

function PetJournalAchievementStatus_OnLeave()
	PetJournal.AchievementStatus.highlight:Hide();
	GameTooltip:Hide();
end

function PetJournalSummonButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self:GetText(), HIGHLIGHT_FONT_COLOR:GetRGB());

	local needsFanFare = PetJournalPetCard.petID and C_PetJournal.PetNeedsFanfare(PetJournalPetCard.petID);
	if needsFanFare then
		GameTooltip:AddLine(BATTLE_PETS_UNWRAP_TOOLTIP, nil, nil, nil, true);
	else
		GameTooltip:AddLine(BATTLE_PETS_SUMMON_TOOLTIP, nil, nil, nil, true);
	end

	if PetJournalPetCard.petID ~= nil then
		local isSummonable, error, errorText = C_PetJournal.GetPetSummonInfo(PetJournalPetCard.petID);
		if errorText then
			GameTooltip_AddErrorLine(GameTooltip, errorText, true);
		end
	end

	GameTooltip:Show();
end

---------------------------------------
-------Help plate stuff-----------
---------------------------------------

PetJournal_HelpPlate = {
	FramePos = { x = 0,          y = -22 },
	FrameSize = { width = 700, height = 580 },
	[1] = { ButtonPos = { x = 26,	y = -75 },  HighLightBox = { x = 10, y = -72, width = 247, height = 50 },	 ToolTipDir = "RIGHT",  ToolTipText = PET_JOURNAL_HELP_1 },
	[2] = { ButtonPos = { x = 105,  y = -300 }, HighLightBox = { x = 10, y = -125, width = 247, height = 430 },  ToolTipDir = "DOWN",   ToolTipText = PET_JOURNAL_HELP_2 },
	[3] = { ButtonPos = { x = 470,  y = -245 }, HighLightBox = { x = 290, y = -215, width = 400, height = 340 }, ToolTipDir = "DOWN",   ToolTipText = PET_JOURNAL_HELP_3 },
	[4] = { ButtonPos = { x = 525,  y = -546},  HighLightBox = { x = 550, y = -556, width = 150, height = 26 },  ToolTipDir = "UP",		ToolTipText = PET_JOURNAL_HELP_4 },
	[5] = { ButtonPos = { x = 470,  y = -95 },  HighLightBox = { x = 290, y = -45, width = 400, height = 160 },  ToolTipDir = "RIGHT",  ToolTipText = PET_JOURNAL_HELP_5 },
	[6] = { ButtonPos = { x = 525,  y = 0 },	HighLightBox = { x = 550, y = 0, width = 150, height = 40 },     ToolTipDir = "LEFT",   ToolTipText = PET_JOURNAL_HELP_6 },
}

function PetJournal_ToggleTutorial()
	local helpPlate = PetJournal_HelpPlate;
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, PetJournal, PetJournal.MainHelpButton );
		SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true );
		CollectionsJournal_HideTabHelpTips();
	else
		HelpPlate_Hide(true);
	end
end