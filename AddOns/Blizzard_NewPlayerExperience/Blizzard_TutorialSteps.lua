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

local MAX_SPELL_HELP_LEVEL = 10;
local MAX_ITEM_HELP_LEVEL = 10;
local MAX_UI_HIDE_LEVEL = 3;
local MAX_QUEST_HELPER_LEVEL = 4;
local MAX_QUEST_COMPLETE_LEVEL = 2;
local MAX_XP_BAR_LEVEL = 2;
local INTRO_LEVEL = 1;
local ROGUE_STEALTH_LEVEL = 5;
local DRUID_CAT_FORM_LEVEL = 5;
local DRUID_BEAR_FORM_LEVEL = 8;
local HUNTER_STABLE_MAX_LEVEL = 9;
local LOW_HEALTH_PERCENTAGE = 0.5;
local MAX_LOOT_CORPSE_LEVEL = 4;
-- ------------------------------------------------------------------------------------------------------------
-- Auto Push Spell Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_AutoPushSpellWatcher = class("AutoPushSpellWatcher", Class_TutorialBase);
function Class_AutoPushSpellWatcher:OnInitialize()
	self:SetMaxLevel(MAX_SPELL_HELP_LEVEL);
end

function Class_AutoPushSpellWatcher:OnBegin()
	local button = TutorialHelper:FindEmptyButton();
	if button then
		Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
		SetCVar("AutoPushSpellToActionBar", 0);
	else
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
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	SetCVar("AutoPushSpellToActionBar", 1);
end


-- ------------------------------------------------------------------------------------------------------------
-- Ability Watcher - checks on relog or reloadui if the player has their abilities on their action bar
-- ------------------------------------------------------------------------------------------------------------
Class_AbilityWatcher = class("AbilityWatcher", Class_TutorialBase);
function Class_AbilityWatcher:OnBegin()
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_ENTERING_WORLD", self);
	self.playerClass = TutorialHelper:GetClass();
	self:CheckAbilities();
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
				TutorialQueue:Add(TutorialLogic.Tutorials.AddSpellToActionBarService, spellID, warningString, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar);
			end
		end
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


-- ------------------------------------------------------------------------------------------------------------
-- UI Watcher - turns off and on various UI elements
-- ------------------------------------------------------------------------------------------------------------
local UI_Elements = {
	BACKPACK				= {MainMenuBarBackpackButton},
	BAGS_BAR				= {MicroButtonAndBagsBar},
	SPELLBOOK_MICROBUTTON	= {SpellbookMicroButton},
	OTHER_MICROBUTTONS		= {CharacterMicroButton, GuildMicroButton, TalentMicroButton, MainMenuMicroButton, AchievementMicroButton, CollectionsMicroButton, QuestLogMicroButton, LFDMicroButton, EJMicroButton},
	STORE_MICROBUTTON		= {StoreMicroButton},
	TARGET_FRAME			= {TargetFrame},
	STATUS_TRACKING_BAR		= {StatusTrackingBarManager},
}

Class_UI_Watcher = class("UI_Watcher", Class_TutorialBase);
function Class_UI_Watcher:OnInitialize()
	self:SetMaxLevel(MAX_UI_HIDE_LEVEL);
end

function Class_UI_Watcher:OnBegin()
	self.questID = TutorialHelper:GetFactionData().ShowAllUIQuest;
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:RegisterEvent("QUEST_ACCEPTED", self);
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);

	self.tutorialData = TutorialHelper:GetFactionData();

	local showBackpack = false;
	local showMainMenuBarArtFrame = false;
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
		showMainMenuBarArtFrame = true;
		showTargetFrame = true;
		showStatusTrackingBar = true;
	end

	if C_QuestLog.IsQuestFlaggedCompleted(self.tutorialData.ShowAllUIQuest) then
		-- the show all ui quest is completed
		self:Complete();
		return;
	end

	self:SetShown(UI_Elements.BACKPACK, showBackpack);
	self:SetShown(UI_Elements.BAGS_BAR, showBagsBar);
	self:SetShown(UI_Elements.SPELLBOOK_MICROBUTTON, showSpellbookButton);
	self:SetShown(UI_Elements.OTHER_MICROBUTTONS, showOtherButtons);
	self:SetShown(UI_Elements.STORE_MICROBUTTON, showStoreButton);
	self:SetShown(UI_Elements.TARGET_FRAME, showTargetFrame);
	self:SetShown(UI_Elements.STATUS_TRACKING_BAR, showStatusTrackingBar);
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
		self:SetShown(UI_Elements.BACKPACK, true);
		self:SetShown(UI_Elements.BAGS_BAR, true);
		self:SetShown(UI_Elements.OTHER_MICROBUTTONS, true);
		self:SetShown(UI_Elements.SPELLBOOK_MICROBUTTON, true);
		self:SetShown(UI_Elements.STORE_MICROBUTTON, true);
		self:SetShown(UI_Elements.TARGET_FRAME, true);
		self:SetShown(UI_Elements.STATUS_TRACKING_BAR, true);
		self:Complete();
	end
end

function Class_UI_Watcher:QUEST_COMPLETE()
	if (not self.IsActive) then return; end

	if C_QuestLog.IsQuestFlaggedCompleted(self.tutorialData.StartingQuest) then
		self:SetShown(UI_Elements.TARGET_FRAME, true);
		self:SetShown(UI_Elements.STATUS_TRACKING_BAR, true);
	end
end

function Class_UI_Watcher:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if (not self.IsActive) then return; end

	self:SetShown(UI_Elements.BAGS_BAR, true);
	self:SetShown(UI_Elements.SPELLBOOK_MICROBUTTON, true);
end

function Class_UI_Watcher:OnInterrupt(interruptedBy)
	self:SetShown(UI_Elements.BACKPACK, true);
	self:SetShown(UI_Elements.BAGS_BAR, true);
	self:SetShown(UI_Elements.OTHER_MICROBUTTONS, true);
	self:SetShown(UI_Elements.SPELLBOOK_MICROBUTTON, true);
	self:SetShown(UI_Elements.STORE_MICROBUTTON, true);
	self:SetShown(UI_Elements.TARGET_FRAME, true);
	self:SetShown(UI_Elements.STATUS_TRACKING_BAR, true);

	self:Complete();
end

function Class_UI_Watcher:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:UnregisterEvent("QUEST_ACCEPTED", self);
	Dispatcher:UnregisterEvent("QUEST_COMPLETE", self);
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
	for i = 1, GossipFrame_GetTitleButtonCount() do
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
	for i = 1, GossipFrame_GetTitleButtonCount() do
		local button = GossipFrame_GetTitleButton(i);
		if button and button:IsShown() and button.type == "Available" then
			NPE_TutorialQuestBangGlow:Hide(button);
		end
	end
	GossipFrameGreetingGoodbyeButton:Show();
	self:HidePointerTutorials();
end

function Class_GossipFrameWatcher:OnInterrupt(interruptedBy)
	self:HidePointerTutorials();
	self:Complete();
end

function Class_GossipFrameWatcher:OnComplete()
	Dispatcher:UnregisterEvent("GOSSIP_SHOW", self);
	Dispatcher:UnregisterEvent("GOSSIP_CLOSED", self);
end


-- ------------------------------------------------------------------------------------------------------------
-- Low Health Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_LowHealthWatcher = class("LowHealthWatcher", Class_TutorialBase);
function Class_LowHealthWatcher:OnBegin()
	self.useFoodQuestID = TutorialHelper:GetFactionData().UseFoodQuest;
	self.enhanchedCombatTacticsQuestID = TutorialHelper:GetFactionData().EnhancedCombatTacticsQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(self.useFoodQuestID) or C_QuestLog.IsQuestFlaggedCompleted(self.enhanchedCombatTacticsQuestID) then
		self:StartWatching();
	end
end

function Class_LowHealthWatcher:StartWatching()
	if C_QuestLog.IsQuestFlaggedCompleted(self.useFoodQuestID) or C_QuestLog.IsQuestFlaggedCompleted(self.enhanchedCombatTacticsQuestID) then
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
		if (not isDeadOrGhost) and (UnitHealth(arg1)/UnitHealthMax(arg1) <= LOW_HEALTH_PERCENTAGE) and not self.inCombat then
			Dispatcher:UnregisterEvent("UNIT_HEALTH", self);

			local tutorialData = TutorialHelper:GetFactionData();
			local container, slot = TutorialHelper:FindItemInContainer(tutorialData.FoodItem);
			if container and slot then
				TutorialQueue:Add(TutorialLogic.Tutorials.EatFood, self.inCombat);
			end
			self:StopWatching();
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
	self:SetMaxLevel(MAX_QUEST_HELPER_LEVEL);
end

function Class_AcceptQuestWatcher:OnBegin()
	Dispatcher:RegisterScript(QuestFrame, "OnShow", self);
	Dispatcher:RegisterScript(QuestFrame, "OnHide", self);
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
	Dispatcher:UnregisterScript(QuestFrame, "OnShow", self);
	Dispatcher:UnregisterScript(QuestFrame, "OnHide", self);
end


-- ------------------------------------------------------------------------------------------------------------
-- Turn In Quest Watch - Watches for a quest turn in window
-- ------------------------------------------------------------------------------------------------------------
Class_TurnInQuestWatcher = class("TurnInQuestWatcher", Class_TutorialBase);
function Class_TurnInQuestWatcher:OnBegin()
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);
end

