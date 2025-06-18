local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;

-- ============================================================================================================
-- Map Bridge
-- ============================================================================================================
local MapBridgeDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);
function MapBridgeDataProviderMixin:OnMapChanged(...) -- override
	if self.mapChangedCallback then
		self.mapChangedCallback(...);
	end
end

function MapBridgeDataProviderMixin:SetOnMapChangedCallback(mapChangedCallback)
	self.mapChangedCallback = mapChangedCallback;
end

function MapBridgeDataProviderMixin:New()
	local t = CreateFromMixins(MapBridgeDataProviderMixin);
	WorldMapFrame:AddDataProvider(t);
	return t;
end

-- ------------------------------------------------------------------------------------------------------------
-- Intro Keyboard Mouse Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_KeyboardMouse = class("Intro_KeyboardMouse", Class_TutorialBase);
function Class_Intro_KeyboardMouse:OnInitialize()
	self.questID = TutorialData:GetFactionData().StartingQuest;
end

function Class_Intro_KeyboardMouse:CanBegin()
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_Intro_KeyboardMouse:OnBegin()	
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		TutorialManager:Finished(self:Name());
		return;
	end
	Dispatcher:RegisterEvent("CINEMATIC_START", self);
	Dispatcher:RegisterEvent("CINEMATIC_STOP", self);
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);
	self:HideScreenTutorial();
	self.LaunchTimer = C_Timer.NewTimer(4,
		function()
			self:LaunchMouseKeyboardFrame();
		end);
end

function Class_Intro_KeyboardMouse:CINEMATIC_START()
	TutorialKeyboardMouseFrame_Frame:Hide();
end

function Class_Intro_KeyboardMouse:CINEMATIC_STOP()
	TutorialKeyboardMouseFrame_Frame:Show();
end

function Class_Intro_KeyboardMouse:LaunchMouseKeyboardFrame()
	EventRegistry:RegisterCallback("TutorialKeyboardMouseFrame.Closed", self.CloseMouseKeyboardFrame, self);
	self:ShowMouseKeyboardTutorial();
	self.GlowTimer = C_Timer.NewTimer(10,
		function()
			GlowEmitterFactory:Show(KeyboardMouseConfirmButton,
			GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow)
		end);
end

function Class_Intro_KeyboardMouse:CloseMouseKeyboardFrame()
	TutorialManager:Finished(self:Name());
end

function Class_Intro_KeyboardMouse:QUEST_DETAIL(logindex, questID)
	EventRegistry:UnregisterCallback("TutorialKeyboardMouseFrame.Closed", self);
	self.earlyExit = true;
	TutorialManager:Finished(self:Name());
end

function Class_Intro_KeyboardMouse:OnInterrupt(interruptedBy)
	self:HideMouseKeyboardTutorial();
	TutorialManager:Finished(self:Name());
end

function Class_Intro_KeyboardMouse:OnComplete()
	if self.LaunchTimer then
		self.LaunchTimer:Cancel();
	end
	if self.GlowTimer then
		self.GlowTimer:Cancel();
	end
	Dispatcher:UnregisterEvent("CINEMATIC_START", self);
	Dispatcher:UnregisterEvent("CINEMATIC_STOP", self);
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	EventRegistry:UnregisterCallback("TutorialKeyboardMouseFrame.Closed", self);
	self:HideMouseKeyboardTutorial();
	if not self.earlyExit then
		TutorialManager:Queue(Class_Intro_CameraLook.name);
	end	
end

-- ------------------------------------------------------------------------------------------------------------
-- Intro Camera Look - This shows using the mouse to look around
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CameraLook = class("Intro_CameraLook", Class_TutorialBase);
function Class_Intro_CameraLook:OnInitialize()
	self.questID = TutorialData:GetFactionData().StartingQuest;
end

function Class_Intro_CameraLook:CanBegin()
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_Intro_CameraLook:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_STARTED_TURNING", self);
	Dispatcher:RegisterEvent("PLAYER_STOPPED_TURNING", self);
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	self.playerHasLooked = false;
	local content = {text = NPEV2_INTRO_CAMERA_LOOK, icon = "newplayertutorial-icon-mouse-turn"};
	self:ShowScreenTutorial(content, nil, TutorialMainFrameMixin.FramePositions.Low);
end

function Class_Intro_CameraLook:PLAYER_STARTED_TURNING()
	self.playerHasLooked = true;
end

function Class_Intro_CameraLook:PLAYER_STOPPED_TURNING()
	if self.playerHasLooked then
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_CameraLook:QUEST_DETAIL()
	self.earlyExit = true;
	TutorialManager:Finished(self:Name());
end

function Class_Intro_CameraLook:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Intro_CameraLook:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_STARTED_TURNING", self);
	Dispatcher:UnregisterEvent("PLAYER_STOPPED_TURNING", self);
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	self:HideScreenTutorial();

	if not self.earlyExit then
		TutorialManager:Queue(Class_Intro_ApproachQuestGiver.name);
	end;
end

-- ------------------------------------------------------------------------------------------------------------
-- Intro Approach Quest Giver
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_ApproachQuestGiver = class("Intro_ApproachQuestGiver", Class_TutorialBase);
function Class_Intro_ApproachQuestGiver:OnInitialize()
	self.questID = TutorialData:GetFactionData().ShowAllUIQuest;
end

function Class_Intro_ApproachQuestGiver:CanBegin()
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_Intro_ApproachQuestGiver:OnBegin()	
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	self:ShowWalkTutorial();
	local unit = TutorialData:GetFactionData().StartingQuestGiverCreatureID;
	if (unit) then
		TutorialRangeManager:StartWatching(unit, TutorialRangeManager.Type.Unit, 5, function() TutorialManager:Finished(self:Name()); end);
	end	
end

function Class_Intro_ApproachQuestGiver:QUEST_DETAIL()
	self.earlyExit = true;
	TutorialManager:Finished(self:Name());
end

function Class_Intro_ApproachQuestGiver:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Intro_ApproachQuestGiver:OnComplete()
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	TutorialRangeManager:Shutdown();
	self:HideWalkTutorial();

	if not self.earlyExit then
		TutorialManager:Queue(Class_Intro_Interact.name);
	end;
end


-- ------------------------------------------------------------------------------------------------------------
-- Interact with Quest Giver
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_Interact = class("Intro_Interact", Class_TutorialBase);
function Class_Intro_Interact:OnInitialize()
	self.questID = TutorialData:GetFactionData().StartingQuest;
end

function Class_Intro_Interact:CanBegin()
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_Intro_Interact:OnBegin()	
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);
	Dispatcher:RegisterEvent("QUEST_ACCEPTED", self);
	if not QuestFrame:IsShown() then
		local content = {text = TutorialData:GetFactionData().StartingQuestInteractString, icon = "newplayertutorial-icon-mouse-rightbutton"};
		self:ShowScreenTutorial(content, nil, TutorialMainFrameMixin.FramePositions.Low);
	end
end

function Class_Intro_Interact:QUEST_DETAIL(logindex, questID)
	if not TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_Interact:QUEST_ACCEPTED(questID)
	if self.questID == questID then
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_Interact:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Intro_Interact:OnComplete()
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	Dispatcher:UnregisterEvent("QUEST_ACCEPTED", self);
	self:HideScreenTutorial();
end

-- ------------------------------------------------------------------------------------------------------------
-- Combat Dummy In Range - waits to see if the player is in melee or ranged combat range
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CombatDummyInRange = class("Intro_CombatDummyInRange", Class_TutorialBase);
function Class_Intro_CombatDummyInRange:OnInitialize()
	self.questID = TutorialData:GetFactionData().StartingQuest;
end

function Class_Intro_CombatDummyInRange:OnAdded()
	if C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil then
		self.readyForTurnIn = C_QuestLog.ReadyForTurnIn(self.questID);
		if self.readyForTurnIn then
			TutorialManager:Finished(self:Name());
		else
			TutorialManager:Queue(self:Name());
		end
	end
end

function Class_Intro_CombatDummyInRange:CanBegin()
	if (C_QuestLog.GetLogIndexForQuestID(self.questID)) ~= nil and (not C_QuestLog.ReadyForTurnIn(self.questID))then
		return true;
	end
	return false;
end

function Class_Intro_CombatDummyInRange:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("PLAYER_ENTER_COMBAT", self);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);

	self.targetedDummy = false;
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().StartingQuestTargetDummyCreatureID) then
		self.targetedDummy = true;
	end

	self.InRange = false;
	local unit = TutorialData:GetFactionData().StartingQuestTargetDummyCreatureID;
	if (unit) then
		if TutorialHelper:IsMeleeClass() then
			local content = {text = NPEV2_INTRO_MELEE_COMBAT, icon="newplayertutorial-icon-mouse-rightbutton"};
			self:ShowScreenTutorial(content, nil, TutorialMainFrameMixin.FramePositions.Low);
			TutorialRangeManager:StartWatching(unit, TutorialRangeManager.Type.Unit, 7, function() self.InRange = true;self:CheckFinished(); end);
		else
			local content = {text = NPEV2_INTRO_RANGED_COMBAT, icon="newplayertutorial-icon-mouse-leftbutton"};
			self:ShowScreenTutorial(content, nil, TutorialMainFrameMixin.FramePositions.Low);
			TutorialRangeManager:StartWatching(unit, TutorialRangeManager.Type.Unit, 30, function() self.InRange = true;self:CheckFinished(); end);
		end
	end
end

function Class_Intro_CombatDummyInRange:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().StartingQuestTargetDummyCreatureID) then
		self.targetedDummy = true;
		self:CheckFinished();
	end
end

function Class_Intro_CombatDummyInRange:PLAYER_ENTER_COMBAT()
	self:CheckFinished();
end

function Class_Intro_CombatDummyInRange:CheckFinished()
	if self.InRange and self.targetedDummy then
		self.success = true;
		self:HideScreenTutorial();
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_CombatDummyInRange:QUEST_REMOVED(questID)
	if questID == TutorialData:GetFactionData().StartingQuest then
		self.success = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_CombatDummyInRange:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Intro_CombatDummyInRange:OnComplete()
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("PLAYER_ENTER_COMBAT", self);
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);

	local UI_Watcher = TutorialManager:GetWatcher("UI_Watcher");
	if UI_Watcher then
		UI_Watcher:SetShown(TutorialData.UI_Elements.TARGET_FRAME, true);
	end
	if self.success then
		TutorialManager:Queue(Class_Intro_CombatTactics.name);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Intro Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CombatTactics = class("Intro_CombatTactics", Class_TutorialBase);
function Class_Intro_CombatTactics:OnInitialize()
	self.questID = TutorialData:GetFactionData().StartingQuest;
	self.playerClass = TutorialHelper:GetClass();
end

function Class_Intro_CombatTactics:OnAdded()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_CombatTactics:CanBegin()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_Intro_CombatTactics:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);

	local classData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	self.spellID = classData.firstSpellID;
	self.spellIDString = "{$"..self.spellID.."}";
	self.keyBindString = "{KB|"..self.spellID.."}";
	self:Reset();
end

function Class_Intro_CombatTactics:Reset()
	self:HidePointerTutorials();
	self:HideResourceCallout();
	self:HideAbilityPrompt();
	self.firstTime = true;

	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().StartingQuestTargetDummyCreatureID) then
		if self.playerClass == "WARRIOR" then -- warriors are the only class that can't use their ability straight away
			Dispatcher:RegisterEvent("UNIT_POWER_FREQUENT", self);
		else
			self:ShowAbilityPrompt();-- every other class can be immediatedly prompted
		end
	else
		Dispatcher:RegisterEvent("UNIT_TARGET", self);
	end
end

function Class_Intro_CombatTactics:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().StartingQuestTargetDummyCreatureID) then
		Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	end
end

function Class_Intro_CombatTactics:ACTIONBAR_SLOT_CHANGED()
	self:Reset();
end

function Class_Intro_CombatTactics:ShowResourceCallout()
	local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player", issecure());
	if not namePlatePlayer then
		return;
	end

	if not self.pointerID then
		local resourceString;
		if self.playerClass == "WARRIOR" then
			resourceString = NPEV2_RESOURCE_CALLOUT_WARRIOR;
		elseif self.playerClass == "ROGUE" or self.playerClass == "MONK" then
			resourceString = NPEV2_RESOURCE_CALLOUT_ENERGY;
		else
			return;
		end
		resourceString = TutorialHelper:FormatString(resourceString:format(self.keyBindString, self.spellIDString));
		self.pointerID = self:AddPointerTutorial(resourceString, "LEFT", namePlatePlayer, 0, 0, nil, "RIGHT");
	end
