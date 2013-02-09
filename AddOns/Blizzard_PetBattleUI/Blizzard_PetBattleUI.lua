NUM_BATTLE_PETS_IN_BATTLE = 3;
NUM_BATTLE_PET_ABILITIES = 3;
BATTLE_PET_ABILITY_SWITCH = 4;
BATTLE_PET_ABILITY_CATCH = 5;
NUM_BATTLE_PET_HOTKEYS = BATTLE_PET_ABILITY_CATCH;
END_OF_PET_BATTLE_PET_LEVEL_UP = "petbattlepetlevel";
END_OF_PET_BATTLE_RESULT = "petbattleresult";
END_OF_PET_BATTLE_CAPTURE = "petbattlecapture";
local MAX_PET_LEVEL = 25;

BATTLE_PET_DISPLAY_ROTATION = 3 * math.pi / 8;

PET_BATTLE_WEATHER_TEXTURES = {
	[590] = "Interface\\PetBattles\\Weather-ArcaneStorm",
	[205] = "Interface\\PetBattles\\Weather-Blizzard",
	[171] = "Interface\\PetBattles\\Weather-BurntEarth",
	[257] = "Interface\\PetBattles\\Weather-Darkness",
	[203] = "Interface\\PetBattles\\Weather-StaticField",
	[596] = "Interface\\PetBattles\\Weather-Moonlight",
	[718] = "Interface\\PetBattles\\Weather-Mud",
	[229] = "Interface\\PetBattles\\Weather-Rain",
	[454] = "Interface\\PetBattles\\Weather-Sandstorm",
	[403] = "Interface\\PetBattles\\Weather-Sunlight",
	--[63] = "Interface\\PetBattles\\Weather-Windy",

	[235] = "Interface\\PetBattles\\Weather-Rain",
};

