PropertyBindingMixin = {};

function PropertyBindingMixin:RegisterStateUpdateEvent(event, optionalCallback)
	self.stateUpdateEvents = self.stateUpdateEvents or {};
	self.stateUpdateEvents[event] = optionalCallback or self.UpdateVisibleState;
	self:RegisterEvent(event); -- NOTE: Depends on this being mixed into a frame
end

function PropertyBindingMixin:UnregisterStateUpdateEvent(event)
	local events = self.stateUpdateEvents;
	if events then
		events[event] = nil;
		self:UnregisterEvent(event); -- NOTE: Depends on this being mixed into a frame
	end
end

function PropertyBindingMixin:RegisterPropertyChangeHandler(event, optionalCallback)
	self.propertyChangeEvents = self.propertyChangeEvents or {};
	self.propertyChangeEvents[event] = optionalCallback or self.UpdateVisibleState;
end

function PropertyBindingMixin:UnregisterPropertyChangeHandler(event)
	local events = self.propertyChangeEvents;
	if events then
		self.propertyChangeEvents[event] = nil;
	end
end

do
	local function FireCallback(propertyBinding, call, ...)
		if call then
			-- TODO: Handle re-entrancy (cannot register, unregister at this point, need to queue)
			call(propertyBinding, ...);
		end
	end

	local function CheckFireCallback(propertyBinding, container, containerKey, ...)
		local call = container and container[containerKey];
		if call then
			FireCallback(propertyBinding, call, ...);
		end
	end

	-- NOTE: Depends on this being mixed into a frame
	function PropertyBindingMixin:OnEvent(event, ...)
		CheckFireCallback(self, self.stateUpdateEvents, event, ...);
	end

	function PropertyBindingMixin:OnPropertyChanged(event, ...)
		CheckFireCallback(self, self.propertyChangeEvents, event, ...);
	end
end

function PropertyBindingMixin:AddStateTooltipString(stateValue, tooltipString)
	self.tooltipStrings = self.tooltipStrings or {};
	self.tooltipStrings[stateValue] = tooltipString;
end

function PropertyBindingMixin:GetStateTooltipString(stateValue)
	return self.tooltipStrings and self.tooltipStrings[stateValue] or "";
end

function PropertyBindingMixin:SetTooltipFunction(tooltipFunction)
	self.tooltipFunction = tooltipFunction;
end

function PropertyBindingMixin:GetTooltipFunction()
	return self.tooltipFunction;
end

function PropertyBindingMixin:SetAccessorFunction(accessor)
	self.shouldPassSelfToAccessor = false;
	self.accessor = accessor;
end

function PropertyBindingMixin:SetAccessorFunctionThroughSelf(accessor)
	self.shouldPassSelfToAccessor = true;
	self.accessor = accessor;
end

function PropertyBindingMixin:SetMutatorFunction(mutator)
	self.shouldPassSelfToMutator = false;
	self.mutator = mutator;
end

function PropertyBindingMixin:SetMutatorFunctionThroughSelf(mutator)
	self.shouldPassSelfToMutator = true;
	self.mutator = mutator;
end

function PropertyBindingMixin:CallMutator(...)
	if self.shouldPassSelfToMutator then
		return self:mutator(...);
	else
		return self.mutator(...);
	end
end

function PropertyBindingMixin:CallAccessor(...)
	if self.shouldPassSelfToAccessor then
		return self:accessor(...);
	else
		return self.accessor(...);
	end
end

function PropertyBindingMixin:SetVisibilityQueryFunction(isVisible)
	assert(type(isVisible) == "function");
	self.isVisible = isVisible;
end

function PropertyBindingMixin:CallVisibilityQuery()
	if self.isVisible then
		return self:isVisible();
	end

	return true;
end

function PropertyBindingMixin:UpdateVisibleState()
	local show = self:CallVisibilityQuery();
	self:SetShown(show);
	return show;
end

function PropertyBindingMixin:SetTooltip(state)
	self.tooltipFrame:ClearLines();
	self.tooltipFrame:SetOwner(self, self.tooltipPoint or "ANCHOR_RIGHT");

	local tooltipFunction = self:GetTooltipFunction();
	local tooltipText = tooltipFunction and tooltipFunction(state) or self:GetStateTooltipString(state);

	GameTooltip_SetTitle(self.tooltipFrame, tooltipText);
	self.tooltipFrame:Show();
end

function PropertyBindingMixin:UpdateTooltipForState(state)
	if self.tooltipFrame and self.tooltipFrame:GetOwner() == self then
		self:SetTooltip(state);
	end
end

function PropertyBindingMixin:OnEnter()
	if self.tooltipFrame then
		self:SetTooltip(self:CallAccessor());
	end
end

function PropertyBindingMixin:OnLeave()
	if self.tooltipFrame then
		self.tooltipFrame:Hide();
	end
end