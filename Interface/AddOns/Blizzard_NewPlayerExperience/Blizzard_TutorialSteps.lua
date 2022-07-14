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
-- Generic Creature Range Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_CreatureRangeWatcher = class("CreatureRangeWatcher", Class_TutorialBase);
function Class_CreatureRangeWatcher:OnBegin(range, targets, screenString, callback)
	self.range = range;
	self.targets = targets;
	self.screenString = screenString;
	self.icon = nil;
	self.callback = callback;
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
end

function Class_CreatureRangeWatcher:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID then
		local creatureID = TutorialHelper:GetCreatureIDFromGUID(unitGUID);
		for i, target in ipairs(self.targets) do
			if creatureID == target then
				local playerX, playerY = UnitPosition("player");
				local targetX, targetY = UnitPosition("target");
				local squaredDistance = math.pow(targetX - playerX, 2) + math.pow(targetY - playerY, 2);
				local squaredRange = math.pow(self.range, 2);
				if (squaredDistance >= squaredRange) then
					local content = {text = TutorialHelper:FormatString(self.screenString), icon=self.icon};
					self.PointerID = self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
					NPE_RangeManager:Shutdown();
					NPE_RangeManager:StartWatching(creatureID, NPE_RangeManager.Type.Unit, self.range, function() self:Complete(); end);
					return;
				else
					self:Complete();
					return;
				end
			end
		end
	end
	self:HidePointerTutorials();
	self:HideScreenTutorial();
end

function Class_CreatureRangeWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_CreatureRangeWatcher:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	self.targets = nil;
	self.message = nil;
	self.range = nil;
	if self.callback then
		self.callback();
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Hide UI
-- ------------------------------------------------------------------------------------------------------------
Class_Hide_Backpack = class("Hide_Backpack", Class_TutorialBase);
function Class_Hide_Backpack:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	MainMenuBarBackpackButton:Hide();
end

function Class_Hide_Backpack:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	self:Complete();
end

function Class_Hide_Backpack:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	MainMenuBarBackpackButton:Show();
end


Class_Hide_MainMenuBar = class("Hide_MainMenuBar", Class_TutorialBase);
function Class_Hide_MainMenuBar:OnBegin()
	MainMenuBarArtFrame:Hide();
end

function Class_Hide_MainMenuBar:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_MainMenuBar:OnComplete()
	MainMenuBarArtFrame:Show();
end


Class_Hide_BagsBar = class("Hide_BagsBar", Class_TutorialBase);
function Class_Hide_BagsBar:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	MicroButtonAndBagsBar:Hide();
end

function Class_Hide_BagsBar:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	self:Complete();
end

function Class_Hide_BagsBar:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_BagsBar:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	MicroButtonAndBagsBar:Show();
end


Class_Hide_OtherMicroButtons = class("Hide_OtherMicroButtons", Class_TutorialBase);
function Class_Hide_OtherMicroButtons:OnBegin()
	GuildMicroButton:Hide();
	TalentMicroButton:Hide();
	MainMenuMicroButton:Hide();
	AchievementMicroButton:Hide();
	CollectionsMicroButton:Hide();
	QuestLogMicroButton:Hide();
	LFDMicroButton:Hide();
	EJMicroButton:Hide();
end

function Class_Hide_OtherMicroButtons:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_OtherMicroButtons:OnComplete()
	GuildMicroButton:Show();
	TalentMicroButton:Show();
	MainMenuMicroButton:Show();
	AchievementMicroButton:Show();
	CollectionsMicroButton:Show();
	QuestLogMicroButton:Show();
	LFDMicroButton:Show();
	EJMicroButton:Show();
end


Class_Hide_StoreMicroButton = class("Hide_StoreMicroButton", Class_TutorialBase);
function Class_Hide_StoreMicroButton:OnBegin()
	StoreMicroButton:Hide();
end

function Class_Hide_StoreMicroButton:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_StoreMicroButton:OnComplete()
	StoreMicroButton:Show();
end


Class_Hide_SpellbookMicroButton = class("Hide_SpellbookMicroButton", Class_TutorialBase);
function Class_Hide_SpellbookMicroButton:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	SpellbookMicroButton:Hide();
end

function Class_Hide_SpellbookMicroButton:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	self:Complete();
end

function Class_Hide_SpellbookMicroButton:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_SpellbookMicroButton:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	SpellbookMicroButton:Show();
end


Class_Hide_CharacterMicroButton = class("Hide_CharacterMicroButton", Class_TutorialBase);
function Class_Hide_CharacterMicroButton:OnBegin()
	CharacterMicroButton:Hide();
end

function Class_Hide_CharacterMicroButton:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_CharacterMicroButton:OnComplete()
	CharacterMicroButton:Show();
end


Class_Hide_TargetFrame = class("Hide_TargetFrame", Class_TutorialBase);
function Class_Hide_TargetFrame:OnBegin()
	TargetFrame:Hide();
end

function Class_Hide_TargetFrame:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_TargetFrame:OnComplete()
	TargetFrame:Show();
end


Class_Hide_StatusTrackingBar = class("Hide_StatusTrackingBar", Class_TutorialBase);
function Class_Hide_StatusTrackingBar:OnBegin()
	StatusTrackingBarManager:Hide();
end

function Class_Hide_StatusTrackingBar:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_StatusTrackingBar:OnComplete()
	StatusTrackingBarManager:Show();
end


Class_Hide_Minimap = class("Hide_Minimap", Class_TutorialBase);
function Class_Hide_Minimap:OnBegin()
	Minimap:Hide();
	MinimapCluster:Hide();
end

function Class_Hide_Minimap:ShowTutorial()
	Minimap:Show();
	MinimapCluster:Show();

	C_Timer.After(1, function()
		self:ShowPointerTutorial(NPEV2_TURN_MINIMAP_ON, "RIGHT", Minimap, 0, 0, nil, "RIGHT");
	end);

	C_Timer.After(12, function()
		self:HidePointerTutorials();
		self:Complete();
	end);
end

function Class_Hide_Minimap:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Hide_Minimap:OnComplete()
	Minimap:Show();
	MinimapCluster:Show();
end


-- ------------------------------------------------------------------------------------------------------------
-- Intro Keyboard Mouse
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_KeyboardMouse = class("Intro_KeyboardMouse", Class_TutorialBase);
function Class_Intro_KeyboardMouse:OnBegin()
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	self:HideScreenTutorial();

	C_Timer.After(4, function()
		self:LaunchMouseKeyboardFrame();
	end);
	EventRegistry:RegisterCallback("NPE_TutorialKeyboardMouseFrame.Closed", self.TutorialClosed, self);
end

function Class_Intro_KeyboardMouse:LaunchMouseKeyboardFrame()
	self:ShowMouseKeyboardTutorial();
	self.Timer = C_Timer.NewTimer(10, function() GlowEmitterFactory:Show(KeyboardMouseConfirmButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) end);
end

function Class_Intro_KeyboardMouse:QUEST_DETAIL(logindex, questID)
	EventRegistry:UnregisterCallback("NPE_TutorialKeyboardMouseFrame.Closed", self);

	NPE_TutorialKeyboardMouseFrame_Frame:HideTutorial();
	self.shortCut = true;
	self:Complete();
end

function Class_Intro_KeyboardMouse:TutorialClosed()
	self:Complete();
end

function Class_Intro_KeyboardMouse:OnInterrupt(interruptedBy)
	NPE_TutorialKeyboardMouseFrame_Frame:HideTutorial();
	self:Complete();
end

function Class_Intro_KeyboardMouse:OnComplete()
	if self.Timer then
		self.Timer:Cancel();
	end
	if not self.shortCut then
		Tutorials.Intro_CameraLook:Begin();
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Mouse Look Help - This shows using the mouse to look around
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CameraLook = class("Intro_CameraLook", Class_TutorialBase);
function Class_Intro_CameraLook:OnBegin()
	self.PlayerHasLooked = false;
	local content = {text = NPEV2_INTRO_CAMERA_LOOK, icon="newplayertutorial-icon-mouse-turn"};
	self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);

	Dispatcher:RegisterEvent("PLAYER_STARTED_TURNING", self);
	Dispatcher:RegisterEvent("PLAYER_STOPPED_TURNING", self);
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);
end

function Class_Intro_CameraLook:PLAYER_STARTED_TURNING()
	self.PlayerHasLooked = true;
end

function Class_Intro_CameraLook:PLAYER_STOPPED_TURNING()
	if self.PlayerHasLooked then
		self:Complete()
	end
end

function Class_Intro_CameraLook:QUEST_DETAIL()
	self.shortCut = true;
	self:Complete()
end

function Class_Intro_CameraLook:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Intro_CameraLook:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_STARTED_TURNING", self);
	Dispatcher:UnregisterEvent("PLAYER_STOPPED_TURNING", self);

	if not self.shortCut then
		Tutorials.Intro_ApproachQuestGiver:Begin();
	end;
end


-- ------------------------------------------------------------------------------------------------------------
-- Approach Quest Giver
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_ApproachQuestGiver = class("Intro_ApproachQuestGiver", Class_TutorialBase);
function Class_Intro_ApproachQuestGiver:OnBegin()
	self:HideScreenTutorial();
	local content = {text = TutorialHelper:GetFactionData().StartingQuestTutorialString, icon = nil};
	self:ShowWalkTutorial();

	local unit = TutorialHelper:GetFactionData().StartingQuestGiverCreatureID;
	if (unit) then
		NPE_RangeManager:StartWatching(unit, NPE_RangeManager.Type.Unit, 5, function() self:Complete(); end);
	end
end

function Class_Intro_ApproachQuestGiver:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Intro_ApproachQuestGiver:OnComplete()
	self:HideWalkTutorial();
	Tutorials.Intro_Interact:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Interact with Quest Giver
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_Interact = class("Intro_Interact", Class_TutorialBase);
function Class_Intro_Interact:OnBegin()
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);
	local content = {text = TutorialHelper:GetFactionData().StartingQuestInteractString, icon = "newplayertutorial-icon-mouse-rightbutton"};
	self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
end

function Class_Intro_Interact:QUEST_DETAIL(logindex, questID)
	local questID = TutorialHelper:GetFactionData().StartingQuest;
	if not TutorialHelper:IsQuestCompleteOrActive(questID) then
		self:Complete();
	end
end

function Class_Intro_Interact:OnInterrupt(interruptedBy)
	self:Complete();
end


-- ------------------------------------------------------------------------------------------------------------
-- Combat Dummy Range Watcher - waits to see if the player is in melee or ranged combat range
-- Used by Intro Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CombatDummyInRange = class("Intro_CombatDummyInRange", Class_TutorialBase);
function Class_Intro_CombatDummyInRange:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_ENTER_COMBAT", self);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);

	self.TargetedDummy = false;
	self.InRange = false;
	local unit = TutorialHelper:GetFactionData().StartingQuestTargetDummyCreatureID;
	if (unit) then
		if TutorialHelper:IsMeleeClass() then
			local content = {text = NPEV2_INTRO_MELEE_COMBAT, icon="newplayertutorial-icon-mouse-rightbutton"};
			self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
			NPE_RangeManager:StartWatching(unit, NPE_RangeManager.Type.Unit, 7, function() self.InRange = true;self:CheckFinished(); end);
		else
			local content = {text = NPEV2_INTRO_RANGED_COMBAT, icon="newplayertutorial-icon-mouse-leftbutton"};
			self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
			NPE_RangeManager:StartWatching(unit, NPE_RangeManager.Type.Unit, 30, function() self.InRange = true;self:CheckFinished(); end);
		end
	end
end

function Class_Intro_CombatDummyInRange:OnInterrupt(interruptedBy)
	self.interrupted = true;
	self:Complete();
end

function Class_Intro_CombatDummyInRange:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().StartingQuestTargetDummyCreatureID) then
		self.TargetedDummy = true;
		self:CheckFinished();
	end
end

function Class_Intro_CombatDummyInRange:PLAYER_ENTER_COMBAT()
	self:CheckFinished();
end

function Class_Intro_CombatDummyInRange:CheckFinished()
	if self.InRange and self.TargetedDummy then
		self:Complete();
	end
end

function Class_Intro_CombatDummyInRange:OnComplete()
	if not self.interrupted then
		Tutorials.Hide_MainMenuBar:Complete();
		Tutorials.Hide_TargetFrame:Complete();
		Tutorials.Intro_CombatTactics:Begin();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Intro Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CombatTactics = class("Intro_CombatTactics", Class_TutorialBase);
function Class_Intro_CombatTactics:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("PLAYER_LEAVE_COMBAT", self);
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);

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
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().StartingQuestTargetDummyCreatureID) then
		local playerClass = TutorialHelper:GetClass();
		if playerClass == "WARRIOR" then
			-- warriors are the only class that can't use their ability straight away
			Dispatcher:RegisterEvent("UNIT_POWER_FREQUENT", self);
		else
			-- every other class can be immediatedly prompted
			self:ShowAbilityPrompt();
		end
	else
		Dispatcher:RegisterEvent("UNIT_TARGET", self);
	end
