local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;

-- ------------------------------------------------------------------------------------------------------------
-- Auto Push Spell Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_AutoPushSpellWatcher = class("AutoPushSpellWatcher", Class_TutorialBase);
function Class_AutoPushSpellWatcher:OnInitialize()
	self:SetMaxLevel(TutorialData.MAX_SPELL_HELP_LEVEL);
end

function Class_AutoPushSpellWatcher:OnBegin()
end

function Class_AutoPushSpellWatcher:StartWatching()
	local button = TutorialHelper:FindEmptyButton();
	if button then
		Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
		SetCVar("AutoPushSpellToActionBar", 0);
	else
		self:Complete();
	end
end

function Class_AutoPushSpellWatcher:StopWatching()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
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
	self:StopWatching();
	SetCVar("AutoPushSpellToActionBar", 1);
end

-- ------------------------------------------------------------------------------------------------------------
-- Ability Watcher - checks on relog or reloadui if the player has their abilities on their action bar
-- ------------------------------------------------------------------------------------------------------------
Class_AbilityWatcher = class("AbilityWatcher", Class_TutorialBase);
function Class_AbilityWatcher:OnInitialize()
	self.playerClass = TutorialHelper:GetClass();
end

function Class_AbilityWatcher:OnBegin()
end

function Class_AbilityWatcher:StartWatching()
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_ENTERING_WORLD", self);
	self:CheckAbilities();
end

function Class_AbilityWatcher:StopWatching()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:UnregisterEvent("PLAYER_ENTERING_WORLD", self);
end

function Class_AbilityWatcher:CheckAbilities()
	if self.playerClass == "ROGUE" or self.playerClass == "DRUID" then
		local form = GetShapeshiftFormID();
		if form ~= nil then
			TutorialLogic:CheckFormSpells()
			return;
		end
	end

	local LevelUpTutorial_spellIDlookUp = TutorialHelper:FilterByClass(TutorialData.LevelAbilitiesTable);
	local playerLevel = UnitLevel("player");
	local warningString = nil;
	local preferredActionBar = nil;
	for startLevel = 1, playerLevel do
	 	local spellID = LevelUpTutorial_spellIDlookUp[startLevel];
		if spellID then
			local button = TutorialHelper:GetActionButtonBySpellID(spellID);
			if not button then
				TutorialManager:Queue(Class_AddSpellToActionBarService.name, spellID, warningString, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar);
			end
		end
	end

	local classData = TutorialHelper:FilterByClass(TutorialData.ClassData);
	local classSpellID = classData.classQuestSpellID;
	if classSpellID then
		preferredActionBar = TutorialHelper:GetClass() == "ROGUE" and "MultiBarBottomLeftButton" or nil;
		TutorialManager:Queue(Class_AddSpellToActionBarService.name, classSpellID, nil, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar);
	end

	self:Complete();
end

function Class_AbilityWatcher:PLAYER_ENTERING_WORLD()
	Dispatcher:UnregisterEvent("PLAYER_ENTERING_WORLD", self);
	self:CheckAbilities();
end

function Class_AbilityWatcher:ACTIONBAR_SLOT_CHANGED(slot)
	if slot == 0 then
		Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
		self:CheckAbilities();
	end
end

function Class_AbilityWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_AbilityWatcher:OnComplete()
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- UI Watcher - turns off and on various UI elements
-- ------------------------------------------------------------------------------------------------------------
Class_UI_Watcher = class("UI_Watcher", Class_TutorialBase);
function Class_UI_Watcher:OnInitialize()
	self:SetMaxLevel(TutorialData.MAX_UI_HIDE_LEVEL);
end

function Class_UI_Watcher:OnBegin()
end