end

function Class_Intro_CombatTactics:ShowAbilityPrompt()
	if self.firstTime == false and (self.playerClass == "WARRIOR" or self.playerClass == "ROGUE") then
		-- warriors and rogues only show the very first ability prompt because their resource callout reinforces it as well
		return;
	end

	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	local classData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	local combatString;
	if self.firstTime == true then
		combatString = TutorialHelper:FormatString(classData.initialString:format(self.keyBindString, self.spellIDString));
	else
		combatString = TutorialHelper:FormatString(classData.reminderString:format(self.keyBindString, self.spellIDString));
	end

	local button = TutorialHelper:GetActionButtonBySpellID(self.spellID);
	if button then
		self.abilityPointerID = self:AddPointerTutorial(combatString, "DOWN", button, 0, 10, nil, "UP");
	end
end

function Class_Intro_CombatTactics:UNIT_SPELLCAST_SUCCEEDED(caster, spelllineID, spellID)
	if spellID == self.spellID then
	if (self.playerClass == "WARRIOR" or self.playerClass == "ROGUE") then
			-- warriors and rogues have a resource callout that reinforces ability use
			self:ShowResourceCallout();
			return;
		end

		self:HideAbilityPrompt();
		self.firstTime = false;
		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		local isUsable = IsUsableAction(button.action);
		if isUsable then
			self:ShowAbilityPrompt();
		end
	end
end

function Class_Intro_CombatTactics:UNIT_POWER_FREQUENT(unit, resource)
	-- for the intro tutorial, we only sue this for warriors to ensure they have enough rage before slamming
	local button = TutorialHelper:GetActionButtonBySpellID(self.spellID);
	if button then
		local isUsable = IsUsableAction(button.action);
		if isUsable then
			Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
			self:ShowAbilityPrompt();
		end
	end
end

function Class_Intro_CombatTactics:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.success = true;
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_CombatTactics:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialData:GetFactionData().StartingQuest;
	if questID == questIDRemoved then
		self.success = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_CombatTactics:HideResourceCallout()
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
		self.pointerID = nil;
	end
end

function Class_Intro_CombatTactics:HideAbilityPrompt()
	if self.abilityPointerID then
		self:HidePointerTutorial(self.abilityPointerID);
		self.abilityPointerID = nil;
	end
end

function Class_Intro_CombatTactics:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Intro_CombatTactics:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	self:HideResourceCallout();
	self:HideAbilityPrompt();
	self:HidePointerTutorials();

	if self.success == true then
		C_Timer.After(2, function() TutorialManager:Queue(Class_QuestCompleteHelp.name); end);
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Intro Chat
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_Chat = class("Intro_Chat", Class_TutorialBase);
function Class_Intro_Chat:OnInitialize()
	self.ShowCount = 0;
end

function Class_Intro_Chat:CanBegin()
	return IsActivePlayerNewcomer();
end

function Class_Intro_Chat:OnBegin()
	if not IsActivePlayerNewcomer() then
		TutorialManager:Finished(self:Name());
		return;
	end

	local standYourGroundCompleted = C_QuestLog.IsQuestFlaggedCompleted(TutorialData:GetFactionData().StandYourGround);
	if not standYourGroundCompleted then
		TutorialManager:Finished(self:Name());
		return;
	end

	local editBox = ChatEdit_GetActiveWindow() or ChatEdit_GetLastActiveWindow();
	if (editBox) then
		self.ShowCount = self.ShowCount + 1;
		if (self.ShowCount == 1) then
			self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_CHATFRAME2), "LEFT", editBox);
		end

		self.Elapsed = 0;
		Dispatcher:RegisterEvent("OnUpdate", self);
	end
end

function Class_Intro_Chat:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed;
	if (self.Elapsed > 10) then
		TutorialManager:Finished(self:Name());
	end
end

function Class_Intro_Chat:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Intro_Chat:OnComplete()
	Dispatcher:UnregisterEvent("OnUpdate", self);
end

-- ------------------------------------------------------------------------------------------------------------
-- Quest Complete Help
-- ------------------------------------------------------------------------------------------------------------
Class_QuestCompleteHelp = class("QuestCompleteHelp", Class_TutorialBase);
function Class_QuestCompleteHelp:OnInitialize()
	self.questID = TutorialData:GetFactionData().StartingQuest;
end

function Class_QuestCompleteHelp:CanBegin()
	return UnitLevel("player") < TutorialData.MAX_QUEST_COMPLETE_LEVEL;
end

function Class_QuestCompleteHelp:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);
	if C_QuestLog.ReadyForTurnIn(self.questID) then
		self.QuestCompleteTimer = C_Timer.NewTimer(2, function() self:ShowHelp(); end);
	end	
end

function Class_QuestCompleteHelp:ShowHelp()
	local questAnchorFrame = nil;

	-- Find the module in the Objective Tracker that contains the quest.
	local function FindQuestAnchorFrame(module)
		-- If the quest has already been found stop searching. There shouldn't be more than one in
		-- this case, but technically there could be (e.g. quests and achievements can have the
		-- same ID) and if so give priority to the first one found.
		if questAnchorFrame then
			return;
		end

		-- If the player has collapsed the Objective Tracker then expand it so the quest is visible.
		module:ForceExpand();

		questAnchorFrame = module:GetExistingBlock(self.questID);
	end
	ObjectiveTrackerFrame:ForEachModule(FindQuestAnchorFrame);

	if questAnchorFrame and questAnchorFrame:IsShown() then
		local xOffset = -40;
		local yOffset = 5;
		self:ShowPointerTutorial(NPEV2_QUEST_COMPLETE_HELP, "RIGHT", questAnchorFrame, xOffset, yOffset, "LEFT");
	-- Fallback case if the quest was untracked.
	else
		local xOffset = -40;
		local yOffset = -10;
		self:ShowPointerTutorial(NPEV2_QUEST_COMPLETE_HELP, "RIGHT", ObjectiveTrackerFrame, xOffset, yOffset, "TOPLEFT");
	end
end

function Class_QuestCompleteHelp:QUEST_COMPLETE()
	if (self.QuestCompleteTimer) then
		self.QuestCompleteTimer:Cancel()
	end
	TutorialManager:Finished(self:Name());
end

function Class_QuestCompleteHelp:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialData:GetFactionData().StartingQuest;
	if questID == questIDRemoved then
		self:HidePointerTutorials();
	end
	TutorialManager:Finished(self:Name());
end

function Class_QuestCompleteHelp:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_QuestCompleteHelp:OnComplete()
	if (self.QuestCompleteTimer) then
		self.QuestCompleteTimer:Cancel()
	end
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("QUEST_COMPLETE", self);
	self:HidePointerTutorials();
end

-- ------------------------------------------------------------------------------------------------------------
-- Use Minimap
-- ------------------------------------------------------------------------------------------------------------
Class_UseMinimap = class("UseMinimap", Class_TutorialBase);
function Class_UseMinimap:OnInitialize()
	self.showAllUIQuestID = TutorialData:GetFactionData().ShowAllUIQuest;
	self.showMinimapQuestID = TutorialData:GetFactionData().ShowMinimapQuest;
end

function Class_UseMinimap:OnAdded()
	if C_QuestLog.IsQuestFlaggedCompleted(self.showAllUIQuestID) then
		if C_QuestLog.IsQuestFlaggedCompleted(self.showMinimapQuestID) then
			TutorialManager:Finished(self:Name());
			return;
		elseif C_QuestLog.GetLogIndexForQuestID(self.showMinimapQuestID) ~= nil then
			TutorialManager:Queue(self:Name());
			return;
		end
	end
	Minimap:Hide();
	MinimapCluster:Hide();
end

function Class_UseMinimap:CanBegin()
	if C_QuestLog.IsQuestFlaggedCompleted(self.showAllUIQuestID) then
		if C_QuestLog.IsQuestFlaggedCompleted(self.showMinimapQuestID) then
			TutorialManager:Finished(self:Name());
			return false;
		elseif C_QuestLog.GetLogIndexForQuestID(self.showMinimapQuestID) ~= nil then
			return true;
		end		
	end
	return false;
end

function Class_UseMinimap:OnBegin()
	Minimap:Show();
	MinimapCluster:Show();
	self.PointerTimer = C_Timer.NewTimer(1, function() self:ShowMinimapPrompt() end);
end

function Class_UseMinimap:ShowMinimapPrompt()
	self:ShowPointerTutorial(NPEV2_TURN_MINIMAP_ON, "RIGHT", Minimap, 0, 0, nil, "RIGHT");
	self.EndTimer = C_Timer.NewTimer(12, function() TutorialManager:Finished(self:Name()); end);
end

function Class_UseMinimap:OnInterrupt(interruptedBy)
	Minimap:Show();
	MinimapCluster:Show();
	TutorialManager:Finished(self:Name());
end

function Class_UseMinimap:OnComplete()
	if self.PointerTimer then
		self.PointerTimer:Cancel();
	end
	if self.EndTimer then
		self.EndTimer:Cancel();
	end
	self:HidePointerTutorials();
end

-- ------------------------------------------------------------------------------------------------------------
-- Quest Reward Choice - Prompts the player to click on a reward item to select one
-- ------------------------------------------------------------------------------------------------------------
Class_QuestRewardChoice = class("QuestRewardChoice", Class_TutorialBase);
function Class_QuestRewardChoice:CanBegin()
	return true;
end

function Class_QuestRewardChoice:OnBegin(args)
	local areAllItemsUsable = unpack(args);
	local prompt = TutorialHelper:FormatString(NPE_QUESTREWARDCHOICE);

	if (not areAllItemsUsable) then
		prompt = TutorialHelper:FormatString(NPE_QUESTREWARDCHOCIEREDITEMS) .. prompt;
	end

	local yOffset;
	local button = QuestInfoRewardsFrameQuestInfoItem1;
	if (button) then
		yOffset = select(2, TutorialHelper:GetFrameButtonEdgeOffset(QuestFrame, button));
	end

	if (yOffset) then
		self:ShowPointerTutorial(prompt, "LEFT", QuestFrame, -15, yOffset, "TOPRIGHT");
	else
		self:ShowPointerTutorial(prompt, "LEFT", QuestFrame, -15, 0);
	end

	self.turnedInCallbackID = Dispatcher:RegisterEvent("QUEST_TURNED_IN", function() TutorialManager:Finished(self:Name()); end, true);
	self.hideCallbackID = Dispatcher:RegisterScript(QuestFrame, "OnHide", function() TutorialManager:Finished(self:Name()); end, true);
end

function Class_QuestRewardChoice:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_QuestRewardChoice:OnComplete()
	if self.turnedInCallbackID then
		Dispatcher:UnregisterEvent("QUEST_TURNED_IN", self.turnedInCallbackID);
		self.turnedInCallbackID = nil;
	end
	if self.hideCallbackID then
		Dispatcher:UnregisterScript(QuestFrame, "OnHide", self.hideCallbackID);
		self.hideCallbackID = nil;
	end
	self:HidePointerTutorials();
end

-- ------------------------------------------------------------------------------------------------------------
-- Intro Open Map - Main screen prompt to open the map
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_OpenMap = class("Intro_OpenMap", Class_TutorialBase);
function Class_Intro_OpenMap:OnInitialize()
	self.questID = TutorialData:GetFactionData().UseMapQuest;
end

function Class_Intro_OpenMap:CanBegin()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	if C_QuestLog.GetLogIndexForQuestID(self.questID) == nil then
		return false;
	end
	return true;
end

function Class_Intro_OpenMap:OnBegin()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		TutorialManager:Finished(self:Name());
		return;
	end
	if C_QuestLog.GetLogIndexForQuestID(self.questID) == nil then
		TutorialManager:Finished(self:Name());
		return;
	end

	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
	Dispatcher:RegisterScript(WorldMapFrame, "OnShow", self);

	self.success = false;
	local key = TutorialHelper:GetMapBinding();
	local content = {text = NPEV2_OPENMAP, icon = nil, keyText = key};
	self:ShowSingleKeyTutorial(content);

	self.Timer = C_Timer.NewTimer(12, function()
		TutorialManager:Finished(self:Name());		
	end);
