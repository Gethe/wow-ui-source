local playerUnitToken = "player";

function AddEvokerTutorials()
	local _, classFilename = UnitClass(playerUnitToken);
	if classFilename == "EVOKER" then
		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_ESSENCE) then
			local class = Class_EvokerEssenceWatcher:new();
			class:OnInitialize();
			class:StartWatching();
		end

		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_EMPOWERED) then
			local class = Class_EvokerEmpoweredSpellWatcher:new();
			class:OnInitialize();
			class:StartWatching();
		end

		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_LOW_HEALTH) then
			local class = Class_EvokerLowHealthWatcher:new();
			class:OnInitialize();
			class:StartWatching();
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Evoker Essence Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_EvokerEssenceWatcher = class("EvokerEssenceWatcher", Class_TutorialBase);
function Class_EvokerEssenceWatcher:OnInitialize()
	self.questID = 64864; -- Evoker Essence Quest
	self.helpTipInfo = {
		text = TUTORIAL_DRACTHYR_ESSENCE,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_DRACTHYR_ESSENCE,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		acknowledgeOnHide = false,
	};
end

function Class_EvokerEssenceWatcher:ShowHelpTip()
	HelpTip:Show(EssencePlayerFrame, self.helpTipInfo);
end

function Class_EvokerEssenceWatcher:StartWatching()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		C_Timer.After(0.1, function()
			self:ShowHelpTip();
		end);
	else
		EventRegistry:RegisterFrameEventAndCallback("QUEST_TURNED_IN", self.OnQuestTurnedIn, self);
	end
end

function Class_EvokerEssenceWatcher:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_TURNED_IN", self);
end

function Class_EvokerEssenceWatcher:OnQuestTurnedIn(questID)
	if questID == self.questID then
		EventRegistry:UnregisterFrameEventAndCallback("QUEST_TURNED_IN", self);
		self:ShowHelpTip();
	end
end

function Class_EvokerEssenceWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_EvokerEssenceWatcher:FinishTutorial()
	self:StopWatching();
	HelpTip:Hide(EssencePlayerFrame, TUTORIAL_DRACTHYR_ESSENCE);
end

-- ------------------------------------------------------------------------------------------------------------
-- Evoker Empowered Ability Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_EvokerEmpoweredSpellWatcher = class("EvokerEmpoweredAbilityWatcher", Class_TutorialBase);
function Class_EvokerEmpoweredSpellWatcher:OnInitialize()
	self.questID = 64872; -- Evoker Empowered Quest
	self.empoweredSpellID = 357208; -- Evoker Empowered Spell
	self.helpTipInfo = {
		text = TUTORIAL_DRACTHYR_EMPOWERED_HOLD,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_DRACTHYR_EMPOWERED,
		buttonStyle = HelpTip.ButtonStyle.None,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		acknowledgeOnHide = false,
	};
	self:UpdateHelpTipString();
end

function Class_EvokerEmpoweredSpellWatcher:UpdateHelpTipString()
	local empoweredSetting = Settings.GetSetting("empowerTapControls");
	local usingEmpoweredTap = empoweredSetting:GetValue() == 1;

	if usingEmpoweredTap then
		self.helpString = TUTORIAL_DRACTHYR_EMPOWERED_TAP;
	else
		self.helpString = TUTORIAL_DRACTHYR_EMPOWERED_HOLD;
	end
	self.helpTipInfo.text = self.helpString;
end

function Class_EvokerEmpoweredSpellWatcher:ShowHelpTip()
	self:UpdateHelpTipString();
	self.actionButton = TutorialHelper:GetActionButtonBySpellID(self.empoweredSpellID);
	if self.actionButton then
		HelpTip:Show(self.actionButton, self.helpTipInfo);
	else
		self:FinishTutorial();
	end
end

function Class_EvokerEmpoweredSpellWatcher:OnQuestAccepted(questID)
	if questID == self.questID then
		EventRegistry:RegisterFrameEventAndCallback("QUEST_TURNED_IN", self.OnQuestTurnedIn, self);
		EventRegistry:RegisterFrameEventAndCallback("QUEST_REMOVED", self.OnQuestRemoved, self);
		EventRegistry:RegisterFrameEventAndCallback("UNIT_SPELLCAST_EMPOWER_START", self.OnStartEmpowerCast, self);
		EventRegistry:RegisterFrameEventAndCallback("UNIT_SPELLCAST_EMPOWER_STOP", function() C_Timer.After(1, GenerateClosure(self.OnStopEmpowerCast, self)) end, self);
		C_Timer.After(4.0, function()
			self:ShowHelpTip();
		end);
	end
