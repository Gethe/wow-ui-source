

local COMPANION_BUTTON_HEIGHT = 46;
local MAX_ACTIVE_PETS = 3;
local NUM_PET_ABILITIES = 6;
PET_ACHIEVEMENT_CATEGORY = 15117;


function PetJournal_OnLoad(self)
	PetJournalTitleText:SetText(PET_JOURNAL);
	SetPortraitToTexture(PetJournalPortrait,"Interface\\Icons\\spell_magic_polymorphrabbit");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
	self:RegisterEvent("BATTLE_PET_CURSOR_CLEAR");
	
	
	self.listScroll.update = PetJournal_UpdatePetList;
	self.listScroll.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.listScroll, "CompanionListButtonTemplate", 0, 0);
	
	
	--PanelTemplates_DeselectTab(PetJournalTab2);
	PetJournal.isWild = false;
end


function PetJournal_OnShow(self)
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	PetJournal_UpdatePetList();
	PetJournal_UpdatePetLoadOut();
	
	local numPoints = 0;
	local _, numCompleted = GetCategoryNumAchievements(PET_ACHIEVEMENT_CATEGORY);
	for i=1,numCompleted do
		local _, name, points = GetAchievementInfo(PET_ACHIEVEMENT_CATEGORY, i);
		numPoints = numPoints + points;
	end
	PetJournal.AchievementStatus.SumText:SetText(numPoints);
end


function PetJournal_OnHide(self)
	UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
	PetJournal.SpellSelect:Hide();
end


function PetJournal_OnEvent(self, event, ...)
	if event == "PET_JOURNAL_LIST_UPDATE" then
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetList();
	elseif event == "BATTLE_PET_CURSOR_CLEAR" then
		PetJournal.Loadout.Pet1.setButton:Hide();
		PetJournal.Loadout.Pet2.setButton:Hide();
		PetJournal.Loadout.Pet3.setButton:Hide();
	end
end


function PetJournal_OnTabClick(isWild)
	PetJournal.isWild = isWild;
	if isWild then
		PanelTemplates_DeselectTab(PetJournalTab1);
		PanelTemplates_SelectTab(PetJournalTab2);
	else
		PanelTemplates_DeselectTab(PetJournalTab2);
		PanelTemplates_SelectTab(PetJournalTab1);
	end
	PetJournal_UpdatePetList();
end


function PetJournal_UpdatePetAbility(AbilityFrame, abilityID)

	local name, icon, typeEnum = C_PetJournal.GetPetAbilityInfo(abilityID);
	AbilityFrame.icon:SetTexture(icon);
	AbilityFrame.abilityID = abilityID;
	AbilityFrame.selected:Hide();
end


function PetJournal_UpdatePetAbilityList(self)
	--local abilityIndex = self:GetID();
	local slotFrame = self;
	local slotIndex = slotFrame:GetID();
	local petID, ability1ID, ability2ID, ability3ID = C_PetJournal.GetPetLoadOutInfo(slotIndex);
	if petID ~= slotFrame.petID then
		PetJournal_UpdatePetLoadOut(); --shouldn't ever happen
	end
	
	local abilities = {C_PetJournal.GetPetAbilityList(slotFrame.speciesID)};
	slotFrame.abilities = abilities;
	
	if #abilities == 6 then
		slotFrame.spell1:Enable();
		slotFrame.spell2:Enable();
		slotFrame.spell3:Enable();
	elseif #abilities == 5 then
		slotFrame.spell1:Enable();
		slotFrame.spell2:Enable();
		slotFrame.spell3:Disable();
	elseif #abilities == 4 then
		slotFrame.spell1:Enable();
		slotFrame.spell2:Disable();
		slotFrame.spell3:Disable();
	else
		slotFrame.spell1:Disable();
		slotFrame.spell2:Disable();
		slotFrame.spell3:Disable();
	end
end


