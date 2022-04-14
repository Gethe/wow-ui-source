local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;

TutorialLogic = {};
TutorialLogic.Tutorials = {};

function TutorialLogic:PLAYER_LEVEL_CHANGED(originalLevel, newLevel)
	if newLevel > 10 then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	else
		local tutorials = self.Tutorials;
		local LevelUpTutorial_spellIDlookUp = TutorialHelper:FilterByClass(TutorialData.LevelAbilitiesTable);
		local warningString = nil;
		local preferredActionBar = nil;
		for i = originalLevel + 1, newLevel do
			local spellID = LevelUpTutorial_spellIDlookUp[i];
			if spellID then
				TutorialQueue:Add(tutorials.AddSpellToActionBarService, spellID, warningString, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar);
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
	local tutorials = self.Tutorials;

	if form == BEAR_FORM then
		formSpells = TutorialData.DruidAnimalFormSpells.bearSpells;
	elseif form == CAT_FORM then
		formSpells = TutorialData.DruidAnimalFormSpells.catSpells;
	elseif form == ROGUE_STEALTH then
		formSpells = TutorialData.RogueStealthSpells;
	end
	if formSpells then
		local warningString = nil;
		local preferredActionBar = nil;
		for i, spellID in ipairs(formSpells) do
			if IsSpellKnown(spellID) then
				TutorialQueue:Add(tutorials.AddSpellToActionBarService, spellID, warningString, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar, form);
			end
		end
	end
end

function TutorialLogic:UPDATE_SHAPESHIFT_FORM()
	local level = UnitLevel("player");
	if level > 10 then
		Dispatcher:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", self);
		return;
	end
	
	C_Timer.After(0.25, function()
		self:CheckFormSpells();
	end);
end

function TutorialLogic:Begin()
	Class_TutorialBase:GlobalEnable()

	self.playerClass = TutorialHelper:GetClass();-- player's class
	self.factionData = TutorialHelper:GetFactionData();-- get the data for the player's faction
	self.vendorQuestID = self.factionData.UseVendorQuest;
	self.specQuestID = TutorialHelper:FilterByClass(self.factionData.SpecQuests);

	-- Certain tutorials kick off when quests are accepted
	NPE_QuestManager:RegisterForCallbacks(self);

	-- many tutorials can occur at the same time, the queue system helps manage it so you get one at a time
	TutorialQueue:Initialize();

	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);

	if self.playerClass == "ROGUE" or self.playerClass == "DRUID" then
		Dispatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	end

	local tutorials = self.Tutorials;
	for k, v in pairs(tutorials) do
		if (type(v) == "table") then
			if(v.Begin)then
				v:Begin();
			end
		end
	end
	-- these tutorials have to be created outside the loop because we dont want to call Begin on them
	tutorials.LootCorpse = Class_LootCorpse:new(tutorials.LootCorpseWatcher);
	tutorials.LootPointer = Class_LootPointer:new(tutorials.LootCorpseWatcher);

	-- first tutorial to start us off
	TutorialQueue:Add(tutorials.Intro_KeyboardMouse);
	tutorials.InventoryWatcher:StartWatching();
end

function TutorialLogic:Shutdown()
	Dispatcher:UnregisterAll(self);
	NPE_QuestManager:UnregisterForCallbacks(self);
	Class_TutorialBase:GlobalDisable();
end

function TutorialLogic:Quest_Accepted(questData)
	local questID = questData.QuestID;
	local tutorials = self.Tutorials;

	if (questID == self.factionData.StartingQuest) then
		TutorialQueue:Add(tutorials.Intro_CombatDummyInRange);
	elseif (questID == self.factionData.UseMapQuest) then
		TutorialQueue:Add(tutorials.Intro_OpenMap);
	elseif (questID == self.factionData.ShowMinimapQuest) then
		tutorials.LootCorpseWatcher:WatchQuestMob(self.factionData.FirstLootableCreatureID);
		TutorialQueue:Add(tutorials.UseMinimap);
	elseif (questID == self.factionData.EnhancedCombatTacticsQuest) then
		TutorialQueue:Add(tutorials.EnhancedCombatTactics);
	elseif (questID == self.factionData.UseQuestItemData.ItemQuest) then
		TutorialQueue:Add(tutorials.UseQuestItem, self.factionData.UseQuestItemData);
	elseif (questID == self.factionData.RemindUseQuestItemData.ItemQuest) then
		TutorialQueue:Add(tutorials.UseQuestItem, self.factionData.RemindUseQuestItemData);
	elseif (questID == self.vendorQuestID) then
		TutorialQueue:Add(tutorials.UseVendor);
	elseif (questID == self.factionData.LookingForGroupQuest) then
		TutorialQueue:Add(tutorials.PromptLFG);
	elseif (questID == self.factionData.LeavePartyPromptQuest) then
		TutorialQueue:Add(tutorials.LeavePartyPrompt);
	elseif (questID == self.factionData.AnUrgentMeeting) then -- second use mount reminder
		local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
		if TutorialHelper:GetActionButtonBySpellID(mountData.mountID) then
			TutorialQueue:Add(tutorials.UseMount);
		end
	elseif (questID == self.factionData.HunterTameTutorialQuestID) then
		TutorialQueue:Add(tutorials.AddHunterTameSpells);
	elseif (questID == self.specQuestID) then
		TutorialQueue:Add(tutorials.ChangeSpec);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Called from Blizzard_TutorialQuestManager when a quest is ready to be completed.
