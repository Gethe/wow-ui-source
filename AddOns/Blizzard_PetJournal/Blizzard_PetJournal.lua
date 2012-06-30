

local COMPANION_BUTTON_HEIGHT = 46;
local MOUNT_BUTTON_HEIGHT = 46;
local MAX_ACTIVE_PETS = 3;
local NUM_PET_ABILITIES = 6;
PET_ACHIEVEMENT_CATEGORY = 15117;
local MAX_PET_LEVEL = 25;
local PLAYER_MOUNT_LEVEL = 20;
local HEAL_PET_SPELL = 125439;
local UNLOCK_REQUIREMENTS = {
	[1] = {requirement = "SPELL", id = "119467"},
	[2] = {requirement = "ACHIEVEMENT", id = "7433"},
	[3] = {requirement = "ACHIEVEMENT", id = "6566"}
};

StaticPopupDialogs["BATTLE_PET_RENAME"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 16,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		C_PetJournal.SetCustomName(self.data, text);
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
		C_PetJournal.CagePetByID(self.data);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BATTLE_PET_RELEASE"] = {
	text = PET_RELEASE_LABEL,
	button1 = OKAY,
	button2 = CANCEL,
	maxLetters = 30,
	OnAccept = function(self)
		C_PetJournal.ReleasePetByID(self.data);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

function PetJournalUtil_GetDisplayName(petID)
	local speciesID, customName, level, xp, maxXp, displayID, petName, petIcon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID);
	if ( customName ) then
		return customName;
	else
		return petName;
	end
end

function PetJournalParent_SetTab(self, tab)
	PanelTemplates_SetTab(self, tab);
	PetJournalParent_UpdateSelectedTab(self);
end

function PetJournalParent_UpdateSelectedTab(self)
	local selected = PanelTemplates_GetSelectedTab(self);
	if ( selected == 1 ) then
		MountJournal:Show();
		PetJournal:Hide();
	else
		MountJournal:Hide();
		PetJournal:Show();
	end
end

function PetJournalParent_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	PetJournalParent_UpdateSelectedTab(self);
	UpdateMicroButtons();
end

function PetJournalParent_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
end

function PetJournal_OnLoad(self)
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
	self:RegisterEvent("PET_JOURNAL_PET_DELETED");
	self:RegisterEvent("PET_JOURNAL_PETS_HEALED");
	self:RegisterEvent("BATTLE_PET_CURSOR_CLEAR");
	self:RegisterEvent("COMPANION_UPDATE");
	
	
	self.listScroll.update = PetJournal_UpdatePetList;
	self.listScroll.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.listScroll, "CompanionListButtonTemplate", 44, 0);
	
	--PanelTemplates_DeselectTab(PetJournalTab2);
	PetJournal.isWild = false;
	UIDropDownMenu_Initialize(self.petOptionsMenu, PetOptionsMenu_Init, "MENU");
end


function PetJournal_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	PetJournal_UpdatePetList();
	PetJournal_UpdatePetLoadOut();
	
	PetJournal.AchievementStatus.SumText:SetText(GetCategoryAchievementPoints(PET_ACHIEVEMENT_CATEGORY, true));
	
	-- check to show the help plate
	if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL) ) then
		local helpPlate = PetJournal_HelpPlate;
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
			HelpPlate_Show( helpPlate, PetJournal, PetJournal.MainHelpButton );
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true );
		end
	end

	CompanionsMicroButtonAlert:Hide();
	MicroButtonPulseStop(CompanionsMicroButton);
	SetPortraitToTexture(PetJournalParentPortrait,"Interface\\Icons\\PetJournalPortrait");
end


function PetJournal_OnHide(self)
	PlaySound("igCharacterInfoClose");
	PetJournal.SpellSelect:Hide();
	HelpPlate_Hide();
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
	elseif event == "PET_JOURNAL_PETS_HEALED" then
		PetJournal_UpdatePetLoadOut();
	elseif event == "PET_JOURNAL_LIST_UPDATE" then
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetList();
		PetJournal_UpdatePetLoadOut();
		PetJournal_UpdatePetCard(PetJournal.PetCardList.MainCard);
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
	end
end

function PetJournal_UpdateSummonButtonState()
	if ( PetJournal.pcPetID and C_PetJournal.PetIsSummonable(PetJournal.pcPetID)) then
		PetJournal.SummonButton:Enable();
	else
		PetJournal.SummonButton:Disable();
	end

	if ( PetJournal.pcPetID and PetJournal.pcPetID == C_PetJournal.GetSummonedPetID() ) then
		PetJournal.SummonButton:SetText(PET_DISMISS);
	else
		PetJournal.SummonButton:SetText(BATTLE_PET_SUMMON);
	end
	
	if (GameTooltip:GetOwner() == PetJournal.SummonButton) then
		PetJournalSummonButton_OnEnter(PetJournal.SummonButton);
	end
