NUM_BATTLE_PETS_IN_BATTLE = 3;
NUM_BATTLE_PET_ABILITIES = 3;

BATTLE_PET_DISPLAY_ROTATION = 3 * math.pi / 8;

--------------------------------------------
-------------Pet Battle Frame---------------
--------------------------------------------
function PetBattleFrame_OnLoad(self)
	self.BottomFrame.actionButtons = {};

	local flowFrame = self.BottomFrame.FlowFrame;
	FlowContainer_Initialize(flowFrame);
	FlowContainer_SetOrientation(flowFrame, "horizontal");
	FlowContainer_SetHorizontalSpacing(flowFrame, 10);

	for i=1, NUM_BATTLE_PETS_IN_BATTLE do
		PetBattleUnitFrame_SetUnit(self.BottomFrame.PetSelectionFrame["Pet"..i], LE_BATTLE_PET_ALLY, i);
	end

	self:RegisterEvent("PET_BATTLE_TURN_STARTED");
	self:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
	self:RegisterEvent("PET_BATTLE_PET_CHANGED");
	self:RegisterEvent("PET_BATTLE_CLOSE");
end

function PetBattleFrame_OnEvent(self, event, ...)
	if ( event == "PET_BATTLE_TURN_STARTED" ) then
		PetBattleFrameTurnTimer_UpdateValues(self.BottomFrame.TurnTimer);
	elseif ( event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" ) then
		PetBattleFrame_UpdatePetSelectionFrame(self);
	elseif ( event == "PET_BATTLE_PET_CHANGED" ) then
		PetBattleFrame_UpdateAssignedUnitFrames(self);
		PetBattleFrame_UpdateAllActionButtons(self);
	elseif ( event == "PET_BATTLE_CLOSE" ) then
		PetBattleFrame_Remove(self);
	end
end

function PetBattleFrame_Display(self)
	self:Show();
	PetBattleFrame_UpdatePetSelectionFrame(self);
	PetBattleFrame_UpdateAssignedUnitFrames(self);
	PetBattleFrame_UpdateActionBarLayout(self);
	PetBattleFrame_UpdateAllActionButtons(self);
end

function PetBattleFrame_UpdatePetSelectionFrame(self)
	local battleState = C_PetBattles.GetBattleState();
	if ( battleState == LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE ) or ( battleState == LE_PET_BATTLE_STATE_WAITING_FOR_FRONT_PETS ) then
		PetBattlePetSelectionFrame_Show(PetBattleFrame.BottomFrame.PetSelectionFrame);
	else
		PetBattlePetSelectionFrame_Hide(PetBattleFrame.BottomFrame.PetSelectionFrame);
	end	
end

function PetBattleFrame_UpdateAllActionButtons(self)
	for i=1, #self.BottomFrame.actionButtons do
		local button = self.BottomFrame.actionButtons[i];
		PetBattleAbilityButton_UpdateIcons(button);
		PetBattleActionButton_UpdateState(button);
	end
	PetBattleActionButton_UpdateState(self.BottomFrame.SwitchPetButton);
	PetBattleActionButton_UpdateState(self.BottomFrame.CatchButton);
end

function PetBattleFrame_UpdateActionButtonLevel(self, actionButton)
	actionButton:SetFrameLevel(self.BottomFrame.FlowFrame:GetFrameLevel() + 1);
end

function PetBattleFrame_UpdateActionBarLayout(self)
	local flowFrame = self.BottomFrame.FlowFrame;
	FlowContainer_RemoveAllObjects(flowFrame);
	FlowContainer_PauseUpdates(flowFrame);

	FlowContainer_SetStartingOffset(flowFrame, 0, -4);

	for i=1, NUM_BATTLE_PET_ABILITIES do
		local actionButton = self.BottomFrame.actionButtons[i];
		if ( not actionButton ) then
			self.BottomFrame.actionButtons[i] = CreateFrame("CheckButton", nil, self.BottomFrame, "PetBattleAbilityButtonTemplate", i);
			actionButton = self.BottomFrame.actionButtons[i];
			PetBattleFrame_UpdateActionButtonLevel(PetBattleFrame, actionButton);
		end

		FlowContainer_AddObject(flowFrame, actionButton);
	end

	FlowContainer_AddObject(flowFrame, self.BottomFrame.SwitchPetButton);
	PetBattleFrame_UpdateActionButtonLevel(PetBattleFrame, self.BottomFrame.SwitchPetButton);

	FlowContainer_AddObject(flowFrame, self.BottomFrame.Delimiter);
	PetBattleFrame_UpdateActionButtonLevel(PetBattleFrame, self.BottomFrame.Delimiter);

	FlowContainer_AddObject(flowFrame, self.BottomFrame.CatchButton);
	PetBattleFrame_UpdateActionButtonLevel(PetBattleFrame, self.BottomFrame.CatchButton);

	FlowContainer_AddObject(flowFrame, self.BottomFrame.ForfeitButton);
	PetBattleFrame_UpdateActionButtonLevel(PetBattleFrame, self.BottomFrame.ForfeitButton);

	FlowContainer_ResumeUpdates(flowFrame);

	local usedX, usedY = FlowContainer_GetUsedBounds(flowFrame);
	flowFrame:SetWidth(usedX);
	self.BottomFrame:SetWidth(usedX + 260);
end

function PetBattleAbilityButton_OnClick(self)
	C_PetBattles.UseAbility(self:GetID());
end

function PetBattleFrame_UpdateAssignedUnitFrames(self)
	local activeAlly = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);

	PetBattleUnitFrame_SetUnit(self.ActiveAlly, LE_BATTLE_PET_ALLY, activeAlly);
	local nextIndex = 2;
	for i=1, NUM_BATTLE_PETS_IN_BATTLE do
		if ( i ~= activeAlly ) then
			PetBattleUnitFrame_SetUnit(self["Ally"..nextIndex], LE_BATTLE_PET_ALLY, i);
			nextIndex = nextIndex + 1;
		end
	end

	local activeEnemy = C_PetBattles.GetActivePet(LE_BATTLE_PET_ENEMY);
	PetBattleUnitFrame_SetUnit(self.ActiveEnemy, LE_BATTLE_PET_ENEMY, activeEnemy);
	nextIndex = 2;
	for i=1, NUM_BATTLE_PETS_IN_BATTLE do
		if ( i ~= activeEnemy ) then
			PetBattleUnitFrame_SetUnit(self["Enemy"..nextIndex], LE_BATTLE_PET_ENEMY, i);
			nextIndex = nextIndex + 1;
		end
	end
