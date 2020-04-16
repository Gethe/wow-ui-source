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
				local content = {text = TutorialHelper:FormatString(self.screenString), icon=self.icon};
				self.PointerID = self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
				NPE_RangeManager:Shutdown();
				NPE_RangeManager:StartWatching(creatureID, NPE_RangeManager.Type.Unit, self.range, function() self:Complete(); end);
				return;
			end
		end
	end
	self:HidePointerTutorials();
	self:HideScreenTutorial();
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
	MainMenuBarBackpackButton:Hide();
end

function Class_Hide_Backpack:OnComplete()
	MainMenuBarBackpackButton:Show();
end

Class_Hide_MainMenuBar = class("Hide_MainMenuBar", Class_TutorialBase);
function Class_Hide_MainMenuBar:OnBegin()
	MainMenuBarArtFrame:Hide();
end

function Class_Hide_MainMenuBar:OnComplete()
	MainMenuBarArtFrame:Show();
end

Class_Hide_BagsBar = class("Hide_BagsBar", Class_TutorialBase);
function Class_Hide_BagsBar:OnBegin()
	MicroButtonAndBagsBar:Hide();
end

function Class_Hide_BagsBar:OnComplete()
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

function Class_Hide_StoreMicroButton:OnComplete()
	StoreMicroButton:Show();
end

Class_Hide_SpellbookMicroButton = class("Hide_SpellbookMicroButton", Class_TutorialBase);
function Class_Hide_SpellbookMicroButton:OnBegin()
	SpellbookMicroButton:Hide();
end

function Class_Hide_SpellbookMicroButton:OnComplete()
	SpellbookMicroButton:Show();
end

Class_Hide_CharacterMicroButton = class("Hide_CharacterMicroButton", Class_TutorialBase);
function Class_Hide_CharacterMicroButton:OnBegin()
	CharacterMicroButton:Hide();
end
function Class_Hide_CharacterMicroButton:OnComplete()
	CharacterMicroButton:Show();
end

Class_Hide_TargetFrame = class("Hide_TargetFrame", Class_TutorialBase);
function Class_Hide_TargetFrame:OnBegin()
	TargetFrame:Hide();
end

function Class_Hide_TargetFrame:OnComplete()
	TargetFrame:Show();
end

Class_Hide_StatusTrackingBar = class("Hide_StatusTrackingBar", Class_TutorialBase);
function Class_Hide_StatusTrackingBar:OnBegin()
	StatusTrackingBarManager:Hide();
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
		self:ShowPointerTutorial(NPEV2_TURN_MINIMAP_ON, "RIGHT", Minimap, 0, 10, nil, "RIGHT");
	end);

	C_Timer.After(12, function()
		self:HidePointerTutorials();
		self:Complete();
	end);
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
	self:HideScreenTutorial();

	C_Timer.After(2, function()
		self:ShowMouseKeyboardTutorial();
	end);
	EventRegistry:RegisterCallback("NPE_TutorialKeyboardMouseFrame.Closed", self.TutorialClosed, self);
end

function Class_Intro_KeyboardMouse:TutorialClosed()
	self:Complete();
end

function Class_Intro_KeyboardMouse:OnComplete()
	Tutorials.Intro_CameraLook:Begin();
end


-- ------------------------------------------------------------------------------------------------------------
-- Mouse Look Help - This shows using the mouse to look around
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CameraLook = class("Intro_CameraLook", Class_TutorialBase);
function Class_Intro_CameraLook:OnBegin()
	self.PlayerHasLooked = false;
	local content = {text = NPEV2_INTRO_CAMERA_LOOK, icon="newplayertutorial-icon-mouse-turn"};
	self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);

	print(GetBindingKey("MOVEFORWARD"));

	Dispatcher:RegisterEvent("PLAYER_STARTED_TURNING", self);
	Dispatcher:RegisterEvent("PLAYER_STOPPED_TURNING", self);
end

function Class_Intro_CameraLook:PLAYER_STARTED_TURNING()
	self.PlayerHasLooked = true;

end

function Class_Intro_CameraLook:PLAYER_STOPPED_TURNING()
	if self.PlayerHasLooked then
		self:Complete()
	end
end

function Class_Intro_CameraLook:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_STARTED_TURNING", self);
	Dispatcher:UnregisterEvent("PLAYER_STOPPED_TURNING", self);

	Tutorials.Intro_ApproachQuestGiver:Begin(); 
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
	Tutorials.Hide_MainMenuBar:Complete();
	Tutorials.Hide_TargetFrame:Complete();
	Tutorials.Intro_CombatTactics:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Intro Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CombatTactics = class("Intro_CombatTactics", Class_TutorialBase);
function Class_Intro_CombatTactics:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("PLAYER_LEAVE_COMBAT", self);

	local classData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	self.spellID = classData.firstSpellID;
	self.spellIDString = "{$"..self.spellID.."}";
	self.keyBindString = "{KB|"..self.spellID.."}";

	self:Reset();
end

function Class_Intro_CombatTactics:Reset()
	self.pointerID = nil;

	self:HidePointerTutorials();
	self:HideResourceCallout();

	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().StartingQuestTargetDummyCreatureID) then
		local playerClass = TutorialHelper:GetClass();
		if playerClass == "WARRIOR" or playerClass == "ROGUE" then
			Dispatcher:RegisterEvent("UNIT_POWER_FREQUENT", self);
		else
			local firstTime = true;
			self:ShowAbilityPrompt(firstTime);
			Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);		end
	else
		Dispatcher:RegisterEvent("UNIT_TARGET", self);
	end
end

function Class_Intro_CombatTactics:UNIT_TARGET()
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().StartingQuestTargetDummyCreatureID) then
		Dispatcher:UnregisterEvent("UNIT_TARGET", self);
		Dispatcher:RegisterEvent("UNIT_POWER_FREQUENT", self);
	end
end

function Class_Intro_CombatTactics:HideResourceCallout()
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
		self.pointerID = nil;
	end
end

