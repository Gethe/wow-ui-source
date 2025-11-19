BREWMASTER_POWER_BAR_NAME = "STAGGER";

-- percentages at which bar should change color
STAGGER_YELLOW_TRANSITION = .30
STAGGER_RED_TRANSITION = .60

-- table indices of bar colors
local GREEN_INDEX = 1;
local YELLOW_INDEX = 2;
local RED_INDEX = 3;

MonkStaggerBarMixin = {}

function MonkStaggerBarMixin:OnLoad()
	self.specRestriction = SPEC_MONK_BREWMASTER;
	self.textLockable = 1;
	self.cvar = "playerStatusText";
	self.cvarLabel = "STATUS_TEXT_PLAYER";
	self.capNumericDisplay = true;
	if ( not self.powerName ) then
		self.powerName = BREWMASTER_POWER_BAR_NAME;
	end
	local _, class = UnitClass("player")
	self.class = class
	if (class == "MONK") then
		if (self.specRestriction == C_SpecializationInfo.GetSpecialization()) then
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			self:RegisterEvent("UNIT_DISPLAYPOWER");
			self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");	
		end
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	end
	self:UpdatePowerType();
	self:SetBarText(_G[self:GetName().."Text"])
	self:InitializeTextStatusBar();
end

function MonkStaggerBarMixin:OnEvent(event, arg1)
	local parent = self:GetParent();
	if ( event == "UNIT_DISPLAYPOWER" or event == "UPDATE_VEHICLE_ACTIONBAR" ) then
		self:UpdatePowerType();
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		if ( arg1 == nil or arg1 == parent.unit) then
			AlternatePowerBar_SetLook(self);
			self:UpdatePowerType();
			if (self.specRestriction == C_SpecializationInfo.GetSpecialization()) then
				self:RegisterEvent("PLAYER_ENTERING_WORLD");
				self:RegisterEvent("UNIT_DISPLAYPOWER");
				self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");	
			end
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		AlternatePowerBar_SetLook(self);
		self:UpdateMaxValues();
		self:UpdatePowerType();
	end
end

function MonkStaggerBarMixin:OnUpdate(elapsed)
	self:UpdateValue();
end

function MonkStaggerBarMixin:UpdateValue()
	if not self:GetParent() then
		return;
	end
	local currstagger = UnitStagger(self:GetParent().unit);
	if (not currstagger) then
		return;
	end
	self:SetValue(currstagger);
	self.value = currstagger
	self:UpdateMaxValues()
	
	local _, maxstagger = self:GetMinMaxValues();
	local percent = currstagger/maxstagger;
	local info = PowerBarColor[self.powerName];
	
	
	if (percent > STAGGER_YELLOW_TRANSITION and percent < STAGGER_RED_TRANSITION) then
		info = info[YELLOW_INDEX];
	elseif (percent > STAGGER_RED_TRANSITION) then
		info = info[RED_INDEX];
	else
		info = info[GREEN_INDEX];
	end
	self:SetStatusBarColor(info.r, info.g, info.b);
end

function MonkStaggerBarMixin:UpdateMaxValues()
	local maxhealth = UnitHealthMax(self:GetParent().unit);
	self:SetMinMaxValues(0, maxhealth);
	self:UpdateTextString();
end

function MonkStaggerBarMixin:UpdatePowerType()
	if (self.class == "MONK" and self.specRestriction == C_SpecializationInfo.GetSpecialization() 
			and not UnitHasVehiclePlayerFrameUI("player") ) then
		self.pauseUpdates = false;
		self:UpdateValue();
		self:Show();
	else
		self.pauseUpdates = true;
		self:Hide();
	end
end
