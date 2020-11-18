Tutorials = {};
function Tutorials:Begin()
	Class_TutorialBase:GlobalEnable()

	local tutorialData = TutorialHelper:GetFactionData();

	-- Certain tutorials kick off when quests are accepted
	NPE_QuestManager:RegisterForCallbacks(self);

	self.QueueSystem:Begin();
	self.AutoPushSpellWatcher:Begin();
	self.SpellChecker:Begin();

	-- Hide various UI elements until they are turned on
	self.Hide_Backpack:Begin();
	self.Hide_TargetFrame:Begin();
	self.Hide_Minimap:Begin();

	self.GossipFrameWatcher:Begin();

	local level = UnitLevel("player");
	if (level < 2) then
		self.XPBarTutorial:Begin();
		self.Hide_BagsBar:Begin();
		self.Hide_SpellbookMicroButton:Begin();
	end
	self.Hide_CharacterMicroButton:Begin();
	self.Hide_OtherMicroButtons:Begin();
	self.Hide_StoreMicroButton:Begin();
		
	local playerClass = TutorialHelper:GetClass();
	if level < 3 and playerClass == "ROGUE" then
		self.StealthTutorial:Begin();
	end
	if level < 8 and  playerClass == "DRUID" then
		self.DruidFormTutorial:Begin();
	end
	if playerClass == "HUNTER" then
		local hunterTameQuestID = tutorialData.HunterTameTutorialQuestID;
		if C_QuestLog.IsQuestFlaggedCompleted(hunterTameQuestID) or C_QuestLog.ReadyForTurnIn(hunterTameQuestID) then
			-- we have already passed the hunter tame pet tutorial
		elseif C_QuestLog.GetLogIndexForQuestID(hunterTameQuestID) ~= nil then
			self.HunterTameTutorial:ForceBegin();
		end

		if level < 9 then
			self.HunterStableTutorial:Begin();
		end
	end
	
	-- Looting
	if (level <= 5) then
		if (level > 2) then
			-- if the player is returning after level 2, then start this tutorial off
			-- in the state where they are only reminded if they don't loot a corpse
			self.LootCorpseWatcher.LootCount = 3;
		end
		self.LootCorpseWatcher:Begin()
	end

	local vendorQuestID = tutorialData.UseVendorQuest;
	if not TutorialHelper:IsQuestCompleteOrActive(vendorQuestID) then
		self.Vendor_Watcher:Begin();
	end

	-- Player Death
	self.Death_Watcher:Begin()

	self.AcceptQuestWatcher:Begin();
	self.TurnInQuestWatcher:Begin();

	-- Starting Quest
	local questID = tutorialData.StartingQuest;
	if C_QuestLog.IsQuestFlaggedCompleted(questID) then	-- Starting Quest is complete
		self.Hide_MainMenuBar:Complete();			-- Show the Main Menu bar
		self.Hide_TargetFrame:Complete();			-- Show the Target Frame
		self.Hide_StatusTrackingBar:Complete();	-- and show the status tracker
	elseif C_QuestLog.ReadyForTurnIn(questID) then	-- Starting Quest is ready to turn in
		self.Hide_MainMenuBar:Complete();		-- Show the Main Menu bar
		self.Intro_CombatTactics:Complete();	-- Intro Combat Tactics is complete
		C_Timer.After(2, function() self.QuestCompleteHelp:Begin(); end); -- after 2 seconds, prompt the turn in tutorial
	elseif C_QuestLog.GetLogIndexForQuestID(questID) ~= nil then -- Starting Quest is active
		self.Intro_CombatDummyInRange:Begin();
	else
		self.Intro_KeyboardMouse:Begin(); -- otherwise just start at the beginning
	end

	-- LFG Quest
	local questID = tutorialData.LookingForGroupQuest;
	if C_QuestLog.GetLogIndexForQuestID(questID) and not C_QuestLog.ReadyForTurnIn(questID) then
		-- Looking For Group Quest is Active
		Tutorials.QueueSystem:QueueLFDTutorial();
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
		if not C_QuestLog.IsQuestFlaggedCompleted(questID) then
			self.Intro_OpenMap:Begin();
		end
	end

	questID = tutorialData.AnUrgentMeeting;
	if C_QuestLog.GetLogIndexForQuestID(questID) ~= nil then
		local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
		if TutorialHelper:GetActionButtonBySpellID(mountData.mountID) then
			self.UseMountWatcher:Begin();
		end
	end

	local standYourGround = C_QuestLog.IsQuestFlaggedCompleted(tutorialData.StandYourGround);
	local braceForImpact = C_QuestLog.IsQuestFlaggedCompleted(tutorialData.BraceForImpact);
	if standYourGround and not braceForImpact then
		self.ChatFrame:Begin(editBox)
	end

	-- if we are past a certain point, turn on of all the UI
	if C_QuestLog.IsQuestFlaggedCompleted(tutorialData.ShowAllUIQuest) then
		self.Hide_Backpack:Complete();
		self.Hide_MainMenuBar:Complete();
		self.Hide_BagsBar:Complete();
		self.Hide_OtherMicroButtons:Complete();
		self.Hide_StoreMicroButton:Complete();
		self.Hide_SpellbookMicroButton:Complete();
		self.Hide_CharacterMicroButton:Complete();
		self.Hide_TargetFrame:Complete();
		self.Hide_StatusTrackingBar:Complete();
		self.Hide_Minimap:Complete();
	end

	self.LootPointer:Begin();
	self.EquipFirstItemWatcher:Begin();

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
		-- is the mount already on the action bar?
		local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
		if TutorialHelper:GetActionButtonBySpellID(mountData.mountID) then
			self.UseMountWatcher:Begin();
		else
			Tutorials.QueueSystem:QueueMountTutorial();
		end
	end

	-- Spec Choice Quest
	if C_QuestLog.IsQuestFlaggedCompleted(tutorialData.SpecQuestTrackID) and not 
		C_QuestLog.IsQuestFlaggedCompleted(tutorialData.SpecCompleteQuestTrackID)then 
		self.SpecTutorial:ForceBegin();
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
	local specQuestID = TutorialHelper:FilterByClass(tutorialData.SpecQuests);
	local vendorQuestID = tutorialData.UseVendorQuest;

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
		Tutorials.QueueSystem:QueueLFDTutorial();
	elseif (questID == vendorQuestID) then
		-- Use Vendor Quest
		self.Vendor_Watcher:Begin();
	elseif (questID == tutorialData.LeavePartyPromptQuest) then
		-- leave party prompt quest
		self.LeavePartyPrompt:Begin();
	elseif (questID == tutorialData.AnUrgentMeeting) then
		-- second use mount reminder
		local mountData = TutorialHelper:FilterByRace(TutorialHelper:GetFactionData().Mounts);
		if TutorialHelper:GetActionButtonBySpellID(mountData.mountID) then
			self.UseMountWatcher:Begin();
		end
	elseif (questID == tutorialData.ShowAllUIQuest) then
		-- Show All UI Quest
		self.Hide_Backpack:Complete();
		self.Hide_BagsBar:Complete();
		self.Hide_OtherMicroButtons:Complete();
		self.Hide_StoreMicroButton:Complete();
		self.Hide_SpellbookMicroButton:Complete();
		self.Hide_CharacterMicroButton:Complete();
	elseif (questID == tutorialData.HunterTameTutorialQuestID) then
		self.HunterTameTutorial:ForceBegin();
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
				local playerClass = TutorialHelper:GetClass();
				if playerClass == "WARRIOR" then
					self.EnhancedCombatTactics_Warrior:Complete();
				elseif playerClass == "ROGUE" then
					self.EnhancedCombatTactics_Rogue:Complete();
				elseif playerClass == "MONK" then
					-- Monk Training
					--
				elseif playerClass == "PRIEST" or playerClass == "WARLOCK" or playerClass == "DRUID" then
					self.EnhancedCombatTactics_UseDoTs:Complete();
				elseif playerClass == "SHAMAN" or playerClass == "MAGE" then
					self.EnhancedCombatTactics_Ranged:Complete();
				else -- ROGUE, PALADIN
					self.EnhancedCombatTactics:Complete();
				end
			elseif questID == tutorialData.UseFoodQuest then
				self.LowHealthWatcher:Begin();
			elseif questID == tutorialData.HunterTameTutorialQuestID then
				self.HunterTameTutorial:Complete();
			end
		end
	end