function Class_Intro_CombatTactics:ResourceCallout()
	local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player", issecure());
	if not namePlatePlayer then
		return;
	end

	local playerClass = TutorialHelper:GetClass();
	local resourceString;
	if playerClass == "WARRIOR" then
		resourceString = NPEV2_RESOURCE_CALLOUT_WARRIOR;
	elseif playerClass == "ROGUE" or playerClass == "MONK" then
		resourceString = NPEV2_RESOURCE_CALLOUT_ENERGY;
	else
		return;
	end
	if not self.pointerID then
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

function Class_Intro_CombatTactics:ShowAbilityPrompt(firstTime)
	local classData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	local combatString;
	if firstTime == true then
		combatString = TutorialHelper:FormatString(classData.initialString:format(self.keyBindString, self.spellIDString));
	else
		combatString = TutorialHelper:FormatString(classData.reminderString:format(self.keyBindString, self.spellIDString));
	end
	
	local button = TutorialHelper:GetActionButtonBySpellID(self.spellID);
	self:ShowPointerTutorial(combatString, "DOWN", button, 0, 10, nil, "UP");
end

function Class_Intro_CombatTactics:UNIT_SPELLCAST_SUCCEEDED(caster, spelllineID, spellID)
	if spellID == self.spellID then
		Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

		local playerClass = TutorialHelper:GetClass();
		if playerClass == "WARRIOR" or playerClass == "ROGUE" then
			self:HidePointerTutorials();
			self.pointerID = nil;
			self:ResourceCallout();
		else
			local firstTime = false;
			self:ShowAbilityPrompt(firstTime);
		end
	end
end

function Class_Intro_CombatTactics:UNIT_POWER_FREQUENT(unit, resource)
	local button = TutorialHelper:GetActionButtonBySpellID(self.spellID);
	if button then
		local isUsable, notEnoughMana = IsUsableAction(button.action);
		if isUsable then
			Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
			local firstTime = true;
			self:ShowAbilityPrompt(firstTime);
			Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		end
	end
end

function Class_Intro_CombatTactics:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().StartingQuest;
	if questID == questIDRemoved then
		self:Complete();
	end
end

function Class_Intro_CombatTactics:OnComplete()
	self:HideResourceCallout();
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

	self.Timer = C_Timer.NewTimer(4, function() ActionButton_ShowOverlayGlow(QuestFrameAcceptButton) end);
end

function Class_AcceptQuest:QUEST_ACCEPTED()
	self:Complete();
end

function Class_AcceptQuest:OnComplete()
	if self.Timer then
		self.Timer:Cancel();
	end
	ActionButton_HideOverlayGlow(QuestFrameAcceptButton);
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

	local numChoices = GetNumQuestLogChoices()
	for i = 1, numChoices do
		local isUsable = select(5, GetQuestLogChoiceInfo(i));
		if (not isUsable) then
			areAllItemsUsable = false;
			break;
		end
	end

	if (GetNumQuestChoices() > 1) then
		--  Wait one frame to make sure the reward buttons have been positioned
		C_Timer.After(0.01, function() Tutorials.QuestRewardChoice:Begin(areAllItemsUsable); end);
	end
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

	self.Timer = C_Timer.NewTimer(4, function() ActionButton_ShowOverlayGlow(QuestFrameCompleteQuestButton) end);
end

function Class_TurnInQuest:OnComplete()
	if self.Timer then
		self.Timer:Cancel();
	end
	ActionButton_HideOverlayGlow(QuestFrameCompleteQuestButton);
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
	self:ShowPointerTutorial(NPEV2_QUEST_COMPLETE_HELP, "RIGHT", ObjectiveTrackerBlocksFrameHeader, 0, 10, nil, "RIGHT");
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

function Class_QuestCompleteHelp:OnCompelte()
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- XP Bar Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_XPBarTutorial = class("XPBarTutorial", Class_TutorialBase);
-- @param data: type STRUCT_ItemContainer
function Class_XPBarTutorial:OnBegin()
	Dispatcher:RegisterEvent("QUEST_TURNED_IN", self);
end

function Class_XPBarTutorial:QUEST_TURNED_IN(completedQuestID)
	Dispatcher:UnregisterEvent("QUEST_TURNED_IN", self);
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	Tutorials.Hide_StatusTrackingBar:Complete();

	local questID = TutorialHelper:GetFactionData().StartingQuest;
	if completedQuestID == questID then 
		self:ShowPointerTutorial(NPEV2_XP_BAR_TUTORIAL, "DOWN", StatusTrackingBarManager, 0, 10, nil, "DOWN"); 
	end
end

function Class_XPBarTutorial:QUEST_DETAIL()
	self:Complete();
end

function Class_XPBarTutorial:OnInitialize()
	self:HidePointerTutorials();
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
end


-- ------------------------------------------------------------------------------------------------------------
-- Repeatable Level Up Tutorial - Used to point out new abilities when a player levels up.
-- ------------------------------------------------------------------------------------------------------------
Class_LevelUpTutorial = class("LevelUpTutorial", Class_TutorialBase);
function Class_LevelUpTutorial:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
end

function Class_LevelUpTutorial:PLAYER_LEVEL_CHANGED(originallevel, newLevel)
	Tutorials.Hide_BagsBar:Complete();
	Tutorials.Hide_SpellbookMicroButton:Complete();

	if newLevel > 1 and newLevel < 10 then 
		LevelUpTutorial_spellIDlookUp = TutorialHelper:FilterByClass(TutorialData.LevelAbilitiesTable);
		local spellID = LevelUpTutorial_spellIDlookUp[newLevel];
		if spellID then
			if (newLevel == 3) then
				local playerClass = TutorialHelper:GetClass();
				if (playerClass == "ROGUE") then 
					Tutorials.StealthTutorial:Begin();
					return;
				end
			end
			Tutorials.AddSpellToActionBar:Begin(spellID, nil, NPEV2_SPELLBOOK_TUTORIAL);
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Add Spell To Action Bar
-- ------------------------------------------------------------------------------------------------------------
Class_AddSpellToActionBar = class("AddSpellToActionBar", Class_TutorialBase);
function Class_AddSpellToActionBar:OnBegin(spellID, warningString, spellMicroButtonString)
	if not spellID then
		self:Complete();
		return;
	end

	self.spellToAdd = spellID;
	self.spellIDString = "{$"..spellID.."}";
	self.warningString = warningString;
	self.spellMicroButtonString = spellMicroButtonString or NPEV2_SPELLBOOK_ADD_SPELL;

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

	if self.spellIDString then
		self:ShowPointerTutorial(TutorialHelper:FormatString(self.spellMicroButtonString:format(self.spellIDString)), "DOWN", SpellbookMicroButton, 0, 10, nil, "DOWN");
	end

	EventRegistry:RegisterCallback("SpellBookFrame.Show", self.SpellBookFrameShow, self);