end

function Class_Intro_CombatTactics:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().StartingQuestTargetDummyCreatureID) then
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
		local playerClass = TutorialHelper:GetClass();
		local resourceString;
		if playerClass == "WARRIOR" then
			resourceString = NPEV2_RESOURCE_CALLOUT_WARRIOR;
		elseif playerClass == "ROGUE" or playerClass == "MONK" then
			resourceString = NPEV2_RESOURCE_CALLOUT_ENERGY;
		else
			return;
		end
		resourceString = TutorialHelper:FormatString(resourceString:format(self.keyBindString, self.spellIDString));
		self.pointerID = self:AddPointerTutorial(resourceString, "LEFT", namePlatePlayer, 0, 0, nil, "RIGHT");
	end
end

function Class_Intro_CombatTactics:PLAYER_LEAVE_COMBAT()
	local tutorialData = TutorialHelper:GetFactionData();
	if C_QuestLog.ReadyForTurnIn(tutorialData.StartingQuest) then
		Dispatcher:UnregisterEvent("PLAYER_LEAVE_COMBAT", self);
		self:Complete();
	else
		self:Reset();
	end
end

function Class_Intro_CombatTactics:ShowAbilityPrompt()
	local playerClass = TutorialHelper:GetClass();
	if self.firstTime == false and (playerClass == "WARRIOR" or playerClass == "ROGUE") then
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
	self:HideAbilityPrompt();

	local playerClass = TutorialHelper:GetClass();
	if (playerClass == "WARRIOR" or playerClass == "ROGUE") then
		-- warriors and rogues have a resource callout that reinforces ability use
		self:ShowResourceCallout();
		return;
	end

	if spellID == self.spellID then
		self:HideAbilityPrompt();
		self.firstTime = false;
		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		local isUsable, _ = IsUsableAction(button.action);
		if isUsable then
			self:ShowAbilityPrompt();
		end
	end
end

function Class_Intro_CombatTactics:UNIT_POWER_FREQUENT(unit, resource)
	-- for the intro tutorial, we only sue this for warriors to ensure they have enough rage before slamming
	local button = TutorialHelper:GetActionButtonBySpellID(self.spellID);
	if button then
		local isUsable, notEnoughMana = IsUsableAction(button.action);
		if isUsable then
			Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
			self:ShowAbilityPrompt();
		end
	end
end

function Class_Intro_CombatTactics:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().StartingQuest;
	if questID == questIDRemoved then
		self:Complete();
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
	self:Complete();
end

function Class_Intro_CombatTactics:OnComplete()
	self:HideResourceCallout();
	self:HideAbilityPrompt();
	self:HidePointerTutorials();
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
end


-- ------------------------------------------------------------------------------------------------------------
-- Gossip Frame Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_GossipFrameWatcher = class("GossipFrameWatcher", Class_TutorialBase);
function Class_GossipFrameWatcher:OnBegin()
	Dispatcher:RegisterEvent("GOSSIP_SHOW", self);
	Dispatcher:RegisterEvent("GOSSIP_CLOSED", self);
end

function Class_GossipFrameWatcher:GOSSIP_SHOW()
	local firstQuestButton = nil;
	local questCount = 0;
	for i=1, GossipFrame_GetTitleButtonCount() do
		local button = GossipFrame_GetTitleButton(i);
		if button and button:IsShown() and button.type == "Available" then
			questCount = questCount + 1;
			if not firstQuestButton then
				firstQuestButton = button;
			end
			NPE_TutorialQuestBangGlow:Show(button);
		end
	end
	GossipFrameGreetingGoodbyeButton:Hide();
	if firstQuestButton and questCount > 1 then
		self:ShowPointerTutorial(NPEV2_MULTIPLE_QUESTS_OFFERED, "LEFT", firstQuestButton, 0, 0, "RIGHT");
	end
end

function Class_GossipFrameWatcher:GOSSIP_CLOSED()
	for i=1, GossipFrame_GetTitleButtonCount() do
		local button = GossipFrame_GetTitleButton(i);
		if button and button:IsShown() and button.type == "Available" then
			NPE_TutorialQuestBangGlow:Hide(button);
		end
	end
	GossipFrameGreetingGoodbyeButton:Show();
	self:HidePointerTutorials();
end

function Class_GossipFrameWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_GossipFrameWatcher:OnComplete()
	self:HidePointerTutorials();
end

-- ------------------------------------------------------------------------------------------------------------
-- Accept Quest Watcher - Watches for a new quest window to pop up that is ready to be accepted
-- ------------------------------------------------------------------------------------------------------------
Class_AcceptQuestWatcher = class("AcceptQuestWatcher", Class_TutorialBase);
function Class_AcceptQuestWatcher:OnInitialize()
	self:SetMaxLevel(4);
end

function Class_AcceptQuestWatcher:OnBegin()
	Dispatcher:RegisterScript(QuestFrame, "OnShow", self);
end

function Class_AcceptQuestWatcher:OnShow()
	Tutorials.AcceptQuest:Begin();
end

function Class_AcceptQuestWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

-- ------------------------------------------------------------------------------------------------------------
-- Accept Quest - Always prompts the player to accept a quest when the window is up
-- ------------------------------------------------------------------------------------------------------------
Class_AcceptQuest = class("AcceptQuest", Class_TutorialBase);
function Class_AcceptQuest:OnInitialize()
	self:SetMaxLevel(4);
end

function Class_AcceptQuest:OnBegin()
	Dispatcher:RegisterEvent("QUEST_ACCEPTED", self);
	Dispatcher:RegisterScript(QuestFrame, "OnHide", function()
		self:Complete();
		end, true);

	self.Timer = C_Timer.NewTimer(4, function() GlowEmitterFactory:Show(QuestFrameAcceptButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) end);
end

function Class_AcceptQuest:QUEST_ACCEPTED()
	self:Complete();
end

function Class_AcceptQuest:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_AcceptQuest:OnComplete()
	if self.Timer then
		self.Timer:Cancel();
	end
	GlowEmitterFactory:Hide(QuestFrameAcceptButton);
end


-- ------------------------------------------------------------------------------------------------------------
-- Turn In Quest Watch - Watches for a quest turn in window
-- ------------------------------------------------------------------------------------------------------------
Class_TurnInQuestWatcher = class("TurnInQuestWatcher", Class_TutorialBase);
function Class_TurnInQuestWatcher:OnBegin()
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);
end

function Class_TurnInQuestWatcher:QUEST_COMPLETE()
	Tutorials.TurnInQuest:Begin();

	-- Figure out if all the items are usable
	local areAllItemsUsable = true;
	local questID = GetQuestID(); -- the last ID that was brought up in a quest frame
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID) -- find the index in the quest log

	local numChoices = GetNumQuestLogChoices(questID)
	for i = 1, numChoices do
		local isUsable = select(5, GetQuestLogChoiceInfo(i));
		if (not isUsable) then
			areAllItemsUsable = false;
			break;
		end
	end

	if (GetNumQuestChoices() > 1) then
		--  Wait one frame to make sure the reward buttons have been positioned
		C_Timer.After(0.1, function() Tutorials.QuestRewardChoice:Begin(areAllItemsUsable); end);
	end
end

function Class_TurnInQuestWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end


-- ------------------------------------------------------------------------------------------------------------
-- Turn In Quest - Always prompts the player to complete a quest when the window is up
-- ------------------------------------------------------------------------------------------------------------
Class_TurnInQuest = class("TurnInQuest", Class_TutorialBase);
function Class_TurnInQuest:OnInitialize()
	self:SetMaxLevel(4);
end

function Class_TurnInQuest:OnBegin()
	Dispatcher:RegisterScript(QuestFrame, "OnHide", function() self:Complete() end, true);

	Dispatcher:RegisterScript(QuestFrameCompleteQuestButton, "OnClick", function(QuestFrameCompleteQuestButton, button, down)
		self:Complete()
		end, true);

	self.Timer = C_Timer.NewTimer(4, function() GlowEmitterFactory:Show(QuestFrameCompleteQuestButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) end);
end

function Class_TurnInQuest:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_TurnInQuest:OnComplete()
	if self.Timer then
		self.Timer:Cancel();
	end
	GlowEmitterFactory:Hide(QuestFrameCompleteQuestButton);
end


-- ------------------------------------------------------------------------------------------------------------
-- Quest Reward Choice - Prompts the player to click on a reward item to select one
-- ------------------------------------------------------------------------------------------------------------
Class_QuestRewardChoice = class("QuestRewardChoice", Class_TutorialBase);
function Class_QuestRewardChoice:OnBegin(areAllItemsUsable)
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

	Dispatcher:RegisterEvent("QUEST_TURNED_IN", function() self:Complete() end, true);
	Dispatcher:RegisterScript(QuestFrame, "OnHide", function() self:Interrupt(self) end, true);
end

function Class_QuestRewardChoice:OnInterrupt(interruptedBy)
	self:Complete();
end


-- ------------------------------------------------------------------------------------------------------------
-- Quest Complete - Quest objective pop up
-- ------------------------------------------------------------------------------------------------------------
Class_QuestCompleteHelp = class("QuestCompleteHelp", Class_TutorialBase);
function Class_QuestCompleteHelp:OnInitialize()
	self:SetMaxLevel(2);
end

function Class_QuestCompleteHelp:OnBegin()
	Tutorials.Intro_CombatTactics:Complete();
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);
	self:ShowPointerTutorial(NPEV2_QUEST_COMPLETE_HELP, "RIGHT", ObjectiveTrackerBlocksFrameHeader, -40, 0, nil, "RIGHT");
end

function Class_QuestCompleteHelp:QUEST_COMPLETE()
	if (self.QuestCompleteTimer) then
		self.QuestCompleteTimer:Cancel()
	end
	self:HidePointerTutorials();
	self:Complete();
end

function Class_QuestCompleteHelp:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().StartingQuest;
	if questID == questIDRemoved then
		self:Complete();
	end
end

function Class_QuestCompleteHelp:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_QuestCompleteHelp:OnComplete()
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Queue System - this tutorial makes sure that certain tutorials can't happen at the same time
-- ------------------------------------------------------------------------------------------------------------
Class_QueueSystem = class("QueueSystem", Class_TutorialBase);
function Class_QueueSystem:OnInitialize()
	self:Reset();
end

function Class_QueueSystem:Reset()
	self.tutorialQueue = {};
	self.tutorialQueue.first = 1;
	self.tutorialQueue.last = 0;
	
	self.tutorialQueue.Push = function(self, value)
		local last = self.last + 1;
		self.last = last;
		self[last] = value;
	end

	self.tutorialQueue.Pop = function(self)
		local first = self.first;
		local value;
		if first <= self.last then
			value = self[first];
			self[first] = nil;
			self.first = first + 1;
		end
		return value;
	end
	self.inProgress = false;
end