end

function PetJournalHealPetButton_OnLoad(self)
	self.spellID = HEAL_PET_SPELL;
	local spellName, spellSubname, spellIcon = GetSpellInfo(self.spellID);
	self.texture:SetTexture(spellIcon);
	self.spellname:SetText(spellName);
end

function PetJournalHealPetButton_OnShow(self)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELLS_CHANGED");
	PetJournalHealPetButton_UpdateUsability(self);
end

function PetJournalHealPetButton_OnHide(self)
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	if (self:IsEventRegistered("SPELLS_CHANGED")) then
		self:UnregisterEvent("SPELLS_CHANGED");
	end
end

function PetJournalHealPetButton_OnDragStart(self)
	PickupSpell(self.spellID);
end

function PetJournalHealPetButton_UpdateUsability(self)
	if (IsSpellKnown(self.spellID)) then
		self.texture:SetDesaturated(0);
		self.BlackCover:Hide();
		self:UnregisterEvent("SPELLS_CHANGED");
		self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		self:RegisterForDrag("LeftButton");
	else
		self.BlackCover:Show();
		self.texture:SetDesaturated(1);
	end
end

function PetJournalHealPetButton_OnEvent(self, event, ...)
	if ( event == "SPELL_UPDATE_COOLDOWN" ) then
		PetJournalHealPetButton_UpdateCooldown(self);
		-- Update tooltip
		if ( GameTooltip:GetOwner() == self ) then
			PetJournalHealPetButton_OnEnter(self);
		end
	elseif ( event == "SPELLS_CHANGED" ) then
		PetJournalHealPetButton_UpdateUsability(self);
	end
end

function PetJournalHealPetButton_UpdateCooldown(self)
	local cooldown = _G[self:GetName().."Cooldown"];
	local start, duration, enable = GetSpellCooldown(self.spellID);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
end

function PetJournalHealPetButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID);
	if (not IsSpellKnown(self.spellID)) then
		GameTooltip:AddLine(PET_BATTLE_HEAL_SPELL_UNKNOWN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1);
		GameTooltip:Show();
	end
	self.UpdateTooltip = PetJournalHealPetButton_OnEnter;
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
	local speciesID, customName, level, xp, maxXp, displayID, petName, petIcon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID);

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
	local speciesID, customName, level, xp, maxXp, displayID, petName, petIcon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(slotFrame.petID);
	
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
	local name, icon, petType, requiredLevel;
	if (abilities[spellIndex1]) then
		name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex1]);
		requiredLevel = PetJournalLoadout_GetRequiredLevel(slotFrame, abilities[spellIndex1]);
		PetJournal.SpellSelect.Spell1:SetEnabled(requiredLevel <= level);
	else
		name = "";
		icon = "";
		petType = "";
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
		name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex2]);
		requiredLevel = PetJournalLoadout_GetRequiredLevel(slotFrame, abilities[spellIndex2]);
		PetJournal.SpellSelect.Spell2:SetEnabled(requiredLevel <= level);
	else
		name = "";
		icon = "";
		petType = "";
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