end

function Class_AddSpellToActionBar:SpellBookFrameShow()
	EventRegistry:RegisterCallback("SpellBookFrame.Show", nil, self);
	EventRegistry:RegisterCallback("SpellBookFrame.Hide", self.SpellBookFrameHide, self);
	self:HidePointerTutorials();
	ActionButton_HideOverlayGlow(SpellbookMicroButton);
	self:RemindAbility();
end

function Class_AddSpellToActionBar:SpellBookFrameHide()
	EventRegistry:RegisterCallback("SpellBookFrame.Hide", nil, self);
	self:Complete();
end

function Class_AddSpellToActionBar:RemindAbility()
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);

	self:HideScreenTutorial();

	local tutorialString = NPEV2_SPELLBOOKREMINDER:format(self.spellIDString);
	tutorialString = TutorialHelper:FormatString(tutorialString)
	
	local spellBtn;
	local buttonIndex = SpellBookFrame_OpenToSpell(self.spellToAdd);
	if buttonIndex then
		spellBtn = _G["SpellButton" .. buttonIndex];
	end
	self:ShowPointerTutorial(tutorialString, "LEFT", spellBtn or SpellBookFrame, 50, 0, nil, "LEFT"); 
end

function Class_AddSpellToActionBar:ACTIONBAR_SLOT_CHANGED(slot)
	local _, spellID = GetActionInfo(slot)
	if spellID == self.spellToAdd then 
		Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
		self:Complete();
	end
end

function Class_AddSpellToActionBar:OnComplete()
	self:HidePointerTutorials();
	self:HideScreenTutorial();
	self.spellToAdd = nil;
end


-- ------------------------------------------------------------------------------------------------------------
-- Open Map - Main screen prompt to open the map
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_OpenMap = class("Intro_OpenMap", Class_TutorialBase);
function Class_Intro_OpenMap:OnBegin()
	local key = TutorialHelper:GetMapBinding();
	Dispatcher:RegisterScript(WorldMapFrame, "OnShow", function() 
		if self.Timer then
			self.Timer:Cancel();
		end
		self:Complete();
		end, true);

	self.Timer = C_Timer.NewTimer(4, function()
		local content = {text = NPEV2_OPENMAP, icon=nil, keyText=key};
		self:ShowSingleKeyTutorial(content);
	end);
end

function Class_Intro_OpenMap:OnComplete()
	if self.Timer then 
		self.Timer:Cancel()
	end
	self:HideSingleKeyTutorial();
	Tutorials.Intro_MapHighlights:Begin();
end


-- ------------------------------------------------------------------------------------------------------------
-- Map Pointers - This shows the map legend and the minimap legend
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_MapHighlights = class("Intro_MapHighlights", Class_TutorialBase);
function Class_Intro_MapHighlights:OnBegin()
	self.MapID = WorldMapFrame:GetMapID();
	self.Prompt = NPE_MAPCALLOUTBASE;
	local hasBlob = false;

	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local questID = C_QuestLog.GetQuestIDForLogIndex(i);
		if QuestUtils_IsQuestWatched(questID) and GetQuestPOIBlobCount(questID) > 0 then
			hasBlob = true;
			break;
		end
	end

	if (hasBlob) then
		self.Prompt = self.Prompt .. NPE_MAPCALLOUTAREA;
	else
		self.Prompt = self.Prompt .. NPE_MAPCALLOUTPOINT;
	end

	self:Display();

	self.Timer = C_Timer.NewTimer(8, function()
			self:AddPointerTutorial(TutorialHelper:FormatString(NPE_CLOSEWORLDMAP), "UP", WorldMapFrameCloseButton, 0, 15);
		end);

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
	if WorldMapFrame.isMaximized then
		self.MapPointerTutorialID = self:AddPointerTutorial(TutorialHelper:FormatString(self.Prompt), "LEFT", WorldMapFrame.ScrollContainer, -200, 0, nil);
	else
		self.MapPointerTutorialID = self:AddPointerTutorial(TutorialHelper:FormatString(self.Prompt), "UP", WorldMapFrame.ScrollContainer, 0, 100, nil);
	end
end

function Class_Intro_MapHighlights:OnSuppressed()
	NPE_TutorialPointerFrame:Hide(self.MapPointerTutorialID);
end

function Class_Intro_MapHighlights:OnUnsuppressed()
	self:Display();
end

function Class_Intro_MapHighlights:OnComplete()
end

function Class_Intro_MapHighlights:OnShutdown()
	if self.Timer then
		self.Timer:Cancel();
	end
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
	local prompt = NPEV2_LOOT_CORPSE;
	if (self.QuestMobID) then
		prompt = NPEV2_LOOT_CORPSE_QUEST;
	end
	local content = {text = prompt, icon="newplayertutorial-icon-mouse-rightbutton"};
	self:ShowScreenTutorial(content);
end

function Class_LootCorpse:OnComplete()
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
	Dispatcher:RegisterEvent("LOOT_OPENED", self);
	Dispatcher:RegisterEvent("LOOT_CLOSED", self);
end

--Function that handles looting from a quest object
function Class_LootPointer:LOOT_OPENED()
	alreadyLootedQuestItem = false;
	local btn = LootButton1;
	if (btn) then
		self:ShowPointerTutorial(TutorialHelper:FormatString(NPE_CLICKLOOT), "RIGHT", btn);  
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
	self.SuccessfulEquipCount = 0;
	Dispatcher:RegisterEvent("UNIT_INVENTORY_CHANGED", self);
end

function Class_EquipFirstItemWatcher:ItemSuccessfullyEquiped()
	self.SuccessfulEquipCount = self.SuccessfulEquipCount + 1;
end

