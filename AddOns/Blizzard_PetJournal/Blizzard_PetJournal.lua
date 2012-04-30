

local COMPANION_BUTTON_HEIGHT = 46;
local MAX_ACTIVE_PETS = 3;
local NUM_PET_ABILITIES = 6;
PET_ACHIEVEMENT_CATEGORY = 15117;



StaticPopupDialogs["BATTLE_PET_RENAME"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 16,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		C_PetJournal.SetCustomName(PetJournal.menuPetID, text);
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local text = parent.editBox:GetText();
		C_PetJournal.SetCustomName(PetJournal.menuPetID, text);
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
		C_PetJournal.CagePetByID(PetJournal.menuPetID);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};


function PetJournal_OnLoad(self)
	PetJournalTitleText:SetText(PET_JOURNAL);
	SetPortraitToTexture(PetJournalPortrait,"Interface\\Icons\\spell_magic_polymorphrabbit");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
	self:RegisterEvent("PET_JOURNAL_PET_DELETED");
	self:RegisterEvent("BATTLE_PET_CURSOR_CLEAR");
	
	
	self.listScroll.update = PetJournal_UpdatePetList;
	self.listScroll.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.listScroll, "CompanionListButtonTemplate", 44, 0);
	
	
	--PanelTemplates_DeselectTab(PetJournalTab2);
	PetJournal.isWild = false;
	UIDropDownMenu_Initialize(self.petOptionsMenu, PetOptionsMenu_Init, "MENU");
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
	if event == "PET_JOURNAL_PET_DELETED" then
		local petID = ...;
		if(PetJournal.pcPetID == petID) then
			PetJournal_HidePetCard();
		end
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetList();
		PetJournal_UpdatePetLoadOut();
	elseif event == "PET_JOURNAL_LIST_UPDATE" then
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


function PetJournal_UpdatePetAbility(AbilityFrame, abilityID, petID, speciesID)

	local name, icon, typeEnum = C_PetJournal.GetPetAbilityInfo(abilityID);
	AbilityFrame.icon:SetTexture(icon);
	AbilityFrame.abilityID = abilityID;
	AbilityFrame.petID = petID;
	AbilityFrame.speciesID = speciesID;
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
	PetJournal_HideAbilityTooltip();
	
	--Setup spell one
	local name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex1]);
	PetJournal.SpellSelect.Spell1.name:SetText(name);
	PetJournal.SpellSelect.Spell1.icon:SetTexture(icon);
	PetJournal.SpellSelect.Spell1.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
	PetJournal.SpellSelect.Spell1.slotIndex = slotIndex;
	PetJournal.SpellSelect.Spell1.abilityIndex = abilityIndex;
	PetJournal.SpellSelect.Spell1.abilityID = abilities[spellIndex1];
	PetJournal.SpellSelect.Spell1.petID = slotFrame.petID;
	PetJournal.SpellSelect.Spell1.speciesID = slotFrame.speciesID;
	--Setup spell two
	name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex2]);
	PetJournal.SpellSelect.Spell2.name:SetText(name);
	PetJournal.SpellSelect.Spell2.icon:SetTexture(icon);
	PetJournal.SpellSelect.Spell2.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
	PetJournal.SpellSelect.Spell2.slotIndex = slotIndex;
	PetJournal.SpellSelect.Spell2.abilityIndex = abilityIndex;
	PetJournal.SpellSelect.Spell2.abilityID = abilities[spellIndex2];
	PetJournal.SpellSelect.Spell2.petID = slotFrame.petID;
	PetJournal.SpellSelect.Spell2.speciesID = slotFrame.speciesID;
	
	
	PetJournal.SpellSelect.Spell1.selected:Hide();
	PetJournal.SpellSelect.Spell2.selected:Hide();
	if self.abilityID == abilities[spellIndex1] then
		PetJournal.SpellSelect.Spell1.selected:Show();
	elseif self.abilityID == abilities[spellIndex2] then
		PetJournal.SpellSelect.Spell2.selected:Show();
	end
	
	PetJournal.SpellSelect:SetPoint("TOP", slotFrame, "BOTTOM", 0, 35);
	PetJournal.SpellSelect:Show();
	PetJournal_ShowAbilityCompareTooltip(abilities[spellIndex1], abilities[spellIndex2], slotFrame.speciesID, slotFrame.petID)
