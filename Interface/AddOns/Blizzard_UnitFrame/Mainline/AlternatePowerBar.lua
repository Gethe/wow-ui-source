-- CLASS { [data primary power type] = { alt power type, alt power name }} 
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
	TRAVELER = {
		[Enum.PowerType.Mana] = { powerType = Enum.PowerType.Energy, powerName = "ENERGY" },
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

	-- SetBarEnabled will take care of the update as necessary.
	local skipUpdate = true;
	self:SetPowerType(alternatePowerType, alternatePowerName, skipUpdate);

	self:SetBarEnabled(self.powerType ~= nil and self.powerName ~= nil);
end

function AlternatePowerBarMixin:OnBarEnabled()
	self:RegisterEvent("UNIT_POWER_UPDATE");
	self:RegisterEvent("UNIT_MAXPOWER");

	self:Update();
end

function AlternatePowerBarMixin:OnBarDisabled()
	self:UnregisterEvent("UNIT_POWER_UPDATE");
	self:UnregisterEvent("UNIT_MAXPOWER");
end

function AlternatePowerBarMixin:Update()
	if not self:IsBarEnabled() then
		return;
	end

	self:UpdateArt();
	self:UpdateMinMaxPower();
	self:UpdatePower();
end

function AlternatePowerBarMixin:SetPowerType(powerType, powerName, skipUpdate)
	self.powerType = powerType;
	self.powerName = powerName;

	if not skipUpdate then
		self:Update();
	end
end

function AlternatePowerBarMixin:GetCurrentPower()
	return UnitPower(self:GetUnit(), self.powerType);
end

function AlternatePowerBarMixin:GetCurrentMinMaxPower()
	local maxPower = UnitPowerMax(self:GetUnit(), self.powerType);
	return 0, maxPower;
end