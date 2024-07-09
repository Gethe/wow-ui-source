local COMPANION_BUTTON_HEIGHT = 46;
local MAX_ACTIVE_PETS = 3;
local NUM_PET_ABILITIES = 6;
PET_ACHIEVEMENT_CATEGORY = 15117;
local MAX_PET_LEVEL = 25;
local HEAL_PET_SPELL = 125439;
local SUMMON_RANDOM_FAVORITE_PET_SPELL = 243819;

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

	UIDropDownMenu_Initialize(self.petOptionsMenu, PetOptionsMenu_Init, "MENU");

	PetJournal_ShowPetCard(1);
end

function PetJournal_OnShow(self)
	PetJournal_UpdatePetList();
	PetJournal_UpdatePetCard(PetJournalPetCard);

	SetPortraitToTexture(self:GetParent().portrait, "Interface\\ICONS\\Spell_Magic_PolymorphChicken");
end


function PetJournal_OnHide(self)
	C_PetJournal.ClearRecentFanfares();
end

function PetJournal_OnEvent(self, event, ...)
	if event == "PET_JOURNAL_PET_DELETED" then
		local petID = ...;
		if (PetJournal_IsPendingCage(petID)) then
			PetJournal_ClearPendingCage();
		end
		PetJournal_UpdatePetList();
		if(PetJournalPetCard.petID == petID) then
			PetJournal_ShowPetCard(1);
		end
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetCard(PetJournalPetCard);
		PetJournal_HidePetDropdown();
	elseif event == "PET_JOURNAL_LIST_UPDATE" then
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetList();
		PetJournal_UpdatePetCard(PetJournalPetCard);
		PetJournal_HidePetDropdown();
	elseif event == "COMPANION_UPDATE" then
		local companionType = ...;
		if companionType == "CRITTER" then
			PetJournal_UpdatePetList();
			PetJournal_UpdateSummonButtonState();
		end
	elseif event == "ACHIEVEMENT_EARNED" then
		PetJournal.AchievementStatus.SumText:SetText(GetCategoryAchievementPoints(PET_ACHIEVEMENT_CATEGORY, true));
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		if (self:IsVisible()) then
			PetJournal_UpdatePetCard(PetJournalPetCard, true);
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

	if hasPetID and C_PetJournal.IsCurrentlySummoned(petID) then
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

-- SUMMON RANDOM FAVORITE PET ---
--[[
function PetJournalSummonRandomFavoritePetButton_OnLoad(self)
	self.spellID = SUMMON_RANDOM_FAVORITE_PET_SPELL;
	self.petID = C_PetJournal.GetSummonRandomFavoritePetGUID();
	local spellName, _, spellIcon = GetSpellInfo(self.spellID);
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
]]--

function PetJournal_UpdateAll()
	PetJournal_UpdatePetList();
	PetJournal_UpdatePetCard(PetJournalPetCard);
	PetJournal_HidePetDropdown();
end

function PetJournal_InitPetButton(pet, elementData)
	local index = elementData.index;

	local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByIndex(index);
	local needsFanfare = petID and C_PetJournal.PetNeedsFanfare(petID);

	if customName then
		pet.name:SetText(customName);
		pet.name:SetHeight(12);
	else
		pet.name:SetText(name);
		pet.name:SetHeight(30);
	end

	pet.icon:SetTexture(needsFanfare and COLLECTIONS_FANFARE_ICON or icon);
	pet.new:SetShown(needsFanfare);
	pet.newGlow:SetShown(needsFanfare);

	if (favorite) then
		pet.dragButton.favorite:Show();
	else
		pet.dragButton.favorite:Hide();
	end

	CollectionItemListButton_SetRedOverlayShown(pet, false);

	if isOwned then
		pet.icon:SetDesaturated(false);
		pet.name:SetFontObject("GameFontNormal");
		pet.dragButton:Enable();
		pet.iconBorder:Show();
		if(isRevoked) then
			pet.iconBorder:Hide();
			pet.icon:SetDesaturated(true);
		else
			-- Only display the unusable texture if you'll never be able to summon this pet.
			local isSummonable, error, errorText = C_PetJournal.GetPetSummonInfo(petID);
			local neverUsable = error == Enum.PetJournalError.InvalidFaction or error == Enum.PetJournalError.InvalidCovenant;
			pet.iconBorder:SetShown(not neverUsable);
			CollectionItemListButton_SetRedOverlayShown(pet, neverUsable);
		end
	else
		pet.icon:SetDesaturated(true);
		pet.iconBorder:Hide();
		pet.name:SetFontObject("GameFontDisable");
		pet.dragButton:Disable();
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

