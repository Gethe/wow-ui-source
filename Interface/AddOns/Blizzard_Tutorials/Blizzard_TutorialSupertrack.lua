local SupertrackTutorialMixin = CreateFromMixins(StateMachineBasedTutorialMixin);

function SupertrackTutorialMixin:Init()
	self:AddState("ListenForNothingSupertracked", "StartPhase_ListenForNothingSupertracked", "StopPhase_ListenForNothingSupertracked");
	self:AddState("TryShowingTutorial", "StartPhase_TryShowingTutorial", "StopPhase_TryShowingTutorial");

	self:SetInitialStateName("ListenForNothingSupertracked");
	self:SetTutorialFlagType("closedInfoFrames", LE_FRAME_TUTORIAL_HOW_TO_SUPERTRACK);
end

function SupertrackTutorialMixin:StartPhase_ListenForNothingSupertracked()
	-- In addition to starting to listen, check to see if we should start the tutorial timer.
	self:CheckStartTutorialTimer();
	EventRegistry:RegisterCallback("Supertracking.OnChanged", self.OnSuperTrackingChanged, self);
end

function SupertrackTutorialMixin:StopPhase_ListenForNothingSupertracked()
	EventRegistry:UnregisterCallback("Supertracking.OnChanged", self);
end

function SupertrackTutorialMixin:OnSuperTrackingChanged()
	self:CheckStartTutorialTimer();
end

function SupertrackTutorialMixin:CheckStartTutorialTimer()
	if C_SuperTrack.IsSuperTrackingAnything() then
		self:StopTimer();

		-- If the user changed to actively supertrack something while the tutorial was showing, then mark the tutorial as acknowledged
		if self:IsShowingTutorialHelp() then
			self:AcknowledgeTutorial();
		end
	else
		self:StartTimer();
	end
end

function SupertrackTutorialMixin:StartTimer()
	self:StopTimer();
	self.Timer = C_Timer.NewTimer(120, function() self:TryShowSupertrackTutorial() end);
end

function SupertrackTutorialMixin:StopTimer()
	if self.Timer then
		self.Timer:Cancel();
	end

	self.Timer = nil;
end

function SupertrackTutorialMixin:TryShowSupertrackTutorial()
	self:StopTimer();

	local target = self:FindTutorialTargetFrame();
	if target and target:IsVisible() then
		local helpTipInfo = {
			text = TUTORIAL_SUPERTRACK_STEP_1,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			autoEdgeFlipping = true,
			autoHideWhenTargetHides = true,
			system = self:GetSystem(),
			callbackArg = self,
			onAcknowledgeCallback = self.AcknowledgeTutorial,
			onHideCallback = function(acknowledged, arg, reason) self:OnTutorialHidden(reason); end,
		};

		HelpTip:Show(UIParent, helpTipInfo, target);
	else
		self:BeginInitialState();
	end
end

function SupertrackTutorialMixin:FindTutorialTargetFrame()
	local targetFrame;
	local targetTop = 0;
	local function blockCallback(block)
		if block.poiButton then
			local top = block.poiButton:GetTop();
			if not targetFrame or top > targetTop then
				targetFrame = block.poiButton;
				targetTop = targetFrame:GetTop() or 0;
			end
		end
	end

	ObjectiveTrackerManager:EnumerateActiveBlocksByTag("quest", blockCallback);
	return targetFrame;
end

function SupertrackTutorialMixin:IsComplete()
	return self:IsTutorialFlagSet()
end

function SupertrackTutorialMixin:GetSystem()
	return "TutorialSupertracking";
end

function SupertrackTutorialMixin:AcknowledgeTutorial()
	if self:IsShowingTutorialHelp() then
		HelpTip:HideAllSystem(self:GetSystem());
	end

	StateMachineBasedTutorialMixin.AcknowledgeTutorial(self);
end

local function CheckBeginTutorial()
	TutorialManager:CheckHasCompletedFrameTutorial(LE_FRAME_TUTORIAL_HOW_TO_SUPERTRACK, function(hasCompletedTutorial)
		if not hasCompletedTutorial then
			CreateAndInitFromMixin(SupertrackTutorialMixin):BeginInitialState();
		end
	end);
end

function SupertrackTutorialMixin:OnTutorialHidden(reason)
	if reason == HelpTip.HideReason.TargetHidden then
		CheckBeginTutorial();
	end
end

EventRegistry:RegisterCallback("TutorialManager.TutorialsEnabled", CheckBeginTutorial);
EventRegistry:RegisterCallback("TutorialManager.TutorialsReset", CheckBeginTutorial);
CheckBeginTutorial();