end

function Class_EvokerEmpoweredSpellWatcher:OnQuestTurnedIn(questID)
	if questID == self.questID then
		self:FinishTutorial();
	end
end

function Class_EvokerEmpoweredSpellWatcher:OnQuestRemoved(questID)
	if questID == self.questID then
		HelpTip:Hide(self.actionButton, self.helpString);
		EventRegistry:RegisterFrameEventAndCallback("QUEST_ACCEPTED", self.OnQuestAccepted, self);
	end
end

function Class_EvokerEmpoweredSpellWatcher:OnStartEmpowerCast()
	HelpTip:Hide(self.actionButton, self.helpString);
end

local function TutorialObjectivesCompleted(questID)
	local questObjectives = C_QuestLog.GetQuestObjectives(questID);
	if questObjectives then
		local levelOneFireBreath = questObjectives[1].finished;
		local levelTwoFireBreath = questObjectives[2].finished;
		local levelThreeFireBreath = questObjectives[3].finished;
		if levelOneFireBreath and levelTwoFireBreath and levelThreeFireBreath then
			return true;
		end
	end
	return false;
end

function Class_EvokerEmpoweredSpellWatcher:OnStopEmpowerCast()
	if TutorialObjectivesCompleted(self.questID) then
		self:FinishTutorial();
	else
		self:ShowHelpTip();
	end
end

function Class_EvokerEmpoweredSpellWatcher:StartWatching()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:FinishTutorial();
	else
		local questActive = C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil;		
		if questActive then
			if TutorialObjectivesCompleted(self.questID) then
				self:FinishTutorial();
			else
				EventRegistry:RegisterFrameEventAndCallback("QUEST_TURNED_IN", self.OnQuestTurnedIn, self);
				EventRegistry:RegisterFrameEventAndCallback("QUEST_REMOVED", self.OnQuestRemoved, self);
				EventRegistry:RegisterFrameEventAndCallback("UNIT_SPELLCAST_EMPOWER_START", self.OnStartEmpowerCast, self);
				EventRegistry:RegisterFrameEventAndCallback("UNIT_SPELLCAST_EMPOWER_STOP", function() C_Timer.After(1, GenerateClosure(self.OnStopEmpowerCast, self)) end, self);
				C_Timer.After(0.1, function()
					self:ShowHelpTip();
				end);
			end
		else
			EventRegistry:RegisterFrameEventAndCallback("QUEST_ACCEPTED", self.OnQuestAccepted, self);
		end
	end
end

function Class_EvokerEmpoweredSpellWatcher:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_ACCEPTED", self);
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_TURNED_IN", self);
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_SPELLCAST_EMPOWER_START", self);
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_SPELLCAST_EMPOWER_STOP", self);
end

function Class_EvokerEmpoweredSpellWatcher:FinishTutorial()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_EMPOWERED, true);
	self:StopWatching();
	HelpTip:Hide(self.actionButton, self.helpString);
end

-- ------------------------------------------------------------------------------------------------------------
-- Evoker Low Health Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_EvokerLowHealthWatcher = class("EvokerLowHealthWatcher", Class_TutorialBase);
function Class_EvokerLowHealthWatcher:OnInitialize()
	self.spellID = 361469; -- Evoker Living Flame Spell

	self.actionButtonHelpTipInfo = {
		text = TUTORIAL_DRACTHYR_SELF_CAST,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_DRACTHYR_LOW_HEALTH,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		autoEdgeFlipping = true,
		autoHorizontalSlide = true,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		acknowledgeOnHide = false,
	};

	self.settingsHelpTipInfo = {
		text = TUTORIAL_DRACTHYR_SELF_CAST_SETTINGS,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_DRACTHYR_LOW_HEALTH,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		autoEdgeFlipping = true,
		autoHorizontalSlide = true,
		hideArrow = true,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		acknowledgeOnHide = false,
	};
end

function Class_EvokerLowHealthWatcher:StartWatching()
	EventRegistry:RegisterFrameEventAndCallback("UNIT_HEALTH", self.OnUnitHealthChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self.UpdateTutorialState, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self.UpdateTutorialState, self);
	self.selfCastChangedHandler = Settings.SetOnValueChangedCallback("PROXY_SELF_CAST", self.UpdateTutorialState, self);
	self.selfCastKeyChangedHandler = Settings.SetOnValueChangedCallback("SELFCAST", self.UpdateTutorialState, self);
