local FIRST_RPE_QUEST_ID = 90882;
local LAST_RPE_QUEST_ID = 90911;

local s_tutorialsAdded = false;
local s_tutorialsActive = false;

local function ToggleTutorial(name, active)
	local watcher = TutorialManager:GetWatcher(name);
	if active then
		watcher:Activate();
	else
		watcher:Deactivate();
	end
end

-- Because a player can enter RPE multiple times a session, these tutorials should not have Complete() called
-- on them like normal tutorials because that would remove them until a UI reload.
-- This will manage them instead with Activate and Deactivate calls.
local function EvaluateRPEState()
	if C_PlayerInfo.IsPlayerInRPE() then
		if not s_tutorialsAdded then
			s_tutorialsAdded = true;
			TutorialManager:AddWatcher(Class_Interrupt_RPE_Watcher:new(), true);
			TutorialManager:AddWatcher(Class_AssistedHighlight_RPE_Watcher:new(), true);
			TutorialManager:AddWatcher(Class_Dragonriding_RPE_Watcher:new(), true);
		end
		if not s_tutorialsActive then
			s_tutorialsActive = true;
			ToggleTutorial("Interrupt_RPE_Watcher", true);
			ToggleTutorial("AssistedHighlight_RPE_Watcher", true);
			ToggleTutorial("Dragonriding_RPE_Watcher", true);
		end
	else
		if s_tutorialsActive then
			s_tutorialsActive = false;
			ToggleTutorial("Interrupt_RPE_Watcher", false);
			ToggleTutorial("AssistedHighlight_RPE_Watcher", false);
			ToggleTutorial("Dragonriding_RPE_Watcher", false);
		else
			EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
				EvaluateRPEState();
			end, EvaluateRPEState);
		end
	end
end

function AddRPETutorials()
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", EvaluateRPEState, AddRPETutorials);
	EvaluateRPEState();
end

-- ------------------------------------------------------------------------------------------------------------
-- Interrupt
-- ------------------------------------------------------------------------------------------------------------

local INTERRUPT_QUEST_ID = 92028;

Class_Interrupt_RPE_Watcher = class("Interrupt_RPE_Watcher", Class_TutorialBase);

function Class_Interrupt_RPE_Watcher:StartWatching()
	-- nop
end