function Class_EquipFirstItemWatcher:UNIT_INVENTORY_CHANGED()
	local upgrades = self:GetBestItemUpgrades();
	local slot, item = next(upgrades);
	local level = UnitLevel("player");

	-- Only show the equip tutorial 3 times
	if (item and (self.SuccessfulEquipCount < 2) and (level > 1)) then
		Tutorials.ShowBags:ForceBegin(item);
	end
end

function Class_EquipFirstItemWatcher:STRUCT_ItemContainer(itemID, characterSlot, container, containerSlot)
	return
	{
		ItemID = itemID,
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
			local ilvl = select(4, GetItemInfo(items[i].ItemID));
			if (ilvl > highestIlvl) then
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
	return ((itemInfo[12] == subClassType.classID) or (itemInfo[13] == subClassType.subClassID));
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

		local existingItemID = GetInventoryItemID("player", i);
		if (existingItemID ~= nil) then
			existingItemIlvl = select(4, GetItemInfo(existingItemID)) or 0;

			if (i == INVSLOT_MAINHAND) then
				existingItemWeaponType = self:GetWeaponType(existingItemID);
			end
		end

		local availableItems = {};
		GetInventoryItemsForSlot(i, availableItems);

		for packedLocation, itemID in pairs(availableItems) do
			local itemInfo = {GetItemInfo(itemID)};
			local ilvl = itemInfo[4];

			if (ilvl ~= nil) then
				if (ilvl > existingItemIlvl) then

					-- why can't I just have a continue statement?
					local match = true;

					-- if it's a main-hand, make sure it matches the current type, if there is one
					if (i == INVSLOT_MAINHAND) then
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

							table.insert(potentialUpgrades[i], self:STRUCT_ItemContainer(itemID, i, bag, slot));
						end
					end
				end
			end
		end
	end

	return potentialUpgrades;
end


-- ------------------------------------------------------------------------------------------------------------
-- Show Bags - Called when the player recieves their first item upgrade
-- ------------------------------------------------------------------------------------------------------------
Class_ShowBags = class("ShowBags", Class_TutorialBase);
function Class_ShowBags:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

-- @param data: type STRUCT_ItemContainer
function Class_ShowBags:OnBegin(data)
	if (MerchantFrame:IsVisible()) then
		self:Interrupt(self);
		return;
	end

	self.Data = data;

	-- Verify the item is still there.  Edge-case where someone managed to open their bags and equip the item
	-- between the time the tutorial was activated and actually begins.  e.g. They turn in a quest that rewards
	-- them with an item, activating this tutorial.  The quest frame is still open to accept the next quest causing
	-- this to be delayed, and in while the quest frame is open, they equip the item.
	if (not GetContainerItemID(data.Container, data.ContainerSlot)) then
		self:Interrupt(self);
		return;
	end

	-- Dirty hack to make sure all bags are closed
	TutorialHelper:CloseAllBags();

	Dispatcher:RegisterFunction("ToggleBackpack", function() self:Complete() end, true);

	local key = TutorialHelper:GetBagBinding();
	local tutorialString = TutorialHelper:FormatString(string.format(NPEV2_SHOW_BAGS, key))
	self:ShowPointerTutorial(tutorialString, "DOWN", MainMenuBarBackpackButton, 0, 0);
end

function Class_ShowBags:OnComplete()
	Tutorials.EquipItem:ForceBegin(self.Data);
end


-- ------------------------------------------------------------------------------------------------------------
-- Equip Item - Called when the player recieves their first item upgrade after they open their bags
-- ------------------------------------------------------------------------------------------------------------
Class_EquipItem = class("EquipItem", Class_TutorialBase);
-- @param data: type STRUCT_ItemContainer
function Class_EquipItem:OnBegin(data)
	if (MerchantFrame:IsVisible()) then
		self:Interrupt(self);
		return;
	end

	self.ItemData = data;
	self:UpdatePointer();

	Dispatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", self)
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self)
	Dispatcher:RegisterEvent("MERCHANT_SHOW", function() self:Interrupt(self) end, true);
end

function Class_EquipItem:UpdatePointer()
	local itemFrame = TutorialHelper:GetItemContainerFrame(self.ItemData.Container, self.ItemData.ContainerSlot);
	if (itemFrame) then
		self:ShowPointerTutorial(TutorialHelper:FormatString(NPE_EQUIPITEM), "DOWN", itemFrame, 0, 0);
	end
end

function Class_EquipItem:PLAYER_EQUIPMENT_CHANGED()
	if (GetInventoryItemID("player", self.ItemData.CharacterSlot) == self.ItemData.ItemID) then
		self:Complete()
	end
end

function Class_EquipItem:BAG_UPDATE_DELAYED()
	if (self.IsActive) then
		local container, slot = TutorialHelper:FindItemInContainer(self.ItemData.ItemID);
		if (container and slot) then
			self.ItemData.Container, self.ItemData.ContainerSlot = container, slot;
			self:UpdatePointer();
		else
			self:Interrupt();
			Tutorials.ShowBags:Interrupt();
		end
	end
end

function Class_EquipItem:OnComplete()
	Tutorials.EquipFirstItemWatcher:ItemSuccessfullyEquiped();
	Tutorials.Hide_CharacterMicroButton:Complete();
	Tutorials.OpenCharacterSheet:ForceBegin(self.ItemData);
end

function Class_EquipItem:OnShutdown()
	self.ItemData = nil;
end


-- ------------------------------------------------------------------------------------------------------------
-- Open Character Sheet - Called when the player recieves their first item upgrade after they open their bags
-- ------------------------------------------------------------------------------------------------------------
Class_OpenCharacterSheet = class("OpenCharacterSheet", Class_TutorialBase);
-- @param data: type STRUCT_ItemContainer
function Class_OpenCharacterSheet:OnBegin(data)
	local key = TutorialHelper:GetCharacterBinding();
	self:ShowPointerTutorial(TutorialHelper:FormatString(string.format(NPE_OPENCHARACTERSHEET, key)), "DOWN", CharacterMicroButton, 0, 0);

	if (CharacterFrame:IsVisible()) then
		self:Complete(data);
	else
		Dispatcher:RegisterScript(CharacterFrame, "OnShow", function() self:Complete(data) end, true);
	end
end

-- @param data: type STRUCT_ItemContainer
function Class_OpenCharacterSheet:OnComplete(data)
	Tutorials.HighlightEquippedItem:ForceBegin(data);
	Tutorials.CloseCharacterSheet:Begin(data);