function Class_QueueSystem:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:RegisterEvent("UNIT_INVENTORY_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);

	self.playerClass = TutorialHelper:GetClass();
	if self.playerClass == "DRUID" or self.playerClass == "ROGUE" then
		Dispatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	end
end

function Class_QueueSystem:PLAYER_UNGHOST()
	self:CheckQueue();
end

function Class_QueueSystem:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel > 9 then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	else
		LevelUpTutorial_spellIDlookUp = TutorialHelper:FilterByClass(TutorialData.LevelAbilitiesTable);
		for i = originalLevel + 1, newLevel, 1 do
			local spellID = LevelUpTutorial_spellIDlookUp[i];
			if spellID then
				local value = {};
				value.spellID = spellID;
				value.warningString = nil;
				value.spellMicroButtonString = NPEV2_SPELLBOOK_TUTORIAL;
				value.type = "PLAYER_LEVEL_CHANGED";
				self.tutorialQueue:Push(value);
			end
		end
	end
	self:CheckQueue();
end

function Class_QueueSystem:UPDATE_SHAPESHIFT_FORM()
	local level = UnitLevel("player");
	if (level > 9) then
		Dispatcher:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", self);
		self:CheckQueue();
		return;
	end
	local form = GetShapeshiftFormID();
	local formSpells = nil;
	if form == BEAR_FORM then
		formSpells = TutorialData.DruidAnimalFormSpells.bearSpells;
	elseif form == CAT_FORM then
		formSpells = TutorialData.DruidAnimalFormSpells.catSpells;
	elseif form == ROGUE_STEALTH then
		formSpells = TutorialData.RogueStealthSpells;
	else
		Tutorials.AddSpellToActionBar:Complete();
	end
	if formSpells then
		for i, spellID in ipairs(formSpells) do
			if IsSpellKnown(spellID) then
				local value = {};
				value.spellID = spellID;
				value.warningString = nil;
				value.spellMicroButtonString = NPEV2_SPELLBOOK_TUTORIAL;
				value.form = form;
				value.type = "REQUIRED_FORM_SPELL";
				self.tutorialQueue:Push(value);
			end
		end
	end
	self.Timer = C_Timer.NewTimer(0.25, function()
		self:CheckQueue();
	end);
end

function Class_QueueSystem:UNIT_INVENTORY_CHANGED()
	local level = UnitLevel("player");
	if (level > 10) then
		-- if the player comes back after level 10, don't prompt them on loot anymore
		Dispatcher:UnregisterEvent("UNIT_INVENTORY_CHANGED", self);
	else
		local value = {};
		value.type = "UNIT_INVENTORY_CHANGED";
		self.tutorialQueue:Push(value);
	end
	self:CheckQueue();
end


function Class_QueueSystem:QueueSpellTutorial(spellID, warningString, spellMicroButtonString, optionalPreferredActionBar)
	if spellID then
		local value = {};
		value.spellID = spellID;
		value.warningString = warningString;
		value.spellMicroButtonString = spellMicroButtonString;
		value.optionalPreferredActionBar = optionalPreferredActionBar;
		value.type = "SPELL_TUTORIAL";
		self.tutorialQueue:Push(value);
	end
	self:CheckQueue();
end

function Class_QueueSystem:QueueMountTutorial()
	local value = {};
	value.type = "MOUNT_TUTORIAL";
	self.tutorialQueue:Push(value);
	self:CheckQueue();
end

function Class_QueueSystem:QueueLFDTutorial()
	local value = {};
	value.type = "LFD_TUTORIAL";
	self.tutorialQueue:Push(value);
	self:CheckQueue();
end

function Class_QueueSystem:QueueSpecTutorial()
	local value = {};
	value.type = "SPEC_TUTORIAL";
	self.tutorialQueue:Push(value);
	self:CheckQueue();
end

function Class_QueueSystem:TutorialFinished()
	self.inProgress = false;
	self:CheckQueue();
end

function Class_QueueSystem:CheckQueue()
	if self.inProgress == true then
		return;
	end

	if UnitIsDeadOrGhost("player") then
		return;
	end

	local value = self.tutorialQueue:Pop();
	if value then
		if value.type == "PLAYER_LEVEL_CHANGED" or value.type == "SPELL_TUTORIAL" then
			if value.spellID then
				self.inProgress = true;
				Tutorials.AddSpellToActionBar:Begin(value.spellID, value.warningString, value.spellMicroButtonString, value.optionalPreferredActionBar);
			end
		elseif value.type == "REQUIRED_FORM_SPELL" then
			local form = GetShapeshiftFormID();
			if form == value.form then
				if value.spellID then
					self.inProgress = true;
					Tutorials.AddSpellToActionBar:Begin(value.spellID, value.warningString, value.spellMicroButtonString);
				end
			else
				-- not in the correct form, dump it
				self:CheckQueue();
			end
		elseif value.type == "UNIT_INVENTORY_CHANGED" then
			self.inProgress = Tutorials.EquipFirstItemWatcher:CheckForUpgrades();
		elseif value.type == "MOUNT_TUTORIAL" then
			self.inProgress = true;
			Tutorials.MountAddedWatcher:ForceBegin();
		elseif value.type == "LFD_TUTORIAL" then
			self.inProgress = true;
			Tutorials.LFGStatusWatcher:ForceBegin();
		elseif value.type == "SPEC_TUTORIAL" then
			self.inProgress = true;
			Tutorials.SpecTutorial:StartTutorial();
		end
	end
end

-- this tutorial checks on relog or reloadui, if the player has their abilities gained from level up
-- on their action bar
Class_SpellChecker = class("SpellChecker", Class_TutorialBase);
function Class_SpellChecker:OnBegin()
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_ENTERING_WORLD", self);
	self:CheckSpells();
end

function Class_SpellChecker:CheckSpells()
	LevelUpTutorial_spellIDlookUp = TutorialHelper:FilterByClass(TutorialData.LevelAbilitiesTable);
	local playerLevel = UnitLevel("player");
	for startLevel = 1, playerLevel do
	 	local spellID = LevelUpTutorial_spellIDlookUp[startLevel];

		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		if not button then
			Tutorials.QueueSystem:QueueSpellTutorial(spellID, nil, NPEV2_SPELLBOOK_TUTORIAL);
		end
	end
	self:Complete();
end

function Class_SpellChecker:PLAYER_ENTERING_WORLD()
	Dispatcher:UnregisterEvent("PLAYER_ENTERING_WORLD", self);
	self:CheckSpells();
end

function Class_SpellChecker:ACTIONBAR_SLOT_CHANGED(slot)
	if slot == 0 then
		Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
		self:CheckSpells();
	end
end

function Class_SpellChecker:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_SpellChecker:OnComplete()
end


-- ------------------------------------------------------------------------------------------------------------
-- XP Bar Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_XPBarTutorial = class("XPBarTutorial", Class_TutorialBase);
-- @param data: type STRUCT_ItemContainer
function Class_XPBarTutorial:OnInitialize()
	self:HidePointerTutorials();
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
end

function Class_XPBarTutorial:OnBegin()
	Dispatcher:RegisterEvent("QUEST_TURNED_IN", self);
end

function Class_XPBarTutorial:QUEST_TURNED_IN(completedQuestID)
	Dispatcher:UnregisterEvent("QUEST_TURNED_IN", self);
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	Tutorials.Hide_StatusTrackingBar:Complete();

	local questID = TutorialHelper:GetFactionData().StartingQuest;
	if completedQuestID == questID then
		self:ShowPointerTutorial(NPEV2_XP_BAR_TUTORIAL, "DOWN", StatusTrackingBarManager, 0, -5, nil, "DOWN");
	end
end

function Class_XPBarTutorial:QUEST_DETAIL()
	self:Complete();
end

function Class_XPBarTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

-- ------------------------------------------------------------------------------------------------------------
-- Add Spell To Action Bar
-- ------------------------------------------------------------------------------------------------------------
Class_AddSpellToActionBar = class("AddSpellToActionBar", Class_TutorialBase);
function Class_AddSpellToActionBar:OnBegin(spellID, warningString, spellMicroButtonString, optionalPreferredActionBar)
	if not spellID then
		self:Complete();
		return;
	end
	self.inProgress = true;
	self.spellToAdd = spellID;
	self.spellIDString = "{$"..self.spellToAdd.."}";
	self.warningString = warningString;
	self.spellMicroButtonString = spellMicroButtonString or NPEV2_SPELLBOOK_ADD_SPELL;
	self.optionalPreferredActionBar = optionalPreferredActionBar;

	local button = TutorialHelper:GetActionButtonBySpellID(self.spellToAdd);
	if  button then
		self:Complete();
		return;
	end

	if self.warningString then
		local finalString = self.warningString:format(self.spellIDString);
		local content = {text = TutorialHelper:FormatString(finalString), icon=nil};
		self.PointerID = self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
	end

	if SpellBookFrame:IsShown() then
		self:SpellBookFrameShow()
	else
		if self.spellIDString then
			self:ShowPointerTutorial(TutorialHelper:FormatString(self.spellMicroButtonString:format(self.spellIDString)), "DOWN", SpellbookMicroButton, 0, 0, nil, "DOWN");
		end
		EventRegistry:RegisterCallback("SpellBookFrame.Show", self.SpellBookFrameShow, self);
	end
end

function Class_AddSpellToActionBar:SpellBookFrameShow()
	EventRegistry:UnregisterCallback("SpellBookFrame.Show", self);
	EventRegistry:RegisterCallback("SpellBookFrame.Hide", self.SpellBookFrameHide, self);
	self:HidePointerTutorials();
	ActionButton_HideOverlayGlow(SpellbookMicroButton);
	self:RemindAbility();
end

function Class_AddSpellToActionBar:SpellBookFrameHide()
	self:Complete();
end

function Class_AddSpellToActionBar:ACTIONBAR_SHOW_BOTTOMLEFT()
	Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	self:RemindAbility();
end

function Class_AddSpellToActionBar:RemindAbility()
	self:HideScreenTutorial();

	-- find an empty button
	self.actionButton = TutorialHelper:FindEmptyButton(self.optionalPreferredActionBar);
	if not self.requested and not actionButton and not MultiBarBottomLeft:IsVisible() then
		-- no button was found, request the bottom left action bar be shown
		Dispatcher:RegisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
		self.requested = RequestBottomLeftActionBar();
		return;
	end

	-- find the spell button
	local toggleFlyout = false;

	self.spellButton, self.flyoutButton = SpellBookFrame_OpenToSpell(self.spellToAdd, toggleFlyout);

	if self.actionButton and (self.flyoutButton or self.spellButton) then
		-- play the drag animation
		Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);

		NPE_TutorialDragButton:Show(self.flyoutButton or self.spellButton, self.actionButton);

		local tutorialString = NPEV2_SPELLBOOKREMINDER:format(self.spellIDString);
		tutorialString = TutorialHelper:FormatString(tutorialString)
		self:ShowPointerTutorial(tutorialString, "LEFT", self.flyoutButton or self.spellButton or SpellBookFrame, 50, 0, nil, "LEFT");
	else
		local tutorialString = NPEV2_SPELLBOOKREMINDER_PART2:format(self.spellIDString);
		tutorialString = TutorialHelper:FormatString(tutorialString)
		self:ShowPointerTutorial(tutorialString, "LEFT", self.spellButton or SpellBookFrame, 50, 0, nil, "LEFT");
	end
end

function Class_AddSpellToActionBar:ACTIONBAR_SLOT_CHANGED(slot)
	local actionType, sID, subType = GetActionInfo(slot);

	if sID == self.spellToAdd then
		self:Complete();
	elseif (actionType == "flyout" and FlyoutHasSpell(sID, self.spellToAdd)) then
		self:Complete();
	else
		-- HACK: there is a special Tutorial only condition here we need to check here for Freezing Trap
		local normalFreezingTrapSpellID = 187650;
		local specialFreezingTrapSpellID = 321164;
		if self.spellToAdd == normalFreezingTrapSpellID then
			if (sID == normalFreezingTrapSpellID) or (sID == specialFreezingTrapSpellID) then
				self:Complete();
				return;
			end
		end

		local nextEmptyButton = TutorialHelper:FindEmptyButton();
		if not nextEmptyButton then
			-- no more empty buttons
			self:Complete();
		elseif self.actionButton ~= nextEmptyButton then
			NPE_TutorialDragButton:Hide();
			self.actionButton = nextEmptyButton;
			NPE_TutorialDragButton:Show(self.flyoutButton or self.spellButton, self.actionButton);
		end
	end
end

function Class_AddSpellToActionBar:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_AddSpellToActionBar:OnComplete()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	EventRegistry:UnregisterCallback("SpellBookFrame.Show", self);
	EventRegistry:UnregisterCallback("SpellBookFrame.Hide", self);
	self:HidePointerTutorials();
	self:HideScreenTutorial();
	NPE_TutorialDragButton:Hide();

	self.spellToAdd = nil;
	self.actionButton = nil;
	self.spellButton = nil;
	self.inProgress = false;

	self.Timer = C_Timer.NewTimer(0.1, function()
		Tutorials.QueueSystem:TutorialFinished();
	end);
end


-- ------------------------------------------------------------------------------------------------------------
-- Add Class Spell To Action Bar
-- ------------------------------------------------------------------------------------------------------------
Class_AddClassSpellToActionBar = class("AddClassSpellToActionBar", Class_TutorialBase);
function Class_AddClassSpellToActionBar:OnBegin()
	local classData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	local spellID = classData.classQuestSpellID;
	if spellID then
		local playerClass = TutorialHelper:GetClass();
		local preferredActionBar = playerClass == "ROGUE" and "MultiBarBottomLeftButton" or nil;
		Tutorials.QueueSystem:QueueSpellTutorial(spellID, nil, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar);
	end
	self:Complete();
end

-- ------------------------------------------------------------------------------------------------------------
-- Open Map - Main screen prompt to open the map
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_OpenMap = class("Intro_OpenMap", Class_TutorialBase);
function Class_Intro_OpenMap:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);

	local key = TutorialHelper:GetMapBinding();
	Dispatcher:RegisterScript(WorldMapFrame, "OnShow", self);

	local content = {text = NPEV2_OPENMAP, icon=nil, keyText=key};
	self:ShowSingleKeyTutorial(content);

	self.Timer = C_Timer.NewTimer(12, function()
		self:Complete();
	end);
end

function Class_Intro_OpenMap:OnShow()
	self.OpenMap = true;
	self:Complete();
end

function Class_Intro_OpenMap:PLAYER_DEAD()
	self:Complete();
end