end

function PetBattleFrame_Remove(self)
	self:Hide();
	RemoveFrameLock("PETBATTLES");
end

local TIMER_BAR_TEXCOORD_LEFT = 0.56347656;
local TIMER_BAR_TEXCOORD_RIGHT = 0.89453125;
local TIMER_BAR_TEXCOORD_TOP = 0.00195313;
local TIMER_BAR_TEXCOORD_BOTTOM = 0.03515625;
function PetBattleFrameTurnTimer_OnUpdate(self, elapsed)
	if ( C_PetBattles.IsInRoundPlayback() ) then
		self.Bar:SetAlpha(0);
		self.TimerText:SetText("");
	elseif ( self.turnExpires ) then
		local timeRemaining = self.turnExpires - GetTime();

		--Deal with variable lag from the server without looking weird
		if ( timeRemaining <= 0.01 ) then
			timeRemaining = 0.01;
		end

		local timeRatio = 1.0;
		if ( self.turnTime > 0.0 ) then
			timeRatio = timeRemaining / self.turnTime;
		end
		local usableSpace = 337;

		self.Bar:SetWidth(timeRatio * usableSpace);
		self.Bar:SetTexCoord(TIMER_BAR_TEXCOORD_LEFT, TIMER_BAR_TEXCOORD_LEFT + (TIMER_BAR_TEXCOORD_RIGHT - TIMER_BAR_TEXCOORD_LEFT) * timeRatio, TIMER_BAR_TEXCOORD_TOP, TIMER_BAR_TEXCOORD_BOTTOM);

		if ( C_PetBattles.IsWaitingOnOpponent() ) then
			self.Bar:SetAlpha(0.5);
			self.TimerText:SetText(PET_BATTLE_WAITING_FOR_OPPONENT);
		else
			self.Bar:SetAlpha(1);
			if ( self.turnTime > 0.0 ) then
				self.TimerText:SetText(ceil(timeRemaining));
			else
				self.TimerText:SetText("")
			end
		end
	else
		self.Bar:SetAlpha(0);
		if ( C_PetBattles.IsWaitingOnOpponent() ) then
			self.TimerText:SetText(PET_BATTLE_WAITING_FOR_OPPONENT);
		else
			self.TimerText:SetText(PET_BATTLE_SELECT_AN_ACTION);
		end
	end
