BREWMASTER_POWER_BAR_NAME = "STAGGER";

-- percentages at which bar should change color
STAGGER_YELLOW_TRANSITION = .30
STAGGER_RED_TRANSITION = .60

-- table indices of bar colors
STAGGER_GREEN_INDEX = 1;
STAGGER_YELLOW_INDEX = 2;
STAGGER_RED_INDEX = 3;

function MonkStaggerBar_OnLoad(self)
	self.specRestriction = SPEC_MONK_BREWMASTER;
	self.textLockable = 1;
	self.cvar = "statusText";
	self.cvarLabel = "STATUS_TEXT_PLAYER";
	self.capNumericDisplay = true;
	if ( not self.powerName ) then
		self.powerName = BREWMASTER_POWER_BAR_NAME;
	end

	self.DefaultBackground:Hide();
	self.DefaultBorder:Hide();
	self.DefaultBorderLeft:Hide();
	self.DefaultBorderRight:Hide();
	self.MonkBackground:Show();
	self.MonkBorder:Show();
	self:SetFrameLevel(100);

	local _, class = UnitClass("player")
	self.class = class
	if (class == "MONK") then
		if (self.specRestriction == GetSpecialization()) then
			MonkStaggerBar_RegisterEvents(self);
		end
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	SetTextStatusBarText(self, _G[self:GetName().."Text"])
	TextStatusBar_Initialize(self);
end

function MonkStaggerBar_OnEvent(self, event, arg1)
	local parent = self:GetParent();
	if ( event == "UNIT_DISPLAYPOWER" or event == "UPDATE_VEHICLE_ACTIONBAR" or event == "UNIT_EXITED_VEHICLE" ) then
		MonkStaggerBar_UpdatePowerType(self);
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		if ( arg1 == nil or arg1 == parent.unit) then
			MonkStaggerBar_UpdatePowerType(self);
			if (self.specRestriction == GetSpecialization()) then
				MonkStaggerBar_RegisterEvents(self);
			end
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		MonkStaggerBar_UpdateMaxValues(self);
		MonkStaggerBar_UpdatePowerType(self);
	end
end

function MonkStaggerBar_OnUpdate(self, elapsed)
	MonkStaggerBar_UpdateValue(self);
end

function MonkStaggerBar_RegisterEvents(self)
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
end

function MonkStaggerBar_UpdateValue(self)
	local currstagger = UnitStagger(self:GetParent().unit);
	if (not currstagger) then
		return;
	end
	self:SetValue(currstagger);
	self.value = currstagger;
	MonkStaggerBar_UpdateMaxValues(self);

	local _, maxstagger = self:GetMinMaxValues();
	local percent = currstagger/maxstagger;
	local info = PowerBarColor[self.powerName];

	if (percent >= STAGGER_RED_TRANSITION) then
		info = info[STAGGER_RED_INDEX];
	elseif (percent >= STAGGER_YELLOW_TRANSITION) then
		info = info[STAGGER_YELLOW_INDEX];
	else
		info = info[STAGGER_GREEN_INDEX];
	end
	self:SetStatusBarColor(info.r, info.g, info.b);
end

function MonkStaggerBar_UpdateMaxValues(self)
	local maxhealth = UnitHealthMax(self:GetParent().unit);
	self:SetMinMaxValues(0, maxhealth);
	TextStatusBar_UpdateTextString(self);
end

function MonkStaggerBar_UpdatePowerType(self)
	if (self.class == "MONK" and self.specRestriction == GetSpecialization()
			and not UnitHasVehiclePlayerFrameUI("player") ) then
		self.pauseUpdates = false;
		MonkStaggerBar_UpdateValue(self);
		self:Show();
	else
		self.pauseUpdates = true;
		self:Hide();
	end
end