function Class_Intro_OpenMap:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Intro_OpenMap:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	self:HideSingleKeyTutorial();

	if self.Timer then
		self.Timer:Cancel()
	end

	if self.OpenMap then
		Tutorials.Intro_MapHighlights:Begin();
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Map Pointers - This shows the map legend and the minimap legend
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_MapHighlights = class("Intro_MapHighlights", Class_TutorialBase);
function Class_Intro_MapHighlights:OnBegin()
	self.MapID = WorldMapFrame:GetMapID();

	self.Prompt = NPEV2_MAPCALLOUTPOINT;
	self:Display();

	Dispatcher:RegisterScript(WorldMapFrame, "OnHide", function() self:Complete(); end, true);

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
	local tutorialData = TutorialHelper:GetFactionData();
	questID = tutorialData.UseMapQuest;

	local targetPin
	for pin in WorldMapFrame:EnumerateAllPins() do
		 if pin.pinTemplate == "QuestPinTemplate" then
			if questID == pin.questID then
				targetPin = pin;
				break;
			end
		 end
	end
	if targetPin then
		self.MapPointerTutorialID = self:AddPointerTutorial(TutorialHelper:FormatString(self.Prompt), "UP", targetPin, 0, 0, nil);
	end
end

function Class_Intro_MapHighlights:OnSuppressed()
	NPE_TutorialPointerFrame:Hide(self.MapPointerTutorialID);
end

function Class_Intro_MapHighlights:OnUnsuppressed()
	self:Display();
end

function Class_Intro_MapHighlights:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Intro_MapHighlights:OnComplete()
end

-- ------------------------------------------------------------------------------------------------------------
-- Repeatable Use Item Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_UseQuestItemTutorial = class("UseQuestItemTutorial", Class_TutorialBase);
function Class_UseQuestItemTutorial:OnBegin(questData)
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	self.questData = questData;
	self:StartWatchingTarget();
end

function Class_UseQuestItemTutorial:StartWatchingTarget()
	local range = self.questData.TargetRange;
	local targets = self.questData.ItemTargets;
	local screenString = self.questData.ScreenTutorialStringID;
	Tutorials.CreatureRangeWatcher:Begin(range, targets, screenString, GenerateClosure(self.InRange, self));
end

function Class_UseQuestItemTutorial:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if spellID == self.questData.ItemSpell then
		self:StartWatchingTarget();
	end
end

function Class_UseQuestItemTutorial:UNIT_TARGET()
	self:HidePointerTutorials();
	local unitGUID = UnitGUID("target");
	if unitGUID then
		local creatureID = TutorialHelper:GetCreatureIDFromGUID(unitGUID);
		local itemTargets = self.questData.ItemTargets;
		for i, target in ipairs(itemTargets) do
			if creatureID == target then
				self:StartWatchingTarget();
				return;
			end
		end
	end
	self:HidePointerTutorials();
	self:HideScreenTutorial();
end

function Class_UseQuestItemTutorial:InRange()
	self:HideScreenTutorial();
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

	local module = QUEST_TRACKER_MODULE:GetBlock(self.questData.ItemQuest)
	if (module and module.itemButton) then
		local pointerString = self.questData.PointerTutorialStringID;
		QuestItemTutorial =	self:ShowPointerTutorial(TutorialHelper:FormatString(pointerString), "UP", module.itemButton);
	end
end

function Class_UseQuestItemTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_UseQuestItemTutorial:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Tutorials.CreatureRangeWatcher:Complete();
	Tutorials.Hide_Backpack:Complete();
end


-- ============================================================================================================
-- LOOTING
--
-- Keeps track of when a player as a mob they can kill
-- Every time the player enters combat, this starts watching the combat log.  When a UNIT_DIED event is heard
-- this checks to see if the player can loot that corpse.
--
-- The player is promted 3 times in a row to loot the corpse as well as the loot pane being called out the first time
-- If the player closes the loot window without actually looting the corpse, the prompts say up.
--
-- Once the player has successfully looted 3 times, this continues to track.
--		- If the player opens a loot window and then closes it without looting, they are re-prompted to loot the
--		  corpse and the pointer is re-invoked
--		- If they don't loot the corpse and get into combat two more times, they are prompted to loot again but
--		  the pointer is not re-invoked
-- ------------------------------------------------------------------------------------------------------------
Class_LootCorpseWatcher = class("LootCorpseWatcher", Class_TutorialBase);
function Class_LootCorpseWatcher:OnInitialize()
	self.LootCount = 0;
	self.RePromptLootCount = 0;
	self.PendingLoot = false;
	self._QuestMobs = {}; -- will hold the UnitID for the mob to watch for
end

function Class_LootCorpseWatcher:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self);
end

function Class_LootCorpseWatcher:WatchQuestMob(unitID)
	if (type(unitID) == "table") then
		for i, id in ipairs(unitID) do
			self._QuestMobs[id] = false;
		end
	else
		self._QuestMobs[unitID] = false;
	end
end

function Class_LootCorpseWatcher:LootSuccessful(unitID)
	-- Handle quest mobs
	if (self._QuestMobs[unitID] ~= nil) then
		self._QuestMobs[unitID] = true;
	end

	self.LootCount = self.LootCount + 1;
	self.PendingLoot = false;
	self.RePromptLootCount = 0;

	Dispatcher:UnregisterEvent("CHAT_MSG_LOOT", self);
	Dispatcher:UnregisterEvent("CHAT_MSG_MONEY", self);
end

function Class_LootCorpseWatcher:CHAT_MSG_LOOT(...)
	self:LootSuccessful();
end

function Class_LootCorpseWatcher:CHAT_MSG_MONEY(...)
	self:LootSuccessful();
end

-- Entering Combat
function Class_LootCorpseWatcher:PLAYER_REGEN_DISABLED(...)
	self:SuppressChildren();
	Dispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
end

-- Leaving Combat
function Class_LootCorpseWatcher:PLAYER_REGEN_ENABLED(...)
	self:UnsuppressChildren();
	Dispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
end

-- Watch for units dying while in combat.  if that happened, check the unit to see if the
-- player can loot it and if so, prompt the player to loot
function Class_LootCorpseWatcher:COMBAT_LOG_EVENT_UNFILTERED(timestamp, logEvent)
	local eventData = {CombatLogGetCurrentEventInfo()};
	local logEvent = eventData[2];
	local unitGUID = eventData[8];
	if ((logEvent == "UNIT_DIED") or (logEvent == "UNIT_DESTROYED")) then
		-- Wait for mirror data
		C_Timer.After(1, function()
			if CanLootUnit(unitGUID) then
				self:UnitLootable(unitGUID);
			end
		end);
	end
end

function Class_LootCorpseWatcher:UnitLootable(unitGUID)
	local unitID = tonumber(string.match(unitGUID, "Creature%-.-%-.-%-.-%-.-%-(.-)%-"));
	for id, hasKilled in pairs(self._QuestMobs) do
		if (unitID == hasKilled) then
			Tutorials.LootCorpse:ForceBegin(unitID);
			return;
		end
	end

	-- if the player hasn't looted their last mob increment the reprompt threshold
	if (self.PendingLoot) then
		self.RePromptLootCount = self.RePromptLootCount + 1;
	end
	self.PendingLoot = true;

	if ((self.LootCount < 3) or (self.RePromptLootCount >= 2)) then
		Tutorials.LootCorpse:Begin();
	else
		-- These are so we can silently watch for people missing looting without a prompt.
		-- If they are prompted, the prompt tutorial (LootCorpse) manages this.
		Dispatcher:RegisterEvent("CHAT_MSG_LOOT", self);
		Dispatcher:RegisterEvent("CHAT_MSG_MONEY", self);
	end
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
		Tutorials.LootPointer:Begin();
	end
end

function Class_LootCorpse:CHAT_MSG_LOOT(...)
	self:Complete();
end

function Class_LootCorpse:CHAT_MSG_MONEY(...)
	self:Complete();
end

function Class_LootCorpse:LOOT_CLOSED(...)
	Tutorials.LootPointer:Begin();
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
	if self.Timer then
		self.Timer:Cancel();
	end

	Tutorials.LootPointer:Complete();

	if (self.QuestMobID) then
		self.QuestMobCount = self.QuestMobCount + 1;
	end

	Tutorials.LootCorpseWatcher:LootSuccessful(self.QuestMobID);
	self.ShowPointer = false;
end

-- ------------------------------------------------------------------------------------------------------------
-- Prompts how to use the loot window the first time
-- This is managed and completed by LootCorpse
-- ------------------------------------------------------------------------------------------------------------
Class_LootPointer = class("LootPointer", Class_TutorialBase);
function Class_LootPointer:OnBegin()
	local level = UnitLevel("player");
	if (level > 4) then -- if the player comes back after level 4, don't prompt them on loot anymore
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("LOOT_OPENED", self);
	Dispatcher:RegisterEvent("LOOT_CLOSED", self);
end

--Function that handles looting from a quest object
function Class_LootPointer:LOOT_OPENED()
	alreadyLootedQuestItem = false;
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


-- ------------------------------------------------------------------------------------------------------------
-- Equip First Item Watcher - Watches you inventory for item upgrades to kick off this sequence
-- ------------------------------------------------------------------------------------------------------------
Class_EquipFirstItemWatcher = class("EquipFirstItemWatcher", Class_TutorialBase);
function Class_EquipFirstItemWatcher:OnInitialize()
	self.WeaponType = {
		TwoHand	= "TwoHand",
		Ranged	= "Ranged",
		Other	= "Other",
	}
end

function Class_EquipFirstItemWatcher:OnBegin()
	local level = UnitLevel("player");
	if (level > 10) then -- if the player comes back after level 10, don't prompt them anymore
		self:Complete();
		return;
	end
end

function Class_EquipFirstItemWatcher:CheckForUpgrades()
	local upgrades = self:GetBestItemUpgrades();
	local slot, item = next(upgrades);

	if item and slot ~= INVSLOT_TABARD then
		Tutorials.EquipTutorial:ForceBegin(item);
		return true;
	end
	Tutorials.QueueSystem:TutorialFinished();
	return false;
end

function Class_EquipFirstItemWatcher:STRUCT_ItemContainer(itemLink, characterSlot, container, containerSlot)
	return
	{
		ItemLink = itemLink,
		Container = container,
		ContainerSlot = containerSlot,
		CharacterSlot = characterSlot,
	};
end

-- Find the best item a player can equip from their bags per equipment slot
-- @return A table keyed off equipement slot that contains a STRUCT_ItemContainer
function Class_EquipFirstItemWatcher:GetBestItemUpgrades()
	local potentialUpgrades = self:GetPotentialItemUpgrades();
	local upgrades = {};

	for equipmentSlot, items in pairs(potentialUpgrades) do
		local highest = nil;
		local highestIlvl = 0;

		for i = 1, #items do
			itemLink = items[i].ItemLink;
			local itemQuality = select(3, GetItemInfo(itemLink));
			local ilvl = GetDetailedItemLevelInfo(itemLink) or 0;
			if (itemQuality == Enum.ItemQuality.Heirloom) then
				-- always recommend heirlooms, regardless of iLevel
				highest = items[i];
				highestIlvl = ilvl;
				break;
			elseif (ilvl > highestIlvl) then
				highest = items[i];
				highestIlvl = ilvl;
			end
		end

		if (highest) then
			upgrades[equipmentSlot] = highest;
		end
	end

	return upgrades;
end

function Class_EquipFirstItemWatcher:GetWeaponType(itemID)
	local loc = select(9, GetItemInfo(itemID));

	if ((loc == "INVTYPE_RANGED") or (loc == "INVTYPE_RANGEDRIGHT")) then
		return self.WeaponType.Ranged;
	elseif (loc == "INVTYPE_2HWEAPON") then
		return self.WeaponType.TwoHand;
	else
		return self.WeaponType.Other;
	end
end

local function IsDagger(itemInfo)
	local subClassType = ITEMSUBCLASSTYPES["DAGGER"];
	return ((itemInfo[12] == subClassType.classID) and (itemInfo[13] == subClassType.subClassID));
end

