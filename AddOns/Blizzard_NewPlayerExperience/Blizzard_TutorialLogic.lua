Tutorials = {};
function Tutorials:Begin()
	Class_TutorialBase:GlobalEnable()

	local tutorialData = TutorialHelper:GetFactionData();

	-- Certain tutorials kick off when quests are accepted
	NPE_QuestManager:RegisterForCallbacks(self);

	-- Hide various UI elements until they are turned on
	self.Hide_Backpack:Begin();
	--self.Hide_MainMenuBar:Begin();
	self.Hide_TargetFrame:Begin();
	--self.Hide_StatusTrackingBar:Begin();
	self.Hide_Minimap:Begin();

	local level = UnitLevel("player");
	if (level < 2) then
		self.XPBarTutorial:Begin();
		self.Hide_BagsBar:Begin();
		self.Hide_SpellbookMicroButton:Begin();
	end
	self.Hide_CharacterMicroButton:Begin();
	self.Hide_OtherMicroButtons:Begin();
	self.Hide_StoreMicroButton:Begin();

	-- Looting
	self.LootCorpseWatcher:Begin()
	if (level > 2) then
		-- if the player is returning after level 2, then start this tutorial off
		-- in the state where they are only reminded if they don't loot a corpse
		self.LootCorpseWatcher.LootCount = 3;
	end

	if (level < 7) then
		self.Vendor_Watcher:Begin();
	end

	-- Player Death
	self.Death_Watcher:Begin()

	self.AcceptQuestWatcher:Begin();
	self.TurnInQuestWatcher:Begin();
	self.LevelUpTutorial:Begin();

	-- Starting Quest
	local questID = tutorialData.StartingQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(questID) then	-- Starting Quest is complete
		self.Hide_MainMenuBar:Complete();			-- Show the Nain Menu bar
		self.Hide_TargetFrame:Complete();			-- Show the Target Frame
		self.Hide_StatusTrackingBar:Complete();	-- and show the status tracker
	elseif C_QuestLog.ReadyForTurnIn(questID) then	-- Starting Quest is ready to turn in
		self.Hide_MainMenuBar:Complete();		-- Show the Main Menu bar
		self.Intro_CombatTactics:Complete();	-- Intro Combat Tactics is complete
		C_Timer.After(2, function() self.QuestCompleteHelp:Begin(); end); -- after 2 seconds, prompt the turn in tutorial
	elseif C_QuestLog.GetLogIndexForQuestID(questID) ~= nil then -- Starting Quest is active
		self.Intro_CombatDummyInRange:Begin();
	else
		self.Intro_CameraLook:Begin(); -- otherwise just start at the beginning
	end

	-- LFG Quest
	if (C_QuestLog.GetLogIndexForQuestID(tutorialData.LookingForGroupQuest)) then
		-- Looking For Group Quest is Active
		self.LookingForGroup:Begin();
	end

	-- Show Minimap Quest
	questID = tutorialData.ShowMinimapQuest;
	if TutorialHelper:IsQuestCompleteOrActive(questID) then	-- Show Minimap Quest is complete (or active)
		self.Hide_Minimap:Complete();					-- so show the minimap
	end

	-- Use Quest Item Quest
	local useQuestItemData = tutorialData.UseQuestItemData;
	if C_QuestLog.GetLogIndexForQuestID(useQuestItemData.ItemQuest) ~= nil then
		self.UseQuestItemTutorial:Begin(useQuestItemData);
	end

	-- Remind Use Quest Item Quest
	local remindUseQuestItemData = tutorialData.RemindUseQuestItemData;
	if C_QuestLog.GetLogIndexForQuestID(remindUseQuestItemData.ItemQuest) ~= nil then
		self.UseQuestItemTutorial:Begin(remindUseQuestItemData);
	end

	-- Use Map Quest
	questID = tutorialData.UseMapQuest;
	if C_QuestLog.GetLogIndexForQuestID(questID) ~= nil then -- Use Map Quest is still active
		self.Intro_OpenMap:Begin();
	end

	-- if we are past a certain point, turn on of all the UI
	if C_QuestLog.IsQuestFlaggedCompleted(tutorialData.ShowAllUIQuest) then
		self.Hide_Backpack:Complete();
		self.Hide_BagsBar:Complete();
		self.Hide_OtherMicroButtons:Complete();
		self.Hide_StoreMicroButton:Complete();
		self.Hide_SpellbookMicroButton:Complete();
		self.Hide_CharacterMicroButton:Complete();
	end

	-- Looting
	if (level < 5) then -- if the player comes back after level 4, don't prompt them on loot anymore		
		self.LootPointer:Begin();-- Begins watcher for player looting an item for the first time.
		self.EquipFirstItemWatcher:Begin();
	end

	if C_QuestLog.IsQuestFlaggedCompleted(tutorialData.UseFoodQuest) then
		self.LowHealthWatcher:Begin();
	end

	if C_QuestLog.GetLogIndexForQuestID(tutorialData.EnhancedCombatTacticsQuest) ~= nil then -- Enhanced combat Tactics Quest is still active
		self.EnhancedCombatTactics:Begin();
	elseif C_QuestLog.IsQuestFlaggedCompleted(tutorialData.EnhancedCombatTacticsQuest) then
		self.LowHealthWatcher:Begin();
	end

	-- Mount Quest
	questID = tutorialData.GetMountQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(questID) then	-- Mount Quest is complete
		-- did the mount get collected?
		local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
		local name, _, _, _, _, _, _, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountData.mountID);
		if not isCollected then
			-- the mount was not collected, start the tutorial
			self.MountAddedWatcher:Begin();
		end
	end

	-- Spec Choice Quest
	local questID = tutorialData.SpecChoiceQuest;
	if C_QuestLog.GetLogIndexForQuestID(questID) ~= nil then -- Spec Choice Quest is active
		self.SpecTutorial:Begin();
	end