function Class_UI_Watcher:StartWatching()
	self.questID = TutorialData:GetFactionData().ShowAllUIQuest;
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:RegisterEvent("QUEST_ACCEPTED", self);
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);

	self.tutorialData = TutorialData:GetFactionData();

	local showBackpack = false;
	local showBagsBar = false;
	local showSpellbookButton = false;
	local showCharacterButton = false;
	local showOtherButtons = false;
	local showTargetFrame = false;
	local showStatusTrackingBar = false;
	local showStoreButton = false;

	local level = UnitLevel("player");
	if level > 1 then
		showBagsBar = true;
		showSpellbookButton = true;
	end

	if C_QuestLog.IsQuestFlaggedCompleted(self.tutorialData.StartingQuest) then
		-- the starting quest is completed
		showTargetFrame = true;
		showStatusTrackingBar = true;
	end

	if C_QuestLog.IsQuestFlaggedCompleted(self.tutorialData.ShowAllUIQuest) then
		-- the show all ui quest is completed
		self:Complete();
		return;
	end

	self:SetShown(TutorialData.UI_Elements.BACKPACK, showBackpack);
	self:SetShown(TutorialData.UI_Elements.BAGS_BAR, showBagsBar);
	self:SetShown(TutorialData.UI_Elements.MAIN_BAGS_BUTTON, showBagsBar);	
	self:SetShown(TutorialData.UI_Elements.SPELLBOOK_MICROBUTTON, showSpellbookButton);
	self:SetShown(TutorialData.UI_Elements.OTHER_MICROBUTTONS, showOtherButtons);
	self:SetShown(TutorialData.UI_Elements.STORE_MICROBUTTON, showStoreButton);
	self:SetShown(TutorialData.UI_Elements.TARGET_FRAME, showTargetFrame);
	self:SetShown(TutorialData.UI_Elements.STATUS_TRACKING_BAR, showStatusTrackingBar);
end

function Class_UI_Watcher:StopWatching()
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:UnregisterEvent("QUEST_ACCEPTED", self);
	Dispatcher:UnregisterEvent("QUEST_COMPLETE", self);
end

function Class_UI_Watcher:SetShown(uiElement, shown)
	if (not self.IsActive) then return; end

	for k, v in pairs(uiElement) do
		v:SetShown(shown);
	end
end

function Class_UI_Watcher:QUEST_ACCEPTED(questID)
	if (not self.IsActive) then return; end

	if questID == self.tutorialData.ShowAllUIQuest then
		self:SetShown(TutorialData.UI_Elements.BACKPACK, true);
		self:SetShown(TutorialData.UI_Elements.BAGS_BAR, true);
		self:SetShown(TutorialData.UI_Elements.MAIN_BAGS_BUTTON, true);
		self:SetShown(TutorialData.UI_Elements.OTHER_MICROBUTTONS, true);
		self:SetShown(TutorialData.UI_Elements.SPELLBOOK_MICROBUTTON, true);
		self:SetShown(TutorialData.UI_Elements.STORE_MICROBUTTON, true);
		self:SetShown(TutorialData.UI_Elements.TARGET_FRAME, true);
		self:SetShown(TutorialData.UI_Elements.STATUS_TRACKING_BAR, true);
		self:Complete();
	end
end

function Class_UI_Watcher:QUEST_COMPLETE()
	if (not self.IsActive) then return; end

	if C_QuestLog.IsQuestFlaggedCompleted(self.tutorialData.StartingQuest) then
		self:SetShown(TutorialData.UI_Elements.TARGET_FRAME, true);
		self:SetShown(TutorialData.UI_Elements.STATUS_TRACKING_BAR, true);
	end
end

function Class_UI_Watcher:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if (not self.IsActive) then return; end

	self:SetShown(TutorialData.UI_Elements.BAGS_BAR, true);
	self:SetShown(TutorialData.UI_Elements.MAIN_BAGS_BUTTON, true);
	self:SetShown(TutorialData.UI_Elements.SPELLBOOK_MICROBUTTON, true);
end

function Class_UI_Watcher:OnInterrupt(interruptedBy)
	self:SetShown(TutorialData.UI_Elements.BACKPACK, true);
	self:SetShown(TutorialData.UI_Elements.BAGS_BAR, true);
	self:SetShown(TutorialData.UI_Elements.MAIN_BAGS_BUTTON, true);
	self:SetShown(TutorialData.UI_Elements.OTHER_MICROBUTTONS, true);
	self:SetShown(TutorialData.UI_Elements.SPELLBOOK_MICROBUTTON, true);
	self:SetShown(TutorialData.UI_Elements.STORE_MICROBUTTON, true);
	self:SetShown(TutorialData.UI_Elements.TARGET_FRAME, true);
	self:SetShown(TutorialData.UI_Elements.STATUS_TRACKING_BAR, true);

	self:Complete();
end

function Class_UI_Watcher:OnComplete()
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- Gossip Frame Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_GossipFrameWatcher = class("GossipFrameWatcher", Class_TutorialBase);
function Class_GossipFrameWatcher:OnInitialize()
	GossipFrame:SetGossipTutorialMode(true);