end


-- ------------------------------------------------------------------------------------------------------------
-- Highlight Equipped Item - Called when the player recieves their first item upgrade after they open their bags
-- ------------------------------------------------------------------------------------------------------------
Class_HighlightEquippedItem = class("HighlightEquippedItem", Class_TutorialBase);
-- @param data: type STRUCT_ItemContainer
function Class_HighlightEquippedItem:OnBegin(data)
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
	local equippedItemFrame = _G[Slot[data.CharacterSlot]];

	self:ShowPointerTutorial(NPEV2_HIGHLIGHT_EQUIPPED_ITEM, "LEFT", equippedItemFrame);
	Dispatcher:RegisterScript(CharacterFrame, "OnHide", function() self:Complete() end, true)
end


-- ------------------------------------------------------------------------------------------------------------
-- Close Character Sheet - Prompts the player to close the character sheet if they haven't already done so
-- ------------------------------------------------------------------------------------------------------------
Class_CloseCharacterSheet = class("CloseCharacterSheet", Class_TutorialBase);
function Class_CloseCharacterSheet:OnBegin()
	Dispatcher:RegisterScript(CharacterFrame, "OnHide", function() self:Complete() end, true);

	self.Timer = C_Timer.NewTimer(20, function()
			self:ShowPointerTutorial(TutorialHelper:FormatString(NPE_CLOSECHARACTERSHEET), "LEFT", CharacterFrameCloseButton, -10);
		end);
end

function Class_CloseCharacterSheet:OnShutdown()
	self.Timer:Cancel();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics = class("EnhancedCombatTactics", Class_TutorialBase);
function Class_EnhancedCombatTactics:OnBegin()
	local playerClass = TutorialHelper:GetClass();
	self.redirected = false;
	if playerClass == "WARRIOR" then
		Tutorials.EnhancedCombatTactics_Warrior:Begin();
		self:Complete();
		self.redirected = true;
	elseif self.playerClass == "MONK" then
		--we need a special case for monk once class design is ready
		--print("HERE IS WHERE WOULD START MONK TRAINING.");
	elseif playerClass == "PRIEST" or playerClass == "WARLOCK" or playerClass == "DRUID" then
		Tutorials.EnhancedCombatTactics_UseDoTs:Begin();
		self.redirected = true;
		self:Complete();
	elseif playerClass == "SHAMAN" or playerClass == "MAGE" then
		Tutorials.EnhancedCombatTactics_Ranged:Begin();
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

	Tutorials.AddSpellToActionBar:Begin(spellID, warningString, spellbookString);
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

		self:ShowBuilderPrompt();
		Dispatcher:RegisterEvent("UNIT_POWER_FREQUENT", self);
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

function Class_EnhancedCombatTactics:ShowBuilderPrompt()
	self.spenderPointerID = nil;
	local button = TutorialHelper:GetActionButtonBySpellID(self.combatData.resourceBuilderSpellID);
	local keyBindString = "{KB|"..self.combatData.resourceBuilderSpellID.."}";
	local builderSpellString = "{$"..self.combatData.resourceBuilderSpellID.."}";
	local tutorialString = self.combatData.builderString:format(keyBindString, builderSpellString);

	self.builderPointerID = self:ShowPointerTutorial(TutorialHelper:FormatString(tutorialString), "DOWN", button or self.combatData.backupUIElement, 0, 10, nil, "DOWN")
end

function Class_EnhancedCombatTactics:ShowSpenderPrompt()
	self.builderPointerID = nil;
	local button = TutorialHelper:GetActionButtonBySpellID(self.combatData.resourceSpenderSpellID);
	local keyBindString = "{KB|"..self.combatData.resourceSpenderSpellID.."}";
	local spenderSpellIDString = "{$"..self.combatData.resourceSpenderSpellID.."}";
	local tutorialString = self.combatData.spenderString:format(keyBindString, spenderSpellIDString);

	self.spenderPointerID = self:ShowPointerTutorial(TutorialHelper:FormatString(tutorialString), "DOWN", button or self.combatData.backupUIElement, 0, 10, nil, "DOWN"); 
end

function Class_EnhancedCombatTactics:UNIT_POWER_FREQUENT(unit, resource)
	local resourceGateAmount = self.combatData.resourceGateAmount;
	local resource = UnitPower("player", self.combatData.resource);

	if resource < resourceGateAmount and not self.builderPointerID then
		self:ShowBuilderPrompt();
	elseif resource >= resourceGateAmount and not self.spenderPointerID then
		self:ShowSpenderPrompt();
	end
end

function Class_EnhancedCombatTactics:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
	if unitID == "player" then
		self:HidePointerTutorials();
		self:HideScreenTutorial();
		self.builderPointerID = nil;
		self.spenderPointerID = nil;
	end
end

function Class_EnhancedCombatTactics:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

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

	if resource >= resourceGateAmount and not self.spenderPointerID then
		self:ShowSpenderPrompt();
	end
end

function Class_EnhancedCombatTactics_Warrior:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
	if unitID == "player" then
		self:HidePointerTutorials();
		self:HideScreenTutorial();
		self.builderPointerID = nil;
		self.spenderPointerID = nil;

		if self.combatData.resourceBuilderSpellID == spellID then
			Dispatcher:RegisterEvent("UNIT_POWER_FREQUENT", self);-- now register so we can use RAGE
			Dispatcher:RegisterEvent("UNIT_TARGETABLE_CHANGED", self);
			Dispatcher:UnregisterEvent("UNIT_TARGET", self);
		end
	end
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
		self:HidePointerTutorials();
		self:HideScreenTutorial();
		self.builderPointerID = nil;
		self.spenderPointerID = nil;
	end
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
	self:HideScreenTutorial();
	self:HidePointerTutorials();
	self:ShowSpenderPrompt();
end

function Class_EnhancedCombatTactics_Ranged:StartRangedWatcher()
	local unit = TutorialHelper:GetFactionData().EnhancedCombatTacticsOverrideCreatureID;
	if (unit) then
		NPE_RangeManager:StartWatching(unit, NPE_RangeManager.Type.Unit, 6, function() self:AtCloseRange(); end);
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
		self:HidePointerTutorials();
		self.builderPointerID = nil;
		self.spenderPointerID = nil;
	end