end

function Class_Intro_OpenMap:OnShow()
	self:HideSingleKeyTutorial();
	self.success = true;
	TutorialManager:Finished(self:Name());
end

function Class_Intro_OpenMap:PLAYER_DEAD()
	self.success = false;
	TutorialManager:Finished(self:Name());
end

function Class_Intro_OpenMap:OnInterrupt(interruptedBy)
	self:HideSingleKeyTutorial();
	TutorialManager:Finished(self:Name());
end

function Class_Intro_OpenMap:CleanUp()
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	if self.Timer then
		self.Timer:Cancel()
	end
	self:HideSingleKeyTutorial();
end

function Class_Intro_OpenMap:OnComplete()
	Dispatcher:UnregisterScript(WorldMapFrame, "OnShow", self);
	self:CleanUp();
	if self.success then
		TutorialManager:Queue(Class_Intro_MapHighlights.name);
	end
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Map Pointers - This shows the map legend and the minimap legend
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_MapHighlights = class("Intro_MapHighlights", Class_TutorialBase);
function Class_Intro_MapHighlights:OnInitialize()
	self.MapID = WorldMapFrame:GetMapID();
	self.Prompt = NPEV2_MAPCALLOUTPOINT;
end

function Class_Intro_MapHighlights:CanBegin()
	return WorldMapFrame:IsShown();
end

function Class_Intro_MapHighlights:OnBegin()
	self:Display();
	self.scriptID = Dispatcher:RegisterScript(WorldMapFrame, "OnHide", function() TutorialManager:Finished(self:Name()); end, true);

	self.MapProvider = MapBridgeDataProviderMixin:New();
	self.MapProvider:SetOnMapChangedCallback(function()
		local mapID = self.MapProvider:GetMap():GetMapID();
		if (mapID ~= self.MapID) then
			self:Suppress();
		else
			self:Unsuppress();
		end
	end);
end

function Class_Intro_MapHighlights:Display()
	local tutorialData = TutorialData:GetFactionData();
	local questID = tutorialData.UseMapQuest;

	local targetPin = nil;
	local function Class_Intro_MapHighlightsPinCallback(pin)
		if targetPin ~= nil then
			return;
		end

		if pin.pinTemplate == "QuestPinTemplate" then
			if questID == pin.questID then
				targetPin = pin;
			end
		end
	end

	WorldMapFrame:ExecuteOnAllPins(Class_Intro_MapHighlightsPinCallback);

	if targetPin then
		self.MapPointerTutorialID = self:AddPointerTutorial(TutorialHelper:FormatString(self.Prompt), "UP", targetPin, 0, 0, nil);
	end
end

function Class_Intro_MapHighlights:OnSuppressed()
	TutorialPointerFrame:Hide(self.MapPointerTutorialID);
end

function Class_Intro_MapHighlights:OnUnsuppressed()
	self:Display();
end

function Class_Intro_MapHighlights:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Intro_MapHighlights:OnComplete()
	Dispatcher:UnregisterScript(WorldMapFrame, "OnHide", self.scriptID);
end


-- ------------------------------------------------------------------------------------------------------------
-- Use Quest Item - Repeatable
-- ------------------------------------------------------------------------------------------------------------
Class_UseQuestItem = class("UseQuestItem", Class_TutorialBase);
function Class_UseQuestItem:OnInitialize()
	local factionData = TutorialData:GetFactionData();
	self.useQuestItemData = factionData.UseQuestItemData;
	self.remindUseQuestItemData = factionData.RemindUseQuestItemData;
end

function Class_UseQuestItem:OnAdded()
	local useQuestItemActive = QuestUtil.IsQuestActiveButNotComplete(self.useQuestItemData.ItemQuest);
	local remindUseQuestItemActive = QuestUtil.IsQuestActiveButNotComplete(self.remindUseQuestItemData.ItemQuest);
	
	local args;
	if useQuestItemActive then
		args = self.useQuestItemData;
	elseif remindUseQuestItemActive then
		args = self.remindUseQuestItemData;
	end
	if args then
		TutorialManager:Queue(self:Name(), args);
	end
end

function Class_UseQuestItem:CanBegin()
	local useQuestItemActive = QuestUtil.IsQuestActiveButNotComplete(self.useQuestItemData.ItemQuest);
	local remindUseQuestItemActive = QuestUtil.IsQuestActiveButNotComplete(self.remindUseQuestItemData.ItemQuest);
	return (useQuestItemActive or remindUseQuestItemActive);
end

function Class_UseQuestItem:OnBegin(args)
	TutorialQuestManager:RegisterForCallbacks(self);
	self.questData = unpack(args);
	self.questID = self.questData.ItemQuest;
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	local questActive = C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil;
	if objectivesComplete or not questActive then
		TutorialManager:Finished(self:Name());
		return;
	end
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	self:StartWatchingTarget();
end

function Class_UseQuestItem:StartWatchingTarget()
	local unitGUID = UnitGUID("target");
	if unitGUID then
		local creatureID = TutorialHelper:GetCreatureIDFromGUID(unitGUID);
		local itemTargets = self.questData.ItemTargets;
		for i, target in ipairs(itemTargets) do
			if creatureID == target then
				local range = self.questData.TargetRange;
				local screenString = self.questData.ScreenTutorialStringID;
				local playerX, playerY = UnitPosition("player");
				local targetX, targetY = UnitPosition("target");
				local squaredDistance = CalculateDistanceSq(targetX, targetY, playerX, playerY);--math.pow(targetX - playerX, 2) + math.pow(targetY - playerY, 2);
				local squaredRange = math.pow(range, 2);
				if (squaredDistance >= squaredRange) then
					local content = {text = TutorialHelper:FormatString(screenString), icon = nil};
					self.PointerID = self:ShowScreenTutorial(content, nil, TutorialMainFrameMixin.FramePositions.Low);
					TutorialRangeManager:Shutdown();
					TutorialRangeManager:StartWatching(target, TutorialRangeManager.Type.Unit, range, GenerateClosure(self.InRange, self));
				else
					self:InRange();
				end
					return true;
			end
		end
	end
	return false;
end

function Class_UseQuestItem:InRange()
	self:HideScreenTutorial();
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

	local block = QuestObjectiveTracker:GetExistingBlock(self.questData.ItemQuest) or CampaignQuestObjectiveTracker:GetExistingBlock(self.questData.ItemQuest)
	if (block and block.ItemButton) then
		local pointerString = self.questData.PointerTutorialStringID;
		self:ShowPointerTutorial(TutorialHelper:FormatString(pointerString), "UP", block.ItemButton);
	end
end

function Class_UseQuestItem:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_UseQuestItem:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if spellID == self.questData.ItemSpell then
		self:StartWatchingTarget();
	end
end

function Class_UseQuestItem:UNIT_TARGET()
	if not self:StartWatchingTarget() then
		self:HidePointerTutorials();
		self:HideScreenTutorial();
	end
end

function Class_UseQuestItem:QUEST_REMOVED(questID)
	if questID == self.questID then
		TutorialManager:Finished(self:Name());
	end
end

function Class_UseQuestItem:Quest_ObjectivesComplete(questData)
	local questID = questData.QuestID;
	if questID == self.questID then
		TutorialManager:Finished(self:Name());
	end
end

function Class_UseQuestItem:OnComplete()
	TutorialQuestManager:UnregisterForCallbacks(self);
	self:HidePointerTutorials();
	self:HideScreenTutorial();
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
end

-- ------------------------------------------------------------------------------------------------------------
-- Change Equipment
-- ------------------------------------------------------------------------------------------------------------
Class_ChangeEquipment = class("ChangeEquipment", Class_TutorialBase);
function Class_ChangeEquipment:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_ChangeEquipment:CanBegin(args)
	return true;
end

function Class_ChangeEquipment:OnBegin(args)
	self.data = unpack(args);
	if (MerchantFrame:IsVisible()) then
		self:Interrupt(self);
		return;
	end

	Dispatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
	Dispatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA", self);
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);

	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.BagOpened, self);
	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", self.BagClosed, self);

	if (not C_Container.GetContainerItemID(self.data.Container, self.data.ContainerSlot)) then
		TutorialManager:Finished(self:Name());
		return;
	end

	self:Reset();
end

function Class_ChangeEquipment:PLAYER_DEAD()
	TutorialManager:Finished(self:Name());
end

function Class_ChangeEquipment:ZONE_CHANGED_NEW_AREA()
	TutorialManager:Finished(self:Name());
end

function Class_ChangeEquipment:Reset()
	self.success = false;
	TutorialDragButton:Hide();
	self:HidePointerTutorials();
	self:PrepBags();
end

function Class_ChangeEquipment:PrepBags()
	-- Dirty hack to make sure all bags are closed
	TutorialHelper:CloseAllBags();
	self.allBagsOpened = false;
	TutorialDragButton:Hide();

	self.Timer = C_Timer.NewTimer(0.1, function()
		local key = TutorialHelper:GetBagBinding();
		local tutorialString = TutorialHelper:FormatString(string.format(NPEV2_SHOW_BAGS, key))
		self:ShowPointerTutorial(tutorialString, "DOWN", MainMenuBarBackpackButton, 0, 0);
	end);
end

-- for this tutorial, all the bags need to be opened
function Class_ChangeEquipment:OpenAllBags()
	self.allBagsOpened = true;
	TutorialHelper:OpenAllBags();

	C_Timer.NewTimer(0.1, function()
		self:ShowCharacterSheetPrompt();
	end);
end

function Class_ChangeEquipment:BagOpened()
	if not self.allBagsOpened then
		self.allBagsOpened = true;

		self.Timer = C_Timer.NewTimer(0.1, function()
			self:OpenAllBags();
		end);
	end
end

function Class_ChangeEquipment:BagClosed()
	if self.success then
		TutorialManager:Finished(self:Name());
		return;
	end
	self:Reset();
end

function Class_ChangeEquipment:ShowCharacterSheetPrompt()
	if (CharacterFrame:IsVisible()) then
		self:CharacterSheetOpened();
		return;
	end
	EventRegistry:RegisterCallback("CharacterFrame.Show", self.CharacterSheetOpened, self);

	local key = TutorialHelper:GetCharacterBinding();
	self:ShowPointerTutorial(TutorialHelper:FormatString(string.format(NPEV2_OPENCHARACTERSHEET, key)), "DOWN", CharacterMicroButton, 0, 0);
end

function Class_ChangeEquipment:CharacterSheetOpened()
	EventRegistry:RegisterCallback("CharacterFrame.Hide", self.CharacterSheetClosed, self);
	self:HidePointerTutorials();

	if self:CheckReady() then
		self.AnimTimer = C_Timer.NewTimer(0.1, function()
			self:StartAnimation();
		end);
		return;
	end
	self:Reset();
end

function Class_ChangeEquipment:CharacterSheetClosed()
	EventRegistry:UnregisterCallback("CharacterFrame.Hide", self);

	if self.success then
		TutorialManager:Finished(self:Name());
		return;
	end
	self:Reset();
end

function Class_ChangeEquipment:CheckReady()
	local bagsReady = IsAnyBagOpen();
	local characterSheetReady = CharacterFrame:IsVisible();
	return bagsReady and characterSheetReady;
end

function Class_ChangeEquipment:PLAYER_EQUIPMENT_CHANGED()
	local item = Item:CreateFromItemLink(self.data.ItemLink);
	local itemID = item:GetItemID();

	if (GetInventoryItemID("player", self.data.CharacterSlot) == itemID) then
		-- the player successfully equipped the item
		Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
		self.success = true;
		TutorialDragButton:Hide();
		self.animationPlaying = false;

		if CharacterFrame:IsVisible() and self.destFrame then
			self:ShowPointerTutorial(NPEV2_SUCCESSFULLY_EQUIPPED, "LEFT", self.destFrame);

			EventRegistry:RegisterCallback("CharacterFrame.Hide", self.CharacterSheetClosed, self);

			self.EquipmentChangedTimer = C_Timer.NewTimer(8, function()
				TutorialManager:Finished(self:Name());
			end);
		else
			TutorialManager:Finished(self:Name());
		end
	end