function Class_TurnInQuestWatcher:QUEST_COMPLETE()
	Dispatcher:RegisterScript(QuestFrame, "OnHide", function() self:HideGlow() end, true);
	Dispatcher:RegisterScript(QuestFrameCompleteQuestButton, "OnClick", function(QuestFrameCompleteQuestButton, button, down)
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
		C_Timer.After(0.1, function() TutorialQueue:Add(TutorialLogic.Tutorials.QuestRewardChoice, areAllItemsUsable); end);
	end
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
	self:HideGlow();
end


-- ------------------------------------------------------------------------------------------------------------
-- XP Bar Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_XPBarWatcher = class("XPBarWatcher", Class_TutorialBase);
function Class_XPBarWatcher:OnInitialize()
	self:SetMaxLevel(MAX_XP_BAR_LEVEL);
end

function Class_XPBarWatcher:OnBegin()
	Dispatcher:RegisterEvent("QUEST_TURNED_IN", self);
	self.questID = TutorialHelper:GetFactionData().StartingQuest;
end

function Class_XPBarWatcher:QUEST_TURNED_IN(completedQuestID)
	Dispatcher:UnregisterEvent("QUEST_TURNED_IN", self);
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	TutorialLogic.Tutorials.UI_Watcher:SetShown(UI_Elements.STATUS_TRACKING_BAR, true);
	
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
	Dispatcher:UnregisterEvent("QUEST_TURNED_IN", self);
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	if self.pointerTutorial then
		self:HidePointerTutorial(self.pointerTutorial);
	end
	TutorialLogic.Tutorials.UI_Watcher:SetShown(UI_Elements.STATUS_TRACKING_BAR, true);
end


-- ------------------------------------------------------------------------------------------------------------
-- Hunter Stable Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_HunterStableWatcher = class("HunterStableWatcher", Class_TutorialBase);
function Class_HunterStableWatcher:OnBegin()
	local playerClass = TutorialHelper:GetClass();
	if (playerClass ~= "HUNTER") or (UnitLevel("player") >= HUNTER_STABLE_MAX_LEVEL) then
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
	Dispatcher:UnregisterEvent("PET_STABLE_SHOW", self);
	Dispatcher:UnregisterEvent("PET_STABLE_CLOSED", self);
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Inventory Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_InventoryWatcher = class("InventoryWatcher", Class_TutorialBase);
function Class_InventoryWatcher:Begin()
	local level = UnitLevel("player");
	if level >= MAX_ITEM_HELP_LEVEL then
		self:Complete();
	end
end

function Class_InventoryWatcher:StartWatching()
	Dispatcher:RegisterEvent("UNIT_INVENTORY_CHANGED", self);
end

function Class_InventoryWatcher:UNIT_INVENTORY_CHANGED()
	local level = UnitLevel("player");
	if level >= MAX_ITEM_HELP_LEVEL then
		Dispatcher:UnregisterEvent("UNIT_INVENTORY_CHANGED", self);
	else
		TutorialQueue:Add(TutorialLogic.Tutorials.ItemUpgradeCheckingService);
	end
end

function Class_InventoryWatcher:OnInterrupt()
	self:Complete();
end

function Class_InventoryWatcher:OnComplete()
	Dispatcher:UnregisterEvent("UNIT_INVENTORY_CHANGED", self);
end


-- ------------------------------------------------------------------------------------------------------------
-- Stealth Watcher - for Rogues
-- ------------------------------------------------------------------------------------------------------------
Class_StealthWatcher = class("StealthWatcher", Class_TutorialBase);
function Class_StealthWatcher:OnBegin()
	local playerClass = TutorialHelper:GetClass();
	if playerClass == "ROGUE" and UnitLevel("player") < ROGUE_STEALTH_LEVEL then
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	else
		self:Complete();
	end
end

function Class_StealthWatcher:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel == ROGUE_STEALTH_LEVEL then
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
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:HidePointerTutorial(self.pointerID);
end


-- ------------------------------------------------------------------------------------------------------------
-- Druid Forms Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_DruidFormWatcher = class("DruidFormWatcher", Class_TutorialBase);
function Class_DruidFormWatcher:OnInitialize()
	self:SetMaxLevel(DRUID_BEAR_FORM_LEVEL);
end

function Class_DruidFormWatcher:OnBegin()
	if TutorialHelper:GetClass() == "DRUID" then
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	else
		self:Complete();
	end
end

function Class_DruidFormWatcher:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel == DRUID_CAT_FORM_LEVEL then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		self.spellToCast = self.CAT_FORM_SPELL_ID;
		self.pointerID = self:AddPointerTutorial(NPEV2_CAT_FORM_TUTORIAL, "DOWN", StanceButton1, 0, 10, nil, "DOWN");
	elseif newLevel == DRUID_BEAR_FORM_LEVEL then
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
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	if self.pointerID then
		self:HidePointerTutorial(self.pointerID);
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Add Spell To Action Bar Service
-- ------------------------------------------------------------------------------------------------------------
Class_AddSpellToActionBarService = class("AddSpellToActionBarService", Class_TutorialBase);
function Class_AddSpellToActionBarService:OnBegin()
	self.playerClass = TutorialHelper:GetClass();
end

function Class_AddSpellToActionBarService:CanStart(args)
	local spellID, warningString, spellMicroButtonString, optionalPreferredActionBar, requiredForm = unpack(args);
	if spellID then
		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		return button == nil;
	end
	return false;
end

function Class_AddSpellToActionBarService:Start(args)
	local spellID, warningString, spellMicroButtonString, optionalPreferredActionBar, requiredForm = unpack(args);
	if not spellID then
		TutorialQueue:NotifyDone(self);
		return;
	end
	self.inProgress = true;
	self.spellToAdd = spellID;
	self.spellIDString = "{$"..self.spellToAdd.."}";
	self.warningString = warningString;
	self.spellMicroButtonString = spellMicroButtonString or NPEV2_SPELLBOOK_ADD_SPELL;
	self.optionalPreferredActionBar = optionalPreferredActionBar;
	self.requiredForm = requiredForm;

	if self.requiredForm and (GetShapeshiftFormID() ~= self.requiredForm) then
		TutorialQueue:NotifyDone(self);
		return;
	end

	if self.playerClass == "ROGUE" or self.playerClass == "DRUID" then
		Dispatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	end

	local button = TutorialHelper:GetActionButtonBySpellID(self.spellToAdd);
	if button then
		TutorialQueue:NotifyDone(self);
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

function Class_AddSpellToActionBarService:UPDATE_SHAPESHIFT_FORM()
	if self.requiredForm and (GetShapeshiftFormID() ~= self.requiredForm) then
		TutorialQueue:NotifyDone(self);
		return;
	end
end

function Class_AddSpellToActionBarService:SpellBookFrameShow()
	EventRegistry:UnregisterCallback("SpellBookFrame.Show", self);
	EventRegistry:RegisterCallback("SpellBookFrame.Hide", self.SpellBookFrameHide, self);
	self:HidePointerTutorials();
	ActionButton_HideOverlayGlow(SpellbookMicroButton);
	C_Timer.After(0.1, function()
		self:RemindAbility();
	end);
end

function Class_AddSpellToActionBarService:SpellBookFrameHide()
	TutorialQueue:NotifyDone(self);
end

function Class_AddSpellToActionBarService:ACTIONBAR_SHOW_BOTTOMLEFT()
	Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	C_Timer.After(0.1, function()
		self:RemindAbility();
	end);
end

function Class_AddSpellToActionBarService:RemindAbility()
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

function Class_AddSpellToActionBarService:ACTIONBAR_SLOT_CHANGED(slot)
	local button = TutorialHelper:GetActionButtonBySpellID(self.spellToAdd);
	if button then
		TutorialQueue:NotifyDone(self);
	else
		local _, spellID = GetActionInfo(slot);

		-- HACK: there is a special Tutorial only condition here we need to check here for Freezing Trap
		local normalFreezingTrapSpellID = 187650;
		local specialFreezingTrapSpellID = 321164;
		if self.spellToAdd == normalFreezingTrapSpellID then
			if (spellID == normalFreezingTrapSpellID) or (spellID == specialFreezingTrapSpellID) then
				TutorialQueue:NotifyDone(self);
				return;
			end
		end

		local nextEmptyButton = TutorialHelper:FindEmptyButton();
		if not nextEmptyButton then
			TutorialQueue:NotifyDone(self);-- no more empty buttons
		elseif self.actionButton ~= nextEmptyButton then
			NPE_TutorialDragButton:Hide();
			self.actionButton = nextEmptyButton;
			NPE_TutorialDragButton:Show(self.flyoutButton or self.spellButton, self.actionButton);
		end
	end
end

function Class_AddSpellToActionBarService:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_AddSpellToActionBarService:Finish()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	EventRegistry:UnregisterCallback("SpellBookFrame.Show", self);
	EventRegistry:UnregisterCallback("SpellBookFrame.Hide", self);
	self:HidePointerTutorials();
	self:HideScreenTutorial();
	NPE_TutorialDragButton:Hide();

	self.spellToAdd = nil;
	self.actionButton = nil;
	self.spellButton = nil;
	self.inProgress = false;
end


-- ------------------------------------------------------------------------------------------------------------
-- Item Upgrade Checking Service - Watches you inventory for item upgrades to kick off this sequence
-- ------------------------------------------------------------------------------------------------------------
Class_ItemUpgradeCheckingService = class("ItemUpgradeCheckingService", Class_TutorialBase);
function Class_ItemUpgradeCheckingService:OnInitialize()
	self.WeaponType = {
		TwoHand	= "TwoHand",
		Ranged	= "Ranged",
		Other	= "Other",
	}
end

function Class_ItemUpgradeCheckingService:CanStart()
	return UnitLevel("player") < MAX_ITEM_HELP_LEVEL;
end

function Class_ItemUpgradeCheckingService:Start()
	local upgrades = self:GetBestItemUpgrades();
	local slot, item = next(upgrades);

	if item and slot ~= INVSLOT_TABARD then
		TutorialQueue:Add(TutorialLogic.Tutorials.ChangeEquipment, item);
	end
	TutorialQueue:NotifyDone(self);
end

function Class_ItemUpgradeCheckingService:STRUCT_ItemContainer(itemLink, characterSlot, container, containerSlot)
	return
	{
		ItemLink = itemLink,
		Container = container,
		ContainerSlot = containerSlot,
		CharacterSlot = characterSlot,
	};
end

-- Find the best item a player can equip from their bags per equipment slot
-- @return A table keyed off equipment slot that contains a STRUCT_ItemContainer
function Class_ItemUpgradeCheckingService:GetBestItemUpgrades()
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

function Class_ItemUpgradeCheckingService:GetWeaponType(itemID)
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
function Class_ItemUpgradeCheckingService:GetPotentialItemUpgrades()
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

						-- rogue's should only be recommended daggers
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

function Class_ItemUpgradeCheckingService:OnInterrupt(interruptedBy)
	self:Complete();
end


-- ------------------------------------------------------------------------------------------------------------
-- Intro Keyboard Mouse Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_KeyboardMouse = class("Intro_KeyboardMouse", Class_TutorialBase);
function Class_Intro_KeyboardMouse:OnBegin()
	self.questID = TutorialHelper:GetFactionData().StartingQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
	end
end

function Class_Intro_KeyboardMouse:CanStart()
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		self:Complete();
		return false;
	end
	return true;
end

function Class_Intro_KeyboardMouse:Start()
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);
	self:HideScreenTutorial();
	C_Timer.After(4, function()
		self:LaunchMouseKeyboardFrame();
	end);