end


function PetJournal_UpdatePetLoadOut()
	PetJournal.SpellSelect:Hide();
	for i=1,MAX_ACTIVE_PETS do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local petID, ability1ID, ability2ID, ability3ID = C_PetJournal.GetPetLoadOutInfo(i);
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID);
		if name then
			if customName then
				loadoutPlate.name:SetText(customName);
				loadoutPlate.name:SetHeight(12);
				loadoutPlate.subName:Show();
				loadoutPlate.subName:SetText(name);
			else
				loadoutPlate.name:SetText(name);
				loadoutPlate.name:SetHeight(30);
				loadoutPlate.subName:Hide();
			end
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

			loadoutPlate.xpBar:SetMinMaxValues(0, maxXp);
			loadoutPlate.xpBar:SetValue(xp);
			loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
			
			PetJournal_UpdatePetAbility(loadoutPlate.spell1, ability1ID, petID, speciesID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell2, ability2ID, petID, speciesID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell3, ability3ID, petID, speciesID);
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
	
	local numPets, numOwned = C_PetJournal.GetNumPets(isWild);
	PetJournal.petCount:SetFormattedText(MAX_BATTLE_PET_TEXT, numOwned);
	
	for i = 1,#petButtons do
		pet = petButtons[i];
		index = offset + i;
		if index <= numPets then
			local petID, speciesID, isOwned, customName, level, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByIndex(index, isWild);
			
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
			pet.icon:SetTexture(icon);
			pet.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
			
			
			--TODO: Add favorite checking. Needs Gameplay
			pet.favorite:Hide();
			
			if isOwned then
				pet.levelBG:Show();
				pet.level:Show();
				pet.level:SetText(level);
				pet.icon:SetDesaturated(0);
				pet.name:SetFontObject("GameFontNormal");
				pet.petTypeIcon:SetDesaturated(0);
				pet.dragButton:Enable();
			else
				pet.levelBG:Hide();
				pet.level:Hide();
				pet.icon:SetDesaturated(1);
				pet.name:SetFontObject("GameFontDisable");
				pet.petTypeIcon:SetDesaturated(1);
				pet.dragButton:Disable();
			end
			pet.petID = petID;
			pet.speciesID = speciesID;
			pet.index = index;
			pet.owned = isOwned;
			pet:Show();
			if pet.showingTooltip then
				GameTooltip:SetItemByID(petID);
			end
			
			--Update Petcard Button
			if PetJournal.pcIndex == index then
				pet.selected = true;
				pet.selectedTexture:Show();
			else
				pet.selected = false;
				pet.selectedTexture:Hide()
			end
		else
			pet:Hide();
		end
	end
	
	local totalHeight = numPets * COMPANION_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
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
	C_PetJournal.PickupPet(self:GetParent().petID, PetJournal.isWild);
	PetJournal.Loadout.Pet1.setButton:Show();
	PetJournal.Loadout.Pet2.setButton:Show();
	PetJournal.Loadout.Pet3.setButton:Show();
	PetJournal_HidePetCard()
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
	PetJournal.SpellSelect:Hide();

	local speciesID, customName, level, name, icon, petType, creatureID, xp, maxXp, displayID, _;		
	if PetJournal.pcPetID then
		speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(PetJournal.pcPetID);
		self.level:SetText(level);
		self.level:Show();
		self.levelBG:Show();
		self.xpBar:Show();
		self.xpBar:SetMinMaxValues(0, maxXp);
		self.xpBar:SetValue(xp);
		self.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
		
		--Stats
		self.statsFrame:Show();
		local health, attack, speed, rarity = C_PetJournal.GetPetStats(PetJournal.pcPetID);
		self.statsFrame.healthValue:SetText(health);
		self.statsFrame.attackValue:SetText(attack);
		self.statsFrame.speedValue:SetText(speed);
		self.statsFrame.rarityValue:SetText(rarity);
	else
		speciesID = PetJournal.pcSpeciesID;
		name, icon, petType, creatureID = C_PetJournal.GetPetInfoBySpeciesID(PetJournal.pcSpeciesID);
		self.level:Hide();
		self.levelBG:Hide();
		self.xpBar:Hide();
		self.statsFrame:Hide();
	end
	
	if customName then
		self.name:SetText(customName);
		self.name:SetHeight(12);
		self.subName:Show();
		self.subName:SetText(name);
	else
		self.name:SetText(name);
		self.name:SetHeight(30);
		self.subName:Hide();
	end
	
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
			spellFrame.abilityID = abilities[i];
			spellFrame.petID = PetJournal.pcPetID;
			spellFrame.speciesID = speciesID;
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


