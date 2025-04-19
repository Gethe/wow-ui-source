ALT_POWER_BAR_PAIR_DISPLAY_INFO = {
	DRUID = {
		[Enum.PowerType.LunarPower] = { powerType = Enum.PowerType.Mana, powerName = "MANA" },
	},
	PRIEST = {
		[Enum.PowerType.Insanity] = { powerType = Enum.PowerType.Mana, powerName = "MANA" },
	},
	SHAMAN = {
		[Enum.PowerType.Maelstrom] = { powerType = Enum.PowerType.Mana, powerName = "MANA" },
	},
};

-- Basic alternate power bar for displaying a specific UnitPower type
-- Primarily intended to be the 3rd bar in a unit frame, beneath the unit's primary power bar
AlternatePowerBarMixin = {};

function AlternatePowerBarMixin:Initialize()
	self.frequentUpdates = true;

	self.baseMixin.Initialize(self);
end

function AlternatePowerBarMixin:OnEvent(event, ...)
	local unit = self:GetUnit();

	if event == "UNIT_MAXPOWER" then
		local unitToken = ...;
		if unitToken == unit then
			self:UpdateMinMaxPower();
		end
	elseif self.isEnabled and self:IsShown() then
		if event == "UNIT_POWER_UPDATE" then
			local unitToken = ...;
			if unitToken == unit then
				self:UpdatePower();
			end
		end
	end

	self.baseMixin.OnEvent(self, event, ...);
end

function AlternatePowerBarMixin:EvaluateUnit()
	local unit = self:GetUnit();
	local _, class = UnitClass(unit);

	local alternatePowerType, alternatePowerName = nil, nil;

	if ALT_POWER_BAR_PAIR_DISPLAY_INFO[class] then
		local primaryPowerType = UnitPowerType(unit);
		local alternatePowerInfo = ALT_POWER_BAR_PAIR_DISPLAY_INFO[class][primaryPowerType];
		if alternatePowerInfo then
			alternatePowerType = alternatePowerInfo.powerType;
			alternatePowerName = alternatePowerInfo.powerName;
		end
	end
	
	self.powerType = alternatePowerType;
	self.powerName = alternatePowerName;

	self:SetBarEnabled(self.powerType ~= nil and self.powerName ~= nil);
end

function AlternatePowerBarMixin:OnBarEnabled()
	self:RegisterEvent("UNIT_POWER_UPDATE");
	self:RegisterEvent("UNIT_MAXPOWER");

	self:UpdateArt();
	self:UpdateMinMaxPower();
	self:UpdatePower();
end

function AlternatePowerBarMixin:OnBarDisabled()
	self:UnregisterEvent("UNIT_POWER_UPDATE");
	self:UnregisterEvent("UNIT_MAXPOWER");
end

function AlternatePowerBarMixin:GetCurrentPower()
	return UnitPower(self:GetUnit(), self.powerType);
end

function AlternatePowerBarMixin:GetCurrentMinMaxPower()
	local maxPower = UnitPowerMax(self:GetUnit(), self.powerType);
	return 0, maxPower;
end