StaticPopupDialogs["PET_BATTLE_FORFEIT"] = {
	text = PET_BATTLE_FORFEIT_CONFIRMATION,
	button1 = OKAY,
	button2 = CANCEL,
	maxLetters = 30,
	OnAccept = function(self)
		C_PetBattles.ForfeitGame();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["PET_BATTLE_FORFEIT_NO_PENALTY"] = {
	text = PET_BATTLE_FORFEIT_CONFIRMATION_NO_PENALTY,
	button1 = OKAY,
	button2 = CANCEL,
	maxLetters = 30,
	OnAccept = function(self)
		C_PetBattles.ForfeitGame();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
--------------------------------------------
-------------Pet Battle Frame---------------
--------------------------------------------
function PetBattleFrame_OnLoad(self)
	self.BottomFrame.abilityButtons = {};

	local flowFrame = self.BottomFrame.FlowFrame;
	FlowContainer_Initialize(flowFrame);
	FlowContainer_SetOrientation(flowFrame, "horizontal");
	FlowContainer_SetHorizontalSpacing(flowFrame, 10);

	for i=1, NUM_BATTLE_PETS_IN_BATTLE do
		PetBattleUnitFrame_SetUnit(self.BottomFrame.PetSelectionFrame["Pet"..i], LE_BATTLE_PET_ALLY, i);
	end
	PetBattleFrame_UpdateAbilityButtonHotKeys(self);
	
	PetBattleFrame_LoadXPTicks(self);

	self:RegisterEvent("PET_BATTLE_OPENING_START");
	self:RegisterEvent("PET_BATTLE_OPENING_DONE");

	self:RegisterEvent("PET_BATTLE_TURN_STARTED");
	self:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
	self:RegisterEvent("PET_BATTLE_PET_CHANGED");
	self:RegisterEvent("PET_BATTLE_XP_CHANGED");
	self:RegisterEvent("PET_BATTLE_ACTION_SELECTED");

	-- Transitioning out of battle event
	self:RegisterEvent("PET_BATTLE_OVER");

	-- End of battle event:
	self:RegisterEvent("PET_BATTLE_CLOSE");

	-- Other events:
	self:RegisterEvent("UPDATE_BINDINGS");
end

function PetBattleFrame_OnEvent(self, event, ...)
	if ( event == "PET_BATTLE_OPENING_START" ) then
		PlaySoundKitID(32047); -- UI_PetBattle_Camera_Move_In
		PetBattleFrame_Display(self);
	elseif ( event == "PET_BATTLE_OPENING_DONE" ) then
		PetBattleFrameTurnTimer_UpdateValues(self.BottomFrame.TurnTimer);
		StartSplashTexture.splashAnim:Play();
		PlaySoundKitID(31584); -- UI_PetBattle_Start
		PetBattleFrame_UpdateSpeedIndicators(self);
	elseif ( event == "PET_BATTLE_TURN_STARTED" ) then
		PetBattleFrameTurnTimer_UpdateValues(self.BottomFrame.TurnTimer);
	elseif ( event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" ) then
		PetBattleFrameTurnTimer_UpdateValues(self.BottomFrame.TurnTimer);
		PetBattleFrame_UpdatePetSelectionFrame(self);
		PetBattleFrame_UpdateSpeedIndicators(self);
		PetBattleFrame_UpdateInstructions(self);
		if (C_PetBattles.IsSkipAvailable()) then
			self.BottomFrame.TurnTimer.SkipButton:Enable();
		else
			self.BottomFrame.TurnTimer.SkipButton:Disable();
		end
	elseif ( event == "PET_BATTLE_PET_CHANGED" ) then
		PetBattleFrame_UpdateAssignedUnitFrames(self);
		PetBattleFrame_UpdateAllActionButtons(self);
		PetBattleFrame_UpdateSpeedIndicators(self);
		PetBattleFrame_UpdateXpBar(self);
	elseif ( event == "PET_BATTLE_OVER" ) then
		PlaySoundKitID(32052); -- UI_PetBattle_Camera_Move_Out
	elseif ( event == "PET_BATTLE_CLOSE" ) then
		PetBattleFrame_Remove(self);
		StaticPopup_Hide("PET_BATTLE_FORFEIT");
		StaticPopup_Hide("PET_BATTLE_FORFEIT_NO_PENALTY");
	elseif ( event == "UPDATE_BINDINGS" ) then
		PetBattleFrame_UpdateAbilityButtonHotKeys(self);
	elseif ( event == "PET_BATTLE_XP_CHANGED" ) then
		PetBattleFrame_UpdateXpBar(self);
	elseif ( event == "PET_BATTLE_ACTION_SELECTED" ) then
		self.BottomFrame.TurnTimer.SkipButton:Disable();
	end
end

function PetBattleFrame_UpdateInstructions(self)
	local battleState = C_PetBattles.GetBattleState();
	if (( C_PetBattles.ShouldShowPetSelect() == true ) and 
		( not C_PetBattles.GetSelectedAction() ) ) then
		self.BottomFrame.FlowFrame.SelectPetInstruction:Show();
	else
		self.BottomFrame.FlowFrame.SelectPetInstruction:Hide();
	end
end

function PetBattleFrame_Display(self)
	AddFrameLock("PETBATTLES");		-- FrameLock removed by PetBattleFrame_Remove
	self:Show();
	if ( FCFManager_GetNumDedicatedFrames("PET_BATTLE_COMBAT_LOG") == 0 ) then
		FCF_OpenTemporaryWindow("PET_BATTLE_COMBAT_LOG");
	end
	PetBattleFrame_UpdatePetSelectionFrame(self);
	PetBattleFrame_UpdateAssignedUnitFrames(self);
	PetBattleFrame_UpdateActionBarLayout(self);
	PetBattleFrame_UpdateAllActionButtons(self);
	PetBattleFrame_InitSpeedIndicators(self);
	PetBattleFrame_UpdateSpeedIndicators(self);
	PetBattleFrame_UpdateXpBar(self);
	PetBattleFrame_UpdatePassButtonAndTimer(self);
	PetBattleFrame_UpdateInstructions(self);
	PetBattleWeatherFrame_Update(self.WeatherFrame);
end

function PetBattleFrame_PetSelectionFrameUpdateVisible(showFrame) 
	local selectionFrame = PetBattleFrame.BottomFrame.PetSelectionFrame;
	local battleState = C_PetBattles.GetBattleState();
	local selectedActionType = C_PetBattles.GetSelectedAction();
	local mustSwap = ( ( not selectedActionType ) or ( selectedActionType == BATTLE_PET_ACTION_NONE ) ) and ( battleState == LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE ) or ( battleState == LE_PET_BATTLE_STATE_WAITING_FOR_FRONT_PETS );
	if ( selectionFrame:IsShown() and ( not mustSwap ) ) then
		PetBattlePetSelectionFrame_Hide(selectionFrame);
	elseif (showFrame) then
		PetBattlePetSelectionFrame_Show(selectionFrame);
	end
end

function PetBattleFrame_UpdatePetSelectionFrame(self)
	local battleState = C_PetBattles.GetBattleState();
	if ((C_PetBattles.ShouldShowPetSelect() == true) and
		( not C_PetBattles.GetSelectedAction() ) ) then
		PetBattlePetSelectionFrame_Show(PetBattleFrame.BottomFrame.PetSelectionFrame);
	else
		PetBattlePetSelectionFrame_Hide(PetBattleFrame.BottomFrame.PetSelectionFrame);
	end
end

function PetBattleFrame_UpdateAllActionButtons(self)
	for i=1, #self.BottomFrame.abilityButtons do
		local button = self.BottomFrame.abilityButtons[i];
		PetBattleAbilityButton_UpdateIcons(button);
		PetBattleActionButton_UpdateState(button);
	end
	PetBattleActionButton_UpdateState(self.BottomFrame.SwitchPetButton);
	PetBattleActionButton_UpdateState(self.BottomFrame.CatchButton);
end

function PetBattleFrame_InitSpeedIndicators(self)
	PetBattleFrame.ActiveAlly.Border:SetShown(true);
	PetBattleFrame.ActiveEnemy.Border2:SetShown(false);
	PetBattleFrame.ActiveEnemy.SpeedUnderlay:SetShown(false);
	PetBattleFrame.ActiveEnemy.SpeedIcon:SetShown(false);

	PetBattleFrame.ActiveAlly.Border:SetShown(true);
	PetBattleFrame.ActiveAlly.Border2:SetShown(false);
	PetBattleFrame.ActiveAlly.SpeedUnderlay:SetShown(false);
	PetBattleFrame.ActiveAlly.SpeedIcon:SetShown(false);
end

function PetBattleFrame_UpdateSpeedIndicators(self)
	local hadSpeedIcon = nil;
	if (PetBattleFrame.ActiveEnemy.SpeedIcon:IsShown()) then
		hadSpeedIcon = LE_BATTLE_PET_ENEMY;
	elseif (PetBattleFrame.ActiveAlly.SpeedIcon:IsShown()) then
		hadSpeedIcon = LE_BATTLE_PET_ALLY;
	end
	
	local enemyActive = C_PetBattles.GetActivePet(LE_BATTLE_PET_ENEMY);
	local enemySpeed = C_PetBattles.GetSpeed(LE_BATTLE_PET_ENEMY, enemyActive);

	local allyActive = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	local allySpeed = C_PetBattles.GetSpeed(LE_BATTLE_PET_ALLY, allyActive);
	
	PetBattleFrame.ActiveEnemy.Border:SetShown(enemySpeed <= allySpeed);
	PetBattleFrame.ActiveEnemy.Border2:SetShown(enemySpeed > allySpeed);
	PetBattleFrame.ActiveEnemy.SpeedUnderlay:SetShown(enemySpeed > allySpeed);
	PetBattleFrame.ActiveEnemy.SpeedIcon:SetShown(enemySpeed > allySpeed);
	
	PetBattleFrame.ActiveAlly.Border:SetShown(enemySpeed >= allySpeed);
	PetBattleFrame.ActiveAlly.Border2:SetShown(enemySpeed < allySpeed);
	PetBattleFrame.ActiveAlly.SpeedUnderlay:SetShown(enemySpeed < allySpeed);
	PetBattleFrame.ActiveAlly.SpeedIcon:SetShown(enemySpeed < allySpeed);
	
	if (enemySpeed > allySpeed and (not hadSpeedIcon or hadSpeedIcon == LE_BATTLE_PET_ALLY)) then
		PetBattleFrame.ActiveEnemy.SpeedFlash:Play();
	elseif (enemySpeed < allySpeed and (not hadSpeedIcon or hadSpeedIcon == LE_BATTLE_PET_ENEMY)) then
		PetBattleFrame.ActiveAlly.SpeedFlash:Play();
	end
end

function PetBattleFrame_UpdateXpBar(self)
	local activePet = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	local level = C_PetBattles.GetLevel(LE_BATTLE_PET_ALLY, activePet);
	if (level >= MAX_PET_LEVEL) then
		self.BottomFrame.xpBar:Hide();
		return;
	end
	
	local xp, maxXp = C_PetBattles.GetXP(LE_BATTLE_PET_ALLY, activePet);
	self.BottomFrame.xpBar:SetMinMaxValues(0, maxXp);
	self.BottomFrame.xpBar:SetValue(xp);
	self.BottomFrame.xpBar:Show();
end

function PetBattleFrame_LoadXPTicks(self)
	local width = self.BottomFrame.xpBar:GetWidth();
	local divWidth = width / 7;
	local xpos = divWidth;
	for i = 1, 6 do
		local texture = _G["PetBattleXPBarDiv"..i];
		if not texture then
			texture = self.BottomFrame.xpBar:CreateTexture("MainMenuXPBarDiv"..i, "OVERLAY");
			texture:SetTexture("Interface\\MainMenuBar\\UI-XP-Bar");
			texture:SetSize(9,9);
			texture:SetTexCoord( 0.01562500, 0.15625000, 0.01562500, 0.17187500);
		end
		local xalign = floor(xpos);
		texture:SetPoint("LEFT", xalign, 1);
		texture:SetVertexColor("0.7450980392156863", "0.6352941176470588", "0.5176470588235294");
		xpos = xpos + divWidth;
	end
end

function PetBattleFrame_UpdateActionButtonLevel(self, actionButton)
	actionButton:SetFrameLevel(self.BottomFrame.FlowFrame:GetFrameLevel() + 1);
end

function PetBattleFrame_UpdateAbilityButtonHotKeys(self)
	for i=1, #self.BottomFrame.abilityButtons do
		local button = self.BottomFrame.abilityButtons[i];
		PetBattleAbilityButton_UpdateHotKey(button);
	end
	PetBattleAbilityButton_UpdateHotKey(self.BottomFrame.SwitchPetButton);
	PetBattleAbilityButton_UpdateHotKey(self.BottomFrame.CatchButton);
end

function PetBattleFrame_UpdatePassButtonAndTimer(self)
	local pveBattle = C_PetBattles.IsPlayerNPC(LE_BATTLE_PET_ENEMY);
	
	-- Timer & Button for PvP
	self.BottomFrame.TurnTimer.TimerBG:SetShown(not pveBattle);
	self.BottomFrame.TurnTimer.Bar:SetShown(not pveBattle);
	self.BottomFrame.TurnTimer.ArtFrame:SetShown(not pveBattle);
	self.BottomFrame.TurnTimer.TimerText:SetShown(not pveBattle);
	
	-- Button Only
	self.BottomFrame.TurnTimer.ArtFrame2:SetShown(pveBattle);

	-- Move the button!
	self.BottomFrame.TurnTimer.SkipButton:ClearAllPoints();
	if (pveBattle) then
		self.BottomFrame.TurnTimer.SkipButton:SetPoint("CENTER", 0, 0);
	else
		self.BottomFrame.TurnTimer.SkipButton:SetPoint("LEFT", 25, 0);
	end
end

function PetBattleFrame_UpdateActionBarLayout(self)
	local flowFrame = self.BottomFrame.FlowFrame;
	FlowContainer_RemoveAllObjects(flowFrame);
	FlowContainer_PauseUpdates(flowFrame);

	FlowContainer_SetStartingOffset(flowFrame, 0, -4);

	for i=1, NUM_BATTLE_PET_ABILITIES do
		local actionButton = self.BottomFrame.abilityButtons[i];
		if ( not actionButton ) then
			self.BottomFrame.abilityButtons[i] = CreateFrame("CheckButton", nil, self.BottomFrame, "PetBattleAbilityButtonTemplate", i);
			actionButton = self.BottomFrame.abilityButtons[i];
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

	self.BottomFrame.FlowFrame.SelectPetInstruction:ClearAllPoints();
	self.BottomFrame.FlowFrame.SelectPetInstruction:SetPoint("TOPLEFT", self.BottomFrame.abilityButtons[1], "TOPLEFT", 0, 0);
	self.BottomFrame.FlowFrame.SelectPetInstruction:SetPoint("BOTTOMRIGHT", self.BottomFrame.SwitchPetButton, "BOTTOMRIGHT", 0, 0);

end

function PetBattleFrame_ShowMultiWildNotification(self)
	if (C_PetBattles.IsWildBattle() == true) then
		local numOpponentPets = C_PetBattles.GetNumPets(LE_BATTLE_PET_ENEMY);
		local text = nil;
		if (numOpponentPets == 2) then
			text = PET_BATTLE_ANOTHER_PET_JOINED;
		elseif (numOpponentPets == 3) then
			text = PET_BATTLE_TWO_PETS_JOINED;
		end
		
		if (text) then
			RaidNotice_AddMessage(RaidWarningFrame, text, ChatTypeInfo["RAID_BOSS_EMOTE"], 5.0 );
		end
	end
end

function PetBattleFrame_ButtonDown(id)
	if ( id > NUM_BATTLE_PET_HOTKEYS ) then
		return;
	end

	local button = PetBattleFrame.BottomFrame.abilityButtons[id];
	if (id == BATTLE_PET_ABILITY_SWITCH) then
		button = PetBattleFrame.BottomFrame.SwitchPetButton;
	elseif (id == BATTLE_PET_ABILITY_CATCH) then
		button = PetBattleFrame.BottomFrame.CatchButton;
	end
	
	if (not button) then
		return;
	end

	StaticPopup_Hide("PET_BATTLE_FORFEIT", nil);
	StaticPopup_Hide("PET_BATTLE_FORFEIT_NO_PENALTY", nil);
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
	if ( GetCVarBool("ActionButtonUseKeydown") ) then
		button:Click();
	end
end

function PetBattleFrame_ButtonUp(id)
	if ( id > NUM_BATTLE_PET_ABILITIES ) then
		return;
	end

	local button = PetBattleFrame.BottomFrame.abilityButtons[id];

	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		if ( not GetCVarBool("ActionButtonUseKeydown") ) then
			button:Click();
		end
	end
end

function PetBattleAbilityButton_OnClick(self)
	if ( IsModifiedClick() ) then
		local activePet = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
		local abilityID = C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, activePet, self:GetID());
		local maxHealth = C_PetBattles.GetMaxHealth(LE_BATTLE_PET_ALLY, activePet);
		local power = C_PetBattles.GetPower(LE_BATTLE_PET_ALLY, activePet);
		local speed = C_PetBattles.GetSpeed(LE_BATTLE_PET_ALLY, activePet);
		
		HandleModifiedItemClick(GetBattlePetAbilityHyperlink(abilityID, maxHealth, power, speed));
	else
		StaticPopup_Hide("PET_BATTLE_FORFEIT",nil);
		StaticPopup_Hide("PET_BATTLE_FORFEIT_NO_PENALTY", nil);
		C_PetBattles.UseAbility(self:GetID());
		PetBattleFrame_PetSelectionFrameUpdateVisible();
	end
end

function PetBattleFrame_UpdateAssignedUnitFrames(self)
	local activeAlly = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	local activeEnemy = C_PetBattles.GetActivePet(LE_BATTLE_PET_ENEMY);

	PetBattleUnitFrame_SetUnit(self.ActiveAlly, LE_BATTLE_PET_ALLY, activeAlly);
	local nextIndex = 2;
	for i=1, NUM_BATTLE_PETS_IN_BATTLE do
		if ( i ~= activeAlly ) then
			PetBattleUnitFrame_SetUnit(self["Ally"..nextIndex], LE_BATTLE_PET_ALLY, i);
			nextIndex = nextIndex + 1;
		end
	end

	PetBattleUnitFrame_SetUnit(self.ActiveEnemy, LE_BATTLE_PET_ENEMY, activeEnemy);
	nextIndex = 2;
	for i=1, NUM_BATTLE_PETS_IN_BATTLE do
		if ( i ~= activeEnemy ) then
			PetBattleUnitFrame_SetUnit(self["Enemy"..nextIndex], LE_BATTLE_PET_ENEMY, i);
			nextIndex = nextIndex + 1;
		end
	end

	PetBattleAuraHolder_SetUnit(self.EnemyBuffFrame, LE_BATTLE_PET_ENEMY, activeEnemy);
	PetBattleAuraHolder_SetUnit(self.EnemyDebuffFrame, LE_BATTLE_PET_ENEMY, activeEnemy);
	PetBattleAuraHolder_SetUnit(self.AllyBuffFrame, LE_BATTLE_PET_ALLY, activeAlly);
	PetBattleAuraHolder_SetUnit(self.AllyDebuffFrame, LE_BATTLE_PET_ALLY, activeAlly);
	PetBattleAuraHolder_SetUnit(self.EnemyPadBuffFrame, LE_BATTLE_PET_ENEMY, PET_BATTLE_PAD_INDEX);
	PetBattleAuraHolder_SetUnit(self.EnemyPadDebuffFrame, LE_BATTLE_PET_ENEMY, PET_BATTLE_PAD_INDEX);
	PetBattleAuraHolder_SetUnit(self.AllyPadBuffFrame, LE_BATTLE_PET_ALLY, PET_BATTLE_PAD_INDEX);
	PetBattleAuraHolder_SetUnit(self.AllyPadDebuffFrame, LE_BATTLE_PET_ALLY, PET_BATTLE_PAD_INDEX);
end

function PetBattleFrame_Remove(self)
	ActionButton_HideOverlayGlow(PetBattleFrame.BottomFrame.CatchButton);
	PetBattleFrame.BottomFrame.CatchButton.playedSound = false;
	self:Hide();
	RemoveFrameLock("PETBATTLES");
end

local TIMER_BAR_TEXCOORD_LEFT = 0.56347656;
local TIMER_BAR_TEXCOORD_RIGHT = 0.89453125;
local TIMER_BAR_TEXCOORD_TOP = 0.00195313;
local TIMER_BAR_TEXCOORD_BOTTOM = 0.03515625;
function PetBattleFrameTurnTimer_OnUpdate(self, elapsed)
	if ( ( C_PetBattles.GetBattleState() ~= LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE ) and
		 ( C_PetBattles.GetBattleState() ~= LE_PET_BATTLE_STATE_ROUND_IN_PROGRESS ) and
		 ( C_PetBattles.GetBattleState() ~= LE_PET_BATTLE_STATE_WAITING_FOR_FRONT_PETS ) ) then
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
	local forfeitPenalty = C_PetBattles.GetForfeitPenalty();
	if(forfeitPenalty == 0) then
		StaticPopup_Show("PET_BATTLE_FORFEIT_NO_PENALTY", nil, nil, nil)
	else
		StaticPopup_Show("PET_BATTLE_FORFEIT", forfeitPenalty, nil, nil)
	end
end

function PetBattleCatchButton_OnClick(self)
	local forfeitPenalty = C_PetBattles.GetForfeitPenalty();
	if(forfeitPenalty == 0) then
		StaticPopup_Hide("PET_BATTLE_FORFEIT_NO_PENALTY",nil);
	else
		StaticPopup_Hide("PET_BATTLE_FORFEIT",nil);
	end
	C_PetBattles.UseTrap();
end

function PetBattleCatchButton_OnShow(self)
	local trapAbilityID = C_PetBattles.GetPlayerTrapAbility();
	if (trapAbilityID and trapAbilityID > 0) then
		local abID, abName, abIcon, abCooldown, abDescription = C_PetBattles.GetAbilityInfoByID(trapAbilityID);
		self.name = abName;
		self.description = abDescription;
		self.Icon:SetTexture(abIcon);
	else
		self.name = CATCH_PET;
		self.description = CATCH_PET_DESCRIPTION;
		self.additionalText = PET_BATTLE_TRAP_ERR_2;
		GameTooltip:Show();
	end
end

function PetBattleCatchButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
	GameTooltip:AddLine(self.description, nil, nil, nil, true);
	if (self.additionalText) then
		GameTooltip:AddLine(self.additionalText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	end
	GameTooltip:Show();
end

function PetBattleFrame_GetAbilityAtLevel(speciesID, targetLevel)
	local abilities, levels = C_PetJournal.GetPetAbilityList(speciesID);
	for i, level in pairs(levels) do
		if level == targetLevel then
			return abilities[i];
		end
	end

	return nil;
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
		self["Pet"..i]:SetEnabled(C_PetBattles.CanPetSwapIn(i));
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
		PetBattleAbilityButton_UpdateBetterIcon(self)
	end
end

function PetBattleActionButton_UpdateState(self)
	local actionType = self.actionType;
	local actionIndex = self.actionIndex;

	local _, usable, cooldown, hasSelected, isSelected, isLocked, isHidden;
	local selectedActionType, selectedActionIndex = C_PetBattles.GetSelectedAction();

	--Decide whether we have a selected action and if it's this button.
	if ( selectedActionType ) then
		hasSelected = true;
		if ( actionType == selectedActionType and (not actionIndex or actionIndex == selectedActionIndex) ) then
			isSelected = true;
		end
	end

	--Get the battle state to check when looking at each action type.
	local battleState = C_PetBattles.GetBattleState();

	--Set up usable/cooldown/locked for each action type.
	if ( actionType == LE_BATTLE_PET_ACTION_ABILITY ) then
		local _, name, icon = C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY), actionIndex);

		--If we're being forced to swap pets, hide us
		if ( C_PetBattles.ShouldShowPetSelect() == true ) then
			isHidden = true;
		end

		--If we exist, check whether we're usable and what the cooldown is.
		if ( name ) then
			local isUsable, currentCooldown, currentLockdown = C_PetBattles.GetAbilityState(LE_BATTLE_PET_ALLY, C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY), actionIndex);
			usable = isUsable;
			cooldown = max(currentCooldown, currentLockdown);
		else
			isLocked = true;
		end
	elseif ( actionType == LE_BATTLE_PET_ACTION_TRAP ) then
		local trapErr;
		usable, trapErr = C_PetBattles.IsTrapAvailable();
		if (not usable and trapErr and trapErr > 1) then
			self.additionalText = _G["PET_BATTLE_TRAP_ERR_"..trapErr];
			self.Lock:SetShown(trapErr == 2); -- PETBATTLE_TRAPSTATUS_CANT_TRAP_NEWBIE
		else
			self.additionalText = nil;
		end
	elseif ( actionType == LE_BATTLE_PET_ACTION_SWITCH_PET ) then
		--If we're being forced to swap pets, hide us
		if ( C_PetBattles.ShouldShowPetSelect() == true ) then
			isHidden = true;
		end
		
		usable = false;
		-- There must be at least one pet that can swap in
		for i = 1, NUM_BATTLE_PETS_IN_BATTLE do
			usable = usable or C_PetBattles.CanPetSwapIn(i);
		end
		-- AND the active pet must be able to swap out
		usable = usable and C_PetBattles.CanActivePetSwapOut();
	elseif ( actionType == LE_BATTLE_PET_ACTION_SKIP ) then
		usable = C_PetBattles.IsSkipAvailable();
	else
		usable = true;
	end

	if ( isHidden ) then
		self:Disable();
		self:SetAlpha(0);
	elseif ( isLocked ) then
		--Set the frame up to look like a cooldown, but with a required level
		if ( self.Icon ) then
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
			self.Icon:SetDesaturated(true);
		end
		self:Disable();
		self:SetAlpha(1);
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Hide();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Show();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.Lock ) then
			self.Lock:Show();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(0.5, 0.5, 0.5);
		end
		if ( self.BetterIcon ) then
			self.BetterIcon:Hide();
		end
	elseif ( cooldown and cooldown > 0 ) then
		--Set the frame up to look like a cooldown.
		if ( self.Icon ) then
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
			self.Icon:SetDesaturated(true);
		end
		self:Disable();
		self:SetAlpha(1);
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
		if ( self.Lock ) then
			self.Lock:Hide();
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
		self:SetAlpha(1);
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Hide();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.Lock ) then
			self.Lock:Hide();
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
		self:SetAlpha(1);
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Show();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.Lock ) then
			self.Lock:Hide();
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
		self:SetAlpha(1);
		if ( self.SelectedHighlight ) then
			self.SelectedHighlight:Hide();
		end
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.Lock ) then
			self.Lock:Hide();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(1, 1, 1);
		end
		if (self.CooldownFlash and actionType ~= LE_BATTLE_PET_ACTION_TRAP) then
			self.CooldownFlashAnim:Play();
		end
	end

	if ( actionType == LE_BATTLE_PET_ACTION_TRAP ) then
		if ( usable ) then
			if ( not self.playedSound ) then
				PlaySoundKitID(28814);
				self.playedSound = true;
			end
			ActionButton_ShowOverlayGlow(self);
		else
			self.playedSound = false;
			ActionButton_HideOverlayGlow(self);
		end
	end