function TutorialLogic:Quest_ObjectivesComplete(questData)
	local questID = questData.QuestID;
	local tutorials = self.Tutorials;
	
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local questID = C_QuestLog.GetQuestIDForLogIndex(i);
		if questID and C_QuestLog.ReadyForTurnIn(questID) then
			if questID == self.factionData.UseQuestItemData.ItemQuest then
				TutorialQueue:NotifyDone(tutorials.UseQuestItem);
			elseif questID == self.factionData.RemindUseQuestItemData.ItemQuest then
				TutorialQueue:NotifyDone(tutorials.UseQuestItem);
			elseif questID == self.factionData.UseFoodQuest then
				tutorials.LowHealthWatcher:Complete();
			end
		end
	end
end

function TutorialLogic:Quest_Updated(questData)
end

function TutorialLogic:Quest_TurnedIn(questData)
	local questID = questData.QuestID;
	local tutorials = self.Tutorials;

	if questID and C_QuestLog.IsQuestFlaggedCompleted(questID) then
		if questID == self.factionData.EnhancedCombatTacticsQuest then
			local playerClass = TutorialHelper:GetClass();
			if playerClass == "WARRIOR" then
				tutorials.EnhancedCombatTactics_Warrior:Complete();
			elseif playerClass == "ROGUE" then
				tutorials.EnhancedCombatTactics_Rogue:Complete();
			elseif playerClass == "PRIEST" or playerClass == "WARLOCK" or playerClass == "DRUID" then
				tutorials.EnhancedCombatTactics_UseDoTs:Complete();
			elseif playerClass == "SHAMAN" or playerClass == "MAGE" then
				tutorials.EnhancedCombatTactics_Ranged:Complete();
			else
				tutorials.EnhancedCombatTactics:Complete();
			end
			return;
		end

		if questID == self.factionData.GetMountQuest then
			TutorialQueue:Add(tutorials.MountReceived);
			return;
		end

		if (questID == self.factionData.LeavePartyPromptQuest) then
			TutorialQueue:Add(tutorials.LeavePartyPrompt);
			return;
		end

		if (questID == self.factionData.StandYourGround) then
			TutorialQueue:Add(tutorials.Intro_Chat);
			return;
		end

		local classQuestID = TutorialHelper:FilterByClass(self.factionData.ClassQuests);
		if questID == classQuestID then
			local classData = TutorialHelper:FilterByClass(TutorialData.ClassData);
			local spellID = classData.classQuestSpellID;
			if spellID then
				local preferredActionBar = TutorialHelper:GetClass() == "ROGUE" and "MultiBarBottomLeftButton" or nil;
				TutorialQueue:Add(tutorials.AddSpellToActionBarService, spellID, nil, NPEV2_SPELLBOOK_TUTORIAL, preferredActionBar);
			end
			return;
		end
	end
end

--watchers
local Tutorials = TutorialLogic.Tutorials;
Tutorials.AutoPushSpellWatcher			= Class_AutoPushSpellWatcher:new();
Tutorials.AbilityWatcher				= Class_AbilityWatcher:new();
Tutorials.UI_Watcher					= Class_UI_Watcher:new()
Tutorials.GossipFrameWatcher			= Class_GossipFrameWatcher:new();
Tutorials.LowHealthWatcher				= Class_LowHealthWatcher:new();
Tutorials.AcceptQuestWatcher			= Class_AcceptQuestWatcher:new();
Tutorials.TurnInQuestWatcher			= Class_TurnInQuestWatcher:new();
Tutorials.Class_XPBarWatcher			= Class_XPBarWatcher:new();
Tutorials.HunterStableWatcher 			= Class_HunterStableWatcher:new();
Tutorials.InventoryWatcher				= Class_InventoryWatcher:new();
Tutorials.StealthWatcher 				= Class_StealthWatcher:new();
Tutorials.DruidFormWatcher 				= Class_DruidFormWatcher:new();