end

function Class_Intro_KeyboardMouse:LaunchMouseKeyboardFrame()
	EventRegistry:RegisterCallback("NPE_TutorialKeyboardMouseFrame.Closed", self.CloseMouseKeyboardFrame, self);
	self:ShowMouseKeyboardTutorial();
	self.Timer = C_Timer.NewTimer(10, 
		function() 
			GlowEmitterFactory:Show(KeyboardMouseConfirmButton, 
			GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) 
		end);
end

function Class_Intro_KeyboardMouse:CloseMouseKeyboardFrame()
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_KeyboardMouse:QUEST_DETAIL(logindex, questID)
	EventRegistry:UnregisterCallback("NPE_TutorialKeyboardMouseFrame.Closed", self);
	self.earlyExit = true;
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_KeyboardMouse:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_KeyboardMouse:Finish()
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	self:HideMouseKeyboardTutorial();
	if not self.earlyExit then
		TutorialQueue:Add(TutorialLogic.Tutorials.Intro_CameraLook);
	end
	self:Complete();
end

function Class_Intro_KeyboardMouse:OnComplete()
	if self.Timer then
		self.Timer:Cancel();
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Intro Camera Look - This shows using the mouse to look around
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CameraLook = class("Intro_CameraLook", Class_TutorialBase);
function Class_Intro_CameraLook:OnBegin()
	self.questID = TutorialHelper:GetFactionData().ShowAllUIQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
	end
end

function Class_Intro_CameraLook:CanStart()
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		self:Complete();
		return false;
	end
	return true;
end

function Class_Intro_CameraLook:Start()
	Dispatcher:RegisterEvent("PLAYER_STARTED_TURNING", self);
	Dispatcher:RegisterEvent("PLAYER_STOPPED_TURNING", self);
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	self.playerHasLooked = false;
	local content = {text = NPEV2_INTRO_CAMERA_LOOK, icon = "newplayertutorial-icon-mouse-turn"};
	self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
end

function Class_Intro_CameraLook:PLAYER_STARTED_TURNING()
	self.playerHasLooked = true;
end

function Class_Intro_CameraLook:PLAYER_STOPPED_TURNING()
	if self.playerHasLooked then
		TutorialQueue:NotifyDone(self);
	end
end

function Class_Intro_CameraLook:QUEST_DETAIL()
	self.earlyExit = true;
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_CameraLook:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_CameraLook:Finish()
	Dispatcher:UnregisterEvent("PLAYER_STARTED_TURNING", self);
	Dispatcher:UnregisterEvent("PLAYER_STOPPED_TURNING", self);
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	self:HideScreenTutorial();
	
	if not self.earlyExit then
		TutorialQueue:Add(TutorialLogic.Tutorials.Intro_ApproachQuestGiver);
	end;
	self:Complete();
end

function Class_Intro_CameraLook:OnComplete()
end


-- ------------------------------------------------------------------------------------------------------------
-- Intro Approach Quest Giver
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_ApproachQuestGiver = class("Intro_ApproachQuestGiver", Class_TutorialBase);
function Class_Intro_ApproachQuestGiver:OnBegin()
	self.questID = TutorialHelper:GetFactionData().ShowAllUIQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
	end
end

function Class_Intro_ApproachQuestGiver:CanStart()
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		self:Complete();
		return false;
	end
	return true;
end

function Class_Intro_ApproachQuestGiver:Start()
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);

	self:ShowWalkTutorial();
	local unit = TutorialHelper:GetFactionData().StartingQuestGiverCreatureID;
	if (unit) then
		NPE_RangeManager:StartWatching(unit, NPE_RangeManager.Type.Unit, 5, function() TutorialQueue:NotifyDone(self); end);
	end
end

function Class_Intro_ApproachQuestGiver:QUEST_DETAIL()
	self.earlyExit = true;
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_ApproachQuestGiver:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_ApproachQuestGiver:Finish()
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	NPE_RangeManager:Shutdown();
	self:HideWalkTutorial();

	if not self.earlyExit then
		TutorialQueue:Add(TutorialLogic.Tutorials.Intro_Interact);
	end;
	self:Complete();
end


-- ------------------------------------------------------------------------------------------------------------
-- Interact with Quest Giver
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_Interact = class("Intro_Interact", Class_TutorialBase);
function Class_Intro_Interact:OnBegin()
	self.questID = TutorialHelper:GetFactionData().StartingQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
	end
end

function Class_Intro_Interact:CanStart()
	if TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		self:Complete();
		return false;
	end
	return true;
end

function Class_Intro_Interact:Start()
	Dispatcher:RegisterEvent("QUEST_DETAIL", self);
	Dispatcher:RegisterEvent("QUEST_ACCEPTED", self);
	if not QuestFrame:IsShown() then
		local content = {text = TutorialHelper:GetFactionData().StartingQuestInteractString, icon = "newplayertutorial-icon-mouse-rightbutton"};
		self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
	end
end

function Class_Intro_Interact:QUEST_DETAIL(logindex, questID)
	if not TutorialHelper:IsQuestCompleteOrActive(self.questID) then
		TutorialQueue:NotifyDone(self);
	end
end

function Class_Intro_Interact:QUEST_ACCEPTED(questID)
	if self.questID == questID then
		TutorialQueue:NotifyDone(self);
	end
end

function Class_Intro_Interact:OnInterrupt(interruptedBy)
	self:HideScreenTutorial();
	self:Complete();
end

function Class_Intro_Interact:Finish()
	Dispatcher:UnregisterEvent("QUEST_DETAIL", self);
	self:HideScreenTutorial();
	self:Complete();
end


-- ------------------------------------------------------------------------------------------------------------
-- Combat Dummy In Range - waits to see if the player is in melee or ranged combat range
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CombatDummyInRange = class("Intro_CombatDummyInRange", Class_TutorialBase);
function Class_Intro_CombatDummyInRange:OnBegin()
	self.questID = TutorialHelper:GetFactionData().StartingQuest;
	if C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil then
		self.readyForTurnIn = C_QuestLog.ReadyForTurnIn(self.questID);
		if self.readyForTurnIn then
			self:Complete();
		else
			TutorialQueue:Add(self);
		end
	end
end

function Class_Intro_CombatDummyInRange:Start()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("PLAYER_ENTER_COMBAT", self);
	Dispatcher:RegisterEvent("UNIT_TARGET", self);

	self.targetedDummy = false;
	local unitGUID = UnitGUID("target");
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().StartingQuestTargetDummyCreatureID) then
		self.targetedDummy = true;
	end

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
		TutorialQueue:NotifyDone(self);
	end
end

function Class_Intro_CombatDummyInRange:QUEST_REMOVED(questID)
	if questID == TutorialHelper:GetFactionData().StartingQuest then
		self.success = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_Intro_CombatDummyInRange:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_Intro_CombatDummyInRange:Finish()
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("PLAYER_ENTER_COMBAT", self);
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);

	TutorialLogic.Tutorials.UI_Watcher:SetShown(UI_Elements.TARGET_FRAME, true);
	if self.success then
		TutorialQueue:Add(TutorialLogic.Tutorials.Intro_CombatTactics);
	end
end

function Class_Intro_CombatDummyInRange:OnComplete()
	TutorialLogic.Tutorials.UI_Watcher:SetShown(UI_Elements.TARGET_FRAME, true);
end


