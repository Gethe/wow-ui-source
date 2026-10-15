RogueComboPointMixin = {};

function RogueComboPointMixin:Setup()
	self.isFull = nil;
	self.isCharged = nil;
	self:ResetVisuals();
	self:Show();
end

function RogueComboPointMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	Pool_HideAndClearAnchors(framePool, self);
end

function RogueComboPointMixin:Update(isFull, isCharged, suppressTransition)
	if self.isFull == isFull and self.isCharged == isCharged then
		return;
	end

	local wasFull = self.isFull ~= nil and self.isFull or false;
	local wasCharged = self.isCharged ~= nil and self.isCharged or false;
	self.isFull = isFull;
	self.isCharged = isCharged;

	self:ResetVisuals();

	local transitionAnim = RogueComboPointTransitions.GetTransitionAnim(wasCharged, wasFull, isCharged, isFull);
	if transitionAnim then
		if suppressTransition then
			self[transitionAnim]:Play();
			self[transitionAnim]:Finish();
		else
			self[transitionAnim]:Restart();
		end
	end
end

-- Adapter for callers that pass only filled state.
function RogueComboPointMixin:SetActive(isActive)
	self:Update(isActive, false);
end

function RogueComboPointMixin:SetActiveNoAnimation(isActive)
	if self.isFull == isActive and self.isCharged == false then
		return;
	end

	self.isFull = isActive;
	self.isCharged = false;
	self:ResetVisuals();

	local instantTransition = isActive and self.instantUnchargedFull or self.instantUnchargedEmpty;
	instantTransition:Play();
	instantTransition:Finish();
end

function RogueComboPointMixin:ResetVisuals()
	for _, transitionAnim in ipairs(self.transitionAnims) do
		transitionAnim:Stop();
	end

	for _, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAlpha(0);
	end
end

RogueComboPointTransitions = {};

function RogueComboPointTransitions.Init()
	-- Using an Init func allows us to use these local named bools and make this big thing more readable
	local uncharged, charged = false, true;
	local empty, full = false, true;
	RogueComboPointTransitions.transitions = {
		{ from = {uncharged, empty}, to = {uncharged, empty}, anim = "unchargedEmpty" },

		{ from = {uncharged, empty}, to = {uncharged, full}, anim = "unchargedEmptyToUnchargedFull" },
		{ from = {uncharged, empty}, to = {charged, full}, anim = "unchargedEmptyToChargedFull" },
		{ from = {uncharged, empty}, to = {charged, empty}, anim = "unchargedEmptyToChargedEmpty" },

		{ from = {charged, empty}, to = {charged, full}, anim = "chargedEmptyToChargedFull" },
		{ from = {charged, empty}, to = {uncharged, full}, anim = "chargedEmptyToUnchargedFull" },
		{ from = {charged, empty}, to = {uncharged, empty}, anim = "chargedEmptyToUnchargedEmpty" },

		{ from = {uncharged, full}, to = {uncharged, empty}, anim = "unchargedFullToUnchargedEmpty" },
		{ from = {uncharged, full}, to = {charged, full}, anim = "unchargedFullToChargedFull" },
		{ from = {uncharged, full}, to = {charged, empty}, anim = "unchargedFullToChargedEmpty" },

		{ from = {charged, full}, to = {charged, empty}, anim = "chargedFullToChargedEmpty" },
		{ from = {charged, full}, to = {uncharged, empty}, anim = "chargedFullToUnchargedEmpty" },
		{ from = {charged, full}, to = {uncharged, full}, anim = "chargedFullToUnchargedFull" },
	};
end

function RogueComboPointTransitions.GetTransitionAnim(fromIsCharged, fromIsFull, toIsCharged, toIsFull)
	if not RogueComboPointTransitions.transitions then
		RogueComboPointTransitions.Init();
	end

	local function stateMatches(state, isCharged, isFull)
		return state[1] == isCharged and state[2] == isFull;
	end
	for _, transition in ipairs(RogueComboPointTransitions.transitions) do
		if stateMatches(transition.from, fromIsCharged, fromIsFull) and stateMatches(transition.to, toIsCharged, toIsFull) then
			return transition.anim;
		end
	end
	return nil;
end