end

function Class_GossipFrameWatcher:OnBegin()
end

function Class_GossipFrameWatcher:StartWatching()
	Dispatcher:RegisterEvent("GOSSIP_SHOW", self);
	Dispatcher:RegisterEvent("GOSSIP_CLOSED", self);
end

function Class_GossipFrameWatcher:StopWatching()
	Dispatcher:UnregisterEvent("GOSSIP_SHOW", self);
	Dispatcher:UnregisterEvent("GOSSIP_CLOSED", self);
end

function Class_GossipFrameWatcher:GOSSIP_SHOW()
	local firstQuestButton = nil;
	local tutorialButtons = GossipFrame:GetTutorialButtons(); 
	if(not tutorialButtons) then 
		return; 
	end 

	for _, button in ipairs(tutorialButtons) do
		if not firstQuestButton then
			firstQuestButton = button;
		end
		TutorialQuestBangGlow:Show(button);
	end
	if firstQuestButton and #tutorialButtons > 1 then
		self:ShowPointerTutorial(NPEV2_MULTIPLE_QUESTS_OFFERED, "LEFT", firstQuestButton, 0, 0, "RIGHT");
	end
end

function Class_GossipFrameWatcher:GOSSIP_CLOSED()
	local tutorialButtons = GossipFrame:GetTutorialButtons(); 
	for _, button in ipairs(tutorialButtons) do
		TutorialQuestBangGlow:Hide(button);
	end
	GossipFrame:SetGossipTutorialMode(false);
	self:HidePointerTutorials();
end

function Class_GossipFrameWatcher:OnInterrupt(interruptedBy)
	self:HidePointerTutorials();
	self:Complete();
	GossipFrame:SetGossipTutorialMode(false);
end

function Class_GossipFrameWatcher:OnComplete()
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- Low Health Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_LowHealthWatcher = class("LowHealthWatcher", Class_TutorialBase);
function Class_LowHealthWatcher:OnInitialize()
	self.useFoodQuestID = TutorialData:GetFactionData().UseFoodQuest;
end

function Class_LowHealthWatcher:OnAdded()
	if C_QuestLog.IsQuestFlaggedCompleted(self.useFoodQuestID) then
		TutorialManager:StartWatcher(self:Name());
	end
end

function Class_LowHealthWatcher:StartWatching()
	if C_QuestLog.IsQuestFlaggedCompleted(self.useFoodQuestID) then
		Dispatcher:RegisterEvent("UNIT_HEALTH", self);
		Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
		Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self);
		self.inCombat = false;
	end
end

function Class_LowHealthWatcher:StopWatching()
	Dispatcher:UnregisterEvent("UNIT_HEALTH", self);
	Dispatcher:UnregisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:UnregisterEvent("PLAYER_REGEN_ENABLED", self);
end

function Class_LowHealthWatcher:PLAYER_REGEN_DISABLED()
	self.inCombat = true;
end

function Class_LowHealthWatcher:PLAYER_REGEN_ENABLED()
	self.inCombat = false;
end

function Class_LowHealthWatcher:UNIT_HEALTH(arg1)
	if arg1 == "player" then
		local isDeadOrGhost = UnitIsDeadOrGhost("player");
		if (not isDeadOrGhost) and (UnitHealth(arg1)/UnitHealthMax(arg1) <= TutorialData.LOW_HEALTH_PERCENTAGE) and not self.inCombat then
			Dispatcher:UnregisterEvent("UNIT_HEALTH", self);

			local tutorialData = TutorialData:GetFactionData();
			local container, slot = TutorialHelper:FindItemInContainer(tutorialData.FoodItem);
			if container and slot then
				TutorialManager:Queue(Class_EatFood.name);
			end
			TutorialManager:StopWatcher(self:Name());
		end
	end
end

function Class_LowHealthWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_LowHealthWatcher:OnComplete()
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- Accept Quest Watcher - Watches for a new quest window to pop up that is ready to be accepted
-- ------------------------------------------------------------------------------------------------------------
Class_AcceptQuestWatcher = class("AcceptQuestWatcher", Class_TutorialBase);
function Class_AcceptQuestWatcher:OnInitialize()
	self:SetMaxLevel(TutorialData.MAX_QUEST_HELPER_LEVEL);
end

function Class_AcceptQuestWatcher:OnBegin()
end