-- ------------------------------------------------------------------------------------------------------------
-- Intro Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_CombatTactics = class("Intro_CombatTactics", Class_TutorialBase);
function Class_Intro_CombatTactics:OnBegin()
	self.questID = TutorialHelper:GetFactionData().StartingQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
	end
	self.playerClass = TutorialHelper:GetClass();
end

function Class_Intro_CombatTactics:CanStart()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
		return false;
	end
	return true;
end

function Class_Intro_CombatTactics:Start()
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
	if unitGUID and (TutorialHelper:GetCreatureIDFromGUID(unitGUID) == TutorialHelper:GetFactionData().StartingQuestTargetDummyCreatureID) then
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
		TutorialQueue:NotifyDone(self);
	end
end

function Class_Intro_CombatTactics:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().StartingQuest;
	if questID == questIDRemoved then
		self.success = false;
		TutorialQueue:NotifyDone(self);
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

function Class_Intro_CombatTactics:Finish()
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("QUEST_LOG_UPDATE", self);
	self:HideResourceCallout();
	self:HideAbilityPrompt();
	self:HidePointerTutorials();

	if self.success == true then
		C_Timer.After(2, function() TutorialQueue:Add(TutorialLogic.Tutorials.QuestCompleteHelp); end);
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Intro Chat
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_Chat = class("Intro_Chat", Class_TutorialBase);
function Class_Intro_Chat:OnInitialize()
	self.ShowCount = 0;
end

function Class_Intro_Chat:OnBegin()
	if not IsActivePlayerNewcomer() then
		self:Complete();
	end
end

function Class_Intro_Chat:CanStart()
	return IsActivePlayerNewcomer();
end

function Class_Intro_Chat:Start()
	local standYourGroundCompleted = C_QuestLog.IsQuestFlaggedCompleted(TutorialHelper:GetFactionData().StandYourGround);
	if not standYourGroundCompleted then
		self:Complete();
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
		TutorialQueue:NotifyDone(self);
	end
end

function Class_Intro_Chat:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_Chat:Finish()
	self:Complete();
end

function Class_Intro_Chat:OnComplete()
	Dispatcher:UnregisterEvent("OnUpdate", self);
end


-- ------------------------------------------------------------------------------------------------------------
-- Quest Complete Help
-- ------------------------------------------------------------------------------------------------------------
Class_QuestCompleteHelp = class("QuestCompleteHelp", Class_TutorialBase);
function Class_QuestCompleteHelp:OnBegin()
	self.questID = TutorialHelper:GetFactionData().StartingQuest;
	if C_QuestLog.ReadyForTurnIn(self.questID) then
		self.QuestCompleteTimer = C_Timer.NewTimer(2, function() TutorialQueue:Add(self); end);
	end
end

function Class_QuestCompleteHelp:CanStart()
	return UnitLevel("player") < MAX_QUEST_COMPLETE_LEVEL;
end

function Class_QuestCompleteHelp:Start()
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);
	self:ShowPointerTutorial(NPEV2_QUEST_COMPLETE_HELP, "RIGHT", ObjectiveTrackerBlocksFrameHeader, -40, 0, nil, "RIGHT");
end

function Class_QuestCompleteHelp:QUEST_COMPLETE()
	if (self.QuestCompleteTimer) then
		self.QuestCompleteTimer:Cancel()
	end
	TutorialQueue:NotifyDone(self);
end

function Class_QuestCompleteHelp:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().StartingQuest;
	if questID == questIDRemoved then
		self:HidePointerTutorials();
	end
	TutorialQueue:NotifyDone(self);
end

function Class_QuestCompleteHelp:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_QuestCompleteHelp:Finish()
	self:Complete();
end

function Class_QuestCompleteHelp:OnComplete()
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("QUEST_COMPLETE", self);
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Use Minimap
-- ------------------------------------------------------------------------------------------------------------
Class_UseMinimap = class("UseMinimap", Class_TutorialBase);
function Class_UseMinimap:OnBegin()
	self.showAllUIQuestID = TutorialHelper:GetFactionData().ShowAllUIQuest;
	self.showMinimapQuestID = TutorialHelper:GetFactionData().ShowMinimapQuest;

	if C_QuestLog.IsQuestFlaggedCompleted(self.showAllUIQuestID) then
		if C_QuestLog.IsQuestFlaggedCompleted(self.showMinimapQuestID) then
			self:Complete();
		elseif C_QuestLog.GetLogIndexForQuestID(self.showMinimapQuestID) ~= nil then
			TutorialQueue:Add(self);
		end
	else
		Minimap:Hide();
		MinimapCluster:Hide();
	end
end

function Class_UseMinimap:Start()
	if C_QuestLog.IsQuestFlaggedCompleted(self.showAllUIQuestID) then
		Minimap:Show();
		MinimapCluster:Show();

		if C_QuestLog.IsQuestFlaggedCompleted(self.showMinimapQuestID) then
			TutorialQueue:NotifyDone(self);
		elseif C_QuestLog.GetLogIndexForQuestID(self.showMinimapQuestID) ~= nil then 
			self.PointerTimer = C_Timer.NewTimer(1, function() self:ShowMinimapPrompt() end);
		end
	else
		Minimap:Hide();
		MinimapCluster:Hide();
	end
end

function Class_UseMinimap:ShowMinimapPrompt()
	self:ShowPointerTutorial(NPEV2_TURN_MINIMAP_ON, "RIGHT", Minimap, 0, 0, nil, "RIGHT");
	self.EndTimer = C_Timer.NewTimer(12, function() TutorialQueue:NotifyDone(self); end);
end

function Class_UseMinimap:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_UseMinimap:Finish()
	self:Complete();
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
function Class_QuestRewardChoice:OnBegin()
end

function Class_QuestRewardChoice:Start(args)
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

	Dispatcher:RegisterEvent("QUEST_TURNED_IN", function() TutorialQueue:NotifyDone(self); end, true);
	Dispatcher:RegisterScript(QuestFrame, "OnHide", function() TutorialQueue:NotifyDone(self); end, true);
end

function Class_QuestRewardChoice:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_QuestRewardChoice:Finish()
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Intro Open Map - Main screen prompt to open the map
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_OpenMap = class("Intro_OpenMap", Class_TutorialBase);
function Class_Intro_OpenMap:OnBegin()
	self.questID = TutorialHelper:GetFactionData().UseMapQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
	elseif C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil then
		TutorialQueue:Add(self);
	end
end

function Class_Intro_OpenMap:CanStart()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
		return false;
	end
	if C_QuestLog.GetLogIndexForQuestID(self.questID) == nil then
		return false;
	end
	return true;
end

function Class_Intro_OpenMap:Start()
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
	Dispatcher:RegisterScript(WorldMapFrame, "OnShow", self);
	
	self.success = false;
	local key = TutorialHelper:GetMapBinding();
	local content = {text = NPEV2_OPENMAP, icon = nil, keyText = key};
	self:ShowSingleKeyTutorial(content);

	self.Timer = C_Timer.NewTimer(12, function()
		TutorialQueue:NotifyDone(self);
	end);
end

function Class_Intro_OpenMap:OnShow()
	self:HideSingleKeyTutorial();
	self.success = true;
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_OpenMap:PLAYER_DEAD()
	self.success = false;
	TutorialQueue:NotifyDone(self);
end

function Class_Intro_OpenMap:OnInterrupt(interruptedBy)
	self:HideSingleKeyTutorial();
	self:Complete();
end

function Class_Intro_OpenMap:CleanUp()
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	if self.Timer then
		self.Timer:Cancel()
	end
	self:HideSingleKeyTutorial();
end

function Class_Intro_OpenMap:Finish()
	Dispatcher:UnregisterScript(WorldMapFrame, "OnShow", self);
	self:CleanUp();
	if self.success then
		TutorialQueue:Add(TutorialLogic.Tutorials.Intro_MapHighlights);
	end
end

function Class_Intro_OpenMap:OnComplete()
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Map Pointers - This shows the map legend and the minimap legend
-- ------------------------------------------------------------------------------------------------------------
Class_Intro_MapHighlights = class("Intro_MapHighlights", Class_TutorialBase);
function Class_Intro_MapHighlights:OnBegin()
end

function Class_Intro_MapHighlights:CanStart()
	return WorldMapFrame:IsShown();
end

function Class_Intro_MapHighlights:Start()
	self.MapID = WorldMapFrame:GetMapID();
	self.Prompt = NPEV2_MAPCALLOUTPOINT;
	self:Display();
	Dispatcher:RegisterScript(WorldMapFrame, "OnHide", function() TutorialQueue:NotifyDone(self); end, true);

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

function Class_Intro_MapHighlights:Finish()
	self:Complete();
end


-- ------------------------------------------------------------------------------------------------------------
-- Use Quest Item - Repeatable
-- ------------------------------------------------------------------------------------------------------------
Class_UseQuestItem = class("UseQuestItem", Class_TutorialBase);
function Class_UseQuestItem:OnBegin()
	local factionData = TutorialHelper:GetFactionData();
	self.useQuestItemData = factionData.UseQuestItemData;
	self.remindUseQuestItemData = factionData.RemindUseQuestItemData;

	local useQuestItemActive = QuestUtil.IsQuestActiveButNotComplete(self.useQuestItemData.ItemQuest);
	if useQuestItemActive then
		TutorialQueue:Add(self, self.useQuestItemData);
	end

	local remindUseQuestItemActive = QuestUtil.IsQuestActiveButNotComplete(self.remindUseQuestItemData.ItemQuest);
	if remindUseQuestItemActive then
		TutorialQueue:Add(self, self.remindUseQuestItemData);
	end