function PetJournal_ShowPetSelect(self)
	local slotFrame = self:GetParent();
	local abilities = slotFrame.abilities;
	local slotIndex = slotFrame:GetID();

	local abilityIndex = self:GetID();
	local spellIndex1 = abilityIndex;
	local spellIndex2 = spellIndex1 + 3;
	
	if PetJournal.SpellSelect:IsShown() and 
		PetJournal.SpellSelect.slotIndex == slotIndex and 
		PetJournal.SpellSelect.abilityIndex == abilityIndex then
		PetJournal.SpellSelect:Hide();
		self.selected:Hide();
		return;
	end
	
	self.selected:Show();
	PetJournal.SpellSelect.slotIndex = slotIndex;
	PetJournal.SpellSelect.abilityIndex = abilityIndex;
	
	--Setup spell one
	local name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex1]);
	PetJournal.SpellSelect.Spell1.name:SetText(name);
	PetJournal.SpellSelect.Spell1.icon:SetTexture(icon);
	PetJournal.SpellSelect.Spell1.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
	PetJournal.SpellSelect.Spell1.slotIndex = slotIndex;
	PetJournal.SpellSelect.Spell1.abilityIndex = abilityIndex;
	PetJournal.SpellSelect.Spell1.abilityID = abilities[spellIndex1];
	--Setup spell two
	name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex2]);
	PetJournal.SpellSelect.Spell2.name:SetText(name);
	PetJournal.SpellSelect.Spell2.icon:SetTexture(icon);
	PetJournal.SpellSelect.Spell2.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
	PetJournal.SpellSelect.Spell2.slotIndex = slotIndex;
	PetJournal.SpellSelect.Spell2.abilityIndex = abilityIndex;
	PetJournal.SpellSelect.Spell2.abilityID = abilities[spellIndex2];
	
	
	PetJournal.SpellSelect.Spell1.selected:Hide();
	PetJournal.SpellSelect.Spell2.selected:Hide();
	if self.abilityID == abilities[spellIndex1] then
		PetJournal.SpellSelect.Spell1.selected:Show();
	elseif self.abilityID == abilities[spellIndex2] then
		PetJournal.SpellSelect.Spell2.selected:Show();
	end
	
	PetJournal.SpellSelect:SetPoint("TOP", slotFrame, "BOTTOM", 0, 35);
	PetJournal.SpellSelect:Show();
end


function PetJournal_UpdatePetLoadOut()
	PetJournal.SpellSelect:Hide();
	for i=1,MAX_ACTIVE_PETS do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local petID, ability1ID, ability2ID, ability3ID = C_PetJournal.GetPetLoadOutInfo(i);
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID);
		if name then
			loadoutPlate.name:SetText(name);
			loadoutPlate.level:SetText(level);
			loadoutPlate.icon:SetTexture(icon);
			
			loadoutPlate.model:Show();
			if displayID ~= 0 and displayID ~= loadoutPlate.displayID then
				loadoutPlate.displayID = displayID;
				loadoutPlate.model:SetDisplayInfo(displayID);
			elseif creatureID ~= 0 and creatureID ~= loadoutPlate.creatureID then
				loadoutPlate.creatureID = creatureID;
				loadoutPlate.model:SetCreature(creatureID);
			end
				
			loadoutPlate.petTypeIcon:SetTexture(GetPetTypeTexture(petType));	
			loadoutPlate.petID = petID;
			loadoutPlate.speciesID = speciesID;
			loadoutPlate.helpFrame:Hide();
			
			PetJournal_UpdatePetAbility(loadoutPlate.spell1, ability1ID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell2, ability2ID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell3, ability3ID);
			PetJournal_UpdatePetAbilityList(loadoutPlate)
		else
			loadoutPlate.helpFrame:Show();
			loadoutPlate.model:Hide();
		end
	end
	
	PetJournal.Loadout.Pet1.setButton:Hide();
	PetJournal.Loadout.Pet2.setButton:Hide();
	PetJournal.Loadout.Pet3.setButton:Hide();
end