-- Walk all the character item slots and create a list of items in the player's inventory
-- that can be equipped into those slots and is a higher ilvl
-- @return a table of all slots that have higher ilvl items in the player's pags. Each table is a list of STRUCT_ItemContainer
function Class_EquipFirstItemWatcher:GetPotentialItemUpgrades()
	local potentialUpgrades = {};

	local playerClass = TutorialHelper:GetClass();

	for i = 0, INVSLOT_LAST_EQUIPPED do
		local existingItemIlvl = 0;
		local existingItemWeaponType;

		local existingItemLink = GetInventoryItemLink("player", i);
		local existingItemQuality;
		if (existingItemLink ~= nil) then
			existingItemIlvl = GetDetailedItemLevelInfo(existingItemLink) or 0;
			existingItemQuality = select(3, GetItemInfo(existingItemLink));

			if (i == INVSLOT_MAINHAND) then
				local existingItemID = GetInventoryItemID("player", i);
				existingItemWeaponType = self:GetWeaponType(existingItemID);
			end
		end

		local availableItems = {};
		GetInventoryItemsForSlot(i, availableItems);

		for packedLocation, itemLink in pairs(availableItems) do
			local itemInfo = {GetItemInfo(itemLink)};
			local ilvl = GetDetailedItemLevelInfo(itemLink) or 0;

			if (ilvl ~= nil) and (existingItemQuality ~= Enum.ItemQuality.Heirloom) then
				if (ilvl > existingItemIlvl) then
					-- why can't I just have a continue statement?
					local match = true;

					-- if it's a main-hand, make sure it matches the current type, if there is one
					if (i == INVSLOT_MAINHAND) then
						local item = Item:CreateFromItemLink(itemLink);
						local itemID = item:GetItemID();
						local weaponType = self:GetWeaponType(itemID);
						match = (not existingItemWeaponType) or (existingItemWeaponType == weaponType);

						-- rouge's should only be recommended daggers
						if ( playerClass == "ROGUE" and not IsDagger(itemInfo)) then
							match = false;
						end
					end

					-- if it's an off-hand, make sure the player doesn't have a 2h or rnaged weapon
					if (i == INVSLOT_OFFHAND) then
						local mainHandID = GetInventoryItemID("player", INVSLOT_MAINHAND);
						if (mainHandID) then
							local mainHandType = self:GetWeaponType(mainHandID);
							if ((mainHandType == self.WeaponType.TwoHand) or (mainHandType == self.WeaponType.Ranged)) then
								match = false;
							end
						end

						-- rouge's should only be recommended daggers
						if ( playerClass == "ROGUE" and not IsDagger(itemInfo)) then
							match = false;
						end
					end

					if (match) then
						local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(packedLocation);

						if ((player == true) and (bags == true)) then
							if (potentialUpgrades[i] == nil) then
								potentialUpgrades[i] = {};
							end

							table.insert(potentialUpgrades[i], self:STRUCT_ItemContainer(itemLink, i, bag, slot));
						end
					end
				end
			end
		end
	end

	return potentialUpgrades;
end

function Class_EquipFirstItemWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_EquipFirstItemWatcher:OnComplete()
end


-- ------------------------------------------------------------------------------------------------------------
-- Equip Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_EquipTutorial = class("EquipTutorial", Class_TutorialBase);
function Class_EquipTutorial:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_EquipTutorial:OnBegin(data)
	if (MerchantFrame:IsVisible()) then
		self:Interrupt(self);
		return;
	end

	Dispatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);

	EventRegistry:RegisterCallback("ContainerFrame.AllBagsClosed", self.BagClosed, self);
	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.BagOpened, self);
	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", self.BagClosed, self);
	EventRegistry:RegisterCallback("ContainerFrame.OpenBackpack", self.BagOpened, self);
	EventRegistry:RegisterCallback("ContainerFrame.CloseBackpack", self.BagClosed, self);

	self.data = data;
	-- Verify the item is still there.  Edge-case where someone managed to open their bags and equip the item
	-- between the time the tutorial was activated and actually begins.  e.g. They turn in a quest that rewards
	-- them with an item, activating this tutorial.  The quest frame is still open to accept the next quest causing
	-- this to be delayed, and in while the quest frame is open, they equip the item.
	if (not GetContainerItemID(data.Container, data.ContainerSlot)) then
		self:Interrupt(self);
		return;
	end

	self:Reset();
end

function Class_EquipTutorial:PLAYER_DEAD()
	self:Complete();

	-- the player died in the middle of the tutorial, requeue it so that when the player is alive, they can try again
	self.Timer = C_Timer.NewTimer(0.1, function()
		Tutorials.QueueSystem:UNIT_INVENTORY_CHANGED();
	end);
end

function Class_EquipTutorial:Reset()
	self.success = false;
	NPE_TutorialDragButton:Hide();
	self:HidePointerTutorials();
	self:PrepBags();
end

function Class_EquipTutorial:PrepBags()
	-- Dirty hack to make sure all bags are closed
	TutorialHelper:CloseAllBags();
	self.allBagsOpened = false;
	NPE_TutorialDragButton:Hide();

	self.Timer = C_Timer.NewTimer(0.1, function()
		local key = TutorialHelper:GetBagBinding();
		local tutorialString = TutorialHelper:FormatString(string.format(NPEV2_SHOW_BAGS, key))
		self:ShowPointerTutorial(tutorialString, "DOWN", MainMenuBarBackpackButton, 0, 0);
	end);
end

-- for this tutorial, all the bags need to be opened
function Class_EquipTutorial:OpenAllBags()
	self.allBagsOpened = true;
	TutorialHelper:OpenAllBags();

	C_Timer.NewTimer(0.1, function()
		self:ShowCharacterSheetPrompt();
	end);
end

function Class_EquipTutorial:BagOpened()
	if not self.allBagsOpened then
		self.allBagsOpened = true;

		self.Timer = C_Timer.NewTimer(0.1, function()
			TutorialHelper:CloseAllBags();
			self:OpenAllBags();
		end);
	end
end

function Class_EquipTutorial:BagClosed()
	if self.success then
		self:Complete();
		return;
	end
	self:Reset();
end

function Class_EquipTutorial:ShowCharacterSheetPrompt()
	if (CharacterFrame:IsVisible()) then
		self:CharacterSheetOpened();
		return;
	end
	EventRegistry:RegisterCallback("CharacterFrame.Show", self.CharacterSheetOpened, self);

	local key = TutorialHelper:GetCharacterBinding();
	self:ShowPointerTutorial(TutorialHelper:FormatString(string.format(NPEV2_OPENCHARACTERSHEET, key)), "DOWN", CharacterMicroButton, 0, 0);
end

function Class_EquipTutorial:CharacterSheetOpened()
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

function Class_EquipTutorial:CharacterSheetClosed()
	EventRegistry:UnregisterCallback("CharacterFrame.Hide", self);
	
	if self.success then
		self:Complete();
		return;
	end
	self:Reset();
end

function Class_EquipTutorial:CheckReady()
	local bagsReady = true;
	for i=1, 1, 1 do
		local frame = _G["ContainerFrame"..i];
		if not frame:IsShown() then
			bagsReady = false;
			break;
		end
	end
	local characterSheetReady = CharacterFrame:IsVisible();
	return bagsReady and characterSheetReady;
end

function Class_EquipTutorial:PLAYER_EQUIPMENT_CHANGED()
	local item = Item:CreateFromItemLink(self.data.ItemLink);
	local itemID = item:GetItemID();

	if (GetInventoryItemID("player", self.data.CharacterSlot) == itemID) then
		-- the player successfully equipped the item
		Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
		self.success = true;
		NPE_TutorialDragButton:Hide();
		self.animationPlaying = false;

		if CharacterFrame:IsVisible() and self.destFrame then
			self:ShowPointerTutorial(NPEV2_SUCCESSFULLY_EQUIPPED, "LEFT", self.destFrame);

			EventRegistry:RegisterCallback("CharacterFrame.Hide", self.CharacterSheetClosed, self);

			self.EquipmentChangedTimer = C_Timer.NewTimer(8, function()
				self:Complete();
			end);
		else
			self:Complete();
		end
	end
end

function Class_EquipTutorial:StartAnimation()
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

		NPE_TutorialDragButton:Show(self.originFrame, self.destFrame);
		self.animationPlaying = true;
	end
end

function Class_EquipTutorial:UpdateItemContainerAndSlotInfo()
	local item = Item:CreateFromItemLink(self.data.ItemLink);
	local currentItemID = item:GetItemID();

	if itemInfo and itemInfo[10] == currentItemID then
		-- nothing in the inventory changed that effected the current tutorial
	else
		-- the origin has changed
		local itemFrame = nil;
		local maxNumContainters = 4;

		local itemFound = false;
		for containerIndex = 0, maxNumContainters do
			local slots = GetContainerNumSlots(containerIndex);
			if (slots > 0) then
				for slotIndex = 1, slots do
					local itemInfo = {GetContainerItemInfo(containerIndex, slotIndex)};
					local itemID = itemInfo[10];
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

function Class_EquipTutorial:UpdateDragOrigin()
	if itemInfo and itemInfo[10] == currentItemID then
		-- nothing in the inventory changed that effected the current tutorial
	else
		self:UpdateItemContainerAndSlotInfo()
		if self.data then
			itemFrame = TutorialHelper:GetItemContainerFrame(self.data.Container, self.data.ContainerSlot);
			if itemFrame then
				self:HidePointerTutorial(self.newItemPointerID);
				self:StartAnimation();
			else
				self:Complete();
			end
		end
	end
end

function Class_EquipTutorial:BAG_UPDATE_DELAYED()
	-- check to see if the player moved the item being tutorialized
	self:UpdateItemContainerAndSlotInfo()
	if self.data then
		if self.animationPlaying == true then
			self:UpdateDragOrigin();
		end
	else
		-- for some reason, the item is gone.  maybe the player sold it
		self:Complete();
	end
end

function Class_EquipTutorial:OnInterrupt()
	self:Complete();
end

function Class_EquipTutorial:OnComplete()
	NPE_TutorialDragButton:Hide();
	self.originFrame = nil;
	self.destFrame = nil;
	self.animationPlaying = false;

	self.data = nil;

	if self.EquipmentChangedTimer then
		self.EquipmentChangedTimer:Cancel();
	end

	EventRegistry:UnregisterCallback("ContainerFrame.AllBagsClosed", self);
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);
	EventRegistry:UnregisterCallback("ContainerFrame.CloseBag", self);
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBackpack", self);
	EventRegistry:UnregisterCallback("ContainerFrame.CloseBackpack", self);
	EventRegistry:UnregisterCallback("CharacterFrame.Show", self);
	EventRegistry:UnregisterCallback("CharacterFrame.Hide", self);
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);

	self.Timer = C_Timer.NewTimer(0.1, function()
		Tutorials.QueueSystem:TutorialFinished();
	end);
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics = class("EnhancedCombatTactics", Class_TutorialBase);
function Class_EnhancedCombatTactics:OnBegin()
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);

	local playerClass = TutorialHelper:GetClass();
	self.redirected = false;
	if playerClass == "WARRIOR" then
		Tutorials.EnhancedCombatTactics_Warrior:Begin();
		self.redirected = true;
		self:Complete();
	elseif playerClass == "ROGUE" then
		Tutorials.EnhancedCombatTactics_Rogue:Begin();
		self.redirected = true;
		self:Complete();
	elseif playerClass == "MONK" then
		-- currently there is not special monk training
	elseif playerClass == "PRIEST" or playerClass == "WARLOCK" or playerClass == "DRUID" then
		Tutorials.EnhancedCombatTactics_UseDoTs:Begin();
		self.redirected = true;
		self:Complete();
	elseif playerClass == "SHAMAN" or playerClass == "MAGE" then
		self.redirected = true;
		Tutorials.EnhancedCombatTactics_Ranged:Begin();
		self:Complete();
	elseif playerClass == "HUNTER" then
		self:Complete();-- Hunters do not have an Enhanced Combat Tutorial
	else
		self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
		Dispatcher:RegisterEvent("UNIT_TARGET", self);
	end
end

function Class_EnhancedCombatTactics:IsSpellOnActionBar(spellID, warningString, spellbookString)
	local button = TutorialHelper:GetActionButtonBySpellID(spellID);
	if button then
		return true;
	end

	Tutorials.QueueSystem:QueueSpellTutorial(spellID, warningString, spellbookString);
	return false;
end

function Class_EnhancedCombatTactics:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().EnhancedCombatTacticsCreatureID) then
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
	Tutorials.EnhancedCombatTactics.callback = GenerateClosure(self.ShowBuilderPrompt, self);
	if self.builderPointerID then
		return;
	end
	self:HideSpenderPrompt();

	Tutorials.EnhancedCombatTactics.spellID = self.combatData.resourceBuilderSpellID;
	local button = TutorialHelper:GetActionButtonBySpellID(Tutorials.EnhancedCombatTactics.spellID);
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
	Tutorials.EnhancedCombatTactics.callback = GenerateClosure(self.ShowSpenderPrompt, self);
	if self.spenderPointerID then
		return;
	end
	self:HideBuilderPrompt();

	Tutorials.EnhancedCombatTactics.spellID = self.combatData.resourceSpenderSpellID;
	local button = TutorialHelper:GetActionButtonBySpellID(Tutorials.EnhancedCombatTactics.spellID);
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

function Class_EnhancedCombatTactics:UNIT_POWER_FREQUENT(unit, resource)
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
	self:Complete();
end

function Class_EnhancedCombatTactics:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);

	if self.redirected == false then
		Tutorials.LowHealthWatcher:Begin();
	end

	self:HidePointerTutorials();
	self:HideScreenTutorial();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics For Warrior
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_Warrior = class("EnhancedCombatTactics_Warrior", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_Warrior:OnBegin()
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
end

function Class_EnhancedCombatTactics_Warrior:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().EnhancedCombatTacticsCreatureID) then
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