function Class_AcceptQuestWatcher:StartWatching()
	Dispatcher:RegisterScript(QuestFrame, "OnShow", self);
	Dispatcher:RegisterScript(QuestFrame, "OnHide", self);
end

function Class_AcceptQuestWatcher:StopWatching()
	Dispatcher:UnregisterScript(QuestFrame, "OnShow", self);
	Dispatcher:UnregisterScript(QuestFrame, "OnHide", self);
end

function Class_AcceptQuestWatcher:OnShow()
	self.Timer = C_Timer.NewTimer(4, function() GlowEmitterFactory:Show(QuestFrameAcceptButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) end);
end

function Class_AcceptQuestWatcher:OnHide()
	if self.Timer then
		self.Timer:Cancel();
	end
	GlowEmitterFactory:Hide(QuestFrameAcceptButton);
end

function Class_AcceptQuestWatcher:OnInterrupt(interruptedBy)
	GlowEmitterFactory:Hide(QuestFrameAcceptButton);
	self:Complete();
end

function Class_AcceptQuestWatcher:OnComplete()
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- Turn In Quest Watch - Watches for a quest turn in window
-- ------------------------------------------------------------------------------------------------------------
Class_TurnInQuestWatcher = class("TurnInQuestWatcher", Class_TutorialBase);
function Class_TurnInQuestWatcher:OnBegin()
end

function Class_TurnInQuestWatcher:StartWatching()
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);
end

function Class_TurnInQuestWatcher:StopWatching()
	Dispatcher:UnregisterEvent("QUEST_COMPLETE", self);

	if self.onHideCallbackID then
		Dispatcher:UnregisterScript(QuestFrame, "OnHide", self.onHideCallbackID);
		self.onHideCallbackID = nil;
	end
	if self.onClickCallbackID then
		Dispatcher:UnregisterScript(QuestFrameCompleteQuestButton, "OnClick", self.onClickCallbackID);
		self.onClickCallbackID = nil;
	end
end

function Class_TurnInQuestWatcher:QUEST_COMPLETE()
	self.onHideCallbackID = Dispatcher:RegisterScript(QuestFrame, "OnHide", function() self:HideGlow() end, true);
	self.onClickCallbackID = Dispatcher:RegisterScript(QuestFrameCompleteQuestButton, "OnClick", function(QuestFrameCompleteQuestButton, button, down)
		self:HideGlow()
		end, true);
	if self.Timer then
		self.Timer:Cancel();
	end
	self.Timer = C_Timer.NewTimer(4, function() GlowEmitterFactory:Show(QuestFrameCompleteQuestButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) end);

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
		C_Timer.After(0.1, function() self:PromptRewardChoice(areAllItemsUsable); end);
	end
end

function Class_TurnInQuestWatcher:PromptRewardChoice(areAllItemsUsable)
	TutorialManager:Queue(Class_QuestRewardChoice.name, areAllItemsUsable);
end

function Class_TurnInQuestWatcher:HideGlow()
	if self.Timer then
		self.Timer:Cancel();
	end
	GlowEmitterFactory:Hide(QuestFrameCompleteQuestButton);
end

function Class_TurnInQuestWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_TurnInQuestWatcher:OnComplete()
	self:StopWatching()
	self:HideGlow();
end

-- ------------------------------------------------------------------------------------------------------------
-- XP Bar Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_XPBarWatcher = class("XPBarWatcher", Class_TutorialBase);
function Class_XPBarWatcher:OnInitialize()
	self:SetMaxLevel(TutorialData.MAX_XP_BAR_LEVEL);
	self.questID = TutorialData:GetFactionData().StartingQuest;
end

function Class_XPBarWatcher:OnBegin()
end

function Class_XPBarWatcher:StartWatching()
	Dispatcher:RegisterEvent("QUEST_TURNED_IN", self);
end

function Class_XPBarWatcher:StopWatching()
	Dispatcher:UnregisterEvent("QUEST_TURNED_IN", self);
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
end

function Class_XPBarWatcher:QUEST_TURNED_IN(completedQuestID)
	Dispatcher:UnregisterEvent("QUEST_TURNED_IN", self);
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	local watcher = TutorialManager:GetWatcher("UI_Watcher");
	if watcher then
		watcher:SetShown(TutorialData.UI_Elements.STATUS_TRACKING_BAR, true);
	end

	if self.questID == completedQuestID then
		self.pointerTutorial = self:ShowPointerTutorial(NPEV2_XP_BAR_TUTORIAL, "DOWN", StatusTrackingBarManager, 0, -5, nil, "DOWN");
	end