end

function Class_UseQuestItem:CanStart()
	local useQuestItemActive = QuestUtil.IsQuestActiveButNotComplete(self.useQuestItemData.ItemQuest);
	local remindUseQuestItemActive = QuestUtil.IsQuestActiveButNotComplete(self.remindUseQuestItemData.ItemQuest);
	return (useQuestItemActive or remindUseQuestItemActive);
end

function Class_UseQuestItem:Start(args)
	self.questData = unpack(args);
	self.questID = self.questData.ItemQuest;
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	local questActive = C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil;
	if objectivesComplete or not questActive then
		TutorialQueue:NotifyDone(self);
		return;
	end

	Dispatcher:RegisterEvent("UNIT_TARGET", self);
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
					self.PointerID = self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
					NPE_RangeManager:Shutdown();
					NPE_RangeManager:StartWatching(target, NPE_RangeManager.Type.Unit, range, GenerateClosure(self.InRange, self));
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

	local module = QUEST_TRACKER_MODULE:GetBlock(self.questData.ItemQuest)
	if (module and module.itemButton) then
		local pointerString = self.questData.PointerTutorialStringID;
		QuestItemTutorial =	self:ShowPointerTutorial(TutorialHelper:FormatString(pointerString), "UP", module.itemButton);
	end
end

function Class_UseQuestItem:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
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

function Class_UseQuestItem:Finish()
	self:HidePointerTutorials();
	self:HideScreenTutorial();
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
end


-- ------------------------------------------------------------------------------------------------------------
-- Chang Equipment
-- ------------------------------------------------------------------------------------------------------------
Class_ChangeEquipment = class("ChangeEquipment", Class_TutorialBase);
function Class_ChangeEquipment:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_ChangeEquipment:Start(args)
	self.data = unpack(args);
	if (MerchantFrame:IsVisible()) then
		self:Interrupt(self);
		return;
	end

	Dispatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
	Dispatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA", self);
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);

	EventRegistry:RegisterCallback("ContainerFrame.AllBagsClosed", self.BagClosed, self);
	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.BagOpened, self);
	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", self.BagClosed, self);
	EventRegistry:RegisterCallback("ContainerFrame.OpenBackpack", self.BagOpened, self);
	EventRegistry:RegisterCallback("ContainerFrame.CloseBackpack", self.BagClosed, self);

	if (not GetContainerItemID(self.data.Container, self.data.ContainerSlot)) then
		TutorialQueue:NotifyDone(self);
		return;
	end

	self:Reset();
end

function Class_ChangeEquipment:PLAYER_DEAD()
	TutorialQueue:NotifyDone(self);

	-- the player died in the middle of the tutorial, requeue it so that when the player is alive, they can try again
	self.Timer = C_Timer.NewTimer(0.1, function()
		TutorialQueue:Add(TutorialLogic.Tutorials.ItemUpgradeCheckingService);
	end);
end

function Class_ChangeEquipment:ZONE_CHANGED_NEW_AREA()
	TutorialQueue:NotifyDone(self);

	-- the player changed zones in the middle of the tutorial, requeue it so that when the player can try again
	self.Timer = C_Timer.NewTimer(0.1, function()
		TutorialQueue:Add(TutorialLogic.Tutorials.ItemUpgradeCheckingService);
	end);
end

function Class_ChangeEquipment:Reset()
	self.success = false;
	NPE_TutorialDragButton:Hide();
	self:HidePointerTutorials();
	self:PrepBags();
end

function Class_ChangeEquipment:PrepBags()
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
			TutorialHelper:CloseAllBags();
			self:OpenAllBags();
		end);
	end
end

function Class_ChangeEquipment:BagClosed()
	if self.success then
		TutorialQueue:NotifyDone(self);
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
		TutorialQueue:NotifyDone(self);
		return;
	end
	self:Reset();
end

function Class_ChangeEquipment:CheckReady()
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

function Class_ChangeEquipment:PLAYER_EQUIPMENT_CHANGED()
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
				TutorialQueue:NotifyDone(self);
			end);
		else
			TutorialQueue:NotifyDone(self);
		end
	end
end

function Class_ChangeEquipment:StartAnimation()
	if not self.data then
		TutorialQueue:NotifyDone(self);
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

		NPE_TutorialDragButton:Show(self.originFrame, self.destFrame);
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

function Class_ChangeEquipment:UpdateDragOrigin()
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
				TutorialQueue:NotifyDone(self);
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
		TutorialQueue:NotifyDone(self);
	end
end

function Class_ChangeEquipment:OnInterrupt()
	TutorialQueue:NotifyDone(self);
	self:Complete();
end

function Class_ChangeEquipment:Finish()
	NPE_TutorialDragButton:Hide();
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

	EventRegistry:UnregisterCallback("ContainerFrame.AllBagsClosed", self);
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);
	EventRegistry:UnregisterCallback("ContainerFrame.CloseBag", self);
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBackpack", self);
	EventRegistry:UnregisterCallback("ContainerFrame.CloseBackpack", self);
	EventRegistry:UnregisterCallback("CharacterFrame.Show", self);
	EventRegistry:UnregisterCallback("CharacterFrame.Hide", self);
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	Dispatcher:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", self);
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	Dispatcher:UnregisterEvent("ZONE_CHANGED_NEW_AREA", self);
end

function Class_ChangeEquipment:OnComplete()
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics = class("EnhancedCombatTactics", Class_TutorialBase);
function Class_EnhancedCombatTactics:OnBegin()
	self.questID = TutorialHelper:GetFactionData().EnhancedCombatTacticsQuest;
	local questComplete = C_QuestLog.IsQuestFlaggedCompleted(self.questID);
	if questComplete then
		self:Complete();
		return;
	end
	if C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil then
		TutorialQueue:Add(self);
	end
end

function Class_EnhancedCombatTactics:CanStart()
	local questComplete = C_QuestLog.IsQuestFlaggedCompleted(self.questID);
	if questComplete then
		self:Complete();
		return false;
	end
	return (C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil);
end

function Class_EnhancedCombatTactics:Start()
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);

	local playerClass = TutorialHelper:GetClass();

	self.completed = false;
	if playerClass == "WARRIOR" then
		TutorialQueue:Add(TutorialLogic.Tutorials.EnhancedCombatTactics_Warrior);
		TutorialQueue:NotifyDone(self);
	elseif playerClass == "ROGUE" then
		TutorialQueue:Add(TutorialLogic.Tutorials.EnhancedCombatTactics_Rogue);
		TutorialQueue:NotifyDone(self);
	elseif playerClass == "PRIEST" or playerClass == "WARLOCK" or playerClass == "DRUID" then
		TutorialQueue:Add(TutorialLogic.Tutorials.EnhancedCombatTactics_UseDoTs);
		TutorialQueue:NotifyDone(self);
	elseif playerClass == "SHAMAN" or playerClass == "MAGE" then
		TutorialQueue:Add(TutorialLogic.Tutorials.EnhancedCombatTactics_Ranged	);
		TutorialQueue:NotifyDone(self);
	elseif playerClass == "HUNTER" or playerClass == "MONK" then
		self.completed = true;
		-- Hunters and Monks do not have an Enhanced Combat Tutorial
		TutorialQueue:NotifyDone(self);
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
	TutorialQueue:Add(TutorialLogic.Tutorials.AddSpellToActionBarService, spellID, warningString, spellbookString);
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
	self.completed = false;
	TutorialQueue:NotifyDone(self);
end

function Class_EnhancedCombatTactics:CleanUp()
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("QUEST_LOG_UPDATE", self);

	self:HidePointerTutorials();
	self:HideScreenTutorial();

	if self.completed == true then
		TutorialLogic.Tutorials.LowHealthWatcher:StartWatching();
	end
end

function Class_EnhancedCombatTactics:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics:Finish()
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
function Class_EnhancedCombatTactics_Warrior:OnBegin()
	self.questID = TutorialHelper:GetFactionData().EnhancedCombatTacticsQuest;
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
end

function Class_EnhancedCombatTactics_Warrior:Start()
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
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

function Class_EnhancedCombatTactics_Warrior:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics_Warrior:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics_Warrior:OnInterrupt(interruptedBy)
	self.completed = false;
	TutorialQueue:NotifyDone(self);
end