function PetJournal_UpdatePetLoadOut()
	PetJournal.SpellSelect:Hide();
	for i=1,MAX_ACTIVE_PETS do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i);
		if (locked) then
			loadoutPlate.name:Hide();
			loadoutPlate.subName:Hide();
			loadoutPlate.level:Hide();
			loadoutPlate.icon:Hide();
			loadoutPlate.model:Hide();			
			loadoutPlate.xpBar:Hide();
			loadoutPlate.healthBar:Hide();
			loadoutPlate.spell1:Hide();
			loadoutPlate.spell2:Hide();
			loadoutPlate.spell3:Hide();
			loadoutPlate.shadows:Hide();
			loadoutPlate.iconBorder:Hide();
			loadoutPlate.abilitiesLabel:Hide();
			loadoutPlate.emptyslot:Hide();
			loadoutPlate.isDead:Hide();
			-- helpFrame & requirementButton are active when the slot is locked
			loadoutPlate.requirementButton:SetShown(UNLOCK_REQUIREMENTS[i].id);
			if (UNLOCK_REQUIREMENTS[i].requirement == "ACHIEVEMENT" and UNLOCK_REQUIREMENTS[i].id) then
				loadoutPlate.requirementButton:SetText(GetAchievementLink(UNLOCK_REQUIREMENTS[i].id));
				loadoutPlate.requirementButton.achievementID = UNLOCK_REQUIREMENTS[i].id;
			elseif (UNLOCK_REQUIREMENTS[i].requirement == "SPELL" and UNLOCK_REQUIREMENTS[i].id) then
				loadoutPlate.requirementButton:SetText(GetSpellLink(UNLOCK_REQUIREMENTS[i].id));
				loadoutPlate.requirementButton.spellID = UNLOCK_REQUIREMENTS[i].id;
			end
			loadoutPlate.helpFrame.slotinfo:SetText(format(BATTLE_PET_SLOT, i));
			loadoutPlate.helpFrame.text:SetText(_G["BATTLE_PET_UNLOCK_HELP_"..i]);
			loadoutPlate.helpFrame:Show();
		elseif (petID <= 0) then
			loadoutPlate.name:Hide();
			loadoutPlate.subName:Hide();
			loadoutPlate.level:Hide();
			loadoutPlate.icon:Hide();
			loadoutPlate.model:Hide();			
			loadoutPlate.xpBar:Hide();
			loadoutPlate.healthBar:Hide();
			loadoutPlate.spell1:Hide();
			loadoutPlate.spell2:Hide();
			loadoutPlate.spell3:Hide();
			loadoutPlate.shadows:Hide();
			loadoutPlate.iconBorder:Hide();
			loadoutPlate.abilitiesLabel:Hide();
			loadoutPlate.helpFrame:Hide();
			loadoutPlate.requirementButton:Hide();
			loadoutPlate.emptyslot:Show();
			loadoutPlate.emptyslot.slot:SetText(format(BATTLE_PET_SLOT, i));
			loadoutPlate.isDead:Hide();
		else -- not locked and petID > 0
			local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID);
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
			loadoutPlate.icon:Show();
			loadoutPlate.shadows:Show();
			loadoutPlate.iconBorder:Show();
			loadoutPlate.abilitiesLabel:Show();
			loadoutPlate.spell1:Show();
			loadoutPlate.spell2:Show();
			loadoutPlate.spell3:Show();

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
			if ( displayID ~= 0 ) then
				if ( displayID ~= loadoutPlate.displayID ) then
					loadoutPlate.creatureID = nil;
					loadoutPlate.displayID = displayID;
					loadoutPlate.model:SetDisplayInfo(displayID);
				end
			elseif ( creatureID ~= 0 ) then
				if ( creatureID ~= loadoutPlate.creatureID ) then
					loadoutPlate.creatureID = creatureID;
					loadoutPlate.displayID = nil;
					loadoutPlate.model:SetCreature(creatureID);
				end
			end
				
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
			loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
			
			local health, maxHealth, _ = C_PetJournal.GetPetStats(petID);
			loadoutPlate.healthBar:SetMinMaxValues(0, maxHealth);
			loadoutPlate.healthBar:SetValue(health);
			loadoutPlate.healthBar.healthRankText:SetFormattedText(PET_BATTLE_CURRENT_HEALTH_FORMAT_VERBOSE, health, maxHealth);
			loadoutPlate.healthBar:Show();
			if (health <= 0) then
				loadoutPlate.isDead:Show();
				loadoutPlate.model:SetAnimation(6,0);
			else
				loadoutPlate.isDead:Hide();
				loadoutPlate.model:SetAnimation(0,0);
			end
			
			PetJournal_UpdatePetAbility(loadoutPlate.spell1, ability1ID, petID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell2, ability2ID, petID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell3, ability3ID, petID);

			--[[Only show flyouts if the person already has the first 3 abilities.
			if ( numUsableAbilities < 3 ) then
				loadoutPlate.spell1.enabled = false;
				loadoutPlate.spell2.enabled = false;
				loadoutPlate.spell3.enabled = false;
				loadoutPlate.spell1:GetHighlightTexture():SetAlpha(0);
				loadoutPlate.spell2:GetHighlightTexture():SetAlpha(0);
				loadoutPlate.spell3:GetHighlightTexture():SetAlpha(0);
				loadoutPlate.spell1:GetPushedTexture():SetAlpha(0);
				loadoutPlate.spell2:GetPushedTexture():SetAlpha(0);
				loadoutPlate.spell3:GetPushedTexture():SetAlpha(0);
				loadoutPlate.spell1.FlyoutArrow:Hide();
				loadoutPlate.spell2.FlyoutArrow:Hide();
				loadoutPlate.spell3.FlyoutArrow:Hide();
			else]]
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
			loadoutPlate.requirementButton:Hide();
			loadoutPlate.emptyslot:Hide();
		end
	end -- for i=1,MAX_ACTIVE_PETS do
	
	PetJournal.Loadout.Pet1.setButton:Hide();
	PetJournal.Loadout.Pet2.setButton:Hide();
	PetJournal.Loadout.Pet3.setButton:Hide();