end

function Tutorials:Shutdown()
	Dispatcher:UnregisterAll(self);
	NPE_QuestManager:UnregisterForCallbacks(self);
	Class_TutorialBase:GlobalDisable();
end

function Tutorials:Quest_Accepted(questData)
	local questID = questData.QuestID;
	local tutorialData = TutorialHelper:GetFactionData();

	if (questID == tutorialData.StartingQuest) then
		-- Starting Quest
		self.Intro_CombatDummyInRange:Begin();
	elseif (questID == tutorialData.UseMapQuest) then
		-- Use Map Quest
		self.Intro_OpenMap:Begin();
	elseif (questID == tutorialData.ShowMinimapQuest) then
		-- Show Minimap Quest
		self.Hide_Minimap:ShowTutorial();
	elseif (questID == tutorialData.EnhancedCombatTacticsQuest) then
		-- Enhanced Combat Tactics Quest
		self.EnhancedCombatTactics:Begin();
	elseif (questID == tutorialData.UseQuestItemData.ItemQuest) then
		-- Use Quest Item Quest
		self.LootCorpseWatcher:WatchQuestMob(tutorialData.FirstLootableCreatureID);	
		self.UseQuestItemTutorial:Begin(tutorialData.UseQuestItemData);
	elseif (questID == tutorialData.RemindUseQuestItemData.ItemQuest) then
		-- Remind Use Quest Item Quest
		self.UseQuestItemTutorial:Begin(tutorialData.RemindUseQuestItemData);
	elseif (questID == tutorialData.LookingForGroupQuest) then
		-- Looking For Group Quest
		self.LookingForGroup:Begin();
	elseif (questID == tutorialData.SpecChoiceQuest) then
		-- Spec Choice Quest
		self.SpecTutorial:Begin();
	elseif (questID == tutorialData.ShowAllUIQuest) then
		-- Show All UI Quest
		self.Hide_Backpack:Complete();
		self.Hide_BagsBar:Complete();
		self.Hide_OtherMicroButtons:Complete();
		self.Hide_StoreMicroButton:Complete();
		self.Hide_SpellbookMicroButton:Complete();
		self.Hide_CharacterMicroButton:Complete();
	end
end