end

function PetBattleFrameTurnTimer_UpdateValues(self)
	local timeRemaining, turnTime = C_PetBattles.GetTurnTimeInfo(); 
	self.turnExpires = GetTime() + timeRemaining;
	self.turnTime = turnTime;
end

function PetBattleForfeitButton_OnClick(self)
	C_PetBattles.ForfeitGame();
end

function PetBattleCatchButton_OnClick(self)
	C_PetBattles.UseTrap();
end

--------------------------------------------
------Pet Battle Pet Selection Frame--------
--------------------------------------------
function PetBattlePetSelectionFrame_Show(self)
	local numPets = C_PetBattles.GetNumPets(LE_BATTLE_PET_ALLY);
	self:SetWidth((self.Pet1:GetWidth() + 10) * numPets + 30);

	for i=1, numPets do
		PetBattleUnitFrame_UpdateHealthInstant(self["Pet"..i]);
		PetBattleUnitFrame_UpdateDisplay(self["Pet"..i]);
		self["Pet"..i]:Show();
	end
	for i=numPets + 1, NUM_BATTLE_PETS_IN_BATTLE do
		self["Pet"..i]:Hide();
	end
	self:Show();
	PetBattleFrame.BottomFrame.SwitchPetButton:SetChecked(true);
end

function PetBattlePetSelectionFrame_Hide(self)
	self:Hide();
	PetBattleFrame.BottomFrame.SwitchPetButton:SetChecked(false);
end

--------------------------------------------
--------Pet Battle Action Button------------
--------------------------------------------
function PetBattleActionButton_Initialize(self, actionType, actionIndex)
	self.actionType = actionType;
	self.actionIndex = actionIndex;

	self:RegisterEvent("PET_BATTLE_ACTION_SELECTED");
	self:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
	PetBattleActionButton_UpdateState(self);
end

function PetBattleActionButton_OnEvent(self, event, ...)
	if ( event == "PET_BATTLE_ACTION_SELECTED" ) then
		PetBattleActionButton_UpdateState(self);
	elseif ( event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" ) then
		PetBattleActionButton_UpdateState(self);
	end
end

function PetBattleActionButton_UpdateState(self)
	local actionType = self.actionType;
	local actionIndex = self.actionIndex;

	local usable, cooldown, hasSelected, isSelected, isLocked;
	local selectedActionType, selectedActionIndex = C_PetBattles.GetSelectedAction();

	--Decide whether we have a selected action and if it's this button.
	if ( selectedActionType ) then
		hasSelected = true;
		if ( actionType == selectedActionType and (not actionIndex or actionIndex == selectedActionIndex) ) then
			isSelected = true;
		end
	end

	--Set up usable/cooldown/locked for each action type.
	if ( actionType == LE_BATTLE_PET_ACTION_ABILITY ) then
		local name, icon, isUsable, currentCooldown = C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY), actionIndex);
		if ( name ) then
			usable, cooldown = isUsable, currentCooldown;
		else
			isLocked = true;
		end
	elseif ( actionType == LE_BATTLE_PET_ACTION_TRAP ) then
		usable = C_PetBattles.IsTrapAvailable();
	else
		usable = true;
	end

	if ( isLocked ) then
		if ( self.Icon ) then
			self.Icon:SetTexture("INTERFACE\\ICONS\\INV_Misc_Key_05");
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
			self.Icon:SetDesaturated(true);
		end
		self:Disable();
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Hide();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(0.5, 0.5, 0.5);
		end
	elseif ( cooldown and cooldown > 0 ) then
		--Set the frame up to look like a cooldown.
		if ( self.Icon ) then
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
			self.Icon:SetDesaturated(true);
		end
		self:Disable();
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Hide();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Show();
		end
		if ( self.Cooldown ) then
			self.Cooldown:SetText(cooldown);
			self.Cooldown:Show();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(0.5, 0.5, 0.5);
		end
	elseif ( not usable or (hasSelected and not isSelected) ) then
		--Set the frame up to look unusable.
		if ( self.Icon ) then
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
			self.Icon:SetDesaturated(true);
		end
		self:Disable();
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Hide();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(0.5, 0.5, 0.5);
		end
	elseif ( hasSelected and isSelected ) then
		--Set the frame up to look selected.
		if ( self.Icon ) then
			self.Icon:SetVertexColor(1, 1, 1);
			self.Icon:SetDesaturated(false);
		end
		self:Enable();
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Show();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(1, 1, 1);
		end
	else
		--Set the frame up to look clickable/usable.
		if ( self.Icon ) then
			self.Icon:SetVertexColor(1, 1, 1);
			self.Icon:SetDesaturated(false);
		end
		self:Enable();
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Hide();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(1, 1, 1);
		end
	end
