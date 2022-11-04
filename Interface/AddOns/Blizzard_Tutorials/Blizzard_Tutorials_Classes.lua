
function AddSpecAndTalentTutorials()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_STARTER_HELP) then
		TutorialManager:AddWatcher(Class_StarterTalentWatcher:new(), true);
	end

	local _, raceFilename = UnitRace("Player");
	local playerIsDracthyr = raceFilename == "Dracthyr";-- the Dracthyrs have a separate quest for spec introduction
	if not playerIsDracthyr and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SPEC_CHANGES) and IsPlayerInitialSpec() then
		TutorialManager:AddTutorial(Class_ChangeSpec:new());
	end

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_CHANGES) then
		TutorialManager:AddTutorial(Class_TalentPoints:new());
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Change Spec
-- ------------------------------------------------------------------------------------------------------------
Class_ChangeSpec = class("ChangeSpec", Class_TutorialBase);
function Class_ChangeSpec:OnInitialize()
end

function Class_ChangeSpec:OnAdded(args)
	if C_SpecializationInfo.CanPlayerUseTalentSpecUI() and IsPlayerInitialSpec() then
		TutorialManager:Queue(self:Name());
	else
		Dispatcher:RegisterEvent("PLAYER_TALENT_UPDATE", self);
		Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
	end
end

function Class_ChangeSpec:StartSelf()
	if C_SpecializationInfo.CanPlayerUseTalentSpecUI() and IsPlayerInitialSpec() then
		Dispatcher:UnregisterEvent("PLAYER_TALENT_UPDATE", self);
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		TutorialManager:Queue(self:Name());
	end
end

function Class_ChangeSpec:PLAYER_LEVEL_CHANGED()
	self:StartSelf();
end

function Class_ChangeSpec:PLAYER_TALENT_UPDATE()
	self:StartSelf();
end

function Class_ChangeSpec:CanBegin()
	if C_SpecializationInfo.CanPlayerUseTalentSpecUI() and IsPlayerInitialSpec() then
		return true;
	end
	return false;
end

function Class_ChangeSpec:OnBegin()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SPEC_CHANGES) then
		TutorialManager:Finished(self:Name());
		return;
	end
	EventRegistry:RegisterCallback("TalentFrame.OpenFrame", self.EvaluateTalentFrame, self);
	EventRegistry:RegisterCallback("TalentFrame.CloseFrame", self.EvaluateTalentFrame, self);
	EventRegistry:RegisterCallback("TalentFrame.SpecTab.ActivateSpec", self.EnableHelp, self);
	C_Timer.After(0.1, function()
		self:ShowSpecButtonPointer();
	end);			
end

function Class_ChangeSpec:ShowSpecButtonPointer()
	self:HidePointerTutorials();
	self:ShowPointerTutorial(NPEV2_SPEC_TUTORIAL_GOSSIP_CLOSED, "DOWN", TalentMicroButton, 0, 10, nil, "DOWN");
	ActionButton_ShowOverlayGlow(TalentMicroButton);
end

function Class_ChangeSpec:EvaluateTalentFrame()
	if ( ClassTalentFrame and ClassTalentFrame:IsShown() ) then
		self:HidePointerTutorials();
		self:EnableHelp(true);
		Dispatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);
	else
		self:ShowSpecButtonPointer();
	end
end

function Class_ChangeSpec:EnableHelp(helpEnabled)
	if ClassTalentFrame then
		ClassTalentFrame.SpecTab:ShowTutorialHelp(helpEnabled);
	end
end

function Class_ChangeSpec:PLAYER_SPECIALIZATION_CHANGED()
	if IsPlayerInitialSpec() then
		return;
	end
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SPEC_CHANGES, true);
	Dispatcher:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);
	EventRegistry:UnregisterCallback("TalentFrame.OpenFrame", self);
	EventRegistry:UnregisterCallback("TalentFrame.CloseFrame", self);
	EventRegistry:UnregisterCallback("TalentFrame.SpecTab.ActivateSpec", self);
	TutorialManager:Finished(self:Name());