function PetJournalListItem_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local id = self.petID;
		if ( id and MacroFrame and MacroFrame:IsShown() ) then
			-- Macros are not yet supported
		elseif (id) then
			--local petLink = C_PetJournal.GetBattlePetLink(id);
			--ChatEdit_InsertLink(petLink);
		end
	elseif button == "RightButton" then
		if self.owned then
			PetJournal_ShowPetDropdown(self.index, self, 80, 20);
		end
	elseif SpellIsTargeting() then
		C_PetJournal.SpellTargetBattlePet(self.petID);
	elseif GetCursorInfo() == "battlepet" then
		ClearCursor();
	else
		PetJournal_ShowPetCard(self.index);
	end
end

function PetJournalDragButton_OnEnter(self)
	local petID = self:GetParent().petID;
	if (not petID) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetCompanionPet(petID);
	GameTooltip:Show();
end

function PetJournalDragButton_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local id = self:GetParent().petID;
		if ( id and MacroFrame and MacroFrame:IsShown() ) then
			-- Macros are not yet supported
		elseif (id) then
			--local petLink = C_PetJournal.GetBattlePetLink(id);
			--ChatEdit_InsertLink(petLink);
		end
	elseif ( button == "RightButton" ) then
		local parent = self:GetParent();
		if ( parent.owned ) then
			PetJournal_ShowPetDropdown(parent.index, self, 0, 0);
		end
	elseif SpellIsTargeting() then
		C_PetJournal.SpellTargetBattlePet(self:GetParent().petID);
	elseif GetCursorInfo() == "battlepet" then
		ClearCursor();
	else
		PetJournalDragButton_OnDragStart(self);
	end
end

function PetJournalDragButton_OnDragStart(self)
	if (not self:GetParent().petID) then
		return;
	end

	if(C_PetJournal.PetIsRevoked(self:GetParent().petID)) then
		return;
	end

	PetJournal_HidePetDropdown();
	C_PetJournal.PickupPet(self:GetParent().petID);
end

function PetJournalDragButton_OnEvent(self, event, ...)
	if ( event == "SPELL_UPDATE_COOLDOWN" and self:GetParent().petID) then
		local start, duration, enable = C_PetJournal.GetPetCooldownByGUID(self:GetParent().petID);
		if (start) then
			CooldownFrame_Set(self.Cooldown, start, duration, enable);
		end
	end
end

function PetJournal_ShowPetDropdown(index, anchorTo, offsetX, offsetY, petID)
	if (index) then
		PetJournal.menuPetID = C_PetJournal.GetPetInfoByIndex(index);
	elseif (petID) then
		PetJournal.menuPetID = petID;
	else
		return;
	end
	ToggleDropDownMenu(1, nil, PetJournal.petOptionsMenu, anchorTo, offsetX, offsetY);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function PetJournal_HidePetDropdown()
	if (UIDropDownMenu_GetCurrentDropDown() == PetJournal.petOptionsMenu) then
		HideDropDownMenu(1);
	end
end

function PetJournal_ShowPetCardByID(petID)
	if (petID == nil) then
		PetJournal_ShowPetCard(1);
		return;
	end

	PetJournal_HidePetDropdown();

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

	PetJournal_HidePetDropdown();

	PetJournalPetCard.petID = nil;
	PetJournalPetCard.speciesID = speciesID;

	PetJournal_FindPetCardIndex();
	PetJournal_UpdatePetCard(PetJournalPetCard);
	PetJournal_UpdatePetList();
	PetJournal_UpdateSummonButtonState();
end

function PetJournal_ShowPetCard(index)
	PetJournal_HidePetDropdown();
	PetJournalPetCard.petIndex = index;
	local owned;

	local ID;
	local species;
	ID, species, owned = C_PetJournal.GetPetInfoByIndex(index);
	PetJournalPetCard.petID = ID;
	PetJournalPetCard.speciesID = species;
	
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
			--local petLink = C_PetJournal.GetBattlePetLink(id);
			--ChatEdit_InsertLink(petLink);
		end
	elseif button == "RightButton" then
		if ( PetJournalPetCard.petID ) then
			PetJournal_ShowPetDropdown(PetJournalPetCard.petIndex, self, 0, 0, PetJournalPetCard.petID);
		end
	else
		PetJournalDragButton_OnDragStart(self);
	end
end

function PetJournal_UpdatePetCard(self, forceSceneChange)
	if (not PetJournalPetCard.petID and not PetJournalPetCard.speciesID) then
		--Select a pet from the list on the left
		self.PetInfo.name:SetText(PET_JOURNAL_CARD_NAME_DEFAULT);
		self.PetInfo.icon:Hide();
		self.modelScene:Hide();
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
		needsFanfare = C_PetJournal.PetNeedsFanfare(PetJournalPetCard.petID);
	else
		speciesID = PetJournalPetCard.speciesID;
		name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, _, displayID = C_PetJournal.GetPetInfoBySpeciesID(PetJournalPetCard.speciesID);
	end
	self.PetInfo.isDead:SetShown(isDead);

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

function PetJournalFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PetJournalFilterDropDown_Initialize, "MENU");
end

function PetJournalFilterDropDown_ResetFilters()
	C_PetJournal.SetDefaultFilters();
end

