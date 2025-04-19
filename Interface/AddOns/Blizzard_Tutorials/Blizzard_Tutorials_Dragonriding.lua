
function AddDragonridingTutorials()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_DRAGON_RIDING_ACTIONBAR) then
		TutorialManager:AddWatcher(Class_DragonRidingWatcher:new(), true);
	end
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
		HelpTip:Show(UIParent, self.helpTipInfo, MainMenuBar);
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
