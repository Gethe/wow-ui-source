local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;

TutorialLogic = {};
function TutorialLogic:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel > 10 then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	else
		local LevelUpTutorial_spellIDlookUp = TutorialHelper:FilterByClass(TutorialData.LevelAbilitiesTable);
		local warningString = nil;
		local preferredActionBar = nil;
		for i = originalLevel + 1, newLevel do
			local spellID = LevelUpTutorial_spellIDlookUp[i];
			if spellID then
				TutorialManager:Queue(Class_AddSpellToActionBarService.name, spellID, warningString, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar);
			end
		end
	end
end

function TutorialLogic:PLAYER_UNGHOST()
	TutorialQueue:CheckQueue();
end

function TutorialLogic:CheckFormSpells()
	local form = GetShapeshiftFormID();
	local formSpells = nil;

	if form == DRUID_BEAR_FORM then
		formSpells = TutorialData.DruidAnimalFormSpells.bearSpells;
	elseif form == DRUID_CAT_FORM then
		formSpells = TutorialData.DruidAnimalFormSpells.catSpells;
	elseif form == ROGUE_STEALTH then
		formSpells = TutorialData.RogueStealthSpells;
	end
	if formSpells then
		local warningString = nil;
		local preferredActionBar = nil;
		for i, spellID in ipairs(formSpells) do
			if IsSpellKnown(spellID) then
				TutorialManager:Queue(Class_AddSpellToActionBarService.name, spellID, warningString, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar, form);
			end
		end
	end
end

function TutorialLogic:UPDATE_SHAPESHIFT_FORM()
	local level = UnitLevel("player");
	if level > TutorialData.MAX_SPELL_HELP_LEVEL then
		Dispatcher:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", self);
		return;
	end
	
	C_Timer.After(0.25, function()
		self:CheckFormSpells();
	end);
end