end


function PetJournalRequirementButton_ShowRequirementToolTip(self)
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
	PetJournal_UpdatePetCard(PetJournal.PetCardList.MainCard);
end

function PetJournal_UpdatePetList()
	local scrollFrame = PetJournal.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local petButtons = scrollFrame.buttons;
	local pet, index;
	
	local isWild = PetJournal.isWild;
	
	local numPets, numOwned = C_PetJournal.GetNumPets(isWild);
	PetJournal.PetCount.Count:SetText(numOwned);
	
	local summonedPetID = C_PetJournal.GetSummonedPetID();

	for i = 1,#petButtons do
		pet = petButtons[i];
		index = offset + i;
		if index <= numPets then
			local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, creatureID, sourceText, description, isWildPet = C_PetJournal.GetPetInfoByIndex(index, isWild);

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
			
			if (favorite) then
				pet.favorite:Show();
			else
				pet.favorite:Hide();
			end
			
			if isOwned then
				local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);
				pet.levelBG:Show();
				pet.level:Show();
				pet.level:SetText(level);
				pet.icon:SetDesaturated(0);
				pet.name:SetFontObject("GameFontNormal");
				pet.petTypeIcon:SetDesaturated(0);
				pet.dragButton:Enable();
				if (isWildPet) then
					pet.iconBorder:Show();
					pet.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);
				else
					pet.iconBorder:Hide();
				end
				if (health <= 0) then
					pet.isDead:Show();
				else
					pet.isDead:Hide();
				end
				if(isRevoked == true) then
					pet.levelBG:Hide();
					pet.level:Hide();
					pet.icon:SetDesaturated(1);
					pet.petTypeIcon:SetDesaturated(1);
					pet.dragButton:Disable();
				end
			else
				pet.levelBG:Hide();
				pet.level:Hide();
				pet.icon:SetDesaturated(1);
				pet.name:SetFontObject("GameFontDisable");
				pet.petTypeIcon:SetDesaturated(1);
				pet.dragButton:Disable();
				pet.isDead:Hide();
			end

			if ( petID and petID == summonedPetID ) then
				pet.dragButton.ActiveTexture:Show();
			else
				pet.dragButton.ActiveTexture:Hide();
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


function PetJournalDragButton_OnClick(self, button)
	if ( button == "RightButton" ) then
		local parent = self:GetParent();
		if ( parent.owned ) then
			PetJournal_ShowPetDropdown(parent.index, self, 0, 0);
		end
	else
		local type, petID = GetCursorInfo();
		if type == "battlepet" then
			PetJournal_UpdatePetLoadOut();
			ClearCursor();
		else
			PetJournalDragButton_OnDragStart(self);
		end
	end
end

function PetJournalDragButton_OnDragStart(self)
	if (not self:GetParent().petID or self:GetParent().petID == 0) then
		return;
	end
	
	C_PetJournal.PickupPet(self:GetParent().petID, PetJournal.isWild);

	for i=1,MAX_ACTIVE_PETS do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i);
		if(locked) then
			PetJournal.Loadout["Pet"..i].setButton:Hide();
		else
			PetJournal.Loadout["Pet"..i].setButton:Show();
		end
	end
end

function PetJournal_ShowPetDropdown(index, anchorTo, offsetX, offsetY)
	PetJournal.menuPetIndex = index;
	PetJournal.menuPetID = C_PetJournal.GetPetInfoByIndex(index);
	ToggleDropDownMenu(1, nil, PetJournal.petOptionsMenu, anchorTo, offsetX, offsetY);
end


function PetJournal_TogglePetCardByID(petID)
	PetJournal.pcPetID = petID;
	PetJournal.pcSpeciesID = C_PetJournal.GetPetInfoByPetID(petID);
	
	PetJournal_FindPetCardIndex();
	PetJournal_UpdatePetCard(PetJournal.PetCardList.MainCard);
	PetJournal.PetCardList:Show();
	PetJournal_UpdatePetList();
	PetJournal_UpdateSummonButtonState();
end