end

-------------------------------------------------
-----------Pet Battle Ability Button-------------
--Only for abilities, not other action buttons---
-------------------------------------------------
function PetBattleAbilityButton_OnLoad(self)
	PetBattleActionButton_Initialize(self, LE_BATTLE_PET_ACTION_ABILITY, self:GetID());
	PetBattleAbilityButton_UpdateHotKey(self);
end

function PetBattleAbilityButton_UpdateBetterIcon(self)
	if (not self.BetterIcon) then
		return;
	end
	self.BetterIcon:Hide();
	
	local activePet = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	if (not activePet) then
		return;
	end

	local petType, noStrongWeakHints, _;
	_, _, _, _, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, activePet, self:GetID());
	if (not petType) then
		return;
	end
	
	-- show Strong/Weak icons on buttons.
	local enemyPetSlot = C_PetBattles.GetActivePet(LE_BATTLE_PET_ENEMY);
	local enemyType = C_PetBattles.GetPetType(LE_BATTLE_PET_ENEMY, enemyPetSlot);
	local modifier = C_PetBattles.GetAttackModifier(petType, enemyType);

	if ( noStrongWeakHints or modifier == 1 ) then
		self.BetterIcon:Hide();
	elseif (modifier > 1) then
		self.BetterIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong");
		self.BetterIcon:Show();
	elseif (modifier < 1) then
		self.BetterIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Weak");
		self.BetterIcon:Show();
	end
