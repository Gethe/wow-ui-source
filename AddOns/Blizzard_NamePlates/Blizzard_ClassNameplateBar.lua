ClassNameplateBar = {};

function ClassNameplateBar:OnLoad()
	--[[ 
		Initialize these variables in the class-specific OnLoad mixin function. Also make sure to implement
		a UpdatePower() mixin function that handles UI changes for whenever the power display changes
	self.class = "PALADIN";
	self.spec = SPEC_PALADIN_RETRIBUTION;
	self.powerTokens = {"HOLY_POWER", "MANA"}
	]]--
	
	self:Setup();
end

function ClassNameplateBar:OnEvent(event, arg1, arg2)
	if ( event == "UNIT_POWER_FREQUENT" and arg1 == "player" ) then
		if (self.powerToken == arg2 ) then
			self:UpdatePower();
		end
	elseif ( event == "UNIT_MAXPOWER" and arg1 == "player" ) then
		self:UpdateMaxPower();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdatePower();
	elseif (event == "PLAYER_TALENT_UPDATE" ) then
		self:Setup();
		self:UpdatePower();
	else
		return false;
	end
	return true;
end

function ClassNameplateBar:MatchesClass()
	local _, myclass = UnitClass("player");
	return myclass == self.class;
end

function ClassNameplateBar:MatchesSpec()
	if ( not self.spec ) then
		return true;
	end
	local myspec = GetSpecialization();
	return myspec == self.spec;
end
	
function ClassNameplateBar:Setup()
	local showBar = false;
	
	if ( self:MatchesClass() ) then
		if ( self:MatchesSpec() ) then
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
			self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			showBar = true;
		else
			self:UnregisterEvent("UNIT_POWER_FREQUENT");
			self:UnregisterEvent("UNIT_MAXPOWER");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		end
		
		self:RegisterEvent("PLAYER_TALENT_UPDATE");
	end
	if (showBar) then
		self:ShowNameplateBar();
		self:UpdateMaxPower();
	end
	return showBar;
end

function ClassNameplateBar:ShowNameplateBar()
	self:Show();
	NamePlateDriverFrame:SetClassNameplateBar(self);
end

function ClassNameplateBar:HideNameplateBar()
	self:Hide();
	NamePlateDriverFrame:SetClassNameplateBar(nil);
end

function ClassNameplateBar:TurnOn(frame, texture, toAlpha)
	ClassPowerBar:TurnOn(frame, texture, toAlpha);
end

function ClassNameplateBar:TurnOff(frame, texture, toAlpha)
	ClassPowerBar:TurnOff(frame, texture, toAlpha);
end

function ClassNameplateBar:UpdateMaxPower()
end

function ClassNameplateBar:UpdatePower()
end


--------------------------------------------------------------------------------
--
-- ClassNameplateManaBar
--
--------------------------------------------------------------------------------

ClassNameplateManaBar = {};

local NameplatePowerBarColor = {
	["MANA"] = { r = 0.1, g = 0.25, b = 1.00 }
};

function ClassNameplateManaBar:OnEvent(event, arg1, arg2)
	if (event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MAXPOWER") then
		self:SetupBar();
		if (event == "UNIT_MAXPOWER") then
			ClassNameplateBar.OnEvent(self, event, arg1, arg2);
		end
	else
		ClassNameplateBar.OnEvent(self, event, arg1, arg2);
	end
end

function ClassNameplateManaBar:Setup()
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	self:Show();
	NamePlateDriverFrame:SetClassNameplateManaBar(self);
end

function ClassNameplateManaBar:SetupBar()
	local powerType, powerToken = UnitPowerType("player");
	if (powerToken) then
		local info = NameplatePowerBarColor[powerToken];
		if (not info) then
			info = PowerBarColor[powerToken];
		end
		self:SetStatusBarColor(info.r, info.g, info.b);

		self.FeedbackFrame:Initialize(info, "player", powerType);
		self:SetScript("OnUpdate", ClassNameplateManaBar_OnUpdate);
	end
	self.powerToken = powerToken;
	self.powerType = powerType;
	self:UpdateMaxPower();
	self:UpdatePower();
	self.currValue = UnitPower("player", powerType);
end

function ClassNameplateManaBar:UpdateMaxPower()
	self:SetMinMaxValues(0, UnitPowerMax("player", self.powerType));
end

function ClassNameplateManaBar:UpdatePower()
	self:SetValue(UnitPower("player", self.powerType));
end

function ClassNameplateManaBar_OnUpdate(self)
	local currValue = UnitPower("player", self.powerType);
	if ( currValue ~= self.currValue ) then
		-- Only show anim if change is more than 10%
		if ( math.abs(currValue - self.currValue) / self.FeedbackFrame.maxValue > 0.1 ) then
			self.FeedbackFrame:StartFeedbackAnim(self.currValue or 0, currValue);
		end
		self.currValue = currValue;
	end
end
