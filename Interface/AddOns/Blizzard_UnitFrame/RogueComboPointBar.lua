local DefaultMaxPoints = 5;	-- Default number of max points for normal layout handling
local DefaultLeftPadding = 0;	-- Padding to use while at or below DefaultMaxPoints
local LeftPaddingPerPointOverDefault = -20;	-- Padding to add for each max point above DefaultMaxPoints

RogueComboPointBarMixin = {};

function RogueComboPointBarMixin:UpdatePower()
	local unit = self:GetUnit();
	local comboPoints = UnitPower(unit, self.powerType);
	local chargedPowerPoints = GetUnitChargedPowerPoints(unit);
	for i = 1, #self.classResourceButtonTable do
		local isFull = i <= comboPoints;
		local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, i) or false;

		self.classResourceButtonTable[i]:Update(isFull, isCharged);
	end
end

function RogueComboPointBarMixin:UpdateChargedPowerPoints()
	self:UpdatePower();
end

function RogueComboPointBarMixin:UpdateMaxPower()
	local maxPoints = UnitPowerMax(self:GetUnit(), self.powerType);
	if maxPoints <= DefaultMaxPoints then
		self.leftPadding = DefaultLeftPadding;
	else
		local pointsOverDefault = maxPoints - DefaultMaxPoints;
		self.leftPadding = pointsOverDefault * LeftPaddingPerPointOverDefault;
	end

	ClassResourceBarMixin.UpdateMaxPower(self);
end


RogueComboPointMixin = {};

function RogueComboPointMixin:Setup()
	self.isFull = nil;
	self.isCharged = nil;
	self:ResetVisuals();
	self:Show();
end

function RogueComboPointMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	FramePool_HideAndClearAnchors(framePool, self);
end

function RogueComboPointMixin:Update(isFull, isCharged)
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
		self[transitionAnim]:Restart();
	end
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