end

function PetBattleAbilityButton_UpdateIcons(self)
	local activePet = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, activePet, self:GetID());
	self.abilityID = id;
	if ( not icon ) then
		icon = "Interface\\Icons\\INV_Misc_QuestionMark";
	end
	if ( not name ) then
		--We don't have an ability here.
		local abilities = {};
		local abilityLevels = {};
		local speciesID = C_PetBattles.GetPetSpeciesID(LE_BATTLE_PET_ALLY, activePet);
		C_PetJournal.GetPetAbilityList(speciesID, abilities, abilityLevels);	--Read ability/ability levels into the correct tables
		self.abilityID = abilities[self:GetID()];
		if ( not self.abilityID ) then
			self.Icon:SetTexture("INTERFACE\\ICONS\\INV_Misc_Key_05");
			self:Hide();
		else
			name, icon = C_PetJournal.GetPetAbilityInfo(self.abilityID);
			self.Icon:SetTexture(icon);
			self.Lock:Show();
			self.requiredLevel = abilityLevels[self:GetID()];
		end
		self.Icon:SetVertexColor(1, 1, 1);
		self:Disable();
		return;
	end
	self.Icon:SetTexture(icon);
	self:Enable();
	self:Show();

	-- show Strong/Weak icons on buttons.
	PetBattleAbilityButton_UpdateBetterIcon(self);
end