function PetOptionsMenu_Init(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	
	info.text = BATTLE_PET_SUMMON
	info.func = function() C_PetJournal.SummonPetByID(PetJournal.menuPetID); end
	UIDropDownMenu_AddButton(info, level)
	
	info.text = BATTLE_PET_RENAME
	info.func = 	function() StaticPopup_Show("BATTLE_PET_RENAME"); end 
	UIDropDownMenu_AddButton(info, level)
		
	info.text = BATTLE_PET_FAVORITE;--BATTLE_PET_UNFAVORITE
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
	
	info.text = BATTLE_PET_RELEASE;
	info.func = nil
	UIDropDownMenu_AddButton(info, level)

	if(PetJournal.menuPetID and C_PetJournal.PetIsTradable(PetJournal.menuPetID)) then
		info.text = BATTLE_PET_PUT_IN_CAGE;
		info.func =  	function() StaticPopup_Show("BATTLE_PET_PUT_IN_CAGE"); end 
		UIDropDownMenu_AddButton(info, level)
	end
	
	info.text = CANCEL
	UIDropDownMenu_AddButton(info, level)
end

---------------------------------------
-------Ability Tooltip stuff-----------
---------------------------------------

local PET_JOURNAL_ABILITY_INFO = {};

function PET_JOURNAL_ABILITY_INFO:GetAbilityID()
	return self.abilityID;
end

function PET_JOURNAL_ABILITY_INFO:GetCooldown()
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:GetRemainingDuration()
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:IsInBattle()
	return false;
end

function PET_JOURNAL_ABILITY_INFO:GetHealth(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(self.petID);
	else
		--Do something with self.speciesID.
	end
	--TODO: return max health
	return 100;
end

function PET_JOURNAL_ABILITY_INFO:GetMaxHealth(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(self.petID);
	else
		--Do something with self.speciesID.
	end
	--TODO: return max health
	return 100;
end

function PET_JOURNAL_ABILITY_INFO:GetAttackStat(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(self.petID);
	else
		--Do something with self.speciesID.
	end
	--TODO: return attack stat
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:GetSpeedStat(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(self.petID);
	else
		--Do something with self.speciesID.
	end
	--TODO: return speed stat
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:GetState(stateID, target)
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:EnsureTarget(target)
	if ( target == "default" ) then
		target = "self";
	end
	if ( target ~= "self" ) then
		GMError("Only \"self\" unit supported in journal");
	end
end


function PetJournal_ShowAbilityTooltip(self, abilityID, speciesID, petID)
	if ( abilityID and abilityID > 0 ) then
		PET_JOURNAL_ABILITY_INFO.abilityID = abilityID;
		PET_JOURNAL_ABILITY_INFO.speciesID = speciesID;
		PET_JOURNAL_ABILITY_INFO.petID = petID;
		PetJournalPrimaryAbilityTooltip:ClearAllPoints();
		PetJournalPrimaryAbilityTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0);
		PetJournalPrimaryAbilityTooltip.anchoredTo = self;
		SharedPetBattleAbilityTooltip_SetAbility(PetJournalPrimaryAbilityTooltip, PET_JOURNAL_ABILITY_INFO);
		PetJournalPrimaryAbilityTooltip:Show();
	end
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
