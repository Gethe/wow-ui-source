
function AddPerksProgramTutorials()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PERKS_PROGRAM_FREEZE_ITEM) then
		TutorialManager:AddWatcher(Class_PerksProgramFreezeItemWatcher:new(), true);
	end

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PERKS_PROGRAM_HIDE_ARMOR) then
		TutorialManager:AddWatcher(Class_PerksProgramProductSelectedWatcher:new(), true);
	end

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PERKS_PROGRAM_NEW_COLLECTION_ITEM) then
		TutorialManager:AddWatcher(Class_PerksProgramProductPurchased:new(), true);
	end

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PERKS_PROGRAM_ACTIVITIES_OPEN) then
		TutorialManager:AddWatcher(Class_PerksProgramActivitiesPromptWatcher:new(), true);
	end

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PERKS_PROGRAM_ACTIVITIES_INTRO) then
		TutorialManager:AddWatcher(Class_PerksProgramActivitiesOpenWatcher:new(), true);
	end

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PERKS_PROGRAM_ACTIVITIES_TRACKING) then
		TutorialManager:AddWatcher(Class_PerksProgramActivitiesTrackingWatcher:new(), true);
	end
end

-- ------------------------------------------------------------------------------------------------------------
Class_PerksProgramFreezeItemWatcher = class("PerksProgramFreezeItemWatcher", Class_TutorialBase);
function Class_PerksProgramFreezeItemWatcher:OnInitialize()
	self.helpTipInfo = {
		text = TUTORIAL_PERKS_PROGRAM_FREEZE_ITEM,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_PERKS_PROGRAM_FREEZE_ITEM,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.BottomEdgeRight,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		alignment = HelpTip.Alignment.Center,
		acknowledgeOnHide = false,
	};
end

function Class_PerksProgramFreezeItemWatcher:ShowHelpTip()
	self.target = PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.FrozenItemFrame.FrozenButton;
	HelpTip:Show(self.target, self.helpTipInfo);
end

function Class_PerksProgramFreezeItemWatcher:StartWatching()
	EventRegistry:RegisterCallback("PerksProgramFrame.OnShow", self.OnPerkProgramFrameShow, self);
end

function Class_PerksProgramFreezeItemWatcher:StopWatching()
	EventRegistry:UnregisterCallback("PerksProgramFrame.OnShow", self);
end

function Class_PerksProgramFreezeItemWatcher:OnPerkProgramFrameShow()
	C_Timer.After(0.1, function()
		self:ShowHelpTip();
	end);
end

function Class_PerksProgramFreezeItemWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_PerksProgramFreezeItemWatcher:FinishTutorial()
	TutorialManager:StopWatcher(self:Name(), true);
	HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_FREEZE_ITEM);
end

-- ------------------------------------------------------------------------------------------------------------
Class_PerksProgramProductSelectedWatcher = class("PerksProgramProductSelectedWatcher", Class_TutorialBase);
function Class_PerksProgramProductSelectedWatcher:OnInitialize()
	self.helpTipInfo = {
		text = TUTORIAL_PERKS_PROGRAM_HIDE_ARMOR,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_PERKS_PROGRAM_HIDE_ARMOR,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		offsetX = 0,
		offsetY	= 0,
		alignment = HelpTip.Alignment.Center,
		acknowledgeOnHide = false,
	};
end

function Class_PerksProgramProductSelectedWatcher:ShowHelpTip()
	self.target = PerksProgramFrame.FooterFrame.ToggleHideArmor;
	HelpTip:Show(self.target, self.helpTipInfo);
end

function Class_PerksProgramProductSelectedWatcher:StartWatching()
	EventRegistry:RegisterCallback("PerksProgramFrame.PerksProductSelected", self.OnPerksProductSelected, self);
end

function Class_PerksProgramProductSelectedWatcher:StopWatching()
	EventRegistry:UnregisterCallback("PerksProgramFrame.OnShow", self);
end

function Class_PerksProgramProductSelectedWatcher:OnPerksProductSelected(categoryID)
	if categoryID == Enum.PerksVendorCategoryType.Transmog or categoryID == Enum.PerksVendorCategoryType.Transmogset then
		C_Timer.After(0.1, function()
			self:ShowHelpTip();
		end);
	else
		HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_HIDE_ARMOR);
	end