function PetJournal_TogglePetCard(index)
	PlaySound("igAbiliityPageTurn");
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
		PetJournal_UpdateSummonButtonState();
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
	PetJournal_UpdateSummonButtonState();
end


function PetJournal_UpdatePetCard(self)
	PetJournal.SpellSelect:Hide();
	
	if (not PetJournal.pcPetID and not PetJournal.pcSpeciesID) then
		return;
	end

	local isDead = false;
	local speciesID, customName, level, name, icon, petType, creatureID, xp, maxXp, displayID, sourceText, description, isWild, _;
	if PetJournal.pcPetID then
		speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID, sourceText, description, isWild = C_PetJournal.GetPetInfoByPetID(PetJournal.pcPetID);
		if ( not speciesID ) then
			--We no longer have this pet. (We may have just released it.)
			PetJournal_HidePetCard();
			return;
		end
		self.level:SetText(level);
		self.level:Show();
		self.levelBG:Show();
		self.xpBar:Show();
		self.xpBar:SetMinMaxValues(0, maxXp);
		self.xpBar:SetValue(xp);
		self.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
		
		--Stats
		local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(PetJournal.pcPetID);
		self.statsFrame:Show();
		self.powerFrame:Show();
		self.speedFrame:Show();

		self.healthBar:Show();
		self.healthBar:SetMinMaxValues(0, maxHealth);
		self.healthBar:SetValue(health);
		self.healthBar.healthRankText:SetFormattedText(PET_BATTLE_CURRENT_HEALTH_FORMAT_VERBOSE, health, maxHealth);
		if (health <= 0) then
			isDead = true;
			self.isDead:Show();
		else
			isDead = false;
			self.isDead:Hide();
		end
		
		self.powerFrame.attackValue:SetText(attack);
		self.speedFrame.speedValue:SetText(speed);
		if ( isWild ) then
			self.rarityFrame.rarityValue:SetText(_G["BATTLE_PET_BREED_QUALITY"..rarity]);
			local color = ITEM_QUALITY_COLORS[rarity-1];
			self.rarityFrame.rarityValue:SetVertexColor(color.r, color.g, color.b);
			self.rarityFrame:Show();
		else
			self.rarityFrame:Hide();
		end
	else
		speciesID = PetJournal.pcSpeciesID;
		name, icon, petType, creatureID, sourceText, description, isWild = C_PetJournal.GetPetInfoBySpeciesID(PetJournal.pcSpeciesID);
		level = 1;
		self.level:Hide();
		self.healthBar:Hide();
		self.levelBG:Hide();
		self.xpBar:Hide();
		self.statsFrame:Hide();
		self.powerFrame:Hide();
		self.speedFrame:Hide();
		self.rarityFrame:Hide();
	end

	self.PetTypeFrame.Label:SetText(_G["BATTLE_PET_NAME_"..petType]);
	self.PetTypeFrame.Icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType]);
	self.PetTypeFrame.abilityID = PET_BATTLE_PET_TYPE_PASSIVES[petType];
	self.PetTypeFrame.petID = PetJournal.pcPetID;
	self.PetTypeFrame.speciesID = speciesID;
	
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

	self.Location.sourceText = sourceText;
	if ( description ~= "" ) then
		self.Location.description = format([["%s"]], description);
	else
		self.Location.description = nil;
	end
	self.Location.speciesName = name;
	
	self.model:Show();
	if ( displayID and displayID ~= 0 ) then
		if ( displayID ~= self.displayID ) then
			self.creatureID = nil;
			self.displayID = displayID;
			self.model:SetDisplayInfo(displayID);
		end
	elseif ( creatureID ~= 0 ) then
		if ( creatureID ~= self.creatureID ) then
			self.creatureID = creatureID;
			self.displayID = nil;
			self.model:SetCreature(creatureID);
		end
	end
	if (isDead) then
		self.model:SetAnimation(6,0);
	else
		self.model:SetAnimation(0,0);
	end
		
	self.petTypeIcon:SetTexture(GetPetTypeTexture(petType) );
	
	--Update pet abilites
	local abilities, levels = C_PetJournal.GetPetAbilityList(speciesID);
	for i=1,NUM_PET_ABILITIES do
		local spellFrame = self["spell"..i];
		if abilities[i] then
			local name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[i]);
			local isNotUsable = not level or level < levels[i];
			spellFrame.name:SetText(name);
			spellFrame.icon:SetTexture(icon);
			spellFrame.icon:SetDesaturated(isNotUsable);
			spellFrame.petTypeIcon:SetTexture(GetPetTypeTexture(petType) );
			spellFrame.LevelRequirement:SetText(levels[i]);
			spellFrame.LevelRequirement:SetShown(isNotUsable);
			spellFrame.BlackCover:SetShown(isNotUsable);
			if (not level or level < levels[i]) then
				spellFrame.additionalText = format(PET_ABILITY_REQUIRES_LEVEL, levels[i]);
			end
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
							if (value) then
								UIDropDownMenu_EnableButton(1, 2);
							else
								UIDropDownMenu_DisableButton(1,2 );
							end;
						end 
		info.keepShownOnClick = true;
		info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		
		info.text = FAVORITES_FILTER
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_FAVORITES, value);
						end 
		info.disabled = not info.checked or info.checked ~= true;
		info.keepShownOnClick = true;
		info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_FAVORITES);
		info.isNotRadio = true;
		info.leftPadding = 16;
		UIDropDownMenu_AddButton(info, level)
		info.leftPadding = 0;
		info.disabled = nil;

		info.text = NOT_COLLECTED
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, value);
						end 
		info.keepShownOnClick = true;
		info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_NOT_COLLECTED);
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
							UIDropDownMenu_Refresh(PetJournalFilterDropDown, 1, 2);
						end
			UIDropDownMenu_AddButton(info, level)
			
			info.text = UNCHECK_ALL
			info.func = function()
							C_PetJournal.ClearAllPetTypesFilter();
							UIDropDownMenu_Refresh(PetJournalFilterDropDown, 1, 2);
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
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;
			info.keepShownOnClick = true;
				
		
			info.text = CHECK_ALL
			info.func = function()
							C_PetJournal.AddAllPetSourcesFilter();
							UIDropDownMenu_Refresh(PetJournalFilterDropDown, 2, 2);
						end
			UIDropDownMenu_AddButton(info, level)
			
			info.text = UNCHECK_ALL
			info.func = function()
							C_PetJournal.ClearAllPetSourcesFilter();
							UIDropDownMenu_Refresh(PetJournalFilterDropDown, 2, 2);
						end
			UIDropDownMenu_AddButton(info, level)
		
			info.notCheckable = false;
			local numSources = C_PetJournal.GetNumPetSources();
			for i=1,numSources do
				info.text = _G["BATTLE_PET_SOURCE_"..i];
				info.func = function(_, _, _, value)
							C_PetJournal.SetPetSourceFilter(i, value);
						end
				info.checked = function() return not C_PetJournal.IsPetSourceFiltered(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end


function PetOptionsMenu_Init(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	
	info.text = BATTLE_PET_SUMMON
	info.func = function() C_PetJournal.SummonPetByID(PetJournal.menuPetID); end
	if (PetJournal.menuPetID and not C_PetJournal.PetIsSummonable(PetJournal.menuPetID)) then
		info.disabled = true;
	end
	UIDropDownMenu_AddButton(info, level)
	info.disabled = nil;
	
	info.text = BATTLE_PET_RENAME
	info.func = 	function() StaticPopup_Show("BATTLE_PET_RENAME", nil, nil, PetJournal.menuPetID); end 
	UIDropDownMenu_AddButton(info, level)

	if (PetJournal.menuPetID and C_PetJournal.PetIsFavorite(PetJournal.menuPetID)) then
		info.text = BATTLE_PET_UNFAVORITE;
		info.func = function() 
			C_PetJournal.SetFavorite(PetJournal.menuPetID, 0); 
		end
		UIDropDownMenu_AddButton(info, level)
	else
		info.text = BATTLE_PET_FAVORITE;
		info.func = function() 
			C_PetJournal.SetFavorite(PetJournal.menuPetID, 1); 
		end
		UIDropDownMenu_AddButton(info, level)
	end
	
	if(PetJournal.menuPetID and C_PetJournal.PetIsTradable(PetJournal.menuPetID)) then
		info.text = BATTLE_PET_RELEASE;
		info.func = function() StaticPopup_Show("BATTLE_PET_RELEASE", PetJournalUtil_GetDisplayName(PetJournal.menuPetID), nil, PetJournal.menuPetID); end
		UIDropDownMenu_AddButton(info, level)
	
		info.text = BATTLE_PET_PUT_IN_CAGE;
		info.func = function() StaticPopup_Show("BATTLE_PET_PUT_IN_CAGE", nil, nil, PetJournal.menuPetID); end 
		if (not C_PetJournal.PetIsCagable(PetJournal.menuPetID)) then
			info.disabled = true;
		end
		UIDropDownMenu_AddButton(info, level)
		info.disabled = nil;
	end
	
	info.text = CANCEL
	info.func = nil
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

function PET_JOURNAL_ABILITY_INFO:GetState(stateID, target)
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:EnsureTarget(target)
	if ( target == "default" ) then
		target = "self";
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
		PetJournalPrimaryAbilityTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0);
		PetJournalPrimaryAbilityTooltip.anchoredTo = self;
		SharedPetBattleAbilityTooltip_SetAbility(PetJournalPrimaryAbilityTooltip, journalAbilityInfo, additionalText);
		PetJournalPrimaryAbilityTooltip:Show();
	end
end

function PetJournal_GetPetAbilityHyperlink(abilityID, petID)
	local maxHealth, power, speed, _;
	if ( petID and petID > 0 ) then
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
	GameTooltip:SetMinimumWidth(150);
	GameTooltip:SetText(BATTLE_PETS_TOTAL_PETS, 1, 1, 1);
	GameTooltip:AddLine(BATTLE_PETS_TOTAL_PETS_TOOLTIP, nil, nil, nil, true);
	GameTooltip:Show();
end

function PetJournalFindBattle_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetMinimumWidth(150);
	GameTooltip:SetText(FIND_BATTLE, 1, 1, 1);
	GameTooltip:AddLine(BATTLE_PETS_FIND_BATTLE_TOOLTIP, nil, nil, nil, true);
	GameTooltip:Show();
end

function PetJournalAchievementStatus_OnEnter(self)
	PetJournal.AchievementStatus.highlight:Show();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetMinimumWidth(150);
	GameTooltip:SetText(BATTLE_PETS_ACHIEVEMENT, 1, 1, 1);
	GameTooltip:AddLine(BATTLE_PETS_ACHIEVEMENT_TOOLTIP, nil, nil, nil, true);
	GameTooltip:Show();
end

function PetJournalSummonButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetMinimumWidth(150);
	GameTooltip:SetText(self:GetText(), 1, 1, 1);
	GameTooltip:AddLine(BATTLE_PETS_SUMMON_TOOLTIP, nil, nil, nil, true);
	GameTooltip:Show();
end

---------------------------------------
-------Help plate stuff-----------
---------------------------------------

PetJournal_HelpPlate = {
	FramePos = { x = 0,	y = -22 },
	FrameSize = { width = 700, height = 580	},
	[1] = { ButtonPos = { x = 26,	y = -75 },	HighLightBox = { x = 10, y = -75, width = 247, height = 50 },	ToolTipDir = "RIGHT",	ToolTipText = PET_JOURNAL_HELP_1 },
	[2] = { ButtonPos = { x = 105,	y = -300 },	HighLightBox = { x = 10, y = -128, width = 247, height = 425 },	ToolTipDir = "DOWN",	ToolTipText = PET_JOURNAL_HELP_2 },
	[3] = { ButtonPos = { x = 470,	y = -95 },	HighLightBox = { x = 290, y = -45, width = 400, height = 508 },	ToolTipDir = "DOWN",	ToolTipText = PET_JOURNAL_HELP_3 },
	[4] = { ButtonPos = { x = 525,	y = -546},	HighLightBox = { x = 550, y = -556, width = 150, height = 26 },	ToolTipDir = "UP",		ToolTipText = PET_JOURNAL_HELP_4 },
}

function PetJournal_ToggleTutorial()
	local helpPlate = PetJournal_HelpPlate;
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, PetJournal, PetJournal.MainHelpButton, true );
		SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true );
	else
		HelpPlate_Hide(true);
	end