function Class_EnhancedCombatTactics_Warrior:Finish()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_POWER_FREQUENT", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics For Rogue
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_Rogue = class("EnhancedCombatTactics_Rogue", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_Rogue:OnBegin()
	self.questID = TutorialHelper:GetFactionData().EnhancedCombatTacticsQuest;
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
end

function Class_EnhancedCombatTactics_Rogue:Start()
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
	TutorialQueue:NotifyDone(self);
end

function Class_EnhancedCombatTactics_Rogue:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics_Rogue:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics_Rogue:Finish()
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
function Class_EnhancedCombatTactics_UseDoTs:OnBegin()
	self.questID = TutorialHelper:GetFactionData().EnhancedCombatTacticsQuest;
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
end

function Class_EnhancedCombatTactics_UseDoTs:Start()
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
	Dispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
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
	self.completed = false;
	TutorialQueue:NotifyDone(self);
end

function Class_EnhancedCombatTactics_UseDoTs:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics_UseDoTs:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics_UseDoTs:Finish()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics for Ranged Classes
-- ------------------------------------------------------------------------------------------------------------
Class_EnhancedCombatTactics_Ranged = class("EnhancedCombatTactics_Ranged", Class_EnhancedCombatTactics);
function Class_EnhancedCombatTactics_Ranged:OnBegin()
	self.questID = TutorialHelper:GetFactionData().EnhancedCombatTacticsQuest;
	self.combatData = TutorialHelper:FilterByClass(TutorialData.ClassData);
end

function Class_EnhancedCombatTactics_Ranged:Start()
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
	self.completed = false;
	TutorialQueue:NotifyDone(self);
end

function Class_EnhancedCombatTactics_Ranged:QUEST_REMOVED(questID)
	if questID == self.questID then
		self.completed = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics_Ranged:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.completed = true;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_EnhancedCombatTactics_Ranged:Finish()
	Dispatcher:UnregisterEvent("UNIT_TARGET", self);
	Dispatcher:UnregisterEvent("UNIT_TARGETABLE_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:CleanUp();
end


-- ------------------------------------------------------------------------------------------------------------
-- Add Hunter Tame Spells
-- ------------------------------------------------------------------------------------------------------------
Class_AddHunterTameSpells = class("AddHunterTameSpells", Class_TutorialBase);
function Class_AddHunterTameSpells:OnBegin()
	self.playerClass = TutorialHelper:GetClass();
	if self.playerClass ~= "HUNTER" then
		self:Complete();
	end

	self.questID = TutorialHelper:GetFactionData().HunterTameTutorialQuestID;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) or C_QuestLog.ReadyForTurnIn(self.questID) then
		self:Complete();
		return;
	end

	local questActive = C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil;
	if questActive then
		TutorialQueue:Add(self);
	end
end

function Class_AddHunterTameSpells:Start()
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
			self:StartTameTutorial();
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

function Class_AddHunterTameSpells:LEARNED_SPELL_IN_TAB(spellID)
	if self:KnowsRequiredSpells() then
		Dispatcher:UnregisterEvent("LEARNED_SPELL_IN_TAB", self);
		if self:CheckForSpellsOnActionBar() then
			self:StartTameTutorial();
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
			TutorialQueue:Add(TutorialLogic.Tutorials.AddSpellToActionBarService, spellID, nil, NPEV2_SPELLBOOK_TUTORIAL, "MultiBarBottomLeftButton");
		end
	end
	self:StartTameTutorial();
end

function Class_AddHunterTameSpells:StartTameTutorial()
	TutorialQueue:Add(TutorialLogic.Tutorials.HunterTame);
	TutorialQueue:NotifyDone(self);
end


-- ------------------------------------------------------------------------------------------------------------
-- Hunter Tame
-- ------------------------------------------------------------------------------------------------------------
Class_HunterTame = class("HunterTame", Class_TutorialBase);
function Class_HunterTame:OnBegin()
	self.playerClass = TutorialHelper:GetClass();
	if self.playerClass ~= "HUNTER" then
		self:Complete();
	end

	self.questID = TutorialHelper:GetFactionData().HunterTameTutorialQuestID;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) or C_QuestLog.ReadyForTurnIn(self.questID) then
		self:Complete();
		return;
	end
end

function Class_HunterTame:Start()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) or C_QuestLog.ReadyForTurnIn(self.questID) then
		self:Complete();
		return;
	end

	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	self.spellsReady = true;

	if TutorialLogic.Tutorials.AddHunterTameSpells:CheckForSpellsOnActionBar() then
		self:StartTameTutorial();
	else
		TutorialQueue:Add(TutorialLogic.Tutorials.AddHunterTameSpells);
		self.success = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_HunterTame:StartTameTutorial()
	local button = TutorialHelper:GetActionButtonBySpellID(1515);
	if button then
		self:ShowPointerTutorial(NPEV2_HUNTER_TAME_ANIMAL, "DOWN", button, 0, 30, nil, "UP");
		Dispatcher:RegisterEvent("PET_STABLE_UPDATE", self);
	else
		TutorialQueue:Add(TutorialLogic.Tutorials.AddHunterTameSpells);
		self.success = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_HunterTame:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().HunterTameTutorialQuestID;
	if questID == questIDRemoved then
		self.success = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_HunterTame:QUEST_LOG_UPDATE()
	local objectivesComplete = C_QuestLog.IsComplete(self.questID);
	if (objectivesComplete) then
		self.success = true;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_HunterTame:PET_STABLE_UPDATE()
	self.success = true;
	TutorialQueue:NotifyDone(self);
end

function Class_HunterTame:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_HunterTame:Finish()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:UnregisterEvent("PET_STABLE_UPDATE", self);
	Dispatcher:UnregisterEvent("QUEST_LOG_UPDATE", self);
	self:HidePointerTutorials();

	if self.success == true then
		TutorialLogic.Tutorials.AddHunterTameSpells:Complete();
		self:Complete();
	end
end

function Class_HunterTame:OnComplete()
	self:HidePointerTutorials();
end


-- ------------------------------------------------------------------------------------------------------------
-- Eat Food
-- ------------------------------------------------------------------------------------------------------------
Class_EatFood = class("EatFood", Class_TutorialBase);
function Class_EatFood:OnBegin()
end

function Class_EatFood:Start(args)
	local inCombat = unpack(args);
	if self.tutorialSuccess == true then
		TutorialQueue:NotifyDone(self);
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
		TutorialQueue:NotifyDone(self);
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
			TutorialQueue:NotifyDone(self);
		end);
	end
end

function Class_EatFood:Reset()
	if not self.tutorialSuccess then
		TutorialQueue:NotifyDone(self);
		TutorialLogic.Tutorials.LowHealthWatcher:StartWatching();
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
	self.tutorialSuccess = false;
	TutorialQueue:NotifyDone(self);
end

function Class_EatFood:Finish()
	Dispatcher:UnregisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:UnregisterEvent("PLAYER_REGEN_ENABLED", self);
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	Dispatcher:UnregisterEvent("UNIT_HEALTH", self);

	self:HidePointerTutorials();
	self:HideScreenTutorial();
	if self.tutorialSuccess == true then
		self:Complete();
	end
end


-- ============================================================================================================
-- Use Vendor
-- ============================================================================================================
Class_UseVendor = class("UseVendor", Class_TutorialBase);
function Class_UseVendor:OnBegin()
	local tutorialData = TutorialHelper:GetFactionData();
	self.questID = tutorialData.UseVendorQuest;

	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
		return;
	end

	local questActive = C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil;
	if questActive then
		TutorialQueue:Add(self);
	end
end

function Class_UseVendor:CanStart()
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		self:Complete();
		return false;
	end
	return (C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil);
end

function Class_UseVendor:Start()
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
		TutorialQueue:NotifyDone(self);
		return;
	end

	Dispatcher:RegisterEvent("MERCHANT_CLOSED", self);
	Dispatcher:RegisterEvent("ITEM_LOCKED", self);
	self:MerchantTabHelp();
end

function Class_UseVendor:MERCHANT_CLOSED()
	if self.buyTutorialComplete == true and self.sellTutorialComplete == true --[[and self.buyBackTutorialComplete == true]] then
		TutorialQueue:NotifyDone(self);
		return;
	end

	Dispatcher:UnregisterEvent("MERCHANT_CLOSED", self);
	self.buyBackTab = false;
	self.merchantTab = false;
	self:HidePointerTutorials();
end

function Class_UseVendor:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_UseVendor:Finish()
	EventRegistry:UnregisterCallback("MerchantFrame.BuyBackTabShow", self);
	EventRegistry:UnregisterCallback("MerchantFrame.MerchantTabShow", self);
	Dispatcher:UnregisterEvent("MERCHANT_SHOW", self);
	self.buyPointerID = nil;
	self.sellPointerID = nil;
	self:HidePointerTutorials();

	self:Complete();
end


-- ------------------------------------------------------------------------------------------------------------
-- LFG Status Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_PromptLFG = class("PromptLFG", Class_TutorialBase);
function Class_PromptLFG:OnBegin()
	local _, instanceType = GetInstanceInfo();
	if instanceType ~= "none" then
		-- we are in a dungeon, we succeeded somehow
		self:Complete();
		return;
	end

	self.questID = TutorialHelper:GetFactionData().LookingForGroupQuest;
	if QuestUtil.IsQuestActiveButNotComplete(self.questID) then
		TutorialQueue:Add(self);
	end
end

function Class_PromptLFG:Start()
	local _, instanceType = GetInstanceInfo();
	if instanceType ~= "none" then
		-- we are in a dungeon, we succeeded somehow
		self.success = true;
		TutorialQueue:NotifyDone(self);
		return;
	end

	if C_QuestLog.GetLogIndexForQuestID(self.questID) == nil then
		self.questRemoved = true;
		self.success = false;
		TutorialQueue:NotifyDone(self);
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
		ActionButton_ShowOverlayGlow(LFDMicroButton);
		self:ShowPointerTutorial(NPEV2_LFD_INTRO, "DOWN", LFDMicroButton, 0, 10, nil, "DOWN");
	end
end

function Class_PromptLFG:QUEST_REMOVED(questIDRemoved)
	if self.questID == questIDRemoved then
		self.questRemoved = true;
		self.success = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_PromptLFG:ShowLFG()
	self.success = true;
	TutorialQueue:NotifyDone(self);
end

function Class_PromptLFG:CloseTutorialElements()
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	if self.onShowID then
		Dispatcher:UnregisterScript(PVEFrame, "OnShow", self.onShowID);
		self.onShowID = nil;
	end
	ActionButton_HideOverlayGlow(LFDMicroButton);
end