function Class_Interrupt_RPE_Watcher:Activate()
	-- Check if quest is done. Also, warlocks have a different quest and don't need the tutorial.
	if C_QuestLog.IsComplete(INTERRUPT_QUEST_ID) or C_QuestLog.IsQuestFlaggedCompleted(INTERRUPT_QUEST_ID) or TutorialHelper:GetClass() == "WARLOCK" then
		return;
	end

	EventRegistry:RegisterFrameEventAndCallback("QUEST_ACCEPTED", self.OnQuestListChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("QUEST_REMOVED", self.OnQuestListChanged, self);
	EventRegistry:RegisterCallback("PlayerSpellsFrame.OpenFrame", self.EvaluateTutorial, self);
	EventRegistry:RegisterCallback("PlayerSpellsFrame.CloseFrame", self.EvaluateTutorial, self);
	self:EvaluateTutorial();
end

function Class_Interrupt_RPE_Watcher:Deactivate()
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_ACCEPTED", self);
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_REMOVED", self);
	EventRegistry:UnregisterCallback("PlayerSpellsFrame.OpenFrame", self);
	EventRegistry:UnregisterCallback("PlayerSpellsFrame.CloseFrame", self);
	self:HidePointerTutorials();
end

function Class_Interrupt_RPE_Watcher:OnQuestListChanged(questID)
	if questID == INTERRUPT_QUEST_ID then
		self:EvaluateTutorial();
	end
end

function Class_Interrupt_RPE_Watcher:EvaluateTutorial()
	local showTutorial = false;
	local canShowTutorial = C_QuestLog.IsOnQuest(INTERRUPT_QUEST_ID) and not C_QuestLog.IsComplete(INTERRUPT_QUEST_ID);
	local spellBookShown = PlayerSpellsFrame and PlayerSpellsFrame:IsShown();
	if canShowTutorial and not spellBookShown then
		showTutorial = true;
		-- check action bars
		local actionBars = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarLeftButton", "MultiBarRightButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button" };
		for actionBarIndex, actionBar in pairs(actionBars) do
			for i = 1, 12 do
				local btn = _G[actionBar .. i];
				if btn and btn.action then
					if C_ActionBar.IsInterruptAction(btn.action) then
						showTutorial = false;
						break;
					end
				end
			end
		end
	end

	if showTutorial then
		self:ShowPointerTutorial(RPE_NO_INTERRUPT_ACTION, "DOWN", PlayerSpellsMicroButton, 0, 10, nil, "DOWN");
	else
		self:HidePointerTutorials();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Assisted Highlight
-- ------------------------------------------------------------------------------------------------------------

Class_AssistedHighlight_RPE_Watcher = class("AssistedHighlight_RPE_Watcher", Class_TutorialBase);

function Class_AssistedHighlight_RPE_Watcher:StartWatching()
	StaticPopupDialogs["RPE_ASSISTED_HIGHLIGHT_CHOICE"] = {
		text = RPE_ASSISTED_HIGHLIGHT_TURN_CHOICE,
		button1 = RPE_ASSISTED_HIGHLIGHT_TURN_OFF,
		button2 = RPE_ASSISTED_HIGHLIGHT_KEEP_ON,
		OnAccept = function()
			SetCVar("assistedCombatHighlight", false);
			SetCVar("assistedCombatHighlightRPE", false);
		end,
		OnCancel = function()
			SetCVar("assistedCombatHighlightRPE", false);
		end,
		timeout = 0,
		whileDead = 1,
		wide = 1,
	};
end

function Class_AssistedHighlight_RPE_Watcher:Activate()
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_IN_COMBAT_CHANGED", self.OnCombatChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("QUEST_ACCEPTED", self.OnQuestAccepted, self);
end

function Class_AssistedHighlight_RPE_Watcher:Deactivate()
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_IN_COMBAT_CHANGED", self);
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_ACCEPTED", self);

	if GetCVarBool("assistedCombatHighlightRPE") then
		SetCVar("assistedCombatHighlight", false);
		SetCVar("assistedCombatHighlightRPE", false);
	end
	StaticPopup_Hide("RPE_ASSISTED_HIGHLIGHT_CHOICE");
end

function Class_AssistedHighlight_RPE_Watcher:OnCombatChanged(inCombat)
	if inCombat and C_QuestLog.IsOnQuest(FIRST_RPE_QUEST_ID) and not GetCVarBool("assistedCombatHighlight") and not GetCVarBool("assistedCombatHighlightRPE") then
		SetCVar("assistedCombatHighlight", true);
		SetCVar("assistedCombatHighlightRPE", true);
		local highlightFrame = CreateFrame("FRAME", nil, nil, "ActionBarButtonAssistedCombatHighlightTemplate");
		highlightFrame:Show();
		highlightFrame.Flipbook.Anim:Play();
		local content = { text = RPE_ASSISTED_HIGHLIGHT_ACTIVATED, iconFrame = highlightFrame };
		local duration = 10;
		self:ShowScreenTutorial(content, duration);
	end
end

function Class_AssistedHighlight_RPE_Watcher:OnQuestAccepted(questID)
	if questID == LAST_RPE_QUEST_ID and GetCVarBool("assistedCombatHighlightRPE") then
		StaticPopup_Show("RPE_ASSISTED_HIGHLIGHT_CHOICE");
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Dragonriding RPE Watcher
-- ------------------------------------------------------------------------------------------------------------

local DRAGONRIDING_QUEST_ID = 90883;
local SPELL_SURGE_FORWARD = 372608;
local SPELL_SKYWARD_ASCENT = 372610;

local DragonridingTutorialStep = EnumUtil.MakeEnum(
	"OpenMountJournal",
	"DragMount",
	"MountUp",
	"TakeOff",
	"FlyHigher",
	"SurgeForward",
	"LookAround",
	"Land"
);

Class_Dragonriding_RPE_Watcher = class("Dragonriding_RPE_Watcher", Class_TutorialBase);

function Class_Dragonriding_RPE_Watcher:StartWatching()
	-- nop
end

function Class_Dragonriding_RPE_Watcher:Activate()
	if C_QuestLog.IsQuestFlaggedCompleted(DRAGONRIDING_QUEST_ID) then
		return;
	end

	EventRegistry:RegisterFrameEventAndCallback("QUEST_ACCEPTED", self.OnQuestAccepted, self);

	if C_QuestLog.IsOnQuest(DRAGONRIDING_QUEST_ID) then
		self:StartTutorial();
	end
end

function Class_Dragonriding_RPE_Watcher:Deactivate()
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_ACCEPTED", self);
	self:HideTutorialFrames();
end

function Class_Dragonriding_RPE_Watcher:StartTutorial()
	EventRegistry:RegisterCallback("CollectionsJournal.OnShow", self.OnCollectionsJournalOnShow, self);
	EventRegistry:RegisterCallback("CollectionsJournal.TabSet", self.OnCollectionsJournalTabSet, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_IS_GLIDING_CHANGED", self.OnPlayerGlidingChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_CAN_GLIDE_CHANGED", self.OnPlayerCanGlideChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("UNIT_SPELLCAST_SUCCEEDED", self.OnUnitSpellcastSucceeded, self);
	EventRegistry:RegisterFrameEventAndCallback("QUEST_REMOVED", self.OnQuestRemoved, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_STOPPED_TURNING", self.OnPlayerStoppedTurning, self);
	EventRegistry:RegisterFrameEventAndCallback("ACTIONBAR_SLOT_CHANGED", self.OnActionBarSlotChanged, self);

	local isGliding, canGlide = C_PlayerInfo.GetGlidingInfo();
	if isGliding then
		self.step = DragonridingTutorialStep.FlyHigher;
	elseif canGlide then
		self.step = DragonridingTutorialStep.TakeOff;
	else
		local actionButton = self:GetMountActionButton();
		if actionButton then
			self.step = DragonridingTutorialStep.MountUp;
		else
			self.step = DragonridingTutorialStep.OpenMountJournal;
		end
	end
	self:EvaluateStep();
end

function Class_Dragonriding_RPE_Watcher:StopTutorial()
	self:HideTutorialFrames();
	self.step = nil;

	EventRegistry:UnregisterCallback("CollectionsJournal.Show", self);
	EventRegistry:UnregisterCallback("CollectionsJournal.TabSet", self);
	EventRegistry:UnregisterCallback("MountJournal.OnHide", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_IS_GLIDING_CHANGED", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_CAN_GLIDE_CHANGED", self);
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_SPELLCAST_SUCCEEDED", self);
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_REMOVED", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_STOPPED_TURNING", self);
	EventRegistry:UnregisterFrameEventAndCallback("ACTIONBAR_SLOT_CHANGED", self);
end

function Class_Dragonriding_RPE_Watcher:HideTutorialFrames()
	-- There can only be 1 tutorial frame tracked so trying to hide one that's not visible will blow away the info anyway,
	-- causing the call for the displayed frame to fail to hide it, so make the appropriate call per step.
	if self.step == DragonridingTutorialStep.TakeOff then
		self:HideDoubleKeyTutorial();
	elseif self.step == DragonridingTutorialStep.FlyHigher or self.step == DragonridingTutorialStep.SurgeForward then
		self:HideSingleKeyTutorial();
	else
		self:HideScreenTutorial();
	end
	TutorialDragButton:Hide();
	self:HidePointerTutorials();
end

function Class_Dragonriding_RPE_Watcher:AdvanceStep()
	if self.step then
		self.step = self.step + 1;
		self:EvaluateStep();
	end
end

function Class_Dragonriding_RPE_Watcher:OnQuestAccepted(questID)
	if questID == DRAGONRIDING_QUEST_ID then
		self:StartTutorial();
	end
end

function Class_Dragonriding_RPE_Watcher:OnActionBarSlotChanged()
	if self.step == DragonridingTutorialStep.DragMount then
		self:AdvanceStep();
	end
end

function Class_Dragonriding_RPE_Watcher:OnCollectionsJournalOnShow(tabID)
	if self.step == DragonridingTutorialStep.OpenMountJournal then
		-- Select Mounts tab
		local mountsTabID = CollectionsJournal.MountsTab:GetID();
		if tabID ~= mountsTabID then
			CollectionsJournal_SetTab(CollectionsJournal, mountsTabID);
		end
		-- Change filter to only Collected and Flying, and reset to all sources.
		-- DefaultFilters will do most of the work, turn off what's unwanted afterwards.
		C_MountJournal.SetDefaultFilters();
		C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, false);
		for filterIndex = 1, Enum.MountTypeMeta.NumValues do
			if C_MountJournal.IsValidTypeFilter(filterIndex) then
				local mountType = filterIndex - 1;
				if mountType ~= Enum.MountType.Flying then
					C_MountJournal.SetTypeFilter(filterIndex, false);
				end
			end
		end
		MountJournal.FilterDropdown:ValidateResetState();

		self:AdvanceStep();
	elseif self.step == DragonridingTutorialStep.DragMount then
		self:ShowDragMountTutorial();
	end
end

function Class_Dragonriding_RPE_Watcher:OnMountJournalOnHide()
	TutorialDragButton:Hide();
	self:HidePointerTutorials();
end

function Class_Dragonriding_RPE_Watcher:OnCollectionsJournalTabSet(journal, tabID)
	if self.step == DragonridingTutorialStep.DragMount then
		local mountsTabID = CollectionsJournal.MountsTab:GetID();
		if tabID == mountsTabID and self.step == DragonridingTutorialStep.DragMount then
			self:ShowDragMountTutorial();
		end
	end
end

function Class_Dragonriding_RPE_Watcher:OnPlayerGlidingChanged(isGliding)
	if isGliding and self.step == DragonridingTutorialStep.TakeOff then
		self:AdvanceStep();
	elseif not isGliding and self.step == DragonridingTutorialStep.Land then
		self:AdvanceStep();
	else
		if isGliding then
			self:EvaluateStep();
		else
			self:HideTutorialFrames();
		end
	end
end

function Class_Dragonriding_RPE_Watcher:OnPlayerCanGlideChanged(canGlide)
	if canGlide and self.step == DragonridingTutorialStep.MountUp then
		self:AdvanceStep();
	elseif self.step == DragonridingTutorialStep.TakeOff then
		if canGlide then
			self:ShowTakeOffTutorial();
		else
			self:HideDoubleKeyTutorial();
		end
	end
end

function Class_Dragonriding_RPE_Watcher:OnUnitSpellcastSucceeded(_unit, _cast, spellID)
	if self.step == DragonridingTutorialStep.FlyHigher and spellID == SPELL_SKYWARD_ASCENT then
		self:AdvanceStep();
	elseif self.step == DragonridingTutorialStep.SurgeForward and spellID == SPELL_SURGE_FORWARD then
		self:AdvanceStep();
	end
end

function Class_Dragonriding_RPE_Watcher:OnPlayerStoppedTurning()
	if self.step == DragonridingTutorialStep.LookAround then
		local isGliding = C_PlayerInfo.GetGlidingInfo();
		if isGliding then
			self:AdvanceStep();
		end
	end
end

function Class_Dragonriding_RPE_Watcher:OnQuestRemoved(questID)
	if questID == DRAGONRIDING_QUEST_ID then
		self:StopTutorial();
	end
end

function Class_Dragonriding_RPE_Watcher:ShowTakeOffTutorial()
	local key = TutorialHelper:GetMapBinding();
	local bindingString = GetBindingKey("JUMP");
	local content = { text = RPE_SKYRIDING_TAKE_OFF, icon = nil, keyText1 = bindingString, keyText2 = bindingString, separator = RPE_SKYRIDING_COMMA };
	self:ShowDoubleKeyTutorial(content);
end

function Class_Dragonriding_RPE_Watcher:ShowDragMountTutorial()
	if not MountJournal:IsShown() then
		return;
	end

	local scrollBoxFrames = MountJournal.ScrollBox:GetFrames();
	local targetFrame = scrollBoxFrames and scrollBoxFrames[1];
	local actionButton = targetFrame and TutorialHelper:FindEmptyButton();
	if actionButton then
		TutorialDragButton:Hide();
		TutorialDragButton:Show(targetFrame, actionButton);
	end

	if targetFrame then
		local overrideMaxWidth = 400;
		self:ShowPointerTutorial(RPE_SKYRIDING_DRAG_MOUNT_HELPTIP, "DOWN", targetFrame, 0, 0, nil, "LEFT", overrideMaxWidth);
	end
end

function Class_Dragonriding_RPE_Watcher:EvaluateStep()
	if self.step == DragonridingTutorialStep.OpenMountJournal then
		self:ShowPointerTutorial(RPE_SKYRIDING_COLLECTIONS_HELPTIP, "DOWN", CollectionsMicroButton, 0, 0, nil, "DOWN");
	elseif self.step == DragonridingTutorialStep.DragMount then
		self:ShowDragMountTutorial();
		-- because OnHide is not synchronous
		RunNextFrame(function()
			EventRegistry:RegisterCallback("MountJournal.OnHide", self.OnMountJournalOnHide, self);
		end);
	elseif self.step == DragonridingTutorialStep.MountUp then
		TutorialDragButton:Hide();
		self:HidePointerTutorials();
		local content = { text = RPE_SKYRIDING_MOUNT_UP };
		self:ShowScreenTutorial(content);
	elseif self.step == DragonridingTutorialStep.TakeOff then
		self:HideScreenTutorial();
		self:ShowTakeOffTutorial();
	elseif self.step == DragonridingTutorialStep.FlyHigher then
		self:HideDoubleKeyTutorial();
		local bindingString = GetBindingKey("JUMP");
		local content = { text = RPE_SKYRIDING_FLY_HIGHER, icon = nil, keyText = bindingString };
		self:ShowSingleKeyTutorial(content);
	elseif self.step == DragonridingTutorialStep.SurgeForward then
		local shown = false;
		local btn = TutorialHelper:GetActionButtonBySpellID(SPELL_SURGE_FORWARD);
		if btn then
			local base = (NUM_ACTIONBAR_PAGES + GetBonusBarOffset() - 1) * NUM_ACTIONBAR_BUTTONS;
			local action = btn.action;
			if action > base then
				action = action - base;
				local bindingString = GetBindingKey("ACTIONBUTTON" .. action);
				if bindingString then
					local content = { text = RPE_SKYRIDING_SURGE_FORWARD, icon = nil, keyText = bindingString };
					self:ShowSingleKeyTutorial(content);
					shown = true;
				end
			end
		end

		if not shown then
			-- Weird action bar setup, just skip this tutorial
			self:AdvanceStep();
		end
	elseif self.step == DragonridingTutorialStep.LookAround then
		self:HideSingleKeyTutorial();
		-- 30% atlas size
		local content = { text = RPE_SKYRIDING_STEER, icon = "newplayertutorial-icon-mouse-multi-turn", iconWidth = 228 * 0.3, iconHeight = 250 * 0.3 };
		self:ShowScreenTutorial(content);
	elseif self.step == DragonridingTutorialStep.Land then
		local atlas ="newplayertutorial-icon-mouse-down";
		if GetCVarBool("mouseInvertPitch") then
			atlas ="newplayertutorial_icon_mouse_up";
		end
		-- 30% atlas size
		local content = { text = RPE_SKYRIDING_LAND, icon = atlas, iconWidth = 152 * 0.3, iconHeight = 222 * 0.3 };
		self:ShowScreenTutorial(content);
	elseif self.step then
		-- advanced past the last step
		self:StopTutorial();
	end
end

function Class_Dragonriding_RPE_Watcher:GetMountActionButton()
	local foundButton = nil;
	local mounts = C_MountJournal.GetCollectedDragonridingMounts();
	local mountsByID = tInvert(mounts);
	ActionBarButtonEventsFrame:ForEachFrame(function(actionButton)
		if actionButton:IsVisible() then
			local type, id = GetActionInfo(actionButton.action);
			if type == "summonmount" and mountsByID[id] then
				foundButton = actionButton;
			end
		end
	end);
	return foundButton;
end