end

function Class_XPBarWatcher:QUEST_DETAIL()
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	self:Complete();
end

function Class_XPBarWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_XPBarWatcher:OnComplete()
	TutorialManager:StopWatcher(self:Name());
	if self.pointerTutorial then
		self:HidePointerTutorial(self.pointerTutorial);
	end
	local watcher = TutorialManager:GetWatcher("UI_Watcher");
	if watcher then
		watcher:SetShown(TutorialData.UI_Elements.STATUS_TRACKING_BAR, true);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Hunter Stable Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_HunterStableWatcher = class("HunterStableWatcher", Class_TutorialBase);
function Class_HunterStableWatcher:OnBegin()
end

function Class_HunterStableWatcher:StartWatching()
	local playerClass = TutorialHelper:GetClass();
	if (playerClass ~= "HUNTER") or (UnitLevel("player") >= TutorialData.HUNTER_STABLE_MAX_LEVEL) then
		self:Complete();
		return;
	end

	local count = C_StableInfo.GetNumStablePets();
	if count > 0 then
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("PET_STABLE_SHOW", self);
	Dispatcher:RegisterEvent("PET_STABLE_CLOSED", self);
end

function Class_HunterStableWatcher:StopWatching()
	Dispatcher:UnregisterEvent("PET_STABLE_SHOW", self);
	Dispatcher:UnregisterEvent("PET_STABLE_CLOSED", self);
end

function Class_HunterStableWatcher:PET_STABLE_SHOW()
	local count = C_StableInfo.GetNumStablePets();
	if count > 0 then
		self:Complete();
		return;
	end
	self:ShowPointerTutorial(NPEV2_HUNTER_STABLE_PET, "LEFT", PetStableStabledPet5, 10, 0, nil, "LEFT");
end

function Class_HunterStableWatcher:PET_STABLE_CLOSED()
	local count = C_StableInfo.GetNumStablePets();
	if count > 0 then
		self:Complete();
	end
end

function Class_HunterStableWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_HunterStableWatcher:OnComplete()
	self:HidePointerTutorials();
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- Inventory Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_InventoryWatcher = class("InventoryWatcher", Class_TutorialBase);
function Class_InventoryWatcher:OnInitialize()
	local level = UnitLevel("player");
	if level >= TutorialData.MAX_ITEM_HELP_LEVEL then
		self:Complete();
	end
end

function Class_InventoryWatcher:OnBegin()
end

function Class_InventoryWatcher:StartWatching()
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);
end

function Class_InventoryWatcher:StopWatching()
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
end

function Class_InventoryWatcher:BAG_UPDATE_DELAYED()
	local level = UnitLevel("player");
	if level >= TutorialData.MAX_ITEM_HELP_LEVEL then
		Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	else
		TutorialManager:Queue(Class_ItemUpgradeCheckingService.name);
	end
end

function Class_InventoryWatcher:OnInterrupt()
	self:Complete();
end

function Class_InventoryWatcher:OnComplete()
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- Stealth Watcher - for Rogues
-- ------------------------------------------------------------------------------------------------------------
Class_StealthWatcher = class("StealthWatcher", Class_TutorialBase);
function Class_StealthWatcher:OnBegin()
end

function Class_StealthWatcher:StartWatching()
	local playerClass = TutorialHelper:GetClass();
	if playerClass == "ROGUE" and UnitLevel("player") <= TutorialData.ROGUE_STEALTH_LEVEL then
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	else
		self:Complete();
	end
end

function Class_StealthWatcher:StopWatching()
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
end

function Class_StealthWatcher:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel >= TutorialData.ROGUE_STEALTH_LEVEL then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		self.pointerID = self:AddPointerTutorial(NPEV2_STEALTH_TUTORIAL, "DOWN", StanceButton1, 0, 10, nil, "DOWN");
	end
end

function Class_StealthWatcher:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	local STEALTH_SPELL_ID = 1784;
	if spellID == STEALTH_SPELL_ID then
		self:Complete();
	end
end

function Class_StealthWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_StealthWatcher:OnComplete()
	self:StopWatching();
	self:HidePointerTutorial(self.pointerID);
end

