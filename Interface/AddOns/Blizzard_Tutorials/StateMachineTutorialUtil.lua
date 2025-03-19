StateMachineBasedTutorialMixin = CreateFromMixins(TutorialStateMachineMixin);

function StateMachineBasedTutorialMixin:AcknowledgeTutorial()
	local forceComplete = true;
	self:CheckComplete(forceComplete);
end

function StateMachineBasedTutorialMixin:IsComplete()
	-- override as necessary
	return false;
end

function StateMachineBasedTutorialMixin:CheckComplete(forceComplete)
	if forceComplete or self:IsComplete() then
		self:MarkTutorialComplete();
		self:Deactivate();
	end
end

function StateMachineBasedTutorialMixin:RestartTutorial()
	HelpTip:HideAllSystem(self:GetSystem());
	self:BeginInitialState();
end

function StateMachineBasedTutorialMixin:SetTutorialFlagType(cvar, flag)
	self.cvar = cvar;
	self.cvarFlag = flag;
end

function StateMachineBasedTutorialMixin:GetTutorialCVar()
	return self.cvar;
end

function StateMachineBasedTutorialMixin:GetTutorialFlag()
	return self.cvarFlag;
end

function StateMachineBasedTutorialMixin:IsTutorialFlagSet()
	if EventUtil.AreVariablesLoaded() then
		local hasCompleted = GetCVarBitfield(self:GetTutorialCVar(), self:GetTutorialFlag());
		return hasCompleted;
	end

	return false;
end

function StateMachineBasedTutorialMixin:MarkTutorialComplete()
	-- override as necessary
	SetCVarBitfield(self:GetTutorialCVar(), self:GetTutorialFlag(), true);
end

function StateMachineBasedTutorialMixin:GetSystem()
	-- override as necessary
	return nil;
end

function StateMachineBasedTutorialMixin:IsShowingTutorialHelp()
	return HelpTip:IsShowingAnyInSystem(self:GetSystem());
end