end

function Class_ChangeEquipment:StartAnimation()
	if not self.data then
		TutorialManager:Finished(self:Name());
		return;
	end

	self.originFrame = TutorialHelper:GetItemContainerFrame(self.data.Container, self.data.ContainerSlot);

	local Slot = {
		[1]	 = "CharacterHeadSlot",
		[2]	 = "CharacterNeckSlot",
		[3]	 = "CharacterShoulderSlot",
		[4]	 = "CharacterShirtSlot",
		[5]	 = "CharacterChestSlot",
		[6]	 = "CharacterWaistSlot",
		[7]	 = "CharacterLegsSlot",
		[8]	 = "CharacterFeetSlot",
		[9]	 = "CharacterWristSlot",
		[10] = "CharacterHandsSlot",
		[11] = "CharacterFinger0Slot",
		[12] = "CharacterFinger0Slot",
		[13] = "CharacterTrinket0Slot",
		[14] = "CharacterTrinket1Slot",
		[15] = "CharacterBackSlot",
		[16] = "CharacterMainHandSlot",
		[17] = "CharacterSecondaryHandSlot",
	}

	self.destFrame = nil;
	local slotTarget = Slot[self.data.CharacterSlot];
	if slotTarget then
		self.destFrame = _G[Slot[self.data.CharacterSlot]];
	end

	if self.originFrame and self.destFrame then
		self.newItemPointerID = self:AddPointerTutorial(NPEV2_DRAG_TO_EQUIP, "DOWN", self.originFrame, 0, 0);

		TutorialDragButton:Show(self.originFrame, self.destFrame);
		self.animationPlaying = true;
	end
end

function Class_ChangeEquipment:UpdateItemContainerAndSlotInfo()
	local item = Item:CreateFromItemLink(self.data.ItemLink);
	local currentItemID = item:GetItemID();

	if itemInfo and itemInfo[10] == currentItemID then
		-- nothing in the inventory changed that effected the current tutorial
	else
		-- the origin has changed
		local itemFrame = nil;

		local itemFound = false;
		for containerIndex = Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots do
			local slots = C_Container.GetContainerNumSlots(containerIndex);
			if (slots > 0) then
				for slotIndex = 1, slots do
					local itemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex);
					local itemID = itemInfo and itemInfo.itemID;
					if itemID and itemID == currentItemID then
						self.data.Container = containerIndex;
						self.data.ContainerSlot = slotIndex;
						itemFound = true;
						break;
					end
				end
			end
		end
		if not itemFound then
			-- somehow the item is gone from our containers, maybe it was sold or already equipped
			self.data = nil;
		end
	end
end

function Class_ChangeEquipment:UpdateDragOrigin()
	if itemInfo and itemInfo[10] == currentItemID then
		-- nothing in the inventory changed that effected the current tutorial
	else
		self:UpdateItemContainerAndSlotInfo()
		if self.data then
			local itemFrame = TutorialHelper:GetItemContainerFrame(self.data.Container, self.data.ContainerSlot);
			self:HidePointerTutorials();
			if itemFrame then
				self:StartAnimation();
			else
				TutorialManager:Finished(self:Name());
			end
		end
	end
end

function Class_ChangeEquipment:BAG_UPDATE_DELAYED()
	-- check to see if the player moved the item being tutorialized
	self:UpdateItemContainerAndSlotInfo()
	if self.data then
		if self.animationPlaying == true then
			self:UpdateDragOrigin();
		end
	else
		-- for some reason, the item is gone.  maybe the player sold it
		TutorialManager:Finished(self:Name());
	end
end

function Class_ChangeEquipment:OnInterrupt()
	TutorialManager:Finished(self:Name());
end

function Class_ChangeEquipment:OnComplete()
	TutorialDragButton:Hide();
	self:HidePointerTutorials();
	self.originFrame = nil;
	self.destFrame = nil;
	self.animationPlaying = false;

	self.data = nil;

	if self.EquipmentChangedTimer then
		self.EquipmentChangedTimer:Cancel();
	end

	if self.AnimTimer then
		self.AnimTimer:Cancel();
		self.AnimTimer = nil;
	end

	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);
	EventRegistry:UnregisterCallback("ContainerFrame.CloseBag", self);
	EventRegistry:UnregisterCallback("CharacterFrame.Show", self);
	EventRegistry:UnregisterCallback("CharacterFrame.Hide", self);
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	Dispatcher:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", self);
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	Dispatcher:UnregisterEvent("ZONE_CHANGED_NEW_AREA", self);
end

-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics = class("EnhancedCombatTactics", Class_TutorialBase);
function Class_EnhancedCombatTactics:OnInitialize()
	self.questID = TutorialData:GetFactionData().EnhancedCombatTacticsQuest;
end

function Class_EnhancedCombatTactics:OnAdded()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		TutorialManager:Finished(self:Name());
		return;
	end
	if C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil then
		C_Timer.After(1.0, function()
			TutorialManager:Queue(self:Name());
		end);
	end
end

function Class_EnhancedCombatTactics:CanBegin()
	local questComplete = C_QuestLog.IsQuestFlaggedCompleted(self.questID);
	if questComplete then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return (C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil);
end

function Class_EnhancedCombatTactics:OnBegin()
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);

	local playerClass = TutorialHelper:GetClass();

	self.completed = false;
	if playerClass == "WARRIOR" then		
		TutorialManager:Finished(self:Name());
		TutorialManager:Queue(Class_EnhancedCombatTactics_Warrior.name);
	elseif playerClass == "ROGUE" then
		TutorialManager:Finished(self:Name());
		TutorialManager:Queue(Class_EnhancedCombatTactics_Rogue.name);
	elseif playerClass == "PRIEST" or playerClass == "WARLOCK" or playerClass == "DRUID" then
		TutorialManager:Finished(self:Name());
		TutorialManager:Queue(Class_EnhancedCombatTactics_UseDoTs.name);
	elseif playerClass == "SHAMAN" or playerClass == "MAGE" then
		TutorialManager:Finished(self:Name());
		TutorialManager:Queue(Class_EnhancedCombatTactics_Ranged.name);
	elseif playerClass == "HUNTER" or playerClass == "MONK" then
		self.completed = true;
		-- Hunters and Monks do not have an Enhanced Combat Tutorial
		TutorialManager:Finished(self:Name());
	else
		self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
		Dispatcher:RegisterEvent("UNIT_TARGET", self);
		Dispatcher:RegisterEvent("QUEST_REMOVED", self);
		Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	end
end

function Class_EnhancedCombatTactics:IsSpellOnActionBar(spellID, warningString, spellbookString)
	local button = TutorialHelper:GetActionButtonBySpellID(spellID);
	if button then
		return true;
	end
	TutorialManager:Queue(Class_AddSpellToActionBarService.name, spellID, warningString, spellbookString);
	return false;
end

function Class_EnhancedCombatTactics:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().EnhancedCombatTacticsCreatureID) then
		--check for the builder spell on the action bar
		if not self:IsSpellOnActionBar(self.combatData.resourceBuilderSpellID, self.combatData.warningBuilderString, NPEV2_SPELLBOOK_ADD_SPELL) then
			return;
		end;

		--check for the spender spell on the action bar
		if not self:IsSpellOnActionBar(self.combatData.resourceSpenderSpellID, self.combatData.warningSpenderString, NPEV2_SPELLBOOK_ADD_SPELL) then
			return;
		end;

		if (self.builderPointerID == nil) and (self.spenderPointerID == nil) then
			self:ShowBuilderPrompt();
		end
		Dispatcher:RegisterEvent("UNIT_POWER_FREQUENT", self);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	else
		self:HideScreenTutorial();
		self:HideSpenderPrompt();
		self:HideBuilderPrompt();
		self:HidePointerTutorials();

		Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
		Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	end
end

function Class_EnhancedCombatTactics:ACTIONBAR_SLOT_CHANGED()
	if self.callback then
		self.callback();
	end
end

function Class_EnhancedCombatTactics:ShowBuilderPrompt()
	self.callback = GenerateClosure(self.ShowBuilderPrompt, self);
	if self.builderPointerID then
		return;
	end
	self:HideSpenderPrompt();

	self.spellID = self.combatData.resourceBuilderSpellID;
	local button = TutorialHelper:GetActionButtonBySpellID(self.spellID);
	local keyBindString = "{KB|"..self.combatData.resourceBuilderSpellID.."}";
	local builderSpellString = "{$"..self.combatData.resourceBuilderSpellID.."}";
	local tutorialString = self.combatData.builderString:format(keyBindString, builderSpellString);
	if button then
		self.builderPointerID = self:AddPointerTutorial(TutorialHelper:FormatString(tutorialString), "DOWN", button, 0, 10, nil, "DOWN");
	else
		self:HideBuilderPrompt();
	end
end

function Class_EnhancedCombatTactics:HideBuilderPrompt()
	if self.builderPointerID then
		self:HidePointerTutorial(self.builderPointerID);
		self.builderPointerID = nil;
	end
end

function Class_EnhancedCombatTactics:ShowSpenderPrompt()
	self.callback = GenerateClosure(self.ShowSpenderPrompt, self);
	if self.spenderPointerID then
		return;
	end
	self:HideBuilderPrompt();

	self.spellID = self.combatData.resourceSpenderSpellID;
	local button = TutorialHelper:GetActionButtonBySpellID(self.spellID);
	local keyBindString = "{KB|"..self.combatData.resourceSpenderSpellID.."}";
	local spenderSpellIDString = "{$"..self.combatData.resourceSpenderSpellID.."}";
	local tutorialString = self.combatData.spenderString:format(keyBindString, spenderSpellIDString);
	if button then
		self.spenderPointerID = self:AddPointerTutorial(TutorialHelper:FormatString(tutorialString), "DOWN", button, 0, 10, nil, "DOWN");
	else
		self:HideSpenderPrompt();
	end
end

function Class_EnhancedCombatTactics:HideSpenderPrompt()
	if self.spenderPointerID then
		self:HidePointerTutorial(self.spenderPointerID);
		self.spenderPointerID = nil;
	end
end

function Class_EnhancedCombatTactics:UNIT_POWER_FREQUENT(unit, _resource)
	local resourceGateAmount = self.combatData.resourceGateAmount;
	local resource = UnitPower("player", self.combatData.resource);
	if resource < resourceGateAmount then
		self:ShowBuilderPrompt();
	elseif resource >= resourceGateAmount then
		self:ShowSpenderPrompt();
	end
end

function Class_EnhancedCombatTactics:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
	if unitID == "player" then
		if spellID == self.combatData.resourceSpenderSpellID then
			self:HideSpenderPrompt();
		elseif spellID == self.combatData.resourceBuilderSpellID then
			self:HideBuilderPrompt();
		end
		self:HideScreenTutorial();
	end
end

function Class_EnhancedCombatTactics:OnInterrupt(interruptedBy)
	self.completed = false;
	TutorialManager:Finished(self:Name());
end

function Class_EnhancedCombatTactics:CleanUp()
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("QUEST_LOG_UPDATE", self);

	self:HidePointerTutorials();
	self:HideScreenTutorial();

	if self.completed == true then
		TutorialManager:StartWatcher(Class_LowHealthWatcher.name);
	end
end

function Class_EnhancedCombatTactics:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	self:CleanUp();
end

-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics For Warrior
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_Warrior = class("EnhancedCombatTactics_Warrior", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_Warrior:OnInitialize()
	self.questID = TutorialData:GetFactionData().EnhancedCombatTacticsQuest;
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
end

function Class_EnhancedCombatTactics_Warrior:OnAdded()
end

function Class_EnhancedCombatTactics_Warrior:CanBegin()
	return true;
end

function Class_EnhancedCombatTactics_Warrior:OnBegin()
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
end

function Class_EnhancedCombatTactics_Warrior:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().EnhancedCombatTacticsCreatureID) then
		--check for the builder spell on the action bar
		if not self:IsSpellOnActionBar(self.combatData.resourceBuilderSpellID, self.combatData.warningBuilderString, NPEV2_SPELLBOOK_ADD_SPELL) then
			return;
		end;

		--check for the spender spell on the action bar
		if not self:IsSpellOnActionBar(self.combatData.resourceSpenderSpellID, self.combatData.warningSpenderString, NPEV2_SPELLBOOK_ADD_SPELL) then
			return;
		end;

		self:ShowBuilderPrompt();
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	else
		self:HidePointerTutorials();
		self:HideScreenTutorial();

		self.builderPointerID = nil;
		self.spenderPointerID = nil;

		Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
		Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	end