function Class_PromptLFG:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_PromptLFG:Finish()
	self:HidePointerTutorials();
	ActionButton_HideOverlayGlow(LFDMicroButton);
	self:CloseTutorialElements();

	if self.success == true then
		TutorialQueue:Add(TutorialLogic.Tutorials.LookingForGroup);
	elseif not self.questRemoved then
		TutorialQueue:Add(TutorialLogic.Tutorials.PromptLFG);
	end
end

function Class_PromptLFG:OnComplete()
	self:CloseTutorialElements();
end


-- ------------------------------------------------------------------------------------------------------------
-- Looking For Group
-- ------------------------------------------------------------------------------------------------------------
Class_LookingForGroup = class("LookingForGroup", Class_TutorialBase);
function Class_LookingForGroup:OnBegin()
	local _, instanceType = GetInstanceInfo();
	if instanceType ~= "none" then
		-- we are in a dungeon, we succeeded somehow
		self:Complete();
	end
end

function Class_LookingForGroup:Start()
	local _, instanceType = GetInstanceInfo();
	if instanceType ~= "none" then
		-- we are in a dungeon, we succeeded somehow
		self.success = true;
		TutorialQueue:NotifyDone(self);
		return;
	end

	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	Dispatcher:RegisterEvent("LFG_UPDATE", self);
	Dispatcher:RegisterEvent("LFG_PROPOSAL_SHOW", self);

	EventRegistry:RegisterCallback("LFDQueueFrameSpecificList_Update.EmptyDungeonList", self.EmptyDungeonList, self);
	EventRegistry:RegisterCallback("LFDQueueFrameSpecificList_Update.DungeonListReady", self.ReadyDungeonList, self);
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
		TutorialQueue:NotifyDone(self);
		return;
	elseif LFGDungeonReadyPopup:IsShown() then
		self.success = true;
		TutorialQueue:NotifyDone(self);
		return;
	elseif self.inQueue then
		return;-- the player is queued for the dungeon
	end
	self.success = false;
	TutorialQueue:NotifyDone(self);
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
	self.success = true;
	TutorialQueue:NotifyDone(self);
end

function Class_LookingForGroup:QUEST_REMOVED(questIDRemoved)
	local questID = TutorialHelper:GetFactionData().LookingForGroupQuest;
	if questID == questIDRemoved then
		self.questRemoved = true;
		self.success = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_LookingForGroup:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_LookingForGroup:Finish()
	GlowEmitterFactory:Hide(LFDQueueFrameFindGroupButton);
	Dispatcher:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE", self);
	Dispatcher:UnregisterEvent("LFG_PROPOSAL_FAILED", self);
	Dispatcher:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE", self);

	EventRegistry:UnregisterCallback("LFDQueueFrameSpecificList_Update.EmptyDungeonList", self);
	EventRegistry:UnregisterCallback("LFDQueueFrameSpecificList_Update.DungeonListReady", self);
	EventRegistry:UnregisterCallback("LFGDungeonList.DungeonEnabled", self);
	EventRegistry:UnregisterCallback("LFGDungeonList.DungeonDisabled", self);

	if self.onHideID then
		Dispatcher:UnregisterScript(PVEFrame, "OnHide", self.onHideID);
		self.onHideID = nil;
	end

	self:HidePointerTutorials();
	self:HideScreenTutorial();
	ActionButton_HideOverlayGlow(LFDMicroButton);

	if self.success == true then
		TutorialLogic.Tutorials.PromptLFG:Complete();
		self:Complete();
	else
		if not self.questRemoved then
			TutorialQueue:Add(TutorialLogic.Tutorials.PromptLFG);
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Leave Party Prompt
-- ------------------------------------------------------------------------------------------------------------
Class_LeavePartyPrompt = class("LeavePartyPrompt", Class_TutorialBase);
function Class_LeavePartyPrompt:OnBegin()
end

function Class_LeavePartyPrompt:Start()
	self.pointerID = self:AddPointerTutorial(NPEV2_LEAVE_PARTY_PROMPT, "LEFT", PlayerFrame, 0, 0);
	C_Timer.After(12, function()
		TutorialQueue:NotifyDone(self);
	end);
end

function Class_LeavePartyPrompt:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_LeavePartyPrompt:Finish()
	self:Complete();
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
function Class_MountReceived:OnBegin()
	self.questID = TutorialHelper:GetFactionData().GetMountQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		TutorialQueue:Add(self);
	end
end

function Class_MountReceived:CanStart()
	return C_QuestLog.IsQuestFlaggedCompleted(self.questID);
end

function Class_MountReceived:Start()
	self.mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	self.mountID = self.mountData.mountID;
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
		Dispatcher:RegisterFunction("ToggleBackpack", function() self:BackpackOpened() end, true);
		local key = TutorialHelper:GetBagBinding();
		local tutorialString = TutorialHelper:FormatString(string.format(NPEV2_MOUNT_TUTORIAL_INTRO, key))
		self:ShowPointerTutorial(tutorialString, "DOWN", MainMenuBarBackpackButton, 0, 10, nil, "DOWN");
	else
		-- the player doesn't have the mount
		self.proceed = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_MountReceived:CheckHasMountItem()
	local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	local mountItem = mountData.mountItem;
	return TutorialHelper:FindItemInContainer(mountItem);
end

function Class_MountReceived:BackpackOpened()
	local container, slot = self:CheckHasMountItem();
	if container and slot then
		local itemFrame = TutorialHelper:GetItemContainerFrame(container, slot)
		self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P2_BEGIN, "DOWN", itemFrame, 0, 10, nil, "RIGHT");
	else
		-- the player doesn't have the mount
		self.proceed = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_MountReceived:NEW_MOUNT_ADDED(data)
	Dispatcher:UnregisterEvent("NEW_MOUNT_ADDED", self);

	if TutorialHelper:GetActionButtonBySpellID(self.mountData.mountID) then
		TutorialQueue:Add(TutorialLogic.Tutorials.UseMount);
		self.proceed = false;
		TutorialQueue:NotifyDone(self);
		return;
	end

	TutorialHelper:CloseAllBags();
	ActionButton_ShowOverlayGlow(CollectionsMicroButton)
	self:HidePointerTutorials();

	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P2_NEW_MOUNT_ADDED, "DOWN", CollectionsMicroButton, 0, 10, nil, "DOWN");
	Dispatcher:RegisterFunction("ToggleCollectionsJournal", function()
		SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
		MountJournal_SelectByMountID(self.mountID);
		self.proceed = true;
		TutorialQueue:NotifyDone(self);
	end, true);
end

function Class_MountReceived:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_MountReceived:Finish()
	Dispatcher:UnregisterEvent("NEW_MOUNT_ADDED", self);
	self:HidePointerTutorials();
	ActionButton_HideOverlayGlow(CollectionsMicroButton);
	if self.proceed == true then
		TutorialQueue:Add(TutorialLogic.Tutorials.AddMountToActionBar, self.mountData);
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Add Mount To Action Bar
-- ------------------------------------------------------------------------------------------------------------
Class_AddMountToActionBar = class("AddMountToActionBar", Class_TutorialBase);
function Class_AddMountToActionBar:OnBegin(mountID)
	self.mountID = mountID;
	self.questID = TutorialHelper:GetFactionData().GetMountQuest;
end

function Class_AddMountToActionBar:CanStart()
	self.questID = TutorialHelper:GetFactionData().GetMountQuest;
	return C_QuestLog.IsQuestFlaggedCompleted(self.questID);
end

function Class_AddMountToActionBar:Start(args)
	self.mountData = unpack(args);
	EventRegistry:RegisterCallback("MountJournal.OnHide", self.MountJournalHide, self);
	Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);

	if TutorialHelper:GetActionButtonBySpellID(self.mountData.mountID) then
		self.success = true;
		TutorialQueue:NotifyDone(self);
		return;
	end

	C_Timer.After(0.1, function()
		self:MountJournalShow();
	end);
end

function Class_AddMountToActionBar:MountJournalShow()
	self.originButton = MountJournal_GetMountButtonByMountID(self.mountData.mountID);
	self.destButton = TutorialHelper:FindEmptyButton();
	if(self.originButton and self.destButton) then
		NPE_TutorialDragButton:Show(self.originButton, self.destButton);
	end
	self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P3, "LEFT", button or MountJournal, 0, 10, nil, "LEFT");
end

function Class_AddMountToActionBar:MountJournalHide()
	TutorialQueue:NotifyDone(self);
end

function Class_AddMountToActionBar:ACTIONBAR_SLOT_CHANGED(slot)
	local actionType, sID, subType = GetActionInfo(slot);

	if sID == self.mountData.mountID then
		TutorialQueue:NotifyDone(self);
	else
		local nextEmptyButton = TutorialHelper:FindEmptyButton();
		if not nextEmptyButton then
			-- no more empty buttons
			self.success = false;
			TutorialQueue:NotifyDone(self);
			self:Complete();
		else
			NPE_TutorialDragButton:Hide();
			self.destButton = nextEmptyButton;
			NPE_TutorialDragButton:Show(self.originButton, self.destButton);
		end
	end
end