end

function Class_PerksProgramProductSelectedWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_PerksProgramProductSelectedWatcher:FinishTutorial()
	EventRegistry:UnregisterCallback("PerksProgramFrame.PerksProductSelected", self);
	TutorialManager:StopWatcher(self:Name(), true);
	HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_HIDE_ARMOR);
end

-- ------------------------------------------------------------------------------------------------------------
Class_PerksProgramProductPurchased = class("PerksProgramProductPurchased", Class_TutorialBase);
function Class_PerksProgramProductPurchased:OnInitialize()
	self.helpTipInfo = {
		text = TUTORIAL_PERKS_PROGRAM_NEW_COLLECTION_ITEM,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_PERKS_PROGRAM_NEW_COLLECTION_ITEM,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Right,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		offsetX = 0,
		offsetY	= 0,
		acknowledgeOnHide = false,
	};
end

function Class_PerksProgramProductPurchased:ShowHelpTip()
	self.target = CollectionsMicroButton;
	HelpTip:Show(self.target, self.helpTipInfo);
end

function Class_PerksProgramProductPurchased:OnProductPurchased()
	self.purchasedProduct = true;
	EventRegistry:UnregisterFrameEventAndCallback("PERKS_PROGRAM_PURCHASE_SUCCESS", self);
end

function Class_PerksProgramProductPurchased:StartWatching()
	EventRegistry:RegisterFrameEventAndCallback("PERKS_PROGRAM_PURCHASE_SUCCESS", self.OnProductPurchased, self);
	EventRegistry:RegisterCallback("PerksProgramFrame.OnHide", self.OnPerkProgramFrameHide, self);
end

function Class_PerksProgramProductPurchased:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("PERKS_PROGRAM_PURCHASE_SUCCESS", self);
	EventRegistry:UnregisterCallback("PerksProgramFrame.OnHide", self);
end

function Class_PerksProgramProductPurchased:OnPerkProgramFrameHide()
	if self.purchasedProduct == true then
		C_Timer.After(0.1, function()
			self:ShowHelpTip();
		end);
	end
end

function Class_PerksProgramProductPurchased:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_PerksProgramProductPurchased:FinishTutorial()
	TutorialManager:StopWatcher(self:Name(), true);
	HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_NEW_COLLECTION_ITEM);
end

-- ------------------------------------------------------------------------------------------------------------
local QuestData = {};
QuestData.Alliance = {
	IntroTradingPostQuestID = 66858;
}
QuestData.Horde = {
	IntroTradingPostQuestID = 66959;
}

Class_PerksProgramActivitiesPromptWatcher = class("PerksProgramActivitiesPromptWatcher", Class_TutorialBase);
function Class_PerksProgramActivitiesPromptWatcher:OnInitialize()
	local factionTable = QuestData[TutorialHelper:GetFaction()];
	if not factionTable then
		return;
	end

	self.questID = QuestData[TutorialHelper:GetFaction()].IntroTradingPostQuestID;
	self.helpTipInfo = {
		text = TUTORIAL_PERKS_PROGRAM_ACTIVITIES_OPEN,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_PERKS_PROGRAM_ACTIVITIES_OPEN,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Right,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		acknowledgeOnHide = false,
	};
end

function Class_PerksProgramActivitiesPromptWatcher:ShowHelpTip()
	self.target = EJMicroButton;	
	HelpTip:Show(self.target, self.helpTipInfo);
end

function Class_PerksProgramActivitiesPromptWatcher:StartWatching()
	if not self.questID then
		self:Complete();
		return;
	end

	if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
		C_Timer.After(0.1, function()
			self:ShowHelpTip();
		end);
	else
		EventRegistry:RegisterFrameEventAndCallback("QUEST_TURNED_IN", self.OnQuestTurnedIn, self);
	end
end

function Class_PerksProgramActivitiesPromptWatcher:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_TURNED_IN", self);
end

function Class_PerksProgramActivitiesPromptWatcher:OnQuestTurnedIn(questID)
	if questID == self.questID then
		EventRegistry:UnregisterFrameEventAndCallback("QUEST_TURNED_IN", self);
		C_Timer.After(0.1, function()
			self:ShowHelpTip();
		end);
	end