function TutorialLogic:Begin()
	self.playerClass = TutorialHelper:GetClass();
	self.factionData = TutorialData:GetFactionData();-- get the data for the player's faction
	self.vendorQuestID = self.factionData.UseVendorQuest;
	self.specQuestID = TutorialHelper:FilterByClass(self.factionData.SpecQuests);
	
	TutorialQuestManager:RegisterForCallbacks(self);-- Certain tutorials kick off when quests are accepted
	
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
	if self.playerClass == "ROGUE" or self.playerClass == "DRUID" then
		Dispatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	end

	-- add tutorials
	TutorialManager:AddTutorial(Class_AddSpellToActionBarService:new());
	TutorialManager:AddTutorial(Class_ItemUpgradeCheckingService:new());
	TutorialManager:AddTutorial(Class_Intro_KeyboardMouse:new());
	TutorialManager:AddTutorial(Class_Intro_CameraLook:new());
	TutorialManager:AddTutorial(Class_Intro_ApproachQuestGiver:new());
	TutorialManager:AddTutorial(Class_Intro_Interact:new());
	TutorialManager:AddTutorial(Class_Intro_CombatDummyInRange:new());
	TutorialManager:AddTutorial(Class_Intro_CombatTactics:new());
	TutorialManager:AddTutorial(Class_Intro_Chat:new());
	TutorialManager:AddTutorial(Class_QuestCompleteHelp:new());
	TutorialManager:AddTutorial(Class_UseMinimap:new());
	TutorialManager:AddTutorial(Class_Intro_OpenMap:new());
	TutorialManager:AddTutorial(Class_Intro_MapHighlights:new());
	TutorialManager:AddTutorial(Class_UseQuestItem:new());
	TutorialManager:AddTutorial(Class_ChangeEquipment:new());
	TutorialManager:AddTutorial(Class_EnhancedCombatTactics:new());
	if self.playerClass == "WARRIOR" then
		TutorialManager:AddTutorial(Class_EnhancedCombatTactics_Warrior:new());
	elseif self.playerClass == "ROGUE" then
		TutorialManager:AddTutorial(Class_EnhancedCombatTactics_Rogue:new());
	elseif self.playerClass == "PRIEST" or self.playerClass == "WARLOCK" or self.playerClass == "DRUID" then
		TutorialManager:AddTutorial(Class_EnhancedCombatTactics_UseDoTs:new());
	elseif self.playerClass == "SHAMAN" or self.playerClass == "MAGE" then
		TutorialManager:AddTutorial(Class_EnhancedCombatTactics_Ranged:new());
	elseif self.playerClass == "HUNTER" then
		TutorialManager:AddTutorial(Class_HunterStableWatcher:new());
		TutorialManager:AddTutorial(Class_AddHunterTameSpells:new());
		TutorialManager:AddTutorial(Class_HunterTame:new());
	end
	TutorialManager:AddTutorial(Class_EatFood:new());
	TutorialManager:AddTutorial(Class_UseVendor:new());
	TutorialManager:AddTutorial(Class_PromptLFG:new());
	TutorialManager:AddTutorial(Class_LookingForGroup:new());
	TutorialManager:AddTutorial(Class_LeavePartyPrompt:new());
	TutorialManager:AddTutorial(Class_MountReceived:new());
	TutorialManager:AddTutorial(Class_AddMountToActionBar:new());
	TutorialManager:AddTutorial(Class_UseMount:new());

	local specQuestID = TutorialHelper:FilterByClass(self.factionData.SpecQuests);
	TutorialManager:AddTutorial(Class_ChangeSpec_NPE:new(), nil, specQuestID);
	local autoStart = true;
	TutorialManager:AddWatcher(Class_StarterTalentWatcher_NPE:new(), autoStart);
	TutorialManager:AddTutorial(Class_TalentPoints:new(), nil, specQuestID);

	TutorialManager:AddWatcher(Class_TurnInQuestWatcher:new(), autoStart);
	local turnInQuestWatcher = TutorialManager:GetWatcher(Class_TurnInQuestWatcher.name)
	TutorialManager:AddTutorial(Class_QuestRewardChoice:new(turnInQuestWatcher));

	TutorialManager:AddWatcher(Class_Death_Watcher:new(), autoStart);
	local deathWatcher = TutorialManager:GetWatcher(Class_Death_Watcher.name);
	TutorialManager:AddTutorial(Class_Death_ReleaseCorpse:new(deathWatcher));
	TutorialManager:AddTutorial(Class_Death_MapPrompt:new(deathWatcher));
	TutorialManager:AddTutorial(Class_Death_ResurrectPrompt:new(deathWatcher));
		
	TutorialManager:AddWatcher(Class_LootCorpseWatcher:new(), autoStart);
	local lootCorpseWatcher = TutorialManager:GetWatcher(Class_LootCorpseWatcher.name);
	TutorialManager:AddTutorial(Class_LootCorpse:new(lootCorpseWatcher));
	TutorialManager:AddTutorial(Class_LootPointer:new(lootCorpseWatcher));

	-- add watchers
	TutorialManager:AddWatcher(Class_AutoPushSpellWatcher:new(), autoStart);
	TutorialManager:AddWatcher(Class_AbilityWatcher:new(), autoStart);
	TutorialManager:AddWatcher(Class_UI_Watcher:new(), autoStart);
	TutorialManager:AddWatcher(Class_GossipFrameWatcher:new(), autoStart);
	TutorialManager:AddWatcher(Class_AcceptQuestWatcher:new(), autoStart);
	TutorialManager:AddWatcher(Class_XPBarWatcher:new(), autoStart);
	if self.playerClass == "HUNTER" then
		TutorialManager:AddWatcher(Class_HunterStableWatcher:new(), autoStart);
	elseif self.playerClass == "ROGUE" or self.playerClass == "DRUID" then
		TutorialManager:AddWatcher(Class_StealthWatcher:new(), autoStart);
		if self.playerClass == "DRUID" then
			TutorialManager:AddWatcher(Class_DruidFormWatcher:new(), autoStart);
		end
	end	
	TutorialManager:AddWatcher(Class_InventoryWatcher:new(), autoStart);
	
	autoStart = false;-- started later after the Player gets food
	TutorialManager:AddWatcher(Class_LowHealthWatcher:new(), autoStart);

	-- start NPE
	TutorialManager:Queue(Class_Intro_KeyboardMouse.name);
end

