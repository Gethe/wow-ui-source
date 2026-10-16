local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;

local USE_VENDOR_LEVEL_REQUIREMENT = 2;
local PERFORMED_VENDOR_TUTORIAL_CVAR = "performedVendorTutorial";
local PERFORMED_DEATH_TUTORIAL_CVAR = "performedDeathTutorial";

function TutorialLogic:IsNPEAllowed() 
	local playerLevel = UnitLevel("player");
	-- Fail safe to just turn off NPE if they reach level 10.
	if playerLevel >= TutorialData.TUTORIAL_LEVEL_LIMIT then
		return false;
	end
	-- For now just disable the tutorial on gamepad until its implemented.
	if InputUtil.IsGamepadUIEnabled() then
		return false;
	end
	-- If they've completed the NPE then they can skip the tutorial on all characters.
	local _, _, _, completed = GetAchievementInfo(TutorialManager.NPE_AchievementID);
	-- If the player resets tutorials then ignore their achievement.
	local skipTutorialAchievement = C_CVar.GetCVarBool("skipTutorialAchievement");
	if completed and not skipTutorialAchievement then
		return false;
	end
	return true;
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: [Release Corpse] - Map Prompt - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------

function Class_Death_ReleaseCorpse:CanBegin()
	return not C_CVar.GetCVarBool(PERFORMED_DEATH_TUTORIAL_CVAR);
end

local oldReleaseCorpseMethod = Class_Death_ReleaseCorpse.OnBegin;
function Class_Death_ReleaseCorpse:OnBegin()
	if not UnitIsDead("player") then
		TutorialManager:Finished(self:Name());
		return;
	end
	if not self:CanBegin() then
		TutorialManager:Finished(self:Name());
		return;
	end
	oldReleaseCorpseMethod(self);
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Release Corpse - Map Prompt - [Resurrect Prompt]
-- ------------------------------------------------------------------------------------------------------------

local oldClass_Death_ResurrectPromptOnCompleteMethod = Class_Death_ResurrectPrompt.OnComplete;
function Class_Death_ResurrectPrompt:OnComplete()
	oldClass_Death_ResurrectPromptOnCompleteMethod(self);
	C_CVar.SetCVar(PERFORMED_DEATH_TUTORIAL_CVAR, "1");
end

-- ============================================================================================================
-- Use Vendor overrides
-- ============================================================================================================

function Class_UseVendor:HandleMerchantShow()
	if self.sellTutorialComplete and self.buyBackTutorialComplete then
		return;
	end
	local playerLevel = UnitLevel("player");
	if playerLevel < USE_VENDOR_LEVEL_REQUIREMENT then
		return;
	end
	local performedVendorTutorial = C_CVar.GetCVarBool(PERFORMED_VENDOR_TUTORIAL_CVAR);
	if performedVendorTutorial then
		return;
	end
	-- need a short delay to find the item frames.
	C_Timer.After(0.1, function()
		local itemFrame = self:GetGreyItemFrame();
		if itemFrame == nil then
			return;
		end
		TutorialManager:Queue(self:Name());
	end);
end

function Class_UseVendor:CanBegin()
	return true;
end

function Class_UseVendor:OnBegin()
	-- We're' doing the vendor tutorial at this point.
	C_CVar.SetCVar(PERFORMED_VENDOR_TUTORIAL_CVAR, "1");
	self:MerchantTabHelp()
end

function Class_UseVendor:StartGreyItemTutorial()
	self:UpdateGreyItemPointer();
end

function Class_UseVendor:StartBuyItemTutorial()
	self.buyPointerTimer = C_Timer.NewTimer(2, function()
		self.buyPointerTimer = nil;
		if self.buyTutorialComplete then
			return;
		end
		self.buyPointerID = self:AddPointerTutorial(TutorialHelper:FormatString(NPEV2_BUY_ITEMS_FROM_VENDOR), "LEFT", MerchantItem2, 0, 0);
	end);
end

local originalClass_UseVendorBagNewItemsUpdated = Class_UseVendor.BagNewItemsUpdated;
function Class_UseVendor:BagNewItemsUpdated()
	originalClass_UseVendorBagNewItemsUpdated(self);
	self:EndBuyTutorialTimer();
end

local originalClass_UseVendorOnComplete = Class_UseVendor.OnComplete;
function Class_UseVendor:OnComplete()
	originalClass_UseVendorOnComplete(self);
	self:EndBuyTutorialTimer();
end

function Class_UseVendor:EndBuyTutorialTimer()
	if self.buyPointerTimer then
		self.buyPointerTimer:Cancel();
		self.buyPointerTimer = nil;
	end
end

function Class_UseVendor:OnAdded()
	self:SetupMerchantCallbacks();
end

function Class_UseVendor:ShouldShowBuyBackTabHelp()
	return false;