function PetJournal_UpdatePetList()
	local scrollFrame = PetJournal.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local petButtons = scrollFrame.buttons;
	local pet, index;
	
	local isWild = PetJournal.isWild;
	
	local numPets = C_PetJournal.GetNumPets(isWild);
	
	for i = 1,#petButtons do
		pet = petButtons[i];
		index = offset + i;
		if index <= numPets then
			local petID, speciesID, isOwned, customName, level, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByIndex(index, isWild);
			
			pet.name:SetText(name);
			pet.icon:SetTexture(icon);
			pet.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
			
			
			--TODO: Add favorite checking. Needs Gameplay
			pet.favorite:Hide();
			
			if isOwned then
				pet.levelBG:Show();
				pet.level:Show();
				pet.level:SetText(level);
				pet.icon:SetDesaturated(0);
				pet.name:SetFontObject("GameFontHighlight");
				pet.petTypeIcon:SetDesaturated(0);
				pet:Enable();
			else
				pet.levelBG:Hide();
				pet.level:Hide();
				pet.icon:SetDesaturated(1);
				pet.name:SetFontObject("GameFontDisable");
				pet.petTypeIcon:SetDesaturated(1);
				pet:Disable();
			end
			pet.petID = petID;
			pet.speciesID = speciesID;
			pet.index = index;
			pet:Show();
			if pet.showingTooltip then
				GameTooltip:SetItemByID(petID);
			end
			
			--Update Petcard Button
			if PetJournal.pcIndex == index then
				pet.selected = true;
				pet.previewButton:Show();
				pet.previewButton.selectedTexture:Show();
				pet.selectedTexture:Show();
			else
				pet.selected = false;
				pet.previewButton.selectedTexture:Hide()
				pet.selectedTexture:Hide()
				if not pet:IsMouseOver() then
					pet.previewButton:Hide()
				end
			end
		else
			pet:Hide();
		end
	end
	
	local totalHeight = numPets * COMPANION_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
end


function PetJournal_UpdatePetCardToggleButtons()
	local petButtons = PetJournal.listScroll.buttons;
	local pet;
	
	for i = 1,#petButtons do
		pet = petButtons[i];
		if not pet.selected then
			if not pet:IsMouseOver() then
				pet.previewButton:Hide();
			else
				pet.previewButton:Show();
			end
		end
	end
end


function PetJournal_OnSearchTextChanged(self)
	local text = self:GetText();
	if text == SEARCH then
		C_PetJournal.SetSearchFilter("");
		return;
	end
	
	C_PetJournal.SetSearchFilter(text);
end


function PetJournal_OnPetDragStart(self)
	C_PetJournal.PickupPet(self.petID, PetJournal.isWild);
	PetJournal.Loadout.Pet1.setButton:Show();
	PetJournal.Loadout.Pet2.setButton:Show();
	PetJournal.Loadout.Pet3.setButton:Show();
end


function PetJournal_TogglePetCardByID(petID)
	PetJournal.pcPetID = petID;
	PetJournal.pcSpeciesID = C_PetJournal.GetPetInfoByPetID(petID);
	
	PetJournal_FindPetCardIndex();
	PetJournal_UpdatePetCard(PetJournal.PetCardList.MainCard);
	PetJournal.PetCardList:Show();
	PetJournal_UpdatePetList();
end


function PetJournal_TogglePetCard(index)
	if PetJournal.PetCardList:IsShown() and PetJournal.pcIndex == index then
		PetJournal_HidePetCard()
	else
		PetJournal.pcIndex = index;
		PetJournal.pcPetID, PetJournal.pcSpeciesID, owned = C_PetJournal.GetPetInfoByIndex(index, PetJournal.isWild);		
		if not owned then
			PetJournal.pcPetID = nil;
		end
		PetJournal_UpdatePetCard(PetJournal.PetCardList.MainCard);
		PetJournal.PetCardList:Show();
		PetJournal_UpdatePetList();
	end
end