-- ------------------------------------------------------------------------------------------------------------
--Called from Blizzard_TutorialQuestManager when a quest is ready to be completed.
function Tutorials:Quest_ObjectivesComplete(questData)
	local questID = questData.QuestID;
	local tutorialData = TutorialHelper:GetFactionData();

	-- -----------------------------------------------
	-- All active quests complete
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local questID = C_QuestLog.GetQuestIDForLogIndex(i);

		-- Only check valid non-account quests.
		if questID and not C_QuestLog.IsAccountQuest(questID) and C_QuestLog.ReadyForTurnIn(questID) then
			if questID == tutorialData.StartingQuest then
				self.Intro_CombatTactics:Complete();
				self.QuestCompleteHelp:Begin();
			elseif questID == tutorialData.UseQuestItemData.ItemQuest then
				self.UseQuestItemTutorial:Complete();
			elseif questID == tutorialData.RemindUseQuestItemData.ItemQuest then
				self.UseQuestItemTutorial:Complete();
			elseif questID == tutorialData.EnhancedCombatTacticsQuest then
				self.playerClass = TutorialHelper:GetClass();
				if self.playerClass == "WARRIOR" then
					self.EnhancedCombatTactics_Warrior:Complete();
				elseif self.playerClass == "MONK" then
					--we need a special case for monk once class design has fixed some things
					print("HERE IS WHERE WOULD COMPLETE MONK TRAINING.");
				elseif self.playerClass == "PRIEST" or self.playerClass == "WARLOCK" or self.playerClass == "DRUID" then
					self.EnhancedCombatTactics_UseDoTs:Complete();
				elseif playerClass == "SHAMAN" or playerClass == "MAGE" then
					self.EnhancedCombatTactics_Ranged:Complete();
				else -- ROGUE, PALADIN
					self.EnhancedCombatTactics:Complete();
				end
			elseif questID == tutorialData.UseFoodQuest then
				self.LowHealthWatcher:Begin();
			end
		end
	end
end

function Tutorials:Quest_TurnedIn(questData)
	local questID = questData.QuestID;
	local tutorialData = TutorialHelper:GetFactionData();

	if questID and not C_QuestLog.IsAccountQuest(questID) and C_QuestLog.IsQuestFlaggedCompleted(questID) then
		if questID == tutorialData.GetMountQuest then
			self.MountAddedWatcher:Begin();
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Generic Creature Range Watcher
Tutorials.CreatureRangeWatcher			= Class_CreatureRangeWatcher:new()

-- ------------------------------------------------------------------------------------------------------------
-- HIDE UI - These tutorials hide UI elements until they are Complete
Tutorials.Hide_Backpack					= Class_Hide_Backpack:new()
Tutorials.Hide_MainMenuBar				= Class_Hide_MainMenuBar:new();
Tutorials.Hide_BagsBar					= Class_Hide_BagsBar:new();
Tutorials.Hide_OtherMicroButtons		= Class_Hide_OtherMicroButtons:new();
Tutorials.Hide_StoreMicroButton			= Class_Hide_StoreMicroButton:new();
Tutorials.Hide_SpellbookMicroButton		= Class_Hide_SpellbookMicroButton:new();
Tutorials.Hide_CharacterMicroButton		= Class_Hide_CharacterMicroButton:new();
Tutorials.Hide_TargetFrame				= Class_Hide_TargetFrame:new();
Tutorials.Hide_StatusTrackingBar		= Class_Hide_StatusTrackingBar:new();
Tutorials.Hide_Minimap					= Class_Hide_Minimap:new();

-- ------------------------------------------------------------------------------------------------------------
-- Intro to Controls
Tutorials.Intro_CameraLook				= Class_Intro_CameraLook:new();
Tutorials.Intro_KeyboardMouse			= Class_Intro_KeyboardMouse:new()
Tutorials.Intro_Interact				= Class_Intro_Interact:new();

-- ------------------------------------------------------------------------------------------------------------
-- Intro to Combat
Tutorials.Intro_CombatDummyInRange		= Class_Intro_CombatDummyInRange:new();
Tutorials.Intro_CombatTactics 			= Class_Intro_CombatTactics:new();

-- ------------------------------------------------------------------------------------------------------------
-- Intro to Quest Mechanics
Tutorials.AcceptQuestWatcher			= Class_AcceptQuestWatcher:new();
Tutorials.AcceptQuest					= Class_AcceptQuest:new(Tutorials.AcceptQuestWatcher);
Tutorials.TurnInQuestWatcher			= Class_TurnInQuestWatcher:new();
Tutorials.TurnInQuest					= Class_TurnInQuest:new(Tutorials.TurnInQuestWatcher);
Tutorials.QuestRewardChoice				= Class_QuestRewardChoice:new(Tutorials.TurnInQuestWatcher);
Tutorials.QuestCompleteHelp				= Class_QuestCompleteHelp:new();

-- ------------------------------------------------------------------------------------------------------------
-- Intro to XP and Level Up
Tutorials.XPBarTutorial					= Class_XPBarTutorial:new()
Tutorials.LevelUpTutorial				= Class_LevelUpTutorial:new()
Tutorials.AddSpellToActionBar			= Class_AddSpellToActionBar:new();

