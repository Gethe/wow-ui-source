ADDITIONAL_POWER_BAR_NAME = "MANA";
ADDITIONAL_POWER_BAR_INDEX = 0;

function AlternatePowerBar_OnLoad(self)
	self.textLockable = 1;
	self.cvar = "statusText";
	self.cvarLabel = "STATUS_TEXT_PLAYER";
	self.capNumericDisplay = true;
	AlternatePowerBar_Initialize(self);
	TextStatusBar_Initialize(self);
end

function AlternatePowerBar_Initialize(self)
	if ( not self.powerName ) then
		self.powerName = ADDITIONAL_POWER_BAR_NAME;
		self.powerIndex = ADDITIONAL_POWER_BAR_INDEX;
	end

	self:RegisterEvent("UNIT_POWER_UPDATE");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");

	SetTextStatusBarText(self, _G[self:GetName().."Text"])

	local info = PowerBarColor[self.powerName];
	self:SetStatusBarColor(info.r, info.g, info.b);
end

function AlternatePowerBar_OnEvent(self, event, ...)
	if ( event == "UNIT_DISPLAYPOWER" or event == "UPDATE_VEHICLE_ACTIONBAR" or event == "UNIT_EXITED_VEHICLE" ) then
		AlternatePowerBar_UpdatePowerType(self);
	elseif ( event=="PLAYER_ENTERING_WORLD" ) then
		AlternatePowerBar_UpdateMaxValues(self);
		AlternatePowerBar_UpdatePowerType(self);
	elseif( (event == "UNIT_MAXPOWER") ) then
		local unitTag = ...;
		local parent = self:GetParent();
		if unitTag == parent.unit then
			AlternatePowerBar_UpdateMaxValues(self);
		end
	elseif ( self:IsShown() ) then
		if ( (event == "UNIT_POWER_UPDATE") ) then
			local unitTag = ...;
			local parent = self:GetParent();
			if unitTag == parent.unit then
				AlternatePowerBar_UpdateValue(self);
			end
		end
	end
end

function AlternatePowerBar_OnUpdate(self, elapsed)
	AlternatePowerBar_UpdateValue(self);
	TextStatusBar_UpdateTextString(self);
end

function AlternatePowerBar_UpdateValue(self)
	local currentPower = UnitPower(self:GetParent().unit,self.powerIndex);
	self:SetValue(currentPower);
	self.value = currentPower
end

function AlternatePowerBar_UpdateMaxValues(self)
	local maxPower = UnitPowerMax(self:GetParent().unit,self.powerIndex);
	self:SetMinMaxValues(0, maxPower);
end

ALT_MANA_BAR_PAIR_DISPLAY_INFO = {
	DRUID = {
		[Enum.PowerType.LunarPower] = true,
	},
	PRIEST = {
		[Enum.PowerType.Insanity] = true,
	},
	SHAMAN = {
		[Enum.PowerType.Maelstrom] = true,
	},
};

function AlternatePowerBar_ShouldDisplayPower(self)
	if UnitHasVehiclePlayerFrameUI("player") then
		return false;
	end

	if UnitPowerMax(self:GetParent().unit, self.powerIndex) == 0 then
		return false;
	end

	local _, class = UnitClass(self:GetParent().unit);
	if ALT_MANA_BAR_PAIR_DISPLAY_INFO[class] then
		local powerType = UnitPowerType(self:GetParent().unit);
		return ALT_MANA_BAR_PAIR_DISPLAY_INFO[class][powerType];
	end

	return false;
end

function AlternatePowerBar_UpdatePowerType(self)
	if AlternatePowerBar_ShouldDisplayPower(self) then
		self.pauseUpdates = false;
		AlternatePowerBar_UpdateValue(self);
		self:Show();
	else
		self.pauseUpdates = true;
		self:Hide();
	end
end