end

function Class_ChangeSpec:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_ChangeSpec:OnComplete()
	Dispatcher:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", self);
	Dispatcher:UnregisterEvent("PLAYER_TALENT_UPDATE", self);
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	EventRegistry:UnregisterCallback("TalentFrame.OpenFrame", self);
	EventRegistry:UnregisterCallback("TalentFrame.CloseFrame", self);
	EventRegistry:UnregisterCallback("TalentFrame.SpecTab.ActivateSpec", self);

	self:CleanUpCallbacks();

	self:EnableHelp(false);
	ActionButton_HideOverlayGlow(TalentMicroButton);
	self:HidePointerTutorials();
	TutorialManager:RemoveTutorial(self:Name());
end

function Class_ChangeSpec:CleanUpCallbacks()
end

-- ------------------------------------------------------------------------------------------------------------
-- NPE Version Change Spec
-- ------------------------------------------------------------------------------------------------------------
Class_ChangeSpec_NPE = class("ChangeSpec_NPE", Class_ChangeSpec);
function Class_ChangeSpec_NPE:OnAdded(args)
	self.specQuestID = args;
	if C_QuestLog.GetLogIndexForQuestID(self.specQuestID) ~= nil then
		self.readyForTurnIn = C_QuestLog.ReadyForTurnIn(self.specQuestID);
		if self.readyForTurnIn then
			TutorialManager:Finished(self:Name());
		else
			TutorialManager:Queue(self:Name());
		end
	end
end

function Class_ChangeSpec_NPE:CanBegin()
	local questActiveButNotComplete = QuestUtil.IsQuestActiveButNotComplete(self.specQuestID);
	if questActiveButNotComplete then
		return true;
	end
	return false;
end

function Class_ChangeSpec_NPE:OnBegin()
	local questComplete = C_QuestLog.IsQuestFlaggedCompleted(self.specQuestID);
	if questComplete then
		TutorialManager:Finished(self:Name());
		return;
	end

	EventRegistry:RegisterCallback("TalentFrame.OpenFrame", self.EvaluateTalentFrame, self);
	EventRegistry:RegisterCallback("TalentFrame.CloseFrame", self.EvaluateTalentFrame, self);
	EventRegistry:RegisterCallback("TalentFrame.SpecTab.ActivateSpec", self.EnableHelp, self);
	local questObjectives = C_QuestLog.GetQuestObjectives(self.specQuestID);
	local spokeToTrainer = questObjectives[1].finished;
	if spokeToTrainer then
		local newSpecActivated = questObjectives[2].finished;
		if newSpecActivated then
			self:Complete();
			return;
		else
			C_Timer.After(0.1, function()
				self:ShowSpecButtonPointer();
			end);			
		end
	else
		Dispatcher:RegisterEvent("QUEST_REMOVED", self);
		Dispatcher:RegisterEvent("UNIT_QUEST_LOG_CHANGED", self);		
	end
end

function Class_ChangeSpec_NPE:QUEST_REMOVED(questIDRemoved)
	if self.specQuestID == questIDRemoved then
		TutorialManager:Finished(self:Name());
	end
end

function Class_ChangeSpec_NPE:UNIT_QUEST_LOG_CHANGED()
	local questObjectives = C_QuestLog.GetQuestObjectives(self.specQuestID);
	local spokeToTrainer = questObjectives[1].finished;
	if spokeToTrainer then
		Dispatcher:UnregisterEvent("UNIT_QUEST_LOG_CHANGED", self);
		Dispatcher:RegisterEvent("GOSSIP_CLOSED", self);
	end
end

function Class_ChangeSpec_NPE:GOSSIP_CLOSED()
	local questObjectives = C_QuestLog.GetQuestObjectives(self.specQuestID);
	local spokeToTrainer = questObjectives[1].finished;
	if spokeToTrainer then
		Dispatcher:UnregisterEvent("GOSSIP_CLOSED", self);
		self:ShowSpecButtonPointer();
	end
end