end

function Class_EnhancedCombatTactics_Ranged:UNIT_TARGETABLE_CHANGED()
	self:HidePointerTutorials();
	self:HideScreenTutorial();
	Dispatcher:UnregisterEvent("UNIT_TARGETABLE_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
end

function Class_EnhancedCombatTactics_Ranged:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
	if unitID == "player" then
		self.builderPointerID = nil;
		self.spenderPointerID = nil;

		if self.combatData.resourceSpenderSpellID == spellID then
			Dispatcher:RegisterEvent("UNIT_TARGETABLE_CHANGED", self);
		end
	end
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
		if ( UnitHealth(arg1)/UnitHealthMax(arg1) <= 0.5 ) and not self.inCombat then
			Dispatcher:UnregisterEvent("UNIT_HEALTH", self);
			Tutorials.EatFood:Begin(self.inCombat);
			self:Complete();
		end
	end
end

function Class_LowHealthWatcher:OnComplete()
end

Class_EatFood = class("EatFood", Class_TutorialBase);
function Class_EatFood:OnBegin(inCombat)
	Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self);
	self.inCombat = inCombat or false;

	if not self.inCombat then
		local key = TutorialHelper:GetBagBinding();
		local tutorialString = string.format(NPEV2_EAT_FOOD_P1, key);
		local content = {text = TutorialHelper:FormatString(tutorialString), icon=nil};
		self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
		Dispatcher:RegisterFunction("ToggleBackpack", function() self:BackpackOpened() end, true);
	end
end

function Class_EatFood:BackpackOpened(inCombat)
	self:HideScreenTutorial();

	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	local tutorialData = TutorialHelper:GetFactionData();

	local container, slot = TutorialHelper:FindItemInContainer(tutorialData.FoodItem);
	if container and slot then
		local itemFrame = TutorialHelper:GetItemContainerFrame(container, slot)
		self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_EAT_FOOD_P2_BEGIN), "RIGHT", itemFrame, 0, 10, nil, "RIGHT");
	else
		self:Complete();
	end
end

function Class_EatFood:UNIT_SPELLCAST_SUCCEEDED(caster, spelllineID, spellID)
	local tutorialData = TutorialHelper:GetFactionData();
	if spellID == tutorialData.FoodSpellCast then
		self:HidePointerTutorials();
		local content = {text = TutorialHelper:FormatString(NPEV2_EAT_FOOD_P2_SUCCEEDED), icon=nil};
		self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low); 
		self.CloseBagTimer = C_Timer.NewTimer(8, function()
			self:Complete();
		end);
	end
end

function Class_EatFood:PLAYER_REGEN_DISABLED()
	-- if we get interrupted by Combat, start over
	self.inCombat = true;
	self:Complete();
	Tutorials.LowHealthWatcher:Begin();
end

function Class_EatFood:PLAYER_REGEN_ENABLED()
	self.inCombat = false;
end

function Class_EatFood:OnComplete()
	self:HidePointerTutorials();
	self:HideScreenTutorial();
end


-- ============================================================================================================
-- Vendor Watcher
-- ============================================================================================================
Class_Vendor_Watcher = class("Vendor_Watcher", Class_TutorialBase);
function Class_Vendor_Watcher:OnBegin()
	Dispatcher:RegisterEvent("MERCHANT_SHOW", self);

	self.buyTutorialComplete = false;
	self.sellTutorialComplete = false;
	self.buyBackTutorialComplete = false;

	EventRegistry:RegisterCallback("MerchantFrame.BuyBackTabShow", self.BuyBackTabHelp, self);
	EventRegistry:RegisterCallback("MerchantFrame.MerchantTabShow", self.MerchantTabHelp, self);
end

function Class_Vendor_Watcher:BuyBackTabHelp()
	if self.buyBackTutorialComplete == true then
		self:HideScreenTutorial();
		self:HidePointerTutorials();
		return;
	end
	self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_BUYBACK_ITEMS), "LEFT", MerchantFrame, 0, 10, nil, "LEFT");
	self.buyBackTutorialComplete = true;
end

function Class_Vendor_Watcher:UpdateGreyItemPointer()
	if self.sellTutorialComplete == true then
		self:HidePointerTutorials();
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

	if itemFrame then
		self:ShowPointerTutorial(NPEV2_SELL_GREY_ITEMS, "DOWN", itemFrame, 0, 0);
	else
		self.sellTutorialComplete = true;
		self:HidePointerTutorials();
	end
end

function Class_Vendor_Watcher:BAG_UPDATE_DELAYED()
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	self:UpdateGreyItemPointer();
end

function Class_Vendor_Watcher:ITEM_LOCKED()
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);
end

function Class_Vendor_Watcher:MerchantTabHelp()
	if self.buyTutorialComplete == true then
		self:HideScreenTutorial();
		self:HidePointerTutorials();
	else
		Dispatcher:RegisterEvent("BAG_NEW_ITEMS_UPDATED", self);
		local content = {text = TutorialHelper:FormatString(NPEV2_SELL_ITEMS_TO_VENDOR), icon="newplayertutorial-icon-mouse-rightbutton"};
		self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
		self:UpdateGreyItemPointer();

		self.Timer = C_Timer.NewTimer(2, function()
			self:AddPointerTutorial(TutorialHelper:FormatString(NPEV2_BUY_ITEMS_FROM_VENDOR), "LEFT", MerchantItem2, 0, 15);
		end);
	end
end

function Class_Vendor_Watcher:BAG_NEW_ITEMS_UPDATED()
	--the player bought something
	Dispatcher:UnregisterEvent("BAG_NEW_ITEMS_UPDATED", self);
	self:HideScreenTutorial();
	self:HidePointerTutorials();
	self:UpdateGreyItemPointer();
	self.buyTutorialComplete = true;
end

function Class_Vendor_Watcher:MERCHANT_SHOW()
	Dispatcher:RegisterEvent("MERCHANT_CLOSED", self);
	Dispatcher:RegisterEvent("ITEM_LOCKED", self);
	Dispatcher:UnregisterEvent("MERCHANT_SHOW", self);

	self:MerchantTabHelp();