end

function Class_EvokerLowHealthWatcher:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_HEALTH", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self);
	self.selfCastChangedHandler:Unregister();
	self.selfCastKeyChangedHandler:Unregister();
end

function Class_EvokerLowHealthWatcher:OnUnitHealthChanged(arg1)
	if arg1 == playerUnitToken then
		self:UpdateTutorialState();
	end
end

local LOW_HEALTH_PERCENTAGE = 0.5;
function Class_EvokerLowHealthWatcher:UpdateTutorialState()
	if not self:ShouldUpdateTutorialState() then
		return;
	end

	local selfCastSettingValue = Settings.GetValue("PROXY_SELF_CAST");
	local usingSelfCast = selfCastSettingValue == SELF_CAST_SETTING_VALUES.KEY_PRESS
						or selfCastSettingValue == SELF_CAST_SETTING_VALUES.AUTO_AND_KEY_PRESS;

	local selfCastKeyModifier = GetModifiedClick("SELFCAST");
	usingSelfCast = usingSelfCast and selfCastKeyModifier ~= "NONE";

	local actionButton = TutorialHelper:GetActionButtonBySpellID(self.spellID);
	if usingSelfCast and actionButton then
		local action = actionButton.action or "";
		local key = GetBindingKey("ACTIONBUTTON"..action);

		-- There's a key assigned, check the combo
		if key then
			local selfCastKeyBind = selfCastKeyModifier.."-"..key;
			if GetBindingAction(selfCastKeyBind) ~= "" then
				-- Something else uses this, keybind combo
				-- In this case the self cast keybind will be eaten by that other thing so we technically can't self cast right now
				usingSelfCast = false;
			end
		end
	end

	-- If we have a self cast keybind set and we have an action button with living flame assigned to it
	-- Then show the help tip on the action button saying how to self cast the spell
	if usingSelfCast and actionButton then
		self:ShowActionButtonHelpTip(actionButton, selfCastKeyModifier);
		return;
	end

	local isInCombat = UnitAffectingCombat(playerUnitToken);

	-- If we don't have a self cast keybind set and we're out of combat
	-- Then show the help tip directing the player to their settings to set a self cast keybind
	if not usingSelfCast and not isInCombat then
		self:ShowSettingsHelpTip();
		return;
	end
end

function Class_EvokerLowHealthWatcher:FinishTutorial()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_LOW_HEALTH, true);
	self:StopWatching();
	self:HideHelpTips();
end

function Class_EvokerLowHealthWatcher:ShouldUpdateTutorialState()
	if self.isShowingHelpTip then
		return true;
	end

	local isDeadOrGhost = UnitIsDeadOrGhost(playerUnitToken);
	local unitHealth = UnitHealth(playerUnitToken);
	local unitMaxHealth = UnitHealthMax(playerUnitToken);
	if unitMaxHealth == 0 then
		return false;
	end
	local healthPercent = unitHealth / unitMaxHealth;
	return not isDeadOrGhost and healthPercent <= LOW_HEALTH_PERCENTAGE;
end

function Class_EvokerLowHealthWatcher:HideHelpTips()
	if self.actionButton then
		HelpTip:Hide(self.actionButton, self.actionButtonHelpTipInfo.text);
		self.actionButton = nil;
	end

	HelpTip:Hide(MicroMenu, self.settingsHelpTipInfo.text);

	self.isShowingHelpTip = false;
end

function Class_EvokerLowHealthWatcher:ShowActionButtonHelpTip(actionButton, selfCastKeyModifier)
	self:HideHelpTips();

	self.actionButton = actionButton;
	self.actionButtonHelpTipInfo.text = TutorialHelper:FormatString(TUTORIAL_DRACTHYR_SELF_CAST:format(selfCastKeyModifier));
	HelpTip:Show(self.actionButton, self.actionButtonHelpTipInfo);
	self.isShowingHelpTip = true;
end

function Class_EvokerLowHealthWatcher:ShowSettingsHelpTip()
	self:HideHelpTips();

	HelpTip:Show(MicroMenu, self.settingsHelpTipInfo);
	self.isShowingHelpTip = true;
end