function Class_ChangeSpec_NPE:CleanUpCallbacks()
	Dispatcher:UnregisterEvent("GOSSIP_CLOSED", self);
	Dispatcher:UnregisterEvent("QUEST_REMOVED", self);
	Dispatcher:UnregisterEvent("UNIT_QUEST_LOG_CHANGED", self);
	EventRegistry:UnregisterCallback("TalentFrame.OpenFrame", self);
	EventRegistry:UnregisterCallback("TalentFrame.CloseFrame", self);
	EventRegistry:UnregisterCallback("TalentFrame.SpecTab.ActivateSpec", self);
end

-- ------------------------------------------------------------------------------------------------------------
-- Talent Points
-- ------------------------------------------------------------------------------------------------------------
Class_TalentPoints = class("TalentPoints", Class_TutorialBase);
function Class_TalentPoints:OnInitialize()
end

function Class_TalentPoints:OnAdded(args)
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_CHANGES) then
		if PlayerUtil.CanUseClassTalents() and C_ClassTalents.HasUnspentTalentPoints() then
			TutorialManager:Queue(self:Name());
		else
			Dispatcher:RegisterEvent("PLAYER_TALENT_UPDATE", self);
			Dispatcher:RegisterEvent("PLAYER_LEVEL_CHANGED", self);
			Dispatcher:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED", self);
		end
	else
		TutorialManager:RemoveTutorial(self:Name());
	end
end

function Class_TalentPoints:StartSelf()
	local canUseTalents = PlayerUtil.CanUseClassTalents();
	local hasUnspentTalentPoints = C_ClassTalents.HasUnspentTalentPoints();
	if canUseTalents and hasUnspentTalentPoints then
		Dispatcher:UnregisterEvent("PLAYER_TALENT_UPDATE", self);
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
		Dispatcher:UnregisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED", self);
		TutorialManager:Queue(self:Name());
	end
end

function Class_TalentPoints:PLAYER_LEVEL_CHANGED()
	self:StartSelf();
end

function Class_TalentPoints:PLAYER_TALENT_UPDATE()
	self:StartSelf();
end

function Class_TalentPoints:ACTIVE_COMBAT_CONFIG_CHANGED()
	self:StartSelf();
end

function Class_TalentPoints:CanBegin()
	if PlayerUtil.CanUseClassTalents() and C_ClassTalents.HasUnspentTalentPoints() then
		return true;
	end
	return false;
end

function Class_TalentPoints:OnBegin()
	if PlayerUtil.CanUseClassTalents() and C_ClassTalents.HasUnspentTalentPoints() then
		EventRegistry:RegisterCallback("TalentFrame.OpenFrame", self.EvaluateTalentFrame, self);
		C_Timer.After(0.1, function()
			self:EvaluateTalentFrame();
		end);	
	else
		self:TalentTutorialFinished();
	end
end

function Class_TalentPoints:ShowTalentButtonPointer()
	self:HidePointerTutorials();
	if HelpTip:IsShowingAnyInSystem("MicroButtons") then
		HelpTip:HideAllSystem("MicroButtons");
	end
	self:ShowPointerTutorial(TALENT_MICRO_BUTTON_UNSPENT_TALENTS, "DOWN", TalentMicroButton, 0, 10, nil, "DOWN");
	ActionButton_ShowOverlayGlow(TalentMicroButton);
end

function Class_TalentPoints:EvaluateTalentFrame()
	if ClassTalentFrame and ClassTalentFrame:IsShown() and C_ClassTalents.HasUnspentTalentPoints() then
		self:HidePointerTutorials();
		EventRegistry:RegisterCallback("TalentFrame.CloseFrame", self.TalentTutorialFinished, self);

		if ClassTalentFrame.SpecTab:IsShown() then
			EventRegistry:RegisterCallback("TalentFrame.TalentTab.Show", self.TalentFrameTalentsTabShow, self);
			local talentsTab = ClassTalentFrame:GetTalentsTabButton();
			self:ShowPointerTutorial(NPEV2_SELECT_TALENTS_TAB, "DOWN", talentsTab, 0, -10, nil, "DOWN");
		else
			EventRegistry:RegisterCallback("TalentFrame.SpecTab.Show", self.TalentFrameSpecTabShow, self);
		end
	else
		if C_ClassTalents.HasUnspentTalentPoints() then
			self:ShowTalentButtonPointer();
		else
			self:TalentTutorialFinished();
		end
	end