end

function Class_EnhancedCombatTactics_Warrior:UNIT_TARGETABLE_CHANGED()
	Dispatcher:UnregisterEvent("UNIT_TARGETABLE_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
end

function Class_EnhancedCombatTactics_Warrior:UNIT_POWER_FREQUENT(unit, _resource)
	local resourceGateAmount = self.combatData.resourceGateAmount;
	local resource = UnitPower("player", self.combatData.resource);

	if resource >= resourceGateAmount then
		self:ShowSpenderPrompt();
	end
end

function Class_EnhancedCombatTactics_Warrior:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
	if unitID == "player" then
		self:HideScreenTutorial();
		self:HideBuilderPrompt();
		self:HideSpenderPrompt();
		self:HidePointerTutorials();

		if self.combatData.resourceBuilderSpellID == spellID then
			Dispatcher:RegisterEvent("UNIT_POWER_FREQUENT", self);-- now register so we can use RAGE
			Dispatcher:RegisterEvent("UNIT_TARGETABLE_CHANGED", self);
			Dispatcher:UnregisterEvent("UNIT_TARGET", self);
		end
	end
end

function Class_EnhancedCombatTactics_Warrior:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics_Warrior:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics_Warrior:OnInterrupt(interruptedBy)
	self.completed = false;
	TutorialManager:Finished(self:Name());
end

function Class_EnhancedCombatTactics_Warrior:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_TARGETABLE_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics For Rogue
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_Rogue = class("EnhancedCombatTactics_Rogue", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_Rogue:OnInitialize()
	self.questID = TutorialData:GetFactionData().EnhancedCombatTacticsQuest;
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
end

function Class_EnhancedCombatTactics_Rogue:OnAdded()
end

function Class_EnhancedCombatTactics_Rogue:CanBegin()
	return true;
end

function Class_EnhancedCombatTactics_Rogue:OnBegin()
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);

	self.resourceGateAmount = self.combatData.resourceGateAmount;
end

function Class_EnhancedCombatTactics_Rogue:UNIT_TARGET()
	if self.IsStealthed() then
		return;
	end
	Class_EnhancedCombatTactics.UNIT_TARGET(self);
end

function Class_EnhancedCombatTactics:UPDATE_SHAPESHIFT_FORM()
	local form = GetShapeshiftFormID();
	if form == ROGUE_STEALTH then
		self:PlayerStealthed();
		return;
	end
	self:PlayerUnstealthed();
end

function Class_EnhancedCombatTactics_Rogue:PlayerStealthed()
	self:HideBuilderPrompt();
	self:HideSpenderPrompt();
	self:HidePointerTutorials();
end

function Class_EnhancedCombatTactics_Rogue:PlayerUnstealthed()
	C_Timer.After(0.1, function()
		self:UNIT_TARGET();
	end);
end

function Class_EnhancedCombatTactics_Rogue:IsStealthed()
	local form = GetShapeshiftFormID();
	if form == ROGUE_STEALTH then
		return true;
	end
	return false;
end

function Class_EnhancedCombatTactics_Rogue:UNIT_POWER_FREQUENT(unit, resource)
	local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints);

	if comboPoints >= self.resourceGateAmount then
		self:ShowSpenderPrompt();
	else
		self:ShowBuilderPrompt();
	end
end

function Class_EnhancedCombatTactics_Rogue:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
	if unitID == "player" then
		if spellID == self.combatData.resourceSpenderSpellID then
			self:HideSpenderPrompt();
			-- the rogue tutorial teaches 3, then 4, then 5 point eviscerates, in that order
			self.resourceGateAmount = min(self.resourceGateAmount + 1, 5);
		elseif spellID == self.combatData.resourceBuilderSpellID then
			self:HideBuilderPrompt();
		end
		self:HideScreenTutorial();
	end
end

function Class_EnhancedCombatTactics_Rogue:OnInterrupt(interruptedBy)
	self.completed = false;
	TutorialManager:Finished(self:Name());
end

function Class_EnhancedCombatTactics_Rogue:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics_Rogue:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics_Rogue:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics For Classes that Use DoTs
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_UseDoTs = class("EnhancedCombatTactics_UseDoTs", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_UseDoTs:OnInitialize()
	self.questID = TutorialData:GetFactionData().EnhancedCombatTacticsQuest;
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
end

function Class_EnhancedCombatTactics_UseDoTs:OnAdded()
end

function Class_EnhancedCombatTactics_UseDoTs:CanBegin()
	return true;
end

function Class_EnhancedCombatTactics_UseDoTs:OnBegin()
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
end

function Class_EnhancedCombatTactics_UseDoTs:COMBAT_LOG_EVENT_UNFILTERED()
	local eventData = {CombatLogGetCurrentEventInfo()};

	local unitGUID = eventData[8];
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().EnhancedCombatTacticsCreatureID) then
		local spellEffect = eventData[2];
		local spenderSpellID = self.combatData.alternateResourceSpenderSpellID or self.combatData.resourceSpenderSpellID;
		if spellEffect and (spellEffect == "SPELL_AURA_APPLIED" or spellEffect == "SPELL_AURA_REFRESH") then
			local spellID = eventData[12];
			if spellID == spenderSpellID then
				Dispatcher:UnregisterEvent("UNIT_TARGET", self);
				self:ShowBuilderPrompt();
			end
		elseif spellEffect and spellEffect == "SPELL_AURA_REMOVED" then
			local spellID = eventData[12];
			if spellID == spenderSpellID then
				Dispatcher:RegisterEvent("UNIT_TARGET", self);
				self:ShowSpenderPrompt();
			end
		end
	end
end

function Class_EnhancedCombatTactics_UseDoTs:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().EnhancedCombatTacticsCreatureID) then
		--check for the builder spell on the action bar
		if not self:IsSpellOnActionBar(self.combatData.resourceBuilderSpellID, self.combatData.warningBuilderString, NPEV2_SPELLBOOK_ADD_SPELL) then
			return;
		end;

		--check for the spender spell on the action bar
		if not self:IsSpellOnActionBar(self.combatData.resourceSpenderSpellID, self.combatData.warningSpenderString, NPEV2_SPELLBOOK_ADD_SPELL) then
			return;
		end;

		self:ShowSpenderPrompt();
	else
		self:HideSpenderPrompt();
		self:HideBuilderPrompt();
		self:HideScreenTutorial();
		self:HidePointerTutorials();
	end
end

function Class_EnhancedCombatTactics_UseDoTs:OnInterrupt(interruptedBy)
	self.completed = false;
	TutorialManager:Finished(self:Name());
end

function Class_EnhancedCombatTactics_UseDoTs:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics_UseDoTs:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics_UseDoTs:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics for Ranged Classes
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_Ranged = class("EnhancedCombatTactics_Ranged", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_Ranged:OnInitialize()
	self.questID = TutorialData:GetFactionData().EnhancedCombatTacticsQuest;
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
end

function Class_EnhancedCombatTactics_Ranged:OnAdded()
end

function Class_EnhancedCombatTactics_Ranged:CanBegin()
	return true;
end

function Class_EnhancedCombatTactics_Ranged:OnBegin()
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
end

function Class_EnhancedCombatTactics_Ranged:AtCloseRange()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:ShowSpenderPrompt();
end

function Class_EnhancedCombatTactics_Ranged:StartRangedWatcher()
	local unit = TutorialData:GetFactionData().EnhancedCombatTacticsOverrideCreatureID;
	if (unit) then
		TutorialRangeManager:StartWatching(unit, TutorialRangeManager.Type.Unit, 6, function() self:AtCloseRange(); end, TutorialRangeManager.Mode.Any, TutorialData:GetFactionData().EnhancedCombatTacticsQuest);
	end
end

function Class_EnhancedCombatTactics_Ranged:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialData:GetFactionData().EnhancedCombatTacticsCreatureID) then
		--check for the builder spell on the action bar
		if not self:IsSpellOnActionBar(self.combatData.resourceBuilderSpellID, self.combatData.warningBuilderString, NPEV2_SPELLBOOK_ADD_SPELL) then
			return;
		end;

		--check for the spender spell on the action bar
		if not self:IsSpellOnActionBar(self.combatData.resourceSpenderSpellID, self.combatData.warningSpenderString, NPEV2_SPELLBOOK_ADD_SPELL) then
			return;
		end;

		self:ShowBuilderPrompt();
		self:StartRangedWatcher();
	else
		self:HideScreenTutorial();
		self:HideSpenderPrompt();
		self:HideBuilderPrompt();
		self:HidePointerTutorials();
	end
end