end

function Class_Vendor_Watcher:MERCHANT_CLOSED()
	Dispatcher:UnregisterEvent("MERCHANT_SHOW", self);
	Dispatcher:UnregisterEvent("MERCHANT_CLOSED", self);
	self:HideScreenTutorial();
	self:HidePointerTutorials();
end

-- ------------------------------------------------------------------------------------------------------------
-- Looking For Group
-- ------------------------------------------------------------------------------------------------------------
Class_LookingForGroup = class("LookingForGroup", Class_TutorialBase);
function Class_LookingForGroup:OnBegin()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterScript(PVEFrame, "OnShow", function() self:ShowLFG() end, true);
	Dispatcher:RegisterScript(PVEFrame, "OnHide", function() self:HideLFG() end, true);

	Dispatcher:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	Dispatcher:RegisterEvent("LFG_ROLE_UPDATE", self);

	ActionButton_ShowOverlayGlow(LFDMicroButton);
	self:ShowPointerTutorial(NPEV2_LFD_INTRO, "DOWN", LFDMicroButton, 0, 10, nil, "DOWN"); 
end

function Class_LookingForGroup:ShowLFG()
	ActionButton_HideOverlayGlow(LFDMicroButton);
	self:HidePointerTutorials();
	C_Timer.After(0.1, function()
		self:CheckRoleInfo();
	end);
end

function Class_LookingForGroup:HideLFG()
	self:HidePointerTutorials();
	self:HideScreenTutorial();
end

function Class_LookingForGroup:CheckRoleInfo()
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
	end

	local tankChecked = LFGRole_GetChecked(LFDQueueFrameRoleButtonTank);
	local healChecked = LFGRole_GetChecked(LFDQueueFrameRoleButtonHealer);
	local dpsChecked = LFGRole_GetChecked(LFDQueueFrameRoleButtonDPS);

	if (tankChecked or healChecked or dpsChecked) then
		-- a role has been selected, go straight to dungeon info
		self:ShowDungeonSelectionInfo();
	else
		-- player needs to select a valid role
		self:ShowRoleInfo();
	end
end

function Class_LookingForGroup:ShowDungeonSelectionInfo()
	self:HidePointerTutorial(self.rolePointerID);
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
	end

	if LFDQueueFrameSpecific:IsVisible() then
		self.pointerID = self:AddPointerTutorial(NPEV2_LFD_SPECIFIC_DUNGEON, "LEFT", LFDQueueFrameSpecific, 0, 10, nil, "LEFT");
		self.randomID = Dispatcher:RegisterScript(LFDQueueFrameRandom, "OnShow", function() self:ShowDungeonSelectionInfo() end, true);
	elseif LFDQueueFrameRandom:IsVisible() then
		self.pointerID = self:AddPointerTutorial(NPEV2_LFD_RANDOM_DUNGEON, "LEFT", LFDQueueFrameTypeDropDown, 0, 10, nil, "LEFT");
		self.specificID = Dispatcher:RegisterScript(LFDQueueFrameSpecific, "OnShow", function() self:ShowDungeonSelectionInfo() end, true);
	end
end

function Class_LookingForGroup:LFG_ROLE_UPDATE()
	self:CheckRoleInfo();
end

function Class_LookingForGroup:ShowRoleInfo()
	local content = {text = TutorialHelper:FormatString(NPEV2_LFD_ROLE_INFO), icon=nil};
	self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
	self.rolePointerID = self:AddPointerTutorial(NPEV2_LFD_SELECT_ROLE, "LEFT", LFDQueueFrameRoleButtonDPS, 0, 0, nil, "RIGHT"); 
end

function Class_LookingForGroup:LFG_QUEUE_STATUS_UPDATE()
	if self.specificID then
		Dispatcher:UnregisterScript(LFDQueueFrameSpecific, "OnShow", self.specificID);
	end
	if self.randomID then
		Dispatcher:UnregisterScript(LFDQueueFrameRandom, "OnShow", self.randomID);
	end
	
	self:ShowPointerTutorial(NPEV2_LFD_INFO_POINTER_MESSAGE, "RIGHT", QueueStatusMinimapButton, 0, 10, nil, "RIGHT"); 
	
	local content = {text = NPEV2_LFD_INFO_MESSAGE, icon=nil};
	self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
	Dispatcher:RegisterEvent("LFG_PROPOSAL_SHOW", self);
end

function Class_LookingForGroup:LFG_PROPOSAL_SHOW()
	Dispatcher:UnregisterEvent("LFG_PROPOSAL_SHOW", self);
	self:Complete();
end

function Class_LookingForGroup:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().LookingForGroupQuest;
	if questID == questIDRemoved then
		self:Complete();
	end
end

function Class_LookingForGroup:OnComplete()
	self:HidePointerTutorials();
	self:HideScreenTutorial();
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
	self:ShowPointerTutorial(TutorialHelper:FormatString(NPE_RELEASESPIRIT), "LEFT", StaticPopup1);
	Dispatcher:RegisterEvent("PLAYER_ALIVE", self);
end

-- PLAYER_ALIVE gets called when the player releases, not when they get back to their corpse
function Class_Death_ReleaseCorpse:PLAYER_ALIVE()
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
	local content = {text = TutorialHelper:FormatString(string.format(NPE_FINDCORPSE, key)), icon=nil};

	self:ShowScreenTutorial(content);
	Dispatcher:RegisterEvent("CORPSE_IN_RANGE", self);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_MapPrompt:PLAYER_UNGHOST()
	self:Interrupt(self);
end

function Class_Death_MapPrompt:CORPSE_IN_RANGE()
	self:Complete();
end

function Class_Death_MapPrompt:OnComplete()
	Tutorials.Death_ResurrectPrompt:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - Map Prompt - [Resurrect Prompt]
-- ------------------------------------------------------------------------------------------------------------
Class_Death_ResurrectPrompt = class("Death_ResurrectPrompt", Class_TutorialBase);
function Class_Death_ResurrectPrompt:OnBegin()
	self:ShowPointerTutorial(TutorialHelper:FormatString(NPE_RESURRECT), "UP", StaticPopup1);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_ResurrectPrompt:PLAYER_UNGHOST()
	self:Complete();
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
-- Prompts the player if they open the chat frame.  also auto closes it if it sits open for a while
-- ------------------------------------------------------------------------------------------------------------
Class_ChatFrame = class("ChatFrame", Class_TutorialBase);
function Class_ChatFrame:OnInitialize()
	self.ShowCount = 0;
