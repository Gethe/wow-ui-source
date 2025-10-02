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

HelpTipStateMachineBasedTutorialMixin = CreateFromMixins(StateMachineBasedTutorialMixin);

function HelpTipStateMachineBasedTutorialMixin:Init(helpTipInfos, helpTipSystemName, states, initialState, bitfield, bitfieldFlag)
	self.helpTipInfos = helpTipInfos;
	self.helpTipSystemName = helpTipSystemName;

	for _key, state in pairs(states) do
		-- Checking for the phase allows for specifying overrides to functionality
		local startPhase = "StartPhase_"..state;
		if not self[startPhase] then
			self[startPhase] = function(self)
				self:ShowHelpTipByState(state);
			end;
		end

		local stopPhase = "StopPhase_"..state;
		if not self[stopPhase] then
			self[stopPhase] = function(self)
				self:HideHelpTipByState(state);
			end;
		end

		self:AddState(state, startPhase, stopPhase);
	end

	self:SetInitialStateName(initialState);
	self:SetTutorialFlagType(bitfield, bitfieldFlag);
end

function HelpTipStateMachineBasedTutorialMixin:ShowHelpTipByState(stateName)
	local helpTipInfo = self.helpTipInfos[stateName];

	self.helpTipParent = helpTipInfo.parent;
	self.relativeRegion = helpTipInfo.relativeRegion or helpTipInfo.parent;
	HelpTip:Show(self.helpTipParent, helpTipInfo, self.relativeRegion);
end

function HelpTipStateMachineBasedTutorialMixin:HideHelpTipByState(stateName)
	HelpTip:Hide(self.helpTipParent, self.helpTipInfos[stateName].text);
	self.helpTipParent = nil;
end

function HelpTipStateMachineBasedTutorialMixin:IsComplete()
	return self:IsTutorialFlagSet();
end

function HelpTipStateMachineBasedTutorialMixin:GetSystem()
	return self.helpTipSystemName;
end

function HelpTipStateMachineBasedTutorialMixin:AcknowledgeTutorial()
	if self:IsShowingTutorialHelp() then
		HelpTip:HideAllSystem(self:GetSystem());
	end

	StateMachineBasedTutorialMixin.AcknowledgeTutorial(self);
end