function Class_EnhancedCombatTactics_Warrior:UNIT_POWER_FREQUENT(unit, resource)
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

function Class_EnhancedCombatTactics_Warrior:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_EnhancedCombatTactics_Warrior:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

	Tutorials.LowHealthWatcher:Begin();

	self:HidePointerTutorials();
	self:HideScreenTutorial();
end

-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics For Rogue
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_Rogue = class("EnhancedCombatTactics_Rogue", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_Rogue:OnBegin()
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM", self);

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
	self:Complete();
end

function Class_EnhancedCombatTactics_Rogue:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", self);

	Tutorials.LowHealthWatcher:Begin();

	self:HidePointerTutorials();
	self:HideScreenTutorial();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics For Classes that Use DoTs
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_UseDoTs = class("EnhancedCombatTactics_UseDoTs", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_UseDoTs:OnBegin()
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
end

function Class_EnhancedCombatTactics_UseDoTs:COMBAT_LOG_EVENT_UNFILTERED()
	local eventData = {CombatLogGetCurrentEventInfo()};

	local unitGUID = eventData[8];
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().EnhancedCombatTacticsCreatureID) then
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
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().EnhancedCombatTacticsCreatureID) then
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
	self:Complete();
end

function Class_EnhancedCombatTactics_UseDoTs:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);

	Tutorials.LowHealthWatcher:Begin();

	self:HidePointerTutorials();
	self:HideScreenTutorial();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics for Ranged Classes
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_Ranged = class("EnhancedCombatTactics_Ranged", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_Ranged:OnBegin()
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
end

function Class_EnhancedCombatTactics_Ranged:AtCloseRange()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:ShowSpenderPrompt();
end

function Class_EnhancedCombatTactics_Ranged:StartRangedWatcher()
	local unit = TutorialHelper:GetFactionData().EnhancedCombatTacticsOverrideCreatureID;
	if (unit) then
		NPE_RangeManager:StartWatching(unit, NPE_RangeManager.Type.Unit, 6, function() self:AtCloseRange(); end, NPE_RangeManager.Mode.Any, TutorialHelper:GetFactionData().EnhancedCombatTacticsQuest);
	end
end

function Class_EnhancedCombatTactics_Ranged:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().EnhancedCombatTacticsCreatureID) then
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
	self:Complete();
end

function Class_EnhancedCombatTactics_Ranged:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_TARGETABLE_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

	Tutorials.LowHealthWatcher:Begin();

	self:HidePointerTutorials();
	self:HideScreenTutorial();
end


-- ------------------------------------------------------------------------------------------------------------
-- Eat Food Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_LowHealthWatcher = class("LowHealthWatcher", Class_TutorialBase);
function Class_LowHealthWatcher:OnBegin()
	Dispatcher:RegisterEvent("UNIT_HEALTH", self);
	Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self);
	self.inCombat = false;
end

function Class_LowHealthWatcher:PLAYER_REGEN_DISABLED()
	self.inCombat = true;
end

function Class_LowHealthWatcher:PLAYER_REGEN_ENABLED()
	self.inCombat = false;
end

function Class_LowHealthWatcher:UNIT_HEALTH(arg1)
	if ( arg1 == "player" ) then
		local heatlh = UnitHealth(arg1);
		local isDeadOrGhost = UnitIsDeadOrGhost("player");
		if (not isDeadOrGhost) and (heatlh/UnitHealthMax(arg1) <= 0.5 ) and not self.inCombat then
			Dispatcher:UnregisterEvent("UNIT_HEALTH", self);

			local tutorialData = TutorialHelper:GetFactionData();
			local container, slot = TutorialHelper:FindItemInContainer(tutorialData.FoodItem);
			if container and slot then
				Tutorials.EatFood:Begin(self.inCombat);
			end
			self:Complete();
		end
	end
end

function Class_LowHealthWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_LowHealthWatcher:OnComplete()
end


Class_EatFood = class("EatFood", Class_TutorialBase);
function Class_EatFood:OnBegin(inCombat)
	if self.tutorialSuccess == true then
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self);
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
	Dispatcher:RegisterEvent("UNIT_HEALTH", self);
	self.inCombat = inCombat or false;
	self.tutorialSuccess = false;

	if not self.inCombat then
		local key = TutorialHelper:GetBagBinding();
		local tutorialString = string.format(NPEV2_EAT_FOOD_P1, key);
		local content = {text = TutorialHelper:FormatString(tutorialString), icon=nil};

		-- Dirty hack to make sure all bags are closed
		TutorialHelper:CloseAllBags();

		self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
		Dispatcher:RegisterFunction("ToggleBackpack", function() self:BackpackOpened() end, true);
	end
end

function Class_EatFood:UNIT_HEALTH(arg1)
	if ( arg1 == "player" ) then
		local health = UnitHealth(arg1);
		local maxHealth = UnitHealthMax(arg1);

		if (health == maxHealth) and (self.tutorialSuccess == false) then
			self:Reset();
		end
	end
end

function Class_EatFood:BackpackOpened(inCombat)
	self:HideScreenTutorial();

	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	local tutorialData = TutorialHelper:GetFactionData();

	local container, slot = TutorialHelper:FindItemInContainer(tutorialData.FoodItem);
	if container and slot then
		local itemFrame = TutorialHelper:GetItemContainerFrame(container, slot)
		self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_EAT_FOOD_P2_BEGIN), "RIGHT", itemFrame, 0, 0, nil, "RIGHT");
	else
		self:Complete();
	end
end

function Class_EatFood:UNIT_SPELLCAST_SUCCEEDED(caster, spelllineID, spellID)
	local tutorialData = TutorialHelper:GetFactionData();
	if spellID == tutorialData.FoodSpellCast then
		Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		self.tutorialSuccess = true;
		self:HidePointerTutorials();
		local content = {text = TutorialHelper:FormatString(NPEV2_EAT_FOOD_P2_SUCCEEDED), icon=nil};
		self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
		self.CloseBagTimer = C_Timer.NewTimer(8, function()
			self:Complete();
		end);
	end
end

function Class_EatFood:Reset()
	if not self.tutorialSuccess then
		self:Complete();
		Tutorials.LowHealthWatcher:Begin();
	end
end

function Class_EatFood:PLAYER_DEAD()
	-- if we get interrupted by Death, start over
	self:Reset();
end

function Class_EatFood:PLAYER_REGEN_DISABLED()
	-- if we get interrupted by Combat, start over
	self.inCombat = true;
	self:Reset();
end

function Class_EatFood:PLAYER_REGEN_ENABLED()
	self.inCombat = false;
end

function Class_EatFood:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_EatFood:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:UnregisterEvent("PLAYER_REGEN_ENABLED", self);
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	Dispatcher:UnregisterEvent("UNIT_HEALTH", self);

	self:HidePointerTutorials();
	self:HideScreenTutorial();
end


-- ============================================================================================================
-- Vendor Watcher
-- ============================================================================================================
Class_Vendor_Watcher = class("Vendor_Watcher", Class_TutorialBase);
function Class_Vendor_Watcher:OnBegin()
	Dispatcher:RegisterEvent("MERCHANT_SHOW", self);

	self:HideScreenTutorial();
	self.buyTutorialComplete = false;
	self.sellTutorialComplete = false;
	self.buyBackTutorialComplete = false;

	EventRegistry:RegisterCallback("MerchantFrame.BuyBackTabShow", self.BuyBackTabHelp, self);
	EventRegistry:RegisterCallback("MerchantFrame.MerchantTabShow", self.MerchantTabHelp, self);
end

function Class_Vendor_Watcher:UpdateGreyItemPointer()
	if not self.merchantTab or self.sellTutorialComplete == true then
		if self.sellPointerID then
			self:HidePointerTutorial(self.sellPointerID);
		end
		return;
	end

	local itemFrame = nil;
	local maxNumContainters = 4;
	local greyItemQuality = 0;
	for containerIndex = 0, maxNumContainters do
		local slots = GetContainerNumSlots(containerIndex);
		if (slots > 0) then
			for slotIndex = 1, slots do
				local itemInfo = {GetContainerItemInfo(containerIndex, slotIndex)};
				local itemQuality = itemInfo[4];
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

function Class_Vendor_Watcher:BAG_UPDATE_DELAYED()
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	self:UpdateGreyItemPointer();
end

function Class_Vendor_Watcher:ITEM_LOCKED()
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);
end

function Class_Vendor_Watcher:BuyBackTabHelp()
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

function Class_Vendor_Watcher:MerchantTabHelp()
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

function Class_Vendor_Watcher:BAG_NEW_ITEMS_UPDATED()
	--the player bought something
	Dispatcher:UnregisterEvent("BAG_NEW_ITEMS_UPDATED", self);
	self:HidePointerTutorials();
	self:UpdateGreyItemPointer();
	self.buyTutorialComplete = true;
end

function Class_Vendor_Watcher:MERCHANT_SHOW()
	if self.buyTutorialComplete == true and self.sellTutorialComplete == true and self.buyBackTutorialComplete == true then
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("MERCHANT_CLOSED", self);
	Dispatcher:RegisterEvent("ITEM_LOCKED", self);
	self:MerchantTabHelp();
end

function Class_Vendor_Watcher:MERCHANT_CLOSED()
	Dispatcher:UnregisterEvent("MERCHANT_CLOSED", self);
	self.buyBackTab = false;
	self.merchantTab = false;
	self:HidePointerTutorials();
end

function Class_Vendor_Watcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Vendor_Watcher:OnComplete()
	Dispatcher:UnregisterEvent("MERCHANT_SHOW", self);
	self.buyPointerID = nil;
	self.sellPointerID = nil;
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- LFG Status Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_LFGStatusWatcher = class("LFGStatusWatcher", Class_TutorialBase);
function Class_LFGStatusWatcher:OnBegin()
	local _, instanceType = GetInstanceInfo();
	if instanceType ~= "none" then
		return;
	end

	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	self.onShowID = Dispatcher:RegisterScript(PVEFrame, "OnShow", 
		function()
			C_Timer.After(0.1, function()
				self:ShowLFG()
			end);
		end, 
		false);
	self.onHideID = Dispatcher:RegisterScript(PVEFrame, "OnHide", function() self:HideLFG() end, false);
	
	Tutorials.LookingForGroup:Begin();
	self:Restart();
end

function Class_LFGStatusWatcher:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().LookingForGroupQuest;
	if questID == questIDRemoved then
		self:Complete();
	end
end

function Class_LFGStatusWatcher:Restart()
	if PVEFrame:IsVisible() then
		self:ShowLFG();
	else
		ActionButton_ShowOverlayGlow(LFDMicroButton);
		self:ShowPointerTutorial(NPEV2_LFD_INTRO, "DOWN", LFDMicroButton, 0, 10, nil, "DOWN");
	end
end

function Class_LFGStatusWatcher:ShowLFG()
	self:HidePointerTutorials();
	ActionButton_HideOverlayGlow(LFDMicroButton);
	Tutorials.LookingForGroup:ShowDungeonSelectionInfo();
end

function Class_LFGStatusWatcher:HideLFG()
	self:HidePointerTutorials();
	self:HideScreenTutorial();

	if Tutorials.LookingForGroup.inQueue or LFGDungeonReadyPopup:IsShown() then
		-- the player is queued for the dungeon
		return;
	elseif self.tutorialSuccess then
		-- the tutorial is over
		self:Complete();
		return;
	end
	self:Restart();
end

function Class_LFGStatusWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_LFGStatusWatcher:OnComplete()
	if self.onHideID then
		Dispatcher:UnregisterScript(PVEFrame, "OnHide", self.onHideID);
		self.onHideID = nil;
	end

	if self.onShowID then
		Dispatcher:UnregisterScript(PVEFrame, "OnShow", self.onShowID);
		self.onShowID = nil;
	end

	ActionButton_HideOverlayGlow(LFDMicroButton);

	if not self.tutorialSuccess then
		local questID = TutorialHelper:GetFactionData().LookingForGroupQuest
		if (C_QuestLog.GetLogIndexForQuestID(questID)) then
			self:Restart();
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Looking For Group
-- ------------------------------------------------------------------------------------------------------------
Class_LookingForGroup = class("LookingForGroup", Class_TutorialBase);
function Class_LookingForGroup:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	Dispatcher:RegisterEvent("LFG_UPDATE", self);
	Dispatcher:RegisterEvent("LFG_PROPOSAL_SHOW", self);
	Dispatcher:RegisterEvent("LFG_PROPOSAL_SUCCEEDED", self);
	Dispatcher:RegisterEvent("LFG_PROPOSAL_FAILED", self);

	EventRegistry:RegisterCallback("LFDQueueFrameSpecificList_Update.EmptyDungeonList", self.EmptyDungeonList, self);
	EventRegistry:RegisterCallback("LFDQueueFrameSpecificList_Update.DungeonListReady", self.ReadyDungeonList, self);
	EventRegistry:RegisterCallback("LFGDungeonList.DungeonEnabled", self.DungeonEnabled, self);
	EventRegistry:RegisterCallback("LFGDungeonList.DungeonDisabled", self.DungeonDisabled, self);
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

	if QueueStatusMinimapButton:IsVisible() then
		self:ShowPointerTutorial(NPEV2_LFD_INFO_POINTER_MESSAGE, "RIGHT", QueueStatusMinimapButton, 20, 0, nil, "RIGHT"); 
	end