function PetBattleAbilityButton_OnEnter(self)
	local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	if ( self:GetEffectiveAlpha() > 0 and C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, petIndex, self:GetID()) ) then
		PetBattleAbilityTooltip_SetAbility(LE_BATTLE_PET_ALLY, petIndex, self:GetID());
		PetBattleAbilityTooltip_Show("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 120, self.additionalText);
	elseif ( self.abilityID ) then
		PetBattleAbilityTooltip_SetAbilityByID(LE_BATTLE_PET_ALLY, petIndex, self.abilityID, format(PET_ABILITY_REQUIRES_LEVEL, self.requiredLevel));
		PetBattleAbilityTooltip_Show("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 120);
	else
		PetBattlePrimaryAbilityTooltip:Hide();
	end
end

function PetBattleAbilityButton_OnLeave(self)
	PetBattlePrimaryAbilityTooltip:Hide();
end

function PetBattleAbilityButton_UpdateHotKey(self)
	local key = GetBindingKey("ACTIONBUTTON"..self:GetID());
	if ( key ) then
		self.HotKey:SetText(key);
		self.HotKey:Show();
	else
		self.HotKey:Hide();
	end
end

--------------------------------------------
----------Pet Battle Unit Frame-------------
--------------------------------------------
function PetBattleUnitFrame_OnLoad(self)
	self:RegisterEvent("PET_BATTLE_MAX_HEALTH_CHANGED");
	self:RegisterEvent("PET_BATTLE_HEALTH_CHANGED");
	self:RegisterEvent("PET_BATTLE_PET_CHANGED");
	
	self:RegisterEvent("PET_BATTLE_AURA_APPLIED");
	self:RegisterEvent("PET_BATTLE_AURA_CANCELED");
	self:RegisterEvent("PET_BATTLE_AURA_CHANGED");
end

function PetBattleUnitFrame_OnClick(self, button)
	if ( button == "RightButton" ) then
		PetBattleUnitFrame_ShowDropdown(self, self.petIndex);
	end
end

function PetBattleUnitFrame_ShowDropdown(self, petIndex)
	--Right now, this only has the report option, so we won't display the dropdown if that won't be available
	local name, speciesName = C_PetBattles.GetName(self.petOwner, petIndex);
	
	HideDropDownMenu(1);
	PetBattleUnitFrameDropDown.petOwner = self.petOwner;	
	PetBattleUnitFrameDropDown.name = name;	
	PetBattleUnitFrameDropDown.petIndex = petIndex;
	PetBattleUnitFrameDropDown.speciesID = C_PetBattles.GetPetSpeciesID(self.petOwner, self.petIndex);	
	ToggleDropDownMenu(1, nil, PetBattleUnitFrameDropDown, "cursor");
end

function PetBattleUnitFrame_OnEvent(self, event, ...)
	if ( event == "PET_BATTLE_HEALTH_CHANGED" or event == "PET_BATTLE_MAX_HEALTH_CHANGED" ) then
		local petOwner, petIndex = ...;
		if ( petOwner == self.petOwner and petIndex == self.petIndex ) then
			PetBattleUnitFrame_UpdateHealthInstant(self);
		end
	elseif ( event == "PET_BATTLE_PET_CHANGED" ) then
		PetBattleUnitFrame_UpdateDisplay(self);
	elseif ( event == "PET_BATTLE_AURA_APPLIED" or
		event == "PET_BATTLE_AURA_CANCELED" or
		event == "PET_BATTLE_AURA_CHANGED" ) then
		local petOwner, petIndex = ...;
		if ( petOwner == self.petOwner and petIndex == self.petIndex ) then
			PetBattleUnitFrame_UpdatePetType(self);
		end
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

	if ( petIndex > C_PetBattles.GetNumPets(petOwner) ) then
		return;
	end

	local battleState = C_PetBattles.GetBattleState();

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
	
	--Update the pet rarity border
	if (self.Border) then
		local rarity = C_PetBattles.GetBreedQuality(petOwner, petIndex);
		if (ENABLE_COLORBLIND_MODE == "1") then 
			self.Name:SetText(self.Name:GetText().." (".._G["BATTLE_PET_BREED_QUALITY"..rarity]..")");
		else
			self.Border:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);		
			self.Name:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);
		end
	end
	
	if (self.BorderAlive and self.BorderAlive:IsShown()) then
		local rarity = C_PetBattles.GetBreedQuality(petOwner, petIndex);
		self.BorderAlive:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);		
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
			self.PetModel:SetAnimation(742, 0); -- Display the PetBattleStand animation
			--self.PetModel:SetAnimation(742, 0);
		end
	end

	--Updated the indicator that this is the active pet
	if ( self.SelectedTexture ) then
		if ( C_PetBattles.ShouldShowPetSelect() == false and
			C_PetBattles.GetActivePet(petOwner) == petIndex ) then
			self.SelectedTexture:Show();
		else
			self.SelectedTexture:Hide();
		end
	end

	--Update the XP bar
	if ( self.XPBar ) then
		local xp, maxXp = C_PetBattles.GetXP(petOwner, petIndex);
		self.XPBar:SetWidth(max((xp / max(maxXp,1)) * self.xpBarWidth, 1));
	end

	--Update the XP text
	if ( self.XPText ) then
		local xp, maxXp = C_PetBattles.GetXP(petOwner, petIndex);
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
		self.ActualHealthBar:SetWidth((health / max(maxHealth,1)) * self.healthBarWidth);
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

		local auraID = PET_BATTLE_PET_TYPE_PASSIVES[petType];
		self.PetType.auraID = auraID;

		if ( auraID and self.PetType.ActiveStatus ) then
			local hasAura = PetBattleUtil_PetHasAura(self.petOwner, self.petIndex, auraID);
			if ( hasAura ) then
				self.PetType.ActiveStatus:Show();
			else
				self.PetType.ActiveStatus:Hide();
			end
		end
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

	self.weakToTextures = { self.WeakTo1 };
	self.resistantToTextures = { self.ResistantTo1 };
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function PetBattleUnitFrameDropDown_ReportUnit(btn, name, petIndex)
	C_PetBattles.SetPendingReportBattlePetTarget(petIndex);
	StaticPopup_Show("CONFIRM_REPORT_BATTLEPET_NAME", name);
end

function PetBattleUnitFrameDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.text = self.name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	
	local name, speciesName = C_PetBattles.GetName(self.petOwner, self.petIndex);
	if (not C_PetBattles.IsPlayerNPC(LE_BATTLE_PET_ENEMY) and self.petOwner == LE_BATTLE_PET_ENEMY 
		and name and name ~= speciesName) then
		info.text = REPORT_PET_NAME;
		info.func = PetBattleUnitFrameDropDown_ReportUnit;
		info.arg1 = self.name;
		info.arg2 = self.petIndex;
		UIDropDownMenu_AddButton(info);
	end
	
	info.disabled = nil;
	info.text = PET_SHOW_IN_JOURNAL;
	info.func = function ()
					if (not PetJournalParent) then
						PetJournal_LoadUI();
					end
					if (not PetJournalParent:IsShown()) then
						ShowUIPanel(PetJournalParent);
					end
					PetJournalParent_SetTab(PetJournalParent, 2);
					PetJournal_SelectSpecies(PetJournal, self.speciesID);
				end
	UIDropDownMenu_AddButton(info);
end