end

--------------------------------------------
--------Pet Battle Ability Button-----------
--------------------------------------------
function PetBattleAbilityButton_OnLoad(self)
	PetBattleActionButton_Initialize(self, LE_BATTLE_PET_ACTION_ABILITY, self:GetID());
end

function PetBattleAbilityButton_UpdateIcons(self)
	local activePet = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	local name, icon, usable, currentCooldown = C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, activePet, self:GetID());
	if ( not icon ) then
		icon = "Interface\\Icons\\INV_Misc_QuestionMark";
	end
	if ( not name ) then
		--We don't have an ability here.
		self.Icon:SetTexture("INTERFACE\\ICONS\\INV_Misc_Key_05");
		self.Icon:SetVertexColor(1, 1, 1);
		self:Disable();
		return;
	end
	self.Icon:SetTexture(icon);
end

function PetBattleAbilityButton_OnEnter(self)
	local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	PetBattleAbilityTooltip_SetAbility(LE_BATTLE_PET_ALLY, petIndex, self:GetID());
	PetBattlePrimaryAbilityTooltip:Show();
end

function PetBattleAbilityButton_OnLeave(self)
	PetBattlePrimaryAbilityTooltip:Hide();
end

--------------------------------------------
----------Pet Battle Unit Frame-------------
--------------------------------------------
function PetBattleUnitFrame_OnLoad(self)
	self:RegisterEvent("PET_BATTLE_HEALTH_CHANGED");
	self:RegisterEvent("PET_BATTLE_PET_CHANGED");
end

function PetBattleUnitFrame_OnEvent(self, event, ...)
	if ( event == "PET_BATTLE_HEALTH_CHANGED" ) then
		local petOwner, petIndex = ...;
		if ( petOwner == self.petOwner and petIndex == self.petIndex ) then
			PetBattleUnitFrame_UpdateHealthInstant(self);
		end
	elseif ( event == "PET_BATTLE_PET_CHANGED" ) then
		PetBattleUnitFrame_UpdateDisplay(self);
	end
end

function PetBattleUnitFrame_SetUnit(self, petOwner, petIndex)
	self.petOwner = petOwner;
	self.petIndex = petIndex;
	PetBattleUnitFrame_UpdateDisplay(self);
	PetBattleUnitFrame_UpdateHealthInstant(self);
	if ( petIndex > C_PetBattles.GetNumPets(petOwner) ) then
		self:Hide();
	else
		self:Show();
	end
end