end

function Class_LookingForGroup:LFG_PROPOSAL_SHOW()
	GlowEmitterFactory:Hide(LFDQueueFrameFindGroupButton);
	self:HidePointerTutorials();
end

function Class_LookingForGroup:LFG_PROPOSAL_SUCCEEDED()
	Dispatcher:UnregisterEvent("LFG_PROPOSAL_SUCCEEDED", self);
	Tutorials.LFGStatusWatcher.tutorialSuccess = true;
	self:Complete();
end

function Class_LookingForGroup:LFG_PROPOSAL_FAILED()
	if(PVEFrame:IsShown()) then
		Dispatcher:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	else
		self:Complete();
		Tutorials.LFGStatusWatcher:ForceBegin();
	end
end

function Class_LookingForGroup:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().LookingForGroupQuest;
	if questID == questIDRemoved then
		self:Complete();
	end
end

function Class_LookingForGroup:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_LookingForGroup:OnComplete()
	GlowEmitterFactory:Hide(LFDQueueFrameFindGroupButton);
	Dispatcher:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	Dispatcher:UnregisterEvent("LFG_PROPOSAL_FAILED", self);
	Dispatcher:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE", self);

	EventRegistry:UnregisterCallback("LFDQueueFrameSpecificList_Update.EmptyDungeonList", self);
	EventRegistry:UnregisterCallback("LFDQueueFrameSpecificList_Update.DungeonListReady", self);
	EventRegistry:UnregisterCallback("LFGDungeonList.DungeonEnabled", self);
	EventRegistry:UnregisterCallback("LFGDungeonList.DungeonDisabled", self);

	self:HidePointerTutorials();
	self:HideScreenTutorial();
	Tutorials.QueueSystem:TutorialFinished();
end


-- ------------------------------------------------------------------------------------------------------------
-- Leave Party Prompt
-- /script Tutorials.LeavePartyPrompt:OnBegin()
-- ------------------------------------------------------------------------------------------------------------
Class_LeavePartyPrompt = class("LeavePartyPrompt", Class_TutorialBase);
function Class_LeavePartyPrompt:OnBegin()
	--self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_LEAVE_PARTY_PROMPT), "LEFT", PlayerFrame, 0, 0);
	self.pointerID = self:AddPointerTutorial(NPEV2_LEAVE_PARTY_PROMPT, "LEFT", PlayerFrame, 0, 0);
	C_Timer.After(10, function()
		self:Complete();
	end);
end

function Class_LeavePartyPrompt:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_LeavePartyPrompt:OnComplete()
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
		self.pointerID = nil;
	end
end

-- ============================================================================================================
-- Player Death
-- ============================================================================================================
Class_Death_Watcher = class("Death_Watcher", Class_TutorialBase);
function Class_Death_Watcher:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
end

function Class_Death_Watcher:PLAYER_DEAD()
	Tutorials.Death_ReleaseCorpse:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: [Relesase Corpse] - Map Prompt - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------
Class_Death_ReleaseCorpse = class("Death_ReleaseCorpse", Class_TutorialBase);
function Class_Death_ReleaseCorpse:OnBegin()
	self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_RELEASESPIRIT), "LEFT", StaticPopup1);
	Dispatcher:RegisterEvent("PLAYER_ALIVE", self);
end

-- PLAYER_ALIVE gets called when the player releases, not when they get back to their corpse
function Class_Death_ReleaseCorpse:PLAYER_ALIVE()
	self:Complete();
end

function Class_Death_ReleaseCorpse:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Death_ReleaseCorpse:OnComplete()
	if (UnitIsGhost("player")) then
		Tutorials.Death_MapPrompt:Begin();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - [Map Prompt] - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------
Class_Death_MapPrompt = class("Death_MapPrompt", Class_TutorialBase);
function Class_Death_MapPrompt:OnBegin()
	local key = TutorialHelper:GetMapBinding();
	local content = {text = NPEV2_FINDCORPSE, icon=nil, keyText=key};
	self:ShowSingleKeyTutorial(content);

	Dispatcher:RegisterEvent("CORPSE_IN_RANGE", self);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_MapPrompt:PLAYER_UNGHOST()
	self:Complete();
end

function Class_Death_MapPrompt:CORPSE_IN_RANGE()
	self:Complete();
end

function Class_Death_MapPrompt:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Death_MapPrompt:OnComplete()
	self:HideSingleKeyTutorial();
	Tutorials.Death_ResurrectPrompt:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - Map Prompt - [Resurrect Prompt]
-- ------------------------------------------------------------------------------------------------------------
Class_Death_ResurrectPrompt = class("Death_ResurrectPrompt", Class_TutorialBase);
function Class_Death_ResurrectPrompt:OnBegin()
	self.Timer = C_Timer.NewTimer(2, function() GlowEmitterFactory:Show(StaticPopup1Button1, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) end);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_ResurrectPrompt:PLAYER_UNGHOST()
	self:Complete();
end

function Class_Death_ResurrectPrompt:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Death_ResurrectPrompt:OnComplete()
	GlowEmitterFactory:Hide(StaticPopup1Button1);
end

-- ============================================================================================================
-- Misc Tutorials
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Highlight Item - When the user clicks on an item upgrade in the presentation frame
-- Open their bags and point to the item until mouseover
-- ------------------------------------------------------------------------------------------------------------
Class_HighlightItem = class("HighlightItem", Class_TutorialBase);
-- @param data: type STRUCT_ItemContainer
function Class_HighlightItem:OnBegin(data)

	-- Reopen all the bags to guarentee container order
	TutorialHelper:CloseAllBags();
	ToggleAllBags();

	self.itemFrame = TutorialHelper:GetItemContainerFrame(data.Container, data.ContainerSlot);
	if (self.itemFrame) then
		self:ShowPointerTutorial(TutorialHelper:FormatString(NPE_EQUIPITEM), "DOWN", self.itemFrame, 0, 15);

		Dispatcher:RegisterFunction("ContainerFrameItemButton_OnEnter", self);
		Dispatcher:RegisterFunction("ContainerFrame_Update", self, true);
	end
end

function Class_HighlightItem:ContainerFrameItemButton_OnEnter(frame)
	if (frame == self.itemFrame) then
		self:Complete();
	end
end

function Class_HighlightItem:ContainerFrame_Update()
	self:Interrupt();
end


-- ------------------------------------------------------------------------------------------------------------
-- Chat Frame
-- ------------------------------------------------------------------------------------------------------------
Class_ChatFrame = class("ChatFrame", Class_TutorialBase);
function Class_ChatFrame:OnInitialize()
	self.ShowCount = 0;
end

function Class_ChatFrame:OnBegin()
	if not IsActivePlayerNewcomer() then
		self:Complete();
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
function Class_ChatFrame:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed;

	if (self.Elapsed > 10) then
		self:Complete();
	end
end

function Class_ChatFrame:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_ChatFrame:OnComplete()
	Dispatcher:UnregisterEvent("OnUpdate", self);
end

-- ------------------------------------------------------------------------------------------------------------
-- Rogue Stealth Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_StealthTutorial = class("StealthTutorial", Class_TutorialBase);
function Class_StealthTutorial:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
end

function Class_StealthTutorial:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel == 3 then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		self.pointerID = self:AddPointerTutorial(NPEV2_STEALTH_TUTORIAL, "DOWN", StanceButton1, 0, 10, nil, "DOWN");
	end
end

local STEALTH_SPELL_ID = 1784;
function Class_StealthTutorial:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if spellID == STEALTH_SPELL_ID then
		self:Complete();
	end
end

function Class_StealthTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_StealthTutorial:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:HidePointerTutorial(self.pointerID);
end


-- ------------------------------------------------------------------------------------------------------------
-- Druid Forms Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_DruidFormTutorial = class("DruidFormTutorial", Class_TutorialBase);
function Class_DruidFormTutorial:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
end

function Class_DruidFormTutorial:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel == 5 then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		self.spellToCast = self.CAT_FORM_SPELL_ID;
		self.pointerID = self:AddPointerTutorial(NPEV2_CAT_FORM_TUTORIAL, "DOWN", StanceButton1, 0, 10, nil, "DOWN");
	end
	if newLevel == 8 then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		self.spellToCast = self.BEAR_FORM_SPELL_ID;
		self.pointerID = self:AddPointerTutorial(NPEV2_BEAR_FORM_TUTORIAL, "DOWN", StanceButton1, 0, 10, nil, "DOWN");
	end
end

function Class_DruidFormTutorial:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if spellID == TutorialData.DruidAnimalFormSpells.CAT_FORM_SPELL_ID then
		self:HidePointerTutorial(self.pointerID);
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	elseif spellID == TutorialData.DruidAnimalFormSpells.BEAR_FORM_SPELL_ID then
		self:Complete();
	end
end

function Class_DruidFormTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_DruidFormTutorial:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:HidePointerTutorial(self.pointerID);
end


-- ------------------------------------------------------------------------------------------------------------
-- Hunter Tame Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_HunterTameTutorial = class("HunterTameTutorial", Class_TutorialBase);
function Class_HunterTameTutorial:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);

	self:RequestBottomLeftActionBar();
	if not self.requested then
		if MultiBarBottomLeft:IsVisible() then
			-- the bottom left action bar is already visible
			if self:KnowsRequiredSpells() then
				-- we already know the hunter spells
				if self:CheckForSpellsOnActionBar() then
					-- and those spells are already on the action bar
					self:StartTameTutorial();
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
		Dispatcher:RegisterEvent("LEARNED_SPELL_IN_TAB", self);
	end
end

function Class_HunterTameTutorial:RequestBottomLeftActionBar()
	if not self.requested and not MultiBarBottomLeft:IsVisible() then
		-- request the bottom left action bar be shown
		Dispatcher:RegisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
		Dispatcher:RegisterEvent("UPDATE_EXTRA_ACTIONBAR", self);
		self.requested = RequestBottomLeftActionBar();
	end
end

function Class_HunterTameTutorial:KnowsRequiredSpells()
	for i, spellID in ipairs(TutorialData.HunterTamePetSpells) do
		if not IsSpellKnown(spellID) then
			return false;
		end
	end
	return true;
end

function Class_HunterTameTutorial:StartTameTutorial()
	local button = TutorialHelper:GetActionButtonBySpellID(1515);
	if button then
		self:ShowPointerTutorial(NPEV2_HUNTER_TAME_ANIMAL, "DOWN", button, 0, 30, nil, "UP");
		Dispatcher:RegisterEvent("PET_STABLE_UPDATE", self);
	else
		self:AddHunterSpellsToActionBar();
	end
end

function Class_HunterTameTutorial:CheckForSpellsOnActionBar()
	for i, spellID in ipairs(TutorialData.HunterTamePetSpells) do
		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		if not button then
			return false;
		end
	end
	return true;
end

function Class_HunterTameTutorial:AddHunterSpellsToActionBar()
	if not self.actionBarEventID then
		self.actionBarEventID = Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	end
	for i, spellID in ipairs(TutorialData.HunterTamePetSpells) do
		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		if not button then
			Tutorials.QueueSystem:QueueSpellTutorial(spellID, nil, NPEV2_SPELLBOOK_TUTORIAL, "MultiBarBottomLeftButton");
			return;
		end
	end

	self:StartTameTutorial();
end

function Class_HunterTameTutorial:SPELLS_CHANGED()
	Dispatcher:UnregisterEvent("SPELLS_CHANGED", self);
	self:AddHunterSpellsToActionBar();
end

function Class_HunterTameTutorial:LEARNED_SPELL_IN_TAB(spellID)
	if self:KnowsRequiredSpells() then
		Dispatcher:UnregisterEvent("LEARNED_SPELL_IN_TAB", self);
		if self:CheckForSpellsOnActionBar() then
			self:StartTameTutorial();
		else
			self:AddHunterSpellsToActionBar();
		end
	end
end

function Class_HunterTameTutorial:ACTIONBAR_SLOT_CHANGED(slot)
	local actionType, sID, subType = GetActionInfo(slot);
	local hunterSpellAddedToBar = false;
	for i, spellID in ipairs(TutorialData.HunterTamePetSpells) do
		if spellID == sID then
			hunterSpellAddedToBar = true;
			break;
		elseif (actionType == "flyout" and FlyoutHasSpell(sID, spellID)) then
			hunterSpellAddedToBar = true;
			break;
		end
	end

	if hunterSpellAddedToBar then
		self:AddHunterSpellsToActionBar();
	end