end

function Class_ChatFrame:OnBegin(editBox)
	if (editBox) then
		self.EditBox = editBox;
		self.ShowCount = self.ShowCount + 1;

		if (self.ShowCount == 1) then
			self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_CHATFRAME), "LEFT", editBox);
		end

		self.Elapsed = 0;
		Dispatcher:RegisterEvent("OnUpdate", self);
		Dispatcher:RegisterFunction("ChatEdit_DeactivateChat", function() self:Complete() end, true);
	end
end

function Class_ChatFrame:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed;

	if (self.Elapsed > 30) then
		if (self.EditBox) then
			ChatEdit_DeactivateChat(self.EditBox);
		end
		self:Interrupt(self);
	end
end

function Class_ChatFrame:OnShutdown()
	self.EditBox = nil;
end

function Class_ChatFrame:OnComplete()
	Dispatcher:UnregisterEvent("OnUpdate", self);
	Dispatcher:RegisterFunction("ChatEdit_DeactivateChat", nil, true);
end

-- ------------------------------------------------------------------------------------------------------------
-- Rogue Stealth Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_StealthTutorial = class("StealthTutorial", Class_TutorialBase);
function Class_StealthTutorial:OnBegin()
	self:ShowPointerTutorial(NPEV2_STEALTH_TUTORIAL, "DOWN", StanceButton1, 0, 10, nil, "DOWN"); 
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
end

local STEALTH_SPELL_ID = 1784;
function Class_StealthTutorial:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if spellID == STEALTH_SPELL_ID then
		self:Complete();
	end
end

function Class_StealthTutorial:OnComplete()
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Auto Spell Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_AutoPushSpellWatcher = class("AutoPushSpellWatcher", Class_TutorialBase);
function Class_AutoPushSpellWatcher:OnBegin()
	local level = UnitLevel("player");
	if level < 10 then
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
		SetCVar("AutoPushSpellToActionBar", 0);
	else
		self:Complete();
	end
end

function Class_AutoPushSpellWatcher:PLAYER_LEVEL_CHANGED(originallevel, newLevel)
	if newLevel >= 10 then
		self:Complete();
	end
end

function Class_AutoPushSpellWatcher:OnComplete()
	SetCVar("AutoPushSpellToActionBar", 1);
end

-- ------------------------------------------------------------------------------------------------------------
-- Mount Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_MountAddedWatcher = class("MountAddedWatcher", Class_TutorialBase);
function Class_MountAddedWatcher:OnBegin()
	Dispatcher:RegisterEvent("NEW_MOUNT_ADDED", self);
	self.proceed = true;

	local container, slot = self:CheckHasMountItem();
	if container and slot then
		-- Dirty hack to make sure all bags are closed
		TutorialHelper:CloseAllBags();
		Dispatcher:RegisterFunction("ToggleBackpack", function() self:BackpackOpened() end, true);
		self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_INTRO, "DOWN", MainMenuBarBackpackButton, 0, 10, nil, "DOWN");
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
		self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P2_BEGIN, "RIGHT", itemFrame, 0, 10, nil, "RIGHT"); 
	else
		-- the player doesn't have the mount
		self.proceed = false;
		self:Complete();
	end
end

function Class_MountAddedWatcher:NEW_MOUNT_ADDED(ID, data)
	Dispatcher:UnregisterEvent("NEW_MOUNT_ADDED", self);
	TutorialHelper:CloseAllBags();
	ActionButton_ShowOverlayGlow(CollectionsMicroButton) 
	self:HidePointerTutorials();

	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P2_NEW_MOUNT_ADDED, "DOWN", CollectionsMicroButton, 0, 10, nil, "DOWN");
	Dispatcher:RegisterFunction("ToggleCollectionsJournal", function()
		self:Complete()
	end, true);
end

function Class_MountAddedWatcher:OnComplete()
	Dispatcher:UnregisterEvent("NEW_MOUNT_ADDED", self);
	ActionButton_HideOverlayGlow(CollectionsMicroButton);
	if self.proceed == true then
		Tutorials.MountTutorial:Begin();
	end
end


Class_MountTutorial = class("MountTutorial", Class_TutorialBase);
function Class_MountTutorial:OnBegin()
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P3, "LEFT", MountJournal, 0, 10, nil, "LEFT");

	C_Timer.After(5, function()
		Dispatcher:RegisterFunction("ToggleCollectionsJournal", function()
			self:Complete()
		end, true);
	end);
end

function Class_MountTutorial:ACTIONBAR_SLOT_CHANGED(slot)
	local _, spellID = GetActionInfo(slot)
	local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	local mountID = mountData.mountID;

	if spellID == mountID then 
		self:Complete()
	end
end

function Class_MountTutorial:OnComplete()
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Spec Tutorial 
-- ------------------------------------------------------------------------------------------------------------
Class_SpecTutorial = class("SpecTutorial", Class_TutorialBase);
function Class_SpecTutorial:OnBegin()
	ActionButton_ShowOverlayGlow(TalentMicroButton);
	self:ShowPointerTutorial(NPEV2_SPEC_TUTORIAL_GOSSIP_CLOSED, "DOWN", TalentMicroButton, 0, 10, nil, "DOWN");

	self.functionID = Dispatcher:RegisterFunction("ToggleTalentFrame", function() 
		self:TutorialToggleTalentFrame();
		end, false);
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
	self:ShowPointerTutorial(NPEV2_SPEC_TUTORIAL_TOGGLE_TALENT_FRAME, "LEFT", PlayerTalentFrame, 0, 10, nil, "LEFT"); 
		
	Dispatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);
	
	self.Timer = C_Timer.NewTimer(8, function() self:Complete() end);
end

function Class_SpecTutorial:PLAYER_SPECIALIZATION_CHANGED()
	Dispatcher:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);
	if self.Timer then
		self.Timer:Cancel();
	end
	self:Complete()
end

function Class_SpecTutorial:OnComplete()
	self:HidePointerTutorials();
end