function PetJournalFilterDropDown_SetCollectedFilter(value)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, value);
end

function PetJournalFilterDropDown_GetCollectedFilter()
	return C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED);
end

function PetJournalFilterDropDown_SetNotCollectedFilter(value)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, value);
end

function PetJournalFilterDropDown_GetNotCollectedFilter()
	return C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED);
end

function PetJournalFilterDropDown_SetAllPetTypes(value)
	C_PetJournal.SetAllPetTypesChecked(value);
	UIDropDownMenu_Refresh(PetJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
end 

function PetJournalFilterDropDown_SetAllPetSources(value)
	C_PetJournal.SetAllPetSourcesChecked(value);
	UIDropDownMenu_Refresh(PetJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
end

function PetJournalFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;

	if level == 1 then

		info.text = COLLECTED
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, value);
						end
		info.checked = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level);

		info.disabled = nil;

		info.text = NOT_COLLECTED;
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, value);
						end
		info.checked = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level);
	end
end

function PetJournalFilterDropDown_AddInSortParameters(filterSystem, level)
	local sortParameters = {
		{ text = NAME, parameter = LE_SORT_BY_NAME, },
		{ text = LEVEL, parameter = LE_SORT_BY_LEVEL, },
		{ text = RARITY, parameter = LE_SORT_BY_RARITY, },
		{ text = TYPE, parameter = LE_SORT_BY_PETTYPE, },
	};

	for index, sortParameter in ipairs(sortParameters) do
		local setSelected = function() 
					C_PetJournal.SetPetSortParameter(sortParameter.parameter); 
					PetJournal_UpdatePetList(); 
				end
		local isSelected = function() return C_PetJournal.GetPetSortParameter() == sortParameter.parameter end;
		FilterDropDownSystem.AddRadioButtonToFilterSystem(filterSystem, sortParameter.text, setSelected, isSelected, level);
	end
end

function PetOptionsMenu_Init(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	local needsFanfare = PetJournal.menuPetID and C_PetJournal.PetNeedsFanfare(PetJournal.menuPetID);

	if needsFanfare then
		info.text = UNWRAP;
		info.func = function() PetJournal_UnwrapPet(PetJournal.menuPetID); end
		UIDropDownMenu_AddButton(info, level);
	else
		local isRevoked = PetJournal.menuPetID and C_PetJournal.PetIsRevoked(PetJournal.menuPetID);
		local isLockedForConvert = PetJournal.menuPetID and C_PetJournal.PetIsLockedForConvert(PetJournal.menuPetID);

		if (not isRevoked and not isLockedForConvert) then
			info.text = BATTLE_PET_SUMMON;
			local speciesID = PetJournal.menuPetID and C_PetJournal.GetPetInfoByPetID(PetJournal.menuPetID)
			info.func = function() C_PetJournal.SummonPetByGUID(PetJournal.menuPetID); end
			if (PetJournal.menuPetID and C_PetJournal.IsCurrentlySummoned(PetJournal.menuPetID)) then
				info.text = PET_DISMISS;
				info.func = function() C_PetJournal.DismissSummonedPet(PetJournal.menuPetID); end
			end
			if (PetJournal.menuPetID and not C_PetJournal.PetIsSummonable(PetJournal.menuPetID)) then
				info.disabled = true;
			end
			UIDropDownMenu_AddButton(info, level);
			info.disabled = nil;
		end

		local isFavorite = PetJournal.menuPetID and C_PetJournal.PetIsFavorite(PetJournal.menuPetID);
		if (isFavorite or (not isRevoked and not isLockedForConvert)) then
			if (isFavorite) then
				info.text = BATTLE_PET_UNFAVORITE;
				info.func = function()
					C_PetJournal.SetFavorite(PetJournal.menuPetID, 0);
				end
			else
				info.text = BATTLE_PET_FAVORITE;
				info.func = function()
					C_PetJournal.SetFavorite(PetJournal.menuPetID, 1);
				end
			end
			info.disabled = not C_PetJournal.IsJournalUnlocked();
			UIDropDownMenu_AddButton(info, level);
			info.disabled = nil;
		end
	end

	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

function PetJournalPetCount_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(BATTLE_PETS_TOTAL_PETS, 1, 1, 1);
	GameTooltip:AddLine(BATTLE_PETS_TOTAL_PETS_TOOLTIP, nil, nil, nil, true);
	GameTooltip:Show();

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

function PetJournalSummonButton_OnClick(self)
	local active = PetJournalPetCard.petID and C_PetJournal.IsCurrentlySummoned(PetJournalPetCard.petID);
	if ( active ) then
		C_PetJournal.DismissSummonedPet(PetJournalPetCard.petID);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		if(C_PetJournal.PetNeedsFanfare(PetJournalPetCard.petID)) then
			PetJournal_UnwrapPet(PetJournalPetCard.petID);
		else
			C_PetJournal.SummonPetByGUID(PetJournalPetCard.petID);
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end	
end