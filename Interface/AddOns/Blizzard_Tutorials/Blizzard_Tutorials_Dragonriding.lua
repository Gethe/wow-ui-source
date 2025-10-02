local RPE_MAP_ID = 2927;
local RPE_QUEST_ID = 90883;

function AddDragonridingTutorials()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRAGON_RIDING_ACTIONBAR) then
		TutorialManager:AddWatcher(Class_DragonRidingWatcher:new(), true);
	end
end

function AddDragonridingRPETutorials()
	if not TutorialManager:GetWatcher("DragonRiding_RPE_Watcher") then
		local mapID = GetMapID();
		if mapID == RPE_MAP_ID then
			TutorialManager:AddWatcher(Class_Dragonriding_RPE_Watcher:new(), true);
		end
	end
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
		AddDragonridingRPETutorials();
	end, Class_Dragonriding_RPE_Watcher);
end

-- ------------------------------------------------------------------------------------------------------------
-- Dragonriding Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_DragonRidingWatcher = class("DragonRidingWatcher", Class_TutorialBase);
function Class_DragonRidingWatcher:OnInitialize()
	self.helpTipInfo = {
		text = DRAGON_RIDING_ACTIONBAR_TUTORIAL,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_DRAGON_RIDING_ACTIONBAR,
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		onAcknowledgeCallback = GenerateClosure(self.FinishTutorial, self),
		acknowledgeOnHide = false,
	};
end

function Class_DragonRidingWatcher:StartWatching()
	EventRegistry:RegisterFrameEventAndCallback("UPDATE_BONUS_ACTIONBAR", self.OnUpdateBonusActionBar, self);
end

function Class_DragonRidingWatcher:OnUpdateBonusActionBar()
	local bonusBarIndex = GetBonusBarIndex();
	--Dragon riding bar is 11
	if bonusBarIndex == 11 then
		HelpTip:Show(UIParent, self.helpTipInfo, MainActionBar);
	else
		HelpTip:Hide(UIParent, DRAGON_RIDING_ACTIONBAR_TUTORIAL);
	end
end

function Class_DragonRidingWatcher:StopWatching()
	EventRegistry:UnregisterFrameEventAndCallback("UPDATE_BONUS_ACTIONBAR", self);
end

function Class_DragonRidingWatcher:FinishTutorial()
	TutorialManager:StopWatcher(self:Name(), true);
end

-- ------------------------------------------------------------------------------------------------------------
-- Dragonriding RPE Watcher
-- ------------------------------------------------------------------------------------------------------------

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

Class_Dragonriding_RPE_Watcher = class("DragonRiding_RPE_Watcher", Class_ChangeSpec);

function Class_Dragonriding_RPE_Watcher:StartWatching()
	EventRegistry:RegisterFrameEventAndCallback("QUEST_ACCEPTED", self.OnQuestAccepted, self);
	local inLog = C_QuestLog.GetLogIndexForQuestID(RPE_QUEST_ID);
	if inLog then
		self:StartTutorial();
	end
end

function Class_Dragonriding_RPE_Watcher:StartTutorial()
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_IS_GLIDING_CHANGED", self.OnPlayerGlidingChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("UNIT_SPELLCAST_SUCCEEDED", self.OnUnitSpellcastSucceeded, self);
	EventRegistry:RegisterFrameEventAndCallback("QUEST_REMOVED", self.OnQuestRemoved, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_STOPPED_TURNING", self.OnPlayerStoppedTurning, self);

	--[[ RPE_TODO: Implement the steps for mounting a flying mount
	local isGliding, canGlide = C_PlayerInfo.GetGlidingInfo();
	if canGlide then
		self.step = DragonridingTutorialStep.TakeOff;
	else
		local actionButton = self:GetMountActionButton();
		if actionButton then
			self.step = DragonridingTutorialStep.MountUp;
		else
			self.step = DragonridingTutorialStep.OpenMountJournal;
		end
	end
	]]--

	local isGliding = C_PlayerInfo.GetGlidingInfo();
	if isGliding then
		self.step = DragonridingTutorialStep.FlyHigher;
	else
		self.step = DragonridingTutorialStep.TakeOff;
	end
	self:EvaluateStep();
end

function Class_Dragonriding_RPE_Watcher:StopTutorial()
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_IS_GLIDING_CHANGED", self);
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_SPELLCAST_SUCCEEDED", self);
	EventRegistry:UnregisterFrameEventAndCallback("QUEST_REMOVED", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_STOPPED_TURNING", self);
	self:HideTutorialFrames();
	self.step = nil;
end

function Class_Dragonriding_RPE_Watcher:HideTutorialFrames()
	-- There can only be 1 tutorial frame tracked so trying to hide one that's not visible will blow away the info anyway
	if self.step == DragonridingTutorialStep.TakeOff then
		self:HideDoubleKeyTutorial();
	elseif self.step == DragonridingTutorialStep.FlyHigher or self.step == DragonridingTutorialStep.SurgeForward then
		self:HideSingleKeyTutorial();
	else
		self:HideScreenTutorial();
	end
end

function Class_Dragonriding_RPE_Watcher:AdvanceStep()
	if self.step then
		self.step = self.step + 1;
		self:EvaluateStep();
	end
end

function Class_Dragonriding_RPE_Watcher:OnQuestAccepted(questID)
	if questID == RPE_QUEST_ID then
		self:StartTutorial();
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
	if questID == RPE_QUEST_ID then
		self:StopTutorial();
	end
end

function Class_Dragonriding_RPE_Watcher:EvaluateStep()
	if self.step == DragonridingTutorialStep.OpenMountJournal then
	elseif self.step == DragonridingTutorialStep.DragMount then
	elseif self.step == DragonridingTutorialStep.MountUp then
	elseif self.step == DragonridingTutorialStep.TakeOff then
		local key = TutorialHelper:GetMapBinding();
		local bindingString = GetBindingKey("JUMP");
		local content = { text = RPE_SKYRIDING_TAKE_OFF, icon = nil, keyText1 = bindingString, keyText2 = bindingString, separator = RPE_SKYRIDING_COMMA };
		self:ShowDoubleKeyTutorial(content);
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