function Class_AddMountToActionBar:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_AddMountToActionBar:Finish()
	EventRegistry:UnregisterCallback("MountJournal.OnHide", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	NPE_TutorialDragButton:Hide();
	self:HidePointerTutorials();

	if TutorialHelper:GetActionButtonBySpellID(self.mountData.mountID) then
		TutorialQueue:Add(TutorialLogic.Tutorials.UseMount);
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Use Mount
-- ------------------------------------------------------------------------------------------------------------
Class_UseMount = class("UseMount", Class_TutorialBase);
function Class_UseMount:OnBegin()
end

function Class_UseMount:CanStart()
	return not IsMounted();
end

function Class_UseMount:Start()
	if IsMounted() then
		TutorialQueue:NotifyDone(self);
		return;
	end
	self.Timer = C_Timer.NewTimer(20, function() TutorialQueue:NotifyDone(self); end);

	Dispatcher:RegisterEvent("ACTIONBAR_UPDATE_USABLE", self);
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
	self.mountID = mountData.mountID;
	self.mountSpellID = mountData.mountSpellID;
	self:TryUseMount();
end

function Class_UseMount:TryUseMount()
	local button = TutorialHelper:GetActionButtonBySpellID(self.mountID);
	if button and IsUsableAction(button.action) then
		self:ShowPointerTutorial(NPEV2_MOUNT_TUTORIAL_P4, "DOWN", button, 0, 10, nil, "UP");
	end
end

function Class_UseMount:ACTIONBAR_UPDATE_USABLE()
	self:TryUseMount();
end

function Class_UseMount:UNIT_SPELLCAST_SUCCEEDED(caster, spelllineID, spellID)
	if self.mountSpellID == spellID then
		TutorialQueue:NotifyDone(self);
	end
end

function Class_UseMount:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_UseMount:Finish()
	Dispatcher:UnregisterEvent("ACTIONBAR_UPDATE_USABLE", self);
	Dispatcher:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	self:HidePointerTutorials();
	if self.Timer then
		self.Timer:Cancel();
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Change Spec
-- ------------------------------------------------------------------------------------------------------------
Class_ChangeSpec = class("ChangeSpec", Class_TutorialBase);
function Class_ChangeSpec:OnBegin()
	local tutorialData = TutorialHelper:GetFactionData();
	self.specQuestID = TutorialHelper:FilterByClass(tutorialData.SpecQuests);
end

function Class_ChangeSpec:Start()
	if C_QuestLog.IsQuestFlaggedCompleted(self.specQuestID) then 
		self:Complete();
		return;
	end
	self.success = false;

	Dispatcher:RegisterEvent("QUEST_REMOVED", self);
	Dispatcher:RegisterEvent("GOSSIP_SHOW", self);
end

function Class_ChangeSpec:QUEST_REMOVED(questIDRemoved)
	if self.specQuestID == questIDRemoved then
		self.success = false;
		TutorialQueue:NotifyDone(self);
	end
end

function Class_ChangeSpec:GOSSIP_SHOW()
	Dispatcher:RegisterEvent("UNIT_QUEST_LOG_CHANGED", self);
end

function Class_ChangeSpec:UNIT_QUEST_LOG_CHANGED()
	Dispatcher:UnregisterEvent("UNIT_QUEST_LOG_CHANGED", self);
	self:ShowPointerTutorial(NPEV2_SPEC_TUTORIAL_GOSSIP_CLOSED, "DOWN", TalentMicroButton, 0, 10, nil, "DOWN");
	ActionButton_ShowOverlayGlow(TalentMicroButton);
	self.functionID = Dispatcher:RegisterFunction("ToggleTalentFrame", function()
		self:TutorialToggleTalentFrame();
		end, false);
end

function Class_ChangeSpec:TutorialToggleTalentFrame()
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

function Class_ChangeSpec:ShowTalentChoiceHelp()
	ActionButton_HideOverlayGlow(TalentMicroButton);
	self:ShowPointerTutorial(NPEV2_SPEC_TUTORIAL_TOGGLE_TALENT_FRAME, "DOWN", PlayerTalentFrameSpecializationSpecButton1, 10, 0, nil, "DOWN");

	Dispatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);
	self.Timer = C_Timer.NewTimer(120, function() TutorialQueue:NotifyDone(self); end);
end

function Class_ChangeSpec:PLAYER_SPECIALIZATION_CHANGED()
	self.success = true;
	TutorialQueue:NotifyDone(self);
end

function Class_ChangeSpec:OnInterrupt(interruptedBy)
	self.success = false;
	TutorialQueue:NotifyDone(self);
end

function Class_ChangeSpec:Finish()
	Dispatcher:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);
	Dispatcher:UnregisterEvent("UNIT_QUEST_LOG_CHANGED", self);
	if self.Timer then
		self.Timer:Cancel();
	end
	ActionButton_HideOverlayGlow(TalentMicroButton);
	self:HidePointerTutorials();
	if self.success then
		self:Complete();
	end
end


-- ============================================================================================================
-- Death Watch - watches for the player to die
-- ============================================================================================================
Class_Death_Watcher = class("Death_Watcher", Class_TutorialBase);
function Class_Death_Watcher:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
end

function Class_Death_Watcher:PLAYER_DEAD()
	TutorialQueue:Add(TutorialLogic.Tutorials.Death_ReleaseCorpse);
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: [Release Corpse] - Map Prompt - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------
Class_Death_ReleaseCorpse = class("Death_ReleaseCorpse", Class_TutorialBase);
function Class_Death_ReleaseCorpse:OnBegin()
end

function Class_Death_ReleaseCorpse:Start()
	Dispatcher:RegisterEvent("PLAYER_ALIVE", self);
	self:ShowPointerTutorial(TutorialHelper:FormatString(NPEV2_RELEASESPIRIT), "LEFT", StaticPopup1);
end

-- PLAYER_ALIVE gets called when the player releases, not when they get back to their corpse
function Class_Death_ReleaseCorpse:PLAYER_ALIVE()
	TutorialQueue:NotifyDone(self);
end

function Class_Death_ReleaseCorpse:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_Death_ReleaseCorpse:Finish()
	self:HidePointerTutorials();
	if (UnitIsGhost("player")) then
		TutorialQueue:Add(TutorialLogic.Tutorials.Death_MapPrompt);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - [Map Prompt] - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------
Class_Death_MapPrompt = class("Death_MapPrompt", Class_TutorialBase);
function Class_Death_MapPrompt:OnBegin()
end

function Class_Death_MapPrompt:Start()
	local key = TutorialHelper:GetMapBinding();
	local content = {text = NPEV2_FINDCORPSE, icon=nil, keyText=key};
	self:ShowSingleKeyTutorial(content);

	Dispatcher:RegisterEvent("CORPSE_IN_RANGE", self);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_MapPrompt:PLAYER_UNGHOST()
	TutorialQueue:NotifyDone(self);
end

function Class_Death_MapPrompt:CORPSE_IN_RANGE()
	TutorialQueue:NotifyDone(self);
end

function Class_Death_MapPrompt:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_Death_MapPrompt:Finish()
	self:HideSingleKeyTutorial();
	if (UnitIsGhost("player")) then
		TutorialQueue:Add(TutorialLogic.Tutorials.Death_ResurrectPrompt);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - Map Prompt - [Resurrect Prompt]
-- ------------------------------------------------------------------------------------------------------------
Class_Death_ResurrectPrompt = class("Death_ResurrectPrompt", Class_TutorialBase);
function Class_Death_ResurrectPrompt:OnBegin()
end

function Class_Death_ResurrectPrompt:Start()
	self.Timer = C_Timer.NewTimer(2, function() GlowEmitterFactory:Show(StaticPopup1Button1, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow) end);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_ResurrectPrompt:PLAYER_UNGHOST()
	TutorialQueue:NotifyDone(self);
end

function Class_Death_ResurrectPrompt:OnInterrupt(interruptedBy)
	TutorialQueue:NotifyDone(self);
end

function Class_Death_ResurrectPrompt:Finish()
	GlowEmitterFactory:Hide(StaticPopup1Button1);
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
	local playerLevel = UnitLevel("player");
	if playerLevel > MAX_LOOT_CORPSE_LEVEL then -- if the player comes back after level 4, don't prompt them on loot anymore
		self:Complete();
		return;
	end
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
			TutorialLogic.Tutorials.LootCorpse:ForceBegin(unitID);
			return;
		end
	end

	-- if the player hasn't looted their last mob increment the reprompt threshold
	if (self.PendingLoot) then
		self.RePromptLootCount = self.RePromptLootCount + 1;
	end
	self.PendingLoot = true;

	if ((self.LootCount < 3) or (self.RePromptLootCount >= 2)) then
		TutorialLogic.Tutorials.LootCorpse:Begin();
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
		TutorialLogic.Tutorials.LootPointer:Begin();
	end
end

function Class_LootCorpse:CHAT_MSG_LOOT(...)
	self:Complete();
end

function Class_LootCorpse:CHAT_MSG_MONEY(...)
	self:Complete();
end

function Class_LootCorpse:LOOT_CLOSED(...)
	TutorialLogic.Tutorials.LootPointer:Begin();
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

	TutorialLogic.Tutorials.LootPointer:Complete();

	if (self.QuestMobID) then
		self.QuestMobCount = self.QuestMobCount + 1;
	end

	TutorialLogic.Tutorials.LootCorpseWatcher:LootSuccessful(self.QuestMobID);
	self.ShowPointer = false;
end

-- ------------------------------------------------------------------------------------------------------------
-- Prompts how to use the loot window the first time
-- This is managed and completed by LootCorpse
-- ------------------------------------------------------------------------------------------------------------
Class_LootPointer = class("LootPointer", Class_TutorialBase);
function Class_LootPointer:OnBegin()
	local level = UnitLevel("player");
	if (level > MAX_LOOT_CORPSE_LEVEL) then -- if the player comes back after level 4, don't prompt them on loot anymore
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