function Class_EnhancedCombatTactics_Ranged:UNIT_TARGETABLE_CHANGED()
	Dispatcher:UnregisterEvent("UNIT_TARGETABLE_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
end

function Class_EnhancedCombatTactics_Ranged:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
	if unitID == "player" then
		if self.combatData.resourceSpenderSpellID == spellID then
			self:HideBuilderPrompt();
			self:HideSpenderPrompt();
			Dispatcher:RegisterEvent("UNIT_TARGETABLE_CHANGED", self);
		end
	end
end

function Class_EnhancedCombatTactics_Ranged:OnInterrupt(interruptedBy)
	self.completed = false;
	TutorialManager:Finished(self:Name());
end

function Class_EnhancedCombatTactics_Ranged:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics_Ranged:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EnhancedCombatTactics_Ranged:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_TARGETABLE_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Add Hunter Tame Spells
-- ------------------------------------------------------------------------------------------------------------
Class_AddHunterTameSpells = class("AddHunterTameSpells", Class_TutorialBase);
function Class_AddHunterTameSpells:OnInitialize()
	self.questID = TutorialData:GetFactionData().HunterTameTutorialQuestID;
	self.playerClass = TutorialHelper:GetClass();
end

function Class_AddHunterTameSpells:CanBegin()
	if self.playerClass ~= "HUNTER" then
		TutorialManager:Finished(self:Name());
		return false;
	end
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) or C_QuestLog.ReadyForTurnIn(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_AddHunterTameSpells:OnBegin()
	local questActive = C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil;
	if not questActive then
		TutorialManager:Finished(self:Name());
		return;
	end

	self:RequestBottomLeftActionBar();
	if not self.requested then
		if MultiBarBottomLeft:IsVisible() then
			-- the bottom left action bar is already visible
			if self:KnowsRequiredSpells() then
				-- we already know the hunter spells
				if self:CheckForSpellsOnActionBar() then
					-- and those spells are already on the action bar
					TutorialManager:Finished(self:Name());
				else
					self:AddHunterSpellsToActionBar();
				end
			else
				-- we don't know the hunter spells yet
				Dispatcher:RegisterEvent("SPELLS_CHANGED", self);
			end
		else
			-- wait for the bottom left action bar to show up
			Dispatcher:RegisterEvent("UPDATE_EXTRA_ACTIONBAR", self);
		end
	else
		-- wait for the spells to show up in the spell book
		Dispatcher:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE", self);
	end
end

function Class_AddHunterTameSpells:RequestBottomLeftActionBar()
	if not self.requested and not MultiBarBottomLeft:IsVisible() then
		-- request the bottom left action bar be shown
		Dispatcher:RegisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
		Dispatcher:RegisterEvent("UPDATE_EXTRA_ACTIONBAR", self);
		self.requested = RequestBottomLeftActionBar();
	end
end

function Class_AddHunterTameSpells:UPDATE_EXTRA_ACTIONBAR(data)
	if (MultiBarBottomLeft:IsShown() ) then
		Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	end
	if self:KnowsRequiredSpells() then
		if self:CheckForSpellsOnActionBar() then
			self:Complete();
		else
			self:AddHunterSpellsToActionBar();
		end
	end
end

function Class_AddHunterTameSpells:SPELLS_CHANGED()
	Dispatcher:UnregisterEvent("SPELLS_CHANGED", self);
	self:AddHunterSpellsToActionBar();
end

function Class_AddHunterTameSpells:ACTIONBAR_SHOW_BOTTOMLEFT()
	Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	Dispatcher:UnregisterEvent("UPDATE_EXTRA_ACTIONBAR", self);
	if self:KnowsRequiredSpells() then
		self:AddHunterSpellsToActionBar();
	end
end

function Class_AddHunterTameSpells:LEARNED_SPELL_IN_SKILL_LINE(spellID)
	if self:KnowsRequiredSpells() then
		Dispatcher:UnregisterEvent("LEARNED_SPELL_IN_SKILL_LINE", self);
		if self:CheckForSpellsOnActionBar() then
			TutorialManager:Finished(self:Name());
		else
			self:AddHunterSpellsToActionBar();
		end
	end
end

function Class_AddHunterTameSpells:CheckForSpellsOnActionBar()
	for i, spellID in ipairs(TutorialData.HunterTamePetSpells) do
		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		if not button then
			return false;
		end
	end
	return true;
end

function Class_AddHunterTameSpells:KnowsRequiredSpells()
	for i, spellID in ipairs(TutorialData.HunterTamePetSpells) do
		if not IsSpellKnown(spellID) then
			return false;
		end
	end
	return true;
end

function Class_AddHunterTameSpells:AddHunterSpellsToActionBar()
	if not self.actionBarEventID then
		self.actionBarEventID = Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	end
	for i, spellID in ipairs(TutorialData.HunterTamePetSpells) do
		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		if not button then
			TutorialManager:Queue(Class_AddSpellToActionBarService.name, spellID, nil, NPEV2_SPELLBOOK_TUTORIAL, "MultiBarBottomLeftButton");
		end
	end
	TutorialManager:Finished(self:Name());
end

function Class_AddHunterTameSpells:OnComplete()	
	Dispatcher:UnregisterEvent("SPELLS_CHANGED", self);
	Dispatcher:UnregisterEvent("UPDATE_EXTRA_ACTIONBAR", self);
	Dispatcher:UnregisterEvent("LEARNED_SPELL_IN_SKILL_LINE", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	if self.actionBarEventID then
		Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self.actionBarEventID);
		self.actionBarEventID = nil;
	end
	TutorialManager:Queue(Class_HunterTame.name);
end

-- ------------------------------------------------------------------------------------------------------------
-- Hunter Tame
-- ------------------------------------------------------------------------------------------------------------
Class_HunterTame = class("HunterTame", Class_TutorialBase);
function Class_HunterTame:OnInitialize()
	self.playerClass = TutorialHelper:GetClass();
	self.questID = TutorialData:GetFactionData().HunterTameTutorialQuestID;
end

function Class_HunterTame:CanBegin()
	if self.playerClass ~= "HUNTER" then
		TutorialManager:Finished(self:Name());
		return false;
	end
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) or C_QuestLog.ReadyForTurnIn(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_HunterTame:OnBegin()
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	self.spellsReady = true;

	if TutorialManager:GetTutorial(Class_AddHunterTameSpells.name):CheckForSpellsOnActionBar() then
		self:StartTameTutorial();
	else
		self.success = false;
		TutorialManager:Queue(Class_AddHunterTameSpells.name);
		TutorialManager:Finished(self:Name());
	end
end

function Class_HunterTame:StartTameTutorial()
	local button = TutorialHelper:GetActionButtonBySpellID(1515);
	if button then
		self:ShowPointerTutorial(NPEV2_HUNTER_TAME_ANIMAL, "DOWN", button, 0, 30, nil, "UP");
		Dispatcher:RegisterEvent("PET_STABLE_UPDATE", self);
	else
		self.success = false;
		TutorialManager:Queue(Class_AddHunterTameSpells.name);
		TutorialManager:Finished(self:Name());
	end
end

function Class_HunterTame:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialData:GetFactionData().HunterTameTutorialQuestID;
	if questID == questIDRemoved then
		self.success = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_HunterTame:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.success = true;
		TutorialManager:Finished(self:Name());
	end
end

function Class_HunterTame:PET_STABLE_UPDATE()
	self.success = true;
	TutorialManager:Finished(self:Name());
end

function Class_HunterTame:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_HunterTame:OnComplete()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:UnregisterEvent("PET_STABLE_UPDATE", self);
	Dispatcher:UnregisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	self:HidePointerTutorials();
end

-- ------------------------------------------------------------------------------------------------------------
-- Self Heal
-- ------------------------------------------------------------------------------------------------------------
Class_SelfHeal = class("SelfHeal", Class_TutorialBase);
function Class_SelfHeal:OnInitialize()
	self.tutorialSuccess = false;
end

function Class_SelfHeal:CanBegin()
	return true;
end

function Class_SelfHeal:OnBegin(args)
	if self.tutorialSuccess then
		TutorialManager:Finished(self:Name());
		return;
	end

	local inCombat = unpack(args);
	local tutorialData = TutorialData:GetFactionData();
	local button = TutorialHelper:GetActionButtonBySpellID(tutorialData.SelfHealSpellID);
	if button then
		self.inCombat = inCombat or false;
		if not self.inCombat then
			Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
			Dispatcher:RegisterEvent("PLAYER_DEAD", self);
			Dispatcher:RegisterEvent("UNIT_HEALTH", self);
			Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
			Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self);

			self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_SELF_HEAL_P1), "DOWN", button, 0, 0, nil, "DOWN");
		end
	else
		TutorialManager:Finished(self:Name());
	end
end

function Class_SelfHeal:OnInterrupt(interruptedBy)
	self.tutorialSuccess = false;
	TutorialManager:Finished(self:Name());
end

function Class_SelfHeal:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	Dispatcher:UnregisterEvent("UNIT_HEALTH", self);
	Dispatcher:UnregisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:UnregisterEvent("PLAYER_REGEN_ENABLED", self);

	self:HidePointerTutorials();
	self:HideScreenTutorial();
end

function Class_SelfHeal:UNIT_SPELLCAST_SUCCEEDED(caster, spelllineID, spellID)
	local tutorialData = TutorialData:GetFactionData();
	if spellID == tutorialData.SelfHealSpellID then
		Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

		self:HidePointerTutorials();
		local content = {text = TutorialHelper:FormatString(NPEV2_SELF_HEAL_P2), icon=nil};
		self:ShowScreenTutorial(content);

		self.tutorialSuccess = true;
		self.Timer = C_Timer.NewTimer(10, function()
			TutorialManager:Finished(self:Name());
		end);
	end
end

function Class_SelfHeal:PLAYER_DEAD()
	-- if we get interrupted by Death, start over
	TutorialManager:Finished(self:Name());
end

function Class_SelfHeal:UNIT_HEALTH(arg1)
	if arg1 == "player" then
		local health = UnitHealth(arg1);
		local maxHealth = UnitHealthMax(arg1);

		if health == maxHealth then
			TutorialManager:Finished(self:Name());
		end
	end
end

function Class_SelfHeal:PLAYER_REGEN_DISABLED()
	-- if we get interrupted by Combat, start over
	self.inCombat = true;
	TutorialManager:Finished(self:Name());
end

function Class_SelfHeal:PLAYER_REGEN_ENABLED()
	self.inCombat = false;
end


-- ============================================================================================================
-- Use Vendor
-- ============================================================================================================
Class_UseVendor = class("UseVendor", Class_TutorialBase);
function Class_UseVendor:OnInitialize()
	local tutorialData = TutorialData:GetFactionData();
	self.questID = tutorialData.UseVendorQuest;
end

function Class_UseVendor:CanBegin()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		TutorialManager:Finished(self:Name());
		return false;
	end
	return (C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil);
end

function Class_UseVendor:OnBegin()
	Dispatcher:RegisterEvent("MERCHANT_SHOW", self);

	self:HideScreenTutorial();
	self.buyTutorialComplete = false;
	self.sellTutorialComplete = false;
	self.buyBackTutorialComplete = false;

	EventRegistry:RegisterCallback("MerchantFrame.BuyBackTabShow", self.BuyBackTabHelp, self);
	EventRegistry:RegisterCallback("MerchantFrame.MerchantTabShow", self.MerchantTabHelp, self);
end

function Class_UseVendor:UpdateGreyItemPointer()
	if not self.merchantTab or self.sellTutorialComplete == true then
		if self.sellPointerID then
			self:HidePointerTutorial(self.sellPointerID);
		end
		return;
	end

	local itemFrame = nil;
	local greyItemQuality = 0;
	for containerIndex = Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots do
		local slots = C_Container.GetContainerNumSlots(containerIndex);
		if (slots > 0) then
			for slotIndex = 1, slots do
				local itemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex);
				local itemQuality = itemInfo and itemInfo.quality;
				if itemQuality == greyItemQuality then
					itemFrame = TutorialHelper:GetItemContainerFrame(containerIndex, slotIndex);
					break;
				end
			end
		end
	end

	if self.sellPointerID then
		self:HidePointerTutorial(self.sellPointerID);
	end
	if itemFrame then
		self.sellPointerID = self:AddPointerTutorial(NPEV2_SELL_GREY_ITEMS, "DOWN", itemFrame, 0, 0);
	else
		self.sellTutorialComplete = true;
	end
end

function Class_UseVendor:BAG_UPDATE_DELAYED()
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	self:UpdateGreyItemPointer();
end

function Class_UseVendor:ITEM_LOCKED()
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);
end

function Class_UseVendor:BuyBackTabHelp()
	self.buyBackTab = true;
	self.merchantTab = false;
	if self.buyPointerID then
		self:HidePointerTutorial(self.buyPointerID);
	end
	if self.sellPointerID then
		self:HidePointerTutorial(self.sellPointerID);
	end

	if self.buyBackTutorialComplete == true then
		return;
	end
	self.buyBackPointerID = self:AddPointerTutorial(TutorialHelper:FormatString(NPEV2_BUYBACK_ITEMS), "LEFT", MerchantFrame, 0, 10, nil, "LEFT");
	self.buyBackTutorialComplete = true;
end

function Class_UseVendor:MerchantTabHelp()
	self.buyBackTab = false;
	self.merchantTab = true;
	if self.buyBackPointerID then
		self:HidePointerTutorial(self.buyBackPointerID);
	end

	if not self.buyTutorialComplete then
		Dispatcher:RegisterEvent("BAG_NEW_ITEMS_UPDATED", self);
		self.buyPointerID = self:AddPointerTutorial(TutorialHelper:FormatString(NPEV2_BUY_ITEMS_FROM_VENDOR), "LEFT", MerchantItem2, 0, 0);
	end

	if not self.sellTutorialComplete then
		self.Timer = C_Timer.NewTimer(4, function()
			self:UpdateGreyItemPointer();
		end);
	end
end

function Class_UseVendor:BAG_NEW_ITEMS_UPDATED()
	--the player bought something
	Dispatcher:UnregisterEvent("BAG_NEW_ITEMS_UPDATED", self);
	self:HidePointerTutorials();
	self:UpdateGreyItemPointer();
	self.buyTutorialComplete = true;
end

function Class_UseVendor:MERCHANT_SHOW()
	if self.buyTutorialComplete == true and self.sellTutorialComplete == true and self.buyBackTutorialComplete == true then
		TutorialManager:Finished(self:Name());
		return;
	end

	Dispatcher:RegisterEvent("MERCHANT_CLOSED", self);
	Dispatcher:RegisterEvent("ITEM_LOCKED", self);
	self:MerchantTabHelp();
end

function Class_UseVendor:MERCHANT_CLOSED()
	if self.buyTutorialComplete == true and self.sellTutorialComplete == true --[[and self.buyBackTutorialComplete == true]] then
		TutorialManager:Finished(self:Name());
		return;
	end

	Dispatcher:UnregisterEvent("MERCHANT_CLOSED", self);
	self.buyBackTab = false;
	self.merchantTab = false;
	self:HidePointerTutorials();
end

function Class_UseVendor:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_UseVendor:OnComplete()
	EventRegistry:UnregisterCallback("MerchantFrame.BuyBackTabShow", self);
	EventRegistry:UnregisterCallback("MerchantFrame.MerchantTabShow", self);
	Dispatcher:UnregisterEvent("MERCHANT_SHOW", self);
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	Dispatcher:UnregisterEvent("BAG_NEW_ITEMS_UPDATED", self);
	Dispatcher:UnregisterEvent("MERCHANT_CLOSED", self);
	Dispatcher:UnregisterEvent("ITEM_LOCKED", self);
	self.buyPointerID = nil;
	self.sellPointerID = nil;
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- LFG Status Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_PromptLFG = class("PromptLFG", Class_TutorialBase);
function Class_PromptLFG:OnInitialize()
	self.questID = TutorialData:GetFactionData().LookingForGroupQuest;
