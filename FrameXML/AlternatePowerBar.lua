ADDITIONAL_POWER_BAR_NAME = "MANA";
ADDITIONAL_POWER_BAR_INDEX = 0;

function AlternatePowerBar_OnLoad(self)
	self.textLockable = 1;
	self.cvar = "playerStatusText";
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
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		if ( arg1 == parent.unit ) then
			AlternatePowerBar_SetLook(self);
			AlternatePowerBar_UpdatePowerType(self);
		end
	elseif ( event=="PLAYER_ENTERING_WORLD" ) then
		local _, class = UnitClass("player");
		if ( class == "MONK" ) then
			self.specRestriction = SPEC_MONK_MISTWEAVER;
			self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
			AlternatePowerBar_SetLook(self);
		end
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
	if ( (UnitPowerType(self:GetParent().unit) ~= self.powerIndex) and (UnitPowerMax(self:GetParent().unit,self.powerIndex) ~= 0) and ( not self.specRestriction or self.specRestriction == GetSpecialization() ) 
		and not UnitHasVehiclePlayerFrameUI("player") ) then
		self.pauseUpdates = false;
		AlternatePowerBar_UpdateValue(self);
		self:Show();
	else
		self.pauseUpdates = true;
		self:Hide();
	end
end

function AlternatePowerBar_SetLook(self)
	local _, class = UnitClass("player");
	if ( class == "MONK" and (GetSpecialization() == SPEC_MONK_MISTWEAVER or GetSpecialization() == SPEC_MONK_BREWMASTER)) then
		self:SetWidth(94);
		self:SetPoint("BOTTOMLEFT", 118, 4);
		self.DefaultBackground:Hide();
		self.DefaultBorder:Hide();
		self.DefaultBorderLeft:Hide();
		self.DefaultBorderRight:Hide();
		self.MonkBackground:Show();
		self.MonkBorder:Show();
		self:SetFrameLevel(100);
	else
		self:SetWidth(104);
		self:SetPoint("BOTTOMLEFT", 114, 23);
		self.DefaultBackground:Show();
		self.DefaultBorder:Show();
		self.DefaultBorderLeft:Show();
		self.DefaultBorderRight:Show();
		self.MonkBackground:Hide();
		self.MonkBorder:Hide();
		self:SetFrameLevel(0);
	end
end