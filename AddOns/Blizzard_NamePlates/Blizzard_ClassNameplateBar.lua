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
	elseif ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" ) then
		local spellID = select(10, UnitCastingInfo("player"));
		local cost = 0;
		if ( event == "UNIT_SPELLCAST_START" ) then
			local costTable = GetSpellPowerCost(spellID);
			for _, costInfo in pairs(costTable) do
				if (costInfo.type == self.powerType) then
					cost = costInfo.cost;
					break;
				end
			end
		end
		self.predictedPowerCost = cost;
		self:SetupBar();
	else
		ClassNameplateBar.OnEvent(self, event, arg1, arg2);
	end
end

function ClassNameplateManaBar:Setup()
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit);
	self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	local tex = self:GetStatusBarTexture();
	local bar = self.ManaCostPredictionBar;

	bar:ClearAllPoints();
	bar:SetPoint("TOPLEFT", tex, "TOPRIGHT", 0, 0);
	bar:SetPoint("BOTTOMLEFT", tex, "BOTTOMRIGHT", 0, 0);

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
			
		self.FullPowerFrame:SetSize(86, 6);
		self.FullPowerFrame.SpikeFrame:SetSize(86, 6);
		self.FullPowerFrame.PulseFrame:SetSize(86, 6);
		self.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetSize(30, 12);
		self.FullPowerFrame.PulseFrame.YellowGlow:SetSize(20, 20);
		self.FullPowerFrame.PulseFrame.SoftGlow:SetSize(20, 20);
		self.FullPowerFrame:Initialize(info.fullPowerAnim);
	end
	self.powerToken = powerToken;
	self.powerType = powerType;
	self:UpdateMaxPower();
	self:UpdatePower();
	local predictedCost = self.predictedPowerCost or 0;
	self.currValue = UnitPower("player", self.powerType) - predictedCost;
end

function ClassNameplateManaBar:UpdateMaxPower()
	local maxValue = UnitPowerMax("player", self.powerType);
	self:SetMinMaxValues(0, maxValue);
	self.FullPowerFrame:SetMaxValue(maxValue);
end

function ClassNameplateManaBar:UpdatePower()
	local predictedCost = self.predictedPowerCost or 0;
	local currValue = UnitPower("player", self.powerType) - predictedCost;
	self:SetValue(currValue);
	if (predictedCost == 0) then
		self.ManaCostPredictionBar:Hide();
	else
		local bar = self.ManaCostPredictionBar;

		local totalWidth = self:GetWidth();
		local _, totalMax = self:GetMinMaxValues();

		local barSize = (predictedCost / totalMax) * totalWidth;
		bar:SetWidth(barSize);
		bar:Show();
	end
end

function ClassNameplateManaBar_OnUpdate(self)
	local predictedCost = self.predictedPowerCost or 0;
	local currValue = UnitPower("player", self.powerType) - predictedCost;
	if ( currValue ~= self.currValue ) then
		-- Only show anim if change is more than 10%
		if ( math.abs(currValue - self.currValue) / self.FeedbackFrame.maxValue > 0.1 ) then
			self.FeedbackFrame:StartFeedbackAnim(self.currValue or 0, currValue);
		end
		if ( self.FullPowerFrame.active ) then
			self.FullPowerFrame:StartAnimIfFull(self.currValue or 0, currValue);
		end
		self.currValue = currValue;
	end
end