-- ------------------------------------------------------------------------------------------------------------
-- Druid Forms Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_DruidFormWatcher = class("DruidFormWatcher", Class_TutorialBase);
function Class_DruidFormWatcher:OnInitialize()
	self:SetMaxLevel(TutorialData.DRUID_BEAR_FORM_LEVEL);
end

function Class_DruidFormWatcher:OnBegin()
end

function Class_DruidFormWatcher:StartWatching()
	if TutorialHelper:GetClass() == "DRUID" then
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	else
		self:Complete();
	end
end

function Class_DruidFormWatcher:StopWatching()
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
end

function Class_DruidFormWatcher:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel == TutorialData.DRUID_CAT_FORM_LEVEL then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		self.spellToCast = self.CAT_FORM_SPELL_ID;
		self.pointerID = self:AddPointerTutorial(NPEV2_CAT_FORM_TUTORIAL, "DOWN", StanceButton1, 0, 10, nil, "DOWN");
	elseif newLevel == TutorialData.DRUID_BEAR_FORM_LEVEL then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		self.spellToCast = self.BEAR_FORM_SPELL_ID;
		self.pointerID = self:AddPointerTutorial(NPEV2_BEAR_FORM_TUTORIAL, "DOWN", StanceButton1, 0, 10, nil, "DOWN");
	end
end

function Class_DruidFormWatcher:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if spellID == TutorialData.DruidAnimalFormSpells.CAT_FORM_SPELL_ID then
		self:HidePointerTutorial(self.pointerID);
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	elseif spellID == TutorialData.DruidAnimalFormSpells.BEAR_FORM_SPELL_ID then
		self:Complete();
	end
end

function Class_DruidFormWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_DruidFormWatcher:OnComplete()
	self:StopWatching();
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
	end
end

-- ============================================================================================================
-- Death Watch - watches for the player to die
-- ============================================================================================================
Class_Death_Watcher = class("Death_Watcher", Class_TutorialBase);
function Class_Death_Watcher:OnBegin()
end

function Class_Death_Watcher:StartWatching()
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
end

function Class_Death_Watcher:StopWatching()
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
end

function Class_Death_Watcher:PLAYER_DEAD()
	TutorialManager:Queue(Class_Death_ReleaseCorpse.name);
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
end

function Class_LootCorpseWatcher:StartWatching()
	local playerLevel = UnitLevel("player");
	if playerLevel > TutorialData.MAX_LOOT_CORPSE_LEVEL then -- if the player comes back after level 4, don't prompt them on loot anymore
		self:Complete();
		return;
	end
	Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self);
end

function Class_LootCorpseWatcher:StopWatching()
	Dispatcher:UnregisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:UnregisterEvent("PLAYER_REGEN_ENABLED", self);
	Dispatcher:UnregisterEvent("CHAT_MSG_LOOT", self);
	Dispatcher:UnregisterEvent("CHAT_MSG_MONEY", self);
	Dispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);

	if (self.canLootTimer) then
		self.canLootTimer:Cancel();
		self.canLootTimer = nil;
	end
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
		if not self.canLootTimer then
			self.canLootTimer = C_Timer.NewTimer(1, function()
				if CanLootUnit(unitGUID) then
					self:UnitLootable(unitGUID);
				end
				self.canLootTimer = nil;
			end);
		end
	end
end

function Class_LootCorpseWatcher:UnitLootable(unitGUID)
	local unitID = tonumber(string.match(unitGUID, "Creature%-.-%-.-%-.-%-.-%-(.-)%-"));
	for id, hasKilled in pairs(self._QuestMobs) do
		if (unitID == hasKilled) then			
			TutorialManager:GetTutorial(Class_LootCorpse.name):ForceBegin(unitID);
			return;
		end
	end

	-- if the player hasn't looted their last mob increment the reprompt threshold
	if (self.PendingLoot) then
		self.RePromptLootCount = self.RePromptLootCount + 1;
	end
	self.PendingLoot = true;

	if ((self.LootCount < 3) or (self.RePromptLootCount >= 2)) then
		TutorialManager:GetTutorial(Class_LootCorpse.name):Begin(unitID);
	else
		-- These are so we can silently watch for people missing looting without a prompt.
		-- If they are prompted, the prompt tutorial (LootCorpse) manages this.
		Dispatcher:RegisterEvent("CHAT_MSG_LOOT", self);
		Dispatcher:RegisterEvent("CHAT_MSG_MONEY", self);
	end
end