end

function Class_HunterTameTutorial:ACTIONBAR_SHOW_BOTTOMLEFT()
	Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	Dispatcher:UnregisterEvent("UPDATE_EXTRA_ACTIONBAR", self);
	if self:KnowsRequiredSpells() then
		self:AddHunterSpellsToActionBar();
	end
end

function Class_HunterTameTutorial:UPDATE_EXTRA_ACTIONBAR(data)
	if (MultiBarBottomLeft:IsShown() ) then
		Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	end
	if self:KnowsRequiredSpells() then
		if self:CheckForSpellsOnActionBar() then
			self:StartTameTutorial();
		else
			self:AddHunterSpellsToActionBar();
		end
	end
end

function Class_HunterTameTutorial:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().HunterTameTutorialQuestID;
	if questID == questIDRemoved then
		self:Complete();
	end
end

function Class_HunterTameTutorial:PET_STABLE_UPDATE()
	self:Complete();
end

function Class_HunterTameTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_HunterTameTutorial:OnComplete()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:UnregisterEvent("PET_STABLE_UPDATE", self);
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Hunter Tame Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_HunterStableTutorial = class("HunterStableTutorial", Class_TutorialBase);
function Class_HunterStableTutorial:OnBegin()
	local count = C_StableInfo.GetNumStablePets();
	if count > 0 then
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("PET_STABLE_SHOW", self);
	Dispatcher:RegisterEvent("PET_STABLE_CLOSED", self);
end

function Class_HunterStableTutorial:PET_STABLE_SHOW()
	local count = C_StableInfo.GetNumStablePets();
	if count > 0 then
		self:Complete();
		return;
	end
	self:ShowPointerTutorial(NPEV2_HUNTER_STABLE_PET, "LEFT", PetStableStabledPet5, 10, 0, nil, "LEFT");
end

function Class_HunterStableTutorial:PET_STABLE_CLOSED()
	local count = C_StableInfo.GetNumStablePets();
	if count > 0 then
		self:Complete();
	end
end

function Class_HunterStableTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_HunterStableTutorial:OnComplete()
	Dispatcher:UnregisterEvent("PET_STABLE_SHOW", self);
	Dispatcher:UnregisterEvent("PET_STABLE_CLOSED", self);
	self:HidePointerTutorials();
end

-- ------------------------------------------------------------------------------------------------------------
-- Auto Spell Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_AutoPushSpellWatcher = class("AutoPushSpellWatcher", Class_TutorialBase);
function Class_AutoPushSpellWatcher:OnBegin()
	local button = TutorialHelper:FindEmptyButton();
	local level = UnitLevel("player");
	if button and (level < 10) then
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
		SetCVar("AutoPushSpellToActionBar", 0);
	else
		self:Complete();
	end
end

function Class_AutoPushSpellWatcher:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel >= 10 then
		self:Complete();
	end
end

function Class_AutoPushSpellWatcher:ACTIONBAR_SLOT_CHANGED(slot)
	local button = TutorialHelper:FindEmptyButton();
	if not button then
		self:Complete();
	end
end

function Class_AutoPushSpellWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_AutoPushSpellWatcher:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	SetCVar("AutoPushSpellToActionBar", 1);
end

-- ------------------------------------------------------------------------------------------------------------
-- Mount Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_MountAddedWatcher = class("MountAddedWatcher", Class_TutorialBase);
function Class_MountAddedWatcher:OnBegin()
	self:StartTutorial();
end

function Class_MountAddedWatcher:StartTutorial()
	local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	self.mountID = mountData.mountID;
	local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(self.mountID);
	if isCollected then
		-- the player had already learned this mount
		self.proceed = true;
		self:NEW_MOUNT_ADDED();
		return;
	end

	Dispatcher:RegisterEvent("NEW_MOUNT_ADDED", self);
	self.proceed = true;

	local container, slot = self:CheckHasMountItem();
	if container and slot then
		-- Dirty hack to make sure all bags are closed
		TutorialHelper:CloseAllBags();
		Dispatcher:RegisterFunction("ToggleBackpack", function() self:BackpackOpened() end, true);
		local key = TutorialHelper:GetBagBinding();
		local tutorialString = TutorialHelper:FormatString(string.format(NPEV2_MOUNT_TUTORIAL_INTRO, key))
		self:ShowPointerTutorial(tutorialString, "DOWN", MainMenuBarBackpackButton, 0, 10, nil, "DOWN");
	else
		-- the player doesn't have the mount
		self.proceed = false;
		self:Complete();
	end
end

function Class_MountAddedWatcher:CheckHasMountItem()
	local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	local mountItem = mountData.mountItem;
	return TutorialHelper:FindItemInContainer(mountItem);
end

function Class_MountAddedWatcher:BackpackOpened()
	local container, slot = self:CheckHasMountItem();
	if container and slot then
		local itemFrame = TutorialHelper:GetItemContainerFrame(container, slot)
		self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P2_BEGIN, "DOWN", itemFrame, 0, 10, nil, "RIGHT");
	else
		-- the player doesn't have the mount
		self.proceed = false;
		self:Complete();
	end
end

function Class_MountAddedWatcher:NEW_MOUNT_ADDED(data)
	Dispatcher:UnregisterEvent("NEW_MOUNT_ADDED", self);
	TutorialHelper:CloseAllBags();
	ActionButton_ShowOverlayGlow(CollectionsMicroButton)
	self:HidePointerTutorials();

	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P2_NEW_MOUNT_ADDED, "DOWN", CollectionsMicroButton, 0, 10, nil, "DOWN");
	Dispatcher:RegisterFunction("ToggleCollectionsJournal", function()
		SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
		MountJournal_SelectByMountID(self.mountID);
		self:Complete()
	end, true);
end

function Class_MountAddedWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_MountAddedWatcher:OnComplete()
	Dispatcher:UnregisterEvent("NEW_MOUNT_ADDED", self);
	ActionButton_HideOverlayGlow(CollectionsMicroButton);
	if self.proceed == true then
		Tutorials.MountTutorial:Begin(self.mountID);
	end
end


Class_MountTutorial = class("MountTutorial", Class_TutorialBase);
function Class_MountTutorial:OnBegin(mountID)	
	EventRegistry:RegisterCallback("MountJournal.OnHide", self.MountJournalHide, self);

	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	self.mountID = mountID;

	if TutorialHelper:GetActionButtonBySpellID(self.mountID) then
		self:Complete();
		return;
	end

	C_Timer.After(0.1, function()
		self:MountJournalShow();
	end);
end

function Class_MountTutorial:MountJournalShow()
	self.originButton = MountJournal_GetMountButtonByMountID(self.mountID);
	self.destButton = TutorialHelper:FindEmptyButton();
	if(self.originButton and self.destButton) then
		NPE_TutorialDragButton:Show(self.originButton, self.destButton);
	end
	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P3, "LEFT", button or MountJournal, 0, 10, nil, "LEFT");
end

function Class_MountTutorial:MountJournalHide()
	self:Complete();
end

function Class_MountTutorial:ACTIONBAR_SLOT_CHANGED(slot)
	local actionType, sID, subType = GetActionInfo(slot);

	if sID == self.mountID then
		self:Complete();
	else
		local nextEmptyButton = TutorialHelper:FindEmptyButton();
		if not nextEmptyButton then
			-- no more empty buttons
			self:Complete();
		else
			NPE_TutorialDragButton:Hide();
			self.destButton = nextEmptyButton;
			NPE_TutorialDragButton:Show(self.originButton, self.destButton);
		end
	end
end

function Class_MountTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_MountTutorial:OnComplete()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	NPE_TutorialDragButton:Hide();
	self:HidePointerTutorials();

	local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	if TutorialHelper:GetActionButtonBySpellID(mountData.mountID) then
		Tutorials.UseMountWatcher:Begin();
	else
		Tutorials.QueueSystem:QueueMountTutorial();
		Tutorials.QueueSystem:TutorialFinished();
	end
end


Class_UseMountTutorialWatcher = class("UseMountWatcher", Class_TutorialBase);
function Class_UseMountTutorialWatcher:OnBegin()
	Dispatcher:RegisterEvent("ACTIONBAR_UPDATE_USABLE", self);
	local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	self.mountID = mountData.mountID;
	self:TryUseMount();
end

function Class_UseMountTutorialWatcher:TryUseMount()
	local button = TutorialHelper:GetActionButtonBySpellID(self.mountID);
	if button and IsUsableAction(button.action) then
		Tutorials.UseMountTutorial:Begin();
	else
		self:HidePointerTutorials();
	end
end

function Class_UseMountTutorialWatcher:ACTIONBAR_UPDATE_USABLE()
	self:TryUseMount()
end

function Class_UseMountTutorialWatcher:OnComplete()
	Dispatcher:UnregisterEvent("ACTIONBAR_UPDATE_USABLE", self);
	self:HidePointerTutorials();
end


Class_UseMountTutorial = class("UseMountTutorial", Class_TutorialBase);
function Class_UseMountTutorial:OnBegin()
	if IsMounted() then
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("ACTIONBAR_UPDATE_USABLE", self);
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	self.mountID = mountData.mountID;
	self.mountSpellID = mountData.mountSpellID;

	local button = TutorialHelper:GetActionButtonBySpellID(self.mountID);
	if button and IsUsableAction(button.action) then
		self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P4, "DOWN", button, 0, 10, nil, "UP");
	else
		self:Complete();
	end
end

function Class_UseMountTutorial:ACTIONBAR_UPDATE_USABLE()
	local button = TutorialHelper:GetActionButtonBySpellID(self.mountID);
	if not button or not IsUsableAction(button.action) then
		self:Complete();
	end
end

function Class_UseMountTutorial:UNIT_SPELLCAST_SUCCEEDED(caster, spelllineID, spellID)
	if self.mountSpellID == spellID then
		Tutorials.UseMountWatcher:Complete();
		self:Complete();
	end
end

function Class_UseMountTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_UseMountTutorial:OnComplete()
	Dispatcher:UnregisterEvent("ACTIONBAR_UPDATE_USABLE", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Spec Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_SpecTutorial = class("SpecTutorial", Class_TutorialBase);
function Class_SpecTutorial:OnBegin()
	Tutorials.QueueSystem:QueueSpecTutorial();
end

function Class_SpecTutorial:StartTutorial()
	local tutorialData = TutorialHelper:GetFactionData();
	local specQuestID = TutorialHelper:FilterByClass(tutorialData.SpecQuests);
	if C_QuestLog.IsQuestFlaggedCompleted(specQuestID) then 
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("GOSSIP_SHOW", self);
	ActionButton_ShowOverlayGlow(TalentMicroButton);
	self:ShowPointerTutorial(NPEV2_SPEC_TUTORIAL_GOSSIP_CLOSED, "DOWN", TalentMicroButton, 0, 10, nil, "DOWN");

	self.functionID = Dispatcher:RegisterFunction("ToggleTalentFrame", function()
		self:TutorialToggleTalentFrame();
		end, false);
end

function Class_SpecTutorial:QUEST_REMOVED(questIDRemoved)
	local tutorialData = TutorialHelper:GetFactionData();
	local specQuestID = TutorialHelper:FilterByClass(tutorialData.SpecQuests);

	if specQuestID == questIDRemoved then
		self:Complete();
	end
end

function Class_SpecTutorial:GOSSIP_SHOW()
	Dispatcher:RegisterEvent("UNIT_QUEST_LOG_CHANGED", self);
end

function Class_SpecTutorial:UNIT_QUEST_LOG_CHANGED()
	-- quest log changed
end

function Class_SpecTutorial:TutorialToggleTalentFrame()
	Dispatcher:UnregisterFunction("ToggleTalentFrame", self.functionID);

	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if ( not PlayerTalentFrame:IsShown() ) then
		ShowUIPanel(PlayerTalentFrame);
		if PlayerTalentFrame:IsShown() then
			self:ShowTalentChoiceHelp();
		end
	else
		self:ShowTalentChoiceHelp();
	end
end

function Class_SpecTutorial:ShowTalentChoiceHelp()
	ActionButton_HideOverlayGlow(TalentMicroButton);
	self:ShowPointerTutorial(NPEV2_SPEC_TUTORIAL_TOGGLE_TALENT_FRAME, "DOWN", PlayerTalentFrameSpecializationSpecButton1, 10, 0, nil, "DOWN");

	Dispatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);

	self.Timer = C_Timer.NewTimer(120, function() self:Complete() end);
end

function Class_SpecTutorial:PLAYER_SPECIALIZATION_CHANGED()
	Dispatcher:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);
	if self.Timer then
		self.Timer:Cancel();
	end
	self:Complete()
end

function Class_SpecTutorial:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_SpecTutorial:OnComplete()
	ActionButton_HideOverlayGlow(TalentMicroButton);
	self:HidePointerTutorials();
	Tutorials.QueueSystem:TutorialFinished();
end