function TutorialLogic:Shutdown()
	Dispatcher:UnregisterAll(self);
	TutorialQuestManager:UnregisterForCallbacks(self);

	TutorialManager:ShutdownWatcher(Class_AutoPushSpellWatcher.name);
	TutorialManager:ShutdownWatcher(Class_AbilityWatcher.name);
	TutorialManager:ShutdownWatcher(Class_UI_Watcher.name);
	TutorialManager:ShutdownWatcher(Class_GossipFrameWatcher.name);
	TutorialManager:ShutdownWatcher(Class_AcceptQuestWatcher.name);
	TutorialManager:ShutdownWatcher(Class_TurnInQuestWatcher.name);
	TutorialManager:ShutdownWatcher(Class_XPBarWatcher.name);
	TutorialManager:ShutdownWatcher(Class_HunterStableWatcher.name);
	TutorialManager:ShutdownWatcher(Class_StealthWatcher.name);
	TutorialManager:ShutdownWatcher(Class_DruidFormWatcher.name);
	TutorialManager:ShutdownWatcher(Class_InventoryWatcher.name);
	TutorialManager:ShutdownWatcher(Class_Death_Watcher.name);
	TutorialManager:ShutdownWatcher(Class_LootCorpseWatcher.name);
	TutorialManager:ShutdownWatcher(Class_LowHealthWatcher.name);

	TutorialManager:ShutdownTutorial(Class_AddSpellToActionBarService.name);
	TutorialManager:ShutdownTutorial(Class_ItemUpgradeCheckingService.name);
	TutorialManager:ShutdownTutorial(Class_Intro_KeyboardMouse.name);
	TutorialManager:ShutdownTutorial(Class_Intro_CameraLook.name);
	TutorialManager:ShutdownTutorial(Class_Intro_ApproachQuestGiver.name);
	TutorialManager:ShutdownTutorial(Class_Intro_Interact.name);
	TutorialManager:ShutdownTutorial(Class_Intro_CombatDummyInRange.name);
	TutorialManager:ShutdownTutorial(Class_Intro_CombatTactics.name);
	TutorialManager:ShutdownTutorial(Class_Intro_Chat.name);
	TutorialManager:ShutdownTutorial(Class_QuestCompleteHelp.name);
	TutorialManager:ShutdownTutorial(Class_UseMinimap.name);
	TutorialManager:ShutdownTutorial(Class_QuestRewardChoice.name);
	TutorialManager:ShutdownTutorial(Class_Intro_OpenMap.name);
	TutorialManager:ShutdownTutorial(Class_Intro_MapHighlights.name);
	TutorialManager:ShutdownTutorial(Class_UseQuestItem.name);
	TutorialManager:ShutdownTutorial(Class_ChangeEquipment.name);
	TutorialManager:ShutdownTutorial(Class_EnhancedCombatTactics.name);
	TutorialManager:ShutdownTutorial(Class_EnhancedCombatTactics_Warrior.name);
	TutorialManager:ShutdownTutorial(Class_EnhancedCombatTactics_Rogue.name);
	TutorialManager:ShutdownTutorial(Class_EnhancedCombatTactics_UseDoTs.name);
	TutorialManager:ShutdownTutorial(Class_EnhancedCombatTactics_Ranged.name);
	TutorialManager:ShutdownTutorial(Class_HunterStableWatcher.name);
	TutorialManager:ShutdownTutorial(Class_AddHunterTameSpells.name);
	TutorialManager:ShutdownTutorial(Class_HunterTame.name);
	TutorialManager:ShutdownTutorial(Class_EatFood.name);
	TutorialManager:ShutdownTutorial(Class_UseVendor.name);
	TutorialManager:ShutdownTutorial(Class_PromptLFG.name);
	TutorialManager:ShutdownTutorial(Class_LookingForGroup.name);
	TutorialManager:ShutdownTutorial(Class_LeavePartyPrompt.name);
	TutorialManager:ShutdownTutorial(Class_MountReceived.name);
	TutorialManager:ShutdownTutorial(Class_AddMountToActionBar.name);
	TutorialManager:ShutdownTutorial(Class_UseMount.name);
	TutorialManager:ShutdownTutorial(Class_ChangeSpec_NPE.name);
	TutorialManager:ShutdownTutorial(Class_TalentPoints.name);
	TutorialManager:ShutdownTutorial(Class_Death_ReleaseCorpse.name);
	TutorialManager:ShutdownTutorial(Class_Death_MapPrompt.name);
	TutorialManager:ShutdownTutorial(Class_Death_ResurrectPrompt.name);
	TutorialManager:ShutdownTutorial(Class_LootCorpse.name);
	TutorialManager:ShutdownTutorial(Class_LootPointer.name);

	TutorialQueue:Status();