end

function Class_TalentPoints:TalentFrameTalentsTabShow()
	EventRegistry:UnregisterCallback("TalentFrame.TalentTab.Show", self);
	C_Timer.After(0.1, function()
		self:EvaluateTalentFrame();
	end);		
end

function Class_TalentPoints:TalentFrameSpecTabShow()
	EventRegistry:UnregisterCallback("TalentFrame.SpecTab.Show", self);
	C_Timer.After(0.1, function()
		self:EvaluateTalentFrame();
	end);		
end

function Class_TalentPoints:TalentTutorialFinished()
	EventRegistry:UnregisterCallback("TalentFrame.CloseFrame", self);
	if C_ClassTalents.HasUnspentTalentPoints() then
		C_Timer.After(0.1, function()
			self:EvaluateTalentFrame();
		end);
	else
		TutorialManager:Finished(self:Name());
	end
end

function Class_TalentPoints:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_TalentPoints:OnComplete()
	self:HidePointerTutorials();
	ActionButton_HideOverlayGlow(TalentMicroButton);
	Dispatcher:UnregisterEvent("PLAYER_TALENT_UPDATE", self);
	Dispatcher:UnregisterEvent("PLAYER_LEVEL_CHANGED", self);
	Dispatcher:UnregisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED", self);
	EventRegistry:UnregisterCallback("TalentFrame.SpecTab.Show", self);
	EventRegistry:UnregisterCallback("TalentFrame.TalentTab.Show", self);
	EventRegistry:UnregisterCallback("TalentFrame.OpenFrame", self);
	EventRegistry:UnregisterCallback("TalentFrame.CloseFrame", self);

	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_CHANGES, true);
	TutorialManager:RemoveTutorial(self:Name());
end

-- ------------------------------------------------------------------------------------------------------------
-- Starter Helper Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_StarterTalentWatcher = class("StarterTalentWatcher", Class_TutorialBase);
	local helpTipInfo = {
		text = NPEV2_TALENTS_STARTER_BUILD,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_TALENT_STARTER_HELP,
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		acknowledgeOnHide = false,
		handlesGlobalMouseEventCallback = function() return true; end,
	};

function Class_StarterTalentWatcher:EvaluateTalentFrame()
	if ClassTalentFrame and ClassTalentFrame:IsShown() and C_ClassTalents.HasUnspentTalentPoints() then
		if self.Timer then
			self.Timer:Cancel();
		end
				
		if ClassTalentFrame.TalentsTab:IsShown() then
			self.Timer = C_Timer.NewTimer(30, function() self:ShowStarterTalentsHelp(ClassTalentFrame.TalentsTab.LoadoutDropDown) end);
		else
			self:HideStarterTalentsHelp();
		end
	else
		self:HideStarterTalentsHelp();
	end	
end

function Class_StarterTalentWatcher:ShowStarterTalentsHelp(pointerTarget)
	HelpTip:Hide(ClassTalentFrame.TalentsTab.LoadoutDropDown, NPEV2_TALENTS_STARTER_BUILD);
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_STARTER_HELP) then
		EventRegistry:RegisterCallback("UIDropDownMenu.Show", self.TalentFrameDropDownShow, self);
		HelpTip:Show(ClassTalentFrame.TalentsTab.LoadoutDropDown, helpTipInfo, pointerTarget);
	end
end

function Class_StarterTalentWatcher:HideStarterTalentsHelp()
	if not ClassTalentFrame then
		return;
	end
	if self.Timer then
		self.Timer:Cancel();
	end
	HelpTip:Hide(ClassTalentFrame.TalentsTab.LoadoutDropDown, NPEV2_TALENTS_STARTER_BUILD);
end