function PetJournal_FindPetCardIndex()
	PetJournal.pcIndex = nil;
	local numPets = C_PetJournal.GetNumPets(PetJournal.isWild);
	for i = 1,numPets do
		local petID, speciesID, owned = C_PetJournal.GetPetInfoByIndex(i, isWild);
		if (owned and petID == PetJournal.pcPetID) or
			(not owned and speciesID == PetJournal.pcSpeciesID)  then
			PetJournal.pcIndex = i;
			break;
		end
	end
end

function PetJournal_HidePetCard()
	PetJournal.PetCardList:Hide();
	PetJournal.pcIndex = nil;
	PetJournal.pcPetID = nil;
	PetJournal.pcSpeciesID = nil;
	PetJournal_UpdatePetList();
end

function PetJournal_UpdatePetCard(self)
	local speciesID, customName, level, name, icon, petType, creatureID, xp, maxXp, displayID, _;		
	if PetJournal.pcPetID then
		speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(PetJournal.pcPetID);
		self.level:SetText(level);
		self.level:Show();
		self.levelBG:Show();
		self.xpbar:Show();
	else
		speciesID = PetJournal.pcSpeciesID;
		name, icon, petType, creatureID = C_PetJournal.GetPetInfoBySpeciesID(PetJournal.pcSpeciesID);
		self.level:Hide();
		self.levelBG:Hide();
		self.xpbar:Hide();
	end
	
	self.name:SetText(customName or name);
	
	self.icon:SetTexture(icon);
	
	self.model:Show();
	if displayID ~= 0 and displayID ~= self.displayID then
		self.displayID = displayID;
		self.model:SetDisplayInfo(displayID);
	elseif creatureID ~= 0 and creatureID ~= self.creatureID then
		self.creatureID = creatureID;
		self.model:SetCreature(creatureID);
	end
		
	self.petTypeIcon:SetTexture(GetPetTypeTexture(petType) );
	
	--Update pet abilites
	local abilities = {C_PetJournal.GetPetAbilityList(speciesID)};
	for i=1,NUM_PET_ABILITIES do
		local spellFrame = self["spell"..i];
		if abilities[i] then
			local name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[i]);
			spellFrame.name:SetText(name);
			spellFrame.icon:SetTexture(icon);
			spellFrame.petTypeIcon:SetTexture(GetPetTypeTexture(petType) );
			spellFrame:Show();
		else
			spellFrame:Hide();
		end
	end
	
	Model_Reset(self.model);
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


function PetJournalFilterDropDown_Initialize(self, level)
	
	local info = UIDropDownMenu_CreateInfo();
	
	if level == 1 then
	
		info.text = COLLECTED
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, value);
						end 
		info.keepShownOnClick = true;
		info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		
		info.text = NOT_COLLECTED
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, value);
						end 
		info.keepShownOnClick = true;
		info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_NOT_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		
		
		info.text = FAVORITES
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_FAVORITES, value);
						end 
		info.keepShownOnClick = true;
		--info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_FAVORITES);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		
		info.keepShownOnClick = true;
		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;
				
		info.text = PET_FAMILIES
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)
		
		info.text = SOURCES
		info.value = 2;
		UIDropDownMenu_AddButton(info, level)
	
	else --if level == 2 then	
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;
			info.keepShownOnClick = true;
				
		
			info.text = CHECK_ALL
			info.func = function()
							C_PetJournal.AddAllPetTypesFilter();
							UIDropDownMenu_RefreshAll(PetJournalFilterDropDown);
						end
			UIDropDownMenu_AddButton(info, level)
			
			info.text = UNCHECK_ALL
			info.func = function()
							C_PetJournal.ClearAllPetTypesFilter();
							UIDropDownMenu_RefreshAll(PetJournalFilterDropDown);
						end
			UIDropDownMenu_AddButton(info, level)
		
			info.notCheckable = false;
			local numTypes = C_PetJournal.GetNumPetTypes();
			for i=1,numTypes do
				info.text = _G["BATTLE_PET_NAME_"..i];
				info.func = function(_, _, _, value)
							C_PetJournal.SetPetTypeFilter(i, value);
						end
				info.checked = function() return not C_PetJournal.IsPetTypeFiltered(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
		
		end
	end
end