end

function TutorialLogic:Quest_Accepted(questData)
	local questID = questData.QuestID;

	local tutorialKey, args;
	if (questID == self.factionData.StartingQuest) then
		tutorialKey = Class_Intro_CombatDummyInRange.name;
	elseif (questID == self.factionData.UseMapQuest) then
		tutorialKey = Class_Intro_OpenMap.name;
	elseif (questID == self.factionData.ShowMinimapQuest) then		
		local lootCorpseWatcher = TutorialManager:GetWatcher(Class_LootCorpseWatcher.name);
		if lootCorpseWatcher then
			lootCorpseWatcher:WatchQuestMob(self.factionData.FirstLootableCreatureID);
		end
		tutorialKey = Class_UseMinimap.name;
	elseif (questID == self.factionData.EnhancedCombatTacticsQuest) then		
		tutorialKey = Class_EnhancedCombatTactics.name;
	elseif (questID == self.factionData.UseQuestItemData.ItemQuest) then
		tutorialKey = Class_UseQuestItem.name;
		args = self.factionData.UseQuestItemData;
	elseif (questID == self.factionData.RemindUseQuestItemData.ItemQuest) then
		tutorialKey = Class_UseQuestItem.name;
		args = self.factionData.RemindUseQuestItemData;	
	elseif (questID == self.vendorQuestID) then
		tutorialKey = Class_UseVendor.name;
	elseif (questID == self.factionData.LookingForGroupQuest) then
		tutorialKey = Class_PromptLFG.name;
	elseif (questID == self.factionData.LeavePartyPromptQuest) then
		tutorialKey = Class_LeavePartyPrompt.name;
	elseif (questID == self.factionData.AnUrgentMeeting) then -- second use mount reminder
		local mountData = TutorialHelper:FilterByRace(TutorialData:GetFactionData().Mounts);
		if TutorialHelper:GetActionButtonBySpellID(mountData.mountID) then
			tutorialKey = Class_UseMount.name;
		end
	elseif (questID == self.factionData.HunterTameTutorialQuestID) then
		tutorialKey = Class_AddHunterTameSpells.name;
	elseif (questID == self.specQuestID) then
		tutorialKey = Class_ChangeSpec_NPE.name;
	end
	if tutorialKey then
		TutorialManager:Queue(tutorialKey, args)
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Called from Blizzard_TutorialQuestManager when a quest is ready to be completed.
function TutorialLogic:Quest_ObjectivesComplete(questData)
	local questID = questData.QuestID;
	local tutorials = self.Tutorials;
end

function TutorialLogic:Quest_Updated(questData)
end

function TutorialLogic:Quest_TurnedIn(questData)
	local questID = questData.QuestID;
	if questID and C_QuestLog.IsQuestFlaggedCompleted(questID) then
		
		if questID == self.factionData.GetMountQuest then
			TutorialManager:Queue(Class_MountReceived.name);
			return;
		end

		if (questID == self.factionData.LeavePartyPromptQuest) then
			TutorialManager:Queue(Class_LeavePartyPrompt.name);
			return;
		end

		if (questID == self.factionData.StandYourGround) then
			TutorialManager:Queue(Class_Intro_Chat.name);
			return;
		end

		local classQuestID = TutorialHelper:FilterByClass(self.factionData.ClassQuests);
		if questID == classQuestID then
			local classData = TutorialHelper:FilterByClass(TutorialData.ClassData);
			local spellID = classData.classQuestSpellID;
			if spellID then
				local preferredActionBar = TutorialHelper:GetClass() == "ROGUE" and "MultiBarBottomLeftButton" or nil;
				TutorialManager:Queue(Class_AddSpellToActionBarService.name, spellID, nil, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar);
			end
			return;
		end

	end
end