function PetBattleUnitTooltip_UpdateForUnit(self, petOwner, petIndex)
	PetBattleUnitFrame_SetUnit(self, petOwner, petIndex);

	local height = 198;
	local attack = C_PetBattles.GetPower(petOwner, petIndex);
	local speed = C_PetBattles.GetSpeed(petOwner, petIndex);
	local level = C_PetBattles.GetLevel(petOwner, petIndex);
	local opponentSpeed = 0;
	if ( petOwner == LE_BATTLE_PET_ALLY ) then
		opponentSpeed = C_PetBattles.GetSpeed(LE_BATTLE_PET_ENEMY, C_PetBattles.GetActivePet(LE_BATTLE_PET_ENEMY));
	else
		opponentSpeed = C_PetBattles.GetSpeed(LE_BATTLE_PET_ALLY, C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY));
	end
	if (speed > opponentSpeed) then
		height = height + 36;
		self.SpeedAdvantage:Show();
		self.SpeedAdvantageIcon:Show();
		self.Delimiter2:SetPoint("TOPLEFT", self.SpeedAdvantageIcon, "BOTTOMLEFT", -3, -10)
	else
		self.SpeedAdvantage:Hide();
		self.SpeedAdvantageIcon:Hide();
		self.Delimiter2:SetPoint("TOPLEFT", self.SpeedAdvantageIcon, "BOTTOMLEFT", -3, 26)
	end
	
	self.AttackAmount:SetText(attack);
	self.SpeedAmount:SetText(speed);
	
	local displayCollected = false;
	local speciesID = C_PetBattles.GetPetSpeciesID(LE_BATTLE_PET_ENEMY, petIndex);
	if ( speciesID ) then
		local _, _, _, _, _, _, _, _, _, _, obtainable = C_PetJournal.GetPetInfoBySpeciesID(speciesID);
		if ( obtainable and petOwner == LE_BATTLE_PET_ENEMY and C_PetBattles.IsWildBattle() ) then
			displayCollected = true;
		end
	end
	if ( displayCollected ) then
		local numOwned, maxAllowed = C_PetJournal.GetNumCollectedInfo(speciesID);
		if (numOwned < maxAllowed) then
			self.CollectedText:SetText(GREEN_FONT_COLOR_CODE..format(ITEM_PET_KNOWN, numOwned, maxAllowed)..FONT_COLOR_CODE_CLOSE);
		else
			self.CollectedText:SetText(RED_FONT_COLOR_CODE..format(ITEM_PET_KNOWN, numOwned, maxAllowed)..FONT_COLOR_CODE_CLOSE);
		end
		self.CollectedText:Show();
		self.HealthBorder:SetPoint("TOPLEFT", self.CollectedText, "BOTTOMLEFT", -1, -6);
		height = height + self.CollectedText:GetHeight()
	else
		self.CollectedText:Hide();
		self.HealthBorder:SetPoint("TOPLEFT", self.Icon, "BOTTOMLEFT", -1, -6);
	end
	
	if ( petOwner == LE_BATTLE_PET_ALLY and level < MAX_PET_LEVEL ) then
		--Add the XP bar
		self.XPBar:Show();
		self.XPBG:Show();
		self.XPBorder:Show();
		self.XPText:Show();
		self.Delimiter:SetPoint("TOP", self.XPBG, "BOTTOM", 0, -10);
		height = height + 18;
	else
		--Remove the XP bar
		self.XPBar:Hide();
		self.XPBG:Hide();
		self.XPBorder:Hide();
		self.XPText:Hide();
		self.Delimiter:SetPoint("TOP", self.HealthBG, "BOTTOM", 0, -10);
	end

	if ( petOwner == LE_BATTLE_PET_ALLY or C_PetBattles.IsPlayerNPC(petOwner) ) then
		--Show and update abilities
		self.AbilitiesLabel:Show();
		local enemyPetType = C_PetBattles.GetPetType(PetBattleUtil_GetOtherPlayer(petOwner), C_PetBattles.GetActivePet(PetBattleUtil_GetOtherPlayer(petOwner)));
		for i=1, NUM_BATTLE_PET_ABILITIES do
			local id, name, icon, maxCooldown, description, numTurns, abilityPetType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(petOwner, petIndex, i);

			local abilityIcon = self["AbilityIcon"..i];
			local abilityName = self["AbilityName"..i];
			if ( id ) then
				local modifier = 1.0;
				if (abilityPetType and enemyPetType) then
					modifier = C_PetBattles.GetAttackModifier(abilityPetType, enemyPetType);
				end
				
				if ( noStrongWeakHints or modifier == 1 ) then
					abilityIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Neutral");
				elseif ( modifier < 1 ) then
					abilityIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Weak");
				elseif ( modifier > 1 ) then
					abilityIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong");
				end
				abilityName:SetText(name);
				abilityIcon:Show();
				abilityName:Show();
			else
				abilityIcon:Hide();
				abilityName:Hide();
			end
		end
	else

		--Hide abilities
		self.AbilitiesLabel:Hide();
		for i=1, NUM_BATTLE_PET_ABILITIES do
			self["AbilityIcon"..i]:Hide();
			self["AbilityName"..i]:Hide();
		end
	end

	if ( SHOW_WEAK_AND_RESISTANT ) then

		--Show and update weak to/resistant against
		self.WeakToLabel:Show();
		self.ResistantToLabel:Show();
		
		local nextWeakIndex, nextResistIndex = 1, 1;
		local currentPetType = C_PetBattles.GetPetType(petOwner, petIndex);
		for i=1, C_PetJournal.GetNumPetTypes() do
			local modifier = C_PetBattles.GetAttackModifier(i, currentPetType);
			if ( modifier > 1 ) then
				local icon = self.weakToTextures[nextWeakIndex];
				if ( not icon ) then
					self.weakToTextures[nextWeakIndex] = self:CreateTexture(nil, "ARTWORK", "PetBattleUnitTooltipPetTypeStrengthTemplate");
					icon = self.weakToTextures[nextWeakIndex];
					icon:ClearAllPoints();
					icon:SetPoint("LEFT", self.weakToTextures[nextWeakIndex - 1], "RIGHT", 5, 0);
				end
				icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[i]);
				icon:Show();
				nextWeakIndex = nextWeakIndex + 1;
			elseif ( modifier < 1 ) then
				local icon = self.resistantToTextures[nextResistIndex];
				if ( not icon ) then
					self.resistantToTextures[nextResistIndex] = self:CreateTexture(nil, "ARTWORK", "PetBattleUnitTooltipPetTypeStrengthTemplate");
					icon = self.resistantToTextures[nextResistIndex];
					icon:ClearAllPoints();
					icon:SetPoint("LEFT", self.resistantToTextures[nextResistIndex - 1], "RIGHT", 5, 0);
				end
				icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[i]);
				icon:Show();
				nextResistIndex = nextResistIndex + 1;
			end
		end

		for i=nextWeakIndex, #self.weakToTextures do
			self.weakToTextures[i]:Hide();
		end
		for i=nextResistIndex, #self.resistantToTextures do
			self.resistantToTextures[i]:Hide();
		end

		height = height + 5;
	else
		--Hide the weak to/resistant to
		self.WeakToLabel:Hide();
		self.ResistantToLabel:Hide();

		for _, texture in pairs(self.weakToTextures) do
			texture:Hide();
		end
		for _, texture in pairs(self.resistantToTextures) do
			texture:Hide();
		end
	end
	
	--Updates debuffs
	local nextFrame = 1;
	local debuffs = self.Debuffs;
	local debuffsHeight = 0;
	for i=1, C_PetBattles.GetNumAuras(petOwner, petIndex) do
		local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(petOwner, petIndex, i);
		if (not isBuff) then
			--We want to display this frame.
			local frame = debuffs.frames[nextFrame];
			if ( not frame ) then
				--No frame, create one
				debuffs.frames[nextFrame] = CreateFrame("FRAME", nil, debuffs, debuffs.template);
				frame = debuffs.frames[nextFrame];
				
				--Anchor the new frame
				if ( nextFrame == 1 ) then
					frame:SetPoint("TOPLEFT", debuffs, "TOPLEFT", 0, 0);
				else
					frame:SetPoint("TOPLEFT", debuffs.frames[nextFrame - 1], "BOTTOMLEFT", 0, -6);
				end
			end
			
			--Update the actual aura
			local id, name, icon, maxCooldown, description = C_PetBattles.GetAbilityInfoByID(auraID);
			
			frame.Icon:SetTexture(icon);
			frame.Name:SetText(name);
			if ( turnsRemaining < 0 ) then
				frame.Duration:SetText("");
			else
				frame.Duration:SetFormattedText(PET_BATTLE_AURA_TURNS_REMAINING, turnsRemaining);
			end
			frame.auraIndex = i;
			frame:Show();

			nextFrame = nextFrame + 1;
			debuffsHeight = debuffsHeight + 40;
		end
	end
	
	for i=nextFrame, #debuffs.frames do
		debuffs.frames[i]:Hide();
	end
	
	if (nextFrame > 1) then
		debuffs:Show()
		self.Delimiter2:Show()
		debuffsHeight = debuffsHeight + 5 --extra padding to go below the debuffs
	else
		debuffs:Hide()
		self.Delimiter2:Hide()
	end
	
	debuffs:SetHeight(debuffsHeight);
	height = height + debuffsHeight;
	self:SetHeight(height);
end

function PetBattleUnitTooltip_Attach(self, point, frame, relativePoint, xOffset, yOffset)
	self:SetParent(frame);
	self:SetFrameStrata("TOOLTIP");
	self:ClearAllPoints();
	self:SetPoint(point, frame, relativePoint, xOffset, yOffset);
end

--------------------------------------------
---------Pet Battle Ability Tooltip---------
--------------------------------------------
PET_BATTLE_ABILITY_INFO = SharedPetBattleAbilityTooltip_GetInfoTable();

function PET_BATTLE_ABILITY_INFO:GetCooldown()
	if (self.abilityID) then
		return 0;
	end
	local isUsable, currentCooldown = C_PetBattles.GetAbilityState(self.petOwner, self.petIndex, self.abilityIndex);
	return currentCooldown;
end

function PET_BATTLE_ABILITY_INFO:GetAbilityID()
	if (self.abilityID) then
		return self.abilityID;
	end
	local id = C_PetBattles.GetAbilityInfo(self.petOwner, self.petIndex, self.abilityIndex);
	return id;
end

function PET_BATTLE_ABILITY_INFO:IsInBattle()
	return true;
end