-- ------------------------------------------------------------------------------------------------------------
-- Intro to Map
Tutorials.Intro_OpenMap					= Class_Intro_OpenMap:new();
Tutorials.Intro_MapHighlights			= Class_Intro_MapHighlights:new();

-- ------------------------------------------------------------------------------------------------------------
-- Generic Use Quest Item Tutorial
Tutorials.UseQuestItemTutorial			= Class_UseQuestItemTutorial:new()

-- ------------------------------------------------------------------------------------------------------------
-- Looting
Tutorials.LootCorpseWatcher				= Class_LootCorpseWatcher:new();
Tutorials.LootCorpse					= Class_LootCorpse:new(Tutorials.LootCorpseWatcher);
Tutorials.LootPointer					= Class_LootPointer:new(Tutorials.LootCorpseWatcher);

-- ------------------------------------------------------------------------------------------------------------
-- Equip Item Tutorials
Tutorials.EquipFirstItemWatcher			= Class_EquipFirstItemWatcher:new();
Tutorials.ShowBags						= Class_ShowBags:new(Tutorials.EquipFirstItemWatcher);
Tutorials.EquipItem						= Class_EquipItem:new(Tutorials.EquipFirstItemWatcher);
Tutorials.OpenCharacterSheet			= Class_OpenCharacterSheet:new(Tutorials.EquipFirstItemWatcher);
Tutorials.HighlightEquippedItem 		= Class_HighlightEquippedItem:new(Tutorials.EquipFirstItemWatcher);
Tutorials.CloseCharacterSheet 			= Class_CloseCharacterSheet:new(Tutorials.EquipFirstItemWatcher);

-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics
Tutorials.EnhancedCombatTactics			= Class_EnhancedCombatTactics:new();
Tutorials.EnhancedCombatTactics_Warrior	= Class_EnhancedCombatTactics_Warrior:new();
Tutorials.EnhancedCombatTactics_UseDoTs	= Class_EnhancedCombatTactics_UseDoTs:new();
Tutorials.EnhancedCombatTactics_Ranged	= Class_EnhancedCombatTactics_Ranged:new();

-- ------------------------------------------------------------------------------------------------------------
-- Food
Tutorials.LowHealthWatcher				= Class_LowHealthWatcher:new();
Tutorials.EatFood						= Class_EatFood:new();

-- ------------------------------------------------------------------------------------------------------------
-- Vendor Watcher
Tutorials.Vendor_Watcher				= Class_Vendor_Watcher:new();

-- ------------------------------------------------------------------------------------------------------------
-- Looking For Group
Tutorials.LookingForGroup				= Class_LookingForGroup:new()

-- ------------------------------------------------------------------------------------------------------------
-- Death
Tutorials.Death_Watcher					= Class_Death_Watcher:new();
Tutorials.Death_ReleaseCorpse			= Class_Death_ReleaseCorpse:new(Tutorials.Death_Watcher);
Tutorials.Death_MapPrompt				= Class_Death_MapPrompt:new(Tutorials.Death_Watcher);
Tutorials.Death_ResurrectPrompt			= Class_Death_ResurrectPrompt:new(Tutorials.Death_Watcher);

-- ------------------------------------------------------------------------------------------------------------
-- Mount Tutorial
Tutorials.MountAddedWatcher				= Class_MountAddedWatcher:new();
Tutorials.MountTutorial					= Class_MountTutorial:new();

-- ------------------------------------------------------------------------------------------------------------
-- Spec Choice Tutorial
Tutorials.SpecTutorial					= Class_SpecTutorial:new()

-- ------------------------------------------------------------------------------------------------------------
-- Misc
Tutorials.HighlightItem					= Class_HighlightItem:new();
Tutorials.ChatFrame						= Class_ChatFrame:new();
Tutorials.StealthTutorial 				= Class_StealthTutorial:new()


-- ============================================================================================================
-- DEBUG
-- ============================================================================================================
function DebugTutorials(value)
	Class_TutorialBase:Debug(value);
end

function TutorialStatus()
	print("---------------------------------------")
	for k, v in pairs(Tutorials) do
		if (type(v) == "table") then
			print(v.IsActive and "+ ACTIVE" or "- INACTIVE", k);
		end
	end
end

DebugTutorials(true);
