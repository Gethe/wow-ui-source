EvokerEbonMightBarMixin = {}

-- Ebon Might Spell that applies Aura on Self
local EbonMightSelfAuraSpellID = 395296;
-- Design-specified, useful visual range from testing, roughly based on upper potential duration range
local EbonMightDisplayMax = 20;

function EvokerEbonMightBarMixin:Initialize()
	-- Supporting units other than current player will complicate tracking, so explicitly limit support until we want that
	self.unit = "player";
	self.requiredClass = "EVOKER";
	self.requiredSpec = SPEC_EVOKER_AUGMENTATION;
	self.frequentUpdates = true;
	-- Numeric status text only - bar is a timer with an arbitrary max, percentages aren't meaningful
	self.disablePercentages = true;

	self.auraExpirationTime = nil;

	-- Customize how numeric status text values are formatted by TextStatusBar
	self.numericDisplayTransformFunc = function(value, valueMax)
		local valueDisplay = value;
		local valueMaxDisplay = valueMax;

		if value ~= 0 and value ~= EbonMightDisplayMax then
			-- Limit display number to 1 floating point digit
			valueDisplay = RoundToSignificantDigits(valueDisplay, 1);
			-- Format ensures value of "1" will display "1.0" to prevent text width thrashing
			valueDisplay = string.format("%.1f", valueDisplay);
		end
		
		return valueDisplay, valueMaxDisplay;
	end;

	self.baseMixin.Initialize(self);
end

function EvokerEbonMightBarMixin:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		local unitToken, auraUpdateInfo = ...;
		self:OnUnitAuraUpdate(unitToken, auraUpdateInfo);
	end

	self.baseMixin.OnEvent(self, event, ...);
end

function EvokerEbonMightBarMixin:OnUnitAuraUpdate(unitToken, unitAuraUpdateInfo)
	if unitToken ~= self:GetUnit() or unitAuraUpdateInfo == nil then
		return;
	end

	-- It's possible for UI to get a UNIT_AURA event with no update info, avoid reacting to that
	local isUpdatePopulated = unitAuraUpdateInfo.isFullUpdate
		or (unitAuraUpdateInfo.addedAuras ~= nil and #unitAuraUpdateInfo.addedAuras > 0)
		or (unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil and #unitAuraUpdateInfo.removedAuraInstanceIDs > 0)
		or (unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil and #unitAuraUpdateInfo.updatedAuraInstanceIDs > 0);

	if isUpdatePopulated then
		self:UpdateAuraState();
	end
end

function EvokerEbonMightBarMixin:UpdateAuraState()
	local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(EbonMightSelfAuraSpellID);

	local auraExpirationTime = auraInfo and auraInfo.expirationTime or nil;

	if auraExpirationTime ~= self.auraExpirationTime then
		self.auraExpirationTime = auraExpirationTime;
		self:UpdatePower();
	end
end

function EvokerEbonMightBarMixin:EvaluateUnit()
	local meetsRequirements = false;

	local _, class = UnitClass(self:GetUnit());
	meetsRequirements = class == self.requiredClass and GetSpecialization() == self.requiredSpec;

	self:SetBarEnabled(meetsRequirements);
end

function EvokerEbonMightBarMixin:OnBarEnabled()
	self:RegisterEvent("UNIT_AURA");

	self:UpdateArt();
	self:UpdateMinMaxPower();
	self:UpdateAuraState();
end

function EvokerEbonMightBarMixin:OnBarDisabled()
	self:UnregisterEvent("UNIT_AURA");

	self.auraExpirationTime = nil;
end

function EvokerEbonMightBarMixin:GetCurrentPower()
	if not self.auraExpirationTime then
		return 0;
	end

	return self.auraExpirationTime - GetTime();
end

function EvokerEbonMightBarMixin:GetCurrentMinMaxPower()
	return 0, EbonMightDisplayMax;
end


PlayerFrameEvokerEbonMightBarMixin = {};

function PlayerFrameEvokerEbonMightBarMixin:Initialize()
	self.OverflowFill:AddMaskTexture(self.PowerBarMask);
	EvokerEbonMightBarMixin.Initialize(self);
end

function PlayerFrameEvokerEbonMightBarMixin:UpdatePower()
	self.baseMixin.UpdatePower(self);

	local shouldShowOverflow = self.currentPower and self.currentPower >= self.maxPower;
	self:SetOverflowVisualsActive(shouldShowOverflow);
end

function PlayerFrameEvokerEbonMightBarMixin:SetOverflowVisualsActive(active)
	local areVisualsActive = self.OverflowCap:IsShown() or self.overflowAnim:IsPlaying();
	if areVisualsActive == active then
		return;
	end

	self.OverflowCap:SetShown(active);
	self.OverflowFill:SetShown(active);

	if active then
		self.overflowAnim:Restart();
	else
		self.overflowAnim:Stop();
	end
end

function PlayerFrameEvokerEbonMightBarMixin:OnBarDisabled()
	EvokerEbonMightBarMixin.OnBarDisabled(self);
	self:SetOverflowVisualsActive(false);
end