function PetBattleUnitFrame_UpdateDisplay(self)
	local petOwner = self.petOwner;
	local petIndex = self.petIndex;

	if ( not petOwner or not petIndex ) then
		return;
	end

	--Update the pet species icon
	if ( self.Icon ) then
		if ( petOwner == LE_BATTLE_PET_ALLY ) then
			self.Icon:SetTexCoord(1, 0, 0, 1);
		else
			self.Icon:SetTexCoord(0, 1, 0, 1);
		end
		self.Icon:SetTexture(C_PetBattles.GetIcon(petOwner, petIndex));
	end

	--Get name info
	local name, speciesName = C_PetBattles.GetName(petOwner, petIndex);

	--Update the pet's custom name (will be the species name if it hasn't been changed).
	if ( self.Name ) then
		self.Name:SetText(name);
	end

	--Update the pet's species name (will be hidden if the custom name matches).
	if ( self.SpeciesName ) then
		if ( name ~= speciesName ) then
			self.SpeciesName:SetText(speciesName);
			self.SpeciesName:Show();
		else
			self.SpeciesName:Hide();
		end
	end

	--Update the display of the level
	if ( self.Level ) then
		self.Level:SetText(C_PetBattles.GetLevel(petOwner, petIndex));
	end

	--Update the 3D model of the pet
	if ( self.PetModel ) then
		self.PetModel:SetDisplayInfo(C_PetBattles.GetDisplayID(petOwner, petIndex));
		self.PetModel:SetRotation(-BATTLE_PET_DISPLAY_ROTATION);
		self.PetModel:SetDoBlend(false);
		if ( C_PetBattles.GetHealth(petOwner, petIndex) == 0 ) then
			self.PetModel:SetAnimation(6, 0); --Display the dead animation
			--self.PetModel:SetAnimation(0, 0);
		else
			self.PetModel:SetAnimation(0, 0);
		end
	end

	--Updated the indicator that this is the active pet
	if ( self.SelectedTexture ) then
		if ( C_PetBattles:GetActivePet(petOwner) == petIndex ) then
			self.SelectedTexture:Show();
		else
			self.SelectedTexture:Hide();
		end
	end

	--Update the XP bar
	if ( self.XPBar ) then
		local xp, maxXp = C_PetBattles.GetXP(petIndex);
		self.XPBar:SetWidth((xp / maxXp) * self.xpBarWidth);
	end

	--Update the XP text
	if ( self.XPText ) then
		local xp, maxXp = C_PetBattles.GetXP(petIndex);
		self.XPText:SetFormattedText(self.xpTextFormat or PET_BATTLE_CURRENT_XP_FORMAT, xp, maxXp);
	end

	--Update the pet type (e.g. "Flying", "Critter", "Magical", etc.)
	PetBattleUnitFrame_UpdatePetType(self);
end

function PetBattleUnitFrame_UpdateHealthInstant(self)
	local petOwner = self.petOwner;
	local petIndex = self.petIndex;

	local health = C_PetBattles.GetHealth(petOwner, petIndex);
	local maxHealth = C_PetBattles.GetMaxHealth(petOwner, petIndex);

	if ( self.HealthText ) then
		self.HealthText:SetFormattedText(self.healthTextFormat or PET_BATTLE_CURRENT_HEALTH_FORMAT, health, maxHealth);
	end
	if ( self.ActualHealthBar ) then
		if ( health == 0 ) then
			self.ActualHealthBar:Hide();
		else
			self.ActualHealthBar:Show();
		end
		self.ActualHealthBar:SetWidth((health / maxHealth) * self.healthBarWidth);
	end
	if ( self.BorderAlive ) then
		if ( health == 0 ) then
			self.BorderAlive:Hide();
		else
			self.BorderAlive:Show();
		end
	end
	if ( self.BorderDead ) then
		if ( health == 0 ) then
			self.BorderDead:Show();
		else
			self.BorderDead:Hide();
		end
	end
	if ( self.hideWhenDeadList ) then
		for _, object in pairs(self.hideWhenDeadList) do
			if ( health == 0 ) then
				object:Hide();
			else
				object:Show();
			end
		end
	end
	if ( self.showWhenDeadList ) then
		for _, object in pairs(self.showWhenDeadList) do
			if ( health == 0 ) then
				object:Show();
			else
				object:Hide();
			end
		end
	end
end

