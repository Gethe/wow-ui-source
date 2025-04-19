TutorialStateMachineMixin = {};

function TutorialStateMachineMixin:AddState(stateName, onBegin, onEnd)
	if not self.states then
		self.states = {};
	end

	self.states[stateName] = { onBegin = onBegin, onEnd = onEnd };
end

function TutorialStateMachineMixin:SetInitialStateName(initialStateName)
	self.initialStateName = initialStateName;
end

function TutorialStateMachineMixin:GetInitialStateName()
	return self.initialStateName;
end

function TutorialStateMachineMixin:BeginState(stateName, ...)
	self:Deactivate();

	if self:CallStateTransition(stateName, "onBegin", ...) then
		self.activeStateName = stateName;
	end
end

function TutorialStateMachineMixin:BeginInitialState()
	self:BeginState(self:GetInitialStateName());
end

function TutorialStateMachineMixin:GetActiveStateName()
	return self.activeStateName;
end

function TutorialStateMachineMixin:Deactivate()
	local activeState = self.activeStateName;
	self.activeStateName = nil;
	if activeState then
		self:CallStateTransition(activeState, "onEnd");
	end
end

function TutorialStateMachineMixin:GetState(stateName)
	return self.states and self.states[stateName];
end

function TutorialStateMachineMixin:CallStateTransition(stateName, stateTransitionKey, ...)
	local state = self:GetState(stateName);
	if state then
		self[state[stateTransitionKey]](self, ...);
		return true;
	end

	return false;
end