function PET_BATTLE_ABILITY_INFO:GetMaxHealth(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetMaxHealth(petOwner, petIndex);
end

function PET_BATTLE_ABILITY_INFO:GetHealth(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetHealth(petOwner, petIndex);
end

function PET_BATTLE_ABILITY_INFO:GetAttackStat(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetPower(petOwner, petIndex);
end

function PET_BATTLE_ABILITY_INFO:GetSpeedStat(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetSpeed(petOwner, petIndex);
end

function PET_BATTLE_ABILITY_INFO:GetState(stateID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetStateValue(petOwner, petIndex, stateID);
end

function PET_BATTLE_ABILITY_INFO:GetWeatherState(stateID)
	return C_PetBattles.GetStateValue(LE_BATTLE_PET_WEATHER, PET_BATTLE_PAD_INDEX, stateID);
end

function PET_BATTLE_ABILITY_INFO:GetPadState(stateID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetStateValue(petOwner, PET_BATTLE_PAD_INDEX, stateID);
end

function PET_BATTLE_ABILITY_INFO:GetPetOwner(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return petOwner;
end

function PET_BATTLE_ABILITY_INFO:HasAura(auraID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return PetBattleUtil_PetHasAura(petOwner, petIndex, auraID);
end

function PET_BATTLE_ABILITY_INFO:GetPetType(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetPetType(petOwner, petIndex);
end


--For use by other functions here
function PET_BATTLE_ABILITY_INFO:GetUnitFromToken(target)
	if ( target == "default" ) then
		target = "self";
	elseif ( target == "affected" ) then
		target = "enemy";
	end

	if ( target == "self" ) then
		return self.petOwner, self.petIndex;
	elseif ( target == "enemy" ) then
		local owner = PetBattleUtil_GetOtherPlayer(self.petOwner);
		return owner, C_PetBattles.GetActivePet(owner);
	else
		error("Unsupported token: "..tostring(target));
	end
end

function PetBattleAbilityTooltip_SetAbility(petOwner, petIndex, abilityIndex)
	PET_BATTLE_ABILITY_INFO.petOwner = petOwner;
	PET_BATTLE_ABILITY_INFO.petIndex = petIndex;
	PET_BATTLE_ABILITY_INFO.abilityID = nil;
	PET_BATTLE_ABILITY_INFO.abilityIndex = abilityIndex;
	SharedPetBattleAbilityTooltip_SetAbility(PetBattlePrimaryAbilityTooltip, PET_BATTLE_ABILITY_INFO);
end

function PetBattleAbilityTooltip_SetAbilityByID(petOwner, petIndex, abilityID, additionalText)
	PET_BATTLE_ABILITY_INFO.petOwner = petOwner;
	PET_BATTLE_ABILITY_INFO.petIndex = petIndex;
	PET_BATTLE_ABILITY_INFO.abilityID = abilityID;
	PET_BATTLE_ABILITY_INFO.abilityIndex = nil;
	SharedPetBattleAbilityTooltip_SetAbility(PetBattlePrimaryAbilityTooltip, PET_BATTLE_ABILITY_INFO, additionalText);
end

----------------------------------------------
------------Pet Battle Weather Frame----------
----------------------------------------------
function PetBattleWeatherFrame_OnLoad(self)
	self:RegisterEvent("PET_BATTLE_AURA_APPLIED");
	self:RegisterEvent("PET_BATTLE_AURA_CANCELED");
	self:RegisterEvent("PET_BATTLE_AURA_CHANGED");
end

function PetBattleWeatherFrame_OnEvent(self, event, ...)
	if ( event == "PET_BATTLE_AURA_APPLIED" or
		event == "PET_BATTLE_AURA_CANCELED" or
		event == "PET_BATTLE_AURA_CHANGED" ) then
		local petOwner, petIndex = ...;
		if ( petOwner == LE_BATTLE_PET_WEATHER ) then
			PetBattleWeatherFrame_Update(self);
		end
	end
end

function PetBattleWeatherFrame_Update(self)
	local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(LE_BATTLE_PET_WEATHER, PET_BATTLE_PAD_INDEX, 1);
	if ( auraID ) then
		local id, name, icon, maxCooldown, description = C_PetBattles.GetAbilityInfoByID(auraID);
		self.Icon:SetTexture(icon);
		self.Name:SetText(name);
		if ( turnsRemaining < 0 ) then
			self.Duration:SetText("");
		else
			self.Duration:SetText(turnsRemaining);
		end

		local backgroundTexture = PET_BATTLE_WEATHER_TEXTURES[auraID];
		if ( backgroundTexture ) then
			self.BackgroundArt:SetTexture(backgroundTexture);
			self.BackgroundArt:Show();
		else
			self.BackgroundArt:Hide();
		end

		self:Show();
	else
		self:Hide();
	end
end

----------------------------------------------
------------Pet Battle Aura Holder------------
----------------------------------------------
function PetBattleAuraHolder_OnLoad(self)
	if ( not self.template ) then
		GMError("Must provide template for PetBattleAuraHolder");
	end
	if ( not self.displayBuffs and not self.displayDebuffs ) then
		GMError("Neither buffs nor nebuffs are displayed in a PetBattleAuraHolder");
	end

	self.frames = {};

	self:RegisterEvent("PET_BATTLE_AURA_APPLIED");
	self:RegisterEvent("PET_BATTLE_AURA_CANCELED");
	self:RegisterEvent("PET_BATTLE_AURA_CHANGED");
end

function PetBattleAuraHolder_OnEvent(self, event, ...)
	if ( event == "PET_BATTLE_AURA_APPLIED" or event == "PET_BATTLE_AURA_CANCELED" or event == "PET_BATTLE_AURA_CHANGED" ) then
		local petOwner, petIndex, instanceID = ...;
		if ( petOwner == self.petOwner and petIndex == self.petIndex ) then
			PetBattleAuraHolder_Update(self);
		end
	end
end

function PetBattleAuraHolder_SetUnit(self, petOwner, petIndex)
	self.petOwner = petOwner;
	self.petIndex = petIndex;
	PetBattleAuraHolder_Update(self);
end

function PetBattleAuraHolder_Update(self)
	if ( not self.petOwner or not self.petIndex ) then
		self:Hide();
		return;
	end

	local growsTo = self.growsToDirection;
	local numPerRow = self.numPerRow;
	local growsFrom = "LEFT";
	if ( growsTo == "LEFT" ) then
		growsFrom = "RIGHT";
	end

	local nextFrame = 1;
	for i=1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
		local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i);
		if ( (isBuff and self.displayBuffs) or (not isBuff and self.displayDebuffs) ) then
			--We want to display this frame.
			local frame = self.frames[nextFrame];
			if ( not frame ) then
				--No frame, create one
				self.frames[nextFrame] = CreateFrame("FRAME", nil, self, self.template);
				frame = self.frames[nextFrame];

				--Anchor the new frame
				if ( nextFrame == 1 ) then
					frame:SetPoint("TOP"..growsFrom, self, "TOP"..growsFrom, 0, 0);
				elseif ( (nextFrame - 1) % numPerRow == 0 ) then
					frame:SetPoint("TOP"..growsFrom, self.frames[nextFrame - numPerRow], "BOTTOM"..growsFrom, 0, 0);
				else
					frame:SetPoint("TOP"..growsFrom, self.frames[nextFrame - 1], "TOP"..growsTo, growsTo == "LEFT" and -4 or 4, 0);
				end
			end

			--Update the actual aura
			local id, name, icon, maxCooldown, description = C_PetBattles.GetAbilityInfoByID(auraID);

			if ( isBuff ) then
				frame.DebuffBorder:Hide();
			else
				frame.DebuffBorder:Show();
			end

			frame.Icon:SetTexture(icon);
			if ( turnsRemaining < 0 ) then
				frame.Duration:SetText("");
			else
				frame.Duration:SetFormattedText(PET_BATTLE_AURA_TURNS_REMAINING, turnsRemaining);
			end
			frame.auraIndex = i;
			frame:Show();

			nextFrame = nextFrame + 1;
		end
	end

	if ( nextFrame > 1 ) then
		--We have at least one aura displayed
		local numRows = math.floor((nextFrame - 2) / numPerRow) + 1; -- -2, 1 for this being the "next", not "previous" frame, 1 for 0-based math.
		self:SetHeight(self.frames[1]:GetHeight() * numRows);
		self:Show();
	else
		--Empty
		self:SetHeight(1);
		self:Hide();
	end

	for i=nextFrame, #self.frames do
		self.frames[i]:Hide();
	end
end

function PetBattleAura_OnEnter(self)
	local parent = self:GetParent();
	local isEnemy = (parent.petOwner == LE_BATTLE_PET_ENEMY);
	PetBattleAbilityTooltip_SetAura(parent.petOwner, parent.petIndex, self.auraIndex);
	if ( isEnemy ) then
		PetBattleAbilityTooltip_Show("TOPRIGHT", self, "BOTTOMLEFT", 15, 5);
	else
		PetBattleAbilityTooltip_Show("TOPLEFT", self, "BOTTOMRIGHT", -15, 5);
	end
end

function PetBattleAura_OnLeave(self)
	PetBattlePrimaryAbilityTooltip:Hide();
end

PET_BATTLE_AURA_INFO = SharedPetBattleAbilityTooltip_GetInfoTable();
function PET_BATTLE_AURA_INFO:GetAbilityID()
	local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, self.auraIndex);
	return auraID;
end

function PET_BATTLE_AURA_INFO:GetRemainingDuration()
	local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, self.auraIndex);
	return turnsRemaining;
end

function PET_BATTLE_AURA_INFO:IsInBattle()
	return true;
end

function PET_BATTLE_AURA_INFO:GetMaxHealth(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetMaxHealth(petOwner, petIndex);
end

function PET_BATTLE_AURA_INFO:GetHealth(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetHealth(petOwner, petIndex);
end

function PET_BATTLE_AURA_INFO:GetAttackStat(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetPower(petOwner, petIndex);
end

function PET_BATTLE_AURA_INFO:GetSpeedStat(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetSpeed(petOwner, petIndex);
end

function PET_BATTLE_AURA_INFO:GetState(stateID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetStateValue(petOwner, petIndex, stateID);
end

function PET_BATTLE_AURA_INFO:GetWeatherState(stateID)
	return C_PetBattles.GetStateValue(LE_BATTLE_PET_WEATHER, PET_BATTLE_PAD_INDEX, stateID);
end

function PET_BATTLE_AURA_INFO:GetPadState(stateID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetStateValue(petOwner, PET_BATTLE_PAD_INDEX, stateID);
end

function PET_BATTLE_AURA_INFO:GetPetOwner(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return petOwner;
end

function PET_BATTLE_AURA_INFO:HasAura(auraID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return PetBattleUtil_PetHasAura(petOwner, petIndex, auraID);
end

function PET_BATTLE_AURA_INFO:GetPetType(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetPetType(petOwner, petIndex);
end

function PET_BATTLE_AURA_INFO:GetUnitFromToken(target)
	if ( target == "default" ) then
		target = "auracaster";
	elseif ( target == "affected" ) then
		target = "aurawearer";
	end

	if ( target == "aurawearer" ) then
		local petOwner, petIndex = self.petOwner, self.petIndex; --The "wearer" refers to the affected pet, not the pad.
		if ( petIndex == PET_BATTLE_PAD_INDEX ) then
			petIndex = C_PetBattles.GetActivePet(petOwner);
		end
		return petOwner, petIndex;
	elseif ( target == "auracaster" ) then
		local _, _, _, _, casterOwner, casterIndex = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, self.auraIndex);
		return casterOwner, casterIndex;
	elseif ( target == "auraenemy" ) then
		local petOwner = PetBattleUtil_GetOtherPlayer(self.petOwner);
		return petOwner, C_PetBattles.GetActivePet(petOwner);
	else
		error("Unsupported token: "..tostring(target));
	end
end

function PetBattleAbilityTooltip_SetAura(petOwner, petIndex, auraIndex)
	PET_BATTLE_AURA_INFO.petOwner = petOwner;
	PET_BATTLE_AURA_INFO.petIndex = petIndex;
	PET_BATTLE_AURA_INFO.auraIndex = auraIndex;
	SharedPetBattleAbilityTooltip_SetAbility(PetBattlePrimaryAbilityTooltip, PET_BATTLE_AURA_INFO);
end

----------------------------------------------
----------Pet Battle Aura ID Tooltip----------
----------------------------------------------
PET_BATTLE_AURA_ID_INFO = SharedPetBattleAbilityTooltip_GetInfoTable();
function PET_BATTLE_AURA_ID_INFO:GetAbilityID()
	return self.auraID;
end

function PET_BATTLE_AURA_ID_INFO:IsInBattle()
	return true;
end

function PET_BATTLE_AURA_ID_INFO:GetMaxHealth(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetMaxHealth(petOwner, petIndex);
end

function PET_BATTLE_AURA_ID_INFO:GetHealth(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetHealth(petOwner, petIndex);
end

function PET_BATTLE_AURA_ID_INFO:GetAttackStat(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetPower(petOwner, petIndex);
end

function PET_BATTLE_AURA_ID_INFO:GetSpeedStat(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetSpeed(petOwner, petIndex);
end

function PET_BATTLE_AURA_ID_INFO:GetState(stateID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetStateValue(petOwner, petIndex, stateID);
end

function PET_BATTLE_AURA_ID_INFO:GetWeatherState(stateID)
	return C_PetBattles.GetStateValue(LE_BATTLE_PET_WEATHER, PET_BATTLE_PAD_INDEX, stateID);
end

function PET_BATTLE_AURA_ID_INFO:GetPadState(stateID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetStateValue(petOwner, PET_BATTLE_PAD_INDEX, stateID);
end

function PET_BATTLE_AURA_ID_INFO:GetPetOwner(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return petOwner;
end

function PET_BATTLE_AURA_ID_INFO:HasAura(auraID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return PetBattleUtil_PetHasAura(petOwner, petIndex, auraID);
end

function PET_BATTLE_AURA_ID_INFO:GetPetType(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetPetType(petOwner, petIndex);
end
function PET_BATTLE_AURA_ID_INFO:GetUnitFromToken(target)
	if ( target == "default" ) then
		target = "auracaster";
	elseif ( target == "affected" ) then
		target = "aurawearer";
	end

	if ( target == "aurawearer" ) then
		local petOwner, petIndex = self.petOwner, self.petIndex;
		if ( petIndex == PET_BATTLE_PAD_INDEX ) then --The "wearer" refers to the affected pet, not the pad.
			petIndex = C_PetBattles.GetActivePet(petOwner);
		end
		return petOwner, petIndex;
	elseif ( target == "auracaster" ) then
		return self.petOwner, self.petIndex;	--Setting by ID should only occur for auras that aren't actually on the target (such as passives). These can be considered as cast by this pet.
	elseif ( target == "auraenemy" ) then
		local petOwner = PetBattleUtil_GetOtherPlayer(self.petOwner);
		return petOwner, C_PetBattles.GetActivePet(petOwner);
	else
		error("Unsupported token: "..tostring(target));
	end
end

function PetBattleAbilityTooltip_SetAuraID(petOwner, petIndex, auraID)
	PET_BATTLE_AURA_ID_INFO.petOwner = petOwner;
	PET_BATTLE_AURA_ID_INFO.petIndex = petIndex;
	PET_BATTLE_AURA_ID_INFO.auraID = auraID;
	SharedPetBattleAbilityTooltip_SetAbility(PetBattlePrimaryAbilityTooltip, PET_BATTLE_AURA_ID_INFO);
end

----------------------------------------------
-------Pet Battle Ability Tooltip Funcs-------
----------------------------------------------
function PetBattleAbilityTooltip_Show(anchorPoint, anchorTo, relativePoint, xOffset, yOffset)
	PetBattlePrimaryAbilityTooltip:ClearAllPoints();
	PetBattlePrimaryAbilityTooltip:SetPoint(anchorPoint, anchorTo, relativePoint, xOffset, yOffset);
	PetBattlePrimaryAbilityTooltip:Show();
end

----------------------------------------------
------------Pet Battle Util Funcs-------------
----------------------------------------------
function PetBattleUtil_GetOtherPlayer(player)
	if ( player == LE_BATTLE_PET_ALLY ) then
		return LE_BATTLE_PET_ENEMY;
	elseif ( player == LE_BATTLE_PET_ENEMY ) then
		return LE_BATTLE_PET_ALLY;
	end
end

function PetBattleUtil_PetHasAura(petOwner, petIndex, auraID)
	for i=1, C_PetBattles.GetNumAuras(petOwner, petIndex) do
		local id, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(petOwner, petIndex, i);
		if ( id == auraID ) then
			return true;
		end
	end
	return false;
end