end

function Class_PerksProgramActivitiesPromptWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_PerksProgramActivitiesPromptWatcher:FinishTutorial()
	TutorialManager:StopWatcher(self:Name(), true);
	HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_ACTIVITIES_OPEN);
end

-- ------------------------------------------------------------------------------------------------------------
Class_PerksProgramActivitiesOpenWatcher = class("PerksProgramActivitiesOpenWatcher", Class_TutorialBase);
function Class_PerksProgramActivitiesOpenWatcher:OnInitialize()
	self.helpTipInfo = {
		text = MONTHLY_ACTIVITIES_HELP_1,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_PERKS_PROGRAM_ACTIVITIES_INTRO,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeLeft,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		alignment = HelpTip.Alignment.Left,
		acknowledgeOnHide = false,
	};
end

function Class_PerksProgramActivitiesOpenWatcher:ShowHelpTip()
	self.target = EncounterJournalMonthlyActivitiesFrame.ThresholdBar;
	HelpTip:Show(EncounterJournalMonthlyActivitiesFrame, self.helpTipInfo, self.target);
end

function Class_PerksProgramActivitiesOpenWatcher:StartWatching()
	EventRegistry:RegisterCallback("EncounterJournal.TabSet", self.OnEncounterJournalTabOpened, self);
end

function Class_PerksProgramActivitiesOpenWatcher:StopWatching()
	EventRegistry:UnregisterCallback("EncounterJournal.TabSet", self);
end

function Class_PerksProgramActivitiesOpenWatcher:OnEncounterJournalTabOpened(EJ, encounterJournalTabID)
	if encounterJournalTabID == EncounterJournal.MonthlyActivitiesTab:GetID() then
		C_Timer.After(0.1, function()
			self:ShowHelpTip();
		end);
	else
		if self.target then
			HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_ACTIVITIES_INTRO);
		end
	end
end

function Class_PerksProgramActivitiesOpenWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_PerksProgramActivitiesOpenWatcher:FinishTutorial()
	TutorialManager:StopWatcher(self:Name(), true);
	HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_ACTIVITIES_INTRO);
end

-- ------------------------------------------------------------------------------------------------------------
Class_PerksProgramActivitiesTrackingWatcher = class("PerksProgramActivitiesTrackingWatcher", Class_TutorialBase);
function Class_PerksProgramActivitiesTrackingWatcher:OnInitialize()
	self.helpTipInfo = {
		text = MONTHLY_ACTIVITIES_HELP_2,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_PERKS_PROGRAM_ACTIVITIES_TRACKING,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		alignment = HelpTip.Alignment.Left,
		offsetX = -20,
		offsetY	= 0,
		acknowledgeOnHide = false,
	};
end

function Class_PerksProgramActivitiesTrackingWatcher:ShowHelpTip()
	self.target = EncounterJournalMonthlyActivitiesFrame;
	HelpTip:Show(self.target, self.helpTipInfo);
end

function Class_PerksProgramActivitiesTrackingWatcher:StartWatching()
	EventRegistry:RegisterCallback("EncounterJournal.TabSet", self.OnEncounterJournalTabOpened, self);
end

function Class_PerksProgramActivitiesTrackingWatcher:StopWatching()
	EventRegistry:UnregisterCallback("EncounterJournal.TabSet", self);
end

function Class_PerksProgramActivitiesTrackingWatcher:OnEncounterJournalTabOpened(EJ, encounterJournalTabID)
	if encounterJournalTabID == EncounterJournal.MonthlyActivitiesTab:GetID() then
		C_Timer.After(0.1, function()
			self:ShowHelpTip();
		end);
	else
		if self.target then
			HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_ACTIVITIES_TRACKING);
		end
	end
end

function Class_PerksProgramActivitiesTrackingWatcher:OnInterrupt(interruptedBy)
	self:Complete();
end

function Class_PerksProgramActivitiesTrackingWatcher:FinishTutorial()
	TutorialManager:StopWatcher(self:Name(), true);
	HelpTip:Hide(self.target, TUTORIAL_PERKS_PROGRAM_ACTIVITIES_TRACKING);
end