end

function Class_PromptLFG:CanBegin()
	local _, instanceType = GetInstanceInfo();
	if instanceType ~= "none" then
		-- we are in a dungeon, we succeeded somehow
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_PromptLFG:OnBegin()
	if C_QuestLog.GetLogIndexForQuestID(self.questID) == nil then
		self.questRemoved = true;
		self.success = false;
		TutorialManager:Finished(self:Name());
		return;
	end

	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	self.onShowID = Dispatcher:RegisterScript(PVEFrame, "OnShow",
		function()
			C_Timer.After(0.1, function()
				self:ShowLFG()
			end);
		end,
		false);
	self:Restart();
end

function Class_PromptLFG:Restart()
	self.success = false;
	self.questRemoved = false;
	if PVEFrame:IsVisible() then
		self:ShowLFG();
	else
		ActionButtonSpellAlertManager:ShowAlert(LFDMicroButton);
		self:ShowPointerTutorial(NPEV2_LFD_INTRO, "DOWN", LFDMicroButton, 0, 10, nil, "DOWN");
	end
end

function Class_PromptLFG:QUEST_REMOVED(questIDRemoved)
	if self.questID == questIDRemoved then
		self.questRemoved = true;
		self.success = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_PromptLFG:ShowLFG()
	self.success = true;
	TutorialManager:Finished(self:Name());
end

function Class_PromptLFG:CloseTutorialElements()
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("QUEST_LOG_UPDATE", self);
	if self.onShowID then
		Dispatcher:UnregisterScript(PVEFrame, "OnShow", self.onShowID);
		self.onShowID = nil;
	end
	ActionButtonSpellAlertManager:HideAlert(LFDMicroButton);
end

function Class_PromptLFG:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_PromptLFG:OnComplete()
	self:HidePointerTutorials();
	ActionButtonSpellAlertManager:HideAlert(LFDMicroButton);
	self:CloseTutorialElements();

	if self.success == true then
		TutorialManager:Queue(Class_LookingForGroup.name);
	elseif not self.questRemoved then
		TutorialManager:Queue(self:Name());
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Looking For Group
-- ------------------------------------------------------------------------------------------------------------
Class_LookingForGroup = class("LookingForGroup", Class_TutorialBase);
function Class_LookingForGroup:OnInitialize()
end

function Class_LookingForGroup:CanBegin()
	local _, instanceType = GetInstanceInfo();
	if instanceType ~= "none" then
		-- we are in a dungeon, we succeeded somehow
		TutorialManager:Finished(self:Name());
		return false;
	end
	return true;
end

function Class_LookingForGroup:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	Dispatcher:RegisterEvent("LFG_UPDATE", self);
	Dispatcher:RegisterEvent("LFG_PROPOSAL_SHOW", self);

	EventRegistry:RegisterCallback("LFDQueueFrameList_Update.EmptyDungeonList", self.EmptyDungeonList, self);
	EventRegistry:RegisterCallback("LFDQueueFrameList_Update.DungeonListReady", self.ReadyDungeonList, self);
	EventRegistry:RegisterCallback("LFGDungeonList.DungeonEnabled", self.DungeonEnabled, self);
	EventRegistry:RegisterCallback("LFGDungeonList.DungeonDisabled", self.DungeonDisabled, self);

	self.onHideID = Dispatcher:RegisterScript(PVEFrame, "OnHide", function() self:HideLFG() end, false);
	self.questRemoved = false;
	self:UpdateDungeonPointer();
end

function Class_LookingForGroup:HideLFG()
	self:HidePointerTutorials();
	self:HideScreenTutorial();

	if self.success then
		TutorialManager:Finished(self:Name());
		return;
	elseif LFGDungeonReadyPopup:IsShown() then
		self.success = true;
		TutorialManager:Finished(self:Name());
		return;
	elseif self.inQueue then
		return;-- the player is queued for the dungeon
	end
	self.success = false;
	TutorialManager:Finished(self:Name());
end

function Class_LookingForGroup:DungeonEnabled(dungeonID)
	if LFDQueueFrameFindGroupButton:IsEnabled() then
		GlowEmitterFactory:Show(LFDQueueFrameFindGroupButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
		self:HidePointerTutorials();
	end
end

function Class_LookingForGroup:DungeonDisabled(dungeonID)
	GlowEmitterFactory:Hide(LFDQueueFrameFindGroupButton);
end

function Class_LookingForGroup:ReadyDungeonList()
	self.dungeonListReady = true;
	self:UpdateDungeonPointer();
end

function Class_LookingForGroup:EmptyDungeonList()
	self.dungeonListReady = false;
	self:UpdateDungeonPointer();
end

function Class_LookingForGroup:UpdateDungeonPointer()
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
	end

	if LFDQueueFrameSpecific:IsVisible() then
		local message;
		if self.dungeonListReady == false then
			message = NPEV2_LFD_SPECIFIC_DUNGEON_ERROR;
		else
			local tutorialDungeonChecked = LFGEnabledList[TutorialData.NPEDungeonID];
			if tutorialDungeonChecked  then
				if LFDQueueFrameFindGroupButton:IsEnabled() and not self.inQueue then
					GlowEmitterFactory:Show(LFDQueueFrameFindGroupButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
				end
			else
				message = NPEV2_LFD_SPECIFIC_DUNGEON;
			end
		end
		if message then
			self.pointerID = self:AddPointerTutorial(message, "LEFT", LFDQueueFrameSpecific, 0, 34, nil, "LEFT");
		end
	end
end

function Class_LookingForGroup:ShowDungeonSelectionInfo()
	if self.inQueue == true then
		return;
	end
	self:UpdateDungeonPointer();
end

function Class_LookingForGroup:LFG_UPDATE(args)
	local mode, subMode = GetLFGMode(LE_LFG_CATEGORY_LFD);
	if mode and mode == "queued" then
		self.inQueue = true;
	else
		self.inQueue = false;
	end
end

function Class_LookingForGroup:LFG_QUEUE_STATUS_UPDATE(args)
	Dispatcher:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	GlowEmitterFactory:Hide(LFDQueueFrameFindGroupButton);

	self:HidePointerTutorials();

	if QueueStatusButton:IsVisible() then
		self:ShowPointerTutorial(NPEV2_LFD_INFO_POINTER_MESSAGE, "DOWN", QueueStatusButton, 0, 0, nil, "DOWN");
	end
end

function Class_LookingForGroup:LFG_PROPOSAL_SHOW()
	GlowEmitterFactory:Hide(LFDQueueFrameFindGroupButton);
	self:HidePointerTutorials();
	self.success = true;
	TutorialManager:Finished(self:Name());
end

function Class_LookingForGroup:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialData:GetFactionData().LookingForGroupQuest;
	if questID == questIDRemoved then
		self.questRemoved = true;
		self.success = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_LookingForGroup:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_LookingForGroup:OnComplete()
	GlowEmitterFactory:Hide(LFDQueueFrameFindGroupButton);
	Dispatcher:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	Dispatcher:UnregisterEvent("LFG_PROPOSAL_FAILED", self);
	Dispatcher:UnregisterEvent("LFG_PROPOSAL_SHOW", self);
	Dispatcher:UnregisterEvent("LFG_UPDATE", self);
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);

	EventRegistry:UnregisterCallback("LFDQueueFrameList_Update.EmptyDungeonList", self);
	EventRegistry:UnregisterCallback("LFDQueueFrameList_Update.DungeonListReady", self);
	EventRegistry:UnregisterCallback("LFGDungeonList.DungeonEnabled", self);
	EventRegistry:UnregisterCallback("LFGDungeonList.DungeonDisabled", self);

	if self.onHideID then
		Dispatcher:UnregisterScript(PVEFrame, "OnHide", self.onHideID);
		self.onHideID = nil;
	end

	self:HidePointerTutorials();
	self:HideScreenTutorial();
	ActionButtonSpellAlertManager:HideAlert(LFDMicroButton);

	if self.success ~= true then
		if not self.questRemoved then
			TutorialManager:Queue(Class_PromptLFG.name);
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Leave Party Prompt
-- ------------------------------------------------------------------------------------------------------------
Class_LeavePartyPrompt = class("LeavePartyPrompt", Class_TutorialBase);
function Class_LeavePartyPrompt:OnInitialize()
end

function Class_LeavePartyPrompt:CanBegin()
	return true;
end

function Class_LeavePartyPrompt:OnBegin()
	self.pointerID = self:AddPointerTutorial(NPEV2_LEAVE_PARTY_PROMPT, "LEFT", PlayerFrame, 0, 0);
	C_Timer.After(12, function()
		TutorialManager:Finished(self:Name());
	end);
end

function Class_LeavePartyPrompt:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_LeavePartyPrompt:OnComplete()
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
		self.pointerID = nil;
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Mount Received
-- ------------------------------------------------------------------------------------------------------------
Class_MountReceived = class("MountReceived", Class_TutorialBase);
function Class_MountReceived:OnInitialize()
	self.questID = TutorialData:GetFactionData().GetMountQuest;
	self.mountData = TutorialData:GetFactionData().MountData;
	self.mountID = self.mountData.mountID;
end

function Class_MountReceived:CanBegin()
	return C_QuestLog.IsQuestFlaggedCompleted(self.questID);
end

function Class_MountReceived:OnBegin()
	local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(self.mountID);
	self.proceed = true;
	if isCollected then
		-- the player had already learned this mount
		self:NEW_MOUNT_ADDED();
		return;
	end

	Dispatcher:RegisterEvent("NEW_MOUNT_ADDED", self);
	local container, slot = self:CheckHasMountItem();
	if container and slot then
		-- Dirty hack to make sure all bags are closed
		TutorialHelper:CloseAllBags();
		EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.BagOpened, self);
		local key = TutorialHelper:GetBagBinding();
		local tutorialString = TutorialHelper:FormatString(string.format(NPEV2_MOUNT_TUTORIAL_INTRO, key))
		self:ShowPointerTutorial(tutorialString, "DOWN", MainMenuBarBackpackButton, 0, 10, nil, "DOWN");
	else
		-- the player doesn't have the mount
		self.proceed = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_MountReceived:CheckHasMountItem()
	local mountItem = self.mountData.mountItem;
	return TutorialHelper:FindItemInContainer(mountItem);
end

function Class_MountReceived:BagOpened(containerFrame)
	local container, slot = self:CheckHasMountItem();
	if not container or not slot then
		EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);

		-- the player doesn't have the mount
		self.proceed = false;
		TutorialManager:Finished(self:Name());
		return;
	end

	if not containerFrame:MatchesBagID(container) then
		return;
	end

	local itemFrame = TutorialHelper:GetItemContainerFrame(container, slot)
	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P2_BEGIN, "DOWN", itemFrame, 0, 10, nil, "RIGHT");
end

function Class_MountReceived:NEW_MOUNT_ADDED(data)
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);
	Dispatcher:UnregisterEvent("NEW_MOUNT_ADDED", self);

	if TutorialHelper:GetActionButtonBySpellID(self.mountData.mountID) then
		self.proceed = false;
		TutorialManager:Finished(self:Name());
		TutorialManager:Queue(Class_UseMount.name);
		return;
	end

	TutorialHelper:CloseAllBags();
	ActionButtonSpellAlertManager:ShowAlert(CollectionsMicroButton)
	self:HidePointerTutorials();

	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P2_NEW_MOUNT_ADDED, "DOWN", CollectionsMicroButton, 0, 10, nil, "DOWN");
	if not self.collectionCallbackID then
		self.collectionCallbackID = Dispatcher:RegisterFunction("ToggleCollectionsJournal", function()
			SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
			MountJournal_SelectByMountID(self.mountID);
			self.proceed = true;
			TutorialManager:Finished(self:Name());
		end, true);
	end
end

function Class_MountReceived:OnInterrupt(interruptedBy)
	self.proceed = false;
	TutorialManager:Finished(self:Name());
end

