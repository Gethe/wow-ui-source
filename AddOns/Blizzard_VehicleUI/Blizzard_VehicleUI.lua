SLIDER1_MIN = 0;
SLIDER1_MAX = 100;
SLIDER1_DEFAULT_VALUE = 50;

SLIDER2_MIN = 0;
SLIDER2_MAX = 100;
SLIDER2_DEFAULT_VALUE = 50;

function math.round (num, idp)
  return math.floor(num  * 10^(idp or 0) + 0.5) / 10^(idp or 0)
end

local cvars = { 
	["VehiclePower"] = { ["max"] = 1 },
	["VehicleAngle"] = { ["max"] = 1 },
	}

function VehicleSlider_UpdateCVar (slider)
	if ( not slider or not slider.cvar or not cvars[slider.cvar] ) then
		return;
	end

	
	SetCVar(slider.cvar, (cvars[slider.cvar].max or 1) * (slider:GetValue() / 100))
end

local eventTab;
function VehicleSlider1_OnEvent (...)
	local self = ...;
	eventTab = { ... };
	tremove(eventTab, 1);
	
	if ( eventTab[1] == "ADDON_LOADED" and eventTab[2] == "Blizzard_VehicleUI" ) then
		if ( self.cvar and cvars[self.cvar] ) then
			self:SetValue(100 - (GetCVar(self.cvar) / cvars[self.cvar].max) * 100);
		else
			self:SetValue(SLIDER1_DEFAULT_VALUE);
		end
	end
end

function VehicleSlider2_OnEvent (...)
	local self = ...;
	eventTab = { ... };
	tremove(eventTab, 1);
	
	if ( eventTab[1] == "ADDON_LOADED" and eventTab[2] == "Blizzard_VehicleUI" ) then
		if ( self.cvar and cvars[self.cvar] ) then
			self:SetValue(100 - (GetCVar(self.cvar) / cvars[self.cvar].max) * 100);
		else
			self:SetValue(SLIDER2_DEFAULT_VALUE);
		end
		self:SetScript("OnValueChanged", VehicleSlider2_OnValueChanged);
	elseif ( eventTab[1] == "VEHICLE_ANGLE_UPDATE" ) then
		self:SetScript("OnValueChanged", nil);
		self:SetValue(100 - (GetCVar(self.cvar) / cvars[self.cvar].max) * 100);
		VehicleSlider2SliderText:SetText(math.round(this:GetValue()));
		VehicleSlider2SliderText:SetPoint("LEFT", VehicleSlider2SliderThumb, "RIGHT", 0, 2);
		self:SetScript("OnValueChanged", VehicleSlider2_OnValueChanged);
	end
end

function VehicleSlider2_OnValueChanged ()
	VehicleSlider2SliderText:ClearAllPoints()
	VehicleSlider2SliderText:SetPoint("LEFT", VehicleSlider2SliderThumb, "RIGHT", 0, 2);
	VehicleSlider2SliderText:SetText(math.round(this:GetValue()));
	VehicleSlider_UpdateCVar(this);
end