end

function Class_UseVendor:CanEndTutorial()
	return true;
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Release Corpse - [Map Prompt] - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------

function Class_Death_MapPrompt:ShowIndicatorOnMap()
	return true;
end

-------------------------------------------------------------------------------------
-- We want to disable the rest of the tutorials in the NPE
-------------------------------------------------------------------------------------

function Class_UseMinimap:OnAdded()
	return false;
end

function Class_UseMinimap:CanBegin()
	return false;
end

function Class_Intro_OpenMap:CanBegin()
	return false;
end

function Class_Intro_MapHighlights:CanBegin()
	return false;
end

function Class_UseQuestItem:CanBegin()
	return false;
end

function Class_UseQuestItem:OnAdded()
end

function Class_EnhancedCombatTactics:OnAdded()
end

function Class_EnhancedCombatTactics:CanBegin()
	return false;
end

function Class_EnhancedCombatTactics_Warrior:CanBegin()
	return false;
end

function Class_EnhancedCombatTactics_Rogue:CanBegin()
	return false;
end

function Class_EnhancedCombatTactics_UseDoTs:CanBegin()
	return false;
end

function Class_EnhancedCombatTactics_Ranged:CanBegin()
	return false;
end

function Class_AddHunterTameSpells:CanBegin()
	return false;
end

function Class_HunterTame:CanBegin()
	return false;
end

function Class_SelfHeal:CanBegin()
	return false;
end

function Class_PromptLFG:CanBegin()
	return false;
end

function Class_LookingForGroup:CanBegin()
	return false;
end

function Class_LeavePartyPrompt:CanBegin()
	return false;
end

function Class_MountReceived:CanBegin()
	return false;
end

function Class_AddMountToActionBar:CanBegin()
	return false;
end

function Class_UseMount:CanBegin()
	return false;
end

function Class_HousingSkip:OnInitialize()
end

function Class_Intro_CombatDummyInRange:CanBegin()
	return false;
end

function Class_AcceptQuestWatcher:OnShow()
end

function Class_MountReceived:OnInitialize()
end

function Class_XPBarWatcher:StartWatching()
end

-------------------------------------------------------------------------------------
-- Specifically enable tutorials for Camelot
-------------------------------------------------------------------------------------

function TutorialLogic:AddTutorials()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);

	-- add tutorials
	TutorialManager:AddTutorial(Class_AddSpellToActionBarService:new());
	TutorialManager:AddTutorial(Class_ItemUpgradeCheckingService:new());
	TutorialManager:AddTutorial(Class_Intro_KeyboardMouse:new());
	TutorialManager:AddTutorial(Class_Intro_CameraLook:new());
	TutorialManager:AddTutorial(Class_Intro_ApproachQuestGiver:new());
	TutorialManager:AddTutorial(Class_Intro_Interact:new());
	TutorialManager:AddTutorial(Class_Intro_Chat:new());
	TutorialManager:AddTutorial(Class_QuestCompleteHelp:new());
	TutorialManager:AddTutorial(Class_UseQuestItem:new());
	TutorialManager:AddTutorial(Class_ChangeEquipment:new());
	TutorialManager:AddTutorial(Class_UseVendor:new());

	local autoStart = true;

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
	
	TutorialManager:AddTutorial(Class_EnterHostileZone:new());
	TutorialManager:AddTutorial(Class_Intro_TargetCreatureInRange:new());

	-- add watchers
	TutorialManager:AddWatcher(Class_UI_Watcher:new(), autoStart);
	TutorialManager:AddWatcher(Class_GossipFrameWatcher:new(), autoStart);
	TutorialManager:AddWatcher(Class_AcceptQuestWatcher:new(), autoStart);
	TutorialManager:AddWatcher(Class_InventoryWatcher:new(), autoStart);

	-- start NPE
	TutorialManager:Queue(Class_Intro_KeyboardMouse.name);
	
	TutorialQuestManager:RegisterForCallbacks(self);-- Certain tutorials kick off when quests are accepted
end

function TutorialLogic:Quest_Accepted(questData)
	local questID = questData.QuestID;

	local tutorialKey = nil;
	local args = nil;
	if self:ContainsQuest(TutorialData:GetFactionData():GetEarlyKillQuestIDsByRace(), questID) then
		tutorialKey = Class_Intro_TargetCreatureInRange.name;
	elseif self:ContainsQuest(TutorialData:GetFactionData():GetEarlyHostileQuestIDByRace(), questID) then
		tutorialKey = Class_EnterHostileZone.name;
	end
	if tutorialKey then
		TutorialManager:Queue(tutorialKey, args);
	end
end

function TutorialLogic:ContainsQuest(questIDs, newQuestID)
	for i, questID in ipairs(questIDs) do
		if questID == newQuestID then
			return true;
		end
	end
	return false;
end