end

function Tutorials:Quest_Updated(questData)
	local questID = questData.QuestID;
	local tutorialData = TutorialHelper:GetFactionData();

	local specQuestID = TutorialHelper:FilterByClass(tutorialData.SpecQuests);

	-- Spec Tutorial was updated
	if (questID == specQuestID) then
		if C_QuestLog.IsQuestFlaggedCompleted(tutorialData.SpecQuestTrackID) and not 
			C_QuestLog.IsQuestFlaggedCompleted(tutorialData.SpecCompleteQuestTrackID)then 
			self.SpecTutorial:ForceBegin();
		end
	end
end

function Tutorials:Quest_Abandoned(questData)
	local questID = questData.QuestID;
	local tutorialData = TutorialHelper:GetFactionData();

	if questID == tutorialData.StartingQuest then
		self.Intro_CombatDummyInRange:Interrupt();
	elseif (questID == tutorialData.EnhancedCombatTacticsQuest) then
		local playerClass = TutorialHelper:GetClass();
		if playerClass == "WARRIOR" then
			self.EnhancedCombatTactics_Warrior:Complete();
		elseif playerClass == "ROGUE" then
			self.EnhancedCombatTactics_Rogue:Complete();
		elseif playerClass == "MONK" then
			-- Monk Training
		elseif playerClass == "PRIEST" or playerClass == "WARLOCK" or playerClass == "DRUID" then
			self.EnhancedCombatTactics_UseDoTs:Complete();
		elseif playerClass == "SHAMAN" or playerClass == "MAGE" then
			self.EnhancedCombatTactics_Ranged:Complete();
		else -- ROGUE, PALADIN
			self.EnhancedCombatTactics:Complete();
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

		if (questID == tutorialData.LeavePartyPromptQuest) then
			-- leave party prompt quest
			self.LeavePartyPrompt:Begin();
		end

		local classQuestID = TutorialHelper:FilterByClass(tutorialData.ClassQuests);
		if questID == classQuestID then
			self.AddClassSpellToActionBar:Begin();
		end

		if (questID == tutorialData.StandYourGround) then
			self.ChatFrame:Begin(editBox)
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
Tutorials.Intro_KeyboardMouse			= Class_Intro_KeyboardMouse:new()
Tutorials.Intro_CameraLook				= Class_Intro_CameraLook:new();
Tutorials.Intro_ApproachQuestGiver		= Class_Intro_ApproachQuestGiver:new();
Tutorials.Intro_Interact				= Class_Intro_Interact:new();

