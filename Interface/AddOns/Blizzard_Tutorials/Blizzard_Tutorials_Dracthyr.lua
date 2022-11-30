
function AddDracthyrTutorials()
	local _, raceFilename = UnitRace("Player");
	if raceFilename == "Dracthyr" then
		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_ESSENCE) then
			local class = Class_DracthyrEssenceWatcher:new();
			class:OnInitialize();
			class:StartWatching();
		end

		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_EMPOWERED) then
			local class = Class_DracthyrEmpoweredSpellWatcher:new();
			class:OnInitialize();
			class:StartWatching();
		end

		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_LOW_HEALTH) then
			local class = Class_DracthyrLowHealthWatcher:new();
			class:OnInitialize();
			class:StartWatching();
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Dracthyr Essence Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_DracthyrEssenceWatcher = class("DracthyrEssenceWatcher", Class_TutorialBase);
function Class_DracthyrEssenceWatcher:OnInitialize()
	self.questID = 64864; -- Dracthyr Essence Quest
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

function Class_DracthyrEssenceWatcher:ShowHelpTip()
	HelpTip:Show(EssencePlayerFrame, self.helpTipInfo);
end

function Class_DracthyrEssenceWatcher:StartWatching()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		C_Timer.After(0.1, function()
			self:ShowHelpTip();
		end);
	else
		EventRegistry:RegisterFrameEventAndCallback("QUEST_TURNED_IN", self.OnQuestTurnedIn, self);
	end
end

function Class_DracthyrEssenceWatcher:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_TURNED_IN", self);
end

function Class_DracthyrEssenceWatcher:OnQuestTurnedIn(questID)
	if questID == self.questID then
		EventRegistry:UnregisterFrameEventAndCallback("QUEST_TURNED_IN", self);
		self:ShowHelpTip();
	end
end

function Class_DracthyrEssenceWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_DracthyrEssenceWatcher:FinishTutorial()
	self:StopWatching();
	HelpTip:Hide(EssencePlayerFrame, TUTORIAL_DRACTHYR_ESSENCE);
end

-- ------------------------------------------------------------------------------------------------------------
-- Dracthyr Empowered Ability Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_DracthyrEmpoweredSpellWatcher = class("DracthyrEmpoweredAbilityWatcher", Class_TutorialBase);
function Class_DracthyrEmpoweredSpellWatcher:OnInitialize()
	self.questID = 64872; -- Dracthyr Empowered Quest
	self.empoweredSpellID = 357208; -- Dracthyr Empowered Spell
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

function Class_DracthyrEmpoweredSpellWatcher:UpdateHelpTipString()
	local empoweredSetting = Settings.GetSetting("empowerTapControls");
	local usingEmpoweredTap = empoweredSetting:GetValue() == 1;

	if usingEmpoweredTap then
		self.helpString = TUTORIAL_DRACTHYR_EMPOWERED_TAP;
	else
		self.helpString = TUTORIAL_DRACTHYR_EMPOWERED_HOLD;
	end
	self.helpTipInfo.text = self.helpString;
end

function Class_DracthyrEmpoweredSpellWatcher:ShowHelpTip()
	self:UpdateHelpTipString();
	self.actionButton = TutorialHelper:GetActionButtonBySpellID(self.empoweredSpellID);
	if self.actionButton then
		HelpTip:Show(self.actionButton, self.helpTipInfo);
	else
		self:FinishTutorial();
	end
end

function Class_DracthyrEmpoweredSpellWatcher:OnQuestAccepted(questID)
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

function Class_DracthyrEmpoweredSpellWatcher:OnQuestTurnedIn(questID)
	if questID == self.questID then
		self:FinishTutorial();
	end
end

function Class_DracthyrEmpoweredSpellWatcher:OnQuestRemoved(questID)
	if questID == self.questID then
		HelpTip:Hide(self.actionButton, self.helpString);
		EventRegistry:RegisterFrameEventAndCallback("QUEST_ACCEPTED", self.OnQuestAccepted, self);
	end
end

function Class_DracthyrEmpoweredSpellWatcher:OnStartEmpowerCast()
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

function Class_DracthyrEmpoweredSpellWatcher:OnStopEmpowerCast()
	if TutorialObjectivesCompleted(self.questID) then
		self:FinishTutorial();
	else
		self:ShowHelpTip();
	end
end

function Class_DracthyrEmpoweredSpellWatcher:StartWatching()
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

function Class_DracthyrEmpoweredSpellWatcher:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_ACCEPTED", self);
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_TURNED_IN", self);
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_SPELLCAST_EMPOWER_START", self);
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_SPELLCAST_EMPOWER_STOP", self);
end

function Class_DracthyrEmpoweredSpellWatcher:FinishTutorial()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_EMPOWERED, true);
	self:StopWatching();
	HelpTip:Hide(self.actionButton, self.helpString);
end

-- ------------------------------------------------------------------------------------------------------------
-- Dracthyr Low Health Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_DracthyrLowHealthWatcher = class("DracthyrLowHealthWatcher", Class_TutorialBase);
function Class_DracthyrLowHealthWatcher:OnInitialize()
	self.spellID = 361469; -- Dracthyr Living Flame Spell
	self.helpTipInfo = {
		text = TUTORIAL_DRACTHYR_SELF_CAST,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_DRACTHYR_LOW_HEALTH,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		acknowledgeOnHide = false,
	};
end

function Class_DracthyrLowHealthWatcher:StartWatching()
	EventRegistry:RegisterFrameEventAndCallback("UNIT_HEALTH", self.OnUnitHealthChanged, self);
end

function Class_DracthyrLowHealthWatcher:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_HEALTH", self);
end

local LOW_HEALTH_PERCENTAGE = 0.5;
function Class_DracthyrLowHealthWatcher:OnUnitHealthChanged(arg1)
	if arg1 == "player" then
		local isDeadOrGhost = UnitIsDeadOrGhost("player");
		local healthPercent = UnitHealth(arg1) / UnitHealthMax(arg1);
		if (not isDeadOrGhost) and healthPercent <= LOW_HEALTH_PERCENTAGE then
			self.actionButton = TutorialHelper:GetActionButtonBySpellID(self.spellID);
			local selfCastKeyModifier = GetModifiedClick("SELFCAST");
			local usingSelfCast = selfCastKeyModifier ~= "NONE";
			if usingSelfCast and self.actionButton then
				local action = self.actionButton.action or "";
				local key = GetBindingKey("ACTIONBUTTON"..action);
				-- There's a key assigned, check the combo
				if key then
					local selfCastKeyBind = selfCastKeyModifier.."-"..key;
					if GetBindingAction(selfCastKeyBind) ~= "" then
						-- something else uses this, cancel
						usingSelfCast = false;
					end
				end
			end
			if usingSelfCast then
				self.helpString = TutorialHelper:FormatString(TUTORIAL_DRACTHYR_SELF_CAST:format(selfCastKeyModifier));
				self.helpTipInfo.text = self.helpString;
				HelpTip:Show(self.actionButton, self.helpTipInfo);				
			else
				self:FinishTutorial();
			end
		elseif healthPercent >= 1.0 then
			HelpTip:Hide(self.actionButton, self.helpString);
		end
	end
end

function Class_DracthyrLowHealthWatcher:FinishTutorial()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRACTHYR_LOW_HEALTH, true);
	self:StopWatching();
	HelpTip:Hide(self.actionButton, self.helpString);
end