end

---------------------------------
---------Mount Journal-----------
---------------------------------
function MountJournal_OnLoad(self)
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self.ListScrollFrame.update = MountJournal_UpdateMountList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "MountListButtonTemplate", 44, 0);
end

function MountJournal_OnEvent(self, event, ...)
	if ( event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" or event == "COMPANION_UPDATE" ) then
		MountJournal_UpdateMountList();
		MountJournal_UpdateMountDisplay();
	end
end

function MountJournal_OnShow(self)
	if ( not MountJournal_FindSelectedIndex() ) then
		MountJournal_Select(1);
	end
	MountJournal_UpdateMountList();
	SetPortraitToTexture(PetJournalParentPortrait,"Interface\\Icons\\MountJournalPortrait");
end

function MountJournal_UpdateMountList()
	local scrollFrame = MountJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numMounts = GetNumCompanions("MOUNT");

	local showMounts = 1;
	local playerLevel = UnitLevel("player");
	if  ( numMounts < 1 ) then
		-- display the no mounts message on the right hand side
		MountJournal.MountDisplay.NoMounts:Show();
		showMounts = 0;
	else
		MountJournal.MountDisplay.NoMounts:Hide();
	end

	for i=1, #buttons do
		local button = buttons[i];
		local index = i + offset;
		if ( index <= numMounts and showMounts == 1) then
			local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", index);
			button.name:SetText(creatureName);
			button.icon:SetTexture(icon);
			button.index = index;
			button.spellID = spellID;

			button.active = active;
			if ( active and playerLevel >= PLAYER_MOUNT_LEVEL) then
				button.DragButton.ActiveTexture:Show();
			else
				button.DragButton.ActiveTexture:Hide();
			end
			button:Show();
			
			if ( button.showingTooltip ) then
				GameTooltip:SetSpellByID(spellID);
			end

			if ( MountJournal.selectedSpellID == spellID ) then
				button.selected = true;
				button.selectedTexture:Show();
			else
				button.selected = false;
				button.selectedTexture:Hide();
			end
			button:SetEnabled(1);
			if (playerLevel >= PLAYER_MOUNT_LEVEL) then
				button.DragButton:SetEnabled(1);
				button.icon:SetDesaturated(0);
				button.icon:SetAlpha(1.0);
				button.name:SetFontObject("GameFontNormal");				
			else
				button.DragButton:SetEnabled(0);
				button.icon:SetDesaturated(1);
				button.icon:SetAlpha(.5);
				button.name:SetFontObject("GameFontDisable");				
			end
		else
			button.icon:SetTexture("Interface\\PetBattles\\MountJournalEmptyIcon");
			button.index = index;
			button.spellID = 0;
			button.selected = false;
			button.DragButton.ActiveTexture:Hide();
			button.selectedTexture:Hide();
			button:SetEnabled(0);
			button.DragButton:SetEnabled(0);
			button.icon:SetDesaturated(1);
			button.icon:SetAlpha(0.5);
		end
	end

	local totalHeight = numMounts * MOUNT_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
	MountJournal.MountCount.Count:SetText(numMounts);
	if ( showMounts == 0 ) then
		MountJournal.selectedSpellID = 0;
		MountJournal_UpdateMountDisplay();
		MountJournal.MountCount.Count:SetText(0);
	end
	if ( playerLevel >= PLAYER_MOUNT_LEVEL and numMounts > 0) then
		MountJournal.MountButton:SetEnabled(1);
	else
		MountJournal.MountButton:SetEnabled(0);
	end
end

function MountJournal_UpdateMountDisplay()
	local index = MountJournal_FindSelectedIndex();

	if ( index ) then
		local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", index);
		if ( MountJournal.MountDisplay.lastDisplayed ~= spellID ) then
			MountJournal.MountDisplay.Name:SetText(creatureName);
			MountJournal.MountDisplay.ModelFrame:SetCreature(creatureID);
			MountJournal.MountDisplay.lastDisplayed = spellID;
		end

		MountJournal.MountDisplay.Name:Show();
		MountJournal.MountDisplay.ModelFrame:Show();

		if ( active ) then
			MountJournal.MountButton:SetText(BINDING_NAME_DISMOUNT);
		else
			MountJournal.MountButton:SetText(MOUNT);
		end
	else
		MountJournal.MountDisplay.Name:Hide();
		MountJournal.MountDisplay.ModelFrame:Hide();
	end
end

function MountJournal_FindSelectedIndex()
	local selectedSpellID = MountJournal.selectedSpellID;
	if ( selectedSpellID ) then
		for i=1, GetNumCompanions("MOUNT") do
			local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", i);
			if ( spellID == selectedSpellID ) then
				return i;
			end
		end
	end

	return nil;
end

function MountJournal_Select(index)
	local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", index);
	MountJournal.selectedSpellID = spellID;
	MountJournal_UpdateMountList();
	MountJournal_UpdateMountDisplay();
end

function MountJournal_GetSelectedSpellID()
	return MountJournal.selectedSpellID;
end

function MountJournalMountButton_OnClick(self)
	local index = MountJournal_FindSelectedIndex();
	if ( index ) then
		local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", index);
		if ( active ) then
			DismissCompanion("MOUNT");
		else
			CallCompanion("MOUNT", index);
		end
	end
end

function MountListDragButton_OnClick(self, button)
	local parent = self:GetParent();
	if ( button ~= "LeftButton" ) then
		if ( parent.active ) then
			DismissCompanion("MOUNT");
		else
			CallCompanion("MOUNT", parent.index);
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
		PickupCompanion("MOUNT", parent.index);
	end
end