function PetBattleUnitFrame_UpdatePetType(self)
	if ( self.PetType ) then
		local petType = C_PetBattles.GetPetType(self.petOwner, self.petIndex);

		self.PetType.Icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType]);
	end
end

--------------------------------------------
----------Pet Battle Unit Tooltips----------
--------------------------------------------
function PetBattleUnitTooltip_OnLoad(self)
	self.healthBarWidth = 230;
	self.xpBarWidth = 230;
	self.healthTextFormat = PET_BATTLE_HEALTH_VERBOSE;
	self.xpTextFormat = PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE;
	PetBattleUnitFrame_OnLoad(self);

	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

local MAX_NUM_PET_BATTLE_ATTACK_MODIFIERS = 2;
function PetBattleUnitTooltip_UpdateForUnit(self, petOwner, petIndex)
	PetBattleUnitFrame_SetUnit(self, petOwner, petIndex);

	local height = 193;
	local attack, defense, speed = C_PetBattles.GetPetStats(petOwner, petIndex);
	self.AttackAmount:SetText(attack);
	self.DefenseAmount:SetText(defense);
	self.SpeedAmount:SetText(speed);

	if ( petOwner == LE_BATTLE_PET_ALLY ) then
		--Add the XP bar
		self.XPBar:Show();
		self.XPBG:Show();
		self.XPBorder:Show();
		self.XPText:Show();
		self.Delimiter:SetPoint("TOP", self.XPBG, "BOTTOM", 0, -10);
		height = height + 18;

		--Show and update abilities
		self.AbilitiesLabel:Show();
		for i=1, NUM_BATTLE_PET_ABILITIES do
			local name, texture = C_PetBattles.GetAbilityInfo(petOwner, petIndex, i);
			local abilityIcon = self["AbilityIcon"..i];
			local abilityName = self["AbilityName"..i];
			abilityIcon:SetTexture(texture);
			abilityName:SetText(name);
			abilityIcon:Show();
			abilityName:Show();
		end

		--Hide the weak to/resistant to
		self.WeakToLabel:Hide();
		self.ResistantToLabel:Hide();

		for i=1, MAX_NUM_PET_BATTLE_ATTACK_MODIFIERS do
			self["WeakTo"..i]:Hide();
			self["ResistantTo"..i]:Hide();
		end
	else
		--Remove the XP bar
		self.XPBar:Hide();
		self.XPBG:Hide();
		self.XPBorder:Hide();
		self.XPText:Hide();
		self.Delimiter:SetPoint("TOP", self.HealthBG, "BOTTOM", 0, -10);

		--Hide abilities
		self.AbilitiesLabel:Hide();
		for i=1, NUM_BATTLE_PET_ABILITIES do
			self["AbilityIcon"..i]:Hide();
			self["AbilityName"..i]:Hide();
		end

		--Show and update weak to/resistant against
		self.WeakToLabel:Show();
		self.ResistantToLabel:Show();
		
		local nextWeakIndex, nextResistIndex = 1, 1;
		local currentPetType = C_PetBattles.GetPetType(petOwner, petIndex);
		for i=1, C_PetBattles.GetNumPetTypes() do
			local modifier = C_PetBattles.GetAttackModifier(i, currentPetType);
			if ( modifier > 1 ) then
				local icon = self["WeakTo"..nextWeakIndex];
				icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[i]);
				icon:Show();
				nextWeakIndex = nextWeakIndex + 1;
			elseif ( modifier < 1 ) then
				local icon = self["ResistantTo"..nextResistIndex];
				icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[i]);
				icon:Show();
				nextResistIndex = nextResistIndex + 1;
			end
		end

		for i=nextWeakIndex, MAX_NUM_PET_BATTLE_ATTACK_MODIFIERS do
			self["WeakTo"..i]:Hide();
		end
		for i=nextResistIndex, MAX_NUM_PET_BATTLE_ATTACK_MODIFIERS do
			self["ResistantTo"..i]:Hide();
		end

		height = height + 5;
	end

	self:SetHeight(height);
end

function PetBattleUnitTooltip_Attach(self, point, frame, relativePoint, xOffset, yOffset)
	self:SetParent(frame);
	self:ClearAllPoints();
	self:SetPoint(point, frame, relativePoint, xOffset, yOffset);