function Class_MountReceived:OnComplete()
	Dispatcher:UnregisterEvent("NEW_MOUNT_ADDED", self);

	-- This should be redundant.
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);

	if self.collectionCallbackID then
		Dispatcher:UnregisterFunction("ToggleCollectionsJournal", self.collectionCallbackID);
		self.collectionCallbackID = nil;
	end

	self:HidePointerTutorials();
	ActionButtonSpellAlertManager:HideAlert(CollectionsMicroButton);
	if self.proceed == true then
		TutorialManager:Queue(Class_AddMountToActionBar.name, self.mountData);
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Add Mount To Action Bar
-- ------------------------------------------------------------------------------------------------------------
Class_AddMountToActionBar = class("AddMountToActionBar", Class_TutorialBase);
function Class_AddMountToActionBar:OnInitialize()
	self.questID = TutorialData:GetFactionData().GetMountQuest;
end

function Class_AddMountToActionBar:CanBegin()
	return C_QuestLog.IsQuestFlaggedCompleted(self.questID);
end

function Class_AddMountToActionBar:OnBegin(args)
	self.mountData = unpack(args);
	EventRegistry:RegisterCallback("MountJournal.OnHide", self.MountJournalHide, self);
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);

	if TutorialHelper:GetActionButtonBySpellID(self.mountData.mountID) then
		TutorialManager:Finished(self:Name());
		return;
	end

	if not MountJournal or not MountJournal:IsVisible() then
		-- Mount journal was closed before this tutorial could start
		-- Can happen if MountReceived tutorial is ignored, a different tutorial is queued to start, then MountReceived is completed
		TutorialManager:Finished(self:Name());
		return;
	end

	self.Timer = C_Timer.NewTimer(0.1, function()
		self:MountJournalShow();
	end);
end

function Class_AddMountToActionBar:MountJournalShow()
	self.originButton = MountJournal_GetMountButtonByMountID(self.mountData.mountID);
	self.destButton = TutorialHelper:FindEmptyButton();
	if(self.originButton and self.destButton) then
		TutorialDragButton:Show(self.originButton, self.destButton);
	end
	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P3, "LEFT", self.originButton or MountJournal, 0, 10, nil, "LEFT");
end

function Class_AddMountToActionBar:MountJournalHide()
	TutorialManager:Finished(self:Name());
end

function Class_AddMountToActionBar:ACTIONBAR_SLOT_CHANGED(slot)
	local actionType, sID, subType = GetActionInfo(slot);

	if sID == self.mountData.mountID then
		TutorialManager:Finished(self:Name());
	else
		local nextEmptyButton = TutorialHelper:FindEmptyButton();
		if not nextEmptyButton then
			-- no more empty buttons
			TutorialManager:Finished(self:Name());
		else
			TutorialDragButton:Hide();
			self.destButton = nextEmptyButton;
			if self.originButton then
				TutorialDragButton:Show(self.originButton, self.destButton);
			end
		end
	end
end

function Class_AddMountToActionBar:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_AddMountToActionBar:OnComplete()
	EventRegistry:UnregisterCallback("MountJournal.OnHide", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	TutorialDragButton:Hide();
	self:HidePointerTutorials();

	if self.Timer then
		self.Timer:Cancel();
	end

	if TutorialHelper:GetActionButtonBySpellID(self.mountData.mountID) then
		TutorialManager:Queue(Class_UseMount.name);
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Use Mount
-- ------------------------------------------------------------------------------------------------------------
Class_UseMount = class("UseMount", Class_TutorialBase);
function Class_UseMount:OnInitialize()
end

function Class_UseMount:CanBegin()
	return not IsMounted();
end

function Class_UseMount:OnBegin()
	if IsMounted() then
		TutorialManager:Finished(self:Name());
		return;
	end
	
	Dispatcher:RegisterEvent("ACTIONBAR_UPDATE_USABLE", self);
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	local mountData = TutorialData:GetFactionData().MountData;
	self.mountID = mountData.mountID;
	self.mountSpellID = mountData.mountSpellID;
	self:TryUseMount();
end

function Class_UseMount:TryUseMount()
	local button = TutorialHelper:GetActionButtonBySpellID(self.mountID);
	if button and IsUsableAction(button.action) then
		self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P4, "DOWN", button, 0, 10, nil, "UP");
		self.Timer = C_Timer.NewTimer(12, function() TutorialManager:Finished(self:Name()); end);
	end
end

function Class_UseMount:QUEST_REMOVED(questIDRemoved)
	if (questIDRemoved == TutorialData:GetFactionData().AnUrgentMeeting) then
		TutorialManager:Finished(self:Name());
	end
end

function Class_UseMount:ACTIONBAR_UPDATE_USABLE()
	self:TryUseMount();
end

function Class_UseMount:UNIT_SPELLCAST_SUCCEEDED(caster, spelllineID, spellID)
	if self.mountSpellID == spellID then
		TutorialManager:Finished(self:Name());
	end
end

function Class_UseMount:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_UseMount:OnComplete()
	Dispatcher:UnregisterEvent("ACTIONBAR_UPDATE_USABLE", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	self:HidePointerTutorials();
	if self.Timer then
		self.Timer:Cancel();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: [Release Corpse] - Map Prompt - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------
Class_Death_ReleaseCorpse = class("Death_ReleaseCorpse", Class_TutorialBase);
function Class_Death_ReleaseCorpse:OnInitialize()
end

function Class_Death_ReleaseCorpse:CanBegin()
	return true;
end

function Class_Death_ReleaseCorpse:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_ALIVE", self);
	self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_RELEASESPIRIT), "LEFT", StaticPopup1);
end

-- PLAYER_ALIVE gets called when the player releases, not when they get back to their corpse
function Class_Death_ReleaseCorpse:PLAYER_ALIVE()
	TutorialManager:Finished(self:Name());
end

function Class_Death_ReleaseCorpse:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Death_ReleaseCorpse:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_ALIVE", self);
	self:HidePointerTutorials();
	if (UnitIsGhost("player")) then
		TutorialManager:Queue(Class_Death_MapPrompt.name);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - [Map Prompt] - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------
Class_Death_MapPrompt = class("Death_MapPrompt", Class_TutorialBase);
function Class_Death_MapPrompt:OnInitialize()
end

function Class_Death_MapPrompt:CanBegin()
	return UnitIsGhost("player");
end

function Class_Death_MapPrompt:OnBegin()
	local key = TutorialHelper:GetMapBinding();
	local content = {text = NPEV2_FINDCORPSE, icon=nil, keyText=key};
	self:ShowSingleKeyTutorial(content);

	Dispatcher:RegisterEvent("CORPSE_IN_RANGE", self);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_MapPrompt:PLAYER_UNGHOST()
	TutorialManager:Finished(self:Name());
end

function Class_Death_MapPrompt:CORPSE_IN_RANGE()
	TutorialManager:Finished(self:Name());
end

function Class_Death_MapPrompt:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Death_MapPrompt:OnComplete()
	Dispatcher:UnregisterEvent("CORPSE_IN_RANGE", self);
	Dispatcher:UnregisterEvent("PLAYER_UNGHOST", self);
	self:HideSingleKeyTutorial();
	if (UnitIsGhost("player")) then
		TutorialManager:Queue(Class_Death_ResurrectPrompt.name);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - Map Prompt - [Resurrect Prompt]
-- ------------------------------------------------------------------------------------------------------------
Class_Death_ResurrectPrompt = class("Death_ResurrectPrompt", Class_TutorialBase);
function Class_Death_ResurrectPrompt:OnInitialize()
end

function Class_Death_ResurrectPrompt:CanBegin()
	return UnitIsGhost("player");
end

function Class_Death_ResurrectPrompt:OnBegin()
	self.Timer = C_Timer.NewTimer(2, function() GlowEmitterFactory:Show(StaticPopup1Button1, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) end);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_ResurrectPrompt:PLAYER_UNGHOST()
	TutorialManager:Finished(self:Name());
end

function Class_Death_ResurrectPrompt:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_Death_ResurrectPrompt:OnComplete()
	GlowEmitterFactory:Hide(StaticPopup1Button1);
	Dispatcher:UnregisterEvent("PLAYER_UNGHOST", self);
end

-- ------------------------------------------------------------------------------------------------------------
-- Prompt the user to loot a coprpse.  Is only successful when the player closes the window and the unit is no
-- longer lootable.  If the window is closed and is still lootable, the pointer is re-invoked
-- ------------------------------------------------------------------------------------------------------------
Class_LootCorpse = class("LootCorpse", Class_TutorialBase);
function Class_LootCorpse:OnInitialize()
	self.ShowPointer = true;
	self.QuestMobCount = 0;
end

function Class_LootCorpse:OnBegin(questMobID)
	if (questMobID) then
		if (self.QuestMobCount >= 2) then
			self:Interrupt(self);
			return;
		end
		self.QuestMobID = questMobID;
	else
		self.QuestMobID = nil;
	end

	self:Display();

	Dispatcher:RegisterEvent("LOOT_CLOSED", self);
	Dispatcher:RegisterEvent("CHAT_MSG_LOOT", self);
	Dispatcher:RegisterEvent("CHAT_MSG_MONEY", self);

	if (self.ShowPointer) then
		TutorialManager:GetTutorial(Class_LootPointer.name):Begin();
	end
end

function Class_LootCorpse:CHAT_MSG_LOOT(...)
	self:Complete();
end

function Class_LootCorpse:CHAT_MSG_MONEY(...)
	self:Complete();
end

function Class_LootCorpse:LOOT_CLOSED(...)
	TutorialManager:GetTutorial(Class_LootPointer.name):Begin();
end

function Class_LootCorpse:OnSuppressed()
	self:HideScreenTutorial();
end

function Class_LootCorpse:OnUnsuppressed()
	self:Display();
end

function Class_LootCorpse:Display()
	self.Timer = C_Timer.NewTimer(15, function()
		self:Complete();
	end);

	local prompt = NPEV2_LOOT_CORPSE;
	if (self.QuestMobID) then
		prompt = NPEV2_LOOT_CORPSE_QUEST;
	end
	local content = {text = prompt, icon="newplayertutorial-icon-mouse-rightbutton"};
	self:ShowScreenTutorial(content);
end

function Class_LootCorpse:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_LootCorpse:OnComplete()
	Dispatcher:UnregisterEvent("LOOT_CLOSED", self);
	Dispatcher:UnregisterEvent("CHAT_MSG_LOOT", self);
	Dispatcher:UnregisterEvent("CHAT_MSG_MONEY", self);

	if self.Timer then
		self.Timer:Cancel();
	end

	local lootPointerTutorial = TutorialManager:GetTutorial(Class_LootPointer.name);
	if lootPointerTutorial then
		lootPointerTutorial:Complete();
	end

	if (self.QuestMobID) then
		self.QuestMobCount = self.QuestMobCount + 1;
	end

	TutorialManager:GetWatcher(Class_LootCorpseWatcher.name):LootSuccessful(self.QuestMobID);
	self.ShowPointer = false;
end

-- ------------------------------------------------------------------------------------------------------------
-- Prompts how to use the loot window the first time
-- This is managed and completed by LootCorpse
-- ------------------------------------------------------------------------------------------------------------
Class_LootPointer = class("LootPointer", Class_TutorialBase);
function Class_LootPointer:OnBegin()
	local level = UnitLevel("player");
	if (level > TutorialData.MAX_LOOT_CORPSE_LEVEL) then -- if the player comes back after level 4, don't prompt them on loot anymore
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("LOOT_OPENED", self);
	Dispatcher:RegisterEvent("LOOT_CLOSED", self);
end

--Function that handles looting from a quest object
function Class_LootPointer:LOOT_OPENED()
	local btn = LootButton1;
	if (btn) then
		self:ShowPointerTutorial(TutorialHelper:FormatString(NPE_CLICKLOOT), "RIGHT", btn, "-80", "0");
	end
end

function Class_LootPointer:LOOT_CLOSED()
	if (self.LootHelpTimer) then
		self.LootHelpTimer:Cancel();
	end
	self:HidePointerTutorials();
end

function Class_LootPointer:OnComplete()
	Dispatcher:UnregisterEvent("LOOT_OPENED", self);
	Dispatcher:UnregisterEvent("LOOT_CLOSED", self);
end