-- ------------------------------------------------------------------------------------------------------------
-- Intro to Combat
Tutorials.Intro_CombatDummyInRange		= Class_Intro_CombatDummyInRange:new();
Tutorials.Intro_CombatTactics 			= Class_Intro_CombatTactics:new();

-- ------------------------------------------------------------------------------------------------------------
-- Intro to Quest Mechanics
Tutorials.GossipFrameWatcher			= Class_GossipFrameWatcher:new();
Tutorials.AcceptQuestWatcher			= Class_AcceptQuestWatcher:new();
Tutorials.AcceptQuest					= Class_AcceptQuest:new(Tutorials.AcceptQuestWatcher);
Tutorials.TurnInQuestWatcher			= Class_TurnInQuestWatcher:new();
Tutorials.TurnInQuest					= Class_TurnInQuest:new(Tutorials.TurnInQuestWatcher);
Tutorials.QuestRewardChoice				= Class_QuestRewardChoice:new(Tutorials.TurnInQuestWatcher);
Tutorials.QuestCompleteHelp				= Class_QuestCompleteHelp:new();

-- ------------------------------------------------------------------------------------------------------------
-- Queue System
Tutorials.QueueSystem					= Class_QueueSystem:new();
Tutorials.SpellChecker					= Class_SpellChecker:new();

-- ------------------------------------------------------------------------------------------------------------
-- Intro to XP and Level Up
Tutorials.XPBarTutorial					= Class_XPBarTutorial:new();
Tutorials.AddSpellToActionBar			= Class_AddSpellToActionBar:new();
Tutorials.AddClassSpellToActionBar		= Class_AddClassSpellToActionBar:new();

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
Tutorials.EquipTutorial					= Class_EquipTutorial:new();

-- ------------------------------------------------------------------------------------------------------------
-- Enhanced Combat Tactics
Tutorials.EnhancedCombatTactics			= Class_EnhancedCombatTactics:new();
Tutorials.EnhancedCombatTactics_Warrior	= Class_EnhancedCombatTactics_Warrior:new();
Tutorials.EnhancedCombatTactics_Rogue	= Class_EnhancedCombatTactics_Rogue:new();
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
Tutorials.LFGStatusWatcher				= Class_LFGStatusWatcher:new();
Tutorials.LookingForGroup				= Class_LookingForGroup:new()
Tutorials.LeavePartyPrompt				= Class_LeavePartyPrompt:new()

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
Tutorials.UseMountWatcher				= Class_UseMountTutorialWatcher:new();
Tutorials.UseMountTutorial				= Class_UseMountTutorial:new();

-- ------------------------------------------------------------------------------------------------------------
-- Spec Choice Tutorial
Tutorials.SpecTutorial					= Class_SpecTutorial:new()

-- ------------------------------------------------------------------------------------------------------------
-- Misc
Tutorials.HighlightItem					= Class_HighlightItem:new();
Tutorials.ChatFrame						= Class_ChatFrame:new();
Tutorials.StealthTutorial 				= Class_StealthTutorial:new();
Tutorials.DruidFormTutorial 			= Class_DruidFormTutorial:new();
Tutorials.HunterTameTutorial 			= Class_HunterTameTutorial:new();
Tutorials.HunterStableTutorial 			= Class_HunterStableTutorial:new();
Tutorials.AutoPushSpellWatcher			= Class_AutoPushSpellWatcher:new();


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

DebugTutorials(false);