end

--------------------------------------------
---------Pet Battle Ability Tooltip---------
--------------------------------------------
PET_BATTLE_ABILITY_INFO = {};
function PET_BATTLE_ABILITY_INFO:GetName()
	local name, icon, usable, currentCooldown, maxCooldown = C_PetBattles.GetAbilityInfo(self.petOwner, self.petIndex, self.abilityIndex);
	return name;
end

function PET_BATTLE_ABILITY_INFO:GetMaxCooldown()
	local name, icon, usable, currentCooldown, maxCooldown = C_PetBattles.GetAbilityInfo(self.petOwner, self.petIndex, self.abilityIndex);
	return maxCooldown;
end

function PET_BATTLE_ABILITY_INFO:GetDescription()
	local name, icon, usable, currentCooldown, maxCooldown, description = C_PetBattles.GetAbilityInfo(self.petOwner, self.petIndex, self.abilityIndex);
	return description;
end


function PetBattleAbilityTooltip_SetAbility(petOwner, petIndex, abilityIndex)
	PET_BATTLE_ABILITY_INFO.petOwner = petOwner;
	PET_BATTLE_ABILITY_INFO.petIndex = petIndex;
	PET_BATTLE_ABILITY_INFO.abilityIndex = abilityIndex;
	SharedPetBattleAbilityTooltip_SetAbility(PetBattlePrimaryAbilityTooltip, PET_BATTLE_ABILITY_INFO);
end


--------------------------------------------
----------Pet Battle Opening Frame----------
--------------------------------------------
function PetBattleOpeningFrame_OnLoad(self)
	self:RegisterEvent("PET_BATTLE_OPENING_START");
	self:RegisterEvent("PET_BATTLE_OPENING_DONE");
	self:RegisterEvent("PET_BATTLE_CLOSE");
end

function PetBattleOpeningFrame_OnEvent(self, event, ...)
	local open;
	local openMainFrame;
	local close;
	if ( event == "PET_BATTLE_OPENING_START" ) then
		open = true;
		if ( C_PetBattles.GetBattleState() ~= LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE ) then
			-- bypassing intro
			close = true;
			openMainFrame = true;
		else
			-- play intro
		end
	elseif ( event == "PET_BATTLE_OPENING_DONE" ) then
		-- end intro, open main frame
		close = true;
		openMainFrame = true;
	elseif ( event == "PET_BATTLE_CLOSE" ) then
		-- end battle all together
		close = true;
	end
	
	if ( open == true ) then
		PetBattleOpeningFrame_Display(self);
	end
	
	if ( close == true ) then
		PetBattleOpeningFrame_Remove(self);
	end
	
	if ( openMainFrame == true ) then
		PetBattleFrame_Display(PetBattleFrame);	
	end
end

function PetBattleOpeningFrame_Display(self)
	PetBattleOpeningFrame_UpdatePanel(self.MyPet, LE_BATTLE_PET_ALLY, 1);
	PetBattleOpeningFrame_UpdatePanel(self.EnemyPet, LE_BATTLE_PET_ENEMY, 1);
	--self:Show();
	AddFrameLock("PETBATTLES");
	AddFrameLock("PETBATTLEOPENING");
end

function PetBattleOpeningFrame_Remove(self)
	self:Hide();
	RemoveFrameLock("PETBATTLEOPENING");
end

function PetBattleOpeningFrame_UpdatePanel(panel, petOwner, petIndex)
	panel.PetModel:SetDisplayInfo(C_PetBattles.GetDisplayID(petOwner, petIndex));
	panel.PetModel:SetRotation((petOwner == LE_BATTLE_PET_ALLY and 1 or -1) * BATTLE_PET_DISPLAY_ROTATION);
	panel.PetModel:SetAnimation(0, 0);	--Only use the first variation of the stand animation to avoid wandering around.
	panel.PetBanner.Name:SetText(C_PetBattles.GetName(petOwner, petIndex));

	SetPortraitToTexture(panel.PetBanner.Icon, C_PetBattles.GetIcon(petOwner, petIndex));
end