function Class_StarterTalentWatcher:TalentFrameDropDownShow(dropdownFrame)
	EventRegistry:UnregisterCallback("UIDropDownMenu.Show", self);
	EventRegistry:RegisterCallback("UIDropDownMenu.Hide", self.TalentFrameDropDownHide, self);
	self:ShowStarterTalentsHelp(dropdownFrame);
end

function Class_StarterTalentWatcher:TalentFrameDropDownHide()
	EventRegistry:UnregisterCallback("UIDropDownMenu.Hide", self);
	self:ShowStarterTalentsHelp(ClassTalentFrame.TalentsTab.LoadoutDropDown);
end

function Class_StarterTalentWatcher:DelayedEvaluateTalentFrame()
	C_Timer.After(0.1, function()
		self:EvaluateTalentFrame();
	end);
end

function Class_StarterTalentWatcher:StarterBuildSelected(starterBuildSelected)
	if starterBuildSelected then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_STARTER_HELP, true);
		self:TalentFrameClosed();
	end
end

function Class_StarterTalentWatcher:TalentFrameClosed()
	self:HideStarterTalentsHelp();
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_STARTER_HELP) then
		TutorialManager:StopWatcher(self:Name(), true);
		self:Complete();
	end
end

function Class_StarterTalentWatcher:StartWatching()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_STARTER_HELP) then
		TutorialManager:StopWatcher(self:Name(), true);
	else
		EventRegistry:RegisterCallback("TalentFrame.CloseFrame", self.TalentFrameClosed, self);
		EventRegistry:RegisterCallback("TalentFrame.TalentTab.Show", self.DelayedEvaluateTalentFrame, self);
		EventRegistry:RegisterCallback("TalentFrame.SpecTab.Show", self.DelayedEvaluateTalentFrame, self);
		EventRegistry:RegisterCallback("TalentFrame.TalentTab.StarterBuild", self.StarterBuildSelected, self);
	end
end

function Class_StarterTalentWatcher:StopWatching()	
	EventRegistry:UnregisterCallback("TalentFrame.CloseFrame", self);
	EventRegistry:UnregisterCallback("TalentFrame.TalentTab.Show", self);
	EventRegistry:UnregisterCallback("TalentFrame.SpecTab.Show", self);
	EventRegistry:UnregisterCallback("TalentFrame.TalentTab.StarterBuild", self);
	EventRegistry:UnregisterCallback("UIDropDownMenu.Show", self);
	EventRegistry:UnregisterCallback("UIDropDownMenu.Hide", self);
end

function Class_StarterTalentWatcher:OnInterrupt(interruptedBy)
	TutorialManager:StopWatcher(self:Name(), true);
end

function Class_StarterTalentWatcher:OnComplete()
	self:HideStarterTalentsHelp();
end

-- ------------------------------------------------------------------------------------------------------------
-- NPE Version Starter Helper Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_StarterTalentWatcher_NPE = class("StarterTalentWatcher_NPE", Class_StarterTalentWatcher);
function Class_StarterTalentWatcher_NPE:ShowStarterTalentsHelp(pointerTarget)
	HelpTip:SetHelpTipsEnabled("NPEv2", true);
	HelpTip:Hide(ClassTalentFrame.TalentsTab.LoadoutDropDown, NPEV2_TALENTS_STARTER_BUILD);

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_STARTER_HELP) then
		EventRegistry:RegisterCallback("UIDropDownMenu.Show", self.TalentFrameDropDownShow, self);
		HelpTip:Show(ClassTalentFrame.TalentsTab.LoadoutDropDown, helpTipInfo, pointerTarget);
	end
end

function Class_StarterTalentWatcher_NPE:HideStarterTalentsHelp()
	if not ClassTalentFrame then
		return;
	end
	if self.Timer then
		self.Timer:Cancel();
	end
	HelpTip:Hide(ClassTalentFrame.TalentsTab.LoadoutDropDown, NPEV2_TALENTS_STARTER_BUILD);
	HelpTip:SetHelpTipsEnabled("NPEv2", false);
end