-- services
Tutorials.AddSpellToActionBarService	= Class_AddSpellToActionBarService:new();
Tutorials.ItemUpgradeCheckingService	= Class_ItemUpgradeCheckingService:new();

-- tutorials
Tutorials.Intro_KeyboardMouse			= Class_Intro_KeyboardMouse:new()
Tutorials.Intro_CameraLook				= Class_Intro_CameraLook:new();
Tutorials.Intro_ApproachQuestGiver		= Class_Intro_ApproachQuestGiver:new();
Tutorials.Intro_Interact				= Class_Intro_Interact:new();
Tutorials.Intro_CombatDummyInRange		= Class_Intro_CombatDummyInRange:new();
Tutorials.Intro_CombatTactics 			= Class_Intro_CombatTactics:new();
Tutorials.Intro_Chat					= Class_Intro_Chat:new();
Tutorials.QuestCompleteHelp				= Class_QuestCompleteHelp:new();
Tutorials.UseMinimap					= Class_UseMinimap:new();
Tutorials.QuestRewardChoice				= Class_QuestRewardChoice:new(Tutorials.TurnInQuestWatcher);
Tutorials.Intro_OpenMap					= Class_Intro_OpenMap:new();
Tutorials.Intro_MapHighlights			= Class_Intro_MapHighlights:new();
Tutorials.UseQuestItem					= Class_UseQuestItem:new()
Tutorials.ChangeEquipment				= Class_ChangeEquipment:new();
Tutorials.EnhancedCombatTactics			= Class_EnhancedCombatTactics:new();
Tutorials.EnhancedCombatTactics_Warrior	= Class_EnhancedCombatTactics_Warrior:new();
Tutorials.EnhancedCombatTactics_Rogue	= Class_EnhancedCombatTactics_Rogue:new();
Tutorials.EnhancedCombatTactics_UseDoTs	= Class_EnhancedCombatTactics_UseDoTs:new();
Tutorials.EnhancedCombatTactics_Ranged	= Class_EnhancedCombatTactics_Ranged:new();
Tutorials.AddHunterTameSpells			= Class_AddHunterTameSpells:new();
Tutorials.HunterTame 					= Class_HunterTame:new();
Tutorials.EatFood						= Class_EatFood:new();
Tutorials.UseVendor						= Class_UseVendor:new();
Tutorials.PromptLFG						= Class_PromptLFG:new();
Tutorials.LookingForGroup				= Class_LookingForGroup:new()
Tutorials.LeavePartyPrompt				= Class_LeavePartyPrompt:new()
Tutorials.MountReceived					= Class_MountReceived:new();
Tutorials.AddMountToActionBar			= Class_AddMountToActionBar:new();
Tutorials.UseMount						= Class_UseMount:new();
Tutorials.ChangeSpec					= Class_ChangeSpec:new()

-- these tutorials have a lot of edge cases and are aren't queued
Tutorials.Death_Watcher					= Class_Death_Watcher:new();
Tutorials.Death_ReleaseCorpse			= Class_Death_ReleaseCorpse:new(Tutorials.Death_Watcher);
Tutorials.Death_MapPrompt				= Class_Death_MapPrompt:new(Tutorials.Death_Watcher);
Tutorials.Death_ResurrectPrompt			= Class_Death_ResurrectPrompt:new(Tutorials.Death_Watcher);
Tutorials.LootCorpseWatcher				= Class_LootCorpseWatcher:new();

-- ============================================================================================================
-- DEBUG
-- ============================================================================================================
function DebugTutorials(value)
	Class_TutorialBase:Debug(value);
end

function TutorialStatus()
	print("--------------START--------------")
	for k, v in pairs(TutorialLogic.Tutorials) do
		if (type(v) == "table") then
			print(v.IsActive and "+ ACTIVE" or "- INACTIVE", k);
		end
	end
	print("---------------END---------------")
end

DebugTutorials(false);