ADDITIONAL_POWER_BAR_NAME = "MANA";
ADDITIONAL_POWER_BAR_INDEX = 0;

function AlternatePowerBar_OnLoad(self)
	local _, class = UnitClass("player");
	if (class ~= "PRIEST" and class ~= "SHAMAN" and class ~= "MONK") then -- TODO: Task 86565, This 'hack' removes the alternate power bar from Shadow Priests, but maybe the code as a whole should be restructured
		self.textLockable = 1;
		self.cvar = "playerStatusText";
		self.cvarLabel = "STATUS_TEXT_PLAYER";
		self.capNumericDisplay = true;
		AlternatePowerBar_Initialize(self);
		TextStatusBar_Initialize(self);
	else
		self:Hide();
	end
end

function AlternatePowerBar_Initialize(self)
	if ( not self.powerName ) then
		self.powerName = ADDITIONAL_POWER_BAR_NAME;
		self.powerIndex = ADDITIONAL_POWER_BAR_INDEX;
	end
	
	self:RegisterEvent("UNIT_POWER");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
	
	SetTextStatusBarText(self, _G[self:GetName().."Text"])
	
	local info = PowerBarColor[self.powerName];
	self:SetStatusBarColor(info.r, info.g, info.b);
end

function AlternatePowerBar_OnEvent(self, event, arg1)
	local parent = self:GetParent();
	if ( event == "UNIT_DISPLAYPOWER" or event == "UPDATE_VEHICLE_ACTIONBAR" ) then
		AlternatePowerBar_UpdatePowerType(self);
	elseif ( event=="PLAYER_ENTERING_WORLD" ) then
		local _, class = UnitClass("player");
		AlternatePowerBar_UpdateMaxValues(self);
		AlternatePowerBar_UpdatePowerType(self);
	elseif( (event == "UNIT_MAXPOWER") and (arg1 == parent.unit) ) then
		AlternatePowerBar_UpdateMaxValues(self);
	elseif ( self:IsShown() ) then
		if ( (event == "UNIT_POWER") and (arg1 == parent.unit) ) then
			AlternatePowerBar_UpdateValue(self);
		end
	end
end

function AlternatePowerBar_OnUpdate(self, elapsed)
	AlternatePowerBar_UpdateValue(self);
end

function AlternatePowerBar_UpdateValue(self)
	local currmana = UnitPower(self:GetParent().unit,self.powerIndex);
	self:SetValue(currmana);
	self.value = currmana
end

function AlternatePowerBar_UpdateMaxValues(self)
	local maxmana = UnitPowerMax(self:GetParent().unit,self.powerIndex);
	self:SetMinMaxValues(0,maxmana);
end

function AlternatePowerBar_UpdatePowerType(self)
	local _, class = UnitClass(self:GetParent().unit);
	local powerType = UnitPowerType(self:GetParent().unit);
	
	if ( (class == "DRUID") and (powerType == SPELL_POWER_LUNAR_POWER) and (UnitPowerMax(self:GetParent().unit,self.powerIndex) ~= 0) 
		and not UnitHasVehiclePlayerFrameUI("player") ) then
		self.pauseUpdates = false;
		AlternatePowerBar_UpdateValue(self);
		self:Show();
	else
		self.pauseUpdates = true;
		self:Hide();
	end
end
